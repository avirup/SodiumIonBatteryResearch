# Lab Chapter 6: Equivalent Circuit Models from Scratch

## Chapter Opening

This chapter is where the battery modeling story changes scale. In Part II we worked with electrochemical models in PyBaMM because they preserve the physics you learned in the theory text. In this chapter we deliberately step down to models that are much simpler, much faster, and much more common inside real battery-management systems: equivalent circuit models, or ECMs. By the time you finish, you will be able to build `Rint`, `1RC`, and `2RC` cell models from first principles in MATLAB, identify their parameters from pulse data, build SOC-dependent lookup tables in the Plett style, and validate the resulting model with the kind of discipline reviewers expect when they read a BMS paper.

Keep Textbook Chapter 10 open as you work. This chapter operationalizes the ECM material from that chapter, especially the reasons ECMs remain dominant in embedded BMS work even though DFN-style models are physically richer. The circuit elements are not magic. The OCV source is the equilibrium thermodynamics you already know. The series resistor approximates the immediate ohmic drop from current collectors, electrolyte, and contact resistance. The RC branches stand in for slower polarization and diffusion effects that a full porous-electrode model would resolve directly. If Textbook Chapter 10 gave you the intuition, this lab gives you the workflow.

This chapter also leans on Textbook Chapter 3, where you learned to interpret capacity, SOC, usable energy, rate capability, and hysteresis, and on the sodium-ion chemistry chapter, where you saw that sodium-ion full-cell OCV curves can look very different from the familiar lithium-ion NMC/graphite case. Those differences matter here. A battery-management algorithm never sees "the chemistry" directly. It sees current, voltage, temperature, and maybe a few carefully designed lookup tables. If those tables were identified casually, the entire estimator stack that sits on top of them inherits the error.

Publishable ECM work is not about drawing a resistor-capacitor schematic and calling it a day. It is about making a sequence of modeling decisions honestly. Which model order is justified by the data? What excitation protocol makes the parameters observable? How do you separate OCV from dynamic polarization? How do you validate on data the model did not see during fitting? What error level is small enough to be useful and large enough to keep you humble? Those questions are more important than the exact optimizer you use.

We will move deliberately. First we will build ECMs from scratch in plain MATLAB so every state and parameter has a physical interpretation. Then we will fit a single pulse so you can see exactly where `R0`, `R1`, `C1`, `R2`, and `C2` come from. After that we will build SOC-dependent parameter tables from a full synthetic HPPC suite, because that workflow is still the clearest way to learn the craft. Only once the logic is secure will we bring in a real public dataset. For this chapter we will use the CALCE Samsung INR 18650-20R open-access files, whose workbook structure we will parse directly in MATLAB. The publicly exposed CALCE portal is strongest on low-current OCV and dynamic-test workbooks rather than on a tidy, one-click "HPPC" archive, so we will use the real CALCE OCV data to build the OCV table and keep the pulse-identification workflow tool-agnostic so you can drop in any HPPC file once you have one.

One more expectation-setting note matters here. This chapter is intentionally more procedural than the PyBaMM chapters. In PyBaMM, the software often carries a lot of the bookkeeping for you. In ECM work, especially in MATLAB, you will do much more of the bookkeeping yourself. That is a feature, not a bug. It is how you learn where every assumption enters.

## Prerequisites Check

- Required software: `MATLAB R2024b` or newer recommended
- Required toolboxes for the core chapter: `Optimization Toolbox`
- Optional for the last guided walkthrough: `Simulink`, `Simscape`, and `Simscape Battery R2025a+`
- Required textbook chapters: Textbook Chapter 10 is essential; Textbook Chapter 3 is strongly recommended; your sodium-ion chemistry chapter is recommended for the sodium-ion adaptation section
- Required prior lab chapters: Lab Chapters 1 and 2 are assumed; Lab Chapters 3 through 5 are not required, but they help if you want to compare ECM and PyBaMM workflows later
- Estimated time: 14 to 18 hours for the full chapter, or 10 to 12 hours if you stop after the core MATLAB workflow and skip the optional Simscape Battery section

If `lsqcurvefit`, `lsqnonlin`, or `readtable` still feel unfamiliar, revisit the optimization and data-handling material from Lab Chapter 2 before you begin. If the distinction between OCV, polarization, and ohmic drop feels fuzzy, pause and reread the equivalent-circuit sections of Textbook Chapter 10 before you touch the first code block.

## Environment Setup

The core of this chapter is plain MATLAB plus the Optimization Toolbox. We will keep the optional Simscape Battery section explicitly separate so the chapter remains runnable even if you only have base MATLAB and optimization.

### Step 1: Verify MATLAB and toolbox availability

Open MATLAB and run:

```matlab
ver
license('test', 'Optimization_Toolbox')
license('test', 'SIMULINK')
license('test', 'Simscape')
license('test', 'Simscape_Battery')
```

Expected behavior:

- `ver` should print your MATLAB release plus installed toolboxes.
- `license('test', 'Optimization_Toolbox')` should return `1`.
- The Simulink and Simscape checks may return `0`; that is fine for the core chapter.

If you do not have the Optimization Toolbox, the core nonlinear fits in this chapter will not run as written. You can still read the chapter, but the code blocks assume `lsqcurvefit` and `lsqnonlin` are available.

### Step 2: Create a clean working folder

Run this once at the top of a fresh Live Script or MATLAB session:

```matlab
chapterRoot = fullfile(pwd, "chapter6_ecm_workspace");
if ~exist(chapterRoot, "dir")
    mkdir(chapterRoot);
end
cd(chapterRoot);

fprintf("Working folder: %s\n", chapterRoot);
```

Expected output:

```text
Working folder: /.../chapter6_ecm_workspace
```

The exact path will differ on your machine. The point is not the path itself. The point is that later in the chapter we will save lookup tables, exported CSV files, and MATLAB MAT-files here so the workflow stays reproducible.

### Step 3: Run a minimal "hello ECM" sanity check

Paste the following into a new script and run it end to end:

```matlab
clear; close all; clc;

time_s = (0:1:300).';
current_a = zeros(size(time_s));
current_a(time_s >= 20 & time_s < 140) = 2.0;

capacity_ah = 2.3;
initial_soc = 0.90;
ocv_soc = [0.00 0.10 0.20 0.40 0.60 0.80 1.00].';
ocv_v =  [3.00 3.30 3.45 3.62 3.78 3.95 4.18].';

R0 = 0.015;
R1 = 0.012;
C1 = 90;

soc = zeros(size(time_s));
v_rc = zeros(size(time_s));
voltage_v = zeros(size(time_s));

soc(1) = initial_soc;
dt = time_s(2) - time_s(1);
alpha = exp(-dt / (R1 * C1));

for k = 1:numel(time_s)
    if k > 1
        soc(k) = soc(k - 1) - current_a(k - 1) * dt / (3600 * capacity_ah);
        soc(k) = min(max(soc(k), 0), 1);
        v_rc(k) = alpha * v_rc(k - 1) + R1 * (1 - alpha) * current_a(k - 1);
    end

    ocv_now = interp1(ocv_soc, ocv_v, soc(k), "pchip", "extrap");
    voltage_v(k) = ocv_now - current_a(k) * R0 - v_rc(k);
end

figure("Color", "w");
subplot(2, 1, 1);
plot(time_s, current_a, "LineWidth", 1.5);
grid on;
xlabel("Time [s]");
ylabel("Current [A]");
title("Hello ECM current profile");

subplot(2, 1, 2);
plot(time_s, voltage_v, "LineWidth", 1.8);
grid on;
xlabel("Time [s]");
ylabel("Terminal voltage [V]");
title("Hello ECM voltage response");

fprintf("Initial voltage: %.3f V\n", voltage_v(1));
fprintf("Voltage at 60 s: %.3f V\n", voltage_v(time_s == 60));
fprintf("Voltage at 200 s: %.3f V\n", voltage_v(time_s == 200));
```

Expected output:

- The top subplot should show a single rectangular current pulse from `20 s` to `140 s` at `2.0 A`.
- The bottom subplot should start near `4.04 V`, drop immediately when the current pulse begins, bend downward slightly more as the RC branch charges, then recover upward once the pulse ends.
- The printed voltages should be physically plausible and should fall roughly in this range:

```text
Initial voltage: 4.040 V
Voltage at 60 s: 3.980 V
Voltage at 200 s: 4.000 V
```

The exact values will differ by a few millivolts if you alter the OCV table or parameters, but the qualitative shape should match exactly.

### Step 4: Optional setup for the Simscape Battery section

If you want the last guided walkthrough to run, you need `Simscape Battery` in `R2025a` or newer because we will use the `hppcTest`, `fitECM`, and `parameterizeEquivalentCircuitBlock` workflow introduced there.

You can verify those functions exist with:

```matlab
which hppcTest
which fitECM
which parameterizeEquivalentCircuitBlock
```

If MATLAB prints valid file paths, the optional section is available. If it prints `'hppcTest' not found`, skip that section without guilt. The core chapter is still complete.

### Common setup failures and fixes

1. `Undefined function 'lsqcurvefit' for input arguments of type 'double'`

   Symptom: the first parameter-identification walkthrough fails immediately.

   Fix: the Optimization Toolbox is not installed or licensed. Confirm with `license('test', 'Optimization_Toolbox')`.

2. `Error using readtable` when opening the CALCE workbook

   Symptom: MATLAB reads the wrong sheet or turns text headers into awkward variable names.

   Fix: use the exact sheet names shown later in the chapter and set `VariableNamingRule` to `"preserve"` so MATLAB does not silently rewrite headers.

3. The plotted voltage rises when discharge current is applied

   Symptom: your sign convention is flipped.

   Fix: throughout this chapter, the core hand-built ECM uses `positive current = discharge`. The CALCE Arbin files use `positive current = charge, negative current = discharge`, so we explicitly normalize them when we read them.

4. The OCV interpolation throws an error about nonmonotonic sample points

   Symptom: `interp1` complains when you pass a decreasing SOC vector.

   Fix: if a branch was recorded from `SOC = 1` down to `SOC = 0`, flip it with `flipud` before interpolating.

## Conceptual Bridge: From Textbook ECM Theory to MATLAB State Updates

In Textbook Chapter 10, you learned why ECMs survive in serious battery-management work even when everyone agrees they are less physical than DFN-style electrochemical models. The short answer is that BMS algorithms live under severe computational, sensing, and calibration constraints. They need models that are fast, robust, and observable from terminal measurements. An ECM gives up mechanistic detail in exchange for exactly that.

The central ECM equation for this chapter is

$$
V_t(t) = U_{\mathrm{oc}}(z(t)) - I(t)R_0 - \sum_{i=1}^{n} v_i(t),
\tag{1}
$$

where $V_t$ is the terminal voltage, $U_{\mathrm{oc}}(z)$ is the open-circuit voltage as a function of SOC $z$, $R_0$ is the instantaneous ohmic resistance, and each $v_i$ is the voltage across a polarization branch. The SOC state evolves by coulomb counting,

$$
\dot{z}(t) = -\frac{I(t)}{3600 Q},
\tag{2}
$$

where $Q$ is the usable cell capacity in ampere-hours and the factor of `3600` converts ampere-seconds to ampere-hours. For a standard Thevenin `1RC` model, the branch state obeys

$$
\dot{v}_1(t) = -\frac{1}{R_1 C_1} v_1(t) + \frac{1}{C_1} I(t).
\tag{3}
$$

For a `2RC` model, we duplicate that structure:

$$
\dot{v}_i(t) = -\frac{1}{R_i C_i} v_i(t) + \frac{1}{C_i} I(t), \quad i \in \{1, 2\}.
\tag{4}
$$

This is the software translation of the circuit diagrams you saw in the textbook. The OCV source handles equilibrium behavior. `R0` handles the immediate voltage step at a current transition. The RC branches handle relaxation on one or more time scales. In a full electrochemical model those time scales would arise from charge-transfer kinetics, electrolyte transport, solid diffusion, and sometimes thermal coupling. In an ECM we do not try to isolate each mechanism cleanly. We let a small number of branches approximate the aggregate dynamic behavior seen at the terminals.

That approximation only works if the experiment excites the dynamics we want to identify. This is why HPPC-style data are still so widely used. A pulse gives you several different observables at once:

- the immediate voltage jump estimates `R0`,
- the short relaxation helps identify the fast branch,
- the longer relaxation helps identify the slow branch,
- the rest windows anchor the local OCV.

This is also why standard practice in ECM work is more disciplined than beginners often assume. You do not fit all parameters everywhere all at once if you can avoid it. You isolate what you can from the pulse geometry, build an OCV table from low-current or rest-rich data, and then use nonlinear least squares only for what genuinely remains coupled.

The state update in MATLAB becomes especially transparent when we discretize the branch dynamics exactly over a fixed sample period `dt`. For one branch,

$$
v_{i,k+1} = \alpha_i v_{i,k} + R_i (1 - \alpha_i) I_k,
\quad
\alpha_i = \exp\left(-\frac{dt}{R_i C_i}\right).
\tag{5}
$$

Equation (5) is one of the most useful formulas in this chapter. It shows three things immediately. First, each branch has a time constant $\tau_i = R_i C_i$. Second, the branch voltage is bounded by the current-scaled resistance $I R_i$. Third, if you know `R_i` and `C_i`, the simulation step is just a few floating-point operations. That is why ECMs are so attractive inside estimators.

There is one more bridge we need before we touch the real data. An ECM is not "identified" when the optimizer returns a number. It is identified when four things are true at the same time:

1. the parameters came from a protocol rich enough to make them observable,
2. the fitted values are physically plausible and vary smoothly with SOC,
3. the model predicts held-out data credibly,
4. the chosen order is justified by the error reduction it buys.

That last point is worth pausing on. A `2RC` model is not automatically "better" than a `1RC` model just because it fits the training pulse more closely. It is better only if the extra branch captures behavior you care about later and does so without turning the parameter table into noise. In battery papers this distinction is often the difference between a useful model and an overfitted one.

We will keep returning to that standard. The workflow in this chapter is not "build the fanciest circuit you can." It is "build the simplest circuit that survives validation honestly."

## Guided Walkthrough 1: Build and Compare `Rint`, `1RC`, and `2RC` Models in Plain MATLAB

**Learning objective:** Understand exactly what each ECM order adds to the terminal-voltage response before you fit anything.

Before we estimate parameters from data, we need to learn to recognize the signatures of the different model orders with our own eyes. In this walkthrough we will simulate three models under the same current profile: a pure `Rint` model, a `1RC` Thevenin model, and a `2RC` model. The code is deliberately plain. We are not using Simulink, Simscape, or a hidden MATLAB app here because the fastest way to build intuition is to see the states being updated explicitly.

### Walkthrough 1 code

```matlab
clear; close all; clc;

% Time base and current profile
dt = 1;
time_s = (0:1:1200).';
current_a = zeros(size(time_s));

current_a(time_s >= 60  & time_s < 240) = 2.3;   % 1C discharge pulse
current_a(time_s >= 360 & time_s < 430) = 4.6;   % 2C discharge pulse
current_a(time_s >= 620 & time_s < 760) = -1.15; % 0.5C charge pulse
current_a(time_s >= 900 & time_s < 980) = 3.45;  % 1.5C discharge pulse

% A smooth but realistic full-cell OCV lookup table
ocv_soc = [0.00 0.05 0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00].';
ocv_v =  [3.00 3.15 3.27 3.42 3.53 3.62 3.70 3.79 3.89 4.00 4.09 4.18].';

% Cell metadata
capacity_ah = 2.3;
initial_soc = 0.95;

% Three candidate ECMs
rintModel = struct( ...
    "name", "Rint", ...
    "Q_ah", capacity_ah, ...
    "R0", 0.020, ...
    "R1", 0.000, ...
    "C1", 1.0, ...
    "R2", 0.000, ...
    "C2", 1.0);

oneRcModel = struct( ...
    "name", "1RC", ...
    "Q_ah", capacity_ah, ...
    "R0", 0.014, ...
    "R1", 0.012, ...
    "C1", 120.0, ...
    "R2", 0.000, ...
    "C2", 1.0);

twoRcModel = struct( ...
    "name", "2RC", ...
    "Q_ah", capacity_ah, ...
    "R0", 0.011, ...
    "R1", 0.010, ...
    "C1", 55.0, ...
    "R2", 0.018, ...
    "C2", 700.0);

rintResult = simulateEcm(time_s, current_a, initial_soc, ocv_soc, ocv_v, rintModel);
oneRcResult = simulateEcm(time_s, current_a, initial_soc, ocv_soc, ocv_v, oneRcModel);
twoRcResult = simulateEcm(time_s, current_a, initial_soc, ocv_soc, ocv_v, twoRcModel);

% Plot current and voltage
figure("Color", "w", "Position", [100 100 1000 720]);

subplot(3, 1, 1);
plot(time_s, current_a, "k", "LineWidth", 1.5);
grid on;
xlabel("Time [s]");
ylabel("Current [A]");
title("Shared current profile");

subplot(3, 1, 2);
plot(time_s, rintResult.voltage_v, "LineWidth", 1.8); hold on;
plot(time_s, oneRcResult.voltage_v, "LineWidth", 1.8);
plot(time_s, twoRcResult.voltage_v, "LineWidth", 1.8);
grid on;
xlabel("Time [s]");
ylabel("Terminal voltage [V]");
title("Voltage response of three ECM orders");
legend("Rint", "1RC", "2RC", "Location", "best");

subplot(3, 1, 3);
plot(time_s, oneRcResult.v1_v, "LineWidth", 1.6); hold on;
plot(time_s, twoRcResult.v1_v, "--", "LineWidth", 1.6);
plot(time_s, twoRcResult.v2_v, "-.", "LineWidth", 1.6);
grid on;
xlabel("Time [s]");
ylabel("Polarization branch voltage [V]");
title("Internal branch voltages");
legend("1RC branch", "2RC fast branch", "2RC slow branch", "Location", "best");

fprintf("Voltage at the end of the 2C pulse:\n");
fprintf("  Rint : %.4f V\n", rintResult.voltage_v(time_s == 429));
fprintf("  1RC  : %.4f V\n", oneRcResult.voltage_v(time_s == 429));
fprintf("  2RC  : %.4f V\n", twoRcResult.voltage_v(time_s == 429));


function result = simulateEcm(time_s, current_a, initial_soc, ocv_soc, ocv_v, model)
    n = numel(time_s);
    dt = time_s(2) - time_s(1);

    soc = zeros(n, 1);
    voltage_v = zeros(n, 1);
    v1_v = zeros(n, 1);
    v2_v = zeros(n, 1);

    soc(1) = initial_soc;

    if model.R1 > 0
        alpha1 = exp(-dt / (model.R1 * model.C1));
    else
        alpha1 = 0;
    end

    if model.R2 > 0
        alpha2 = exp(-dt / (model.R2 * model.C2));
    else
        alpha2 = 0;
    end

    for k = 1:n
        if k > 1
            soc(k) = soc(k - 1) - current_a(k - 1) * dt / (3600 * model.Q_ah);
            soc(k) = min(max(soc(k), 0), 1);

            if model.R1 > 0
                v1_v(k) = alpha1 * v1_v(k - 1) ...
                    + model.R1 * (1 - alpha1) * current_a(k - 1);
            end

            if model.R2 > 0
                v2_v(k) = alpha2 * v2_v(k - 1) ...
                    + model.R2 * (1 - alpha2) * current_a(k - 1);
            end
        end

        ocv_now = interp1(ocv_soc, ocv_v, soc(k), "pchip", "extrap");
        voltage_v(k) = ocv_now - current_a(k) * model.R0 - v1_v(k) - v2_v(k);
    end

    result = struct( ...
        "soc", soc, ...
        "voltage_v", voltage_v, ...
        "v1_v", v1_v, ...
        "v2_v", v2_v);
end
```

### Walkthrough 2 explanation

The first block creates a current profile with four informative regions: a mild discharge, a hard discharge, a charge pulse, and a final medium discharge. We could have used one pulse only, but the chapter is about pattern recognition. Multiple pulse amplitudes make the differences between the models easier to see.

The OCV table is intentionally smooth and monotonic. That is a teaching choice, not a field-wide rule. Some chemistries have plateaus, small inflections, or hysteresis that need special treatment. We will talk about those later in the chapter and again in the sodium-ion section.

Each candidate model is stored as a small MATLAB `struct`. This is one of the simplest ways to keep parameter sets readable without introducing a class definition too early. Notice that the `Rint` model is represented by setting `R1 = 0` and `R2 = 0`; the simulation function interprets those as absent branches.

Inside `simulateEcm`, the SOC update uses the previous current sample, which is the cleanest explicit-Euler interpretation at a fixed sample period. The branch updates use the exact discrete-time decay factor `alpha = exp(-dt/(RC))`. That is better than a first-order Euler step for the branch states because it preserves the correct exponential shape even for moderately large `dt`.

The terminal voltage is then computed from Equation (1): OCV minus the instantaneous ohmic drop minus the branch voltages. Because we are using the convention `positive current = discharge`, the voltage falls under positive current and rises under negative current.

### Walkthrough 2 expected output

You should see four important features.

First, the `Rint` trace reacts instantly to each current step and then stays flat except for the slow change caused by SOC drift. There is no curved relaxation during rest because there are no dynamic states other than SOC.

Second, the `1RC` trace drops immediately when the pulse begins and then bends further downward during the pulse as the single polarization branch charges. When the current returns to zero, the voltage recovers smoothly on one dominant time scale.

Third, the `2RC` trace does everything the `1RC` trace does, but the rest recovery has a visible "shoulder": a fast partial recovery followed by a slower tail. That is the signature you want to learn to recognize. It is the main reason a `2RC` model is often the default workhorse in automotive BMS papers.

Fourth, the branch-voltage subplot makes the same story explicit. The fast branch in the `2RC` model rises and decays quickly. The slow branch changes more gradually and lingers during rest.

The printed voltages at the end of the `2C` pulse should show the expected ranking:

- `Rint` usually predicts the highest terminal voltage because it cannot accumulate polarization.
- `1RC` predicts a lower voltage because it captures one dynamic overpotential.
- `2RC` predicts the lowest voltage of the three because it captures both a fast and a slow polarization component.

### Walkthrough 2 troubleshooting

1. The `2RC` model looks almost identical to the `1RC` model.

   Symptom: the two traces sit nearly on top of each other.

   Fix: your slow branch time constant may be too short, or your `R2` value may be too small. Increase `C2` or `R2` so the slow tail is visible over the rest periods.

2. The voltage rises during discharge.

   Symptom: the pulse directions look backwards.

   Fix: your sign convention is flipped. In this chapter's hand-built model, discharge current is positive.

3. The SOC leaves the interval `[0, 1]`.

   Symptom: interpolation errors or nonsense voltages near the end of the simulation.

   Fix: clamp the SOC after each update, exactly as the code does with `min(max(...))`.

4. The `Rint` result shows a slow recovery during rest.

   Symptom: the flat line after a pulse is missing.

   Fix: check that `R1` and `R2` are really set to zero for the `Rint` case and that the branch-update code skips them.

### Walkthrough 2 reflection

This exercise teaches the visual grammar of ECMs. Before this point, "1RC" and "2RC" may have felt like labels from a paper. Now you have seen the specific voltage features they add. That matters because the rest of the chapter is about fitting those features from data rather than inventing them by hand.

## Guided Walkthrough 2: Identify `R0`, `R1`, `C1`, `R2`, and `C2` from a Single Synthetic HPPC Pulse

**Learning objective:** Learn exactly how a pulse and recovery encode a `2RC` parameter set.

We are now going to move from forward simulation to inverse modeling. Instead of choosing parameters and predicting voltage, we will generate one synthetic pulse response, corrupt it with a tiny amount of measurement noise, and recover the parameters back. We start with synthetic data because it lets us separate method from mess. If the method does not work on clean synthetic data, it certainly will not work on a real workbook downloaded from the public internet.

### Walkthrough 2 code

```matlab
clear; close all; clc;

% One pulse with a long recovery window
time_s = (0:1:220).';
current_a = zeros(size(time_s));
current_a(time_s >= 40 & time_s < 58) = 8.0;  % discharge pulse

% Known truth used to generate synthetic "measurements"
ocv_true_v = 3.865;
trueParams = struct( ...
    "R0", 0.0130, ...
    "R1", 0.0075, ...
    "C1", 35.0, ...
    "R2", 0.0200, ...
    "C2", 220.0);

voltage_clean_v = simulatePulse(current_a, ocv_true_v, trueParams);

rng(7);
noise_std_v = 1e-3;
voltage_meas_v = voltage_clean_v + noise_std_v * randn(size(voltage_clean_v));

% Step 1: estimate R0 from the instantaneous voltage jump
idxPulseStart = find(diff(current_a) > 0, 1, "first") + 1;
idxPulseEnd = find(diff(current_a) < 0, 1, "first");
idxRecoveryStart = idxPulseEnd + 1;

deltaI = current_a(idxPulseStart) - current_a(idxPulseStart - 1);
vBefore = voltage_meas_v(idxPulseStart - 1);
vAfter = voltage_meas_v(idxPulseStart);
R0_hat = (vBefore - vAfter) / deltaI;

% Step 2: estimate OCV from the tail end of the recovery
ocv_hat_v = mean(voltage_meas_v(end-20:end));

% Step 3: fit the recovery with one exponential and then with two
recoveryTime_s = time_s(idxRecoveryStart:end) - time_s(idxRecoveryStart);
recoveryOvervoltage_v = ocv_hat_v - voltage_meas_v(idxRecoveryStart:end);
pulseCurrent_a = current_a(idxPulseStart);
pulseDuration_s = time_s(idxPulseEnd) - time_s(idxPulseStart) + 1;

oneRcModelFun = @(p, t) p(1) * exp(-t / p(2));
twoRcModelFun = @(p, t) p(1) * exp(-t / p(2)) + p(3) * exp(-t / p(4));

opts = optimoptions("lsqcurvefit", "Display", "off");

p0_1rc = [0.05, 20];
lb_1rc = [0, 1];
ub_1rc = [0.5, 500];
pHat_1rc = lsqcurvefit(oneRcModelFun, p0_1rc, recoveryTime_s, ...
    recoveryOvervoltage_v, lb_1rc, ub_1rc, opts);

p0_2rc = [0.03, 8, 0.07, 80];
lb_2rc = [0, 1, 0, 5];
ub_2rc = [0.5, 100, 0.5, 1000];
pHat_2rc = lsqcurvefit(twoRcModelFun, p0_2rc, recoveryTime_s, ...
    recoveryOvervoltage_v, lb_2rc, ub_2rc, opts);

% Sort the two time constants so the fast branch is always branch 1
if pHat_2rc(2) > pHat_2rc(4)
    pHat_2rc = [pHat_2rc(3) pHat_2rc(4) pHat_2rc(1) pHat_2rc(2)];
end

A1 = pHat_2rc(1);
tau1_s = pHat_2rc(2);
A2 = pHat_2rc(3);
tau2_s = pHat_2rc(4);

R1_hat = A1 / (pulseCurrent_a * (1 - exp(-pulseDuration_s / tau1_s)));
R2_hat = A2 / (pulseCurrent_a * (1 - exp(-pulseDuration_s / tau2_s)));
C1_hat = tau1_s / R1_hat;
C2_hat = tau2_s / R2_hat;

recoveryFit_1rc_v = oneRcModelFun(pHat_1rc, recoveryTime_s);
recoveryFit_2rc_v = twoRcModelFun(pHat_2rc, recoveryTime_s);

rmse_1rc_mv = 1000 * sqrt(mean((recoveryOvervoltage_v - recoveryFit_1rc_v).^2));
rmse_2rc_mv = 1000 * sqrt(mean((recoveryOvervoltage_v - recoveryFit_2rc_v).^2));

fprintf("Estimated parameters from one pulse:\n");
fprintf("  R0  = %.5f ohm\n", R0_hat);
fprintf("  R1  = %.5f ohm\n", R1_hat);
fprintf("  C1  = %.2f F\n", C1_hat);
fprintf("  R2  = %.5f ohm\n", R2_hat);
fprintf("  C2  = %.2f F\n", C2_hat);
fprintf("  OCV = %.4f V\n", ocv_hat_v);
fprintf("1RC recovery RMSE : %.3f mV\n", rmse_1rc_mv);
fprintf("2RC recovery RMSE : %.3f mV\n", rmse_2rc_mv);

figure("Color", "w", "Position", [120 120 1000 720]);

subplot(3, 1, 1);
plot(time_s, current_a, "k", "LineWidth", 1.5);
grid on;
xlabel("Time [s]");
ylabel("Current [A]");
title("Synthetic HPPC pulse");

subplot(3, 1, 2);
plot(time_s, voltage_meas_v, "o", "MarkerSize", 3.0, "DisplayName", "Measured"); hold on;
plot(time_s, voltage_clean_v, "LineWidth", 1.8, "DisplayName", "True clean response");
xline(time_s(idxPulseStart), "--", "Pulse start", "LabelVerticalAlignment", "bottom");
xline(time_s(idxRecoveryStart), "--", "Recovery start", "LabelVerticalAlignment", "bottom");
grid on;
xlabel("Time [s]");
ylabel("Voltage [V]");
title("Measured voltage with millivolt noise");
legend("Location", "best");

subplot(3, 1, 3);
plot(recoveryTime_s, 1000 * recoveryOvervoltage_v, "ko", "MarkerSize", 3.0, ...
    "DisplayName", "Measured recovery overvoltage"); hold on;
plot(recoveryTime_s, 1000 * recoveryFit_1rc_v, "LineWidth", 1.6, ...
    "DisplayName", sprintf("1RC fit (RMSE %.2f mV)", rmse_1rc_mv));
plot(recoveryTime_s, 1000 * recoveryFit_2rc_v, "LineWidth", 1.8, ...
    "DisplayName", sprintf("2RC fit (RMSE %.2f mV)", rmse_2rc_mv));
grid on;
xlabel("Recovery time [s]");
ylabel("Recovery overvoltage [mV]");
title("Why the second RC branch helps");
legend("Location", "best");


function voltage_v = simulatePulse(current_a, ocv_v, params)
    n = numel(current_a);
    voltage_v = zeros(n, 1);
    v1 = zeros(n, 1);
    v2 = zeros(n, 1);
    dt = 1;

    alpha1 = exp(-dt / (params.R1 * params.C1));
    alpha2 = exp(-dt / (params.R2 * params.C2));

    for k = 1:n
        if k > 1
            v1(k) = alpha1 * v1(k - 1) + params.R1 * (1 - alpha1) * current_a(k - 1);
            v2(k) = alpha2 * v2(k - 1) + params.R2 * (1 - alpha2) * current_a(k - 1);
        end
        voltage_v(k) = ocv_v - params.R0 * current_a(k) - v1(k) - v2(k);
    end
end
```

### Walkthrough 3 explanation

The pulse lasts `18 s` and is followed by a long rest. That is deliberate. If the rest were too short, the slow branch would not have enough time to reveal itself.

The first estimate, `R0_hat`, comes from the immediate voltage jump at pulse start. This is the part of the waveform least contaminated by the RC dynamics, so we estimate it directly instead of bundling it into the nonlinear fit.

The recovery fit is built on `recoveryOvervoltage_v = OCV - V`. During rest, the current is zero, so the terminal voltage rises toward OCV from below. That means `OCV - V` is a positive quantity that decays to zero. It is exactly the object a sum of exponentials should fit.

The one-exponential model tests the `1RC` hypothesis. The two-exponential model tests the `2RC` hypothesis. Once we recover amplitudes `A1` and `A2` and time constants `tau1` and `tau2`, we convert them back into `R1`, `R2`, `C1`, and `C2` using the finite pulse duration. That conversion is easy to miss, so it is worth reading carefully: the branch amplitudes at recovery start are not simply `I*R1` and `I*R2` unless the pulse is infinitely long. The factor `(1 - exp(-Tpulse/tau))` corrects for the fact that the branch may not have reached steady state.

### Walkthrough 3 expected output

You should see a clean ranking:

- `R0_hat` should land very close to the true `0.013 ohm`.
- The `2RC` recovery RMSE should be clearly smaller than the `1RC` RMSE.
- The recovered `tau1` should be on the order of tens of seconds, and `tau2` should be substantially slower.

Typical output from this script is in this neighborhood:

```text
Estimated parameters from one pulse:
  R0  = 0.0129 ohm
  R1  = 0.0077 ohm
  C1  = 34.2 F
  R2  = 0.0198 ohm
  C2  = 221.5 F
  OCV = 3.8648 V
1RC recovery RMSE : 2.0 mV
2RC recovery RMSE : 0.9 mV
```

Do not obsess over the last decimal place. The exact numbers will move with the random noise realization. What matters is that the recovered parameters remain close to truth and that the `2RC` fit captures the long tail better.

### Walkthrough 3 troubleshooting

1. `R0_hat` is much too large.

   Symptom: the printed `R0` is closer to `0.03 ohm` or `0.04 ohm`.

   Fix: you probably measured the jump too late, after the RC branches had already started contributing. Use the sample immediately before and immediately after the step.

2. The fitted `tau1` and `tau2` swap places every run.

   Symptom: sometimes the fast branch is printed as branch 2 and sometimes as branch 1.

   Fix: this is not physically wrong, but it is annoying. Sort the pair after fitting, exactly as the code does.

3. The `2RC` fit becomes numerically unstable.

   Symptom: one time constant runs to the upper bound.

   Fix: your pulse or rest window may not be rich enough, or the initial guesses are too poor. Longer rest windows and better initialization help immediately.

4. The one-exponential fit looks just as good as the two-exponential fit.

   Symptom: the RMSE values are nearly identical.

   Fix: either the slow branch is too weak in the synthetic truth, or the pulse is too short to excite it. Increase `R2`, `C2`, or the pulse duration.

### Walkthrough 3 reflection

This exercise teaches the core logic behind Plett-style identification. A pulse response is not just "some transient." It contains a direct ohmic jump, a fast decay, and often a slow decay. Once you learn to read those pieces, the parameter-estimation workflow stops feeling mysterious.

## Guided Walkthrough 3: Build SOC-Dependent `2RC` Tables from a Full Synthetic HPPC Suite

**Learning objective:** Turn a collection of pulses into the lookup tables that a BMS actually uses.

A real ECM is rarely a single fixed parameter set. Resistances, time constants, and OCV all move with SOC, and usually with temperature as well. In this walkthrough we generate a synthetic HPPC suite over multiple SOC levels, identify a `2RC` model at each level, and build smooth lookup tables. This is the closest we will come in this chapter to the classic textbook ECM-identification pipeline.

### Walkthrough 3 code

```matlab
clear; close all; clc;

rng(11);

socNodes = (1.00:-0.10:0.20).';
pulseCurrent_a = 6.0;
pulseDuration_s = 18;
restBefore_s = 40;
restAfter_s = 150;

ocv_soc = [0.00 0.05 0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00].';
ocv_v =  [3.00 3.15 3.27 3.42 3.53 3.62 3.70 3.79 3.89 4.00 4.09 4.18].';

trueR0 = @(z) 0.0105 + 0.0060 * (1 - z).^1.2;
trueR1 = @(z) 0.0050 + 0.0040 * (1 - z);
trueC1 = @(z) 28.0 + 35.0 * z;
trueR2 = @(z) 0.0120 + 0.0100 * (1 - z).^2;
trueC2 = @(z) 150.0 + 450.0 * z;

nSoc = numel(socNodes);
identified = table('Size', [nSoc 7], ...
    'VariableTypes', repmat("double", 1, 7), ...
    'VariableNames', ["SOC", "OCV_V", "R0_Ohm", "R1_Ohm", "C1_F", "R2_Ohm", "C2_F"]);

for idx = 1:nSoc
    soc0 = socNodes(idx);
    time_s = (0:1:(restBefore_s + pulseDuration_s + restAfter_s)).';
    current_a = zeros(size(time_s));
    current_a(time_s >= restBefore_s & time_s < restBefore_s + pulseDuration_s) = pulseCurrent_a;

    ocv0_v = interp1(ocv_soc, ocv_v, soc0, "pchip");
    paramsTrue = struct( ...
        "R0", trueR0(soc0), ...
        "R1", trueR1(soc0), ...
        "C1", trueC1(soc0), ...
        "R2", trueR2(soc0), ...
        "C2", trueC2(soc0));

    voltage_clean_v = simulatePulse(current_a, ocv0_v, paramsTrue);
    voltage_meas_v = voltage_clean_v + 8e-4 * randn(size(voltage_clean_v));

    fitted = fitSinglePulse(time_s, current_a, voltage_meas_v);

    identified.SOC(idx) = soc0;
    identified.OCV_V(idx) = fitted.OCV_V;
    identified.R0_Ohm(idx) = fitted.R0_Ohm;
    identified.R1_Ohm(idx) = fitted.R1_Ohm;
    identified.C1_F(idx) = fitted.C1_F;
    identified.R2_Ohm(idx) = fitted.R2_Ohm;
    identified.C2_F(idx) = fitted.C2_F;
end

% Smooth the identified tables so they behave like something you would ship
denseSoc = linspace(min(identified.SOC), max(identified.SOC), 101).';
ocvDense = interp1(identified.SOC, identified.OCV_V, denseSoc, "pchip");
r0Dense = interp1(identified.SOC, identified.R0_Ohm, denseSoc, "pchip");
r1Dense = interp1(identified.SOC, identified.R1_Ohm, denseSoc, "pchip");
c1Dense = interp1(identified.SOC, identified.C1_F, denseSoc, "pchip");
r2Dense = interp1(identified.SOC, identified.R2_Ohm, denseSoc, "pchip");
c2Dense = interp1(identified.SOC, identified.C2_F, denseSoc, "pchip");

ecmLookup = table(denseSoc, ocvDense, r0Dense, r1Dense, c1Dense, r2Dense, c2Dense, ...
    'VariableNames', ["SOC", "OCV_V", "R0_Ohm", "R1_Ohm", "C1_F", "R2_Ohm", "C2_F"]);

writetable(ecmLookup, "chapter6_synthetic_2rc_lookup.csv");
save("chapter6_synthetic_2rc_lookup.mat", "ecmLookup", "identified");

% Validate at an unseen SOC point
validationSoc = 0.45;
validationTime_s = (0:1:(restBefore_s + pulseDuration_s + restAfter_s)).';
validationCurrent_a = zeros(size(validationTime_s));
validationCurrent_a(validationTime_s >= restBefore_s & ...
    validationTime_s < restBefore_s + pulseDuration_s) = pulseCurrent_a;

validationTruth = struct( ...
    "R0", trueR0(validationSoc), ...
    "R1", trueR1(validationSoc), ...
    "C1", trueC1(validationSoc), ...
    "R2", trueR2(validationSoc), ...
    "C2", trueC2(validationSoc));

validationOcv_v = interp1(ocv_soc, ocv_v, validationSoc, "pchip");
validationMeasured_v = simulatePulse(validationCurrent_a, validationOcv_v, validationTruth);

lookupParams = struct( ...
    "R0", interp1(ecmLookup.SOC, ecmLookup.R0_Ohm, validationSoc, "pchip"), ...
    "R1", interp1(ecmLookup.SOC, ecmLookup.R1_Ohm, validationSoc, "pchip"), ...
    "C1", interp1(ecmLookup.SOC, ecmLookup.C1_F, validationSoc, "pchip"), ...
    "R2", interp1(ecmLookup.SOC, ecmLookup.R2_Ohm, validationSoc, "pchip"), ...
    "C2", interp1(ecmLookup.SOC, ecmLookup.C2_F, validationSoc, "pchip"));

validationPredicted_v = simulatePulse(validationCurrent_a, validationOcv_v, lookupParams);
validationRmse_mv = 1000 * sqrt(mean((validationMeasured_v - validationPredicted_v).^2));

disp(identified);
fprintf("Held-out pulse RMSE at SOC %.2f: %.3f mV\n", validationSoc, validationRmse_mv);

figure("Color", "w", "Position", [100 100 1100 760]);

subplot(2, 2, 1);
plot(identified.SOC, identified.OCV_V, "o", "MarkerSize", 6, "LineWidth", 1.2); hold on;
plot(ecmLookup.SOC, ecmLookup.OCV_V, "LineWidth", 1.8);
grid on;
xlabel("SOC [-]");
ylabel("OCV [V]");
title("Identified OCV table");
legend("Pulse estimates", "Smoothed table", "Location", "best");

subplot(2, 2, 2);
plot(identified.SOC, identified.R0_Ohm, "o-", "LineWidth", 1.4); hold on;
plot(identified.SOC, identified.R1_Ohm, "s-", "LineWidth", 1.4);
plot(identified.SOC, identified.R2_Ohm, "d-", "LineWidth", 1.4);
grid on;
xlabel("SOC [-]");
ylabel("Resistance [ohm]");
title("SOC-dependent resistances");
legend("R0", "R1", "R2", "Location", "best");

subplot(2, 2, 3);
plot(identified.SOC, identified.C1_F, "s-", "LineWidth", 1.4); hold on;
plot(identified.SOC, identified.C2_F, "d-", "LineWidth", 1.4);
grid on;
xlabel("SOC [-]");
ylabel("Capacitance [F]");
title("SOC-dependent capacitances");
legend("C1", "C2", "Location", "best");

subplot(2, 2, 4);
plot(validationTime_s, validationMeasured_v, "k", "LineWidth", 1.8); hold on;
plot(validationTime_s, validationPredicted_v, "--", "LineWidth", 1.8);
grid on;
xlabel("Time [s]");
ylabel("Voltage [V]");
title(sprintf("Held-out validation pulse, RMSE = %.2f mV", validationRmse_mv));
legend("Truth", "Lookup-table prediction", "Location", "best");


function fitted = fitSinglePulse(time_s, current_a, voltage_v)
    idxPulseStart = find(diff(current_a) > 0, 1, "first") + 1;
    idxPulseEnd = find(diff(current_a) < 0, 1, "first");
    idxRecoveryStart = idxPulseEnd + 1;

    deltaI = current_a(idxPulseStart) - current_a(idxPulseStart - 1);
    R0_hat = (voltage_v(idxPulseStart - 1) - voltage_v(idxPulseStart)) / deltaI;
    OCV_hat = mean(voltage_v(end-20:end));

    recoveryTime_s = time_s(idxRecoveryStart:end) - time_s(idxRecoveryStart);
    recoveryOvervoltage_v = OCV_hat - voltage_v(idxRecoveryStart:end);

    modelFun = @(p, t) p(1) * exp(-t / p(2)) + p(3) * exp(-t / p(4));
    p0 = [0.02, 8, 0.05, 80];
    lb = [0, 1, 0, 5];
    ub = [0.5, 150, 0.5, 1500];
    opts = optimoptions("lsqcurvefit", "Display", "off");
    pHat = lsqcurvefit(modelFun, p0, recoveryTime_s, recoveryOvervoltage_v, lb, ub, opts);

    if pHat(2) > pHat(4)
        pHat = [pHat(3) pHat(4) pHat(1) pHat(2)];
    end

    pulseCurrent_a = current_a(idxPulseStart);
    pulseDuration_s = time_s(idxPulseEnd) - time_s(idxPulseStart) + 1;
    R1_hat = pHat(1) / (pulseCurrent_a * (1 - exp(-pulseDuration_s / pHat(2))));
    R2_hat = pHat(3) / (pulseCurrent_a * (1 - exp(-pulseDuration_s / pHat(4))));
    C1_hat = pHat(2) / R1_hat;
    C2_hat = pHat(4) / R2_hat;

    fitted = struct( ...
        "OCV_V", OCV_hat, ...
        "R0_Ohm", R0_hat, ...
        "R1_Ohm", R1_hat, ...
        "C1_F", C1_hat, ...
        "R2_Ohm", R2_hat, ...
        "C2_F", C2_hat);
end


function voltage_v = simulatePulse(current_a, ocv_v, params)
    n = numel(current_a);
    dt = 1;
    voltage_v = zeros(n, 1);
    v1 = zeros(n, 1);
    v2 = zeros(n, 1);

    alpha1 = exp(-dt / (params.R1 * params.C1));
    alpha2 = exp(-dt / (params.R2 * params.C2));

    for k = 1:n
        if k > 1
            v1(k) = alpha1 * v1(k - 1) + params.R1 * (1 - alpha1) * current_a(k - 1);
            v2(k) = alpha2 * v2(k - 1) + params.R2 * (1 - alpha2) * current_a(k - 1);
        end
        voltage_v(k) = ocv_v - params.R0 * current_a(k) - v1(k) - v2(k);
    end
end
```

### Walkthrough 4 explanation

The SOC nodes run from `1.0` down to `0.2` in `10%` steps because that is a common first-pass table density in BMS work. We use simple analytic functions for the "true" SOC dependence so the identified tables have something physically smooth to recover.

The `fitSinglePulse` helper is almost the same logic from Walkthrough 2, but now we reuse it inside a loop over SOC. This is the important workflow leap. A BMS parameter table is not a single fit. It is a family of fits organized by state.

After identification, we interpolate the results onto a denser SOC grid and save them to both CSV and MAT formats. That is a subtle but important research habit. CSV is easy to inspect and share. MAT preserves exact MATLAB types and is convenient inside your own workflow.

The held-out validation at `SOC = 0.45` matters just as much as the table construction. Because `0.45` was not one of the training nodes, the validation plot checks whether the identified tables interpolate sensibly instead of only memorizing the fitted points.

### Walkthrough 4 expected output

The printed table should show three healthy patterns.

- `OCV_V` should increase monotonically with SOC.
- `R0_Ohm`, `R1_Ohm`, and usually `R2_Ohm` should rise as SOC falls.
- `C1_F` and `C2_F` should stay positive and vary smoothly rather than jumping erratically from node to node.

The held-out RMSE should usually land in the low single-digit millivolt range because the data are synthetic and the model class matches the truth. If you see `10 mV` or `20 mV` here, something is wrong.

The plot of the held-out pulse should show two traces that are nearly indistinguishable at normal viewing scale. That is exactly what you want at this stage.

### Walkthrough 4 troubleshooting

1. The identified tables look jagged rather than smooth.

   Symptom: neighboring SOC nodes jump up and down unpredictably.

   Fix: your recovery fits are underconstrained or too noisy. Longer rest windows, better initialization, or mild smoothing are all reasonable.

2. One capacitance becomes negative or enormous.

   Symptom: `C1` or `C2` prints as a negative number or a wildly large value.

   Fix: check that the corresponding amplitude and time constant are positive and that the conversion from amplitude to resistance uses the correct pulse duration.

3. The held-out validation is poor even though the fitted nodes look fine.

   Symptom: low training error but bad interpolation at `SOC = 0.45`.

   Fix: you may need more SOC nodes or a more stable interpolation method. This is a classic sign that the lookup table is too sparse for the local curvature.

4. The OCV table is not monotonic.

   Symptom: the voltage dips at one SOC node and rises again at the next.

   Fix: if your chemistry should be monotonic, that nonmonotonicity usually signals noisy OCV extraction rather than real physics.

### Walkthrough 4 reflection

This is the first point in the chapter where the workflow looks like something you could actually ship into an estimator. You now have an OCV table, SOC-dependent dynamic parameters, a saved lookup file, and a held-out validation check. That is the minimal professional unit of ECM work.

## Guided Walkthrough 4: Parse a Real CALCE Workbook and Build an OCV-SOC Table You Can Reuse

**Learning objective:** Turn a public experimental workbook into a clean OCV table that can feed an ECM.

Now we bring in real data. For this chapter the most reliable public source for a laptop-runnable ECM workflow is the CALCE Samsung INR 18650-20R archive maintained by the Center for Advanced Life Cycle Engineering at the University of Maryland. The public portal explicitly documents the experiment and exposes downloadable files for low-current OCV, incremental-current OCV, and dynamic tests at several temperatures.

For the `25 degC` low-current OCV file relevant here:

| Item | Value |
| --- | --- |
| Dataset source | CALCE Battery Research Data portal |
| Cell | Samsung `INR 18650-20R` |
| File | `11_5_2015_low current OCV test_SP20-1.xlsx` |
| Archive URL | `https://web.calce.umd.edu/batteries/data/SP1_25C_LC_OCV_11_5_2015.zip` |
| Approximate size | about `2.9 MB` zipped |
| Format | Excel workbook (`.xlsx`) |
| Sheet name | `SP20-OCVSOC-0.05C` |
| Relevant columns | `Duration (sec)`, `Pgm step`, `mV`, `mA`, `Temperature` |
| License note | The CALCE page states the data are open access and asks users to cite CALCE papers describing the experiment; it does not present a formal software-style license |

There is an important sign-convention pitfall here. The CALCE files were logged with Arbin-style tester conventions: positive current corresponds to charge, and negative current corresponds to discharge. That is the opposite of the convention we used in our hand-built ECM functions. We will normalize that explicitly in the code so later sections stay consistent.

### Walkthrough 4 code

```matlab
clear; close all; clc;

dataRoot = fullfile(pwd, "calce_ocv_data");
if ~exist(dataRoot, "dir")
    mkdir(dataRoot);
end

zipFile = fullfile(dataRoot, "SP1_25C_LC_OCV_11_5_2015.zip");
xlsxFile = fullfile(dataRoot, "11_5_2015_low current OCV test_SP20-1.xlsx");
downloadUrl = "https://web.calce.umd.edu/batteries/data/SP1_25C_LC_OCV_11_5_2015.zip";

if ~isfile(xlsxFile)
    if ~isfile(zipFile)
        fprintf("Downloading CALCE archive...\n");
        websave(zipFile, downloadUrl);
    end
    unzip(zipFile, dataRoot);
end

raw = readtable(xlsxFile, ...
    "Sheet", "SP20-OCVSOC-0.05C", ...
    "VariableNamingRule", "preserve");

time_s = raw.("Duration (sec)");
voltage_v = raw.("mV") / 1000;
current_a_raw = raw.("mA") / 1000;

if ismember("Temperature", raw.Properties.VariableNames)
    temperature_c = raw.("Temperature");
    temperature_c = fillmissing(temperature_c, "previous");
else
    temperature_c = nan(size(time_s));
end

% CALCE/Arbin convention: positive current = charge, negative current = discharge
chargeMask = current_a_raw > 0.03;
dischargeMask = current_a_raw < -0.03;
restMask = abs(current_a_raw) <= 0.03;

chargeTime_s = time_s(chargeMask);
chargeCurrent_a = current_a_raw(chargeMask);
chargeVoltage_v = voltage_v(chargeMask);

dischargeTime_s = time_s(dischargeMask);
dischargeCurrent_a = current_a_raw(dischargeMask);
dischargeVoltage_v = voltage_v(dischargeMask);

chargeAh = cumtrapz(chargeTime_s, chargeCurrent_a) / 3600;
dischargeAh = cumtrapz(dischargeTime_s, -dischargeCurrent_a) / 3600;

usableCapacity_ah = max(dischargeAh);
socCharge = chargeAh / max(chargeAh);
socDischarge = 1 - dischargeAh / usableCapacity_ah;

socGrid = linspace(0, 1, 101).';
chargeCurve_v = interp1(socCharge, chargeVoltage_v, socGrid, "linear", "extrap");
dischargeCurve_v = interp1(flipud(socDischarge), flipud(dischargeVoltage_v), socGrid, ...
    "linear", "extrap");
ocvCurve_v = 0.5 * (chargeCurve_v + dischargeCurve_v);
hysteresis_v = chargeCurve_v - dischargeCurve_v;

ocvTable = table(socGrid, ocvCurve_v, chargeCurve_v, dischargeCurve_v, hysteresis_v, ...
    'VariableNames', ["SOC", "OCV_V", "ChargeBranch_V", "DischargeBranch_V", "Hysteresis_V"]);

writetable(ocvTable, fullfile(dataRoot, "calce_sp20_ocv_table_25C.csv"));
save(fullfile(dataRoot, "calce_sp20_ocv_table_25C.mat"), ...
    "ocvTable", "usableCapacity_ah", "time_s", "voltage_v", "current_a_raw", "temperature_c");

% Use the extracted OCV table in a simple 2RC forward simulation
testTime_s = (0:1:300).';
testCurrent_a = zeros(size(testTime_s));
testCurrent_a(testTime_s >= 30 & testTime_s < 60) = 4.0;   % positive discharge for our ECM
testCurrent_a(testTime_s >= 160 & testTime_s < 190) = -2.0;

params2RC = struct("R0", 0.015, "R1", 0.009, "C1", 45, "R2", 0.020, "C2", 250);
initialSoc = 0.80;
forwardVoltage_v = simulateWithLookup(testTime_s, testCurrent_a, initialSoc, ...
    ocvTable.SOC, ocvTable.OCV_V, usableCapacity_ah, params2RC);

fprintf("Estimated usable capacity from CALCE low-current file: %.3f Ah\n", usableCapacity_ah);
fprintf("Hysteresis near 50%% SOC: %.4f V\n", ...
    interp1(ocvTable.SOC, ocvTable.Hysteresis_V, 0.50, "linear"));

figure("Color", "w", "Position", [100 100 1100 760]);

subplot(2, 2, 1);
plot(time_s / 3600, voltage_v, "LineWidth", 1.1);
grid on;
xlabel("Elapsed time [h]");
ylabel("Voltage [V]");
title("Raw CALCE low-current OCV voltage trace");

subplot(2, 2, 2);
plot(time_s / 3600, current_a_raw, "LineWidth", 1.1);
grid on;
xlabel("Elapsed time [h]");
ylabel("Current [A]");
title("Raw CALCE current trace (positive = charge)");

subplot(2, 2, 3);
plot(ocvTable.SOC, ocvTable.ChargeBranch_V, "LineWidth", 1.6); hold on;
plot(ocvTable.SOC, ocvTable.DischargeBranch_V, "LineWidth", 1.6);
plot(ocvTable.SOC, ocvTable.OCV_V, "k--", "LineWidth", 1.8);
grid on;
xlabel("SOC [-]");
ylabel("Voltage [V]");
title("Extracted charge, discharge, and averaged OCV curves");
legend("Charge branch", "Discharge branch", "Averaged OCV", "Location", "best");

subplot(2, 2, 4);
yyaxis left;
plot(testTime_s, testCurrent_a, "k", "LineWidth", 1.3);
ylabel("Current [A]");
yyaxis right;
plot(testTime_s, forwardVoltage_v, "LineWidth", 1.8);
ylabel("Voltage [V]");
grid on;
xlabel("Time [s]");
title("Reusing the real OCV table inside a 2RC simulation");


function voltage_v = simulateWithLookup(time_s, current_a, initialSoc, socLut, ocvLut, capacity_ah, params)
    n = numel(time_s);
    dt = time_s(2) - time_s(1);

    soc = zeros(n, 1);
    v1 = zeros(n, 1);
    v2 = zeros(n, 1);
    voltage_v = zeros(n, 1);
    soc(1) = initialSoc;

    alpha1 = exp(-dt / (params.R1 * params.C1));
    alpha2 = exp(-dt / (params.R2 * params.C2));

    for k = 1:n
        if k > 1
            soc(k) = soc(k - 1) - current_a(k - 1) * dt / (3600 * capacity_ah);
            soc(k) = min(max(soc(k), 0), 1);
            v1(k) = alpha1 * v1(k - 1) + params.R1 * (1 - alpha1) * current_a(k - 1);
            v2(k) = alpha2 * v2(k - 1) + params.R2 * (1 - alpha2) * current_a(k - 1);
        end

        ocvNow_v = interp1(socLut, ocvLut, soc(k), "pchip", "extrap");
        voltage_v(k) = ocvNow_v - params.R0 * current_a(k) - v1(k) - v2(k);
    end
end
```

### Simscape Battery walkthrough explanation

The first half is a public-data workflow, not a modeling workflow. It checks for the workbook locally, downloads the zip if necessary, unzips it, and reads the exact sheet `SP20-OCVSOC-0.05C` while preserving the original column names. That detail matters because CALCE's headers contain spaces and parentheses. If you let MATLAB rewrite them automatically, the later parsing becomes harder to explain and harder to trust.

The code then splits the trace into charge, discharge, and rest regions using a small current threshold of `0.03 A`. That threshold is not sacred. It is a practical cutoff that keeps the branch extraction from being polluted by near-zero holding steps.

We compute charge and discharge SOC axes separately from the integrated ampere-hours. This is important because the charge branch grows from low SOC to high SOC, while the discharge branch shrinks from high SOC to low SOC. Trying to reuse one axis for both without care is the fastest way to confuse `interp1`.

Finally, we average the charge and discharge branches to obtain a simple low-current OCV estimate. This is standard practice in the field when hysteresis is modest and you want a single OCV table for an ECM. It is also a modeling shortcut. If hysteresis is large and important to your application, averaging it away is a convenience, not ground truth.

### Simscape Battery walkthrough expected output

You should see a long, slow voltage trace whose dynamic structure is much calmer than a typical drive cycle because the OCV test was designed to approximate equilibrium.

The printed usable capacity should be close to the cell's nominal `2.0 Ah`, though not necessarily exactly equal. A result in the range `1.9 Ah` to `2.1 Ah` is plausible for this file. The hysteresis at `50% SOC` should be on the order of tens of millivolts, not hundreds.

The extracted OCV plot should show:

- a charge branch slightly above the discharge branch,
- an averaged OCV curve between them,
- full-cell voltage rising from the lower end of the SOC range toward roughly `4.2 V` at high SOC.

The final subplot should confirm that the extracted OCV table is immediately usable inside the same `2RC` simulation logic we built earlier. That is the main practical point of the exercise.

### Simscape Battery walkthrough troubleshooting

1. `readtable` cannot find the sheet.

   Symptom: MATLAB says the sheet name does not exist.

   Fix: open the workbook manually and confirm the exact sheet name. On the verified CALCE file, it is `SP20-OCVSOC-0.05C`.

2. The charge or discharge interpolation fails.

   Symptom: `interp1` reports nonunique or nonmonotonic sample points.

   Fix: make sure the SOC vector you pass into `interp1` is increasing. The code uses `flipud` on the discharge branch for exactly this reason.

3. The extracted capacity is absurdly small.

   Symptom: you get something like `0.2 Ah`.

   Fix: your current units are probably still in milliamps. The workbook uses `mA`, so we divide by `1000`.

4. The averaged OCV is visibly jagged.

   Symptom: the table wiggles from node to node.

   Fix: use a denser current threshold or mild smoothing after interpolation. Jaggedness here usually comes from branch-selection noise rather than from the chemistry.

### Simscape Battery walkthrough reflection

This is the chapter's most important real-data habit: do not leave public spreadsheets in raw form. Turn them into a clean, documented modeling artifact. Here that artifact is an OCV-SOC table. In later chapters it will become validation data, estimator benchmarks, and eventually sodium-ion comparison sets.

## Guided Walkthrough 5: Optional Simscape Battery Block Parameterization in `R2025a+`

**Learning objective:** Map the hand-built HPPC workflow onto MATLAB's newer Simscape Battery tooling.

This section is optional because not every reader will have `Simscape Battery`. But if you do have it, it is worth seeing how the newer toolbox workflow lines up with the manual workflow we just built. We are still using HPPC-style data. We are simply handing that data to `hppcTest` and `fitECM` instead of writing the entire identification loop ourselves.

### Walkthrough 5 code

```matlab
clear; close all; clc;

import simscape.battery.parameters.*;

% Synthetic HPPC data in table form
time_s = (0:1:220).';
current_a = zeros(size(time_s));
current_a(time_s >= 40 & time_s < 58) = 8.0;

trueParams = struct("R0", 0.013, "R1", 0.0075, "C1", 35, "R2", 0.020, "C2", 220);
ocv_v = 3.865;
voltage_v = simulatePulse(current_a, ocv_v, trueParams);

hppcData = table(time_s, voltage_v, current_a, ...
    'VariableNames', ["time_s", "voltage_v", "current_a"]);

hppcExp = hppcTest(hppcData, ...
    TimeVariable = "time_s", ...
    VoltageVariable = "voltage_v", ...
    CurrentVariable = "current_a", ...
    CurrentSignConvention = "positiveDischarge");

ecmObj = fitECM(hppcExp, NumRCPairs = 2);
disp(ecmObj);

mdl = "chapter6BatteryEquivalentCircuit";
if bdIsLoaded(mdl)
    close_system(mdl, 0);
end

new_system(mdl);
open_system(mdl);

blockPath = mdl + "/Battery Equivalent Circuit";
add_block("batt_lib/Cells/Battery Equivalent Circuit", blockPath, ...
    "Position", [120 90 280 180]);

parameterizeEquivalentCircuitBlock(ecmObj, getSimulinkBlockHandle(blockPath), ...
    ParameterizePseudoOCV = true);

save_system(mdl);


function voltage_v = simulatePulse(current_a, ocv_v, params)
    n = numel(current_a);
    dt = 1;
    voltage_v = zeros(n, 1);
    v1 = zeros(n, 1);
    v2 = zeros(n, 1);

    alpha1 = exp(-dt / (params.R1 * params.C1));
    alpha2 = exp(-dt / (params.R2 * params.C2));

    for k = 1:n
        if k > 1
            v1(k) = alpha1 * v1(k - 1) + params.R1 * (1 - alpha1) * current_a(k - 1);
            v2(k) = alpha2 * v2(k - 1) + params.R2 * (1 - alpha2) * current_a(k - 1);
        end
        voltage_v(k) = ocv_v - params.R0 * current_a(k) - v1(k) - v2(k);
    end
end
```

### Walkthrough 5 explanation

The `hppcTest` object is MathWorks' way of telling Simscape Battery, "this table contains pulse data, and here is which column is time, which is voltage, and which is current." The `CurrentSignConvention = "positiveDischarge"` line is especially important because it keeps the object aligned with the convention we used throughout this chapter.

The `fitECM` call then estimates an ECM object directly from that pulse dataset. We specify `NumRCPairs = 2` because this walkthrough is intended to mirror the manual `2RC` work above.

Finally, `parameterizeEquivalentCircuitBlock` pushes the fitted parameters into the Battery Equivalent Circuit block in a new Simulink model. That is the key bridge from research script to Simulink workflow.

### Walkthrough 5 expected output

You should see:

- an `ECM` object printed in the Command Window,
- a new Simulink model called `chapter6BatteryEquivalentCircuit`,
- a Battery Equivalent Circuit block whose parameters have been populated.

If your release is older than `R2025a`, these functions may not exist. That is a version issue, not a modeling issue.

### Walkthrough 5 troubleshooting

1. `fitECM` is undefined.

   Symptom: MATLAB cannot find the function.

   Fix: you are on an older release or do not have Simscape Battery installed. Skip this optional section.

2. The block path `batt_lib/Cells/Battery Equivalent Circuit` is not found.

   Symptom: `add_block` fails.

   Fix: confirm that Simscape Battery is installed and that the Battery Equivalent Circuit block exists in your release.

3. The object fit is poor even on synthetic data.

   Symptom: the estimated block obviously does not reproduce the pulse.

   Fix: check the current sign convention first. A wrong sign convention is the most common cause of nonsense ECM fits.

### Walkthrough 5 reflection

This optional section is the software-ecosystem bridge. The manual workflow is the part you must understand. The toolbox workflow is the part you can use later for speed once you trust yourself to audit what it is doing.

## Reproduction Exercise: Recreate the Plett-Style HPPC-to-ECM Workflow

For this chapter, the most valuable reproduction target is procedural rather than pixel-perfect. Gregory Plett's *Battery Management Systems, Volume II: Equivalent-Circuit Methods* is still one of the clearest descriptions of the classic ECM identification workflow for BMS use. The book does not ship a companion numerical dataset you can drop into MATLAB and match figure-for-figure, so we will reproduce the workflow itself and judge success by whether we recover the same qualitative outcomes.

Use the synthetic HPPC suite from Walkthrough 3 and do the following without changing the underlying truth model:

1. Build an OCV table from the rest windows only.
2. Estimate `R0` from the pulse jump rather than from a global optimizer.
3. Fit one `1RC` and one `2RC` model at each SOC node.
4. Report training RMSE and held-out pulse RMSE for both models.
5. Write a short note explaining whether the second RC branch is justified by the improvement you actually measured.

The unavoidable ambiguity is that Plett's book presents the workflow, not a public raw workbook with one canonical answer file. So "close enough" here means:

- the OCV table is smooth and monotonic,
- the `2RC` model fits the recovery tails materially better than the `1RC` model,
- the parameter trends with SOC are physically plausible,
- the held-out prediction improves rather than only the fitted pulses.

If your final result satisfies those conditions, you have reproduced the intellectual content of the workflow even if your exact numerical values differ from any example embedded in the book.

## Open-Ended Exercises

### Exercise 1: When does the second RC branch stop being worth it?

Modify Walkthrough 3 so that the pulse duration is only `5 s` instead of `18 s`, then repeat the whole lookup-table identification workflow. Compare the held-out validation error for `1RC` and `2RC`.

Hint: keep the same truth model. Only shorten the excitation. The question is not whether the second branch exists in truth, but whether the data still let you identify it reliably.

### Exercise 2: What happens if the OCV curve gets flatter?

Replace the smooth lithium-ion-like OCV table used in Walkthroughs 1 and 3 with a flatter, plateau-heavy curve that mimics a sodium-ion hard-carbon full-cell region. Then rerun the held-out validation and comment on how sensitive the terminal voltage becomes to small SOC errors.

Hint: you do not need a perfect sodium-ion OCV model here. A deliberately flatter mid-SOC segment is enough to expose the observability issue.

### Exercise 3: Add temperature as a second lookup dimension

Repeat Walkthrough 3 twice: once with all resistances increased by `30%` and all capacitances reduced by `20%` to mimic a colder cell, and once with the original parameters. Store the results as two separate lookup tables and write a short function that switches between them based on temperature.

Hint: you are not building a full electrothermal model yet. You are building the habit of indexing ECM tables by more than one state variable.

## Worked Solutions to the Open-Ended Exercises

### Solution 1: Short pulses make the slow branch harder to justify

The shortest clean way to answer Exercise 1 is to reuse Walkthrough 3 exactly as written and change only:

```matlab
pulseDuration_s = 5;
restAfter_s = 150;
```

When you rerun the identification, three things usually happen.

- The `R0` estimates remain stable because the instantaneous jump is still visible.
- The fast branch remains identifiable because its time constant is comparable to the pulse width.
- The slow branch becomes much less stable because the pulse does not load it strongly enough before recovery begins.

In practice you will usually find that the held-out `2RC` improvement shrinks markedly and may become too small to justify the extra branch. That is the correct lesson. Model order is a property of the data-protocol pair, not just of the underlying cell physics.

### Solution 2: Flatter OCV reduces voltage sensitivity to SOC error

One runnable modification is:

```matlab
ocv_soc = [0.00 0.10 0.20 0.35 0.50 0.65 0.80 0.90 1.00].';
ocv_v =  [2.95 3.18 3.30 3.36 3.40 3.44 3.60 3.92 4.08].';
```

If you drop that table into Walkthrough 3, the pulse-fitting still works, but the held-out voltage becomes less sensitive to modest SOC misalignment across the flat mid-SOC region. That is good for some types of robustness and bad for SOC observability. In a Kalman-filter chapter, this will matter a lot: if `dU_oc/dz` is small, voltage alone cannot strongly correct SOC error.

### Solution 3: Two temperatures are just two tables until you need more

The simplest implementation is:

```matlab
temperatureLabels = ["25C", "10C"];
lookupTables = struct();

for tIdx = 1:numel(temperatureLabels)
    if temperatureLabels(tIdx) == "25C"
        resistanceScale = 1.00;
        capacitanceScale = 1.00;
    else
        resistanceScale = 1.30;
        capacitanceScale = 0.80;
    end

    % Apply the scale factors to trueR0, trueR1, trueR2, trueC1, and trueC2
    % before running the Walkthrough 3 identification loop.
end
```

The key result is not the exact numbers. It is the workflow habit: once temperature matters, you should stop pretending one ECM table is universally valid.

## What Changes for Sodium-Ion?

Several things change, and none of them are cosmetic.

First, sodium-ion full-cell OCV curves can be flatter or more stepped than the lithium-ion NMC/graphite style curve we used in the teaching examples. Hard-carbon anodes, polyanionic cathodes, and Prussian-blue analogues can all produce plateaus or low-slope regions that reduce voltage sensitivity to SOC. In practical BMS work that means ECM identification and SOC estimation from voltage alone both become harder. The model may still fit terminal voltage well, but the fitted parameters may be less informative about SOC than you expect.

Second, the public-data situation is much thinner for sodium-ion. Today there are far fewer openly distributed HPPC suites for SIB cells than for lithium-ion cells. In real sodium-ion research you will often do one of three things: generate your own virtual HPPC data from a physics-based model, digitize pulse plots from papers as a preliminary study, or work with partner data that cannot be redistributed. That makes the generic pulse-identification code from this chapter more valuable than any one public workbook.

Third, temperature dependence deserves earlier attention in sodium-ion than many beginners expect. One of sodium-ion's practical selling points is better low-temperature behavior relative to many lithium-ion chemistries. That advantage will not show up honestly if you identify a single `25 degC` ECM and pretend it applies everywhere. For SIB work, adding temperature as a lookup dimension sooner is usually good practice rather than optional polish.

Fourth, usable capacity and reference SOC can be trickier. Some sodium-ion cells exhibit stronger first-cycle losses, chemistry-dependent voltage plateaus, and more complicated hysteresis behavior. That means you should define the capacity basis used by your ECM explicitly: rated capacity, measured usable capacity at a reference temperature, or the capacity observed in the same dataset used for identification. Reviewers notice when this is vague.

The practical takeaway is simple. The core ECM mathematics transfers directly to sodium-ion. The identification discipline transfers directly too. What changes is the OCV shape, the data availability, and the burden on you to document what "SOC" and "OCV" mean for the chemistry you are modeling.

## Chapter Summary and Skill Checklist

- You built `Rint`, `1RC`, and `2RC` models directly in MATLAB and learned to recognize their voltage signatures by eye.
- You identified `R0`, `R1`, `C1`, `R2`, and `C2` from pulse-response data instead of treating them as black-box optimizer outputs.
- You turned a multi-SOC pulse suite into lookup tables suitable for BMS work and validated them on held-out data.
- You parsed a real CALCE workbook, handled a real sign-convention mismatch, and converted raw experimental data into a reusable OCV table.
- You saw how the newer Simscape Battery workflow maps onto the manual HPPC logic rather than replacing it conceptually.

Commands, functions, and patterns that should now feel familiar:

- `readtable(..., "VariableNamingRule", "preserve")`
- `interp1(..., "pchip")`
- `lsqcurvefit`
- `cumtrapz`
- exact discrete-time branch update with `alpha = exp(-dt/(R*C))`
- saving reproducible artifacts with `writetable` and `save`
- explicit current-sign normalization between data sources and model conventions

You should now be able to say "yes" to each of these:

- I can explain what each ECM element corresponds to physically and what it does to the voltage trace.
- I can identify `R0` from a pulse jump without hiding it inside a global optimizer.
- I can fit a `1RC` or `2RC` model to a pulse-recovery trace and interpret the result.
- I can build an SOC-dependent lookup table from a set of pulses.
- I can read a public workbook, normalize its units and signs, and extract an OCV curve from it.
- I can justify when a `2RC` model is actually worth the extra complexity.

If any of those boxes still feels shaky, revisit Walkthroughs 2 and 3 before moving on. Chapter 7 assumes this material is solid.

## Deliverable

The deliverable from the chapter plan is:

> A MATLAB script that takes raw HPPC data and returns an identified `2RC` model with a validation RMSE report.

The cleanest way to approach it is to combine the moving parts from this chapter into one file:

1. a loader that reads your workbook or CSV and normalizes current, voltage, time, and SOC metadata,
2. a pulse-fitting function like `fitSinglePulse`,
3. a loop over SOC nodes,
4. a lookup-table export,
5. a held-out validation plot plus a printed RMSE summary.

A strong submission should create at least three artifacts:

- `identified_2rc_lookup.csv`
- `identified_2rc_lookup.mat`
- `validation_report.txt` or a Live Script section printing RMSE and plotting measured versus modeled voltage

If you want a concrete target, start from Walkthrough 3 and replace the synthetic pulse generator with your own HPPC reader. If your data include only one SOC, you can still complete a reduced version of the deliverable by identifying a single fixed `2RC` parameter set and validating it on a second pulse from the same file.

## Further Practice and Reading

1. Gregory L. Plett, *Battery Management Systems, Volume II: Equivalent-Circuit Methods*, Artech House, 2015. This is still the best conceptual reference for the BMS side of ECM thinking.
2. CALCE Battery Research Data portal for the Samsung `INR 18650-20R` files used in this chapter: `https://calce.umd.edu/data`
3. Fangdan Zheng, Yinjiao Xing, Jiuchun Jiang, Bingxiang Sun, Jonghoon Kim, and Michael Pecht, "Influence of different open circuit voltage tests on state of charge online estimation for lithium-ion batteries," *Applied Energy*, 183, 2016, pp. 513-525.
4. MathWorks documentation for the optional toolbox workflow: `hppcTest`, `fitECM`, and `parameterizeEquivalentCircuitBlock` in the Simscape Battery documentation.
5. Arbin Instruments documentation on current polarity conventions. This is worth bookmarking because public battery workbooks often inherit the tester's sign convention rather than the modeler's preferred one.

The next chapter is Lab Chapter 7: SOC Estimation with Kalman Filters.

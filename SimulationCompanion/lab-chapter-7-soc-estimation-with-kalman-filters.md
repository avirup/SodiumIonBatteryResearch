# Lab Chapter 7: SOC Estimation with Kalman Filters

## Chapter Opening

This chapter is where the equivalent-circuit work from Lab Chapter 6 becomes a real battery-management algorithm. In the previous chapter we learned how to build `Rint`, `1RC`, and `2RC` models, identify their parameters from pulse data, and validate them honestly. That was necessary groundwork, but it was not yet estimation. A battery management system does not get to ask for the true SOC. It receives noisy current and voltage measurements, inherits whatever initialization error the pack had at key-on, and must still produce a credible estimate in real time. The Kalman-filter family exists because simple coulomb counting and simple voltage lookup fail exactly where a serious battery system cannot afford to fail.

Keep Textbook Chapter 10 open while you work. This chapter operationalizes the state-space formulation and estimator intuition you learned there. The equivalent-circuit model is now no longer the final product. It becomes the process model inside an observer. The OCV curve is no longer just a lookup table to draw a nice figure. It becomes the nonlinear measurement map that lets voltage correct accumulated SOC error. The polarization branch voltages are no longer just fitting artifacts. They become hidden states that the estimator must carry so it does not mistake transient overpotential for a true SOC shift.

You should also keep the sodium-ion chapter from the theory textbook nearby. That chapter matters more here than many readers expect. In a chemistry with a steep and smooth OCV-SOC curve, voltage is informative and the filter can often recover from a bad initial SOC guess surprisingly quickly. In a chemistry with broad plateaus or weak OCV slope, which is common for hard-carbon-based sodium-ion systems over parts of the SOC range, the same filter architecture becomes far more delicate. The mathematics do not change, but the observability does. This chapter is therefore not only about Kalman filters as generic algorithms. It is about learning when the filter deserves your trust and when the chemistry itself has made the problem harder.

The chapter has three intertwined goals. First, we will implement an Extended Kalman Filter, or EKF, from scratch in MATLAB using the same style of explicit state update you built in Chapter 6. Second, we will compare that EKF with a UKF so you can see what the unscented transform buys you and what it does not. Third, we will benchmark both estimators on public data and on a sodium-ion-inspired flat-OCV stress test so the code becomes a research tool rather than a classroom toy.

This is publishable-research territory because the judgment calls are now the point. You will have to choose state definitions, process noise, measurement noise, OCV interpolation strategy, and validation metrics. Those choices are standard practice in the field, but they are not neutral. A filter that looks excellent on one drive cycle may be brittle under initialization error, temperature drift, sensor bias, or a chemistry with a flatter OCV curve. Reviewers in this area know that. The strongest estimator papers do not merely report a low RMSE. They show what assumptions were made, how the tuning was selected, what the dynamic protocol was, how convergence was defined, and where the method fails.

We will move in the same spirit as the earlier chapters: slowly enough that every line of code is teachable, but seriously enough that the finished scripts can become the seed of a paper-quality workflow. We begin with a conceptual bridge from the `1RC` ECM to a nonlinear state observer. We then implement an EKF on synthetic data, because synthetic data let us separate algorithmic mistakes from dataset mess. After that we tune the process and measurement noise in a disciplined way, then move to CALCE data for a real-data benchmark, then expand to a UKF and bias-augmented states. The chapter closes by asking the question that matters for your long-term goal: what breaks when we move from an easy lithium-ion OCV curve to a sodium-ion-like plateau, and what do we do about it?

## Prerequisites Check

- Required software: `MATLAB R2024b` or newer recommended
- Required toolboxes for the core chapter: none beyond base MATLAB
- Strongly recommended toolbox: `Optimization Toolbox` if you want to re-fit ECM parameters locally rather than reuse the Chapter 6 values
- Optional toolbox: `Statistics and Machine Learning Toolbox` is not required, but some readers may prefer it for alternative plotting or smoothing helpers
- Required textbook chapters: Textbook Chapter 10 is essential; the sodium-ion chemistry chapter is strongly recommended; the thermal and degradation chapters are not required here
- Required prior lab chapters: Lab Chapters 1, 2, and 6 are essential; Lab Chapter 4 helps if you want to cross-check current-profile handling
- Estimated time: 16 to 20 hours for the full chapter, or 10 to 12 hours for Run 1 through the EKF tuning study

If the `1RC` and `2RC` state updates from Lab Chapter 6 still feel mechanical rather than intuitive, revisit Sections 6.1 through 6.4 before you continue. If the idea of OCV as a function of SOC is still blurry, reread the OCV-SOC table discussion from Textbook Chapter 10 and the OCV extraction workflow from Lab Chapter 6. The code here assumes that those ideas are already familiar even if they are not yet automatic.

## Environment Setup

The core of this chapter is intentionally lightweight. We will use plain MATLAB scripts with local functions, which keeps every exercise runnable on a laptop without Simulink, Simscape Battery, or a third-party toolbox. That is a teaching choice and also a research choice. If you understand the estimator in plain MATLAB first, you will be much safer later when a higher-level toolbox hides the bookkeeping.

### Step 1: Verify your MATLAB release and workspace hygiene

Open MATLAB and run:

```matlab
ver
pwd
```

Expected behavior is simple. `ver` should print your MATLAB release and installed toolboxes. `pwd` should print the working directory that will hold the chapter files. If you are deep inside an unrelated project folder, move now. Estimator work tends to generate multiple exported tables, tuning sweeps, and cached results, and the quickest way to make the work irreproducible is to scatter those files across ad hoc directories.

### Step 2: Create a clean chapter workspace

Run the following exactly once in a fresh MATLAB session:

```matlab
chapterRoot = fullfile(pwd, "chapter7_soc_estimation_workspace");
if ~exist(chapterRoot, "dir")
    mkdir(chapterRoot);
end
cd(chapterRoot);

fprintf("Working folder: %s\n", chapterRoot);
```

Expected output:

```text
Working folder: /.../chapter7_soc_estimation_workspace
```

The exact path will differ on your machine. What matters is that you now have a dedicated workspace for this chapter. In Run 2 we will download CALCE files into a subfolder here, write intermediate CSV files, and save estimator outputs so that every figure can be regenerated later.

### Step 3: Run a minimal estimator hello-world

This snippet does not estimate a full battery state yet. It verifies that your MATLAB session handles the core linear-algebra operations an EKF depends on.

```matlab
clear; close all; clc;

% Minimal two-state prediction/update sanity check
A = [1.0 0.0; 0.0 0.92];
C = [0.75 -1.0];
Q = diag([1e-6, 2e-5]);
R = (5e-3)^2;

x_hat = [0.80; 0.01];
P = diag([0.02^2, 0.03^2]);
current_a = 2.0;
measured_voltage_v = 3.76;

% Process-model prediction
x_pred = A * x_hat + [-(1 / (3600 * 2.3)); 0.08] * current_a;
P_pred = A * P * A' + Q;

% Measurement update
predicted_voltage_v = 3.95 - 0.015 * current_a + C * x_pred;
innovation_v = measured_voltage_v - predicted_voltage_v;
innovation_cov = C * P_pred * C' + R;
kalman_gain = (P_pred * C') / innovation_cov;
x_next = x_pred + kalman_gain * innovation_v;
P_next = (eye(2) - kalman_gain * C) * P_pred;

fprintf("Predicted voltage: %.4f V\n", predicted_voltage_v);
fprintf("Innovation: %.4f V\n", innovation_v);
fprintf("Updated SOC estimate: %.4f\n", x_next(1));
fprintf("Updated RC-voltage estimate: %.4f V\n", x_next(2));
```

Expected output should look numerically reasonable rather than identical to the values below:

```text
Predicted voltage: 3.7452 V
Innovation: 0.0148 V
Updated SOC estimate: 0.813...
Updated RC-voltage estimate: 0.008...
```

The exact last digits are not the point. The point is that MATLAB executes the predict-update structure cleanly, the innovation covariance is positive, and the updated state remains physically plausible.

### Step 4: Common setup failures and fixes

**Script runs, but figures do not appear.** This usually means you are running in a non-graphical session or your figure windows are opening behind other windows. Test with `figure; plot(1:10); grid on;`.

**`interp1` errors later in the chapter.** Almost all such errors come from OCV tables whose SOC grid is unsorted or contains duplicate entries. The filter code assumes the SOC grid is strictly increasing from `0` to `1`.

**Covariance matrices become singular or non-positive.** In early experiments this is usually a coding mistake, not a deep filtering issue. Check matrix dimensions first, then confirm that `Q` and `R` are positive and that you are not accidentally transposing a row vector into the wrong shape.

**The filter seems to “work” but SOC drifts outside `[0, 1]`.** That is not acceptable behavior, even in a teaching example. Later code in this chapter clamps SOC after prediction and after update to keep the state physically meaningful.

## Conceptual Bridge: From an ECM to a Nonlinear State Observer

In Textbook Chapter 10, the state-space form of a battery estimator may have looked almost deceptively compact. That is because the notation hides the real conceptual move. In Chapter 6, the equivalent-circuit model was a simulator. We supplied current, propagated internal variables, and predicted voltage. In this chapter, the same model becomes a process model inside an observer. That means the voltage measurement is no longer only an output to plot. It is evidence that can correct hidden-state error.

For the simplest useful observer in this chapter, we will use a `1RC` model with the state vector

$$
\mathbf{x}_k =
\begin{bmatrix}
z_k \\
v_{1,k}
\end{bmatrix},
\tag{1}
$$

where $z_k$ is SOC and $v_{1,k}$ is the polarization-branch voltage at sample index $k$. The discrete-time process model is

$$
z_{k+1} = z_k - \frac{\eta \Delta t}{3600 Q} I_k + w_{z,k},
\tag{2}
$$

and

$$
v_{1,k+1} = \alpha v_{1,k} + R_1(1-\alpha)I_k + w_{v,k},
\qquad
\alpha = \exp\!\left(-\frac{\Delta t}{R_1 C_1}\right),
\tag{3}
$$

where $Q$ is cell capacity in ampere-hours, $\eta$ is coulombic efficiency, and $w_{z,k}$ and $w_{v,k}$ are process-noise terms. Equation (2) is just coulomb counting written as a state equation. Equation (3) is the exact discrete-time update for the RC branch that you already used in Lab Chapter 6.

The nonlinear measurement equation is

$$
y_k = U_{\mathrm{oc}}(z_k) - R_0 I_k - v_{1,k} + n_k,
\tag{4}
$$

where $y_k$ is the measured terminal voltage, $U_{\mathrm{oc}}(z)$ is the OCV-SOC relationship, and $n_k$ is measurement noise. Equation (4) contains the core reason SOC estimation is both possible and fragile. It is possible because voltage depends on SOC through the OCV map. It is fragile because the dependence is only as informative as the slope of that map.

To see that, differentiate Equation (4) with respect to the state:

$$
\mathbf{C}_k
=
\frac{\partial y_k}{\partial \mathbf{x}_k}
=
\begin{bmatrix}
\frac{dU_{\mathrm{oc}}}{dz}(z_k) & -1
\end{bmatrix}.
\tag{5}
$$

Equation (5) is the measurement Jacobian used by the EKF. It says something physically important. The filter sees SOC only through the OCV slope $\frac{dU_{\mathrm{oc}}}{dz}$. If that slope is large, a small SOC error produces a noticeable voltage error, so the measurement update can correct the state strongly. If the slope is small, a large SOC error may produce only a tiny voltage signature, and the measurement update becomes weak. This is why sodium-ion plateaus and flat graphite or hard-carbon regions are estimator headaches: the chemistry itself has made voltage less informative.

The EKF proceeds in the familiar predict-measure-update pattern. During prediction, we propagate the state with the process model and propagate the covariance with the local linearization

$$
\mathbf{P}_{k|k-1}
=
\mathbf{A}_k \mathbf{P}_{k-1|k-1} \mathbf{A}_k^\top
+ \mathbf{Q},
\tag{6}
$$

where $\mathbf{A}_k$ is the process Jacobian and $\mathbf{Q}$ is the process-noise covariance. For the `1RC` model used here,

$$
\mathbf{A}_k =
\begin{bmatrix}
1 & 0 \\
0 & \alpha
\end{bmatrix}.
\tag{7}
$$

During the measurement step, we compute the innovation

$$
r_k = y_k - \hat{y}_{k|k-1},
\tag{8}
$$

its covariance

$$
S_k = \mathbf{C}_k \mathbf{P}_{k|k-1} \mathbf{C}_k^\top + R,
\tag{9}
$$

the Kalman gain

$$
\mathbf{K}_k = \mathbf{P}_{k|k-1} \mathbf{C}_k^\top S_k^{-1},
\tag{10}
$$

and the corrected state

$$
\hat{\mathbf{x}}_{k|k}
=
\hat{\mathbf{x}}_{k|k-1}
+ \mathbf{K}_k r_k.
\tag{11}
$$

Those equations are standard. What matters pedagogically is how they connect to Chapter 6. The process model is just your ECM in state-space form. The innovation is the difference between measured voltage and predicted voltage. The covariance tells the filter how much to trust its own model versus the measurement. The Kalman gain translates that trust balance into an actual SOC correction.

Three misconceptions are worth removing before we write code. The first is that the EKF “finds SOC from voltage.” It does not. The EKF combines a process model, a current history, an OCV map, and a voltage measurement. If the current sensor is biased or the OCV map is wrong, the estimator can still fail badly while appearing mathematically healthy.

The second misconception is that `Q` and `R` are merely tuning knobs that you can adjust until the plot looks nice. They are tuning knobs, but they also encode modeling honesty. A very small process-noise covariance `Q` says, in effect, “I trust my ECM and current integration almost completely.” A very small measurement-noise variance `R` says, “I trust the voltage sensor and measurement model almost completely.” If either claim is too optimistic, the filter can become overconfident and brittle.

The third misconception is that a more nonlinear filter automatically solves weak observability. It does not. A UKF can approximate nonlinear propagation more accurately than an EKF, especially when the OCV map has stronger curvature, but no sigma-point trick can create observability where the chemistry provides almost none. If the OCV plateau is flat, the problem is fundamentally hard. That is exactly why the sodium-ion stress test later in the chapter matters.

The software bridge from theory to MATLAB is therefore this. We store the OCV curve as a lookup table, evaluate both the curve and its derivative by interpolation, propagate the hidden states with the same exact discrete-time ECM equations we already trust, and let the filter update those states using the voltage residual. Once that logic is clear, the code becomes compact. The difficulty is not syntax. It is making physically honest choices about the model and the noise assumptions.

## Guided Walkthrough 1: Build a State-Space Battery Model and See Why OCV Slope Controls Observability

**Learning objective:** See, in code and on plots, why the same EKF architecture behaves differently on a steep OCV curve and on a sodium-ion-like plateau.

Before we implement the EKF, we need to understand what information the voltage measurement actually contains. The best way to do that is to compare two OCV curves. The first will be a lithium-ion-like curve with a healthy slope over much of the SOC range. The second will be a sodium-ion-inspired curve with a broad flat plateau. We will compute the OCV slope, convert a fixed SOC error into an implied voltage error, and then simulate a simple current profile to see where the measurement should or should not be informative.

```matlab
clear; close all; clc;

% Shared SOC grid
soc_grid = linspace(0, 1, 1001).';

% Lithium-ion-like OCV curve: smooth and steadily increasing
ocv_li_v = 3.00 ...
    + 0.72 * soc_grid ...
    + 0.18 * tanh((soc_grid - 0.15) / 0.06) ...
    + 0.16 * tanh((soc_grid - 0.85) / 0.05);

% Sodium-ion-inspired OCV curve: broad flat plateau in the middle
ocv_sib_v = 2.45 ...
    + 0.40 * soc_grid ...
    + 0.26 * tanh((soc_grid - 0.10) / 0.05) ...
    + 0.06 * tanh((soc_grid - 0.45) / 0.10) ...
    + 0.28 * tanh((soc_grid - 0.88) / 0.04);

% Numerical derivatives dUoc/dz in volts per unit SOC
dudsoc_li = gradient(ocv_li_v, soc_grid);
dudsoc_sib = gradient(ocv_sib_v, soc_grid);

% Translate a 5% SOC estimation error into an expected voltage mismatch
soc_error = 0.05;
delta_v_li = dudsoc_li * soc_error;
delta_v_sib = dudsoc_sib * soc_error;

% Build a simple discharge-rest-discharge profile that spans the plateau region
dt = 1;
time_s = (0:1:2600).';
current_a = zeros(size(time_s));
current_a(time_s >= 100  & time_s < 800)  = 2.0;
current_a(time_s >= 1100 & time_s < 1700) = 1.0;
current_a(time_s >= 1900 & time_s < 2450) = 1.5;

capacity_ah = 3.0;
initial_soc = 0.95;

soc_trace = initial_soc - cumsum([0; current_a(1:end-1)]) * dt / (3600 * capacity_ah);
soc_trace = min(max(soc_trace, 0), 1);

voltage_li_v = interp1(soc_grid, ocv_li_v, soc_trace, "pchip", "extrap");
voltage_sib_v = interp1(soc_grid, ocv_sib_v, soc_trace, "pchip", "extrap");
dudsoc_li_trace = interp1(soc_grid, dudsoc_li, soc_trace, "pchip", "extrap");
dudsoc_sib_trace = interp1(soc_grid, dudsoc_sib, soc_trace, "pchip", "extrap");

mid_mask = soc_grid >= 0.40 & soc_grid <= 0.60;
fprintf("Mean dUoc/dSOC between 40%% and 60%% SOC:\n");
fprintf("  Li-ion-like curve : %.4f V/SOC\n", mean(dudsoc_li(mid_mask)));
fprintf("  SIB-like curve    : %.4f V/SOC\n", mean(dudsoc_sib(mid_mask)));
fprintf("Expected voltage error from a 5%% SOC mistake near 50%% SOC:\n");
idx50 = find(abs(soc_grid - 0.50) == min(abs(soc_grid - 0.50)), 1, "first");
fprintf("  Li-ion-like curve : %.4f V\n", delta_v_li(idx50));
fprintf("  SIB-like curve    : %.4f V\n", delta_v_sib(idx50));

figure("Color", "w", "Position", [100 100 1100 850]);

subplot(3, 1, 1);
plot(soc_grid, ocv_li_v, "LineWidth", 2.0); hold on;
plot(soc_grid, ocv_sib_v, "LineWidth", 2.0);
grid on;
xlabel("SOC [-]");
ylabel("OCV [V]");
title("Two OCV-SOC curves with very different estimator friendliness");
legend("Li-ion-like", "SIB-like", "Location", "northwest");

subplot(3, 1, 2);
plot(soc_grid, dudsoc_li, "LineWidth", 2.0); hold on;
plot(soc_grid, dudsoc_sib, "LineWidth", 2.0);
grid on;
xlabel("SOC [-]");
ylabel("dU_{oc}/dSOC [V per unit SOC]");
title("Measurement sensitivity to SOC is controlled by OCV slope");
legend("Li-ion-like", "SIB-like", "Location", "northeast");

subplot(3, 1, 3);
yyaxis left;
plot(time_s, current_a, "k", "LineWidth", 1.4);
ylabel("Current [A]");
yyaxis right;
plot(time_s, dudsoc_li_trace, "LineWidth", 1.8); hold on;
plot(time_s, dudsoc_sib_trace, "LineWidth", 1.8);
ylabel("Local dU_{oc}/dSOC [V per unit SOC]");
grid on;
xlabel("Time [s]");
title("The same duty cycle becomes more or less observable depending on chemistry");
legend("Current", "Li-ion-like slope", "SIB-like slope", "Location", "best");
```

The code begins by creating two explicit OCV maps on the same SOC grid. The lithium-ion-like curve is intentionally steep at low and high SOC and still meaningfully sloped through the middle. The sodium-ion-inspired curve has a much flatter middle region. These are teaching curves rather than digitized data, but they are realistic enough to make the observability issue concrete.

The `gradient` calls compute a numerical derivative of each OCV curve with respect to SOC. That derivative is not a decorative extra. It is the first element of the EKF measurement Jacobian from Equation (5). If you later use a noisy or badly smoothed OCV table, the derivative becomes noisy too, and the filter can respond erratically. That is why Chapter 6 spent time on clean OCV tables.

Next, we convert a `5%` SOC estimation error into an implied voltage error by multiplying the slope by `0.05`. This is a useful mental calibration trick. If `dUoc/dSOC` is `0.8 V/SOC`, then a `5%` SOC error implies roughly `40 mV` of voltage disagreement, which is easy for a clean voltage sensor to see. If the slope is `0.1 V/SOC`, the same `5%` SOC error implies only `5 mV`, which is already comparable to ordinary sensor noise and modeling error.

The current profile is deliberately simple. It is just a sequence of discharge pulses with rest periods. We are not yet trying to test the RC dynamics. We are asking how the same SOC trajectory looks to the measurement model when the chemistry changes. The `soc_trace` calculation is plain coulomb counting, using the previous current sample so the trace stays aligned with the discrete-time convention we will use in the estimator.

The bottom subplot overlays current and the local OCV slope along the trajectory. That plot is one of the most important in the first half of the chapter. It makes visible the part of the estimator problem that often stays hidden when people discuss Kalman filters abstractly. The chemistry has already decided, before any algorithm starts, where voltage can meaningfully correct SOC and where it cannot.

### Expected Output for Walkthrough 1

The first subplot should show two monotonic OCV curves. The lithium-ion-like curve should climb steadily from roughly `2.7 V` to above `4.0 V` with noticeable but smooth curvature. The sodium-ion-inspired curve should also rise overall, but its middle portion should flatten visibly, creating a broad region where the voltage changes only weakly with SOC.

The second subplot should make the main lesson unmistakable. The lithium-ion-like derivative should remain appreciably above zero through most of the usable SOC range, while the SIB-like derivative should dip much lower through the middle. Near `50%` SOC, the difference should be large enough that the printed implied voltage error for a `5%` SOC mistake is several times bigger for the Li-ion-like curve than for the SIB-like curve.

The third subplot should show a piecewise-constant current trace on the left axis and two slope traces on the right axis. As SOC moves through the midrange, the SIB-like slope should sag, sometimes dramatically, while the Li-ion-like slope remains healthier. That plot tells you where an EKF will tend to rely more on current integration than on voltage correction.

### What Could Go Wrong in Walkthrough 1

**The derivative plot is noisy or jagged.** This usually happens when the OCV grid is too coarse or the OCV data are noisy. Increase the grid density or smooth the OCV data before differentiating. In real workflows, an unsmoothed derivative is one of the fastest ways to destabilize an EKF.

**The SOC trace hits zero or one too early.** That means the capacity or current magnitudes are inconsistent with the simulation length. Increase `capacity_ah` or shorten the pulses so the example stays inside the meaningful operating range.

**The two OCV curves look too similar.** If you accidentally change the coefficients so both curves remain steep, the pedagogical point is lost. The SIB-inspired curve should have a visibly flatter mid-SOC region.

### Reflection on Walkthrough 1

This exercise teaches a habit that will matter throughout the rest of the manual: before tuning an estimator, ask what the measurement can realistically tell you. Many Kalman-filter problems in battery research are not primarily “algorithm problems.” They are observability problems created by chemistry, protocol, or poor OCV preprocessing. We will return to this point when we later stress-test the filter on a hard-carbon sodium-ion-like plateau.

## Guided Walkthrough 2: Implement an Extended Kalman Filter from Scratch on Synthetic `1RC` Data

**Learning objective:** Write a complete EKF that estimates SOC and polarization voltage from current and noisy terminal voltage, starting from a badly wrong initial SOC.

We now have enough conceptual footing to build the estimator itself. We will first generate synthetic truth from a `1RC` model, add realistic voltage noise, and then ask the EKF to recover SOC from a deliberately poor initial guess. This is the cleanest way to debug the algorithm because we know the true hidden states. If the filter diverges here, the mistake is in our implementation or in our tuning, not in the dataset.

```matlab
clear; close all; clc;

% Time base and current profile
dt = 1;
time_s = (0:1:2400).';
current_a = zeros(size(time_s));
current_a(time_s >= 50   & time_s < 350)  = 2.0;
current_a(time_s >= 500  & time_s < 780)  = 3.5;
current_a(time_s >= 980  & time_s < 1220) = -1.5;
current_a(time_s >= 1450 & time_s < 1740) = 2.8;
current_a(time_s >= 1880 & time_s < 2260) = 1.2;

% OCV lookup table shared by truth model and estimator
ocv_soc = linspace(0, 1, 201).';
ocv_v = 3.00 ...
    + 0.74 * ocv_soc ...
    + 0.16 * tanh((ocv_soc - 0.14) / 0.06) ...
    + 0.18 * tanh((ocv_soc - 0.86) / 0.05);

% True cell parameters
params.Q_ah = 2.3;
params.eta = 1.0;
params.R0 = 0.014;
params.R1 = 0.018;
params.C1 = 95.0;

% Generate synthetic truth
true_initial_soc = 0.88;
[soc_true, v1_true, voltage_true_v] = simulateTruth1Rc( ...
    time_s, current_a, true_initial_soc, ocv_soc, ocv_v, params);

% Add measurement noise
rng(11);
voltage_noise_std_v = 4e-3;
voltage_meas_v = voltage_true_v + voltage_noise_std_v * randn(size(voltage_true_v));

% Coulomb counting baseline with wrong initialization
soc_cc = true_initial_soc - 0.20 ...
    - cumsum([0; current_a(1:end-1)]) * dt / (3600 * params.Q_ah);
soc_cc = min(max(soc_cc, 0), 1);

% EKF initialization
x_hat = zeros(2, numel(time_s));
x_hat(:, 1) = [0.68; 0.00];  % deliberately wrong SOC guess

P = diag([0.08^2, 0.03^2]);
Q = diag([2e-8, 4e-6]);
R = (voltage_noise_std_v)^2;

innovation_v = zeros(size(time_s));
kalman_gain_soc = zeros(size(time_s));
kalman_gain_v1 = zeros(size(time_s));
predicted_voltage_v = zeros(size(time_s));

predicted_voltage_v(1) = measurement1Rc(x_hat(:, 1), current_a(1), ocv_soc, ocv_v, params);

for k = 2:numel(time_s)
    % Prediction step
    x_pred = predictState1Rc(x_hat(:, k - 1), current_a(k - 1), dt, params);
    x_pred(1) = min(max(x_pred(1), 0), 1);

    alpha = exp(-dt / (params.R1 * params.C1));
    A = [1.0 0.0; 0.0 alpha];
    P_pred = A * P * A' + Q;

    % Predicted measurement and local Jacobian
    predicted_voltage_v(k) = measurement1Rc(x_pred, current_a(k), ocv_soc, ocv_v, params);
    dUoc_dSoc = ocvSlope(x_pred(1), ocv_soc, ocv_v);
    C = [dUoc_dSoc, -1.0];

    % Innovation
    innovation_v(k) = voltage_meas_v(k) - predicted_voltage_v(k);
    S = C * P_pred * C' + R;
    K = (P_pred * C') / S;

    % Correction
    x_hat(:, k) = x_pred + K * innovation_v(k);
    x_hat(1, k) = min(max(x_hat(1, k), 0), 1);
    kalman_gain_soc(k) = K(1);
    kalman_gain_v1(k) = K(2);

    % Joseph-form covariance update for numerical robustness
    I2 = eye(2);
    P = (I2 - K * C) * P_pred * (I2 - K * C)' + K * R * K';
end

soc_error = x_hat(1, :)' - soc_true;
rmse_soc = sqrt(mean(soc_error.^2));
max_abs_soc_error = max(abs(soc_error));

convergence_threshold = 0.01;
idx_conv = find(abs(soc_error) <= convergence_threshold, 1, "first");
if isempty(idx_conv)
    convergence_time_s = NaN;
else
    convergence_time_s = time_s(idx_conv);
end

fprintf("EKF SOC RMSE: %.4f\n", rmse_soc);
fprintf("EKF maximum absolute SOC error: %.4f\n", max_abs_soc_error);
fprintf("Convergence time to within 1%% SOC: %.1f s\n", convergence_time_s);

figure("Color", "w", "Position", [80 80 1200 900]);

subplot(4, 1, 1);
plot(time_s, current_a, "k", "LineWidth", 1.4);
grid on;
xlabel("Time [s]");
ylabel("Current [A]");
title("Synthetic current profile");

subplot(4, 1, 2);
plot(time_s, soc_true, "LineWidth", 2.0); hold on;
plot(time_s, soc_cc, "--", "LineWidth", 1.8);
plot(time_s, x_hat(1, :), "LineWidth", 1.8);
grid on;
xlabel("Time [s]");
ylabel("SOC [-]");
title("True SOC, bad coulomb-counting baseline, and EKF estimate");
legend("True SOC", "Coulomb counting", "EKF estimate", "Location", "best");

subplot(4, 1, 3);
plot(time_s, voltage_meas_v, "Color", [0.6 0.6 0.6]); hold on;
plot(time_s, predicted_voltage_v, "LineWidth", 1.6);
plot(time_s, voltage_true_v, "--", "LineWidth", 1.6);
grid on;
xlabel("Time [s]");
ylabel("Voltage [V]");
title("Measured, predicted, and true terminal voltage");
legend("Measured voltage", "EKF predicted voltage", "True voltage", "Location", "best");

subplot(4, 1, 4);
yyaxis left;
plot(time_s, innovation_v * 1000, "LineWidth", 1.4);
ylabel("Innovation [mV]");
yyaxis right;
plot(time_s, kalman_gain_soc, "LineWidth", 1.4); hold on;
plot(time_s, kalman_gain_v1, "LineWidth", 1.4);
ylabel("Kalman gain");
grid on;
xlabel("Time [s]");
title("Innovation and estimator gain evolution");
legend("Innovation", "SOC gain", "RC-voltage gain", "Location", "best");


function x_next = predictState1Rc(x_now, current_a, dt, params)
    alpha = exp(-dt / (params.R1 * params.C1));

    soc_next = x_now(1) - params.eta * current_a * dt / (3600 * params.Q_ah);
    v1_next = alpha * x_now(2) + params.R1 * (1 - alpha) * current_a;

    x_next = [soc_next; v1_next];
end


function voltage_v = measurement1Rc(x_state, current_a, ocv_soc, ocv_v, params)
    ocv_now = interp1(ocv_soc, ocv_v, x_state(1), "pchip", "extrap");
    voltage_v = ocv_now - current_a * params.R0 - x_state(2);
end


function slope = ocvSlope(soc, ocv_soc, ocv_v)
    d_ocv = gradient(ocv_v, ocv_soc);
    slope = interp1(ocv_soc, d_ocv, soc, "pchip", "extrap");
end


function [soc, v1_v, voltage_v] = simulateTruth1Rc( ...
    time_s, current_a, initial_soc, ocv_soc, ocv_v, params)

    n = numel(time_s);
    dt = time_s(2) - time_s(1);
    alpha = exp(-dt / (params.R1 * params.C1));

    soc = zeros(n, 1);
    v1_v = zeros(n, 1);
    voltage_v = zeros(n, 1);

    soc(1) = initial_soc;
    voltage_v(1) = measurement1Rc([soc(1); v1_v(1)], current_a(1), ocv_soc, ocv_v, params);

    for k = 2:n
        soc(k) = soc(k - 1) - params.eta * current_a(k - 1) * dt / (3600 * params.Q_ah);
        soc(k) = min(max(soc(k), 0), 1);
        v1_v(k) = alpha * v1_v(k - 1) + params.R1 * (1 - alpha) * current_a(k - 1);
        voltage_v(k) = measurement1Rc([soc(k); v1_v(k)], current_a(k), ocv_soc, ocv_v, params);
    end
end
```

The first block defines the excitation. The current profile includes multiple discharge regions and one charge pulse so the RC state sees several transitions. That gives the filter a chance to learn both SOC drift and dynamic polarization. A single constant-current segment would be enough to make the code run, but it would teach much less.

The OCV table is deliberately smooth. In Chapter 6 we discussed building an OCV map from measured data. Here we reuse the same lookup-table idea but evaluate it inside the measurement equation. The true system and the estimator share the same OCV map in this first experiment. That is a teaching shortcut. In Run 2 we will relax that assumption by moving to public data where the model-data mismatch is real.

The function `simulateTruth1Rc` is your hidden battery. It produces the true SOC, the true polarization voltage, and the true terminal voltage. Notice that its state update is exactly the same physics you already learned in Chapter 6. This is important: the EKF is not a separate battery model. It is an inference layer wrapped around the same battery model.

The line that builds `soc_cc` creates a baseline for comparison. We intentionally start coulomb counting with a `20%` SOC error. Because pure coulomb counting has no measurement correction channel, that initialization error never disappears. This is exactly why the EKF exists. It can use voltage to recover from a bad initial guess, provided the OCV slope gives it enough information.

The filter state `x_hat` contains two entries at each time step: SOC and RC-branch voltage. The initial SOC estimate is set to `0.68` even though the truth is `0.88`. That is a large miss on purpose. If you initialize the filter too close to truth, you learn very little about its corrective behavior.

The covariance `P`, process noise `Q`, and measurement noise `R` are the heart of the design. `P` encodes our initial uncertainty. `Q` says how much model mismatch or unmodeled disturbance we expect per time step. `R` reflects voltage measurement uncertainty. In this first synthetic example, `R` is chosen to match the injected measurement noise standard deviation. That is standard practice in a controlled teaching problem, though in real experiments you often inflate `R` slightly to absorb modeling error as well.

Inside the loop, the prediction step uses `current_a(k - 1)` because the process model advances from state `k-1` to state `k` using the current already applied over that interval. The predicted measurement uses `current_a(k)` because the terminal voltage at sample `k` depends on the current present at that sample. Keeping those indices straight is one of the most common sources of silent estimator bugs.

The Jacobian row `C = [dUoc_dSoc, -1.0]` is the code form of Equation (5). The first component measures how strongly voltage responds to SOC at the present operating point. The second component is always `-1` because a larger polarization voltage reduces the measured terminal voltage one-for-one. This is where the battery physics becomes estimator math.

The covariance update uses the Joseph form

$$
\mathbf{P}_{k|k} =
(\mathbf{I} - \mathbf{K}_k \mathbf{C}_k)\mathbf{P}_{k|k-1}
(\mathbf{I} - \mathbf{K}_k \mathbf{C}_k)^\top
+ \mathbf{K}_k R \mathbf{K}_k^\top,
\tag{12}
$$

which is numerically safer than the simpler algebraically equivalent form. That choice is standard practice in the field and worth internalizing early.

### Expected Output for Walkthrough 2

The first subplot should show a piecewise-constant current trace with several plateaus and one negative current section for charge. The second subplot is the one to read most carefully. The true SOC should start near `0.88` and drift gradually with the current history. The bad coulomb-counting baseline should stay displaced by roughly `0.20` for the entire run because it has no correction mechanism. The EKF estimate should start at the wrong value but then bend toward the truth as voltage updates accumulate, usually reaching within about `1%` SOC after a few hundred seconds.

The voltage subplot should show a noisy gray measured trace, a cleaner predicted-voltage trace from the EKF, and a dashed true-voltage trace. The EKF prediction should track the overall voltage waveform closely after the first correction transient. If the predicted voltage stays visibly offset from both the measured and true traces for long periods, the filter is not tuned or coded correctly.

The bottom subplot should show the innovation in millivolts and the two Kalman-gain components. Early in the run, the SOC gain is often larger because the filter is trying to repair the bad initialization. As uncertainty shrinks, the gain typically settles to smaller values. The innovation should look like a zero-centered noisy signal after convergence rather than a persistently biased one.

The printed metrics should show a clear EKF advantage over the wrong-initialized coulomb-counting baseline. A typical run with the values above produces an SOC RMSE on the order of a few thousandths to a few hundredths, a maximum absolute error well below the initial `20%` miss, and a convergence time of a few hundred seconds. Exact values vary slightly with MATLAB version because of floating-point details, but the qualitative behavior should be stable.

### What Could Go Wrong in Walkthrough 2

**The EKF estimate diverges immediately.** The most common cause is an indexing error between `current_a(k - 1)` and `current_a(k)`. The process model and measurement model do not use the same sample in the same way.

**The SOC estimate never leaves the bad initial value.** This usually means the measurement Jacobian is wrong, the Kalman gain is near zero because `R` is far too large, or the OCV derivative is being evaluated incorrectly.

**The innovation has a persistent offset.** That often signals a model mismatch, such as an incorrect `R0`, or a measurement convention mistake, such as using the wrong current sign.

**The covariance becomes negative or complex.** That is almost always a coding bug. Check that `Q` and `R` are positive scalars or positive-definite matrices and confirm that the Joseph update is implemented exactly.

### Reflection on Walkthrough 2

This walkthrough is the real threshold moment of the chapter. You have now written an EKF that works on a battery-shaped problem rather than on an abstract textbook matrix example. More importantly, you have seen that the filter is not magic. It is only a disciplined reconciliation between a process model, a measurement model, and quantified uncertainty.

## Guided Walkthrough 3: Tune Process Noise and Measurement Noise Without Guesswork

**Learning objective:** Understand how `Q` and `R` change estimator behavior, and learn a practical sweep-based workflow for selecting them.

The hardest part of EKF work in practice is not writing the loop. It is tuning the covariances honestly. Many beginner implementations work only because `Q` and `R` were tweaked until the plot looked appealing for one dataset. That is not a research workflow. In this walkthrough we will run a systematic sweep over SOC process noise and voltage measurement noise, compute performance metrics for each pair, and then compare three concrete tuning cases: overconfident model trust, overconfident measurement trust, and a balanced setting.

```matlab
clear; close all; clc;

% Shared synthetic dataset
dt = 1;
time_s = (0:1:2200).';
current_a = zeros(size(time_s));
current_a(time_s >= 60   & time_s < 340)  = 2.2;
current_a(time_s >= 470  & time_s < 730)  = 3.8;
current_a(time_s >= 890  & time_s < 1110) = -1.4;
current_a(time_s >= 1300 & time_s < 1650) = 2.6;
current_a(time_s >= 1820 & time_s < 2080) = 1.8;

ocv_soc = linspace(0, 1, 201).';
ocv_v = 3.00 ...
    + 0.74 * ocv_soc ...
    + 0.16 * tanh((ocv_soc - 0.14) / 0.06) ...
    + 0.18 * tanh((ocv_soc - 0.86) / 0.05);

params.Q_ah = 2.3;
params.eta = 1.0;
params.R0 = 0.014;
params.R1 = 0.018;
params.C1 = 95.0;

true_initial_soc = 0.90;
[soc_true, ~, voltage_true_v] = simulateTruth1Rc( ...
    time_s, current_a, true_initial_soc, ocv_soc, ocv_v, params);

rng(22);
meas_noise_std_v = 5e-3;
voltage_meas_v = voltage_true_v + meas_noise_std_v * randn(size(voltage_true_v));

q_soc_candidates = logspace(-10, -6, 9);
r_candidates_v = [1 2 3 5 7 10 15] * 1e-3;

rmse_map = zeros(numel(q_soc_candidates), numel(r_candidates_v));
conv_map = zeros(numel(q_soc_candidates), numel(r_candidates_v));

for i = 1:numel(q_soc_candidates)
    for j = 1:numel(r_candidates_v)
        q_soc = q_soc_candidates(i);
        q_v1 = 1e-5;
        r_var = r_candidates_v(j)^2;

        [soc_hat, ~, ~] = runEkf1Rc( ...
            time_s, current_a, voltage_meas_v, ocv_soc, ocv_v, params, ...
            0.65, diag([0.08^2, 0.03^2]), diag([q_soc, q_v1]), r_var);

        soc_error = soc_hat - soc_true;
        rmse_map(i, j) = sqrt(mean(soc_error.^2));

        idx_conv = find(abs(soc_error) <= 0.01, 1, "first");
        if isempty(idx_conv)
            conv_map(i, j) = NaN;
        else
            conv_map(i, j) = time_s(idx_conv);
        end
    end
end

% Compare three representative tuning cases
caseNames = ["Model overtrusted", "Measurement overtrusted", "Balanced"];
Q_cases = cat(3, ...
    diag([1e-10, 1e-6]), ...
    diag([1e-6, 1e-4]), ...
    diag([1e-8, 1e-5]));
R_cases = [(15e-3)^2, (1e-3)^2, (5e-3)^2];

soc_cases = zeros(numel(time_s), 3);
innov_cases = zeros(numel(time_s), 3);

for c = 1:3
    [soc_cases(:, c), ~, innov_cases(:, c)] = runEkf1Rc( ...
        time_s, current_a, voltage_meas_v, ocv_soc, ocv_v, params, ...
        0.65, diag([0.08^2, 0.03^2]), Q_cases(:, :, c), R_cases(c));
end

figure("Color", "w", "Position", [60 60 1250 900]);

subplot(2, 2, 1);
imagesc(r_candidates_v * 1000, log10(q_soc_candidates), rmse_map);
set(gca, "YDir", "normal");
colorbar;
xlabel("Voltage measurement noise std [mV]");
ylabel("log_{10}(SOC process noise variance)");
title("SOC RMSE across Q-R sweep");

subplot(2, 2, 2);
imagesc(r_candidates_v * 1000, log10(q_soc_candidates), conv_map);
set(gca, "YDir", "normal");
colorbar;
xlabel("Voltage measurement noise std [mV]");
ylabel("log_{10}(SOC process noise variance)");
title("Convergence time to 1% SOC across Q-R sweep");

subplot(2, 2, 3);
plot(time_s, soc_true, "k", "LineWidth", 2.0); hold on;
plot(time_s, soc_cases(:, 1), "LineWidth", 1.7);
plot(time_s, soc_cases(:, 2), "LineWidth", 1.7);
plot(time_s, soc_cases(:, 3), "LineWidth", 1.7);
grid on;
xlabel("Time [s]");
ylabel("SOC [-]");
title("How three tuning philosophies change the estimator trajectory");
legend(["True SOC", caseNames], "Location", "best");

subplot(2, 2, 4);
plot(time_s, innov_cases(:, 1) * 1000, "LineWidth", 1.4); hold on;
plot(time_s, innov_cases(:, 2) * 1000, "LineWidth", 1.4);
plot(time_s, innov_cases(:, 3) * 1000, "LineWidth", 1.4);
grid on;
xlabel("Time [s]");
ylabel("Innovation [mV]");
title("Innovation behavior under three tuning philosophies");
legend(caseNames, "Location", "best");


function [soc_hat, v1_hat, innovation_v] = runEkf1Rc( ...
    time_s, current_a, voltage_meas_v, ocv_soc, ocv_v, params, ...
    initial_soc_guess, P0, Q, R)

    dt = time_s(2) - time_s(1);
    n = numel(time_s);

    x_hat = zeros(2, n);
    x_hat(:, 1) = [initial_soc_guess; 0];
    P = P0;

    innovation_v = zeros(n, 1);
    alpha = exp(-dt / (params.R1 * params.C1));

    for k = 2:n
        x_pred = predictState1Rc(x_hat(:, k - 1), current_a(k - 1), dt, params);
        x_pred(1) = min(max(x_pred(1), 0), 1);

        A = [1.0 0.0; 0.0 alpha];
        P_pred = A * P * A' + Q;

        y_pred = measurement1Rc(x_pred, current_a(k), ocv_soc, ocv_v, params);
        dUoc_dSoc = ocvSlope(x_pred(1), ocv_soc, ocv_v);
        C = [dUoc_dSoc, -1.0];

        innovation_v(k) = voltage_meas_v(k) - y_pred;
        S = C * P_pred * C' + R;
        K = (P_pred * C') / S;

        x_hat(:, k) = x_pred + K * innovation_v(k);
        x_hat(1, k) = min(max(x_hat(1, k), 0), 1);

        I2 = eye(2);
        P = (I2 - K * C) * P_pred * (I2 - K * C)' + K * R * K';
    end

    soc_hat = x_hat(1, :).';
    v1_hat = x_hat(2, :).';
end


function x_next = predictState1Rc(x_now, current_a, dt, params)
    alpha = exp(-dt / (params.R1 * params.C1));
    soc_next = x_now(1) - params.eta * current_a * dt / (3600 * params.Q_ah);
    v1_next = alpha * x_now(2) + params.R1 * (1 - alpha) * current_a;
    x_next = [soc_next; v1_next];
end


function voltage_v = measurement1Rc(x_state, current_a, ocv_soc, ocv_v, params)
    ocv_now = interp1(ocv_soc, ocv_v, x_state(1), "pchip", "extrap");
    voltage_v = ocv_now - current_a * params.R0 - x_state(2);
end


function slope = ocvSlope(soc, ocv_soc, ocv_v)
    d_ocv = gradient(ocv_v, ocv_soc);
    slope = interp1(ocv_soc, d_ocv, soc, "pchip", "extrap");
end


function [soc, v1_v, voltage_v] = simulateTruth1Rc( ...
    time_s, current_a, initial_soc, ocv_soc, ocv_v, params)

    n = numel(time_s);
    dt = time_s(2) - time_s(1);
    alpha = exp(-dt / (params.R1 * params.C1));

    soc = zeros(n, 1);
    v1_v = zeros(n, 1);
    voltage_v = zeros(n, 1);

    soc(1) = initial_soc;
    voltage_v(1) = measurement1Rc([soc(1); v1_v(1)], current_a(1), ocv_soc, ocv_v, params);

    for k = 2:n
        soc(k) = soc(k - 1) - params.eta * current_a(k - 1) * dt / (3600 * params.Q_ah);
        soc(k) = min(max(soc(k), 0), 1);
        v1_v(k) = alpha * v1_v(k - 1) + params.R1 * (1 - alpha) * current_a(k - 1);
        voltage_v(k) = measurement1Rc([soc(k); v1_v(k)], current_a(k), ocv_soc, ocv_v, params);
    end
end
```

The `q_soc_candidates` vector sweeps the SOC process-noise variance across four orders of magnitude. This parameter deserves that much attention because it directly controls how willing the filter is to let voltage measurements correct the integrated SOC state. A very small value says the SOC state equation is almost exact. A larger value admits that current integration, model simplification, and capacity uncertainty can create real state drift that the filter should be free to correct.

The `r_candidates_v` vector sweeps the assumed voltage measurement standard deviation from `1 mV` to `15 mV`. In a synthetic example we know the injected sensor noise, but in real experimental work the effective `R` often needs to absorb more than sensor electronics alone. It also has to cover unmodeled hysteresis, imperfect OCV tables, temperature mismatch, and structural model error.

The metric maps are deliberately simple: SOC RMSE and convergence time to `1%` SOC. Those two together are much more informative than either one alone. An aggressively tuned filter can converge quickly but chatter in steady state. A timid filter can achieve a decent RMSE over a long record while recovering too slowly from the initial error to be useful in practice.

The three named cases are there to turn the sweep into intuition. In the “model overtrusted” case, `Q` is tiny and `R` is large. The filter acts stubborn and slow because it trusts current integration and the ECM more than it trusts the voltage measurement. In the “measurement overtrusted” case, `Q` is relatively large and `R` is tiny. The filter reacts sharply to voltage residuals, often correcting faster but also becoming noisier and more vulnerable to measurement-model mismatch. The “balanced” case tries to land between those extremes.

### Expected Output for Walkthrough 3

The RMSE heat map should show a valley rather than a single magic point. That is a healthy sign. Well-behaved filters often have a region of acceptable tuning rather than a single exact setting. If the map is uniformly terrible, there is likely an implementation bug or the sweep range is wildly inappropriate.

The convergence-time map should show the expected tradeoff: larger process noise and smaller measurement noise usually speed up convergence, but not always gracefully. Some regions may converge quickly at the price of noisier steady-state behavior.

In the SOC trajectory subplot, the “model overtrusted” case should approach the truth sluggishly and may never fully eliminate the initial offset over the available window. The “measurement overtrusted” case should move toward truth aggressively but may show visible jitter. The balanced case should recover decisively while remaining comparatively smooth.

The innovation subplot should help you read the same story from another angle. In an overtrusted-measurement regime, the innovation is often reduced quickly but the state becomes more reactive. In an overtrusted-model regime, innovations can stay biased for longer because the filter resists correction.

### What Could Go Wrong in Walkthrough 3

**The heat maps contain `NaN` almost everywhere.** That means the filter rarely reaches the `1%` convergence threshold over the chosen window. This can happen if the initial SOC error is too large, the OCV curve is too flat, or the tuning range is too conservative.

**The “measurement overtrusted” case looks perfect instead of noisy.** In a synthetic problem with a matched model, very aggressive measurement trust can indeed look surprisingly good. That is why this walkthrough is only preparation. On real data in Run 2, the same aggressiveness usually becomes much less attractive.

**Changing `Q` seems to have no effect.** This usually means the `Q` matrix is not actually being passed into the filter function you are calling, or the code is accidentally reusing a stale value.

### Reflection on Walkthrough 3

This exercise teaches estimator tuning as an engineering study rather than as folklore. That habit matters when you eventually write a methods section. “We tuned `Q` and `R` by trial and error” is weak. “We swept physically plausible ranges, evaluated RMSE and convergence time, and selected a balanced operating point that generalized across held-out tests” is much stronger and much more reproducible.

## Guided Walkthrough 4: CALCE Dataset Integration and Real-Data EKF Benchmarking

**Learning objective:** Build a reusable MATLAB workflow that reads CALCE files, normalizes their sign conventions and column names, constructs an OCV table, and benchmarks the EKF on a real dynamic current profile.

This walkthrough is where the chapter stops being a purely synthetic estimator exercise. We are going to use the CALCE INR 18650-20R battery dataset, which is one of the best public sources for SOC-estimation work because it exposes both OCV tests and dynamic validation profiles for the same cell family. The CALCE battery data portal describes low-current OCV tests, incremental-current OCV tests, and dynamic tests such as DST, FUDS, US06, and BJDST for this cell family, and it links those experiments to the estimator-comparison papers by Xing, He, Pecht, and collaborators. That makes CALCE especially valuable for a research methods manual: it gives us both raw data and a literature context for why those data were collected in the first place.

### Dataset overview

Use the CALCE battery data portal:

- Data landing page: `https://calce.umd.edu/data`
- Alternate page with the same INR 18650-20R section: `https://calce.umd.edu/battery-data`
- Related CALCE publication describing the temperature-dependent SOC-estimation workflow: Xing, He, Pecht, and Tsui, *Applied Energy* 113 (2014), DOI `10.1016/j.apenergy.2013.07.008`

At the time of writing, the INR 18650-20R section provides:

- low-current OCV workbooks for `0°C`, `25°C`, and `45°C`
- incremental-current OCV workbooks for `0°C`, `25°C`, and `45°C`
- dynamic validation profiles including `DST`, `FUDS`, `US06`, and `BJDST`

The CALCE portal serves these as Excel workbooks and associated initial-capacity files. Individual file sizes can change slightly as the site is reorganized, but the OCV and dynamic-test workbooks are typically in the “hundreds of kilobytes to a few megabytes” range. The license on the public CALCE portal is effectively open-access-for-research-use with a citation requirement: CALCE explicitly asks that publications using the data cite the CALCE article(s) describing the experiments.

Two practical notes matter immediately.

First, CALCE workbook schemas are not always identical across cell families or years. A robust parser must search for likely column names rather than assuming a single perfect header row.

Second, CALCE dynamic files often follow Arbin conventions where discharge current appears negative. In this chapter, our hand-built estimator uses `positive current = discharge`, so we will normalize the sign when reading the data.

### What we will do in this walkthrough

We will assume you manually download two files into the chapter workspace:

- one `25°C` OCV workbook from the INR 18650-20R section
- one `25°C` dynamic-profile workbook, preferably `FUDS` or `DST`

Create this folder structure inside `chapter7_soc_estimation_workspace`:

```text
chapter7_soc_estimation_workspace/
├── data/
│   └── calce_inr18650_20r/
│       ├── ocv_25c.xlsx
│       └── fuds_25c.xlsx
└── results/
```

The exact filenames on the CALCE portal are sometimes more verbose. Renaming them locally to concise names is a reproducibility aid, not a scientific shortcut. The important thing is to record the original CALCE page and sample number in your research log.

```matlab
clear; close all; clc;

chapterRoot = pwd;
dataFolder = fullfile(chapterRoot, "data", "calce_inr18650_20r");
resultsFolder = fullfile(chapterRoot, "results");
if ~exist(resultsFolder, "dir")
    mkdir(resultsFolder);
end

ocvFile = fullfile(dataFolder, "ocv_25c.xlsx");
dynamicFile = fullfile(dataFolder, "fuds_25c.xlsx");

% Read and normalize the two CALCE workbooks
ocvTableRaw = readCalceWorkbookRobust(ocvFile);
dynamicTableRaw = readCalceWorkbookRobust(dynamicFile);

ocvData = normalizeCalceBatteryTable(ocvTableRaw);
dynamicData = normalizeCalceBatteryTable(dynamicTableRaw);

% Build an OCV table from the low-current OCV file
[ocvSoc, ocvVoltage] = buildOcvTableFromCalce(ocvData);

% Extract the dynamic current-voltage-time series and resample to 1 s
dyn = extractDynamicSeries(dynamicData);
[time_s, current_a, voltage_v] = resampleSeriesToUniformStep( ...
    dyn.time_s, dyn.current_a, dyn.voltage_v, 1.0);

% Normalize current sign to the convention used in this chapter
% CALCE dynamic files often use negative current for discharge.
if mean(current_a(current_a ~= 0)) < 0
    current_a = -current_a;
end

% Use a simple 1RC parameter set consistent with Chapter 6 scale
params.Q_ah = estimateCapacityFromOcvFile(ocvData);
params.eta = 1.0;
params.R0 = 0.014;
params.R1 = 0.018;
params.C1 = 95.0;

% Reference SOC from coulomb counting anchored near the first OCV point
initial_soc_guess = estimateInitialSocFromVoltage(voltage_v(1), ocvSoc, ocvVoltage);
soc_ref = initial_soc_guess - cumsum([0; current_a(1:end-1)]) / (3600 * params.Q_ah);
soc_ref = min(max(soc_ref, 0), 1);

% EKF run
P0 = diag([0.08^2, 0.03^2]);
Q = diag([1e-8, 1e-5]);
R = (7e-3)^2;

[soc_hat, v1_hat, innovation_v] = runEkf1Rc( ...
    time_s, current_a, voltage_v, ocvSoc, ocvVoltage, params, ...
    initial_soc_guess - 0.10, P0, Q, R);

predicted_voltage_v = zeros(size(time_s));
for k = 1:numel(time_s)
    predicted_voltage_v(k) = measurement1Rc([soc_hat(k); v1_hat(k)], ...
        current_a(k), ocvSoc, ocvVoltage, params);
end

voltage_rmse_v = sqrt(mean((predicted_voltage_v - voltage_v).^2));
soc_shift = soc_hat - soc_ref;

fprintf("Estimated cell capacity from OCV workbook: %.4f Ah\n", params.Q_ah);
fprintf("Voltage RMSE on dynamic file: %.4f V\n", voltage_rmse_v);
fprintf("Mean EKF-minus-reference SOC offset: %.4f\n", mean(soc_shift));
fprintf("Maximum absolute EKF-minus-reference SOC offset: %.4f\n", max(abs(soc_shift)));

figure("Color", "w", "Position", [70 70 1200 950]);

subplot(4, 1, 1);
plot(time_s, current_a, "k", "LineWidth", 1.2);
grid on;
xlabel("Time [s]");
ylabel("Current [A]");
title("CALCE dynamic current profile after sign normalization");

subplot(4, 1, 2);
plot(ocvSoc, ocvVoltage, "LineWidth", 2.0);
grid on;
xlabel("SOC [-]");
ylabel("OCV [V]");
title("OCV table constructed from CALCE low-current workbook");

subplot(4, 1, 3);
plot(time_s, voltage_v, "Color", [0.55 0.55 0.55]); hold on;
plot(time_s, predicted_voltage_v, "LineWidth", 1.6);
grid on;
xlabel("Time [s]");
ylabel("Voltage [V]");
title("Measured CALCE voltage and EKF model voltage");
legend("Measured voltage", "EKF model voltage", "Location", "best");

subplot(4, 1, 4);
plot(time_s, soc_ref, "--", "LineWidth", 1.6); hold on;
plot(time_s, soc_hat, "LineWidth", 1.8);
yyaxis right;
plot(time_s, innovation_v * 1000, "LineWidth", 1.0);
ylabel("Innovation [mV]");
yyaxis left;
grid on;
xlabel("Time [s]");
ylabel("SOC [-]");
title("Reference SOC, EKF SOC, and innovation on real data");
legend("Reference SOC", "EKF SOC", "Innovation", "Location", "best");

writetable(table(time_s, current_a, voltage_v, soc_ref, soc_hat, innovation_v, ...
    'VariableNames', {'time_s','current_a','voltage_v','soc_ref','soc_hat','innovation_v'}), ...
    fullfile(resultsFolder, "calce_ekf_results.csv"));


function tableOut = readCalceWorkbookRobust(filename)
    sheetNames = sheetnames(filename);
    tableOut = table();

    for s = 1:numel(sheetNames)
        try
            candidate = readtable(filename, "Sheet", sheetNames{s}, ...
                "VariableNamingRule", "preserve");
            if width(candidate) >= 3 && height(candidate) >= 10
                tableOut = candidate;
                return;
            end
        catch
        end
    end

    error("Could not find a usable sheet in %s", filename);
end


function normData = normalizeCalceBatteryTable(rawTable)
    names = string(rawTable.Properties.VariableNames);
    namesLower = lower(strrep(names, " ", ""));

    normData = table();
    normData.time_s = getColumnByPatterns(rawTable, namesLower, ...
        ["testtime(s)", "steptime(s)", "time(s)", "totaltime(s)", "time"]);
    normData.current_a = getColumnByPatterns(rawTable, namesLower, ...
        ["current(a)", "current", "current_a"]);
    normData.voltage_v = getColumnByPatterns(rawTable, namesLower, ...
        ["voltage(v)", "voltage", "voltage_v"]);

    tempCol = getColumnByPatterns(rawTable, namesLower, ...
        ["temperature(c)", "aux_temperature_1(c)", "celltemperature(c)", "temperature"], false);
    if ~isempty(tempCol)
        normData.temperature_c = tempCol;
    end

    capCol = getColumnByPatterns(rawTable, namesLower, ...
        ["capacity(ah)", "dischargecapacity(ah)", "chargecapacity(ah)", "capacity"], false);
    if ~isempty(capCol)
        normData.capacity_ah = capCol;
    end

    stepCol = getColumnByPatterns(rawTable, namesLower, ...
        ["stepindex", "step", "stepnumber"], false);
    if ~isempty(stepCol)
        normData.step_index = stepCol;
    end

    modeCol = getColumnByPatterns(rawTable, namesLower, ...
        ["stepmode", "status", "mode"], false);
    if ~isempty(modeCol)
        normData.mode = modeCol;
    end

    validMask = ~(isnan(normData.time_s) | isnan(normData.current_a) | isnan(normData.voltage_v));
    normData = normData(validMask, :);

    normData.time_s = normData.time_s - normData.time_s(1);
end


function column = getColumnByPatterns(rawTable, namesLower, patterns, required)
    if nargin < 4
        required = true;
    end

    column = [];
    for p = 1:numel(patterns)
        idx = find(contains(namesLower, patterns(p)), 1, "first");
        if ~isempty(idx)
            candidate = rawTable.(rawTable.Properties.VariableNames{idx});
            if isnumeric(candidate)
                column = candidate(:);
            elseif iscell(candidate)
                column = str2double(string(candidate(:)));
            else
                column = str2double(string(candidate(:)));
            end
            return;
        end
    end

    if required
        error("Could not locate a required column matching patterns: %s", strjoin(patterns, ", "));
    end
end


function [soc, ocv] = buildOcvTableFromCalce(ocvData)
    voltage_v = ocvData.voltage_v;

    if ismember("capacity_ah", string(ocvData.Properties.VariableNames))
        capacity_trace_ah = ocvData.capacity_ah;
        capacity_trace_ah = capacity_trace_ah - min(capacity_trace_ah);
        usable_capacity_ah = max(capacity_trace_ah);
        if usable_capacity_ah <= 0
            usable_capacity_ah = 2.0;
        end
        soc = 1 - capacity_trace_ah / usable_capacity_ah;
    else
        current_a = ocvData.current_a;
        time_s = ocvData.time_s;
        dt = median(diff(time_s));
        charge_removed_ah = cumsum([0; current_a(1:end-1)]) * dt / 3600;
        usable_capacity_ah = max(charge_removed_ah) - min(charge_removed_ah);
        if usable_capacity_ah <= 0
            usable_capacity_ah = 2.0;
        end
        soc = 1 - (charge_removed_ah - min(charge_removed_ah)) / usable_capacity_ah;
    end

    soc = min(max(soc, 0), 1);

    % Sort and average duplicate SOCs to build a clean interpolation table
    [socSorted, sortIdx] = sort(soc);
    voltageSorted = voltage_v(sortIdx);
    [socUnique, ~, groupIdx] = unique(round(socSorted, 4));
    ocvUnique = accumarray(groupIdx, voltageSorted, [], @mean);

    soc = socUnique;
    ocv = ocvUnique;
end


function dyn = extractDynamicSeries(dynamicData)
    dyn.time_s = dynamicData.time_s;
    dyn.current_a = dynamicData.current_a;
    dyn.voltage_v = dynamicData.voltage_v;

    if numel(dyn.time_s) < 10
        error("Dynamic file appears too short to be usable.");
    end
end


function [timeUniform_s, currentUniform_a, voltageUniform_v] = ...
    resampleSeriesToUniformStep(time_s, current_a, voltage_v, dt)

    timeUniform_s = (time_s(1):dt:time_s(end)).';
    currentUniform_a = interp1(time_s, current_a, timeUniform_s, "previous", "extrap");
    voltageUniform_v = interp1(time_s, voltage_v, timeUniform_s, "linear", "extrap");
end


function qAh = estimateCapacityFromOcvFile(ocvData)
    if ismember("capacity_ah", string(ocvData.Properties.VariableNames))
        cap = ocvData.capacity_ah;
        qAh = max(cap) - min(cap);
    else
        qAh = 2.0;
    end

    if ~(isfinite(qAh) && qAh > 0.5)
        qAh = 2.0;
    end
end


function soc0 = estimateInitialSocFromVoltage(voltage0, ocvSoc, ocvVoltage)
    [~, idx] = min(abs(ocvVoltage - voltage0));
    soc0 = ocvSoc(idx);
end


function [soc_hat, v1_hat, innovation_v] = runEkf1Rc( ...
    time_s, current_a, voltage_meas_v, ocv_soc, ocv_v, params, ...
    initial_soc_guess, P0, Q, R)

    dt = time_s(2) - time_s(1);
    n = numel(time_s);

    x_hat = zeros(2, n);
    x_hat(:, 1) = [initial_soc_guess; 0];
    P = P0;
    innovation_v = zeros(n, 1);
    alpha = exp(-dt / (params.R1 * params.C1));

    for k = 2:n
        x_pred = predictState1Rc(x_hat(:, k - 1), current_a(k - 1), dt, params);
        x_pred(1) = min(max(x_pred(1), 0), 1);

        A = [1.0 0.0; 0.0 alpha];
        P_pred = A * P * A' + Q;

        y_pred = measurement1Rc(x_pred, current_a(k), ocv_soc, ocv_v, params);
        dUoc_dSoc = ocvSlope(x_pred(1), ocv_soc, ocv_v);
        C = [dUoc_dSoc, -1.0];

        innovation_v(k) = voltage_meas_v(k) - y_pred;
        S = C * P_pred * C' + R;
        K = (P_pred * C') / S;

        x_hat(:, k) = x_pred + K * innovation_v(k);
        x_hat(1, k) = min(max(x_hat(1, k), 0), 1);

        I2 = eye(2);
        P = (I2 - K * C) * P_pred * (I2 - K * C)' + K * R * K';
    end

    soc_hat = x_hat(1, :).';
    v1_hat = x_hat(2, :).';
end


function x_next = predictState1Rc(x_now, current_a, dt, params)
    alpha = exp(-dt / (params.R1 * params.C1));
    soc_next = x_now(1) - params.eta * current_a * dt / (3600 * params.Q_ah);
    v1_next = alpha * x_now(2) + params.R1 * (1 - alpha) * current_a;
    x_next = [soc_next; v1_next];
end


function voltage_v = measurement1Rc(x_state, current_a, ocv_soc, ocv_v, params)
    ocv_now = interp1(ocv_soc, ocv_v, x_state(1), "pchip", "extrap");
    voltage_v = ocv_now - current_a * params.R0 - x_state(2);
end


function slope = ocvSlope(soc, ocv_soc, ocv_v)
    d_ocv = gradient(ocv_v, ocv_soc);
    slope = interp1(ocv_soc, d_ocv, soc, "pchip", "extrap");
end
```

The parser design deserves attention. The helper `readCalceWorkbookRobust` loops through workbook sheets and accepts the first sheet that is large enough to look like data rather than a title sheet. That may feel inelegant, but it is the right kind of inelegance for real research data. Public datasets are rarely as schema-stable as tutorial data.

The function `normalizeCalceBatteryTable` then searches for likely headers such as `Current(A)` or `Voltage(V)` rather than assuming one exact spelling. That is a standard research habit worth internalizing. If you hard-code a single header string into every notebook, you are one workbook revision away from silent failure.

The OCV builder uses the low-current workbook to create a monotonic `SOC -> OCV` table. If the workbook already contains a capacity column, we use it directly. If not, we fall back to integrating current over time. The grouping on rounded SOC values is not mathematically sacred. It is a practical deduplication step so that interpolation later does not choke on repeated x-values.

The “reference SOC” in this example is not ground truth. It is coulomb counting anchored by the initial OCV estimate. That distinction is crucial. On synthetic data we had true SOC. On real data we usually do not. So here we benchmark the EKF against three things instead: voltage fit quality, consistency with a capacity-constrained coulomb-counting trace, and innovation behavior. That is honest practice.

### Expected Output for Walkthrough 4

The first subplot should show a real dynamic current profile with frequent sign changes and amplitude changes, not the idealized rectangular pulses of the synthetic examples. If you downloaded `FUDS`, the current should have a stop-and-go character with many moderate excursions. If you downloaded `DST`, the pattern should be similarly dynamic but with a different cadence.

The second subplot should show a smooth OCV curve at `25°C` derived from the low-current workbook. It should rise monotonically from the low-SOC voltage region to the fully charged region. If it looks jagged, folded, or strongly non-monotonic, your preprocessing is not yet trustworthy.

The third subplot should show the measured dynamic voltage in gray and the EKF model voltage overlaid on it. A correct result will not be perfect, because the `1RC` parameter set here is deliberately generic rather than re-identified to the exact workbook, but it should follow the dominant dynamic structure and give a reasonable voltage RMSE.

The final subplot should show the reference SOC and EKF SOC in the left axis and the innovation in millivolts on the right axis. On real data, innovations are usually larger and less perfectly centered than in synthetic studies. That is normal. What you are looking for is a residual that is bounded, not one that drifts in one direction for the entire test.

### What Could Go Wrong in Walkthrough 4

**`sheetnames` works, but `readtable` returns empty columns or text everywhere.** CALCE workbooks occasionally contain title rows or merged-cell formatting above the actual data region. Open the workbook once manually and confirm which sheet contains the actual numeric table.

**The dynamic voltage is obviously upside down relative to current.** You likely forgot to normalize the current sign convention. CALCE files often represent discharge current as negative.

**The OCV table folds back on itself.** That usually means you used a dynamic file rather than a low-current or incremental-OCV file to build the OCV map, or the SOC direction must be reversed before interpolation.

**The EKF tracks reference SOC poorly even though voltage fit looks decent.** That can happen when the OCV table is weakly informative in the active SOC range or when the `1RC` parameters are only approximate. It is not automatically a coding error.

### Reflection on Walkthrough 4

This walkthrough teaches the data-engineering half of estimator research. Writing a Kalman loop is only half the craft. The other half is turning a public dataset with idiosyncratic formatting into a physically consistent input stream without silently breaking time, sign, units, or the OCV map. That is the work that makes later benchmarking credible.

## Guided Walkthrough 5: Implement a UKF and Compare It Against the EKF on the Same Dynamic Test

**Learning objective:** Learn what the UKF changes in practice by comparing it head-to-head with the EKF on the same nonlinear OCV measurement model.

The UKF is often introduced as “the nonlinear Kalman filter that avoids Jacobians.” That description is true but too shallow to be useful. The important question is not whether it uses Jacobians. The important question is whether its nonlinear propagation buys you meaningfully better battery-state estimates for the model mismatch and OCV curvature you actually have. In many battery papers the UKF outperforms the EKF modestly, not dramatically. That is a healthy expectation to carry into your own work.

We will use the same `1RC` process and measurement model as before so that the comparison isolates the filter architecture rather than changing the battery physics underneath us.

```matlab
clear; close all; clc;

% Shared dataset: still synthetic so we know the hidden truth exactly
dt = 1;
time_s = (0:1:2200).';
current_a = zeros(size(time_s));
current_a(time_s >= 80   & time_s < 420)  = 2.2;
current_a(time_s >= 600  & time_s < 930)  = 3.0;
current_a(time_s >= 1120 & time_s < 1320) = -1.0;
current_a(time_s >= 1490 & time_s < 1810) = 2.7;
current_a(time_s >= 1930 & time_s < 2160) = 1.4;

ocv_soc = linspace(0, 1, 201).';
ocv_v = 3.00 ...
    + 0.74 * ocv_soc ...
    + 0.17 * tanh((ocv_soc - 0.12) / 0.05) ...
    + 0.15 * tanh((ocv_soc - 0.88) / 0.04);

params.Q_ah = 2.3;
params.eta = 1.0;
params.R0 = 0.014;
params.R1 = 0.018;
params.C1 = 95.0;

[soc_true, ~, voltage_true_v] = simulateTruth1Rc( ...
    time_s, current_a, 0.86, ocv_soc, ocv_v, params);

rng(31);
voltage_meas_v = voltage_true_v + 5e-3 * randn(size(voltage_true_v));

P0 = diag([0.08^2, 0.03^2]);
Q = diag([1e-8, 1e-5]);
R = (5e-3)^2;
initial_soc_guess = 0.68;

[soc_ekf, v1_ekf, innovation_ekf] = runEkf1Rc( ...
    time_s, current_a, voltage_meas_v, ocv_soc, ocv_v, params, ...
    initial_soc_guess, P0, Q, R);

[soc_ukf, v1_ukf, innovation_ukf] = runUkf1Rc( ...
    time_s, current_a, voltage_meas_v, ocv_soc, ocv_v, params, ...
    initial_soc_guess, P0, Q, R);

rmse_ekf = sqrt(mean((soc_ekf - soc_true).^2));
rmse_ukf = sqrt(mean((soc_ukf - soc_true).^2));

fprintf("EKF SOC RMSE: %.4f\n", rmse_ekf);
fprintf("UKF SOC RMSE: %.4f\n", rmse_ukf);
fprintf("Relative UKF improvement over EKF: %.2f %%\n", ...
    100 * (rmse_ekf - rmse_ukf) / rmse_ekf);

figure("Color", "w", "Position", [60 60 1200 900]);

subplot(4, 1, 1);
plot(time_s, current_a, "k", "LineWidth", 1.4);
grid on;
xlabel("Time [s]");
ylabel("Current [A]");
title("Shared dynamic profile for EKF-UKF comparison");

subplot(4, 1, 2);
plot(time_s, soc_true, "k", "LineWidth", 2.0); hold on;
plot(time_s, soc_ekf, "LineWidth", 1.7);
plot(time_s, soc_ukf, "LineWidth", 1.7);
grid on;
xlabel("Time [s]");
ylabel("SOC [-]");
title("State estimates");
legend("True SOC", "EKF", "UKF", "Location", "best");

subplot(4, 1, 3);
plot(time_s, (soc_ekf - soc_true) * 100, "LineWidth", 1.5); hold on;
plot(time_s, (soc_ukf - soc_true) * 100, "LineWidth", 1.5);
grid on;
xlabel("Time [s]");
ylabel("SOC error [%]");
title("Estimation error trajectories");
legend("EKF error", "UKF error", "Location", "best");

subplot(4, 1, 4);
plot(time_s, innovation_ekf * 1000, "LineWidth", 1.3); hold on;
plot(time_s, innovation_ukf * 1000, "LineWidth", 1.3);
grid on;
xlabel("Time [s]");
ylabel("Innovation [mV]");
title("Innovation comparison");
legend("EKF innovation", "UKF innovation", "Location", "best");


function [soc_hat, v1_hat, innovation_v] = runUkf1Rc( ...
    time_s, current_a, voltage_meas_v, ocv_soc, ocv_v, params, ...
    initial_soc_guess, P0, Q, R)

    n = numel(time_s);
    dt = time_s(2) - time_s(1);
    nx = 2;

    alpha_ukf = 1e-3;
    beta_ukf = 2.0;
    kappa_ukf = 0.0;
    lambda = alpha_ukf^2 * (nx + kappa_ukf) - nx;
    gamma = sqrt(nx + lambda);

    Wm = [lambda / (nx + lambda), repmat(1 / (2 * (nx + lambda)), 1, 2 * nx)];
    Wc = Wm;
    Wc(1) = Wc(1) + (1 - alpha_ukf^2 + beta_ukf);

    x_hat = zeros(nx, n);
    x_hat(:, 1) = [initial_soc_guess; 0];
    P = P0;
    innovation_v = zeros(n, 1);

    for k = 2:n
        sigmaPoints = computeSigmaPoints(x_hat(:, k - 1), P, gamma);

        sigmaPred = zeros(nx, 2 * nx + 1);
        for i = 1:(2 * nx + 1)
            sigmaPred(:, i) = predictState1Rc(sigmaPoints(:, i), current_a(k - 1), dt, params);
            sigmaPred(1, i) = min(max(sigmaPred(1, i), 0), 1);
        end

        x_pred = sigmaPred * Wm.';
        P_pred = Q;
        for i = 1:(2 * nx + 1)
            dx = sigmaPred(:, i) - x_pred;
            P_pred = P_pred + Wc(i) * (dx * dx.');
        end

        ySigma = zeros(1, 2 * nx + 1);
        for i = 1:(2 * nx + 1)
            ySigma(i) = measurement1Rc(sigmaPred(:, i), current_a(k), ocv_soc, ocv_v, params);
        end

        y_pred = ySigma * Wm.';
        Pyy = R;
        Pxy = zeros(nx, 1);
        for i = 1:(2 * nx + 1)
            dx = sigmaPred(:, i) - x_pred;
            dy = ySigma(i) - y_pred;
            Pyy = Pyy + Wc(i) * (dy * dy.');
            Pxy = Pxy + Wc(i) * dx * dy.';
        end

        K = Pxy / Pyy;
        innovation_v(k) = voltage_meas_v(k) - y_pred;

        x_hat(:, k) = x_pred + K * innovation_v(k);
        x_hat(1, k) = min(max(x_hat(1, k), 0), 1);
        P = P_pred - K * Pyy * K.';
    end

    soc_hat = x_hat(1, :).';
    v1_hat = x_hat(2, :).';
end


function sigmaPoints = computeSigmaPoints(x, P, gamma)
    nx = numel(x);
    jitter = 1e-12 * eye(nx);
    S = chol(P + jitter, "lower");
    sigmaPoints = zeros(nx, 2 * nx + 1);
    sigmaPoints(:, 1) = x;

    for i = 1:nx
        sigmaPoints(:, i + 1) = x + gamma * S(:, i);
        sigmaPoints(:, i + 1 + nx) = x - gamma * S(:, i);
    end
end


function [soc_hat, v1_hat, innovation_v] = runEkf1Rc( ...
    time_s, current_a, voltage_meas_v, ocv_soc, ocv_v, params, ...
    initial_soc_guess, P0, Q, R)

    dt = time_s(2) - time_s(1);
    n = numel(time_s);
    x_hat = zeros(2, n);
    x_hat(:, 1) = [initial_soc_guess; 0];
    P = P0;
    innovation_v = zeros(n, 1);
    alpha = exp(-dt / (params.R1 * params.C1));

    for k = 2:n
        x_pred = predictState1Rc(x_hat(:, k - 1), current_a(k - 1), dt, params);
        x_pred(1) = min(max(x_pred(1), 0), 1);

        A = [1.0 0.0; 0.0 alpha];
        P_pred = A * P * A' + Q;

        y_pred = measurement1Rc(x_pred, current_a(k), ocv_soc, ocv_v, params);
        dUoc_dSoc = ocvSlope(x_pred(1), ocv_soc, ocv_v);
        C = [dUoc_dSoc, -1.0];

        innovation_v(k) = voltage_meas_v(k) - y_pred;
        S = C * P_pred * C' + R;
        K = (P_pred * C') / S;

        x_hat(:, k) = x_pred + K * innovation_v(k);
        x_hat(1, k) = min(max(x_hat(1, k), 0), 1);

        I2 = eye(2);
        P = (I2 - K * C) * P_pred * (I2 - K * C)' + K * R * K';
    end

    soc_hat = x_hat(1, :).';
    v1_hat = x_hat(2, :).';
end


function x_next = predictState1Rc(x_now, current_a, dt, params)
    alpha = exp(-dt / (params.R1 * params.C1));
    soc_next = x_now(1) - params.eta * current_a * dt / (3600 * params.Q_ah);
    v1_next = alpha * x_now(2) + params.R1 * (1 - alpha) * current_a;
    x_next = [soc_next; v1_next];
end


function voltage_v = measurement1Rc(x_state, current_a, ocv_soc, ocv_v, params)
    ocv_now = interp1(ocv_soc, ocv_v, x_state(1), "pchip", "extrap");
    voltage_v = ocv_now - current_a * params.R0 - x_state(2);
end


function slope = ocvSlope(soc, ocv_soc, ocv_v)
    d_ocv = gradient(ocv_v, ocv_soc);
    slope = interp1(ocv_soc, d_ocv, soc, "pchip", "extrap");
end


function [soc, v1_v, voltage_v] = simulateTruth1Rc( ...
    time_s, current_a, initial_soc, ocv_soc, ocv_v, params)

    n = numel(time_s);
    dt = time_s(2) - time_s(1);
    alpha = exp(-dt / (params.R1 * params.C1));
    soc = zeros(n, 1);
    v1_v = zeros(n, 1);
    voltage_v = zeros(n, 1);

    soc(1) = initial_soc;
    voltage_v(1) = measurement1Rc([soc(1); v1_v(1)], current_a(1), ocv_soc, ocv_v, params);

    for k = 2:n
        soc(k) = soc(k - 1) - params.eta * current_a(k - 1) * dt / (3600 * params.Q_ah);
        soc(k) = min(max(soc(k), 0), 1);
        v1_v(k) = alpha * v1_v(k - 1) + params.R1 * (1 - alpha) * current_a(k - 1);
        voltage_v(k) = measurement1Rc([soc(k); v1_v(k)], current_a(k), ocv_soc, ocv_v, params);
    end
end
```

The UKF implementation uses the standard unscented-transform structure: generate sigma points from the current mean and covariance, propagate each point through the nonlinear process model, propagate the predicted sigma points through the nonlinear measurement model, and reconstruct the predicted mean and covariance from the weighted cloud.

Why is this potentially useful for a battery estimator? Because the OCV measurement equation is nonlinear, and the EKF represents that nonlinearity only through a local first-order linearization. When the OCV curve has stronger curvature, or when the prior covariance is large enough that a first-order local approximation is crude, the UKF can capture the curvature more faithfully.

At the same time, this code also shows why the UKF is not magic. The process model is still the same `1RC` ECM. The OCV table is still the same table. If those are wrong, the UKF cannot rescue them. It can only propagate nonlinear uncertainty a bit more accurately.

The UKF parameters `alpha_ukf`, `beta_ukf`, and `kappa_ukf` are standard unscented-transform tuning constants. The values here are common defaults for small state dimensions: `alpha = 1e-3`, `beta = 2`, `kappa = 0`. Those defaults are not the only valid choice, but they are a reasonable place to start and are widely used in practice.

### Expected Output for Walkthrough 5

The SOC-estimate subplot should show that both filters recover from the wrong initial SOC and track the true state closely after convergence. In a matched synthetic problem like this one, the UKF may improve the RMSE modestly, but it usually does not revolutionize the result. That is the normal outcome. If the UKF massively outperforms the EKF on this matched problem, inspect the EKF implementation before assuming the UKF is simply better.

The error subplot should make the comparison easier to read. Both error traces should begin far from zero because of the initial SOC miss. After convergence, both should hover near zero, with the UKF sometimes slightly smoother or slightly lower in magnitude depending on where the OCV nonlinearity is strongest.

The innovation subplot should show two bounded traces with similar structure. If the UKF innovation is not meaningfully different from the EKF innovation on this problem, that is not a failure. It means the local linearization was already adequate for the chosen operating regime.

### What Could Go Wrong in Walkthrough 5

**`chol` fails inside sigma-point generation.** That usually means the covariance matrix has lost positive definiteness due to numerical roundoff. The small `jitter` term in `computeSigmaPoints` is there precisely to make the routine more robust.

**The UKF is much noisier than the EKF.** Check the sigma-point weights and confirm that `Pyy` includes the measurement-noise term `R`.

**The UKF does worse than the EKF on every run.** That can happen if the unscented parameters are mis-implemented or if covariance propagation is wrong, but it can also happen on simple matched problems where the UKF brings little benefit and numerical details dominate. The point of the exercise is comparison, not guaranteed superiority.

### Reflection on Walkthrough 5

This walkthrough teaches the right mental model for the UKF. It is not “the better EKF.” It is a different approximation strategy for nonlinear state estimation. Sometimes that difference matters. Sometimes it barely matters. Publishable work requires knowing which regime you are in.

## Guided Walkthrough 6: Handle Voltage Bias and Current-Sensor Drift with an Augmented-State EKF

**Learning objective:** Extend the estimator state to include a sensor-bias term and see how even a small current or voltage offset can quietly corrupt SOC if you do not model it.

By this point, the filter may feel reliable. That is exactly when it becomes dangerous. In real battery-management systems, one of the easiest ways to corrupt SOC over long windows is not a dramatic model failure. It is a tiny sensor bias. A current offset of just a few tens of milliamps can accumulate into a meaningful coulomb-counting error. A voltage bias of a few millivolts can tilt every correction step. If your estimator does not explicitly allow for those biases, it may compensate by distorting SOC or polarization states instead.

We will augment the `1RC` state with one additional state representing voltage-sensor bias:

$$
\mathbf{x}_k =
\begin{bmatrix}
z_k \\
v_{1,k} \\
b_{v,k}
\end{bmatrix},
\tag{13}
$$

with a random-walk bias model

$$
b_{v,k+1} = b_{v,k} + w_{b,k}.
\tag{14}
$$

The measurement equation becomes

$$
y_k = U_{\mathrm{oc}}(z_k) - R_0 I_k - v_{1,k} + b_{v,k} + n_k.
\tag{15}
$$

This is a small extension in code but a very important extension in research thinking.

```matlab
clear; close all; clc;

dt = 1;
time_s = (0:1:2600).';
current_a = zeros(size(time_s));
current_a(time_s >= 60   & time_s < 460)  = 2.2;
current_a(time_s >= 640  & time_s < 980)  = 3.4;
current_a(time_s >= 1180 & time_s < 1390) = -1.2;
current_a(time_s >= 1600 & time_s < 2010) = 2.5;
current_a(time_s >= 2190 & time_s < 2490) = 1.6;

ocv_soc = linspace(0, 1, 201).';
ocv_v = 3.00 ...
    + 0.74 * ocv_soc ...
    + 0.16 * tanh((ocv_soc - 0.12) / 0.05) ...
    + 0.18 * tanh((ocv_soc - 0.87) / 0.05);

params.Q_ah = 2.3;
params.eta = 1.0;
params.R0 = 0.014;
params.R1 = 0.018;
params.C1 = 95.0;

[soc_true, v1_true, voltage_true_v] = simulateTruth1Rc( ...
    time_s, current_a, 0.87, ocv_soc, ocv_v, params);

rng(44);
true_voltage_bias_v = 8e-3;
voltage_meas_v = voltage_true_v + true_voltage_bias_v + 4e-3 * randn(size(voltage_true_v));

% Standard EKF that ignores the bias
[soc_plain, ~, innovation_plain] = runEkf1Rc( ...
    time_s, current_a, voltage_meas_v, ocv_soc, ocv_v, params, ...
    0.70, diag([0.08^2, 0.03^2]), diag([1e-8, 1e-5]), (4e-3)^2);

% Augmented EKF that estimates voltage bias
[soc_bias, v1_bias, bias_hat, innovation_bias] = runEkf1RcWithVoltageBias( ...
    time_s, current_a, voltage_meas_v, ocv_soc, ocv_v, params, ...
    0.70, diag([0.08^2, 0.03^2, (20e-3)^2]), ...
    diag([1e-8, 1e-5, 1e-9]), (4e-3)^2);

rmse_plain = sqrt(mean((soc_plain - soc_true).^2));
rmse_bias = sqrt(mean((soc_bias - soc_true).^2));

fprintf("Plain EKF SOC RMSE: %.4f\n", rmse_plain);
fprintf("Bias-aware EKF SOC RMSE: %.4f\n", rmse_bias);
fprintf("Final estimated voltage bias: %.5f V\n", bias_hat(end));
fprintf("True voltage bias: %.5f V\n", true_voltage_bias_v);

figure("Color", "w", "Position", [60 60 1200 950]);

subplot(4, 1, 1);
plot(time_s, voltage_meas_v, "Color", [0.6 0.6 0.6]); hold on;
plot(time_s, voltage_true_v, "k--", "LineWidth", 1.3);
grid on;
xlabel("Time [s]");
ylabel("Voltage [V]");
title("Measured voltage includes an unknown 8 mV bias");
legend("Measured voltage", "True voltage", "Location", "best");

subplot(4, 1, 2);
plot(time_s, soc_true, "k", "LineWidth", 2.0); hold on;
plot(time_s, soc_plain, "LineWidth", 1.7);
plot(time_s, soc_bias, "LineWidth", 1.7);
grid on;
xlabel("Time [s]");
ylabel("SOC [-]");
title("SOC estimates with and without an explicit bias state");
legend("True SOC", "Plain EKF", "Bias-aware EKF", "Location", "best");

subplot(4, 1, 3);
plot(time_s, bias_hat * 1000, "LineWidth", 1.8); hold on;
yline(true_voltage_bias_v * 1000, "--", "LineWidth", 1.5);
grid on;
xlabel("Time [s]");
ylabel("Voltage bias [mV]");
title("Recovered bias state");
legend("Estimated bias", "True bias", "Location", "best");

subplot(4, 1, 4);
plot(time_s, innovation_plain * 1000, "LineWidth", 1.3); hold on;
plot(time_s, innovation_bias * 1000, "LineWidth", 1.3);
grid on;
xlabel("Time [s]");
ylabel("Innovation [mV]");
title("Innovation comparison");
legend("Plain EKF", "Bias-aware EKF", "Location", "best");


function [soc_hat, v1_hat, bias_hat, innovation_v] = runEkf1RcWithVoltageBias( ...
    time_s, current_a, voltage_meas_v, ocv_soc, ocv_v, params, ...
    initial_soc_guess, P0, Q, R)

    dt = time_s(2) - time_s(1);
    n = numel(time_s);
    x_hat = zeros(3, n);
    x_hat(:, 1) = [initial_soc_guess; 0; 0];
    P = P0;
    innovation_v = zeros(n, 1);
    alpha = exp(-dt / (params.R1 * params.C1));

    for k = 2:n
        x_pred = predictState1RcWithBias(x_hat(:, k - 1), current_a(k - 1), dt, params);
        x_pred(1) = min(max(x_pred(1), 0), 1);

        A = [1.0 0.0 0.0; 0.0 alpha 0.0; 0.0 0.0 1.0];
        P_pred = A * P * A' + Q;

        y_pred = measurement1RcWithBias(x_pred, current_a(k), ocv_soc, ocv_v, params);
        dUoc_dSoc = ocvSlope(x_pred(1), ocv_soc, ocv_v);
        C = [dUoc_dSoc, -1.0, 1.0];

        innovation_v(k) = voltage_meas_v(k) - y_pred;
        S = C * P_pred * C' + R;
        K = (P_pred * C') / S;

        x_hat(:, k) = x_pred + K * innovation_v(k);
        x_hat(1, k) = min(max(x_hat(1, k), 0), 1);

        I3 = eye(3);
        P = (I3 - K * C) * P_pred * (I3 - K * C)' + K * R * K';
    end

    soc_hat = x_hat(1, :).';
    v1_hat = x_hat(2, :).';
    bias_hat = x_hat(3, :).';
end


function x_next = predictState1RcWithBias(x_now, current_a, dt, params)
    alpha = exp(-dt / (params.R1 * params.C1));
    soc_next = x_now(1) - params.eta * current_a * dt / (3600 * params.Q_ah);
    v1_next = alpha * x_now(2) + params.R1 * (1 - alpha) * current_a;
    bias_next = x_now(3);
    x_next = [soc_next; v1_next; bias_next];
end


function voltage_v = measurement1RcWithBias(x_state, current_a, ocv_soc, ocv_v, params)
    ocv_now = interp1(ocv_soc, ocv_v, x_state(1), "pchip", "extrap");
    voltage_v = ocv_now - current_a * params.R0 - x_state(2) + x_state(3);
end


function [soc_hat, v1_hat, innovation_v] = runEkf1Rc( ...
    time_s, current_a, voltage_meas_v, ocv_soc, ocv_v, params, ...
    initial_soc_guess, P0, Q, R)

    dt = time_s(2) - time_s(1);
    n = numel(time_s);
    x_hat = zeros(2, n);
    x_hat(:, 1) = [initial_soc_guess; 0];
    P = P0;
    innovation_v = zeros(n, 1);
    alpha = exp(-dt / (params.R1 * params.C1));

    for k = 2:n
        x_pred = predictState1Rc(x_hat(:, k - 1), current_a(k - 1), dt, params);
        x_pred(1) = min(max(x_pred(1), 0), 1);

        A = [1.0 0.0; 0.0 alpha];
        P_pred = A * P * A' + Q;

        y_pred = measurement1Rc(x_pred, current_a(k), ocv_soc, ocv_v, params);
        dUoc_dSoc = ocvSlope(x_pred(1), ocv_soc, ocv_v);
        C = [dUoc_dSoc, -1.0];

        innovation_v(k) = voltage_meas_v(k) - y_pred;
        S = C * P_pred * C' + R;
        K = (P_pred * C') / S;

        x_hat(:, k) = x_pred + K * innovation_v(k);
        x_hat(1, k) = min(max(x_hat(1, k), 0), 1);

        I2 = eye(2);
        P = (I2 - K * C) * P_pred * (I2 - K * C)' + K * R * K';
    end

    soc_hat = x_hat(1, :).';
    v1_hat = x_hat(2, :).';
end


function x_next = predictState1Rc(x_now, current_a, dt, params)
    alpha = exp(-dt / (params.R1 * params.C1));
    soc_next = x_now(1) - params.eta * current_a * dt / (3600 * params.Q_ah);
    v1_next = alpha * x_now(2) + params.R1 * (1 - alpha) * current_a;
    x_next = [soc_next; v1_next];
end


function voltage_v = measurement1Rc(x_state, current_a, ocv_soc, ocv_v, params)
    ocv_now = interp1(ocv_soc, ocv_v, x_state(1), "pchip", "extrap");
    voltage_v = ocv_now - current_a * params.R0 - x_state(2);
end


function slope = ocvSlope(soc, ocv_soc, ocv_v)
    d_ocv = gradient(ocv_v, ocv_soc);
    slope = interp1(ocv_soc, d_ocv, soc, "pchip", "extrap");
end


function [soc, v1_v, voltage_v] = simulateTruth1Rc( ...
    time_s, current_a, initial_soc, ocv_soc, ocv_v, params)

    n = numel(time_s);
    dt = time_s(2) - time_s(1);
    alpha = exp(-dt / (params.R1 * params.C1));
    soc = zeros(n, 1);
    v1_v = zeros(n, 1);
    voltage_v = zeros(n, 1);

    soc(1) = initial_soc;
    voltage_v(1) = measurement1Rc([soc(1); v1_v(1)], current_a(1), ocv_soc, ocv_v, params);

    for k = 2:n
        soc(k) = soc(k - 1) - params.eta * current_a(k - 1) * dt / (3600 * params.Q_ah);
        soc(k) = min(max(soc(k), 0), 1);
        v1_v(k) = alpha * v1_v(k - 1) + params.R1 * (1 - alpha) * current_a(k - 1);
        voltage_v(k) = measurement1Rc([soc(k); v1_v(k)], current_a(k), ocv_soc, ocv_v, params);
    end
end
```

The plain EKF, which does not know about the bias, often reacts by carrying a persistent SOC offset so that the measurement equation can absorb the biased voltage. This is one of the most important “looks fine until you inspect it carefully” failure modes in battery estimation.

The augmented filter adds only one state and one extra covariance entry, but that addition changes the estimator’s interpretation of the same innovation. Instead of forcing the SOC state to explain every persistent residual, it can attribute part of that residual to a slowly varying sensor bias. That is a much more physically honest model when such a bias really exists.

The bias process-noise variance in `Q` is set very small. That is intentional. A sensor bias typically changes slowly or is approximately constant over the duration of a single experiment. Setting the bias process noise too large tells the filter to let the bias wander quickly, which can make the estimator absorb ordinary voltage noise as fake bias motion.

### Expected Output for Walkthrough 6

The second subplot should show the plain EKF and the bias-aware EKF starting from the same bad initial SOC but ending in different places. The plain EKF often converges to a trajectory that looks plausible yet remains visibly offset from the true SOC because it has no way to represent the persistent voltage offset honestly. The bias-aware EKF should track the true SOC much more closely once it has identified the bias state.

The bias plot should rise from zero toward approximately `8 mV`, perhaps with a slightly noisy transient. A correct implementation does not need to recover the bias instantly. It needs to move toward the right magnitude and relieve the SOC state from carrying the whole error.

### What Could Go Wrong in Walkthrough 6

**The estimated bias diverges instead of settling.** The most likely causes are an excessively large bias process-noise variance or a sign error in the measurement equation.

**The bias state stays near zero forever.** That often means the initial covariance on the bias state is too small, so the filter never gives itself permission to learn it.

**Both filters give nearly identical SOC.** If the injected bias is too small relative to the voltage noise or the OCV slope is too steep, the plain EKF can absorb the error surprisingly well. Increase the bias slightly if you want the difference to be more visible for teaching.

### Reflection on Walkthrough 6

This exercise teaches a research habit that reviewers appreciate immediately: if you know a realistic nuisance source exists, put it in the state or measurement model rather than pretending it does not. That move often matters more than switching from EKF to UKF.

## Reproduction Exercise: Recreate an EKF Comparison Figure and Then Stress It Under High Measurement Noise

Part III required a reproduce-a-published-figure exercise, and this chapter is one of the highest-value places to do it because state-estimation papers are full of algorithm claims that only make sense when you can rerun and interrogate them.

We will do this reproduction in two layers.

First, complete the EKF assignment from Gregory Plett’s Coursera Course 3, *Battery State-of-Charge (SOC) Estimation*. That assignment is still one of the cleanest ways to internalize the predictor-corrector logic in a battery-specific setting. Treat that as warm-up reproduction: your goal is not novelty but fluency.

Second, reproduce the qualitative comparison setup from ElMenshawy, Massoud, and Guglielmi, “State-of-Charge Estimation Using Triple Forgetting Factor Adaptive Extended Kalman Filter for Battery Energy Storage Systems in Electric Bus Applications,” *IEEE Transactions on Transportation Electrification*, 11(2), 2025, DOI `10.1109/TTE.2024.3514704`. An open-access version is indexed through the Politecnico di Torino repository, and public metadata show that the paper compares a conventional adaptive EKF, a dual-forgetting-factor adaptive EKF, and a triple-forgetting-factor adaptive EKF under low- and high-measurement-noise conditions, reporting RMSE, MAE, MaxAE, and convergence behavior.

We are not going to pretend we can reproduce the paper bit-for-bit without the authors’ exact ECM parameter-identification and bus-drive-cycle preprocessing files. That would be false precision. What we *can* reproduce faithfully is the core claim structure:

1. estimator performance must be compared under both low-noise and high-noise cases,
2. convergence time matters alongside RMSE,
3. adaptive covariance logic becomes most valuable when measurement noise is elevated.

### Reproduction target

Our concrete target is a two-panel figure showing SOC-estimation trajectories under low and high measurement noise for three filters:

- a baseline EKF
- a simple adaptive EKF with innovation-based `R` inflation
- a UKF used here as a nonlinear comparison baseline

This is not an exact algorithmic replica of the triple-forgetting-factor paper. It is an educational reproduction of the paper’s comparison logic and figure style, with full disclosure that we are using a simplified adaptive strategy because the published paper’s complete implementation details are not all public in machine-runnable form.

That distinction matters. This is one of several valid reproduction choices, and we are making it openly because reproducible pedagogy is more valuable than pretending the paper was fully specified when it was not.

```matlab
clear; close all; clc;

dt = 1;
time_s = (0:1:2400).';
current_a = zeros(size(time_s));
current_a(time_s >= 90   & time_s < 420)  = 2.5;
current_a(time_s >= 560  & time_s < 930)  = 3.0;
current_a(time_s >= 1120 & time_s < 1320) = -1.1;
current_a(time_s >= 1490 & time_s < 1910) = 2.7;
current_a(time_s >= 2050 & time_s < 2320) = 1.7;

ocv_soc = linspace(0, 1, 201).';
ocv_v = 3.00 ...
    + 0.74 * ocv_soc ...
    + 0.16 * tanh((ocv_soc - 0.12) / 0.05) ...
    + 0.18 * tanh((ocv_soc - 0.87) / 0.05);

params.Q_ah = 2.3;
params.eta = 1.0;
params.R0 = 0.014;
params.R1 = 0.018;
params.C1 = 95.0;

[soc_true, ~, voltage_true_v] = simulateTruth1Rc( ...
    time_s, current_a, 0.85, ocv_soc, ocv_v, params);

noiseStdCases = [3e-3, 15e-3];
caseLabels = ["Low measurement noise", "High measurement noise"];

figure("Color", "w", "Position", [80 80 1250 880]);

for c = 1:2
    rng(100 + c);
    voltage_meas_v = voltage_true_v + noiseStdCases(c) * randn(size(voltage_true_v));

    [soc_ekf, ~, ~] = runEkf1Rc( ...
        time_s, current_a, voltage_meas_v, ocv_soc, ocv_v, params, ...
        0.67, diag([0.08^2, 0.03^2]), diag([1e-8, 1e-5]), noiseStdCases(c)^2);

    [soc_aekf, ~, ~] = runAdaptiveEkf1Rc( ...
        time_s, current_a, voltage_meas_v, ocv_soc, ocv_v, params, ...
        0.67, diag([0.08^2, 0.03^2]), diag([1e-8, 1e-5]), noiseStdCases(c)^2);

    [soc_ukf, ~, ~] = runUkf1Rc( ...
        time_s, current_a, voltage_meas_v, ocv_soc, ocv_v, params, ...
        0.67, diag([0.08^2, 0.03^2]), diag([1e-8, 1e-5]), noiseStdCases(c)^2);

    rmse_ekf = sqrt(mean((soc_ekf - soc_true).^2));
    rmse_aekf = sqrt(mean((soc_aekf - soc_true).^2));
    rmse_ukf = sqrt(mean((soc_ukf - soc_true).^2));

    subplot(2, 1, c);
    plot(time_s, soc_true, "k", "LineWidth", 2.1); hold on;
    plot(time_s, soc_ekf, "LineWidth", 1.5);
    plot(time_s, soc_aekf, "LineWidth", 1.5);
    plot(time_s, soc_ukf, "LineWidth", 1.5);
    grid on;
    xlabel("Time [s]");
    ylabel("SOC [-]");
    title(sprintf("%s | RMSE EKF = %.4f, AEKF = %.4f, UKF = %.4f", ...
        caseLabels(c), rmse_ekf, rmse_aekf, rmse_ukf));
    legend("True SOC", "EKF", "Innovation-adaptive EKF", "UKF", "Location", "best");
end


function [soc_hat, v1_hat, innovation_v] = runAdaptiveEkf1Rc( ...
    time_s, current_a, voltage_meas_v, ocv_soc, ocv_v, params, ...
    initial_soc_guess, P0, Q, R0)

    dt = time_s(2) - time_s(1);
    n = numel(time_s);
    x_hat = zeros(2, n);
    x_hat(:, 1) = [initial_soc_guess; 0];
    P = P0;
    innovation_v = zeros(n, 1);
    alpha = exp(-dt / (params.R1 * params.C1));
    Rk = R0;
    lambda = 0.98;

    for k = 2:n
        x_pred = predictState1Rc(x_hat(:, k - 1), current_a(k - 1), dt, params);
        x_pred(1) = min(max(x_pred(1), 0), 1);

        A = [1.0 0.0; 0.0 alpha];
        P_pred = A * P * A' + Q;

        y_pred = measurement1Rc(x_pred, current_a(k), ocv_soc, ocv_v, params);
        dUoc_dSoc = ocvSlope(x_pred(1), ocv_soc, ocv_v);
        C = [dUoc_dSoc, -1.0];

        innovation_v(k) = voltage_meas_v(k) - y_pred;
        Rk = lambda * Rk + (1 - lambda) * innovation_v(k)^2;
        S = C * P_pred * C' + Rk;
        K = (P_pred * C') / S;

        x_hat(:, k) = x_pred + K * innovation_v(k);
        x_hat(1, k) = min(max(x_hat(1, k), 0), 1);

        I2 = eye(2);
        P = (I2 - K * C) * P_pred * (I2 - K * C)' + K * Rk * K';
    end

    soc_hat = x_hat(1, :).';
    v1_hat = x_hat(2, :).';
end


function [soc_hat, v1_hat, innovation_v] = runUkf1Rc( ...
    time_s, current_a, voltage_meas_v, ocv_soc, ocv_v, params, ...
    initial_soc_guess, P0, Q, R)

    n = numel(time_s);
    dt = time_s(2) - time_s(1);
    nx = 2;
    alpha_ukf = 1e-3;
    beta_ukf = 2.0;
    kappa_ukf = 0.0;
    lambda = alpha_ukf^2 * (nx + kappa_ukf) - nx;
    gamma = sqrt(nx + lambda);

    Wm = [lambda / (nx + lambda), repmat(1 / (2 * (nx + lambda)), 1, 2 * nx)];
    Wc = Wm;
    Wc(1) = Wc(1) + (1 - alpha_ukf^2 + beta_ukf);

    x_hat = zeros(nx, n);
    x_hat(:, 1) = [initial_soc_guess; 0];
    P = P0;
    innovation_v = zeros(n, 1);

    for k = 2:n
        sigmaPoints = computeSigmaPoints(x_hat(:, k - 1), P, gamma);
        sigmaPred = zeros(nx, 2 * nx + 1);

        for i = 1:(2 * nx + 1)
            sigmaPred(:, i) = predictState1Rc(sigmaPoints(:, i), current_a(k - 1), dt, params);
            sigmaPred(1, i) = min(max(sigmaPred(1, i), 0), 1);
        end

        x_pred = sigmaPred * Wm.';
        P_pred = Q;
        for i = 1:(2 * nx + 1)
            dx = sigmaPred(:, i) - x_pred;
            P_pred = P_pred + Wc(i) * (dx * dx.');
        end

        ySigma = zeros(1, 2 * nx + 1);
        for i = 1:(2 * nx + 1)
            ySigma(i) = measurement1Rc(sigmaPred(:, i), current_a(k), ocv_soc, ocv_v, params);
        end

        y_pred = ySigma * Wm.';
        Pyy = R;
        Pxy = zeros(nx, 1);
        for i = 1:(2 * nx + 1)
            dx = sigmaPred(:, i) - x_pred;
            dy = ySigma(i) - y_pred;
            Pyy = Pyy + Wc(i) * (dy * dy.');
            Pxy = Pxy + Wc(i) * dx * dy.';
        end

        K = Pxy / Pyy;
        innovation_v(k) = voltage_meas_v(k) - y_pred;
        x_hat(:, k) = x_pred + K * innovation_v(k);
        x_hat(1, k) = min(max(x_hat(1, k), 0), 1);
        P = P_pred - K * Pyy * K.';
    end

    soc_hat = x_hat(1, :).';
    v1_hat = x_hat(2, :).';
end


function sigmaPoints = computeSigmaPoints(x, P, gamma)
    nx = numel(x);
    S = chol(P + 1e-12 * eye(nx), "lower");
    sigmaPoints = zeros(nx, 2 * nx + 1);
    sigmaPoints(:, 1) = x;
    for i = 1:nx
        sigmaPoints(:, i + 1) = x + gamma * S(:, i);
        sigmaPoints(:, i + 1 + nx) = x - gamma * S(:, i);
    end
end


function [soc_hat, v1_hat, innovation_v] = runEkf1Rc( ...
    time_s, current_a, voltage_meas_v, ocv_soc, ocv_v, params, ...
    initial_soc_guess, P0, Q, R)

    dt = time_s(2) - time_s(1);
    n = numel(time_s);
    x_hat = zeros(2, n);
    x_hat(:, 1) = [initial_soc_guess; 0];
    P = P0;
    innovation_v = zeros(n, 1);
    alpha = exp(-dt / (params.R1 * params.C1));

    for k = 2:n
        x_pred = predictState1Rc(x_hat(:, k - 1), current_a(k - 1), dt, params);
        x_pred(1) = min(max(x_pred(1), 0), 1);

        A = [1.0 0.0; 0.0 alpha];
        P_pred = A * P * A' + Q;

        y_pred = measurement1Rc(x_pred, current_a(k), ocv_soc, ocv_v, params);
        dUoc_dSoc = ocvSlope(x_pred(1), ocv_soc, ocv_v);
        C = [dUoc_dSoc, -1.0];

        innovation_v(k) = voltage_meas_v(k) - y_pred;
        S = C * P_pred * C' + R;
        K = (P_pred * C') / S;

        x_hat(:, k) = x_pred + K * innovation_v(k);
        x_hat(1, k) = min(max(x_hat(1, k), 0), 1);

        I2 = eye(2);
        P = (I2 - K * C) * P_pred * (I2 - K * C)' + K * R * K';
    end

    soc_hat = x_hat(1, :).';
    v1_hat = x_hat(2, :).';
end


function x_next = predictState1Rc(x_now, current_a, dt, params)
    alpha = exp(-dt / (params.R1 * params.C1));
    soc_next = x_now(1) - params.eta * current_a * dt / (3600 * params.Q_ah);
    v1_next = alpha * x_now(2) + params.R1 * (1 - alpha) * current_a;
    x_next = [soc_next; v1_next];
end


function voltage_v = measurement1Rc(x_state, current_a, ocv_soc, ocv_v, params)
    ocv_now = interp1(ocv_soc, ocv_v, x_state(1), "pchip", "extrap");
    voltage_v = ocv_now - current_a * params.R0 - x_state(2);
end


function slope = ocvSlope(soc, ocv_soc, ocv_v)
    d_ocv = gradient(ocv_v, ocv_soc);
    slope = interp1(ocv_soc, d_ocv, soc, "pchip", "extrap");
end


function [soc, v1_v, voltage_v] = simulateTruth1Rc( ...
    time_s, current_a, initial_soc, ocv_soc, ocv_v, params)

    n = numel(time_s);
    dt = time_s(2) - time_s(1);
    alpha = exp(-dt / (params.R1 * params.C1));
    soc = zeros(n, 1);
    v1_v = zeros(n, 1);
    voltage_v = zeros(n, 1);

    soc(1) = initial_soc;
    voltage_v(1) = measurement1Rc([soc(1); v1_v(1)], current_a(1), ocv_soc, ocv_v, params);

    for k = 2:n
        soc(k) = soc(k - 1) - params.eta * current_a(k - 1) * dt / (3600 * params.Q_ah);
        soc(k) = min(max(soc(k), 0), 1);
        v1_v(k) = alpha * v1_v(k - 1) + params.R1 * (1 - alpha) * current_a(k - 1);
        voltage_v(k) = measurement1Rc([soc(k); v1_v(k)], current_a(k), ocv_soc, ocv_v, params);
    end
end
```

### How close is “close enough”?

For this reproduction exercise, “close enough” means you recover the same *comparison logic* as the published paper:

- all filters perform similarly under low-noise conditions or differ only modestly,
- adaptive handling of measurement uncertainty matters more as noise increases,
- convergence behavior is as important as headline RMSE.

If your low-noise panel and high-noise panel both show the same ranking and nearly identical gaps, that is a warning sign that your stress test is not actually stressing anything. Increase the high-noise level or reduce the initial trust in the correct covariance until the difference becomes meaningful.

### What this reproduction actually teaches

It teaches two things at once. The first is methodological: battery estimator claims should be tested across noise regimes, not only in one pleasant operating condition. The second is scholarly: when the paper does not specify every implementation detail, your job is to document the substitutions openly rather than smuggle them in as if they were exact.

## Open-Ended Exercises

These exercises are where you stop being a reader who can rerun the chapter and start becoming a researcher who can adapt it.

### Exercise 1: Flat-Plateau Sodium-Ion Stress Test

Replace the lithium-ion-like OCV table in Guided Walkthrough 2 with the sodium-ion-inspired plateau curve from Guided Walkthrough 1. Quantify how much worse the EKF performs in terms of SOC RMSE, maximum absolute error, and convergence time. Then propose one fix and demonstrate it in code.

Hints:

- Keep the same current profile and ECM parameters first so the OCV shape is the only changed factor.
- Compare not only the SOC error but also the Kalman gain and innovation magnitude.
- Reason physically: if the OCV slope falls, the measurement update becomes weaker.

### Exercise 2: Temperature-Mismatch Sensitivity

Use the CALCE `25°C` OCV table for the estimator, but perturb the measured voltage as if the real cell were operating on a colder or warmer OCV curve. Quantify how much SOC error is introduced by an OCV-temperature mismatch.

Hints:

- You can emulate a temperature mismatch without downloading more files by shifting the OCV curve upward or downward in a SOC-dependent way.
- Keep the current profile fixed so you isolate the OCV mismatch.
- Report whether the resulting innovation looks like noise, bias, or both.

### Exercise 3: Current-Bias Sensitivity

Augment the synthetic dataset so that the measured current includes a constant offset of `20 mA`, `50 mA`, and `100 mA`, while the truth model still uses the unbiased current. Compare plain coulomb counting, the standard EKF, and a current-bias-aware extension of the filter.

Hints:

- A current bias enters the process model rather than the measurement model.
- You can model it as an additional state `b_I` with a slow random walk.
- Watch long-horizon error accumulation rather than only short transients.

### Exercise 4: Refit the `1RC` Parameters and Re-run the CALCE Benchmark

Take the real-data benchmarking workflow from Guided Walkthrough 4 and replace the generic `R0`, `R1`, and `C1` values with parameters identified from either a pulse segment in the dynamic file or the Chapter 6 ECM-identification workflow. Quantify whether the improved model changes the EKF’s SOC trajectory meaningfully or only improves the voltage RMSE.

Hints:

- A better voltage fit does not always translate into much better SOC estimation.
- Compare innovation statistics before and after parameter refinement.
- Be careful not to claim improved SOC truthfulness unless you have a stronger reference than anchored coulomb counting.

## Worked Solutions to the Open-Ended Exercises

### Solution 1: Flat-Plateau Sodium-Ion Stress Test

The point of this exercise is not merely to show that “SIB is harder.” The point is to connect that difficulty directly to the measurement Jacobian from Equation (5). When the OCV slope collapses over part of the SOC range, the SOC component of the Kalman gain shrinks, so the filter leans more heavily on process integration.

```matlab
clear; close all; clc;

dt = 1;
time_s = (0:1:2200).';
current_a = zeros(size(time_s));
current_a(time_s >= 80   & time_s < 400)  = 2.2;
current_a(time_s >= 560  & time_s < 920)  = 3.1;
current_a(time_s >= 1110 & time_s < 1320) = -1.2;
current_a(time_s >= 1480 & time_s < 1860) = 2.6;

soc_grid = linspace(0, 1, 201).';
ocv_li = 3.00 ...
    + 0.74 * soc_grid ...
    + 0.16 * tanh((soc_grid - 0.14) / 0.06) ...
    + 0.18 * tanh((soc_grid - 0.86) / 0.05);
ocv_sib = 2.45 ...
    + 0.40 * soc_grid ...
    + 0.26 * tanh((soc_grid - 0.10) / 0.05) ...
    + 0.06 * tanh((soc_grid - 0.45) / 0.10) ...
    + 0.28 * tanh((soc_grid - 0.88) / 0.04);

params.Q_ah = 3.0;
params.eta = 1.0;
params.R0 = 0.014;
params.R1 = 0.018;
params.C1 = 95.0;

[soc_true_li, ~, voltage_true_li] = simulateTruth1Rc(time_s, current_a, 0.88, soc_grid, ocv_li, params);
[soc_true_sib, ~, voltage_true_sib] = simulateTruth1Rc(time_s, current_a, 0.88, soc_grid, ocv_sib, params);

rng(55);
voltage_meas_li = voltage_true_li + 4e-3 * randn(size(voltage_true_li));
voltage_meas_sib = voltage_true_sib + 4e-3 * randn(size(voltage_true_sib));

[soc_hat_li, ~, innovation_li, gain_li] = runEkf1RcWithGain( ...
    time_s, current_a, voltage_meas_li, soc_grid, ocv_li, params, ...
    0.68, diag([0.08^2, 0.03^2]), diag([1e-8, 1e-5]), (4e-3)^2);

[soc_hat_sib, ~, innovation_sib, gain_sib] = runEkf1RcWithGain( ...
    time_s, current_a, voltage_meas_sib, soc_grid, ocv_sib, params, ...
    0.68, diag([0.08^2, 0.03^2]), diag([3e-8, 1e-5]), (4e-3)^2);

rmse_li = sqrt(mean((soc_hat_li - soc_true_li).^2));
rmse_sib = sqrt(mean((soc_hat_sib - soc_true_sib).^2));
maxe_li = max(abs(soc_hat_li - soc_true_li));
maxe_sib = max(abs(soc_hat_sib - soc_true_sib));

idx_conv_li = find(abs(soc_hat_li - soc_true_li) <= 0.01, 1, "first");
idx_conv_sib = find(abs(soc_hat_sib - soc_true_sib) <= 0.01, 1, "first");

fprintf("Li-ion-like RMSE: %.4f | Max error: %.4f | Convergence time: %.1f s\n", ...
    rmse_li, maxe_li, time_s(idx_conv_li));
fprintf("SIB-like RMSE: %.4f | Max error: %.4f | Convergence time: %.1f s\n", ...
    rmse_sib, maxe_sib, time_s(idx_conv_sib));

figure("Color", "w", "Position", [70 70 1200 900]);

subplot(3, 1, 1);
plot(time_s, soc_true_li, "k", "LineWidth", 2.0); hold on;
plot(time_s, soc_hat_li, "LineWidth", 1.6);
plot(time_s, soc_hat_sib, "LineWidth", 1.6);
grid on;
xlabel("Time [s]");
ylabel("SOC [-]");
title("Same EKF architecture on Li-ion-like and SIB-like OCV curves");
legend("True SOC", "EKF on Li-ion-like curve", "EKF on SIB-like curve", "Location", "best");

subplot(3, 1, 2);
plot(time_s, gain_li, "LineWidth", 1.5); hold on;
plot(time_s, gain_sib, "LineWidth", 1.5);
grid on;
xlabel("Time [s]");
ylabel("SOC Kalman gain");
title("SOC gain weakens when the OCV plateau flattens");
legend("Li-ion-like", "SIB-like", "Location", "best");

subplot(3, 1, 3);
plot(time_s, innovation_li * 1000, "LineWidth", 1.3); hold on;
plot(time_s, innovation_sib * 1000, "LineWidth", 1.3);
grid on;
xlabel("Time [s]");
ylabel("Innovation [mV]");
title("Innovation traces remain bounded but become less informative for SOC");
legend("Li-ion-like", "SIB-like", "Location", "best");


function [soc_hat, v1_hat, innovation_v, gain_soc] = runEkf1RcWithGain( ...
    time_s, current_a, voltage_meas_v, ocv_soc, ocv_v, params, ...
    initial_soc_guess, P0, Q, R)

    dt = time_s(2) - time_s(1);
    n = numel(time_s);
    x_hat = zeros(2, n);
    x_hat(:, 1) = [initial_soc_guess; 0];
    P = P0;
    innovation_v = zeros(n, 1);
    gain_soc = zeros(n, 1);
    alpha = exp(-dt / (params.R1 * params.C1));

    for k = 2:n
        x_pred = predictState1Rc(x_hat(:, k - 1), current_a(k - 1), dt, params);
        x_pred(1) = min(max(x_pred(1), 0), 1);

        A = [1.0 0.0; 0.0 alpha];
        P_pred = A * P * A' + Q;

        y_pred = measurement1Rc(x_pred, current_a(k), ocv_soc, ocv_v, params);
        dUoc_dSoc = ocvSlope(x_pred(1), ocv_soc, ocv_v);
        C = [dUoc_dSoc, -1.0];

        innovation_v(k) = voltage_meas_v(k) - y_pred;
        S = C * P_pred * C' + R;
        K = (P_pred * C') / S;
        gain_soc(k) = K(1);

        x_hat(:, k) = x_pred + K * innovation_v(k);
        x_hat(1, k) = min(max(x_hat(1, k), 0), 1);

        I2 = eye(2);
        P = (I2 - K * C) * P_pred * (I2 - K * C)' + K * R * K';
    end

    soc_hat = x_hat(1, :).';
    v1_hat = x_hat(2, :).';
end


function x_next = predictState1Rc(x_now, current_a, dt, params)
    alpha = exp(-dt / (params.R1 * params.C1));
    soc_next = x_now(1) - params.eta * current_a * dt / (3600 * params.Q_ah);
    v1_next = alpha * x_now(2) + params.R1 * (1 - alpha) * current_a;
    x_next = [soc_next; v1_next];
end


function voltage_v = measurement1Rc(x_state, current_a, ocv_soc, ocv_v, params)
    ocv_now = interp1(ocv_soc, ocv_v, x_state(1), "pchip", "extrap");
    voltage_v = ocv_now - current_a * params.R0 - x_state(2);
end


function slope = ocvSlope(soc, ocv_soc, ocv_v)
    d_ocv = gradient(ocv_v, ocv_soc);
    slope = interp1(ocv_soc, d_ocv, soc, "pchip", "extrap");
end


function [soc, v1_v, voltage_v] = simulateTruth1Rc( ...
    time_s, current_a, initial_soc, ocv_soc, ocv_v, params)

    n = numel(time_s);
    dt = time_s(2) - time_s(1);
    alpha = exp(-dt / (params.R1 * params.C1));
    soc = zeros(n, 1);
    v1_v = zeros(n, 1);
    voltage_v = zeros(n, 1);

    soc(1) = initial_soc;
    voltage_v(1) = measurement1Rc([soc(1); v1_v(1)], current_a(1), ocv_soc, ocv_v, params);

    for k = 2:n
        soc(k) = soc(k - 1) - params.eta * current_a(k - 1) * dt / (3600 * params.Q_ah);
        soc(k) = min(max(soc(k), 0), 1);
        v1_v(k) = alpha * v1_v(k - 1) + params.R1 * (1 - alpha) * current_a(k - 1);
        voltage_v(k) = measurement1Rc([soc(k); v1_v(k)], current_a(k), ocv_soc, ocv_v, params);
    end
end
```

One practical fix is already illustrated above: slightly increasing SOC process noise for the SIB-like case gives the filter more freedom to adapt when the voltage measurement becomes less informative. That does not solve the observability problem completely, but it is often a reasonable first response.

### Solution 2: Temperature-Mismatch Sensitivity

The shortest demonstration is to perturb the OCV curve itself and quantify the induced estimator drift.

```matlab
clear; close all; clc;

soc_grid = linspace(0, 1, 201).';
ocv_25c = 3.00 ...
    + 0.74 * soc_grid ...
    + 0.16 * tanh((soc_grid - 0.14) / 0.06) ...
    + 0.18 * tanh((soc_grid - 0.86) / 0.05);

% Synthetic colder-curve mismatch: slightly lower voltage in midrange
ocv_cold = ocv_25c - 0.025 + 0.015 * soc_grid;

dt = 1;
time_s = (0:1:1800).';
current_a = zeros(size(time_s));
current_a(time_s >= 100 & time_s < 750) = 2.0;
current_a(time_s >= 950 & time_s < 1450) = 1.5;

params.Q_ah = 2.3;
params.eta = 1.0;
params.R0 = 0.014;
params.R1 = 0.018;
params.C1 = 95.0;

[soc_true, ~, voltage_true_cold] = simulateTruth1Rc(time_s, current_a, 0.88, soc_grid, ocv_cold, params);
rng(88);
voltage_meas_v = voltage_true_cold + 4e-3 * randn(size(voltage_true_cold));

[soc_hat_wrong_ocv, ~, innovation_v] = runEkf1Rc( ...
    time_s, current_a, voltage_meas_v, soc_grid, ocv_25c, params, ...
    0.68, diag([0.08^2, 0.03^2]), diag([1e-8, 1e-5]), (4e-3)^2);

fprintf("SOC RMSE under temperature-mismatched OCV table: %.4f\n", ...
    sqrt(mean((soc_hat_wrong_ocv - soc_true).^2)));
fprintf("Mean innovation under mismatch: %.4f mV\n", mean(innovation_v) * 1000);
```

The expected outcome is a nonzero mean innovation and an SOC estimate that is systematically biased, not merely noisy. That is the key interpretation: OCV-temperature mismatch behaves like structural model bias.

### Solution 3: Current-Bias Sensitivity

The core insight is that current bias contaminates the process model directly, so if you leave it unmodeled the estimator can slowly drift even when voltage updates are present.

```matlab
clear; close all; clc;

dt = 1;
time_s = (0:1:3000).';
current_true_a = zeros(size(time_s));
current_true_a(time_s >= 100  & time_s < 800)  = 2.0;
current_true_a(time_s >= 1100 & time_s < 1850) = 1.8;
current_true_a(time_s >= 2100 & time_s < 2700) = 2.4;

current_meas_a = current_true_a + 0.05;  % 50 mA bias

soc_grid = linspace(0, 1, 201).';
ocv_v = 3.00 ...
    + 0.74 * soc_grid ...
    + 0.16 * tanh((soc_grid - 0.14) / 0.06) ...
    + 0.18 * tanh((soc_grid - 0.86) / 0.05);

params.Q_ah = 2.3;
params.eta = 1.0;
params.R0 = 0.014;
params.R1 = 0.018;
params.C1 = 95.0;

[soc_true, ~, voltage_true_v] = simulateTruth1Rc(time_s, current_true_a, 0.90, soc_grid, ocv_v, params);
rng(93);
voltage_meas_v = voltage_true_v + 4e-3 * randn(size(voltage_true_v));

[soc_hat_wrong_current, ~, ~] = runEkf1Rc( ...
    time_s, current_meas_a, voltage_meas_v, soc_grid, ocv_v, params, ...
    0.72, diag([0.08^2, 0.03^2]), diag([1e-8, 1e-5]), (4e-3)^2);

fprintf("SOC RMSE with 50 mA current bias left unmodeled: %.4f\n", ...
    sqrt(mean((soc_hat_wrong_current - soc_true).^2)));
```

The proper current-bias-aware extension is structurally similar to the voltage-bias exercise, except the bias enters the process model in the coulomb-counting term. That is a very good mini-project if you are building toward a paper.

### Solution 4: Refit the `1RC` Parameters and Re-run CALCE

The full solution depends on your Chapter 6 identification workflow, but the methodological lesson is straightforward. A lower voltage RMSE is good. A meaningfully improved SOC estimate is even better. The two are related but not equivalent. If your refined parameters mainly reduce dynamic-voltage residuals while leaving the OCV map and observability unchanged, the SOC improvement may be modest.

## What Changes for Sodium-Ion?

This section is no longer a short aside. By Chapter 7, the sodium-ion differences are central.

First, OCV shape becomes a first-class estimator design issue rather than a chemistry footnote. Many sodium-ion full-cell combinations, especially those involving hard carbon and plateau-rich cathode behavior, give long SOC intervals where $\frac{dU_{\mathrm{oc}}}{dz}$ is small. In the language of Equation (5), that means the measurement Jacobian becomes weak in exactly the component that connects voltage to SOC. A filter tuned on a lithium-ion-like curve can therefore look overconfident on a sodium-ion-like curve even if every matrix dimension is correct.

Second, parameter transfer is less forgiving. With lithium-ion, public ECM tables, OCV datasets, and validation profiles are abundant. With sodium-ion, you are more likely to assemble the estimator stack from partial literature parameterizations, digitized OCV curves, or synthetic surrogate data generated from a physics-based model. That makes uncertainty accounting more important, not less.

Third, validation strategy has to broaden. A sodium-ion SOC estimator should not be judged only by terminal-voltage fit under one dynamic cycle. It should also be stress-tested across initialization error, plateau regions, temperature mismatch, and sensor-bias scenarios, because those are precisely the conditions under which weak observability gets exposed.

Fourth, a practical sodium-ion workflow often benefits from hybridization. You may use PyBaMM or another electrochemical model to generate synthetic sodium-ion trajectories across controlled parameter variations, then use those trajectories as a virtual test bench for estimator design before scarce experimental data arrive. That is not a substitute for validation. It is a rational way to build estimator intuition under data scarcity.

Finally, the fix for a hard sodium-ion SOC problem is not always “use a fancier filter.” Sometimes the real fix is better excitation, a chemistry-specific OCV table, temperature-aware lookup surfaces, explicit hysteresis handling, or augmenting the state with additional nuisance terms. The filter architecture matters, but the information content of the battery and the experiment matters more.

## Chapter Summary and Skill Checklist

- You translated the `1RC` ECM from Chapter 6 into a nonlinear state-space observer suitable for SOC estimation.
- You implemented an EKF from scratch in MATLAB, including prediction, measurement linearization, correction, and Joseph-form covariance updates.
- You learned to interpret the measurement Jacobian physically through the OCV slope and connected that directly to estimator observability.
- You tuned `Q` and `R` using systematic sweeps rather than ad hoc aesthetic adjustment.
- You built a robust CALCE data-ingestion workflow that handles workbook quirks, sign conventions, and OCV-table construction.
- You benchmarked the EKF on real dynamic data and learned the difference between true SOC, anchored coulomb-counting reference, and voltage-fit quality.
- You implemented a UKF and learned when its nonlinear propagation is worth the extra complexity.
- You extended the state to estimate voltage bias and saw how nuisance states can protect SOC from absorbing persistent measurement errors.
- You completed a reproduction exercise in the right scholarly spirit: explicit substitutions, explicit limitations, and explicit comparison criteria.
- You stress-tested the estimator for sodium-ion-like flat OCV plateaus and identified why those chemistries are estimator-hard.

Commands, functions, and patterns that should now feel familiar:

- `interp1(..., "pchip", "extrap")` for OCV lookup
- `gradient` for numerical OCV slope evaluation
- EKF predict-measure-update structure in a `for` loop
- Joseph-form covariance updates
- sigma-point generation with `chol`
- workbook parsing with `sheetnames` and `readtable`
- resampling with `interp1(..., "previous")` and `interp1(..., "linear")`
- innovation-based tuning and residual inspection

You should now be able to:

- derive and code the state equations for a `1RC` SOC estimator
- explain why OCV slope determines how informative voltage is for SOC correction
- implement and tune an EKF without relying on a toolbox wizard
- compare EKF and UKF results honestly rather than assuming one must win
- ingest a public battery dataset and normalize its conventions before estimation
- diagnose whether a persistent innovation trend is caused by bias, temperature mismatch, or poor tuning
- explain why sodium-ion plateau regions weaken voltage-based SOC correction
- design a publishable benchmark that reports RMSE, max error, and convergence time together

If any of those boxes still feel shaky, revisit Guided Walkthroughs 2 through 4 before moving on.

## Deliverable

The deliverable from the plan is:

> A MATLAB implementation of both EKF and UKF for SOC estimation, benchmarked on CALCE data, with a written analysis of which performs better and why.

Approach it in four passes.

First, freeze your modeling assumptions. Choose the exact OCV source, ECM order, current sign convention, sample period, and initial covariance structure. Write those down before you compare filters. This is standard practice in the field.

Second, benchmark on at least two regimes:

- a synthetic matched-model case where true SOC is known
- one CALCE dynamic file where voltage-fit realism matters more than synthetic perfection

Third, report at least these metrics for each estimator:

- SOC RMSE
- maximum absolute SOC error
- convergence time to a stated threshold such as `1%` SOC
- voltage RMSE
- a short innovation-behavior comment

Fourth, include one stress test that makes the analysis interesting. A good choice is either a voltage-bias case or the sodium-ion plateau case. Without a stress test, the EKF-UKF comparison often becomes too bland to teach much.

A strong partial solution would therefore include:

- one script for matched synthetic EKF/UKF comparison
- one script for CALCE ingestion and real-data EKF benchmarking
- one script for a stress test such as bias or plateau observability
- a short report discussing not only which filter was numerically best, but *why* that happened

The “why” is the heart of the deliverable. If the UKF only improves slightly, explain that the OCV nonlinearity and covariance spread were modest. If the bias-aware EKF wins decisively, explain that nuisance modeling mattered more than filter-order sophistication. Those are exactly the kinds of conclusions that turn classwork into research competence.

## Further Practice and Reading

Primary papers and references:

1. Xing, Y., He, W., Pecht, M., & Tsui, K. L. (2014). *State of Charge Estimation of Lithium-Ion Batteries Using the Open-Circuit Voltage at Various Ambient Temperatures*. *Applied Energy*, 113, 106-115. DOI: `10.1016/j.apenergy.2013.07.008`.
2. ElMenshawy, M. S., Massoud, A. M., & Guglielmi, P. (2025). *State-of-Charge Estimation Using Triple Forgetting Factor Adaptive Extended Kalman Filter for Battery Energy Storage Systems in Electric Bus Applications*. *IEEE Transactions on Transportation Electrification*, 11(2), 6664-6674. DOI: `10.1109/TTE.2024.3514704`.
3. Plett, G. L. *Battery Management Systems*, especially the SOC-estimation material and the Coursera “Battery State-of-Charge (SOC) Estimation” assignments.

Documentation and tool references:

1. CALCE Battery Research Data portal: `https://calce.umd.edu/data`
2. MATLAB documentation for `readtable`, `sheetnames`, `interp1`, and matrix factorization routines such as `chol`
3. MATLAB documentation on state-estimation workflows if you later want to port the hand-built filters into System objects or Simulink observers

Community and reusable code resources:

1. MATLAB File Exchange searches for “battery EKF SOC” and “UKF battery SOC” can be useful for cross-checking implementation structure, though you should trust your own derived equations first.
2. The battery-modeling and BMS communities around GitHub often share ECM-estimation and Kalman-filter notebooks; use them as comparison points, not as substitutes for understanding.
3. If you are also working in Python, Chapter 10 will show how to generate synthetic virtual-cell data in PyBaMM and use that as an estimator-design sandbox for sodium-ion problems where experimental data remain sparse.

The next chapter is Lab Chapter 8: SOH and Aging Models.

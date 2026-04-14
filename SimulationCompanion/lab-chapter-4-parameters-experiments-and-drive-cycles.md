# Lab Chapter 4: Parameters, Experiments, and Drive Cycles

## Chapter Opening

Chapter 3 taught you how to run PyBaMM. This chapter teaches you how to *control* it. That sounds like a small step, but it is the difference between replaying a canned example and building a research workflow. By the end of this chapter, you will know how to inspect and modify parameter sets without losing provenance, replace function-valued parameters such as OCV curves and diffusivity laws, encode multi-step experimental protocols with charge, discharge, rest, and CV holds, import a real drive-cycle current trace, and decide when an isothermal simulation is good enough and when thermal coupling is worth the cost.

This matters for publishable research because most battery-modeling papers do not fail at the level of the governing equations. They fail in the translation layer between theory and execution. A parameter value is copied from the wrong chemistry. A charge-rest-discharge protocol is described vaguely and implemented differently than stated. A drive cycle is used without documenting current sign conventions. A thermal result is reported without saying whether temperature was held fixed or solved dynamically. Reviewers notice those things because they are exactly the places where otherwise good battery papers become irreproducible.

Keep Textbook Chapter 8 open while you work. That chapter gave you the porous-electrode equations and the physical meaning of OCV, overpotential, diffusion limitation, and transport coupling. This lab operationalizes that chapter. When we swap an OCV function or slow a diffusivity law, we are not “tweaking software.” We are changing a constitutive relation inside the electrochemical model you already learned in theory. Keep Textbook Chapter 10 open as well. That chapter explained why test protocols, current excitation, and duty-cycle choice determine what a battery model can and cannot reveal. This lab turns those ideas into executable experiments.

The deeper point is that a battery model is never just “the DFN” or “the SPMe.” It is always the model *plus* a parameterization *plus* an operating protocol *plus* a solver configuration. Serious simulation work is the craft of managing all four honestly. If Chapter 3 taught you how to ask PyBaMM for a voltage curve, Chapter 4 teaches you how to justify the curve you asked for.

This chapter also matters directly for sodium-ion work. Early sodium-ion studies often reuse lithium-ion software workflows because the tooling is more mature on the lithium-ion side. That is sensible, but only if you understand which parts of the workflow are chemistry-agnostic and which are not. Parameter handling, experiment construction, drive-cycle import, and thermal-vs-isothermal judgment all transfer cleanly. OCV shape, transport functions, nominal voltage, and data availability do not. We will keep making that distinction explicit.

The chapter is structured as a gradual climb. We begin with the parameter set itself: how to inspect it, compare it, modify it, and save your changes in a way your future self can still trust. Next, we replace function-valued parameters, because this is where PyBaMM stops feeling like a library of built-ins and starts behaving like a research tool. Then we move to the `Experiment` class and build a full charge-rest-discharge workflow. After that, we bring in a public UDDS current profile and run it through a model under realistic dynamic forcing. Finally, we revisit temperature, first as a fixed input and then as a coupled state, and quantify what changes.

Part II already satisfied its formal reproduce-a-published-figure requirement in Chapter 3, but this chapter still includes a literature-backed reproduction exercise because it is too valuable to skip. We will recreate the six-step cycling structure reported by Pozzato, Allam, and Onori (2022) for an EV-style ageing protocol and document exactly where we are matching the paper, where we are approximating, and what “close enough” means.

If you work carefully through this chapter, you will finish with a genuinely reusable notebook pattern: parameter provenance at the top, protocol definition in the middle, public data ingestion on the left edge, and publication-quality interpretation at the end. That is the skeleton of a real battery paper.

## Prerequisites Check

- Required software: the `sib-research` environment from Lab Chapter 1, `Python 3.11+`, `JupyterLab 4.4+`, `Git`
- Required Python packages for this chapter: `pybamm==25.12.1`, `numpy`, `pandas`, `scipy`, `matplotlib`
- Optional but recommended package for later file formats: `openpyxl`
- Required textbook chapters: Textbook Chapter 8 is essential; Textbook Chapter 10 is strongly recommended
- Required prior lab chapters: Lab Chapter 1, Lab Chapter 2, and Lab Chapter 3
- Estimated time: 12 to 16 hours if Chapter 3 felt comfortable; 16 to 20 hours if parameter handling and protocol design are new to you

If the object model from Chapter 3 still feels shaky, revisit Sections 3.3 through 3.6 before you begin. If Python plotting from Lab Chapter 2 still feels awkward, revisit Sections 2.4 and 2.5. This chapter assumes you can already read a NumPy array, build a clean Matplotlib figure, and recognize when a result is physically implausible.

## Environment Setup

We will use the same pinned PyBaMM version as Chapter 3 so that parameter introspection, `Experiment` behavior, and drive-cycle examples all stay aligned.

### Step 1: Activate the research environment

If you are using `conda`:

```bash
conda activate sib-research
```

If you are using `venv` on Linux or macOS:

```bash
source .venv/bin/activate
```

If you are using `venv` on Windows PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

### Step 2: Install the chapter dependencies

If you already completed Chapter 3 successfully, you may already have everything you need. If not, install the pinned stack explicitly:

```bash
python -m pip install pybamm==25.12.1 numpy pandas scipy matplotlib openpyxl
```

If your shell does not expose `python`, use:

```bash
python3 -m pip install pybamm==25.12.1 numpy pandas scipy matplotlib openpyxl
```

The `openpyxl` package is not needed for the core guided walkthroughs in this chapter, but it becomes useful the moment you start pulling `.xlsx` battery files from public repositories. Installing it now saves you a needless interruption later.

### Step 3: Verify the install with a minimal “hello protocol”

Run this snippet in a terminal-backed Python session or a fresh notebook cell:

```python
import pybamm

params = pybamm.ParameterValues("Chen2020")

print("PyBaMM version:", pybamm.__version__)
print("Nominal capacity [A.h]:", params["Nominal cell capacity [A.h]"])
print("Thermal parameter count:", len(params.list_by_category("thermal")))
print("Drive-cycle helper available:", hasattr(pybamm, "DataLoader"))
```

Expected output on the pinned version is:

```text
PyBaMM version: 25.12.1
Nominal capacity [A.h]: 5.0
Thermal parameter count: 13
Drive-cycle helper available: True
```

The exact order of the printed lines may differ if you add extra checks, but the version, nominal capacity, and thermal-parameter count should match.

### Step 4: Confirm Jupyter is using the correct interpreter

Launch JupyterLab:

```bash
jupyter lab
```

Then run:

```python
import sys
import pybamm

print(sys.executable)
print(pybamm.__version__)
```

The interpreter path should point into your intended environment, and the version should again print `25.12.1`.

### Common install failures and their fixes

1. `AttributeError: 'ParameterValues' object has no attribute 'get_info'`  
   Symptom: code from this chapter works in the book but not in your notebook.  
   Fix: you are almost certainly on an older PyBaMM version. Reinstall with the exact pin `pybamm==25.12.1`.

2. `ModuleNotFoundError: No module named 'pybamm'` in Jupyter but not in the terminal  
   Symptom: the import works in one place and fails in another.  
   Fix: your notebook kernel is bound to the wrong environment. Re-register the active environment kernel and switch notebooks to it.

3. A drive-cycle file download fails when calling `pybamm.DataLoader()`  
   Symptom: PyBaMM imports correctly, but the first call to `get_data("UDDS.csv")` errors.  
   Fix: this is usually a transient network or firewall issue. Retry once. If it persists, open the PyBaMM data release URL in a browser and download the file manually to a local folder, then point `pandas.read_csv` at that path.

4. Solver warnings appear on your first drive-cycle solve  
   Symptom: PyBaMM complains about evaluating outside the drive-cycle time range or about step-size rejection.  
   Fix: read the warning before panicking. On dynamic current profiles, some rejected trial steps are normal. If the solve completes and the result looks physical, the warning is often benign.

## Conceptual Bridge: What the Tool Thinks a “Parameter” and an “Experiment” Are

In Textbook Chapter 8, a porous-electrode model looked like a set of governing equations plus constitutive laws. In practice, that means a battery simulation is assembled from at least three logically distinct pieces:

1. the conservation laws and algebraic constraints,
2. the parameter functions and constants that close those equations,
3. the operating condition imposed on the cell.

PyBaMM mirrors that separation very deliberately, and if you internalize that separation now, later chapters become much easier.

The model itself is the equation structure. In Chapter 3, we instantiated `DFN`, `SPMe`, and `SPM` objects. Those objects determine what states exist, what PDEs or ODEs are solved, and which constitutive relations the model expects. The parameter set is not the same thing. A `ParameterValues` object supplies numerical values and callable functions for names such as `Negative electrode OCP [V]`, `Positive particle diffusivity [m2.s-1]`, and `Current function [A]`. The experiment is not the same thing either. An experiment is a time program for the external boundary condition: discharge here, rest there, hold at this voltage until that current, then apply an oscillatory current trace from data.

That separation maps very naturally onto the terminal-voltage decomposition you learned in theory. Under load, the measured voltage is not just an OCV lookup. It is the result of equilibrium potentials, kinetic losses, transport losses, and ohmic losses combining under a particular applied current history:

$$
V(t) = U_p\!\left(\theta_p(t)\right) - U_n\!\left(\theta_n(t)\right)
- \eta_{\mathrm{rxn}}(t) - \eta_{\mathrm{ohm}}(t) - \eta_{\mathrm{conc}}(t).
\tag{1}
$$

Equation (1) is why this chapter has the shape it does. If you change an OCV function, you are changing the equilibrium term. If you slow a diffusivity function, you are changing the transport-limited response and therefore the concentration overpotential. If you move from a mild CC discharge to a stop-start drive cycle, you are not changing the chemistry at all; you are changing the forcing that excites those terms. If you change from isothermal to lumped thermal coupling, you are allowing temperature to move from “fixed parameter” to “solved state,” which then feeds back into kinetics, conductivity, diffusivity, and entropic heating.

This is also why a battery-model result must always be reported with more than just the model name. “We used a DFN model” is not enough. A DFN with one OCV curve, one diffusivity law, one current profile, and fixed temperature is a different scientific object from a DFN with a different OCV curve, a pulse protocol, and thermal coupling. The governing equations are the same; the simulation is not.

PyBaMM encodes that distinction in software form. `ParameterValues` is dictionary-like because many parameters are indeed simple constants, but it is more than a dictionary because some parameters are functions and because the class knows how to process those functions into the model. Newer PyBaMM releases also expose parameter introspection methods such as `get_info`, `list_by_category`, and `diff`. Those are not niceties. They are reproducibility tools. They let you answer questions like:

- What exactly did I modify?
- Which parameters in this set belong to the thermal domain?
- How does one published parameter set differ from another?

The `Experiment` class does something equally important on the operating-condition side. It turns a prose protocol into an executable boundary program. The string

```python
"Charge at 1 C until 4.2 V"
```

is not just a friendly label. It compiles into a specific current-controlled step with a voltage termination event. Likewise,

```python
pybamm.step.current(drive_cycle_array)
```

means: at each time in the provided array, impose this current value and interpolate between the data points. That is why drive-cycle data must start at `t = 0`, have consistent time units, and use a current sign convention you can explain.

Temperature is the last conceptual bridge worth pausing on. In an isothermal run, temperature is treated as an imposed quantity, effectively a parameter. In a lumped thermal run, temperature becomes a state governed by an energy balance:

$$
\rho_{\mathrm{eff}} \frac{dT}{dt}
=
\bar{Q}
-
\frac{hA}{V}\left(T - T_{\infty}\right).
\tag{2}
$$

Here, $\bar{Q}$ is the average heat-generation rate, $h$ is the total heat-transfer coefficient, $A$ is the cooling area, and $V$ is the cell volume. The important modeling lesson is not the algebra itself, but the change in role: temperature moves from a fixed input to a coupled state variable. Once that happens, every temperature-dependent parameter becomes dynamically active.

So the mental model for the rest of the chapter is this. The textbook gave you equations and physical meaning. PyBaMM gives you a disciplined way to encode constants, functions, and forcing histories separately. Good simulation practice is learning when to change each of those layers, how to document the change, and how to interpret the consequences without confusing one layer for another.

## Guided Walkthrough 1: Inspect, Compare, Modify, and Save a Parameter Set

**Learning objective:** Treat a PyBaMM parameter set as a research object rather than a hidden bundle of defaults.

Before we modify anything, we need to build the habit of *looking* at a parameter set carefully. The most common beginner mistake in physics-based battery modeling is to treat a named parameter set as if it were a chemistry truth. It is not. It is a concrete, inspectable, editable package of assumptions. In this walkthrough, we will inspect metadata, compare two bundled sets, make a controlled set of overrides, and save those overrides so the chapter’s later simulations remain traceable.

### Walkthrough 1 code

```python
import json
from pathlib import Path

import pybamm


# Load two built-in parameter sets so we can inspect and compare them.
chen_params = pybamm.ParameterValues("Chen2020")
marquis_params = pybamm.ParameterValues("Marquis2019")

# Ask PyBaMM for metadata about one specific parameter.
capacity_info = chen_params.get_info("Nominal cell capacity [A.h]")

# Pull a thematic subset to understand the structure of the parameter set.
thermal_parameters = chen_params.list_by_category("thermal")

# Compare two published parameter sets.
parameter_diff = chen_params.diff(marquis_params)

print("PyBaMM version:", pybamm.__version__)
print("Nominal capacity value:", capacity_info.value)
print("Nominal capacity units:", capacity_info.units)
print("Nominal capacity category:", capacity_info.category)
print("Thermal parameter count:", len(thermal_parameters))
print("First five thermal parameters:", thermal_parameters[:5])
print("Changed keys versus Marquis2019:", len(parameter_diff.changed))
print("Sample changed keys:", list(parameter_diff.changed.keys())[:5])


# Make a research copy before editing anything.
research_params = chen_params.copy()
research_overrides = {
    "Current function [A]": 7.5,
    "Ambient temperature [K]": 303.15,
    "Lower voltage cut-off [V]": 2.8,
}
research_params.update(research_overrides)


# Save both a small override file and a full snapshot for reproducibility.
output_dir = Path("artifacts/chapter_4")
output_dir.mkdir(parents=True, exist_ok=True)

override_path = output_dir / "chen2020_research_overrides.json"
snapshot_path = output_dir / "chen2020_research_snapshot.json"

override_path.write_text(json.dumps(research_overrides, indent=2))
research_params.to_json(snapshot_path)


# Reload the snapshot to prove it round-trips cleanly.
reloaded_params = pybamm.ParameterValues.from_json(snapshot_path)

print("Override file saved to:", override_path.resolve())
print("Snapshot file saved to:", snapshot_path.resolve())
print("Reloaded current [A]:", reloaded_params["Current function [A]"])
print("Reloaded ambient temperature [K]:", reloaded_params["Ambient temperature [K]"])
print("Reloaded lower cut-off [V]:", reloaded_params["Lower voltage cut-off [V]"])
```

### Walkthrough 1 explanation

The first two lines load `Chen2020` and `Marquis2019` as full `ParameterValues` objects. We are not yet solving a model. This is purely parameter work, and that is an important conceptual distinction. You can and should study parameter sets before you ever launch a solver.

`chen_params.get_info("Nominal cell capacity [A.h]")` returns a metadata object rather than just the raw value. The returned object includes the numerical value, the units string, and the category. That matters because real parameter sets get large very quickly, and metadata is what keeps them navigable.

`list_by_category("thermal")` is our first act of structured browsing. In research practice, this is exactly the kind of question you ask when you switch from an isothermal notebook to a coupled thermal notebook: which parameters in this set are actually thermal?

`diff(marquis_params)` is one of the most useful habits in the whole chapter. When you say “I reran the analysis with a different parameter set,” you should be able to answer the follow-up question: different *how*? The diff object gives you a principled starting point.

The next block is about safe editing. `copy()` is not optional here. If you modify the original `chen_params` in place and later reuse it assuming it is still pristine, you have created the kind of hidden state that ruins notebooks and confuses coauthors.

Our three overrides are deliberately modest. We increase the current to `7.5 A`, increase ambient temperature to `303.15 K`, and raise the lower voltage cutoff to `2.8 V`. None of these changes alters the structure of the electrochemical model; they alter the operating assumptions attached to it.

The saving pattern deserves attention. We write a small human-readable overrides file ourselves using `json.dumps`, and we also ask PyBaMM to serialize the full parameter set with `to_json`. Both are useful. The override file is what a human wants to review in Git. The full snapshot is what makes a future rerun exact.

Finally, we reload the saved snapshot with `from_json` and print a few key fields. That last step is not ceremony. It is a verification that the saved artifact is genuinely usable rather than just decorative.

### Walkthrough 1 expected output

You should see `PyBaMM version: 25.12.1`, a nominal capacity of `5.0 A.h`, and a thermal parameter count of `13`. The exact set of changed keys reported by `diff()` will be longer than what prints on screen, because we intentionally print only the first handful.

You should also see two file paths printed inside `artifacts/chapter_4`. The reloaded current, ambient temperature, and lower-cutoff voltage should match the override values you wrote. If they do not, stop here and fix the save-reload path before moving on. Hidden parameter drift is a real research problem.

### Walkthrough 2 troubleshooting

1. You edit `chen_params` directly and later forget you changed it.  
   Symptom: later notebooks behave strangely even though the code “looks unchanged.”  
   Fix: always `copy()` before mutating a published parameter set.

2. `get_info` or `diff` is missing.  
   Symptom: an `AttributeError` appears on one of the introspection calls.  
   Fix: your PyBaMM version is too old. Reinstall the pinned version for this manual.

3. The snapshot JSON saves, but reload values do not match your edits.  
   Symptom: the printed values are different after `from_json`.  
   Fix: inspect whether you accidentally wrote the override file instead of the full snapshot file path, or overwrote the wrong file from an older run.

### Reflection

This exercise teaches a quiet but essential research skill: parameters are not decorations around a model. They are first-class artifacts. If you can inspect them, compare them, and save them cleanly, you are already working at a more publishable level than many battery notebooks ever reach.

## Guided Walkthrough 2: Replace an OCV Curve and a Diffusivity Function

**Learning objective:** Replace function-valued parameters safely and understand what parts of the simulated behavior each change should influence.

Textbook Chapter 8 treated OCV functions and transport coefficients as constitutive ingredients in the model. In PyBaMM, those ingredients are exposed directly enough that you can swap them. That is powerful, but it is also where many readers first collide with symbolic programming. The subtle point is that your custom function must be compatible with PyBaMM’s expression tree. If you write a function that only works on ordinary NumPy arrays, it may fail once PyBaMM passes it a symbolic variable. We will handle that carefully.

### Walkthrough 2 code

```python
import numpy as np
import matplotlib.pyplot as plt
import pybamm


model = pybamm.lithium_ion.DFN()

# Start from a clean baseline and make the current slightly higher so transport effects show up.
baseline_params = pybamm.ParameterValues("Chen2020")
baseline_params.update({"Current function [A]": 7.5})

modified_params = baseline_params.copy()


# Grab the original functions so we can wrap rather than replace blindly.
base_negative_ocp = baseline_params["Negative electrode OCP [V]"]
base_positive_diffusivity = baseline_params["Positive particle diffusivity [m2.s-1]"]


# Build a table-based OCV perturbation. This mimics what you would do with measured OCV data.
sto_grid = np.linspace(0.01, 0.99, 200)
shifted_negative_ocp_values = base_negative_ocp(sto_grid) - 0.02 * (1.0 - sto_grid)


def chapter4_negative_ocp(sto):
    return pybamm.Interpolant(
        sto_grid,
        shifted_negative_ocp_values,
        sto,
        name="chapter4_negative_ocp_table",
    )


# Make the positive-particle diffusivity uniformly slower.
def slower_positive_diffusivity(sto, temperature):
    return 0.6 * base_positive_diffusivity(sto, temperature)


modified_params.update(
    {
        "Negative electrode OCP [V]": chapter4_negative_ocp,
        "Positive particle diffusivity [m2.s-1]": slower_positive_diffusivity,
    }
)


t_eval = np.linspace(0, 2400, 241)
solutions = {}

for label, params in {
    "Baseline": baseline_params,
    "Modified functions": modified_params,
}.items():
    simulation = pybamm.Simulation(model, parameter_values=params)
    solutions[label] = simulation.solve(t_eval)


time_min = t_eval / 60.0
baseline_voltage_v = solutions["Baseline"]["Terminal voltage [V]"](t_eval)
modified_voltage_v = solutions["Modified functions"]["Terminal voltage [V]"](t_eval)

baseline_conc_overpotential_v = solutions["Baseline"][
    "X-averaged battery concentration overpotential [V]"
](t_eval)
modified_conc_overpotential_v = solutions["Modified functions"][
    "X-averaged battery concentration overpotential [V]"
](t_eval)

print(
    "Voltage shift at t = 0 [mV]:",
    round(float((modified_voltage_v[0] - baseline_voltage_v[0]) * 1000), 2),
)
print(
    "Voltage shift at t = 2400 s [mV]:",
    round(float((modified_voltage_v[-1] - baseline_voltage_v[-1]) * 1000), 2),
)
print(
    "Max added concentration overpotential [mV]:",
    round(
        float(
            np.max(
                np.abs(
                    modified_conc_overpotential_v - baseline_conc_overpotential_v
                )
            )
            * 1000
        ),
        2,
    ),
)


fig, axes = plt.subplots(2, 1, figsize=(9, 8), sharex=True, constrained_layout=True)

axes[0].plot(time_min, baseline_voltage_v, linewidth=2.2, label="Baseline")
axes[0].plot(time_min, modified_voltage_v, linewidth=2.2, label="Modified functions")
axes[0].set_ylabel("Terminal Voltage [V]")
axes[0].set_title("Replacing an OCV curve and a diffusivity law")
axes[0].legend()
axes[0].grid(True, alpha=0.3)

axes[1].plot(
    time_min,
    baseline_conc_overpotential_v * 1000,
    linewidth=2.2,
    label="Baseline",
)
axes[1].plot(
    time_min,
    modified_conc_overpotential_v * 1000,
    linewidth=2.2,
    label="Modified functions",
)
axes[1].set_xlabel("Time [min]")
axes[1].set_ylabel("Concentration Overpotential [mV]")
axes[1].legend()
axes[1].grid(True, alpha=0.3)

plt.show()
```

### Walkthrough 2 explanation

We begin with a `DFN` model and a clean `Chen2020` parameter set. We then raise the current to `7.5 A` so that concentration effects become large enough to read clearly over a modest simulation window. This is standard teaching practice: amplify the mechanism you want to observe, but say out loud that you are doing it.

The next two lines pull the original negative-electrode OCP function and positive-particle diffusivity function out of the parameter set. This is a much safer way to customize behavior than replacing functions from scratch without a reference.

The OCV replacement is intentionally table-based. We evaluate the original OCP on a stoichiometry grid and then subtract a small stoichiometry-dependent offset. That creates a synthetic measured-like table. The custom function `chapter4_negative_ocp(sto)` returns a `pybamm.Interpolant`, not a NumPy interpolation. That distinction is critical. `pybamm.Interpolant` can live inside the symbolic model; `np.interp` cannot.

The diffusivity modification is simpler. We define `slower_positive_diffusivity(sto, temperature)` with the same input signature as the original function and scale the baseline value by `0.6`. This is a good example of a change that mostly affects dynamic transport behavior rather than the equilibrium voltage baseline.

After updating the modified parameter set, we solve the baseline and modified models on the same time grid. Using the same `t_eval` is essential because it makes the resulting differences pointwise comparable.

We then extract two variables. `Terminal voltage [V]` tells us what a user or cycler would observe directly. `X-averaged battery concentration overpotential [V]` is the internal mechanism we expect the diffusivity change to affect most strongly. This pairing is deliberate: an external signal plus an internal explanation.

### Walkthrough 2 expected output and interpretation

You should see the modified-voltage curve sit slightly below the baseline from the very beginning, because we shifted the negative-electrode OCP downward. As the discharge progresses, the gap should widen somewhat, and the concentration-overpotential curve for the modified case should rise more aggressively than the baseline because we intentionally slowed the positive-particle diffusivity.

The printed values will be in the tens of millivolts, not volts. That scale is important. We are not building a cartoonishly different battery; we are making realistic-looking constitutive perturbations and watching how they propagate.

If both voltage curves are essentially identical and the concentration-overpotential curves sit on top of one another, something is wrong with your function replacement.

### Walkthrough 3 troubleshooting

1. You use `np.interp` or other pure-NumPy logic in the custom OCV function.  
   Symptom: PyBaMM fails once the function is processed into the model.  
   Fix: use `pybamm.Interpolant` for tabulated functions that must accept symbolic inputs.

2. Your custom function signature does not match the expected inputs.  
   Symptom: the solver fails during parameter processing with a function-argument error.  
   Fix: use `model.print_parameter_info()` if needed to check which inputs a given function parameter expects.

3. You mutate the baseline parameter set and then “compare” it to itself.  
   Symptom: baseline and modified curves match suspiciously well.  
   Fix: make the modified set from `baseline_params.copy()` before updating.

### Walkthrough 2 reflection

This exercise teaches one of the most transferable skills in the companion: how to replace the physics-bearing pieces of a PyBaMM model without losing symbolic compatibility. That is exactly the workflow you will need later for sodium-ion OCV curves, fitted transport laws, and literature-derived constitutive updates.

## Guided Walkthrough 3: Encode a Full Charge-Rest-Discharge Protocol with `Experiment`

**Learning objective:** Build a multi-step protocol that includes CC, CV, and rest periods, then interpret the resulting current and voltage trajectory correctly.

Battery papers rarely use one clean constant-current segment and stop. Real workflows include transitions, cutoffs, and recovery periods. That is why PyBaMM’s `Experiment` class matters. In this walkthrough, we will encode a full protocol that begins with discharge, pauses for relaxation, recharges with a CC-CV sequence, and rests again. The objective is not just to run it, but to read the sign conventions and step transitions like an experimentalist.

### Walkthrough 3 code

```python
import numpy as np
import matplotlib.pyplot as plt
import pybamm


parameter_values = pybamm.ParameterValues("Chen2020")

experiment = pybamm.Experiment(
    [
        "Discharge at C/3 until 3.0 V",
        "Rest for 30 minutes",
        "Charge at 1 C until 4.2 V",
        "Hold at 4.2 V until C/20",
        "Rest for 30 minutes",
    ],
    period="10 seconds",
)

simulation = pybamm.Simulation(
    pybamm.lithium_ion.DFN(),
    parameter_values=parameter_values,
    experiment=experiment,
    solver=pybamm.CasadiSolver(mode="fast"),
)
solution = simulation.solve()


time_s = solution["Time [s]"].entries
time_h = time_s / 3600.0
current_a = solution["Current [A]"].entries
voltage_v = solution["Terminal voltage [V]"].entries
discharge_capacity_ah = solution["Discharge capacity [A.h]"].entries


discharge_energy_wh = np.trapezoid(
    np.clip(current_a, 0.0, None) * voltage_v,
    time_s,
) / 3600.0
charge_energy_wh = -np.trapezoid(
    np.clip(current_a, None, 0.0) * voltage_v,
    time_s,
) / 3600.0
throughput_ah = np.trapezoid(np.abs(current_a), time_s) / 3600.0

print("Total throughput [A.h]:", round(float(throughput_ah), 4))
print("Discharge energy [W.h]:", round(float(discharge_energy_wh), 4))
print("Charge energy [W.h]:", round(float(charge_energy_wh), 4))
print("Final terminal voltage [V]:", round(float(voltage_v[-1]), 4))


fig, axes = plt.subplots(3, 1, figsize=(10, 10), sharex=True, constrained_layout=True)

axes[0].plot(time_h, current_a, linewidth=2.1, color="tab:blue")
axes[0].set_ylabel("Current [A]")
axes[0].set_title("CC-rest-CCCV-rest protocol")
axes[0].grid(True, alpha=0.3)

axes[1].plot(time_h, voltage_v, linewidth=2.1, color="tab:orange")
axes[1].set_ylabel("Terminal Voltage [V]")
axes[1].grid(True, alpha=0.3)

axes[2].plot(time_h, discharge_capacity_ah, linewidth=2.1, color="tab:green")
axes[2].set_ylabel("Discharge Capacity [A.h]")
axes[2].set_xlabel("Time [h]")
axes[2].grid(True, alpha=0.3)

plt.show()
```

### Walkthrough 3 explanation

The `Experiment` constructor is the star here. Each string is one operating step. PyBaMM parses these into structured step objects with durations, directions, and termination events.

The first step, `"Discharge at C/3 until 3.0 V"`, means what it says: apply a positive discharge current equal to one-third of the nominal capacity in amperes until the lower voltage threshold is reached. The second step is a rest. In PyBaMM, that means zero current, not a magical equilibrium reset.

The third and fourth steps together form a standard CCCV charge. First we charge at a fixed current until the upper cutoff voltage `4.2 V` is reached. Then we hold voltage constant at `4.2 V` and allow the current to decay until it reaches `C/20`. This is standard practice in the field. If you publish charge simulations without being clear about whether your charge was CC-only or CCCV, you are leaving out an important part of the method.

We request a reporting `period="10 seconds"` because that is dense enough to show the CV taper smoothly without creating an unnecessarily large solution.

The energy calculations are worth reading carefully. Discharge current is positive in PyBaMM, so discharge energy is computed from the positive-current portion of the signal. Charge current is negative, so we take the negative-current portion, multiply by voltage, and apply a minus sign to report charge energy as a positive quantity. This sign bookkeeping is simple once you understand it, but it is one of the most common sources of silent mistakes in battery data analysis.

### Walkthrough 3 expected output and interpretation

The current plot should have five visually distinct regions. First, a positive constant-current discharge segment. Second, a flat zero-current rest. Third, a negative constant-current charge segment. Fourth, a negative current that gradually decays in magnitude during the CV hold. Fifth, another flat zero-current rest.

The voltage plot should fall during discharge, rebound upward during the first rest, rise during charge, flatten near `4.2 V` during the CV hold, and relax slightly during the final rest. The discharge-capacity curve should rise during discharge and then remain flat during the rest and charge portions because it measures discharged capacity since the beginning of the simulation, not signed charge throughput.

If your current sign is reversed in your mental model, this whole figure will feel backwards. That is exactly why this walkthrough exists.

### Walkthrough 4 troubleshooting

1. You place the charge step first while keeping the default fully charged initial state.  
   Symptom: the first step is skipped or declared infeasible.  
   Fix: either start from discharge, as we do here, or explicitly set the initial state before charging first.

2. You confuse discharge capacity with net charge throughput.  
   Symptom: you expect the capacity curve to decrease during charge.  
   Fix: `Discharge capacity [A.h]` is cumulative discharged capacity, not signed coulomb counting.

3. The CV hold never appears.  
   Symptom: the current plot jumps straight from constant-current charge to rest.  
   Fix: the current may already have dropped below the termination threshold by the moment `4.2 V` is reached, or your version/parser may differ. Re-check the string exactly.

### Walkthrough 3 reflection

This exercise teaches you to think of an experiment as executable boundary data. That is a graduate-level modeling habit. You are no longer “running a battery model.” You are applying a specific test protocol to a virtual cell and reading the result with the same sign discipline you would need on a real cycler.

## Dataset Integration: Public UDDS Drive-Cycle Data

This chapter’s real-data section uses a public UDDS current trace distributed in PyBaMM’s data release and derived from the standard Urban Dynamometer Driving Schedule workflow. We use the packaged file because it is small, directly machine-readable, and immediately compatible with PyBaMM. If you prefer to go to the regulatory source, keep the EPA Dynamometer Drive Schedules page bookmarked as the authoritative reference for the underlying standard.

| Item | Value |
| --- | --- |
| Public current file used in code | `UDDS.csv` from the PyBaMM public data release |
| Programmatic access | `pybamm.DataLoader().get_data("UDDS.csv")` |
| Direct release pattern | `https://github.com/pybamm-team/pybamm-data/releases/download/v1.0.x/UDDS.csv` |
| Underlying standard | EPA Urban Dynamometer Driving Schedule (UDDS) |
| EPA reference page | `https://www.epa.gov/vehicle-and-fuel-emissions-testing/dynamometer-drive-schedules` |
| Reported EPA file size for the raw schedule page entry | `12.32 KB` for the tab-delimited UDDS text file |
| Format used in the PyBaMM convenience file | two columns: time in seconds, current in amperes |
| License and reuse note | cite the source you actually use; the EPA page does not expose a separate dataset license on the download listing, while the PyBaMM release is publicly distributed for model examples |

For research notebooks, the packaged `UDDS.csv` is the right level of convenience. For a paper, cite the underlying standard trace or the data package you actually downloaded. Do not pretend a convenience wrapper is the primary source if it is not.

The parsing workflow in the next walkthrough will make four checks that should become muscle memory:

1. strip comment lines and null rows,
2. ensure the time column is monotonically increasing,
3. confirm the time axis starts at zero,
4. state the current sign convention explicitly.

Those checks feel boring right up until the day one of them saves your figure.

## Guided Walkthrough 4: Load a Real UDDS Current Profile and Run It in PyBaMM

**Learning objective:** Parse a public drive-cycle file cleanly, validate its columns and sign convention, and run it through a physics-based model.

This is the point where the chapter becomes recognizably research-like. We are no longer using a hand-written one-line current function. We are taking a public current trace, validating it, and using it as a dynamic input. For this walkthrough we use `SPMe` rather than `DFN`. That is a standard practice in the field when you want electrolyte dynamics but also want fast iteration under long or jagged duty cycles.

### Walkthrough 4 code

```python
from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import pybamm


def load_drive_cycle(filename):
    data_loader = pybamm.DataLoader()
    file_path = Path(data_loader.get_data(filename))

    drive_cycle = pd.read_csv(
        file_path,
        comment="#",
        header=None,
        names=["time_s", "current_a"],
    )

    drive_cycle = (
        drive_cycle.dropna()
        .drop_duplicates(subset="time_s", keep="first")
        .sort_values("time_s")
        .reset_index(drop=True)
    )

    # Normalize the time axis in case a downloaded file starts at a nonzero timestamp.
    drive_cycle["time_s"] = drive_cycle["time_s"] - drive_cycle["time_s"].iloc[0]

    return file_path, drive_cycle


udds_path, udds = load_drive_cycle("UDDS.csv")

udds["delta_t_s"] = udds["time_s"].diff().fillna(0.0)
udds["signed_capacity_increment_ah"] = (
    udds["current_a"] * udds["delta_t_s"] / 3600.0
)
udds["cumulative_signed_capacity_ah"] = udds["signed_capacity_increment_ah"].cumsum()

print("Loaded file:", udds_path)
print("Row count:", len(udds))
print("Duration [s]:", round(float(udds["time_s"].iloc[-1]), 1))
print("Minimum current [A]:", round(float(udds["current_a"].min()), 4))
print("Maximum current [A]:", round(float(udds["current_a"].max()), 4))
print("Time starts at zero:", bool(np.isclose(udds["time_s"].iloc[0], 0.0)))


fig, axes = plt.subplots(2, 1, figsize=(10, 7), sharex=True, constrained_layout=True)

axes[0].plot(udds["time_s"] / 60.0, udds["current_a"], linewidth=1.7, color="tab:blue")
axes[0].set_ylabel("Current [A]")
axes[0].set_title("Public UDDS current profile")
axes[0].grid(True, alpha=0.3)

axes[1].plot(
    udds["time_s"] / 60.0,
    udds["cumulative_signed_capacity_ah"],
    linewidth=1.7,
    color="tab:purple",
)
axes[1].set_xlabel("Time [min]")
axes[1].set_ylabel("Cumulative Signed Capacity [A.h]")
axes[1].grid(True, alpha=0.3)

plt.show()


drive_cycle_array = udds[["time_s", "current_a"]].to_numpy()

experiment = pybamm.Experiment(
    [pybamm.step.current(drive_cycle_array)],
    period="1 second",
)

parameter_values = pybamm.ParameterValues("Chen2020")
simulation = pybamm.Simulation(
    pybamm.lithium_ion.SPMe(),
    parameter_values=parameter_values,
    experiment=experiment,
    solver=pybamm.CasadiSolver(mode="fast"),
)
solution = simulation.solve()


time_s = solution["Time [s]"].entries
time_min = time_s / 60.0
current_a = solution["Current [A]"].entries
voltage_v = solution["Terminal voltage [V]"].entries
discharge_capacity_ah = solution["Discharge capacity [A.h]"].entries
approx_soc = 1.0 - discharge_capacity_ah / parameter_values["Nominal cell capacity [A.h]"]
electrolyte_concentration = solution["X-averaged electrolyte concentration [mol.m-3]"].entries

print("Final terminal voltage [V]:", round(float(voltage_v[-1]), 4))
print("Final approximate SOC [-]:", round(float(approx_soc[-1]), 4))
print(
    "Electrolyte concentration range [mol.m-3]:",
    round(float(electrolyte_concentration.min()), 2),
    "to",
    round(float(electrolyte_concentration.max()), 2),
)


fig, axes = plt.subplots(4, 1, figsize=(10, 12), sharex=True, constrained_layout=True)

axes[0].plot(time_min, current_a, linewidth=1.7, color="tab:blue")
axes[0].set_ylabel("Current [A]")
axes[0].set_title("UDDS-driven SPMe simulation")
axes[0].grid(True, alpha=0.3)

axes[1].plot(time_min, voltage_v, linewidth=1.9, color="tab:orange")
axes[1].set_ylabel("Voltage [V]")
axes[1].grid(True, alpha=0.3)

axes[2].plot(time_min, approx_soc, linewidth=1.9, color="tab:red")
axes[2].set_ylabel("Approx. SOC [-]")
axes[2].grid(True, alpha=0.3)

axes[3].plot(
    time_min,
    electrolyte_concentration,
    linewidth=1.9,
    color="tab:green",
)
axes[3].set_ylabel("X-avg Electrolyte c [mol.m$^{-3}$]")
axes[3].set_xlabel("Time [min]")
axes[3].grid(True, alpha=0.3)

plt.show()
```

### Walkthrough 4 explanation

We begin with a reusable helper, `load_drive_cycle(filename)`. This does more than read a CSV. It performs light but meaningful data hygiene: remove nulls, remove repeated timestamps, sort by time, and normalize the time axis so the trace begins at zero. Those four operations are so common in battery-data work that they are worth wrapping early.

The cumulative signed-capacity calculation is not something PyBaMM needs in order to solve the model. It is something *you* need in order to inspect the dataset. A current profile can look plausible while still having an unexpected net bias or sign mistake. Integrating it once is a quick way to see whether the trace is mostly discharge, mostly charge, or approximately energy-neutral.

The `drive_cycle_array` passed into `pybamm.step.current` must be a two-column NumPy array. The first column is time in seconds. The second is current in amperes. PyBaMM treats positive current as discharge and negative current as charge or regenerative current. State that explicitly whenever you work with a dynamic trace, because public datasets do not all use the same sign convention.

We then build a one-step experiment containing the whole drive cycle. The `period="1 second"` argument tells PyBaMM how densely to record the outputs. Since UDDS is conventionally used at a one-second cadence, this is the natural choice.

We use `SPMe` instead of `DFN` for a reason. This is standard practice when you want realistic electrolyte dynamics and internal concentration behavior but also want a model that remains pleasant to rerun many times in a notebook. Later, if a reviewer-level result depends critically on this case, you can rerun the final comparison with the `DFN`.

Finally, we plot four panels: current, voltage, approximate SOC, and x-averaged electrolyte concentration. That panel selection is intentional. It ties together the external input, external response, state depletion, and one internal transport variable.

### Walkthrough 4 expected output and interpretation

The first figure should show a jagged current trace with frequent changes and many sections near zero. That is exactly what you expect from an urban stop-and-go profile. The cumulative signed-capacity curve should drift rather than remain perfectly flat, indicating a net discharge bias over the cycle.

The simulation figure should show the terminal voltage sagging during higher discharge-current sections and recovering during low-current or regenerative sections. The approximate SOC should decline gradually rather than linearly, because the current is not constant. The x-averaged electrolyte concentration should vary more subtly than voltage, but it should still respond coherently to the current bursts.

If the current looks upside down relative to the voltage response, the first thing to check is sign convention, not solver correctness.

### Walkthrough 5 troubleshooting

1. The first timestamp is not zero.  
   Symptom: PyBaMM raises an error or the drive cycle starts strangely.  
   Fix: normalize the time axis exactly as we do in the helper function.

2. Your current sign convention is reversed relative to PyBaMM.  
   Symptom: voltage rises when you think the battery is discharging.  
   Fix: inspect the input current, not just the output voltage. Positive current should mean discharge in this chapter’s code.

3. `DataLoader` cannot download the file on a restricted network.  
   Symptom: the code fails before `pandas.read_csv` ever runs.  
   Fix: manually download the CSV once and point `read_csv` at the local path.

4. The solver prints a warning about evaluating outside the data range.  
   Symptom: a warning appears before the solve completes.  
   Fix: on dynamic traces, some rejected trial steps are normal. If the final result is smooth and the solve completes, this warning is usually harmless.

### Walkthrough 4 reflection

This exercise teaches the real workflow boundary between public data and simulation. A drive cycle is not magic. It is just a time series. But once you learn how to validate, parse, and impose it cleanly, your battery model stops living in a toy world of constant-current segments.

## Guided Walkthrough 5: Temperature as an Input Versus Temperature as a Coupled State

**Learning objective:** Compare an isothermal drive-cycle simulation to a lumped-thermal simulation and quantify what thermal coupling changes.

Chapter 4 is the right place to learn this distinction because temperature often sneaks into modeling work without being declared clearly. In an isothermal model, temperature is an imposed condition. In a thermally coupled model, temperature is part of the solution. We will use the same dynamic current trace in both cases so the comparison remains honest.

To make the thermal effect visible over a single short drive cycle, we will double the UDDS current amplitude. This is a teaching shortcut, not a claim about a real vehicle pack. I am flagging that explicitly because it is exactly the kind of modeling choice you should label clearly in a paper.

### Walkthrough 5 code

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import pybamm


data_loader = pybamm.DataLoader()
udds = pd.read_csv(
    data_loader.get_data("UDDS.csv"),
    comment="#",
    header=None,
    names=["time_s", "current_a"],
).dropna()

udds["time_s"] = udds["time_s"] - udds["time_s"].iloc[0]

# Teaching shortcut: amplify the current so the temperature response is visible in one cycle.
scaled_udds = udds.copy()
scaled_udds["current_a"] = 2.0 * scaled_udds["current_a"]
drive_cycle_array = scaled_udds[["time_s", "current_a"]].to_numpy()

experiment = pybamm.Experiment(
    [pybamm.step.current(drive_cycle_array)],
    period="1 second",
)

models = {
    "Isothermal SPMe": pybamm.lithium_ion.SPMe(),
    "Lumped-thermal SPMe": pybamm.lithium_ion.SPMe({"thermal": "lumped"}),
}

solutions = {}
for label, model in models.items():
    params = pybamm.ParameterValues("Chen2020")
    params.update(
        {
            "Ambient temperature [K]": 298.15,
            "Initial temperature [K]": 298.15,
            "Total heat transfer coefficient [W.m-2.K-1]": 10.0,
        }
    )

    simulation = pybamm.Simulation(
        model,
        parameter_values=params,
        experiment=experiment,
        solver=pybamm.CasadiSolver(mode="fast"),
    )
    solutions[label] = simulation.solve()


time_s = solutions["Isothermal SPMe"]["Time [s]"].entries
time_min = time_s / 60.0

isothermal_voltage_v = solutions["Isothermal SPMe"]["Terminal voltage [V]"].entries
lumped_voltage_v = solutions["Lumped-thermal SPMe"]["Terminal voltage [V]"].entries

isothermal_temperature_k = solutions["Isothermal SPMe"][
    "Volume-averaged cell temperature [K]"
].entries
lumped_temperature_k = solutions["Lumped-thermal SPMe"][
    "Volume-averaged cell temperature [K]"
].entries
lumped_total_heating = solutions["Lumped-thermal SPMe"][
    "Volume-averaged total heating [W.m-3]"
].entries
current_a = solutions["Lumped-thermal SPMe"]["Current [A]"].entries

print(
    "Isothermal max temperature rise [K]:",
    round(float(isothermal_temperature_k.max() - 298.15), 4),
)
print(
    "Lumped max temperature rise [K]:",
    round(float(lumped_temperature_k.max() - 298.15), 4),
)
print(
    "Max voltage difference [mV]:",
    round(float(np.max(np.abs(lumped_voltage_v - isothermal_voltage_v)) * 1000), 2),
)


fig, axes = plt.subplots(3, 1, figsize=(10, 10), sharex=True, constrained_layout=True)

axes[0].plot(time_min, current_a, linewidth=1.6, color="tab:blue")
axes[0].set_ylabel("Current [A]")
axes[0].set_title("Isothermal versus lumped-thermal drive-cycle simulation")
axes[0].grid(True, alpha=0.3)

axes[1].plot(time_min, isothermal_voltage_v, linewidth=2.0, label="Isothermal")
axes[1].plot(time_min, lumped_voltage_v, linewidth=2.0, label="Lumped thermal")
axes[1].set_ylabel("Voltage [V]")
axes[1].legend()
axes[1].grid(True, alpha=0.3)

axes[2].plot(
    time_min,
    isothermal_temperature_k,
    linewidth=2.0,
    label="Isothermal",
)
axes[2].plot(
    time_min,
    lumped_temperature_k,
    linewidth=2.0,
    label="Lumped thermal",
)
axes[2].plot(
    time_min,
    298.15 + 0.000001 * lumped_total_heating,
    linewidth=1.0,
    linestyle="--",
    alpha=0.6,
    label="Heating trend (scaled for shape only)",
)
axes[2].set_ylabel("Temperature [K]")
axes[2].set_xlabel("Time [min]")
axes[2].legend()
axes[2].grid(True, alpha=0.3)

plt.show()
```

### Walkthrough 5 explanation

The first part of the code reloads the UDDS profile and doubles the current amplitude. I am saying this twice because it matters pedagogically: this is a teaching move to make thermal coupling visible over one short trace. In real work, you would justify current amplitude from the cell or pack you are studying.

We then create two models with identical electrochemical structure but different thermal treatment. `pybamm.lithium_ion.SPMe()` is isothermal by default. `pybamm.lithium_ion.SPMe({"thermal": "lumped"})` adds the lumped thermal ODE from Equation (2).

The parameter updates add three thermal quantities: ambient temperature, initial temperature, and total heat-transfer coefficient. These are the minimum thermal assumptions that keep the comparison explicit.

We extract three outputs: voltage, volume-averaged temperature, and volume-averaged total heating. The heating variable is particularly useful because it reminds you that a temperature rise is not an abstract solver artifact. It is being driven by interpretable heat generation inside the model.

The final plot overlays temperature from both cases. In the isothermal case, the temperature should remain flat. In the lumped case, it should rise. That is the whole conceptual distinction, rendered as a figure.

### Walkthrough 5 expected output and interpretation

The printed maximum temperature rise for the isothermal case should be essentially zero, because the model is not allowed to heat up. The lumped case should show a positive temperature rise. The exact magnitude depends on the current amplification and heat-transfer coefficient, but it should be visibly nonzero.

In the figure, the isothermal temperature line should be flat at `298.15 K`. The lumped-thermal line should drift upward over the cycle, with the heating trend roughly following higher-current sections. The voltage traces may differ only by a few millivolts, but that is exactly the lesson: sometimes thermal coupling changes the answer a little, and sometimes it changes it a lot. You need to quantify rather than guess.

### What could go wrong

1. You forget to enable the thermal option.  
   Symptom: both temperature traces are flat.  
   Fix: make sure the second model is instantiated with `{"thermal": "lumped"}`.

2. The thermal effect is too small to see.  
   Symptom: the lumped-temperature line is technically rising but visually flat.  
   Fix: that can happen on mild traces. Increase current amplitude modestly or reduce the heat-transfer coefficient, and label the change honestly as a teaching adjustment.

3. You choose unrealistic thermal parameters and get absurd heating.  
   Symptom: the temperature rise is many tens of kelvin over one short cycle.  
   Fix: revisit the heat-transfer coefficient and the current scaling before trusting anything else.

### Walkthrough 5 reflection

This exercise teaches a modeling judgment rather than a syntax pattern. Temperature can be a fixed assumption or a solved state. The code difference is one option dictionary. The scientific difference is much larger, because it changes which mechanisms are actually active during the simulation.

## Reproduction Exercise: Recreate the Six-Step EV Ageing Protocol from Pozzato, Allam, and Onori (2022)

The open-access dataset paper by Pozzato, Allam, and Onori describes an EV-oriented ageing workflow built from CC-CV charge steps, a shallow CC discharge, and a UDDS discharge segment. The paper’s Figure 1 shows the first three cycling profiles for one cell and zooms into the six-step cycle structure. The figure caption and data-description text are unusually helpful: the authors explicitly state that positive current denotes discharge and negative current denotes charge, and they describe the six steps in prose.

That makes this a strong reproduction target for Chapter 4. We are not trying to reproduce every exact voltage value of the authors’ experimental cell. We are reproducing the *protocol structure* in PyBaMM and making our approximation choices explicit.

The paper is:

G. Pozzato, A. Allam, and S. Onori, “Lithium-ion battery aging dataset based on electric vehicle real-driving profiles,” *Data in Brief*, 41, 107995, 2022, DOI `10.1016/j.dib.2022.107995`.

### What we can match exactly

We can match the six-step sequence described in the paper:

1. charge at a specified C-rate until `4.0 V`,
2. hold at `4.0 V` until current falls below `50 mA`,
3. charge at `C/4` until `4.2 V`,
4. hold at `4.2 V` until current falls below `50 mA`,
5. shallow discharge at `C/4`,
6. UDDS discharge.

### What we cannot match exactly from the paper alone

The exact cell is an `INR21700-M50T` with nominal capacity `4.85 Ah`, while our bundled teaching parameter set is `Chen2020`. The paper’s Step 6 uses a UDDS profile normalized to the authors’ cell capacity, and the exact stop criterion for the concatenated UDDS section depends on the experimental capacity state at that point in life. Those details matter.

### Our declared approximations

We will use the `Chen2020` parameter set but reset its nominal capacity to `4.85 Ah` so the C-rates are closer to the paper’s cell. We will explicitly initialize the cell at `20% SOC` so the opening charge steps are feasible. We will approximate the shallow `C/4` discharge from `100%` to `80% SOC` as `48 minutes` at `C/4`, because `20%` of a full `4 h` `C/4` discharge is `0.8 h`. We will include one public UDDS trace rather than concatenating traces until a specific terminal SOC event.

That means our reproduction target is *structural fidelity*, not exact voltage matching. Close enough here means the current trace has the correct sign pattern, the step ordering matches the paper, and the voltage evolution is physically consistent with that sequence.

### Reproduction code

```python
import pandas as pd
import matplotlib.pyplot as plt
import pybamm


data_loader = pybamm.DataLoader()
udds = pd.read_csv(
    data_loader.get_data("UDDS.csv"),
    comment="#",
    header=None,
    names=["time_s", "current_a"],
).dropna()
udds["time_s"] = udds["time_s"] - udds["time_s"].iloc[0]
udds_array = udds[["time_s", "current_a"]].to_numpy()


parameter_values = pybamm.ParameterValues("Chen2020")
parameter_values.update({"Nominal cell capacity [A.h]": 4.85})
parameter_values = parameter_values.set_initial_state(0.2, inplace=False)

protocol = pybamm.Experiment(
    [
        "Charge at C/2 until 4.0 V",
        "Hold at 4.0 V until 50 mA",
        "Charge at C/4 until 4.2 V",
        "Hold at 4.2 V until 50 mA",
        "Rest for 30 minutes",
        "Discharge at C/4 for 48 minutes",
        pybamm.step.current(udds_array),
    ],
    period="1 second",
)

simulation = pybamm.Simulation(
    pybamm.lithium_ion.SPMe({"thermal": "lumped"}),
    parameter_values=parameter_values,
    experiment=protocol,
    solver=pybamm.CasadiSolver(mode="fast"),
)
solution = simulation.solve()

time_h = solution["Time [s]"].entries / 3600.0
current_a = solution["Current [A]"].entries
voltage_v = solution["Terminal voltage [V]"].entries


fig, axes = plt.subplots(2, 1, figsize=(10, 8), sharex=True, constrained_layout=True)

axes[0].plot(time_h, current_a, linewidth=1.8, color="tab:blue")
axes[0].set_ylabel("Current [A]")
axes[0].set_title("Protocol-structure reproduction of Pozzato et al. (2022), Fig. 1")
axes[0].grid(True, alpha=0.3)

axes[1].plot(time_h, voltage_v, linewidth=1.8, color="tab:orange")
axes[1].set_ylabel("Voltage [V]")
axes[1].set_xlabel("Time [h]")
axes[1].grid(True, alpha=0.3)

plt.show()
```

### What the reproduced figure should look like

The current trace should begin negative, because the cycle starts with charge. You should see an initial negative constant-current segment, then a tapering negative CV segment near `4.0 V`, then another smaller negative constant-current segment at `C/4`, then a second tapering CV hold near `4.2 V`. After the rest, you should see a positive `C/4` discharge plateau, followed by a jagged UDDS section with frequent current changes and occasional low-current intervals.

The voltage trace should rise during the two charge stages, flatten during the CV holds, relax during the rest, drop gently during the shallow `C/4` discharge, and then oscillate during the UDDS segment. If that sequence appears in the correct order with the correct sign convention, your reproduction is doing the intended scientific job.

### Where “close enough” ends

If your current signs are reversed, the step sequence is infeasible, or the CC-CV structure is not visible, the reproduction is not close enough. If the precise voltage values differ modestly from the experimental figure because we used a bundled teaching parameter set rather than the authors’ exact cell characterization, that is acceptable *as long as you say so*. Honest approximation is part of good reproduction practice.

## Open-Ended Exercises

### Exercise 1: Design a GITT protocol and extract quasi-OCV

Build a galvanostatic intermittent titration protocol with ten repeated pairs of `10` minutes of `C/10` discharge and `50` minutes of rest. Use the end-of-rest voltages to estimate quasi-OCV as a function of discharged capacity.

Hints:

- Use a repeated tuple inside `pybamm.Experiment`.
- The end of each rest segment is where the current is still essentially zero, but the next sample is not.
- Plot quasi-OCV points against `Discharge capacity [A.h]`.

### Exercise 2: Swap UDDS for WLTC and compare transport stress

Load `WLTC.csv` with the same helper pattern used for `UDDS.csv`. Run the same `SPMe` workflow and compare:

- final approximate SOC,
- minimum terminal voltage,
- maximum x-averaged concentration overpotential.

Hints:

- PyBaMM’s data release includes `WLTC.csv`.
- Use the same plotting structure so the comparison stays fair.
- Do not compare two traces on mismatched time units.

### Exercise 3: Quantify cooling sensitivity

Using the lumped-thermal setup from Walkthrough 5, run the same amplified UDDS trace with three heat-transfer coefficients: `5`, `10`, and `25 W.m-2.K-1`. Report the maximum temperature rise and the maximum terminal-voltage deviation from the isothermal case.

Hints:

- Write a small helper function that accepts `h` and returns a solved simulation.
- Reuse the same current trace and model options each time.
- If you change two things at once, the comparison becomes much harder to interpret.

## Worked Solutions

### Solution to Exercise 1

```python
import numpy as np
import matplotlib.pyplot as plt
import pybamm


experiment = pybamm.Experiment(
    [
        (
            "Discharge at C/10 for 10 minutes",
            "Rest for 50 minutes",
        )
    ]
    * 10,
    period="1 minute",
)

simulation = pybamm.Simulation(
    pybamm.lithium_ion.SPMe(),
    parameter_values=pybamm.ParameterValues("Chen2020"),
    experiment=experiment,
    solver=pybamm.CasadiSolver(mode="fast"),
)
solution = simulation.solve()

time_s = solution["Time [s]"].entries
current_a = solution["Current [A]"].entries
voltage_v = solution["Terminal voltage [V]"].entries
discharge_capacity_ah = solution["Discharge capacity [A.h]"].entries

rest_mask = np.isclose(current_a, 0.0, atol=1e-6)
rest_end_indices = np.where(rest_mask & np.r_[~rest_mask[1:], True])[0]

quasi_ocv_v = voltage_v[rest_end_indices]
quasi_ocv_capacity_ah = discharge_capacity_ah[rest_end_indices]

fig, axes = plt.subplots(2, 1, figsize=(9, 8), constrained_layout=True)

axes[0].plot(time_s / 3600.0, current_a, linewidth=1.7)
axes[0].set_ylabel("Current [A]")
axes[0].set_title("GITT-like protocol")
axes[0].grid(True, alpha=0.3)

axes[1].plot(quasi_ocv_capacity_ah, quasi_ocv_v, marker="o", linewidth=1.7)
axes[1].set_xlabel("Discharge Capacity [A.h]")
axes[1].set_ylabel("Quasi-OCV [V]")
axes[1].grid(True, alpha=0.3)

plt.show()
```

The first plot should look like a staircase of short positive pulses separated by long zero-current rests. The second plot should show quasi-OCV decreasing smoothly with discharged capacity. The key lesson is methodological: GITT is not just a protocol string. It is a protocol plus a post-processing rule.

### Solution to Exercise 2

```python
from pathlib import Path

import numpy as np
import pandas as pd
import pybamm


def load_cycle(name):
    loader = pybamm.DataLoader()
    cycle = pd.read_csv(
        Path(loader.get_data(name)),
        comment="#",
        header=None,
        names=["time_s", "current_a"],
    ).dropna()
    cycle["time_s"] = cycle["time_s"] - cycle["time_s"].iloc[0]
    return cycle


def run_cycle(name):
    cycle = load_cycle(name)
    experiment = pybamm.Experiment(
        [pybamm.step.current(cycle[["time_s", "current_a"]].to_numpy())],
        period="1 second",
    )
    sim = pybamm.Simulation(
        pybamm.lithium_ion.SPMe(),
        parameter_values=pybamm.ParameterValues("Chen2020"),
        experiment=experiment,
        solver=pybamm.CasadiSolver(mode="fast"),
    )
    sol = sim.solve()
    return {
        "cycle": name,
        "final_soc": float(
            1.0
            - sol["Discharge capacity [A.h]"].entries[-1]
            / pybamm.ParameterValues("Chen2020")["Nominal cell capacity [A.h]"]
        ),
        "min_voltage": float(sol["Terminal voltage [V]"].entries.min()),
        "max_conc_overpotential": float(
            np.max(
                np.abs(
                    sol["X-averaged battery concentration overpotential [V]"].entries
                )
            )
        ),
    }


for record in [run_cycle("UDDS.csv"), run_cycle("WLTC.csv")]:
    print(record)
```

The exact numbers depend on the packaged trace amplitudes, but the workflow is the point: same model, same solver, same metrics, different forcing.

### Solution to Exercise 3

```python
import numpy as np
import pandas as pd
import pybamm


loader = pybamm.DataLoader()
udds = pd.read_csv(
    loader.get_data("UDDS.csv"),
    comment="#",
    header=None,
    names=["time_s", "current_a"],
).dropna()
udds["time_s"] = udds["time_s"] - udds["time_s"].iloc[0]
udds["current_a"] = 2.0 * udds["current_a"]

experiment = pybamm.Experiment(
    [pybamm.step.current(udds[["time_s", "current_a"]].to_numpy())],
    period="1 second",
)


def solve_with_h(h_value):
    params = pybamm.ParameterValues("Chen2020")
    params.update(
        {
            "Ambient temperature [K]": 298.15,
            "Initial temperature [K]": 298.15,
            "Total heat transfer coefficient [W.m-2.K-1]": h_value,
        }
    )
    sim = pybamm.Simulation(
        pybamm.lithium_ion.SPMe({"thermal": "lumped"}),
        parameter_values=params,
        experiment=experiment,
        solver=pybamm.CasadiSolver(mode="fast"),
    )
    return sim.solve()


isothermal_solution = pybamm.Simulation(
    pybamm.lithium_ion.SPMe(),
    parameter_values=pybamm.ParameterValues("Chen2020"),
    experiment=experiment,
    solver=pybamm.CasadiSolver(mode="fast"),
).solve()


for h_value in [5.0, 10.0, 25.0]:
    sol = solve_with_h(h_value)
    max_temp_rise = float(
        sol["Volume-averaged cell temperature [K]"].entries.max() - 298.15
    )
    max_voltage_delta = float(
        np.max(
            np.abs(
                sol["Terminal voltage [V]"].entries
                - isothermal_solution["Terminal voltage [V]"].entries
            )
        )
    )
    print(
        {
            "h_W_m2_K": h_value,
            "max_temp_rise_K": round(max_temp_rise, 4),
            "max_voltage_delta_mV": round(max_voltage_delta * 1000, 2),
        }
    )
```

You should find that stronger cooling reduces peak temperature rise. Whether it materially changes voltage over one trace depends on the size of the thermal feedback under your chosen current amplitude. That is the answer the exercise is designed to make you quantify rather than guess.

## What Changes for Sodium-Ion?

By Chapter 4, the sodium-ion adaptation is no longer a footnote. It starts affecting the workflow in visible ways.

First, parameter replacement becomes more central. PyBaMM now includes an official sodium-ion example model, but the public parameter ecosystem is still much sparser than for lithium-ion. In practice, that means you will spend more time doing exactly what Walkthroughs 1 and 2 taught: inspecting parameter values, replacing OCV functions, and documenting constitutive assumptions from papers.

Second, the OCV problem gets harder. Hard-carbon sodium-ion negative electrodes often exhibit flatter or more structured OCV regions than graphite lithium-ion cells. That makes voltage less informative over some SOC windows and increases the value of protocols like GITT for building quasi-equilibrium voltage maps.

Third, equal power does not mean equal current. Sodium-ion cells typically operate at lower nominal voltage than comparable lithium-ion cells, so a drive cycle expressed in power terms often maps to higher current demand at the cell level. If you port a lithium-ion drive-cycle notebook to sodium-ion, current scaling deserves a deliberate second look.

Fourth, validation usually becomes less direct. With lithium-ion, you can often test a method against rich public datasets and then adapt it to your own chemistry. With sodium-ion, you may need to validate the workflow logic on lithium-ion public data first, then port it to sodium-ion parameter sets or digitized literature curves. That is not a weakness if you state it honestly. It is standard practice in a young data ecosystem.

Finally, low-temperature behavior matters sooner. One reason sodium-ion is attractive is its potential low-temperature robustness in some chemistries. That means the distinction between fixed-temperature and coupled-temperature modeling, which might be a small correction in one lithium-ion notebook, may become central in a sodium-ion study.

So the transferable lesson is this: Chapter 4’s software patterns carry over cleanly, but sodium-ion raises the stakes on parameter provenance, OCV fidelity, and explicit validation strategy.

## Chapter Summary and Skill Checklist

- You inspected parameter metadata with `get_info`, browsed thematic subsets with `list_by_category`, and compared published sets with `diff`.
- You made safe parameter edits by copying a baseline set, applying overrides, and saving both a human-readable override file and a full snapshot.
- You replaced function-valued parameters, including a table-based OCV function using `pybamm.Interpolant`.
- You encoded a full CC-rest-CCCV-rest experiment with `pybamm.Experiment`.
- You loaded a public UDDS drive-cycle file, validated its columns and timing, and ran it through `SPMe`.
- You compared isothermal and lumped-thermal dynamic simulations and quantified the consequences of thermal coupling.
- You reproduced the protocol structure of a published EV-style ageing cycle while documenting your approximations explicitly.

The commands, classes, and patterns that should now be entering muscle memory are:

- `pybamm.ParameterValues("Chen2020")`
- `params.get_info(...)`
- `params.list_by_category(...)`
- `params.diff(other_params)`
- `params.copy()`
- `params.update({...})`
- `params.to_json(...)`
- `pybamm.ParameterValues.from_json(...)`
- `pybamm.Experiment([...], period="...")`
- `pybamm.step.current(drive_cycle_array)`
- `pybamm.DataLoader().get_data("UDDS.csv")`
- `pybamm.Interpolant(x_data, y_data, symbolic_argument)`
- `pybamm.CasadiSolver(mode="fast")`

You should now be able to answer “yes” to each of these:

- I can inspect a PyBaMM parameter set without treating it as an opaque black box.
- I can explain the difference between changing a constant parameter, changing a function parameter, and changing the operating protocol.
- I can encode CC, CV, rest, and drive-cycle steps in a single reproducible experiment.
- I can import a public current trace and check its time base and sign convention before trusting the result.
- I can explain whether temperature was fixed or coupled in a given simulation and why that choice was acceptable.

If any of those boxes are still unchecked, revisit the relevant walkthrough before you move into Chapter 5. Parameter estimation is much harder when parameter provenance and protocol design are still fuzzy.

## Deliverable

The deliverable for this chapter is:

> A notebook that runs a realistic drive cycle on a commercial-like cell and produces publication-quality plots of voltage, current, SOC, and internal concentrations.

Approach it in four stages.

First, create a parameter-provenance section at the top of the notebook. Load a bundled parameter set, save an override file, and print the exact parameters you changed. The user-visible rule here is simple: if a reviewer asked what changed relative to the base chemistry, your notebook should answer in one screen.

Second, include one clean protocol section using `Experiment`. It can be the CC-rest-CCCV-rest example from Walkthrough 3 or a variant you design yourself.

Third, include one real-data section that loads `UDDS.csv` or another public drive cycle such as `WLTC.csv`, validates the file structure, and runs it through either `SPMe` or `DFN`. Save a figure with four aligned panels showing current, voltage, SOC, and one internal concentration variable.

Fourth, add a short interpretation paragraph. It should state which model fidelity you chose, which parameter edits matter scientifically, whether temperature was fixed or coupled, and why those choices are appropriate for a first research-grade notebook.

A strong partial deliverable includes:

- one top-to-bottom runnable notebook,
- one saved JSON override file,
- one saved protocol figure,
- one saved drive-cycle figure,
- one short written interpretation of the modeling choices.

## Further Practice and Reading

1. PyBaMM Tutorial 4, “Setting parameter values”  
   `https://docs.pybamm.org/en/stable/source/examples/notebooks/getting_started/tutorial-4-setting-parameter-values.html`

2. PyBaMM Tutorial 5, “Run experiments”  
   `https://docs.pybamm.org/en/v25.4.0/source/examples/notebooks/getting_started/tutorial-5-run-experiments.html`

3. PyBaMM notebook, “Changing the input current when solving PyBaMM models”  
   `https://docs.pybamm.org/en/stable/source/examples/notebooks/parameterization/change-input-current.html`

4. G. Pozzato, A. Allam, and S. Onori, “Lithium-ion battery aging dataset based on electric vehicle real-driving profiles,” *Data in Brief*, 41, 107995, 2022.  
   DOI `10.1016/j.dib.2022.107995`

5. Y. Xiaolong Chen et al., “Development of Experimental Techniques for Parameterization of Multi-scale Lithium-ion Battery Models,” *Journal of The Electrochemical Society*, 167, 080534, 2020.  
   DOI `10.1149/1945-7111/ab9050`

6. PyBaMM official sodium-ion example  
   `https://docs.pybamm.org/en/stable/source/examples/notebooks/models/sodium-ion.html`

7. EPA Dynamometer Drive Schedules page  
   `https://www.epa.gov/vehicle-and-fuel-emissions-testing/dynamometer-drive-schedules`

8. PyBaMM GitHub discussions for practical implementation questions  
   `https://github.com/pybamm-team/PyBaMM/discussions`

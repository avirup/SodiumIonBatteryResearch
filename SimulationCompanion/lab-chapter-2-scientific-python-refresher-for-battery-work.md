# Lab Chapter 2: Scientific Python Refresher for Battery Work

## Chapter Opening

This chapter is about turning general scientific Python familiarity into battery-modeling fluency. By the time you finish it, you should no longer think of NumPy, SciPy, Pandas, and Matplotlib as four separate libraries you learned once in a methods course. You should think of them as the basic hand tools with which you express battery equations, solve dynamic models, inspect time-series data, fit parameters, and generate figures that can survive the transition from notebook output to paper draft. The immediate skill goal is modest on purpose: solve a battery-flavored ODE in Python with confidence. But the research goal underneath it is larger. We are building the numerical habits you will reuse in PyBaMM, in parameter-estimation pipelines, in dataset cleaning, and in every simulation-validation loop that follows.

This chapter operationalizes material you already learned in the theory textbook, especially Textbook Chapter 10 on equivalent-circuit models and state estimation. Keep that chapter open while you work. When we write the second-order Thevenin model as a system of differential equations, we are translating the circuit intuition of that chapter into executable code. Textbook Chapter 3 should also remain close at hand, because we will be careful about units, current sign conventions, capacity normalization, and the distinction between open-circuit voltage and terminal voltage. Later, when we talk about fitting parameters from voltage data, you should also remember the warnings from the textbook chapters on cell behavior and degradation: a model can fit a curve and still be physically misleading if you ask the data to identify parameters it cannot actually distinguish.

This chapter also builds directly on Lab Chapter 1. Chapter 1 gave you the environment and reproducibility habits that prevent your numerical work from becoming a pile of semi-runnable notebook fragments. Here we use that environment for real modeling work. We will reuse the repository layout, the logging habit, and the idea that every meaningful output should be reproducible from code and tied to a specific environment. If Chapter 1 was the lab bench, Chapter 2 is the moment we start using the instruments.

The pacing is intentional. We are not jumping into PyBaMM yet. That will happen in Chapter 3. Before we ask PyBaMM to discretize a Doyle-Fuller-Newman model, you need to be comfortable with the simpler but crucial layer underneath: arrays, state vectors, ODE solvers, least-squares fitting, time-indexed data cleaning, and plot construction. Those are not beginner topics in disguise. They are the skeleton underneath almost every publishable battery workflow. If you can write and trust a clean second-order RC model today, you will understand PyBaMM objects better in Chapter 3, design cleaner experiments in Chapter 4, fit parameters more honestly in Chapter 5, and move into MATLAB ECM work in Chapter 6 without feeling as if the math and the code live in separate universes.

There is one more reason this chapter matters for your specific goal of publishable sodium-ion research. Sodium-ion work often begins in a data-sparse environment. You will frequently be adapting lithium-ion methods, public datasets, and model structures to sodium-ion chemistry. That means you need to distinguish the durable computational skill from the chemistry-specific assumption. Solving an ODE, resampling a time series, or fitting a parameter vector are durable skills. The exact OCV curve, voltage window, and identifiability behavior are chemistry-specific. This chapter helps you separate those layers cleanly, which is exactly what you need if your long-term target is simulation-based sodium-ion work built on partial public data.

So our pattern for the chapter is simple. First, we bridge the theory of equivalent-circuit models to their numerical representation. Then we refresh the NumPy patterns that battery work uses constantly. After that, we solve a second-order RC model with `scipy.integrate.solve_ivp`, compare solver behavior, and talk honestly about what solver choice means. Next, we shift from synthetic signals to a public experimental dataset so that Pandas and Matplotlib are grounded in real battery traces rather than toy CSV files. Then we fit a model back to noisy data using `scipy.optimize.least_squares`. Finally, because Part I of this companion must already train you in reproduction practice, we will reproduce a published time-series figure from an open paper using the paper's linked public dataset. That last exercise is where the chapter becomes more than a refresher. It becomes research practice.

## Prerequisites Check

- Required software: the `sib-research` environment from Lab Chapter 1; `Python 3.11`; `JupyterLab 4.4+`; `Git 2.43+`
- Required Python packages: `numpy==2.3.4`, `scipy==1.16.0`, `pandas==3.0.2`, `matplotlib==3.10.8`, `jupyterlab==4.4.10`, `ipykernel==7.2.0`
- Optional but recommended: a code editor with notebook support, and a PDF viewer so you can keep the chapter and the cited paper open together
- Required textbook chapters: Textbook Chapter 3 and Textbook Chapter 10 are essential; the chapter becomes easier if Textbook Chapter 7 is also familiar conceptually
- Required prior lab chapters: Lab Chapter 1
- Estimated time: 10 to 14 hours, depending on how quickly you move through the fitting and reproduction sections

If any of these feel shaky, stop now instead of pushing forward half-prepared. If NumPy broadcasting still feels magical rather than understandable, the early sections of this chapter are especially important. If your Chapter 1 environment is not reproducible yet, fix that first. We will assume from this point onward that you can create a notebook, run a script from the repository root, and save outputs into `results/` and `figures/` without confusion.

## Environment Setup

This chapter does not require a brand-new environment, but it does require confidence that the Chapter 1 environment is the one you are actually using. The most common failure mode in numerical methods chapters is not a wrong equation. It is running the right code in the wrong interpreter.

### Step 1: Activate the Chapter 1 environment

If you used `conda` in Chapter 1:

```bash
conda activate sib-research
```

If you used `venv` on Linux or macOS:

```bash
source .venv/bin/activate
```

If you used `venv` on Windows PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

### Step 2: Verify the scientific stack

Run this from the repository root:

```bash
python - <<'PY'
import numpy as np
import scipy
import pandas as pd
import matplotlib

print("NumPy     :", np.__version__)
print("SciPy     :", scipy.__version__)
print("Pandas    :", pd.__version__)
print("Matplotlib:", matplotlib.__version__)
PY
```

Expected output should look like:

```text
NumPy     : 2.3.4
SciPy     : 1.16.0
Pandas    : 3.0.2
Matplotlib: 3.10.8
```

Patch-version drift is not automatically a disaster, but if your versions differ from the pinned Chapter 1 environment, record that in your research log before continuing.

### Step 3: Create a notebook and script location for this chapter

We will keep the usual pattern: exploratory work in `notebooks/`, reusable helpers in `src/`, and generated outputs in `results/` and `figures/`.

```bash
mkdir -p notebooks src results figures data/raw data/processed
```

Create a notebook called `notebooks/chapter_2_scientific_python_refresher.ipynb`. If you prefer to begin in a script, that is fine, but the notebook format is useful here because we will inspect intermediate arrays and plots frequently.

### Step 4: Minimal `solve_ivp` hello world

Before we solve a battery model, verify that SciPy's ODE solver is functioning.

```python
import numpy as np
from scipy.integrate import solve_ivp


def exponential_decay_rhs(time_s, state):
    return [-0.5 * state[0]]


evaluation_times_s = np.linspace(0.0, 10.0, 6)

solution = solve_ivp(
    fun=exponential_decay_rhs,
    t_span=(0.0, 10.0),
    y0=[1.0],
    t_eval=evaluation_times_s,
)

print("status:", solution.status)
print("message:", solution.message)
print("y(t):", np.round(solution.y[0], 4))
```

Expected output:

```text
status: 0
message: The solver successfully reached the end of the integration interval.
y(t): [1.     0.3679 0.1353 0.0498 0.0183 0.0067]
```

Those values follow the exact analytical solution $y(t) = e^{-0.5t}$. If your numbers are close to the ones above, your solver is working.

### Step 5: Launch JupyterLab and confirm the kernel

```bash
jupyter lab
```

Open the notebook you created and check the kernel name in the top-right corner. It should still be `Python (sib-research)` or the Chapter 1 equivalent. Then run:

```python
import sys
print(sys.executable)
```

The printed path should point into your intended environment. If it points to a system interpreter, stop and fix the kernel mismatch now.

### Common setup failures and fixes

1. `ModuleNotFoundError: No module named 'scipy'`  
   Symptom: imports fail inside Jupyter but succeed in the terminal, or vice versa.  
   Fix: you almost certainly have a kernel mismatch. Re-register the kernel from the active environment with `python -m ipykernel install --user --name sib-research --display-name "Python (sib-research)"`.

2. `ImportError` mentioning a compiled library or wheel incompatibility  
   Symptom: NumPy or SciPy imports fail even though installation appeared to work.  
   Fix: this is usually an environment inconsistency. Recreate the environment from `environment.yml` rather than trying to patch it package-by-package.

3. Plots do not display in the notebook  
   Symptom: code runs but no figure appears.  
   Fix: ensure the notebook cell actually ends with a plotting command or `plt.show()`, and verify that you did not disable the inline backend accidentally.

4. `solve_ivp` works for the hello-world example but later battery code fails with shape errors  
   Symptom: SciPy complains about incompatible dimensions or unpacking errors.  
   Fix: the most common cause is forgetting that the state passed into the right-hand side is an array, even for scalar problems. We will be very explicit about state-vector shape in the next section.

## Conceptual Bridge: From the Equivalent Circuit in the Textbook to a State Vector in Python

In Textbook Chapter 10, the equivalent-circuit model was valuable because it compressed a complicated electrochemical reality into a small number of states and parameters you could reason about directly. A resistor gave you the instantaneous ohmic drop. One or more RC branches gave you delayed polarization behavior. SOC evolved through charge balance. The model was not "true" in the same way a physics-based porous-electrode model aims to be true, but it was useful because it captured the right dynamic shape at the right computational cost.

The most important translation we make in this chapter is that from circuit picture to state-space representation. In the textbook, you probably drew the second-order Thevenin model as an OCV source in series with $R_0$ and two parallel RC branches. In Python, that same model becomes a state vector and a right-hand-side function. If discharge current is positive, one convenient form is

$$
\frac{dz}{dt} = -\frac{I(t)}{3600 Q_\mathrm{n}},
\tag{1}
$$

$$
\frac{dv_1}{dt} = -\frac{v_1}{R_1 C_1} + \frac{I(t)}{C_1},
\qquad
\frac{dv_2}{dt} = -\frac{v_2}{R_2 C_2} + \frac{I(t)}{C_2},
\tag{2}
$$

and

$$
V_\mathrm{t}(t) = \mathrm{OCV}\!\left(z(t)\right) - I(t)R_0 - v_1(t) - v_2(t).
\tag{3}
$$

Equation (1) says SOC is just charge balance written in differential form. Equation (2) says each RC branch stores a transient overpotential with its own time constant $\tau_i = R_i C_i$. Equation (3) says terminal voltage is open-circuit voltage minus the ohmic drop and minus the transient branch drops. Nothing here is new physically. What changes is the representation. Instead of solving the circuit by hand for one simple input, we hand the whole system to an ODE solver and let it march through time.

This is exactly the moment where many readers conceptually split in two. One group thinks, "Good, now we are doing code." The other thinks, "Good, now we are still doing the same battery model, just in executable form." The second attitude is the right one. The Python objects are not a separate subject. They are the mechanism by which the same model becomes testable, sweepable, fit-able, and eventually publishable.

NumPy enters first because state-space battery work is almost never scalar work. Even if the state vector is only three elements long, the surrounding workflow is array-shaped. You evaluate OCV at hundreds of SOC points. You compare multiple current levels on the same grid. You slice discharge windows out of a long record. You compute residual vectors between measured and simulated voltage samples. Vectorization is not a performance trick added at the end. It is the natural language of the problem.

SciPy's `solve_ivp` is the next layer. In textbook notation, the model is a set of coupled first-order ODEs. In SciPy notation, it is a Python function with signature `rhs(t, y, ...)` that returns the time derivative of the state vector. The ODE solver repeatedly calls that function, chooses time steps, and constructs a numerical approximation to the trajectory. That sounds mechanical, but several research decisions hide inside it. Which solver should you choose? How tight should the tolerances be? Is the problem stiff? Do you want the solution only at a few evaluation times or on an adaptive grid? Those questions do not disappear just because the code runs. They become part of the modeling method.

`scipy.optimize.least_squares` extends the same logic into inverse problems. In forward simulation, we supply parameters and predict voltage. In fitting, we reverse the direction: we adjust parameters so that simulated voltage resembles measured voltage as closely as possible. Mathematically, we define a residual vector such as

$$
r_i(\theta) = V_{\mathrm{sim},i}(\theta) - V_{\mathrm{meas},i},
\tag{4}
$$

and we ask the optimizer to reduce the norm of that vector over parameter vector $\theta$. Again, the software object and the battery method are the same idea seen from two angles. A parameter fit is just a repeated forward simulation wrapped in an optimizer.

Pandas then plays a complementary role. The textbook equivalent-circuit model is mathematically clean, but real battery datasets are not. Public files contain missing values, inconsistent headings, text legends, different sign conventions, and sometimes incomplete metadata. Pandas is the structure we use to make those data problems explicit rather than informal. A `DataFrame` is where units become column names, timestamps become indices, resampling becomes auditable, and segment labels become filter conditions. That matters because later, when you do publishable work, a large fraction of your time will not be spent solving equations. It will be spent making sure the data you feed into those equations are what you think they are.

Matplotlib is the last piece of the bridge. In theory, a plotted curve is evidence. In practice, plotting is part of analysis, not just presentation. A good plot tells you whether a solver stepped over a sharp transient, whether a fit is matching only the slow drift and missing the pulse edges, whether your sign convention is backwards, and whether one current trace is actually being plotted on the wrong axis. Publication-quality plotting begins long before publication. It begins when your diagnostic plots are precise enough that you can trust them.

So the bridge from textbook theory to scientific Python is not a change in subject. It is a change in representation. The circuit becomes a state vector, the governing equations become a right-hand-side function, the dataset becomes a `DataFrame`, the calibration becomes a least-squares problem, and the interpretation becomes a figure you can read critically. Keep that translation in mind through every exercise in this chapter. If the code ever starts feeling like disconnected syntax, come back to Equations (1) through (4) and ask which mathematical object each line is implementing.

## Guided Walkthrough 1: NumPy Patterns You Will Use Constantly

**Learning objective:** Use vectorization, broadcasting, and slicing to evaluate battery voltage over many SOC and current combinations without writing nested Python loops.

Before we solve any ODEs, we need to refresh the array operations that battery work uses all the time. The right way to think about vectorization here is not "faster code" but "clearer statement of the physics." If you want terminal voltage for four current levels over an SOC grid, that is a 2D array problem. Writing it as a 2D array clarifies the structure of the question.

### Walkthrough 1 code

```python
import numpy as np
import matplotlib.pyplot as plt


def teaching_ocv_from_soc(soc_fraction):
    """Simple smooth OCV curve with low-SOC and high-SOC knees."""
    soc_fraction = np.clip(np.asarray(soc_fraction), 0.0, 1.0)
    return (
        2.85
        + 0.42 * soc_fraction
        + 0.06 * np.tanh((soc_fraction - 0.10) / 0.04)
        + 0.10 * np.tanh((soc_fraction - 0.88) / 0.05)
    )


soc_grid = np.linspace(0.02, 0.98, 241)
discharge_currents_a = np.array([1.0, 2.0, 4.0, 6.0])[:, None]
r0_ohm = 0.018

ocv_grid_v = teaching_ocv_from_soc(soc_grid)
terminal_voltage_grid_v = ocv_grid_v - discharge_currents_a * r0_ohm

mid_soc_slice = slice(80, 161)
mid_soc_soc = soc_grid[mid_soc_slice]
mid_soc_voltage_grid_v = terminal_voltage_grid_v[:, mid_soc_slice]

print("soc_grid shape:", soc_grid.shape)
print("discharge_currents_a shape:", discharge_currents_a.shape)
print("terminal_voltage_grid_v shape:", terminal_voltage_grid_v.shape)
print("Voltage at 50% SOC for each current level [V]:")
soc_50_index = np.argmin(np.abs(soc_grid - 0.50))
print(np.round(terminal_voltage_grid_v[:, soc_50_index], 4))

fig, ax = plt.subplots(figsize=(8, 5), constrained_layout=True)

for current_a, voltage_curve_v in zip(discharge_currents_a[:, 0], terminal_voltage_grid_v):
    ax.plot(
        soc_grid,
        voltage_curve_v,
        linewidth=2.0,
        label=f"{current_a:.0f} A discharge",
    )

ax.set_xlabel("State of charge, SOC [-]")
ax.set_ylabel("Terminal voltage [V]")
ax.set_title("Broadcasted voltage calculation over SOC and discharge current")
ax.grid(True, alpha=0.3)
ax.legend()

plt.show()
```

### Walkthrough 1 code explanation

The `teaching_ocv_from_soc` function is not intended as a chemistry-specific OCV model. It is a smooth teaching function that mimics three features you expect in a real OCV curve: a broad central region, a low-SOC knee, and a high-SOC knee. The `np.tanh` terms are especially convenient for teaching because they create smooth transitions without any piecewise discontinuities. Later chapters will replace this kind of teaching function with tabulated or experimentally fitted OCV relations, but for now the smoothness is helpful because it keeps numerical behavior easy to interpret.

`soc_grid = np.linspace(0.02, 0.98, 241)` creates a one-dimensional array of SOC values. We deliberately stop short of exactly 0 and 1 because many battery functions behave awkwardly at the hard edges of the allowable range. In publishable work, you often clip away the extreme ends for similar reasons.

`discharge_currents_a = np.array([1.0, 2.0, 4.0, 6.0])[:, None]` is the line most worth pausing on. The values start as a one-dimensional array of shape `(4,)`. The `[:, None]` adds a new axis, turning it into a column vector of shape `(4, 1)`. That one extra axis is what allows broadcasting to work cleanly against the SOC grid of shape `(241,)`.

`ocv_grid_v = teaching_ocv_from_soc(soc_grid)` returns a one-dimensional voltage array of length 241. When we write `ocv_grid_v - discharge_currents_a * r0_ohm`, NumPy broadcasts the `(241,)` OCV array against the `(4, 1)` current array and produces a `(4, 241)` terminal-voltage array. That is exactly what we want: one voltage curve for each current level, evaluated at every SOC point.

The `mid_soc_slice = slice(80, 161)` line is here because slicing is a daily battery-analysis operation, not a beginner curiosity. You will constantly isolate windows: the middle SOC range, the first 60 seconds of a pulse, the rest period after a current step, or the final 10% of a charge. Writing a slice object once and reusing it is clearer than sprinkling index literals throughout the code.

`soc_50_index = np.argmin(np.abs(soc_grid - 0.50))` finds the grid point closest to 50% SOC. In research code you should prefer explicit selection logic like this over assuming that a nice round SOC value is exactly present in a floating-point grid.

In the plot loop, the `zip(discharge_currents_a[:, 0], terminal_voltage_grid_v)` pairing works because `discharge_currents_a[:, 0]` turns the column vector back into a flat list of current values for labeling, while `terminal_voltage_grid_v` iterates row-by-row over the broadcast result.

### Walkthrough 1 expected output

The terminal printout should look like this in structure:

```text
soc_grid shape: (241,)
discharge_currents_a shape: (4, 1)
terminal_voltage_grid_v shape: (4, 241)
Voltage at 50% SOC for each current level [V]:
[3.1131 3.0951 3.0591 3.0231]
```

The exact voltages may differ by a few last digits depending on the SOC grid point closest to 0.50, but the pattern must be monotonic: higher discharge current produces lower terminal voltage at the same SOC because the ohmic drop grows as $I R_0$.

The plot should show four smooth curves of terminal voltage versus SOC. All four curves should have the same shape because only the ohmic term changes in this simple example; the higher-current curves should be vertically shifted downward by a constant amount relative to the lower-current curves. The low-SOC and high-SOC knees should be visible. A wrong result usually looks like one of three things: curves crossing when they should not, a jagged line caused by accidental integer indexing, or only one curve appearing because broadcasting collapsed incorrectly.

### Walkthrough 1 troubleshooting

1. `ValueError` about incompatible shapes  
   Symptom: `operands could not be broadcast together`.  
   Fix: make sure the current array has shape `(n_currents, 1)` rather than `(n_currents,)`. The `[:, None]` is the key.

2. All four curves lie on top of each other  
   Symptom: the plot shows only one apparent curve.  
   Fix: verify that `r0_ohm` is not accidentally zero and that you did not overwrite `discharge_currents_a` with a scalar.

3. The voltage increases with current  
   Symptom: higher discharge current produces a higher terminal voltage.  
   Fix: your sign convention is reversed somewhere. In this chapter, discharge current is positive and subtracts voltage.

### Walkthrough 1 reflection

This exercise taught the NumPy shape habits we will keep reusing: column vectors for parameter sweeps, one-dimensional grids for state variables, slicing for physically meaningful windows, and explicit attention to units and sign convention. If this felt almost too simple, that is good. These are the habits that make later model code readable instead of mysterious.

## Guided Walkthrough 2: Solve a Second-Order RC Model with `solve_ivp`

**Learning objective:** Implement the second-order Thevenin model from Textbook Chapter 10 as an ODE system, solve it under a pulse-rest protocol, and compare solver behavior.

This is the chapter's core numerical exercise. We will move from an algebraic battery approximation to a dynamic model with internal states. The model is still small enough to understand line-by-line, which is exactly why it is such a good bridge to later chapters.

### Solver choice before code

You will see three SciPy solvers in this chapter: `RK45`, `BDF`, and `LSODA`. Here is the practical distinction you should remember.

| Solver | Numerical family | Good default use | Most common failure mode in battery work |
| --- | --- | --- | --- |
| `RK45` | explicit Runge-Kutta | nonstiff problems; first checks; teaching examples | many tiny steps when dynamics span very different time constants |
| `BDF` | implicit multistep | stiff or mildly stiff problems; later PyBaMM-like behavior | extra overhead when the problem is easy |
| `LSODA` | automatic stiffness switching | when you do not know if the problem is stiff | harder to diagnose solver behavior because the switching is internal |

The two RC time constants in this exercise are intentionally separated enough that stiffness can begin to matter, but not so extreme that the model becomes numerically fragile.

### Walkthrough 2 code

```python
from dataclasses import dataclass
from time import perf_counter

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp


@dataclass(frozen=True)
class TheveninParameters:
    capacity_ah: float
    r0_ohm: float
    r1_ohm: float
    c1_f: float
    r2_ohm: float
    c2_f: float


def teaching_ocv_from_soc(soc_fraction):
    soc_fraction = np.clip(np.asarray(soc_fraction), 0.0, 1.0)
    return (
        2.85
        + 0.42 * soc_fraction
        + 0.06 * np.tanh((soc_fraction - 0.10) / 0.04)
        + 0.10 * np.tanh((soc_fraction - 0.88) / 0.05)
    )


PARAMS = TheveninParameters(
    capacity_ah=3.0,
    r0_ohm=0.015,
    r1_ohm=0.010,
    c1_f=1800.0,
    r2_ohm=0.008,
    c2_f=18000.0,
)


segment_start_times_s = np.array([0, 300, 900, 1200, 1500, 1800, 2400, 3000], dtype=float)
segment_currents_a = np.array([0.0, 3.0, 0.0, 6.0, 0.0, 4.5, 0.0, 1.5], dtype=float)
simulation_end_time_s = 3600.0


def current_profile_a(time_s):
    segment_index = np.searchsorted(segment_start_times_s, time_s, side="right") - 1
    segment_index = np.clip(segment_index, 0, len(segment_currents_a) - 1)
    return float(segment_currents_a[segment_index])


def thevenin_rhs(time_s, state, params):
    soc_fraction, v_rc1_v, v_rc2_v = state
    current_a = current_profile_a(time_s)

    dsoc_dt = -current_a / (3600.0 * params.capacity_ah)
    dv_rc1_dt = -(v_rc1_v / (params.r1_ohm * params.c1_f)) + current_a / params.c1_f
    dv_rc2_dt = -(v_rc2_v / (params.r2_ohm * params.c2_f)) + current_a / params.c2_f

    return [dsoc_dt, dv_rc1_dt, dv_rc2_dt]


def simulate_model(method_name):
    evaluation_times_s = np.linspace(0.0, simulation_end_time_s, 1201)
    initial_state = [0.95, 0.0, 0.0]

    start_clock = perf_counter()

    solution = solve_ivp(
        fun=thevenin_rhs,
        t_span=(0.0, simulation_end_time_s),
        y0=initial_state,
        t_eval=evaluation_times_s,
        method=method_name,
        args=(PARAMS,),
        rtol=1e-8,
        atol=1e-10,
    )

    elapsed_wall_time_s = perf_counter() - start_clock

    current_trace_a = np.array([current_profile_a(t) for t in solution.t])
    soc_trace = solution.y[0]
    v_rc1_trace_v = solution.y[1]
    v_rc2_trace_v = solution.y[2]
    terminal_voltage_v = (
        teaching_ocv_from_soc(soc_trace)
        - current_trace_a * PARAMS.r0_ohm
        - v_rc1_trace_v
        - v_rc2_trace_v
    )

    output = pd.DataFrame(
        {
            "time_s": solution.t,
            "current_a": current_trace_a,
            "soc_fraction": soc_trace,
            "v_rc1_v": v_rc1_trace_v,
            "v_rc2_v": v_rc2_trace_v,
            "terminal_voltage_v": terminal_voltage_v,
        }
    )

    diagnostics = {
        "method": method_name,
        "status": solution.status,
        "nfev": solution.nfev,
        "wall_time_s": elapsed_wall_time_s,
        "final_soc": soc_trace[-1],
        "final_voltage_v": terminal_voltage_v[-1],
    }

    return output, diagnostics


all_outputs = {}
all_diagnostics = []

for solver_name in ["RK45", "BDF", "LSODA"]:
    simulation_output, diagnostics = simulate_model(solver_name)
    all_outputs[solver_name] = simulation_output
    all_diagnostics.append(diagnostics)


diagnostics_table = pd.DataFrame(all_diagnostics)
print(diagnostics_table.round(6))

reference_voltage_v = all_outputs["BDF"]["terminal_voltage_v"].to_numpy()

for solver_name, simulation_output in all_outputs.items():
    max_abs_difference_v = np.max(
        np.abs(simulation_output["terminal_voltage_v"].to_numpy() - reference_voltage_v)
    )
    print(f"{solver_name:>5s} max |V - V_BDF| = {max_abs_difference_v:.6e} V")


fig, axes = plt.subplots(3, 1, figsize=(9, 9), sharex=True, constrained_layout=True)

for solver_name, simulation_output in all_outputs.items():
    axes[0].plot(
        simulation_output["time_s"] / 60.0,
        simulation_output["terminal_voltage_v"],
        linewidth=2.0,
        label=solver_name,
    )
    axes[1].plot(
        simulation_output["time_s"] / 60.0,
        simulation_output["soc_fraction"],
        linewidth=2.0,
        label=solver_name,
    )

bdf_output = all_outputs["BDF"]
axes[2].step(
    bdf_output["time_s"] / 60.0,
    bdf_output["current_a"],
    where="post",
    color="black",
    linewidth=1.8,
)

axes[0].set_ylabel("Terminal voltage [V]")
axes[1].set_ylabel("SOC [-]")
axes[2].set_ylabel("Current [A]")
axes[2].set_xlabel("Time [min]")

axes[0].set_title("Second-order Thevenin response under a pulse-rest protocol")
axes[0].grid(True, alpha=0.3)
axes[1].grid(True, alpha=0.3)
axes[2].grid(True, alpha=0.3)
axes[0].legend()

plt.show()
```

### Walkthrough 2 code explanation

The `@dataclass(frozen=True)` definition is a clean way to package the model parameters. We use a dataclass here not because it is fashionable, but because it makes parameter names explicit and prevents accidental in-place mutation. In fitting work later, we will sometimes create modified parameter sets. Freezing the dataclass helps catch unintended edits.

The current profile is represented by `segment_start_times_s` and `segment_currents_a`. This is a standard pattern for piecewise-constant battery protocols. Each entry in `segment_currents_a` applies from its start time until the next listed start time. The sequence here is rest, 3 A pulse, rest, 6 A pulse, rest, 4.5 A pulse, rest, then a gentle 1.5 A discharge to the end. That protocol is pedagogically useful because it excites both fast and slow RC dynamics.

`current_profile_a` uses `np.searchsorted` to determine which time segment contains the current solver time. The crucial detail is `side="right"` combined with subtracting one. That means a time exactly equal to a segment boundary belongs to the new segment, which is what we want for a right-continuous step protocol.

Inside `thevenin_rhs`, the state vector is unpacked into `soc_fraction`, `v_rc1_v`, and `v_rc2_v`. This is the code representation of Equations (1) and (2). Notice how compact it becomes once the physics is already understood. The SOC equation divides current by `3600 * capacity_ah` because one amp-hour is 3600 coulombs. That factor is easy to forget, and forgetting it is one of the fastest ways to get obviously wrong SOC trajectories.

The RC branch equations each have a decay term and a forcing term. The decay term is `-v_rc / (R C)`, which tells the branch overpotential to relax to zero in the absence of current. The forcing term is `I / C`, which drives the branch state during current flow.

`simulate_model` exists so we can rerun the same model cleanly with different solver methods. Reusable wrappers like this are important. If the solver configuration is embedded inline in three separate notebook cells, comparison becomes much harder to trust.

The solver tolerances `rtol=1e-8` and `atol=1e-10` are tighter than you would need for a quick exploratory sketch, but that is intentional. We want solver-to-solver differences to reflect the method, not a loose tolerance choice. Later, when computational cost matters more, you will often loosen these tolerances.

We compute terminal voltage after solving rather than treating it as an additional differential state. That is correct because voltage here is an algebraic output of the state, not a state that needs its own ODE.

The `diagnostics_table` prints `status`, `nfev`, wall-clock time, final SOC, and final voltage. In model development, diagnostics like this should be routine. Otherwise you can switch solvers and feel productive without actually learning anything about the numerical behavior.

### Walkthrough 2 expected output

The diagnostics table should have three rows, one per solver. The exact wall times depend on your machine, but the qualitative pattern should look like this:

```text
  method  status   nfev  wall_time_s  final_soc  final_voltage_v
0   RK45       0    ...       ...       0.400...        2.98...
1    BDF       0    ...       ...       0.400...        2.98...
2  LSODA       0    ...       ...       0.400...        2.98...
```

All three solvers should finish successfully with `status = 0`. The final SOC should be about 0.40 because the total discharged ampere-hours in the profile are substantial but not enough to empty the 3 Ah cell. The final terminal voltage should be just under 3.0 V for the teaching OCV curve and parameter set used here.

The printed maximum voltage differences relative to `BDF` should usually be small, often in the microvolt-to-submillivolt range for this problem when using tight tolerances. If you see differences of several tens of millivolts, something is wrong.

The figure should have three stacked panels. The top panel shows terminal voltage, with visible downward steps at current pulses and smooth recovery during rest intervals. The middle panel shows SOC declining only during discharge segments and flattening during rest. The bottom panel shows the pulse-rest current schedule as a step plot. A correct voltage plot has both instantaneous drops and slower relaxations. If you see only sharp jumps with no recovery curvature, you have probably lost the RC dynamics. If you see SOC changing during rest, your current profile function is wrong.

### Walkthrough 2 troubleshooting

1. SOC goes negative or above 1  
   Symptom: the SOC trace leaves the physically valid interval.  
   Fix: check the current sign convention and the capacity conversion factor of `3600`.

2. Voltage rises during discharge pulses  
   Symptom: applying positive discharge current makes the terminal voltage jump upward.  
   Fix: the sign on the ohmic or RC terms is reversed.

3. The solver raises a dimension or unpacking error  
   Symptom: messages about too many or too few values to unpack.  
   Fix: verify that `y0` has three entries and the right-hand side returns three derivatives.

4. `RK45` appears much slower than the others  
   Symptom: large `nfev` or noticeably longer runtime.  
   Fix: that can be real. The separated RC time constants make the problem mildly stiff. Record the observation rather than assuming it is a bug.

### Walkthrough 2 reflection

This exercise taught the basic forward-model pattern we will reuse all through the manual: define parameters, define an input protocol, write a right-hand side, solve the ODE, compute outputs, and inspect diagnostics. Chapter 5 will wrap this same pattern inside an optimizer. Chapter 6 will rebuild a similar model in MATLAB. Chapter 3 will replace this hand-built ODE with a much larger PyBaMM model, but the logic will still feel familiar if you understand this exercise well.

## Dataset Integration: A Public Battery Time-Series File

This chapter's real-data anchor is the public dataset released alongside Ana Foles and co-authors' open paper on lithium-ion battery pack modeling for stationary energy management. We will use it for Pandas practice and for the Part I reproduction exercise.

| Item | Value |
| --- | --- |
| Dataset | `Lithium_Ion_Battery_Testing_Data.csv` |
| Landing page | `https://doi.org/10.5281/zenodo.5196334` |
| Direct download | `https://zenodo.org/records/5196334/files/Lithium_Ion_Battery_Testing_Data.csv?download=1` |
| Size | about 2.9 MB |
| Format | CSV |
| License | CC BY 4.0 |
| Paper using the data | Foles et al., *Open Research Europe* (2022), DOI `10.12688/openreseurope.14301.2` |

The paper describes the file as containing charge and discharge acquisition data at constant power levels, including current, voltage, SOC, ambient temperature, and a final legend column named `BI` that explains the segment or operating condition. This is a good teaching dataset because it is small enough to inspect comfortably but real enough to remind you that public battery data never arrive in the exact shape your analysis wants.

Three common pitfalls matter before we touch the code.

First, current sign convention is never to be assumed. Some datasets treat discharge current as positive, some as negative, and some switch conventions between instruments. You should not infer the sign convention from wishful thinking. You should infer it from how voltage and SOC move together.

Second, time columns are often messy. Some files store elapsed seconds, some absolute timestamps, some MATLAB datenums, and some only preserve row order. Our parsing code will therefore detect time heuristically rather than assuming one exact header.

Third, text metadata matter. The `BI` legend column may look ancillary, but it is the column that lets us isolate constant-power segments for plotting and reproduction. Treat text columns in battery datasets as part of the method, not as decoration.

## Guided Walkthrough 3: Parse, Clean, and Plot a Public Battery Dataset with Pandas and Matplotlib

**Learning objective:** Download a real battery CSV, normalize its column names, infer a usable time axis, resample a trace, and produce a publication-quality diagnostic plot.

We are now leaving the world of fully controlled synthetic signals. That means the code will get longer, but the length is doing real work. Every explicit cleaning step is a future argument you will not need to have with yourself about what the data actually mean.

### Walkthrough 3 code

```python
from pathlib import Path
from urllib.request import urlretrieve

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


DATA_URL = (
    "https://zenodo.org/records/5196334/files/"
    "Lithium_Ion_Battery_Testing_Data.csv?download=1"
)
RAW_PATH = Path("data/raw/Lithium_Ion_Battery_Testing_Data.csv")


def canonicalize_text(text):
    text = str(text).strip().lower()
    replacements = {
        " ": "_",
        "-": "_",
        "/": "_per_",
        "(": "",
        ")": "",
        "[": "",
        "]": "",
        "%": "pct",
    }
    for old, new in replacements.items():
        text = text.replace(old, new)
    while "__" in text:
        text = text.replace("__", "_")
    return text.strip("_")


def download_if_needed():
    RAW_PATH.parent.mkdir(parents=True, exist_ok=True)
    if not RAW_PATH.exists():
        print(f"Downloading dataset to {RAW_PATH}")
        urlretrieve(DATA_URL, RAW_PATH)
    else:
        print(f"Using existing file at {RAW_PATH}")


def normalize_columns(dataframe):
    dataframe = dataframe.copy()
    dataframe.columns = [canonicalize_text(column) for column in dataframe.columns]

    rename_map = {}
    for column in dataframe.columns:
        if column == "bi":
            rename_map[column] = "segment_label"
        elif "current" in column and "charge" not in column:
            rename_map[column] = "current_a"
        elif "voltage" in column and "charge" not in column:
            rename_map[column] = "voltage_v"
        elif "soc" in column:
            rename_map[column] = "soc_pct"
        elif column in {"ta", "ambient_temperature", "ambient_temperature_c"}:
            rename_map[column] = "ambient_temperature_c"
        elif "time" in column and "temperature" not in column:
            rename_map[column] = "time_raw"

    return dataframe.rename(columns=rename_map)


def build_elapsed_time_seconds(dataframe):
    dataframe = dataframe.copy()

    if "time_raw" not in dataframe.columns:
        dataframe["elapsed_s"] = np.arange(len(dataframe), dtype=float)
        time_origin_description = "No explicit time column detected; using row index as pseudo-time."
        return dataframe, time_origin_description

    numeric_time = pd.to_numeric(dataframe["time_raw"], errors="coerce")
    if numeric_time.notna().mean() > 0.95:
        dataframe["elapsed_s"] = numeric_time - numeric_time.iloc[0]
        time_origin_description = "Detected numeric time column and shifted it to start at zero."
        return dataframe, time_origin_description

    datetime_time = pd.to_datetime(dataframe["time_raw"], errors="coerce")
    if datetime_time.notna().mean() > 0.95:
        dataframe["elapsed_s"] = (datetime_time - datetime_time.iloc[0]).dt.total_seconds()
        time_origin_description = "Detected datetime-like time column and converted to elapsed seconds."
        return dataframe, time_origin_description

    dataframe["elapsed_s"] = np.arange(len(dataframe), dtype=float)
    time_origin_description = (
        "Time column could not be parsed reliably; using row index as pseudo-time."
    )
    return dataframe, time_origin_description


download_if_needed()
raw_df = pd.read_csv(RAW_PATH)
clean_df = normalize_columns(raw_df)
clean_df, time_note = build_elapsed_time_seconds(clean_df)

for column in ["current_a", "voltage_v", "soc_pct", "ambient_temperature_c", "elapsed_s"]:
    if column in clean_df.columns:
        clean_df[column] = pd.to_numeric(clean_df[column], errors="coerce")

clean_df = clean_df.dropna(subset=["current_a", "voltage_v", "elapsed_s"]).copy()
clean_df = clean_df.sort_values("elapsed_s")
clean_df = clean_df.drop_duplicates(subset=["elapsed_s"])

time_index = pd.to_timedelta(clean_df["elapsed_s"], unit="s")
time_indexed_df = clean_df.set_index(time_index)

resampled_df = (
    time_indexed_df[["current_a", "voltage_v"]]
    .resample("10s")
    .mean()
    .interpolate(method="time")
)

print("Normalized columns:")
print(clean_df.columns.tolist())
print()
print("Time parsing note:")
print(time_note)
print()
print("First five cleaned rows:")
print(clean_df.head())
print()
print("Missing-value fraction after cleaning:")
print(clean_df[["current_a", "voltage_v"]].isna().mean())

fig, axes = plt.subplots(2, 1, figsize=(10, 7), sharex=True, constrained_layout=True)

axes[0].plot(
    resampled_df.index.total_seconds() / 3600.0,
    resampled_df["voltage_v"],
    color="tab:blue",
    linewidth=1.5,
)
axes[0].set_ylabel("Voltage [V]")
axes[0].set_title("Resampled public battery dataset trace")
axes[0].grid(True, alpha=0.3)

axes[1].plot(
    resampled_df.index.total_seconds() / 3600.0,
    resampled_df["current_a"],
    color="tab:orange",
    linewidth=1.5,
)
axes[1].set_xlabel("Elapsed time [h]")
axes[1].set_ylabel("Current [A]")
axes[1].grid(True, alpha=0.3)

plt.show()
```

### Walkthrough 3 code explanation

The `download_if_needed` helper exists because data acquisition should be explicit and idempotent. If the file is already present in `data/raw/`, the code reuses it. If not, it downloads it and stores it exactly as obtained. This is the same raw-versus-processed discipline introduced in Chapter 1.

`canonicalize_text` is a small but important utility. Public CSV files do not agree on whether a column will be named `Current`, `current`, `Current (A)`, `Current[A]`, or `current-a`. Normalizing once at the beginning is much safer than writing fragile downstream code that depends on one exact spelling.

`normalize_columns` then maps semantically similar names to a canonical set we actually want to work with: `current_a`, `voltage_v`, `soc_pct`, `ambient_temperature_c`, `segment_label`, and `time_raw`. This is one of the most reusable patterns in the whole manual. Later chapters will do the same thing for CALCE, NASA, Oxford, and other battery datasets that come with their own naming conventions.

`build_elapsed_time_seconds` is deliberately defensive. It first checks whether a time-like column exists. If not, it builds a pseudo-time from row order. If a time column exists, it tries numeric parsing first and datetime parsing second. This is realistic battery-data work. Very often you do not know ahead of time which representation a public file uses.

The numeric coercions with `errors="coerce"` convert malformed strings to `NaN` rather than raising an error immediately. This is usually the right first move in dataset cleaning because it lets you inspect how much of the file is affected before deciding what to drop.

`drop_duplicates(subset=["elapsed_s"])` prevents resampling from failing on repeated timestamps. Duplicate time values are common in exported instrument data and almost always need attention.

The resampling step uses `10s` bins and then `interpolate(method="time")`. This is a standard teaching choice. It produces a visually smoother trace and gives you a uniformly sampled signal for downstream work. It is also a methodological choice you should record in a real study, because resampling can alter fast transients if done carelessly.

The plotting choices deserve comment too. We use a two-panel figure rather than a dual-axis figure because current and voltage deserve their own y-axes and it is easier to read alignment across time that way. The colors are conventional and high-contrast. Grid lines are faint because they should support reading, not dominate the plot.

### Walkthrough 3 expected output

The first printed block should list normalized column names that include at least `current_a`, `voltage_v`, and `elapsed_s`. If the file headings match the paper description closely, you should also see `soc_pct`, `ambient_temperature_c`, and `segment_label`.

The time-parsing note will tell you which branch of the parser was used. If an explicit time column is present and parseable, you should see a message about shifting numeric time to start at zero or converting datetimes to elapsed seconds. If not, the parser will tell you it fell back to pseudo-time based on row order. That fallback is acceptable for quick visualization but should be logged as a limitation.

The `head()` output should show a tidy table rather than a messy raw import. Current and voltage should be numeric. If the dataset includes SOC, it should look like a percentage-like quantity rather than random text. Missing-value fractions for current and voltage should be zero after cleaning.

The figure should show a long voltage trace in the upper panel and a corresponding current trace in the lower panel. The current trace should have blocks corresponding to constant-power charging or discharging segments and near-zero intervals if rest periods are present. A wrong result usually reveals itself immediately: flat zero current everywhere, voltage values clearly outside plausible pack ranges, or a plot compressed into a vertical line because the time axis was parsed incorrectly.

### Walkthrough 3 troubleshooting

1. The file downloads but `pd.read_csv` fails with an encoding or delimiter issue  
   Symptom: a single giant column or unreadable characters.  
   Fix: inspect the raw file manually. If needed, pass an explicit delimiter or encoding. For this dataset the default comma-separated parse should work.

2. The time axis is nonsense  
   Symptom: elapsed time jumps backward or spans an absurd range.  
   Fix: print the raw time column before conversion. The file may store absolute time, elapsed time, or a format you need to parse differently.

3. Current and voltage columns are empty after coercion  
   Symptom: `NaN` fills the supposedly numeric columns.  
   Fix: the header mapping likely missed the correct source columns. Print `raw_df.columns.tolist()` and update the mapping logic.

4. Resampling smooths away important transitions  
   Symptom: sharp steps look suspiciously rounded.  
   Fix: reduce the resample interval or plot the raw cleaned signal alongside the resampled one. Resampling is a choice, not a law.

### Walkthrough 3 reflection

This exercise taught the battery-data workflow that documentation often skips: download, normalize, coerce, time-align, resample, and only then plot. We will keep this exact posture throughout the manual. In publishable work, careful parsing is not "preprocessing before the real research." It is part of the research.

## Guided Walkthrough 4: Fit a Second-Order RC Model to Synthetic Noisy Data

**Learning objective:** Generate synthetic voltage data from a known RC model, add realistic measurement noise, and recover the model parameters with `scipy.optimize.least_squares`.

This is the moment where forward simulation turns into inverse modeling. Parameter fitting is where many otherwise clean numerical workflows become fragile, because the optimizer will happily chase numerical artifacts, bad initial guesses, or structurally unidentifiable parameter combinations if you let it. We will therefore keep the problem controlled: known OCV function, known current profile, moderate noise, bounded parameters, and a model class that matches the data-generating model.

### Walkthrough 4 code

```python
from dataclasses import dataclass

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from scipy.optimize import least_squares


@dataclass(frozen=True)
class TheveninParameters:
    capacity_ah: float
    r0_ohm: float
    r1_ohm: float
    c1_f: float
    r2_ohm: float
    c2_f: float


def teaching_ocv_from_soc(soc_fraction):
    soc_fraction = np.clip(np.asarray(soc_fraction), 0.0, 1.0)
    return (
        2.85
        + 0.42 * soc_fraction
        + 0.06 * np.tanh((soc_fraction - 0.10) / 0.04)
        + 0.10 * np.tanh((soc_fraction - 0.88) / 0.05)
    )


TRUE_PARAMS = TheveninParameters(
    capacity_ah=3.2,
    r0_ohm=0.012,
    r1_ohm=0.009,
    c1_f=2200.0,
    r2_ohm=0.006,
    c2_f=22000.0,
)


profile_start_times_s = np.array([0, 200, 500, 800, 1100, 1400, 1800, 2200], dtype=float)
profile_currents_a = np.array([0.0, 2.5, 0.0, 5.0, 0.0, 3.5, 0.0, 1.5], dtype=float)
end_time_s = 2600.0
evaluation_times_s = np.linspace(0.0, end_time_s, 900)
initial_soc_fraction = 0.92


def current_profile_a(time_s):
    index = np.searchsorted(profile_start_times_s, time_s, side="right") - 1
    index = np.clip(index, 0, len(profile_currents_a) - 1)
    return float(profile_currents_a[index])


def simulate_thevenin(parameters):
    def rhs(time_s, state):
        soc_fraction, v_rc1_v, v_rc2_v = state
        current_a = current_profile_a(time_s)

        dsoc_dt = -current_a / (3600.0 * parameters.capacity_ah)
        dv_rc1_dt = -(v_rc1_v / (parameters.r1_ohm * parameters.c1_f)) + current_a / parameters.c1_f
        dv_rc2_dt = -(v_rc2_v / (parameters.r2_ohm * parameters.c2_f)) + current_a / parameters.c2_f
        return [dsoc_dt, dv_rc1_dt, dv_rc2_dt]

    solution = solve_ivp(
        fun=rhs,
        t_span=(0.0, end_time_s),
        y0=[initial_soc_fraction, 0.0, 0.0],
        t_eval=evaluation_times_s,
        method="BDF",
        rtol=1e-8,
        atol=1e-10,
    )

    current_trace_a = np.array([current_profile_a(t) for t in solution.t])
    voltage_trace_v = (
        teaching_ocv_from_soc(solution.y[0])
        - current_trace_a * parameters.r0_ohm
        - solution.y[1]
        - solution.y[2]
    )

    return solution.t, current_trace_a, solution.y[0], voltage_trace_v


rng = np.random.default_rng(seed=42)
time_s, current_a, soc_fraction, clean_voltage_v = simulate_thevenin(TRUE_PARAMS)
measured_voltage_v = clean_voltage_v + rng.normal(loc=0.0, scale=0.003, size=clean_voltage_v.shape)


def parameter_vector_to_dataclass(parameter_vector):
    return TheveninParameters(
        capacity_ah=3.2,
        r0_ohm=parameter_vector[0],
        r1_ohm=parameter_vector[1],
        c1_f=parameter_vector[2],
        r2_ohm=parameter_vector[3],
        c2_f=parameter_vector[4],
    )


def residuals(parameter_vector):
    parameters = parameter_vector_to_dataclass(parameter_vector)
    _, _, _, simulated_voltage_v = simulate_thevenin(parameters)
    return simulated_voltage_v - measured_voltage_v


initial_guess = np.array([0.020, 0.015, 1200.0, 0.012, 12000.0])
lower_bounds = np.array([0.001, 0.001, 200.0, 0.001, 2000.0])
upper_bounds = np.array([0.050, 0.050, 20000.0, 0.050, 80000.0])

fit_result = least_squares(
    fun=residuals,
    x0=initial_guess,
    bounds=(lower_bounds, upper_bounds),
    method="trf",
    verbose=1,
)

fitted_params = parameter_vector_to_dataclass(fit_result.x)
_, _, _, fitted_voltage_v = simulate_thevenin(fitted_params)

comparison_table = pd.DataFrame(
    {
        "parameter": ["R0 [ohm]", "R1 [ohm]", "C1 [F]", "R2 [ohm]", "C2 [F]"],
        "true_value": [
            TRUE_PARAMS.r0_ohm,
            TRUE_PARAMS.r1_ohm,
            TRUE_PARAMS.c1_f,
            TRUE_PARAMS.r2_ohm,
            TRUE_PARAMS.c2_f,
        ],
        "initial_guess": initial_guess,
        "fitted_value": fit_result.x,
    }
)
comparison_table["relative_error_pct"] = (
    100.0
    * (comparison_table["fitted_value"] - comparison_table["true_value"])
    / comparison_table["true_value"]
)

rmse_v = np.sqrt(np.mean((fitted_voltage_v - measured_voltage_v) ** 2))

print(comparison_table.round(4))
print()
print(f"Optimization success: {fit_result.success}")
print(f"Optimizer message   : {fit_result.message}")
print(f"Voltage RMSE        : {rmse_v:.6f} V")

fig, axes = plt.subplots(2, 1, figsize=(10, 7), sharex=True, constrained_layout=True)

axes[0].plot(time_s / 60.0, measured_voltage_v, label="Synthetic measurement", linewidth=1.2)
axes[0].plot(time_s / 60.0, fitted_voltage_v, label="Fitted model", linewidth=2.0)
axes[0].set_ylabel("Voltage [V]")
axes[0].set_title("Parameter identification for a second-order RC model")
axes[0].grid(True, alpha=0.3)
axes[0].legend()

axes[1].plot(time_s / 60.0, measured_voltage_v - fitted_voltage_v, color="tab:red", linewidth=1.0)
axes[1].axhline(0.0, color="black", linestyle="--", linewidth=1.0)
axes[1].set_xlabel("Time [min]")
axes[1].set_ylabel("Residual [V]")
axes[1].grid(True, alpha=0.3)

plt.show()
```

### Walkthrough 4 code explanation

The first half of the script is a forward simulator very similar to Walkthrough 2. That is deliberate. Parameter estimation should not require an entirely separate mental model. It should feel like "the same simulator, now embedded in an optimizer."

`TRUE_PARAMS` defines the hidden ground truth we want the optimizer to recover. We keep capacity fixed during fitting because one of the key lessons of parameter estimation is restraint. The more parameters you let float, the easier it becomes for the optimizer to trade one physical effect against another. In real experiments, fitting $Q_\mathrm{n}$, $R_0$, $R_1$, $C_1$, $R_2$, and $C_2$ all at once from one voltage trace is rarely a good first move.

The current profile includes multiple pulse amplitudes and rest intervals because identifiability improves when the excitation contains both fast and slow dynamic content. A constant-current trace alone often does not give enough information to separate two RC branches cleanly.

`rng = np.random.default_rng(seed=42)` makes the noisy data reproducible. That matters because otherwise every run would create a slightly different estimation problem, which makes learning harder and logging results messier.

The residual function returns `simulated_voltage_v - measured_voltage_v`, not the squared residuals. This is an important SciPy convention. `least_squares` wants the residual vector itself and takes care of the objective function internally.

The parameter bounds are not arbitrary. They encode physical plausibility and also stabilize the optimization numerically. Without bounds, the optimizer can temporarily explore absurd capacitance values or nearly zero resistances that make the problem harder to solve robustly. In real research, every bound should be justified in your notes or methods section.

The optimizer method `trf` is SciPy's trust-region reflective algorithm, a sensible default for bounded least-squares problems. The `verbose=1` option is pedagogically useful because it reminds you that fitting is an iterative process, not magic.

The residual plot is as important as the parameter table. A fit can have a low RMSE and still miss the pulse edges systematically. Looking at the residual as a function of time is how you catch that.

### Walkthrough 4 expected output

The comparison table should list the true values, the deliberately imperfect initial guesses, and the fitted values. Because the data are generated by the same model class being fitted, the recovered parameters should usually land close to the truth. With the noise level used here, you should expect `R0` to be recovered very accurately and the RC branch parameters to come back within a few to perhaps ten percent, depending on the random draw and solver details.

The script should print `Optimization success: True` and an optimizer message indicating termination because the gradient or cost reduction criterion was met. The voltage RMSE should be on the order of the noise level, roughly a few millivolts.

The upper plot should show the noisy synthetic measurement and the fitted model lying almost on top of each other. You should still be able to see small differences near the sharpest transitions because noise and parameter coupling make exact overlap unnecessary. The lower residual plot should oscillate around zero without long obvious drifts. A wrong result often looks like a good match in the flat parts and a bad mismatch at every pulse edge, which is a sign the branch time constants are wrong even if the global RMSE seems acceptable.

### Walkthrough 4 troubleshooting

1. The optimizer converges but the parameters are unphysical  
   Symptom: one resistance hits the upper bound and one capacitance hits the lower bound.  
   Fix: your initial guess or excitation profile may not be informative enough. Try a richer pulse sequence or fewer free parameters.

2. The fit fails with a solver error inside `least_squares`  
   Symptom: SciPy complains during some candidate evaluations.  
   Fix: tighten bounds so the optimizer does not explore numerically awkward regions.

3. RMSE is low but the residual plot has a visible structure  
   Symptom: the residual swings systematically at each pulse.  
   Fix: do not trust RMSE alone. This usually means the model class or fitted time constants are still wrong.

4. Parameter estimates vary every time you rerun the script  
   Symptom: different results each run.  
   Fix: set the random seed, as we did with `default_rng(seed=42)`.

### Walkthrough 4 reflection

This exercise taught the core idea of model calibration: a forward simulator wrapped in an optimizer. In Chapter 5 we will bring this idea into PyBaMM and discuss identifiability more seriously. For now, the important lesson is that fitting is not only about obtaining numbers. It is about checking whether the experiment, the model structure, and the residual pattern justify believing those numbers.

## Guided Walkthrough 5: Reproduction Exercise - Recreate Figure 10 from Foles et al. (2022)

**Learning objective:** Reproduce a published time-series figure from a public battery dataset, document the ambiguities, and decide what counts as "close enough."

This is the highest-value exercise in Part I because it forces all the earlier pieces to work together: parsing a public dataset, interpreting metadata, choosing a plotting strategy, and being explicit about what the paper does and does not specify. The target is Figure 10 from:

Ana Foles, Luís Fialho, Pedro Horta, and Manuel Collares-Pereira, "Validation of a lithium-ion commercial battery pack model using experimental data for stationary energy management application," *Open Research Europe*, 2022, DOI `10.12688/openreseurope.14301.2`.

The paper describes Figure 10 as "Lithium-ion battery voltage and current data from the experimental test plan, for complete charge-discharge cycles, at different constant power levels (due to readiness, only few power levels are represented)." The underlying dataset is the Zenodo CSV we used in Walkthrough 3. The figure caption does not list the exact selected power levels, which is the main ambiguity we need to handle honestly.

### Our reproduction choices

We need to make three explicit choices.

First, because the caption says only "a few power levels are represented," we will select three representative power levels directly from the `segment_label` text in the dataset: a low, medium, and high power level among those that appear frequently enough to plot cleanly.

Second, because public CSV exports can segment cycles unevenly, we will detect contiguous groups of identical `segment_label` values and then keep one representative contiguous segment for each selected power level.

Third, because exact figure aesthetics are rarely fully specified, we will aim to reproduce the figure's informational content rather than every cosmetic choice. "Close enough" here means the resulting figure should show complete charge-discharge voltage and current traces for multiple power levels, with the expected ordering in duration and magnitude: lower power produces longer cycles, higher power produces shorter cycles and larger current magnitude.

### Walkthrough 5 code

```python
from pathlib import Path
from urllib.request import urlretrieve

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


DATA_URL = (
    "https://zenodo.org/records/5196334/files/"
    "Lithium_Ion_Battery_Testing_Data.csv?download=1"
)
RAW_PATH = Path("data/raw/Lithium_Ion_Battery_Testing_Data.csv")


def canonicalize_text(text):
    text = str(text).strip().lower()
    for old, new in {
        " ": "_",
        "-": "_",
        "/": "_per_",
        "(": "",
        ")": "",
        "[": "",
        "]": "",
        "%": "pct",
    }.items():
        text = text.replace(old, new)
    while "__" in text:
        text = text.replace("__", "_")
    return text.strip("_")


def load_foles_dataset():
    RAW_PATH.parent.mkdir(parents=True, exist_ok=True)
    if not RAW_PATH.exists():
        urlretrieve(DATA_URL, RAW_PATH)

    dataframe = pd.read_csv(RAW_PATH)
    dataframe.columns = [canonicalize_text(column) for column in dataframe.columns]

    rename_map = {}
    for column in dataframe.columns:
        if column == "bi":
            rename_map[column] = "segment_label"
        elif "current" in column and "charge" not in column:
            rename_map[column] = "current_a"
        elif "voltage" in column and "charge" not in column:
            rename_map[column] = "voltage_v"
        elif "soc" in column:
            rename_map[column] = "soc_pct"
        elif column in {"ta", "ambient_temperature", "ambient_temperature_c"}:
            rename_map[column] = "ambient_temperature_c"
        elif "time" in column and "temperature" not in column:
            rename_map[column] = "time_raw"

    dataframe = dataframe.rename(columns=rename_map)

    for column in ["current_a", "voltage_v", "soc_pct"]:
        if column in dataframe.columns:
            dataframe[column] = pd.to_numeric(dataframe[column], errors="coerce")

    if "time_raw" in dataframe.columns:
        numeric_time = pd.to_numeric(dataframe["time_raw"], errors="coerce")
        if numeric_time.notna().mean() > 0.95:
            dataframe["elapsed_s"] = numeric_time - numeric_time.iloc[0]
        else:
            datetime_time = pd.to_datetime(dataframe["time_raw"], errors="coerce")
            if datetime_time.notna().mean() > 0.95:
                dataframe["elapsed_s"] = (datetime_time - datetime_time.iloc[0]).dt.total_seconds()
            else:
                dataframe["elapsed_s"] = np.arange(len(dataframe), dtype=float)
    else:
        dataframe["elapsed_s"] = np.arange(len(dataframe), dtype=float)

    dataframe["segment_label"] = dataframe.get("segment_label", pd.Series("", index=dataframe.index)).fillna("")
    dataframe = dataframe.dropna(subset=["current_a", "voltage_v", "elapsed_s"]).copy()
    dataframe = dataframe.sort_values("elapsed_s").reset_index(drop=True)

    return dataframe


df = load_foles_dataset()

df["segment_id"] = (df["segment_label"] != df["segment_label"].shift(fill_value="")).cumsum()
df["power_level_w"] = (
    df["segment_label"]
    .astype(str)
    .str.extract(r"(\d{3,4})", expand=False)
)
df["power_level_w"] = pd.to_numeric(df["power_level_w"], errors="coerce")

segment_summary = (
    df.groupby("segment_id")
    .agg(
        segment_label=("segment_label", "first"),
        power_level_w=("power_level_w", "first"),
        start_time_s=("elapsed_s", "first"),
        end_time_s=("elapsed_s", "last"),
        n_rows=("elapsed_s", "size"),
        mean_abs_current_a=("current_a", lambda x: np.mean(np.abs(x))),
    )
    .reset_index()
)
segment_summary["duration_s"] = segment_summary["end_time_s"] - segment_summary["start_time_s"]

usable_segments = segment_summary.dropna(subset=["power_level_w"]).copy()
usable_segments = usable_segments[usable_segments["duration_s"] > 0]
usable_segments = usable_segments.sort_values(["power_level_w", "duration_s"], ascending=[True, False])

available_levels = np.sort(usable_segments["power_level_w"].unique())
if len(available_levels) < 3:
    raise RuntimeError("Need at least three distinguishable power levels for the reproduction.")

selected_levels = np.array([
    available_levels[0],
    available_levels[len(available_levels) // 2],
    available_levels[-1],
])

selected_segment_rows = []
for level in selected_levels:
    representative_segment = usable_segments[usable_segments["power_level_w"] == level].iloc[0]
    selected_segment_rows.append(representative_segment)

selected_segments = pd.DataFrame(selected_segment_rows)
print("Selected representative power levels [W]:", selected_levels.tolist())
print(selected_segments[["segment_label", "power_level_w", "duration_s", "n_rows"]])


plot_frames = []
for _, row in selected_segments.iterrows():
    segment_df = df[df["segment_id"] == row["segment_id"]].copy()
    segment_df["segment_elapsed_h"] = (segment_df["elapsed_s"] - segment_df["elapsed_s"].iloc[0]) / 3600.0
    segment_df["power_level_w"] = row["power_level_w"]
    plot_frames.append(segment_df)

plot_df = pd.concat(plot_frames, ignore_index=True)

fig, axes = plt.subplots(2, 1, figsize=(10, 8), sharex=True, constrained_layout=True)

for level, one_level_df in plot_df.groupby("power_level_w", sort=True):
    axes[0].plot(
        one_level_df["segment_elapsed_h"],
        one_level_df["voltage_v"],
        linewidth=2.0,
        label=f"{int(level)} W",
    )
    axes[1].plot(
        one_level_df["segment_elapsed_h"],
        one_level_df["current_a"],
        linewidth=2.0,
        label=f"{int(level)} W",
    )

axes[0].set_ylabel("Voltage [V]")
axes[0].set_title("Reproduction of Foles et al. (2022) Figure 10 using the public CSV")
axes[0].grid(True, alpha=0.3)
axes[0].legend(title="Power level")

axes[1].set_xlabel("Elapsed time within representative segment [h]")
axes[1].set_ylabel("Current [A]")
axes[1].grid(True, alpha=0.3)

figure_path = Path("figures/chapter_2_reproduced_figure_10_foles.png")
figure_path.parent.mkdir(parents=True, exist_ok=True)
fig.savefig(figure_path, dpi=300)
print(f"Saved reproduction figure to: {figure_path}")

plt.show()
```

### Walkthrough 5 code explanation

The data-loading function repeats logic from Walkthrough 3 because every code block in this companion should be runnable independently. In your own repository, you would probably factor the shared loader into `src/data_loading.py`. In a teaching chapter, repetition is preferable to hidden dependencies.

`segment_id = (segment_label != segment_label.shift()).cumsum()` is a very useful Pandas idiom. It turns changes in a label column into contiguous segment identifiers. This lets us separate one block of constant-power operation from the next even if the same power level appears again later in the file.

`power_level_w` is extracted from text with a regular expression. This is a realistic compromise. The paper tells us the file contains legend text in `BI`, but it does not give us a perfectly normalized numeric power column. Instead of complaining, we mine the text responsibly.

The segment summary table computes duration, row count, and mean absolute current. These diagnostics help us filter out trivial or degenerate segments. We then sort by power level and duration and choose the longest representative segment for each selected power level.

The most important methodological line is the selection of `selected_levels` as low, middle, and high values from the available set. This is where we handle the paper's ambiguity explicitly. We are not pretending to know the exact hidden choice behind the published figure. We are making a principled, reproducible choice from the public data and stating it.

We plot voltage and current in stacked axes because Figure 10 is about both together. The x-axis is elapsed time within each representative segment, not global experiment time, because that makes multi-level comparison much clearer and is consistent with the paper's figure intent.

### Walkthrough 5 expected output

The printed table should list three selected representative segments with their power levels, durations, and row counts. The exact labels depend on the dataset, but you should see one relatively low power level, one midrange value, and one high value.

The reproduced figure should have two panels. In the upper panel, the three voltage traces should occupy similar voltage ranges but differ in duration and slope; higher power generally produces a faster traversal of the cycle. In the lower panel, current magnitudes should clearly differ by power level. Depending on the dataset's sign convention, discharge may appear as positive or negative current. What matters is consistency with the voltage evolution and the paper's narrative.

"Close enough" for this reproduction does not mean pixel-perfect overlay with the paper figure. It means:

1. The figure displays complete representative charge-discharge behavior for multiple constant power levels.
2. The relative ordering makes physical sense: lower power corresponds to longer duration, higher power to larger current magnitude.
3. The general visual story matches the published caption and surrounding text.

If your result satisfies those three conditions, you have performed a defensible reproduction. If it does not, the first place to investigate is not Matplotlib styling. It is segment selection and sign convention.

### Walkthrough 5 troubleshooting

1. No usable power levels are extracted  
   Symptom: `power_level_w` is all `NaN`.  
   Fix: inspect the raw `segment_label` strings. The numeric power value may be formatted differently from the regular expression we used.

2. The selected segment is too short or obviously incomplete  
   Symptom: the plotted curve looks like only a fragment of a cycle.  
   Fix: refine the segment filter using duration or row count and inspect the summary table manually.

3. Current sign appears "wrong" relative to your expectation  
   Symptom: discharge segments are negative when you expected positive, or vice versa.  
   Fix: do not force a sign change unless you can justify it. The goal is faithful reproduction, not aesthetic conformity.

4. Your reproduced figure does not visually resemble the published one  
   Symptom: wrong ordering, strange durations, or implausible voltage range.  
   Fix: revisit the ambiguity discussion. Figure reproduction is often mostly about data segmentation, not plotting syntax.

### Walkthrough 5 reflection

This exercise taught a publishable-research habit that is more important than people admit: when a paper is ambiguous, do not hide the ambiguity. State your interpretation, make it reproducible, and define what "close enough" means. That is the difference between a serious reproduction attempt and a screenshot imitation.

## Open-Ended Exercises

These are the first points in the chapter where you should stop copying and start adapting. Work them before reading the solutions.

### Exercise 1: Make the ODE problem more stiff

Modify Walkthrough 2 so that the fast RC branch becomes much faster and the slow branch becomes much slower. A good starting point is to reduce `C1` by a factor of 10 and increase `C2` by a factor of 5. Then compare `RK45`, `BDF`, and `LSODA` again.

Hints:

- Keep the current profile unchanged so the solver comparison is meaningful.
- Compare `nfev`, wall-clock time, and maximum voltage differences.
- Pay attention to whether one solver begins to take dramatically more function evaluations.

### Exercise 2: Fit the wrong model on purpose

Repeat Walkthrough 4, but fit a first-order RC model to data generated by the second-order model. In other words, allow only `R0`, `R1`, and `C1` to vary and remove the second RC branch from the fitted model.

Hints:

- Keep the same noisy synthetic measurements.
- Compare RMSE and the residual plot against the second-order fit.
- Ask which features of the residual reveal model inadequacy.

### Exercise 3: Flatten the OCV curve to mimic sodium-ion behavior

Replace `teaching_ocv_from_soc` with a flatter plateau-like function and rerun the synthetic fitting problem from Walkthrough 4. Keep the same current profile and noise level.

Hints:

- A plateau means $d\mathrm{OCV}/dz$ becomes small over a wide SOC range.
- Think about why that makes SOC-related effects harder to separate from RC transients.
- Compare how stable the fitted parameters look relative to the earlier case.

## Worked Solutions to Open-Ended Exercises

### Solution to Exercise 1

The code change is small, but the interpretation matters.

```python
import numpy as np
import pandas as pd
from scipy.integrate import solve_ivp


class Params:
    capacity_ah = 3.0
    r0_ohm = 0.015
    r1_ohm = 0.010
    c1_f = 180.0
    r2_ohm = 0.008
    c2_f = 90000.0


segment_start_times_s = np.array([0, 300, 900, 1200, 1500, 1800, 2400, 3000], dtype=float)
segment_currents_a = np.array([0.0, 3.0, 0.0, 6.0, 0.0, 4.5, 0.0, 1.5], dtype=float)


def ocv_from_soc(soc):
    soc = np.clip(np.asarray(soc), 0.0, 1.0)
    return 2.85 + 0.42 * soc + 0.06 * np.tanh((soc - 0.10) / 0.04) + 0.10 * np.tanh((soc - 0.88) / 0.05)


def current_profile_a(time_s):
    index = np.searchsorted(segment_start_times_s, time_s, side="right") - 1
    index = np.clip(index, 0, len(segment_currents_a) - 1)
    return float(segment_currents_a[index])


def rhs(time_s, state):
    soc, v1, v2 = state
    current_a = current_profile_a(time_s)
    return [
        -current_a / (3600.0 * Params.capacity_ah),
        -(v1 / (Params.r1_ohm * Params.c1_f)) + current_a / Params.c1_f,
        -(v2 / (Params.r2_ohm * Params.c2_f)) + current_a / Params.c2_f,
    ]


summary_rows = []
evaluation_times_s = np.linspace(0.0, 3600.0, 1201)

for method_name in ["RK45", "BDF", "LSODA"]:
    solution = solve_ivp(
        fun=rhs,
        t_span=(0.0, 3600.0),
        y0=[0.95, 0.0, 0.0],
        t_eval=evaluation_times_s,
        method=method_name,
        rtol=1e-8,
        atol=1e-10,
    )
    current_trace_a = np.array([current_profile_a(t) for t in solution.t])
    voltage_trace_v = ocv_from_soc(solution.y[0]) - current_trace_a * Params.r0_ohm - solution.y[1] - solution.y[2]
    summary_rows.append(
        {
            "method": method_name,
            "nfev": solution.nfev,
            "final_voltage_v": voltage_trace_v[-1],
        }
    )

print(pd.DataFrame(summary_rows))
```

You should find that `RK45` now takes noticeably more function evaluations than before, while `BDF` and often `LSODA` remain comparatively comfortable. That is the practical signal of increased stiffness. The model class did not change, only the separation in time scales.

### Solution to Exercise 2

Here we intentionally underfit the data with a model that is too simple.

```python
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from scipy.optimize import least_squares


def ocv_from_soc(soc):
    soc = np.clip(np.asarray(soc), 0.0, 1.0)
    return 2.85 + 0.42 * soc + 0.06 * np.tanh((soc - 0.10) / 0.04) + 0.10 * np.tanh((soc - 0.88) / 0.05)


profile_start_times_s = np.array([0, 200, 500, 800, 1100, 1400, 1800, 2200], dtype=float)
profile_currents_a = np.array([0.0, 2.5, 0.0, 5.0, 0.0, 3.5, 0.0, 1.5], dtype=float)
evaluation_times_s = np.linspace(0.0, 2600.0, 900)


def current_profile_a(time_s):
    index = np.searchsorted(profile_start_times_s, time_s, side="right") - 1
    index = np.clip(index, 0, len(profile_currents_a) - 1)
    return float(profile_currents_a[index])


def generate_second_order_truth():
    true_params = {"capacity_ah": 3.2, "r0": 0.012, "r1": 0.009, "c1": 2200.0, "r2": 0.006, "c2": 22000.0}

    def rhs(time_s, state):
        soc, v1, v2 = state
        current_a = current_profile_a(time_s)
        return [
            -current_a / (3600.0 * true_params["capacity_ah"]),
            -(v1 / (true_params["r1"] * true_params["c1"])) + current_a / true_params["c1"],
            -(v2 / (true_params["r2"] * true_params["c2"])) + current_a / true_params["c2"],
        ]

    solution = solve_ivp(rhs, (0.0, 2600.0), [0.92, 0.0, 0.0], t_eval=evaluation_times_s, method="BDF")
    current_trace_a = np.array([current_profile_a(t) for t in solution.t])
    voltage_trace_v = ocv_from_soc(solution.y[0]) - current_trace_a * true_params["r0"] - solution.y[1] - solution.y[2]
    return voltage_trace_v


rng = np.random.default_rng(42)
measured_voltage_v = generate_second_order_truth() + rng.normal(0.0, 0.003, size=evaluation_times_s.shape)


def simulate_first_order(parameter_vector):
    r0_ohm, r1_ohm, c1_f = parameter_vector

    def rhs(time_s, state):
        soc, v1 = state
        current_a = current_profile_a(time_s)
        return [
            -current_a / (3600.0 * 3.2),
            -(v1 / (r1_ohm * c1_f)) + current_a / c1_f,
        ]

    solution = solve_ivp(rhs, (0.0, 2600.0), [0.92, 0.0], t_eval=evaluation_times_s, method="BDF")
    current_trace_a = np.array([current_profile_a(t) for t in solution.t])
    voltage_trace_v = ocv_from_soc(solution.y[0]) - current_trace_a * r0_ohm - solution.y[1]
    return voltage_trace_v


def residuals(parameter_vector):
    return simulate_first_order(parameter_vector) - measured_voltage_v


fit_result = least_squares(
    residuals,
    x0=np.array([0.020, 0.012, 2000.0]),
    bounds=(np.array([0.001, 0.001, 100.0]), np.array([0.050, 0.050, 40000.0])),
)

fitted_voltage_v = simulate_first_order(fit_result.x)
residual_v = measured_voltage_v - fitted_voltage_v

print("Fitted parameters:", fit_result.x)
print("RMSE [V]:", np.sqrt(np.mean(residual_v ** 2)))

plt.figure(figsize=(9, 4.5))
plt.plot(evaluation_times_s / 60.0, residual_v, linewidth=1.0)
plt.axhline(0.0, color="black", linestyle="--", linewidth=1.0)
plt.xlabel("Time [min]")
plt.ylabel("Residual [V]")
plt.title("Residual from fitting a first-order model to second-order data")
plt.grid(True, alpha=0.3)
plt.show()
```

The important outcome is not just a higher RMSE. It is the residual structure. You should see systematic pulse-edge mismatch that the first-order model cannot eliminate. That is exactly the kind of evidence you need before claiming a model order is inadequate.

### Solution to Exercise 3

Here we flatten the OCV curve to mimic one of the practical difficulties of sodium-ion work.

```python
import numpy as np
from scipy.integrate import solve_ivp
from scipy.optimize import least_squares


def flat_plateau_ocv_from_soc(soc):
    soc = np.clip(np.asarray(soc), 0.0, 1.0)
    return 2.95 + 0.05 * soc + 0.025 * np.tanh((soc - 0.08) / 0.03) + 0.030 * np.tanh((soc - 0.92) / 0.03)


profile_start_times_s = np.array([0, 200, 500, 800, 1100, 1400, 1800, 2200], dtype=float)
profile_currents_a = np.array([0.0, 2.5, 0.0, 5.0, 0.0, 3.5, 0.0, 1.5], dtype=float)
evaluation_times_s = np.linspace(0.0, 2600.0, 900)


def current_profile_a(time_s):
    index = np.searchsorted(profile_start_times_s, time_s, side="right") - 1
    index = np.clip(index, 0, len(profile_currents_a) - 1)
    return float(profile_currents_a[index])


def simulate(parameter_vector):
    r0_ohm, r1_ohm, c1_f, r2_ohm, c2_f = parameter_vector

    def rhs(time_s, state):
        soc, v1, v2 = state
        current_a = current_profile_a(time_s)
        return [
            -current_a / (3600.0 * 3.2),
            -(v1 / (r1_ohm * c1_f)) + current_a / c1_f,
            -(v2 / (r2_ohm * c2_f)) + current_a / c2_f,
        ]

    solution = solve_ivp(rhs, (0.0, 2600.0), [0.92, 0.0, 0.0], t_eval=evaluation_times_s, method="BDF")
    current_trace_a = np.array([current_profile_a(t) for t in solution.t])
    return flat_plateau_ocv_from_soc(solution.y[0]) - current_trace_a * r0_ohm - solution.y[1] - solution.y[2]


true_parameters = np.array([0.012, 0.009, 2200.0, 0.006, 22000.0])
rng = np.random.default_rng(42)
measured_voltage_v = simulate(true_parameters) + rng.normal(0.0, 0.003, size=evaluation_times_s.shape)


fit_result = least_squares(
    fun=lambda p: simulate(p) - measured_voltage_v,
    x0=np.array([0.020, 0.015, 1200.0, 0.012, 12000.0]),
    bounds=(np.array([0.001, 0.001, 200.0, 0.001, 2000.0]), np.array([0.050, 0.050, 20000.0, 0.050, 80000.0])),
)

print("True parameters  :", true_parameters)
print("Fitted parameters:", np.round(fit_result.x, 6))
print("RMSE [V]         :", np.sqrt(np.mean((simulate(fit_result.x) - measured_voltage_v) ** 2)))
```

The typical outcome is that the optimizer still fits voltage reasonably well, but the recovered parameters become less stable or less interpretable. That is the qualitative lesson you should take forward into sodium-ion work: flatter OCV regions reduce the observability you get "for free" from voltage.

## What Changes for Sodium-Ion?

Up to this point, almost every skill in the chapter is chemistry-agnostic. Arrays, ODE solvers, least-squares fitting, Pandas cleaning, and figure construction do not care whether the active ion is lithium or sodium. But the interpretation of the outputs does change, and it changes in ways you should start internalizing now.

The first change is the OCV curve. Many sodium-ion chemistries, especially hard-carbon-based systems, exhibit flatter voltage plateaus over important SOC ranges than the textbook lithium-ion examples you may be used to. In numerical terms, that means $d\mathrm{OCV}/dz$ can be small over a broad interval. The practical consequence is that terminal voltage becomes less informative about SOC in those regions, and RC transients or sensor noise can dominate what you see. When you reach the fitting and state-estimation chapters later in the manual, that one chemistry fact will explain a large fraction of the extra difficulty.

The second change is parameter transferability. In this chapter we used a smooth teaching OCV function and synthetic RC parameters. In sodium-ion work, you should be much less willing to borrow lithium-ion OCV or resistance assumptions casually. The workflow of the chapter still applies, but the parameter values need stronger justification, and the sensitivity of the results to those values should be reported more explicitly.

The third change is dataset availability. Lithium-ion public datasets are abundant enough that we can afford to learn parsing on them. Sodium-ion public datasets are much sparser and often less standardized. That makes the data-cleaning habits from Walkthrough 3 even more important. In sodium-ion projects, you will often combine sparse public measurements, digitized figures, and simulation-generated synthetic data. The computational workflow stays the same; the provenance burden gets heavier.

The fourth change is validation strategy. For lithium-ion, it is often possible to find a public benchmark dataset that closely matches your modeling setup. For sodium-ion, you may need to validate at the level of qualitative behaviors, voltage-window consistency, rate sensitivity, or agreement with a published figure rather than against a rich open raw dataset. That does not lower the standard. It changes what honest validation looks like.

So the short version is this: the software patterns from this chapter transfer directly to sodium-ion, but the chemistry makes the inverse problems harder, the datasets thinner, and the need for explicit assumptions greater. Keep that in mind from the beginning rather than treating sodium-ion as "lithium-ion with renamed variables."

## Chapter Summary and Skill Checklist

The key skills from this chapter are the ones you should start to feel in your hands rather than merely remember abstractly.

- evaluate battery equations over entire grids with NumPy vectorization and broadcasting
- slice arrays deliberately to isolate physically meaningful windows
- write a state-vector ODE for a second-order Thevenin model
- choose among `RK45`, `BDF`, and `LSODA` with a reason rather than a guess
- inspect solver diagnostics instead of trusting a successful run blindly
- download and normalize a public battery dataset with Pandas
- infer a usable time axis and resample a battery time series
- fit model parameters with `scipy.optimize.least_squares`
- diagnose a fit with residual structure, not RMSE alone
- reproduce a published figure while documenting the ambiguities honestly

You should now be able to check all of the following:

- I can represent a battery equivalent-circuit model as a system of first-order ODEs.
- I can explain why SOC, RC overpotentials, and terminal voltage play different roles in the code.
- I can use broadcasting to evaluate terminal voltage for multiple current levels without nested loops.
- I can run `solve_ivp` and explain why one solver may be more appropriate than another.
- I can build a residual function and fit parameters with bounded least squares.
- I can clean a real battery CSV rather than only work with synthetic arrays.
- I can state my current sign convention explicitly instead of assuming it.
- I can reproduce a published time-series figure in a way that is transparent about interpretation choices.

If any box above still feels uncertain, revisit the corresponding walkthrough now. Later chapters assume these skills are already in muscle memory.

## Deliverable

The deliverable from your plan is a notebook that simulates a second-order RC equivalent-circuit discharge, adds noise, and fits the parameters back. The bonus deliverable is to wrap it as a reusable function.

Approach the deliverable in two layers.

First, create the notebook `notebooks/chapter_2_scientific_python_refresher.ipynb` and make sure it contains:

- a clean implementation of the second-order Thevenin forward model
- at least one pulse-rest current protocol
- a synthetic noisy voltage trace generated from known parameters
- a bounded least-squares fit recovering those parameters
- at least one residual plot and one parameter-comparison table

Second, factor the forward model into a reusable helper in `src/thevenin_model.py` or similar. A minimal but good reusable interface would be a function that accepts parameters, a current-profile function, initial SOC, and evaluation times and returns a `DataFrame` of time, current, SOC, branch voltages, and terminal voltage.

A strong submission for this chapter will also save:

- a CSV of the synthetic measurements in `results/`
- a CSV of fitted parameters in `results/`
- at least one figure in `figures/`
- a short log entry describing solver choice, fit behavior, and what you learned from the residuals

If you want a worked partial structure for the reusable function, this is a good starting signature:

```python
def simulate_thevenin(
    parameters,
    current_profile_a,
    evaluation_times_s,
    initial_soc_fraction,
    method="BDF",
):
    ...
```

The important design idea is to separate the model definition from the specific experiment. That habit will pay off immediately in Chapter 3 when PyBaMM starts making the same separation explicit at a much larger scale.

## Further Practice and Reading

- Ana Foles, Luís Fialho, Pedro Horta, and Manuel Collares-Pereira, "Validation of a lithium-ion commercial battery pack model using experimental data for stationary energy management application," *Open Research Europe* (2022). This is the paper used in the reproduction exercise and worth reading alongside the public CSV.
- G. L. Plett, *Battery Management Systems*, especially the equivalent-circuit modeling material. The mathematics there will feel different after doing the coding work in this chapter.
- SciPy official documentation for `scipy.integrate.solve_ivp` and `scipy.optimize.least_squares`. Bookmark both now; they will reappear throughout the manual.
- NumPy official documentation on broadcasting. This is one of the few docs pages that repays careful rereading.
- Matplotlib official tutorials on labeling, styles, and multi-axis layouts. Publication-quality plotting is learned by iteration, not by memorizing one magic function.
- Community resources: Scientific Python Forum and the PyData community spaces. Even before PyBaMM enters, these are useful homes for the numerical questions that battery research raises.

Lab Chapter 3: *Your First PyBaMM Simulation* is next.

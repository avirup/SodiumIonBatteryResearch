# Lab Chapter 3: Your First PyBaMM Simulation

## Chapter Opening

This chapter is the point where the theory textbook stops being something you understand and starts becoming something you can execute. Up to now, the Doyle-Fuller-Newman model has lived mostly in the language of conservation laws, porous-electrode assumptions, constitutive relations, and boundary conditions. By the end of this chapter, you will have turned that theory into a working PyBaMM workflow that you can run, modify, inspect, and defend. You will know how to build a lithium-ion battery model from PyBaMM's core objects, how to solve a default DFN simulation with a real parameter set, how to extract internal states instead of staring only at terminal voltage, and how to compare the DFN against reduced-order models in a way that is honest about both computational cost and modeling error.

This matters for publishable research because physics-based battery modeling is not only about deriving equations correctly. It is about being able to move from the equations to a trustworthy software implementation, ask the model targeted questions, and explain why a particular model fidelity is justified for a particular study. Reviewers do not care that you know the DFN model exists. They care whether your parameter set is traceable, whether your solver choices are sensible, whether your plotted internal states mean what you say they mean, and whether you are using a reduced model because it is appropriate rather than because you never learned how to run the full one.

Keep Textbook Chapter 8 open while you work through this lab. This chapter operationalizes the DFN model you learned there, so you want the derivation fresh in your mind. When we inspect electrolyte concentration gradients, solid-particle diffusion, interfacial overpotentials, and open-circuit voltage contributions, we are not learning new battery physics from scratch. We are learning how PyBaMM represents the same physics in software. Textbook Chapter 3 should also be nearby, because the distinction between open-circuit voltage, terminal voltage, overpotential, discharge capacity, C-rate, and state of charge needs to remain exact when we start reading variables out of a simulation object. Textbook Chapter 10 is worth keeping in the background as well, because one of the most important skills you will develop here is choosing an appropriate model fidelity. That same judgment call sits underneath every later BMS approximation, virtual-cell workflow, and parameter-estimation loop.

This chapter also depends directly on Labs 1 and 2. Lab Chapter 1 gave you the reproducible environment and project habits we now rely on. Lab Chapter 2 refreshed the scientific Python tools that sit underneath every modeling workflow in this companion. PyBaMM is not a replacement for those skills. It is a higher-level expression of them. If NumPy arrays, SciPy-style problem structure, and plotting logic still feel foggy, this chapter will become much harder than it needs to be.

There is one more reason this chapter matters for your long-term goal of sodium-ion research. Today we will use mostly lithium-ion parameter sets because PyBaMM's built-in ecosystem is much richer there. That is not a detour. It is training. Your future sodium-ion work will reuse the same software patterns: model construction, parameter management, solver choice, internal-variable inspection, fidelity comparison, and figure reproduction. What will change is the chemistry-specific content: different OCV shapes, different diffusivity functions, different parameter availability, and weaker public-data coverage. The software method is durable. We are learning that durable layer here.

The pace of the chapter is deliberate. First, we will install PyBaMM properly and verify that it really works. Next, we will build a conceptual bridge from the DFN derivation in the textbook to PyBaMM's object model. Then we will run a first DFN simulation with the `Chen2020` parameter set and interpret every major curve. After that, we will open the model up and inspect internal variables, because serious battery modeling begins when you stop treating voltage as the only truth. Then we will compare `SPM`, `SPMe`, and `DFN` on the same duty cycle and quantify the accuracy-speed tradeoff. Finally, because every Part of this companion must train reproduction skill, we will reproduce a published SPMe error-decomposition figure based on Marquis et al. (2019) and discuss exactly what "close enough" means when a modern software implementation is not numerically identical to the authors' original post-processing pipeline.

If you do this chapter carefully, PyBaMM stops being an intimidating package name and becomes a research instrument. That is the real milestone.

## Prerequisites Check

- Required software: the `sib-research` environment from Lab Chapter 1; `Python 3.11`; `JupyterLab 4.4+`
- Additional Python package for this chapter: `pybamm==25.12.1`
- Recommended plotting stack already installed from earlier chapters: `numpy==2.3.4`, `scipy==1.16.0`, `pandas==3.0.2`, `matplotlib==3.10.8`
- Required textbook chapters: Textbook Chapter 8 is essential; Textbook Chapter 3 should be close at hand; Textbook Chapter 10 is helpful context
- Required prior lab chapters: Lab Chapter 1 and Lab Chapter 2
- Estimated time: 10 to 14 hours if your install is smooth; 14 to 16 hours if this is your first real PyBaMM workflow

If Lab Chapter 2 still feels shaky, especially with plotting and numerical thinking, revisit Sections 2.2 through 2.6 before going deeper here. If your Jupyter kernel setup from Chapter 1 was never fully clean, fix it now. The most common PyBaMM beginner problem is not a bad model. It is running the right code in the wrong environment.

## Environment Setup

PyBaMM installs cleanly for most readers if the environment is already healthy. The key phrase there is "if the environment is already healthy." We will not assume that. We will verify each step.

### Step 1: Activate the Chapter 1 environment

If you used `conda` in Lab Chapter 1:

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

### Step 2: Install PyBaMM with a pinned version

For this manual we will pin to `pybamm==25.12.1`. The pin is not because older or newer versions are necessarily wrong. It is because beginner pain rises sharply when examples are written against one API and run against another.

Install PyBaMM with:

```bash
python -m pip install pybamm==25.12.1
```

If you prefer to make the version pin explicit in a requirements file for the repository, create `requirements-chapter-3.txt`:

```txt
pybamm==25.12.1
```

Then install it with:

```bash
python -m pip install -r requirements-chapter-3.txt
```

If you are using `conda`, do not overcomplicate this. A clean `conda` environment plus `pip install pybamm==25.12.1` is a perfectly normal workflow for PyBaMM.

### Step 3: Verify the install with a minimal "hello battery"

Run this exact snippet in a terminal or a fresh notebook cell:

```python
import pybamm
import numpy as np

# Build the default DFN with a bundled teaching parameter set.
model = pybamm.lithium_ion.DFN()
parameter_values = pybamm.ParameterValues("Chen2020")
simulation = pybamm.Simulation(model, parameter_values=parameter_values)

# Ask PyBaMM for output on a clean reporting grid.
evaluation_times_s = np.linspace(0, 600, 61)
solution = simulation.solve(evaluation_times_s)

# Evaluate the processed variable on the same time grid.
terminal_voltage_v = solution["Terminal voltage [V]"](evaluation_times_s)

print("PyBaMM version:", pybamm.__version__)
print("Initial voltage [V]:", round(float(terminal_voltage_v[0]), 4))
print("Voltage at 600 s [V]:", round(float(terminal_voltage_v[-1]), 4))
```

Expected output on the pinned version is:

```text
PyBaMM version: 25.12.1
Initial voltage [V]: 4.0377
Voltage at 600 s [V]: 3.8155
```

Do not obsess if the last digit differs by a few units in the fourth decimal place on a different machine. Do stop immediately if you get an import error, a solver failure, or a voltage that is nowhere near these values.

### Step 4: Confirm Jupyter sees the correct environment

Launch JupyterLab:

```bash
jupyter lab
```

Create a notebook named `notebooks/chapter_3_first_pybamm_simulation.ipynb`, then run:

```python
import sys
import pybamm

print(sys.executable)
print(pybamm.__version__)
```

The interpreter path should point into your intended environment, and the printed version should be `25.12.1`.

### Common install failures and fixes

1. `ModuleNotFoundError: No module named 'pybamm'`  
   Symptom: PyBaMM imports in the terminal fail, or they work in the terminal but not in Jupyter.  
   Fix: if both terminal and notebook fail, PyBaMM is not installed in the active environment. Re-activate the environment and reinstall. If the terminal works but Jupyter fails, re-register the kernel from the active environment with `python -m ipykernel install --user --name sib-research --display-name "Python (sib-research)"`.

2. Installation succeeds but import fails with a dependency error mentioning `casadi`, `scipy`, or a compiled wheel  
   Symptom: `pip` finishes, but `import pybamm` crashes immediately.  
   Fix: create a fresh environment instead of patching the broken one. Most PyBaMM import failures are environment-consistency problems, not package bugs.

3. Solver errors on the first run  
   Symptom: the package imports but the hello-world simulation fails.  
   Fix: first confirm you copied the code exactly. If you did, remove any local modifications to your environment and retry in a fresh environment. Beginner PyBaMM code should not fail on the built-in DFN plus `Chen2020`.

4. A notebook seems to "hang" while solving  
   Symptom: the cell runs longer than expected with no visible output.  
   Fix: wait a little longer first; the first import and solve can take longer on some systems. If it remains stalled, restart the kernel and run the small 600-second example before attempting anything larger.

## Conceptual Bridge: From Textbook DFN Equations to PyBaMM Objects

In Textbook Chapter 8, the Doyle-Fuller-Newman model appeared as a coupled system of equations for lithium concentration in the solid particles, lithium-ion concentration in the electrolyte, charge conservation in the solid phase, charge conservation in the electrolyte, interfacial reaction kinetics, and the constitutive laws that tie those fields together. In that presentation, the intellectual burden is on understanding the model. In PyBaMM, the burden shifts slightly: you still need to understand the model, but now you also need to understand how the software stores, processes, discretizes, and solves it.

At the theory level, the DFN model can be summarized very compactly. In the active-material particles we solve diffusion:

$$
\frac{\partial c_{s,k}}{\partial t}
= \frac{1}{r^2}\frac{\partial}{\partial r}\left(D_{s,k} r^2 \frac{\partial c_{s,k}}{\partial r}\right),
\qquad k \in \{n,p\},
\tag{1}
$$

while in the electrolyte we solve salt conservation:

$$
\varepsilon_k \frac{\partial c_{e,k}}{\partial t}
= -\nabla \cdot N_{e,k} + \frac{1-t_+^0}{F} a_k j_k,
\tag{2}
$$

and in the solid and electrolyte phases we enforce charge conservation:

$$
\nabla \cdot i_{s,k} = -a_k j_k,
\qquad
\nabla \cdot i_{e,k} = a_k j_k.
\tag{3}
$$

The interfacial current density $j_k$ is usually closed through Butler-Volmer kinetics, and the measured terminal voltage emerges from the difference between positive and negative current-collector potentials, corrected by the various losses and concentration effects. None of that changes in PyBaMM. What changes is the representation.

PyBaMM does not begin by "running a solver." It begins by building a symbolic model graph. When you write:

```python
model = pybamm.lithium_ion.DFN()
```

you are not yet solving anything. You are constructing a software object that contains the model equations, variables, submodels, events, boundary conditions, and metadata. You can think of `model` as the theory-textbook object translated into symbolic Python form.

The next critical object is the parameter set:

```python
parameter_values = pybamm.ParameterValues("Chen2020")
```

This is one of the most important conceptual habits to internalize early. In PyBaMM, the model and the parameter values are intentionally separate. That separation matters because it lets you ask a research question cleanly. Are you changing the governing equations, or are you changing only the chemistry and cell properties fed into those equations? If you blur those two ideas together, you will later make it much harder to report what you actually did.

After parameters, PyBaMM still has more work to do before anything becomes numerical. The geometry object defines where each field lives. The mesh object decides where those domains are sampled. The discretization object converts the symbolic PDE system into an algebraic-differential system the solver can handle. The solver then advances that discretized system in time. Finally, the `Simulation` object wraps the whole pipeline so that in normal use you do not need to manually call every processing step.

That object hierarchy is worth making explicit:

| PyBaMM object | What it represents conceptually | What you usually do with it |
| --- | --- | --- |
| `model` | The governing equations and variables | Choose `DFN`, `SPM`, `SPMe`, or another model |
| `ParameterValues` | Cell chemistry and numerical constants | Select or modify a parameter set |
| `geometry` | Domains and coordinates | Usually accept the model default at first |
| `mesh` | Spatial sampling of those domains | Adjust resolution when accuracy or speed matters |
| `discretisation` | Numerical translation of equations to algebraic form | Usually left implicit until you need control |
| `solver` | Time integration and nonlinear solves | Swap only when a problem demands it |
| `simulation` | A convenience wrapper over the full workflow | The main entry point for most users |

This is the software version of the bridge from theory to tool. Textbook Chapter 8 gave you the physics, assumptions, and derivation. PyBaMM gives you an organized representation of those same ingredients. If you ever feel lost in the library API, ask: which part of the mathematical model does this object correspond to?

There is a second conceptual bridge that matters just as much. In theory class, it is easy to talk about "the voltage" as if it were one simple number produced by the model. In PyBaMM, voltage is a composition of interpretable contributors. You can ask for terminal voltage, open-circuit voltage, reaction overpotentials, electrolyte ohmic losses, concentration overpotentials, and internal concentrations separately. This is not software trivia. It is the practical expression of the decomposition you learned in the textbook. When a simulation result looks odd, the first serious question is not "did the code work?" It is "which physical contribution is driving this shape?"

One more point is worth stating explicitly before we touch code. A `Simulation` object is convenient, but it can hide the layers underneath. That convenience is good for productivity, but bad for learning if you let it stay magical. In this chapter we will use `Simulation` heavily because that is the right tool for most work. But we will also open the box once so you see the manual pipeline. Later chapters on parameters, experiments, and reproducibility will make much more sense if you know what `Simulation` is saving you from having to do by hand.

So the mental map for the chapter is this: Textbook Chapter 8 tells you what the DFN is. PyBaMM tells you how to hold that DFN in software. The rest of the chapter is about learning to use that software representation without losing contact with the physics.

## Guided Walkthrough 1: Meet the PyBaMM Object Hierarchy

**Learning objective:** Instantiate a DFN model, inspect the objects underneath `Simulation`, and understand what PyBaMM is building before it solves anything.

We will start by making the object hierarchy concrete. Most PyBaMM tutorials quite reasonably jump straight to `Simulation`. For a first working notebook that is fine, but for a methods book it is too opaque. We will briefly look at both the high-level and low-level workflows so that later chapters do not feel magical.

### Walkthrough 1 code

```python
import numpy as np
import pybamm


# Create the symbolic model and attach a real parameterization.
model = pybamm.lithium_ion.DFN()
parameter_values = pybamm.ParameterValues("Chen2020")

print("PyBaMM version:", pybamm.__version__)
print("Model name:", model.name)
print("Default geometry domains:", list(model.default_geometry.keys()))
print("Default solver:", type(model.default_solver).__name__)
print("Nominal capacity [A.h]:", parameter_values["Nominal cell capacity [A.h]"])
print("Lower voltage cut-off [V]:", parameter_values["Lower voltage cut-off [V]"])
print("Upper voltage cut-off [V]:", parameter_values["Upper voltage cut-off [V]"])


geometry = model.default_geometry
parameter_values.process_model(model)
parameter_values.process_geometry(geometry)

# Keep the first teaching mesh intentionally modest.
var_pts = {
    "x_n": 10,
    "x_s": 10,
    "x_p": 10,
    "r_n": 10,
    "r_p": 10,
}

mesh = pybamm.Mesh(geometry, model.default_submesh_types, var_pts)
discretisation = pybamm.Discretisation(mesh, model.default_spatial_methods)
discretisation.process_model(model)

# Solve the discretized model directly, without the Simulation wrapper.
solver = model.default_solver
evaluation_times_s = np.linspace(0, 600, 51)
manual_solution = solver.solve(model, evaluation_times_s)

manual_voltage_v = manual_solution["Terminal voltage [V]"](evaluation_times_s)

print("Voltage at 600 s from the manual pipeline [V]:", round(float(manual_voltage_v[-1]), 4))
```

### Walkthrough 1 explanation

The first two lines create the core objects of the workflow. `pybamm.lithium_ion.DFN()` gives us the symbolic DFN model itself. `pybamm.ParameterValues("Chen2020")` selects a built-in lithium-ion parameter set associated with the LG M50 cell described in Chen et al. (2020). This is standard practice in teaching and benchmarking because it gives us a parameter set that is already internally consistent.

The next group of `print` statements is not throwaway code. We are making the object hierarchy visible. `model.name` confirms which model we instantiated. `model.default_geometry.keys()` shows the physical domains that the DFN spans: negative electrode, separator, positive electrode, negative particle, positive particle, and current collector. `model.default_solver` tells us which solver PyBaMM would use by default if we delegated the solve to `Simulation`. On the pinned version that solver is `IDAKLUSolver`, which is a good default for stiff battery-model systems.

The `process_model` and `process_geometry` calls are where parameters stop being abstract values in a dictionary and start being substituted into the symbolic model and geometry. This is the first point where the mathematical object becomes chemistry-specific.

The `var_pts` dictionary controls the mesh resolution. The meanings are worth committing to memory now: `x_n`, `x_s`, and `x_p` are through-thickness points in the negative electrode, separator, and positive electrode, while `r_n` and `r_p` are radial points in the negative and positive particles. If you reduce these values, the simulation becomes faster but less accurate. If you increase them, the reverse happens. Later chapters will reuse this exact pattern when we talk about mesh sensitivity and computational cost.

`pybamm.Mesh(...)` builds the mesh from the geometry and the default submesh types. `pybamm.Discretisation(...)` constructs the numerical machinery for turning symbolic PDEs into algebraic form. `discretisation.process_model(model)` is the point where the model becomes numerically solvable.

Only after those steps do we get to the solver. `solver.solve(model, evaluation_times_s)` numerically advances the discretized model over the requested time grid. The final two lines extract terminal voltage from the resulting solution and evaluate it at the grid we asked for.

### Walkthrough 1 expected output

On the pinned version you should see output of this form:

```text
PyBaMM version: 25.12.1
Model name: Doyle-Fuller-Newman model
Default geometry domains: ['negative electrode', 'separator', 'positive electrode', 'negative particle', 'positive particle', 'current collector']
Default solver: IDAKLUSolver
Nominal capacity [A.h]: 5.0
Lower voltage cut-off [V]: 2.5
Upper voltage cut-off [V]: 4.2
Voltage at 600 s from the manual pipeline [V]: 3.8171
```

The important thing is not memorizing the fourth decimal place. It is recognizing what the output proves. You have instantiated a DFN, attached a real parameter set, processed the geometry, created a mesh, discretized the model, and solved it directly through the lower-level API. That is the full theory-to-numerics chain in one short block of code.

### Walkthrough 1 troubleshooting

1. `KeyError` when accessing a parameter name  
   Symptom: one of the string keys in `parameter_values[...]` fails.  
   Fix: parameter names in PyBaMM are exact string keys. Copy them carefully. Later chapters will show safer ways to inspect and modify parameter sets.

2. A mesh-related error during `pybamm.Mesh(...)`  
   Symptom: PyBaMM complains about missing or incompatible variable-point definitions.  
   Fix: make sure the keys in `var_pts` are exactly `x_n`, `x_s`, `x_p`, `r_n`, and `r_p` for this model.

3. A solver error on the manual pipeline but not on the high-level `Simulation` workflow  
   Symptom: the low-level path feels brittle.  
   Fix: that is exactly why `Simulation` exists. The manual pipeline is for understanding and for specialized control, not because you should build every notebook this way.

### Walkthrough 1 reflection

This exercise teaches the first nontrivial PyBaMM habit: the library is not a black box that takes current in and voltage out. It is a structured numerical representation of the theory you learned in Textbook Chapter 8. That mindset will matter every time you later adjust parameters, experiments, meshes, or model fidelity.

## Guided Walkthrough 2: Run a Default DFN Simulation and Interpret the Big Curves

**Learning objective:** Solve a built-in DFN model with `Chen2020`, extract the major outputs, and interpret terminal voltage, discharge capacity, and approximate SOC correctly.

Now we will switch to the high-level workflow you will use most of the time. This is where PyBaMM becomes productive. The goal is not only to run the simulation, but to read it properly. A correct plot is not useful unless you know what it means physically.

### Walkthrough 2 code

```python
import numpy as np
import matplotlib.pyplot as plt
import pybamm


# The high-level Simulation object wraps the full PyBaMM pipeline.
model = pybamm.lithium_ion.DFN()
parameter_values = pybamm.ParameterValues("Chen2020")
simulation = pybamm.Simulation(model, parameter_values=parameter_values)

# Report on a clean one-hour grid.
evaluation_times_s = np.linspace(0, 3600, 361)
solution = simulation.solve(evaluation_times_s)

time_s = evaluation_times_s
time_min = time_s / 60.0

# Pull out the main variables we want to interpret.
terminal_voltage_v = solution["Terminal voltage [V]"](time_s)
open_circuit_voltage_v = solution["Battery open-circuit voltage [V]"](time_s)
discharge_capacity_ah = solution["Discharge capacity [A.h]"](time_s)
nominal_capacity_ah = parameter_values["Nominal cell capacity [A.h]"]
approximate_soc = 1.0 - discharge_capacity_ah / nominal_capacity_ah

print("Initial terminal voltage [V]:", round(float(terminal_voltage_v[0]), 4))
print("Terminal voltage at 3600 s [V]:", round(float(terminal_voltage_v[-1]), 4))
print("Discharge capacity after 3600 s [A.h]:", round(float(discharge_capacity_ah[-1]), 4))
print("Approximate SOC after 3600 s [-]:", round(float(approximate_soc[-1]), 4))


fig, axes = plt.subplots(3, 1, figsize=(9, 10), sharex=True, constrained_layout=True)

axes[0].plot(time_min, terminal_voltage_v, linewidth=2.2, label="Terminal voltage")
axes[0].plot(time_min, open_circuit_voltage_v, linewidth=1.8, linestyle="--", label="Battery OCV")
axes[0].set_ylabel("Voltage [V]")
axes[0].set_title("DFN discharge with the Chen2020 parameter set")
axes[0].legend()
axes[0].grid(True, alpha=0.3)

axes[1].plot(time_min, discharge_capacity_ah, color="tab:green", linewidth=2.2)
axes[1].set_ylabel("Discharge Capacity [A.h]")
axes[1].grid(True, alpha=0.3)

axes[2].plot(time_min, approximate_soc, color="tab:red", linewidth=2.2)
axes[2].set_ylabel("Approximate SOC [-]")
axes[2].set_xlabel("Time [min]")
axes[2].grid(True, alpha=0.3)

plt.show()
```

### Walkthrough 2 explanation

The first three lines are now familiar: instantiate the DFN, select a parameter set, and wrap the workflow in `Simulation`. This is the pattern you should expect to reuse constantly.

`evaluation_times_s = np.linspace(0, 3600, 361)` gives us a clean one-second-like reporting grid at ten-second spacing. PyBaMM may still use adaptive internal time stepping underneath, but this line tells the processed variables where we want the solution evaluated for plotting and downstream analysis.

`solution["Terminal voltage [V]"](time_s)` is the first PyBaMM pattern worth committing to muscle memory. A solution variable is not just a stored array. It is a processed variable that can be evaluated on the time grid you want, and later on spatial coordinates as well. This is one of the reasons PyBaMM feels more expressive than a hand-built ODE script.

We also extract `Battery open-circuit voltage [V]`. This is a very useful comparison curve because it separates equilibrium thermodynamics from dynamic losses. The gap between OCV and terminal voltage is not random. It is the accumulated effect of kinetic, ohmic, and concentration losses.

The `Discharge capacity [A.h]` variable is exactly what its name suggests: how much capacity has been drawn since the simulation began. We then compute an approximate SOC using

$$
\mathrm{SOC}_{\mathrm{approx}}(t)
= 1 - \frac{Q_{\mathrm{discharged}}(t)}{Q_{\mathrm{nominal}}}.
\tag{4}
$$

That approximation is fine for a first DFN walkthrough, but it is still an approximation. In later chapters and in real BMS work, SOC estimation becomes more subtle than discharged-capacity bookkeeping. I am flagging that now so you do not quietly internalize Equation (4) as a universal truth.

The plotting section deliberately puts the variables in separate axes rather than overloading one panel. For a research notebook, clarity beats compactness.

### Walkthrough 2 expected output

The printed values on the pinned version should be approximately:

```text
Initial terminal voltage [V]: 4.0377
Terminal voltage at 3600 s [V]: 2.9830
Discharge capacity after 3600 s [A.h]: 4.9381
Approximate SOC after 3600 s [-]: 0.0124
```

The first plot should show terminal voltage starting a little above `4.03 V` and declining steadily toward about `2.98 V` over the hour. The dashed OCV curve should sit above the terminal-voltage curve almost everywhere. That gap is physically meaningful: it is the sum of losses that appear only under load.

The second plot should be almost a straight line rising from `0` to just under `5 A.h`, because the default `Chen2020` setup is effectively a constant-current discharge over this interval.

The third plot should fall nearly linearly from `1` toward zero, ending just above zero rather than exactly at zero because the one-hour window is very close to, but not identical with, a complete nominal-capacity discharge for this particular model trajectory.

If your terminal-voltage curve is jagged, increases during discharge, or crosses above the OCV curve, something is wrong.

### Walkthrough 2 troubleshooting

1. `KeyError` for a variable name  
   Symptom: `solution["Battery open-circuit voltage [V]"]` or a similar lookup fails.  
   Fix: variable names are exact. Use the strings shown here exactly, including units.

2. Confusing terminal voltage with OCV  
   Symptom: you interpret the dashed curve as "what the battery is doing" and ignore the loaded terminal voltage.  
   Fix: remember Textbook Chapter 3. OCV is an equilibrium quantity. Terminal voltage is what a pack controller or experiment actually sees under load.

3. Misreading the approximate SOC  
   Symptom: you assume it is a model-provided ground truth SOC state.  
   Fix: in this walkthrough it is simply discharged capacity normalized by nominal capacity. That is fine for teaching, but it is not the last word on SOC.

### Walkthrough 2 reflection

This exercise teaches the basic rhythm of PyBaMM work: instantiate, solve, extract processed variables, and interpret them in physical language rather than just visually. We will reuse this pattern in every later PyBaMM chapter.

## Guided Walkthrough 3: Open the Cell and Inspect Internal Variables

**Learning objective:** Extract internal concentrations, overpotentials, and spatial profiles from the DFN so that the model stops being "a voltage generator" and becomes a physically interpretable virtual cell.

This is the most important conceptual move in the chapter. Terminal voltage is the public face of the model. Internal variables are where the research value lives. If you only ever read voltage, you are using a physics-based model like a fancier equivalent circuit.

### Walkthrough 3 code

```python
import numpy as np
import matplotlib.pyplot as plt
import pybamm


model = pybamm.lithium_ion.DFN()
parameter_values = pybamm.ParameterValues("Chen2020")
parameter_values.update({"Current function [A]": 5.0})

simulation = pybamm.Simulation(model, parameter_values=parameter_values)

# Stop halfway through the nominal discharge so internal states stay easy to read.
evaluation_times_s = np.linspace(0, 1800, 301)
solution = simulation.solve(evaluation_times_s)

time_min = evaluation_times_s / 60.0

terminal_voltage_v = solution["Terminal voltage [V]"](evaluation_times_s)
battery_ocv_v = solution["Battery open-circuit voltage [V]"](evaluation_times_s)
xavg_electrolyte_concentration = solution["X-averaged electrolyte concentration [mol.m-3]"](evaluation_times_s)
xavg_negative_surface_concentration = solution[
    "X-averaged negative particle surface concentration [mol.m-3]"
](evaluation_times_s)
xavg_positive_surface_concentration = solution[
    "X-averaged positive particle surface concentration [mol.m-3]"
](evaluation_times_s)
xavg_reaction_overpotential_v = solution["X-averaged battery reaction overpotential [V]"](evaluation_times_s)
xavg_concentration_overpotential_v = solution["X-averaged battery concentration overpotential [V]"](evaluation_times_s)


# Use the parameter-set geometry so our spatial coordinates are valid.
negative_electrode_thickness_m = parameter_values["Negative electrode thickness [m]"]
separator_thickness_m = parameter_values["Separator thickness [m]"]
positive_electrode_thickness_m = parameter_values["Positive electrode thickness [m]"]
negative_particle_radius_m = parameter_values["Negative particle radius [m]"]

cell_length_m = (
    negative_electrode_thickness_m
    + separator_thickness_m
    + positive_electrode_thickness_m
)

x_positions_m = np.linspace(0.0, cell_length_m, 200)
r_positions_m = np.linspace(0.0, negative_particle_radius_m, 150)

electrolyte_profile_start = solution["Electrolyte concentration [mol.m-3]"](x=x_positions_m, t=0.0)
electrolyte_profile_end = solution["Electrolyte concentration [mol.m-3]"](x=x_positions_m, t=1800.0)

# Radial concentration inside an x-averaged negative particle.
negative_particle_profile_start = solution[
    "X-averaged negative particle concentration [mol.m-3]"
](r=r_positions_m, t=0.0)
negative_particle_profile_end = solution[
    "X-averaged negative particle concentration [mol.m-3]"
](r=r_positions_m, t=1800.0)


fig, axes = plt.subplots(2, 2, figsize=(12, 9), constrained_layout=True)

axes[0, 0].plot(time_min, terminal_voltage_v, linewidth=2.2, label="Terminal voltage")
axes[0, 0].plot(time_min, battery_ocv_v, linewidth=1.8, linestyle="--", label="Battery OCV")
axes[0, 0].set_title("Voltage-level variables")
axes[0, 0].set_xlabel("Time [min]")
axes[0, 0].set_ylabel("Voltage [V]")
axes[0, 0].legend()
axes[0, 0].grid(True, alpha=0.3)

axes[0, 1].plot(
    time_min,
    xavg_electrolyte_concentration,
    linewidth=2.2,
    label="X-averaged electrolyte concentration",
)
axes[0, 1].plot(
    time_min,
    xavg_negative_surface_concentration,
    linewidth=2.0,
    label="Negative particle surface concentration",
)
axes[0, 1].plot(
    time_min,
    xavg_positive_surface_concentration,
    linewidth=2.0,
    label="Positive particle surface concentration",
)
axes[0, 1].set_title("Concentration-level variables")
axes[0, 1].set_xlabel("Time [min]")
axes[0, 1].set_ylabel("Concentration [mol.m$^{-3}$]")
axes[0, 1].legend()
axes[0, 1].grid(True, alpha=0.3)

axes[1, 0].plot(
    time_min,
    xavg_reaction_overpotential_v * 1000.0,
    linewidth=2.2,
    label="Reaction overpotential",
)
axes[1, 0].plot(
    time_min,
    xavg_concentration_overpotential_v * 1000.0,
    linewidth=2.2,
    label="Concentration overpotential",
)
axes[1, 0].set_title("Overpotential contributions")
axes[1, 0].set_xlabel("Time [min]")
axes[1, 0].set_ylabel("Overpotential [mV]")
axes[1, 0].legend()
axes[1, 0].grid(True, alpha=0.3)

axes[1, 1].plot(
    x_positions_m * 1e6,
    electrolyte_profile_start,
    linewidth=2.0,
    label="Electrolyte concentration at 0 min",
)
axes[1, 1].plot(
    x_positions_m * 1e6,
    electrolyte_profile_end,
    linewidth=2.0,
    label="Electrolyte concentration at 30 min",
)
axes[1, 1].set_title("Through-thickness electrolyte profile")
axes[1, 1].set_xlabel("Position through cell [µm]")
axes[1, 1].set_ylabel("Electrolyte Concentration [mol.m$^{-3}$]")
axes[1, 1].legend()
axes[1, 1].grid(True, alpha=0.3)

plt.show()


fig, ax = plt.subplots(figsize=(8, 5), constrained_layout=True)
ax.plot(
    r_positions_m * 1e6,
    negative_particle_profile_start,
    linewidth=2.0,
    label="Negative particle concentration at 0 min",
)
ax.plot(
    r_positions_m * 1e6,
    negative_particle_profile_end,
    linewidth=2.0,
    label="Negative particle concentration at 30 min",
)
ax.set_title("X-averaged negative-particle radial concentration profile")
ax.set_xlabel("Particle radius coordinate [µm]")
ax.set_ylabel("Concentration [mol.m$^{-3}$]")
ax.legend()
ax.grid(True, alpha=0.3)
plt.show()
```

### Walkthrough 3 explanation

We intentionally shorten the simulation window to `1800 s`, which is a half-hour at approximately `1C` for the nominal 5 Ah cell. That gives us a mid-discharge view where the model is still far from terminal cutoffs and the internal-state interpretation is cleaner.

The first group of variable extractions uses `X-averaged` quantities. This is an important PyBaMM naming pattern. When a quantity varies spatially, PyBaMM often provides both the full field and spatially averaged versions. For a first inspection, the averages are easier to interpret. Later, when you need to diagnose localization or gradients, you move to the full fields.

The overpotential variables are especially important. `X-averaged battery reaction overpotential [V]` captures kinetic losses associated with interfacial charge transfer. `X-averaged battery concentration overpotential [V]` captures the contribution of concentration nonuniformity to voltage loss. When the terminal voltage drops away from the OCV curve, these are two of the places to look.

The next block extracts actual spatial profiles. This is where PyBaMM begins to feel like a genuine virtual cell. We compute the total cell thickness from the negative electrode, separator, and positive electrode thicknesses. We then define a coordinate array `x_positions_m` spanning that thickness and evaluate `Electrolyte concentration [mol.m-3]` at the start and at thirty minutes. Because we pass both `x=` and `t=`, PyBaMM returns the field values on exactly the spatial slice we asked for.

The negative-particle radial profile is even closer to the theory textbook. `X-averaged negative particle concentration [mol.m-3]` is the radial diffusion field averaged across the negative electrode thickness. Evaluating it over `r_positions_m` at two times shows whether the particle interior and surface are diverging as diffusion struggles to keep up with intercalation or deintercalation.

### Walkthrough 3 expected output

The first figure should have four panels.

The top-left panel should show terminal voltage below the battery OCV, with the gap widening modestly as the discharge proceeds. If the two curves lie exactly on top of each other, something is wrong physically: a loaded cell should not have zero losses.

The top-right panel should show the x-averaged electrolyte concentration drifting away from its initial value of roughly `1000 mol.m^-3`, while the negative and positive particle surface concentrations move in opposite directions. Under discharge, lithium leaves the negative electrode and arrives at the positive, so the surface concentrations should reflect that directionality.

The bottom-left panel should show overpotentials in millivolts. The reaction overpotential should generally be the larger of the two over the first half hour, with the concentration overpotential present but smaller. The exact magnitudes depend on the parameter set and current, but they should be smooth, physically plausible curves rather than noisy oscillations.

The bottom-right panel should show the electrolyte concentration profile through the cell thickness. At `t = 0`, it should be nearly flat. At `t = 30 min`, it should have developed a gradient: higher in one region, lower in another, reflecting ionic transport and source terms through the layered structure.

The second figure should show the negative-particle radial concentration profile. At the start of discharge it should be fairly flat. After thirty minutes it should be steeper, with a visible gradient between the particle center and surface. That is the DFN's solid-phase diffusion physics made visible.

### Walkthrough 3 troubleshooting

1. `nan` values when evaluating a spatial profile  
   Symptom: the profile arrays are full of `nan`.  
   Fix: this usually means the coordinate values are outside the physical domain. Use the parameter-set geometry values, as we did here, instead of guessing coordinate ranges.

2. Confusing full fields with averaged fields  
   Symptom: you interpret an `X-averaged` quantity as though it described a local point.  
   Fix: PyBaMM variable names are intentionally descriptive. Read them literally. `X-averaged` means averaged through the cell thickness.

3. Overpotential units look too small or too large  
   Symptom: a curve appears to be only `0.01` units tall and feels meaningless.  
   Fix: remember the raw units are volts. For interpretability we multiplied them by `1000` to plot in millivolts.

### Walkthrough 3 reflection

This exercise teaches the real payoff of physics-based models. You are no longer limited to asking, "what voltage does the model predict?" You can ask which physical sub-process is responsible for the voltage behavior and inspect the corresponding internal state directly.

## Guided Walkthrough 4: Compare `SPM`, `SPMe`, and `DFN` on the Same Duty Cycle

**Learning objective:** Quantify the runtime-versus-fidelity tradeoff between `SPM`, `SPMe`, and `DFN` on a common current profile, and learn when each model is a defensible choice.

This is the modeling-judgment exercise of the chapter. Battery researchers often talk loosely about reduced-order models being "faster" or full-order models being "more accurate." Those statements are true but not useful until you quantify them on the same task. We will do that carefully.

To avoid event-trigger effects near voltage cutoffs, we will compare all three models over a fixed `1800 s` discharge at `5 A`, then evaluate every model on the same reporting grid. That produces a cleaner instructional comparison than allowing each model to stop at its own terminal-voltage event.

### Walkthrough 4 code

```python
import time
import numpy as np
import matplotlib.pyplot as plt
import pybamm


def run_model_on_common_grid(model_factory, current_a, evaluation_times_s):
    parameter_values = pybamm.ParameterValues("Chen2020")
    parameter_values.update({"Current function [A]": current_a})

    simulation = pybamm.Simulation(model_factory(), parameter_values=parameter_values)

    # Measure runtime in the same way for every model.
    start_time = time.perf_counter()
    solution = simulation.solve(evaluation_times_s)
    runtime_s = time.perf_counter() - start_time

    # Evaluate all models on the same reporting grid before comparison.
    terminal_voltage_v = solution["Terminal voltage [V]"](evaluation_times_s)

    return {
        "runtime_s": runtime_s,
        "terminal_voltage_v": terminal_voltage_v,
    }


evaluation_times_s = np.linspace(0.0, 1800.0, 301)
current_a = 5.0

model_factories = {
    "SPM": pybamm.lithium_ion.SPM,
    "SPMe": pybamm.lithium_ion.SPMe,
    "DFN": pybamm.lithium_ion.DFN,
}

results = {}
for model_name, model_factory in model_factories.items():
    results[model_name] = run_model_on_common_grid(
        model_factory=model_factory,
        current_a=current_a,
        evaluation_times_s=evaluation_times_s,
    )

dfn_voltage_v = results["DFN"]["terminal_voltage_v"]

# Compute every reduced model's error against the DFN baseline.
for model_name in ["SPM", "SPMe"]:
    rms_error_v = np.sqrt(
        np.mean((results[model_name]["terminal_voltage_v"] - dfn_voltage_v) ** 2)
    )
    results[model_name]["rms_error_mV_vs_DFN"] = 1000.0 * rms_error_v

results["DFN"]["rms_error_mV_vs_DFN"] = 0.0

for model_name, result in results.items():
    print(
        f"{model_name:4s} | runtime = {result['runtime_s']:.4f} s"
        f" | RMS error vs DFN = {result['rms_error_mV_vs_DFN']:.3f} mV"
    )


time_min = evaluation_times_s / 60.0

fig, axes = plt.subplots(1, 2, figsize=(12, 5), constrained_layout=True)

for model_name, result in results.items():
    axes[0].plot(
        time_min,
        result["terminal_voltage_v"],
        linewidth=2.2,
        label=model_name,
    )

axes[0].set_title("Voltage prediction by model fidelity")
axes[0].set_xlabel("Time [min]")
axes[0].set_ylabel("Terminal Voltage [V]")
axes[0].legend()
axes[0].grid(True, alpha=0.3)

bar_positions = np.arange(len(results))
runtime_values = [results[name]["runtime_s"] for name in ["SPM", "SPMe", "DFN"]]
error_values = [results[name]["rms_error_mV_vs_DFN"] for name in ["SPM", "SPMe", "DFN"]]

axes[1].bar(bar_positions - 0.18, runtime_values, width=0.36, label="Runtime [s]")
axes[1].bar(bar_positions + 0.18, error_values, width=0.36, label="RMS error [mV]")
axes[1].set_xticks(bar_positions)
axes[1].set_xticklabels(["SPM", "SPMe", "DFN"])
axes[1].set_title("Runtime versus DFN-relative error")
axes[1].legend()
axes[1].grid(True, alpha=0.3)

plt.show()
```

### Walkthrough 4 explanation

The helper function `run_model_on_common_grid` exists for one reason: it forces the comparison to be methodologically clean. Every model receives the same current and the same evaluation grid. The only thing that changes is the model fidelity.

Inside that helper, we update the `Chen2020` parameter set with a fixed current of `5 A`. That `update` pattern is the first one you should internalize for later parameter-study work. We are not editing PyBaMM source code. We are modifying a parameter object.

`time.perf_counter()` is a practical runtime-measurement tool. The absolute numbers you see will depend on your machine, operating system, and whether this is the first solve in a fresh kernel. The relative ordering is the part that matters scientifically.

After running all three models, we compute an RMS voltage error against the DFN:

$$
\mathrm{RMS}(m)
= \sqrt{\frac{1}{N}\sum_{i=1}^N\left(V_m(t_i) - V_{\mathrm{DFN}}(t_i)\right)^2}.
\tag{5}
$$

This is not the only possible accuracy metric, but it is a transparent and defensible first one. We express it in millivolts because that is the scale on which battery-model voltage differences become intuitively interpretable.

The two-panel figure then makes the tradeoff visible: the left plot shows voltage predictions themselves, while the right plot puts runtime and error side by side.

### Walkthrough 4 expected output

On the pinned version, a representative run is:

```text
SPM  | runtime = 0.2527 s | RMS error vs DFN = 54.177 mV
SPMe | runtime = 0.5038 s | RMS error vs DFN = 3.826 mV
DFN  | runtime = 1.3298 s | RMS error vs DFN = 0.000 mV
```

Your runtimes will vary, sometimes substantially, but the ordering should remain the same: `SPM` fastest, `DFN` slowest, `SPMe` in between. The accuracy trend should also be stable: `SPMe` should sit much closer to the DFN than the plain `SPM` on this moderate-rate discharge.

In the left plot, the `SPMe` voltage curve should be visually almost on top of the DFN curve, while the `SPM` should show a visibly larger deviation, especially as the discharge proceeds. In the right plot, the bars should make the core lesson obvious: the `SPMe` buys a large error reduction at a modest runtime penalty relative to `SPM`, while still remaining faster than the DFN.

### Walkthrough 4 interpreting the modeling choice

This is where we connect the software output back to research judgment.

Use `DFN` when internal-state fidelity matters, when you need mechanistic interpretation, when you are testing parameter sensitivity in a way that depends on electrolyte dynamics, or when you need a high-fidelity virtual cell to generate synthetic data for another workflow.

Use `SPMe` when you still care about electrolyte effects but need cheaper repeated solves. This is often the sweet spot for parameter studies, control-oriented simulation, and mid-fidelity research questions.

Use `SPM` when you need speed more than detailed fidelity and when the operating conditions are gentle enough that electrolyte limitations are not the dominant story. That last phrase matters. `SPM` is not "the beginner model." It is a deliberate approximation with a domain of validity.

### Walkthrough 4 troubleshooting

1. Treating runtime as a universal benchmark  
   Symptom: you compare your exact runtime numbers to a colleague's machine or to this chapter and overinterpret the difference.  
   Fix: use runtime comparatively within one environment, not as a universal hardware-independent truth.

2. Comparing models on different time grids  
   Symptom: you accidentally compare arrays with different sampling or different terminal events.  
   Fix: evaluate every model on a common reporting grid before computing an error metric.

3. Declaring the SPMe "always better" without qualification  
   Symptom: you learn the ranking from this example and generalize too far.  
   Fix: model choice depends on operating regime, chemistry, question, and acceptable error. This walkthrough is a benchmark, not a universal law.

### Walkthrough 4 reflection

This exercise teaches a habit that publishable work depends on: model fidelity should be chosen by evidence and task fit, not by prestige. The "best" battery model is the one that is accurate enough for the question while still practical enough for the workflow.

## Dataset Integration: Parsing a Public Battery Dataset Before Chapter 4

This chapter is primarily about your first PyBaMM simulation, not about full experiment scripting. That deeper workflow belongs in Chapter 4. But battery-modeling competence also requires comfort with public experimental data, so we will do one light but real dataset integration here.

We will use the **Oxford Energy Trading Battery Degradation Dataset**:

- Dataset landing page: `https://ora.ox.ac.uk/objects/uuid:9aae61af-2949-49f1-8ad5-6aea448979e5`
- DOI: `10.5287/bodleian:gJPdDzvP4`
- Example file for this chapter: `SPM_cell1_profileData.csv`
- File size: approximately `2.9 MB`
- Format: CSV without a header row
- License: ODC Open Database License (ODbL)

The Oxford `Readme.txt` explains that `SPM_cell1_profileData.csv` contains five columns:

1. profile time in seconds
2. current in amperes, with **negative meaning charging**
3. cell voltage in volts
4. cell surface temperature in degrees Celsius, where `0` means missing
5. ambient temperature in degrees Celsius, where `0` means missing

That sign convention is the first pitfall to notice. In many BMS and ECM contexts, discharge current is treated as positive. In this Oxford dataset, charging is negative. You must always decide whether to keep the native sign convention or map it to the one used in your model. For this chapter we will keep the dataset unchanged and only compute helper columns.

### Dataset parsing code

```python
from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


csv_path = Path("data/raw/SPM_cell1_profileData.csv")

# The Oxford file has no header row, so we assign names manually.
profile_df = pd.read_csv(
    csv_path,
    header=None,
    names=[
        "profile_time_s",
        "current_a",
        "voltage_v",
        "surface_temperature_c",
        "ambient_temperature_c",
    ],
)


# Convert missing temperatures encoded as zero into proper NaN values.
profile_df["surface_temperature_c"] = profile_df["surface_temperature_c"].replace(0, np.nan)
profile_df["ambient_temperature_c"] = profile_df["ambient_temperature_c"].replace(0, np.nan)
profile_df["profile_time_h"] = profile_df["profile_time_s"] / 3600.0
profile_df["discharge_current_a"] = -profile_df["current_a"]

print(profile_df.head())
print(profile_df.describe())


window_df = profile_df.iloc[:2000].copy()

fig, axes = plt.subplots(3, 1, figsize=(10, 9), sharex=True, constrained_layout=True)

axes[0].plot(window_df["profile_time_h"], window_df["current_a"], linewidth=1.5)
axes[0].set_ylabel("Current [A]")
axes[0].set_title("Oxford SPM cell profile data: first window")
axes[0].grid(True, alpha=0.3)

axes[1].plot(window_df["profile_time_h"], window_df["voltage_v"], linewidth=1.5, color="tab:orange")
axes[1].set_ylabel("Voltage [V]")
axes[1].grid(True, alpha=0.3)

axes[2].plot(
    window_df["profile_time_h"],
    window_df["surface_temperature_c"],
    linewidth=1.5,
    label="Surface temperature",
)
axes[2].plot(
    window_df["profile_time_h"],
    window_df["ambient_temperature_c"],
    linewidth=1.5,
    label="Ambient temperature",
)
axes[2].set_ylabel("Temperature [°C]")
axes[2].set_xlabel("Profile Time [h]")
axes[2].legend()
axes[2].grid(True, alpha=0.3)

plt.show()
```

### How to read the parsed data

The `header=None` argument matters because the file does not ship with column names. If you forget that, Pandas will quietly treat the first data row as a header and your whole dataset will shift.

Replacing zeros in the temperature columns with `NaN` is a small but important data-cleaning move. The Oxford readme explicitly states that `0` indicates a missing measurement, not a real `0 °C` environment. If you skip that replacement, later averages and plots become physically misleading.

`discharge_current_a = -current_a` does not alter the raw data. It creates a convenience column in the sign convention many battery models use. That is a good research habit. Preserve the raw field, add a translated field, and document the choice.

### Dataset parsing expected output

The `head()` output should show five raw numeric columns plus the helper columns we added. The plotted window should show a stepped current trace, a corresponding voltage trace constrained within the Kokam cell's operating window, and temperature curves that move much more slowly than current or voltage.

The important conceptual lesson is simple: real battery files arrive with conventions and quirks. Even before we drive a PyBaMM simulation with public profiles in Chapter 4, we need to be able to read the file, label the units, handle missing values correctly, and state the sign convention without hesitation.

## Guided Walkthrough 5: Reproduce a Published Figure from Marquis et al. (2019)

**Learning objective:** Reproduce the qualitative structure of a published SPMe-versus-DFN error-decomposition figure using PyBaMM's `Marquis2019` parameter set, while documenting the modeling choices and ambiguities honestly.

This is the highest-value exercise in the chapter. The paper is:

Scott G. Marquis, Valentin Sulzer, Robert Timms, Colin P. Please, and S. Jon Chapman, "An asymptotic derivation of a single particle model with electrolyte," *Journal of The Electrochemical Society*, 166(15), A3693-A3706, 2019. DOI: `10.1149/2.0341915jes`.

The target is **Figure 3** in the accepted manuscript hosted by the Oxford University Research Archive. In the paper, that figure shows component-wise voltage errors between the SPMe and the DFN during a `3C` discharge.

We need to be transparent about three facts before we begin.

First, PyBaMM now ships a built-in `Marquis2019` parameter set and a modern SPMe implementation, which is exactly what makes this exercise feasible on a laptop.

Second, the paper's notation for the voltage decomposition does not map one-to-one onto PyBaMM variable names in a way the authors spelled out as a modern notebook-ready script. So we must make a principled mapping.

Third, the paper terminated the comparison at `3.2 V`, while the bundled `Marquis2019` lower-voltage cutoff inside PyBaMM differs. We will therefore impose the paper's `3.2 V` cutoff explicitly in the experiment.

That is what honest reproduction looks like. We do not hide the ambiguities. We surface them and document the choices.

### The variable mapping we will use

This is an informed mapping from the paper's plotted components to PyBaMM variables:

| Paper notation | PyBaMM variable used here | Why this is a defensible mapping |
| --- | --- | --- |
| $\bar{U}_{eq}$ | `Battery open-circuit voltage [V]` | Represents the equilibrium open-circuit contribution |
| $\bar{\eta}_r$ | `X-averaged battery reaction overpotential [V]` | Represents kinetic charge-transfer losses |
| $\bar{\Delta \Phi}_{Elec}$ | `X-averaged battery electrolyte ohmic losses [V]` | Represents electrolyte-phase voltage drop |
| $\bar{\eta}_c$ | `X-averaged battery concentration overpotential [V]` | Represents concentration-driven voltage loss |

This mapping is an inference from the paper and PyBaMM's documented variable names. It is not a claim that we are using the authors' original private post-processing code line for line.

### Walkthrough 5 code

```python
import numpy as np
import matplotlib.pyplot as plt
import pybamm


parameter_values = pybamm.ParameterValues("Marquis2019")
electrode_area_m2 = (
    parameter_values["Electrode height [m]"] * parameter_values["Electrode width [m]"]
)

# Match the paper's comparison regime explicitly.
experiment = pybamm.Experiment(["Discharge at 3C until 3.2 V"])

models = {
    "SPMe": pybamm.lithium_ion.SPMe(),
    "DFN": pybamm.lithium_ion.DFN(),
}

component_variables = {
    "Battery OCV error": "Battery open-circuit voltage [V]",
    "Reaction overpotential error": "X-averaged battery reaction overpotential [V]",
    "Electrolyte ohmic error": "X-averaged battery electrolyte ohmic losses [V]",
    "Concentration overpotential error": "X-averaged battery concentration overpotential [V]",
}

results = {}

for model_name, model in models.items():
    simulation = pybamm.Simulation(
        model,
        parameter_values=pybamm.ParameterValues("Marquis2019"),
        experiment=experiment,
    )
    solution = simulation.solve()

    result = {
        "time_s": solution["Time [s]"].entries,
        "discharge_capacity_ah_per_m2": (
            solution["Discharge capacity [A.h]"].entries / electrode_area_m2
        ),
    }

    for label, variable_name in component_variables.items():
        result[label] = solution[variable_name].entries

    results[model_name] = result


# Align the comparison on a common time axis before subtraction.
common_time_s = np.linspace(
    0.0,
    min(results["SPMe"]["time_s"][-1], results["DFN"]["time_s"][-1]),
    400,
)

capacity_axis_ah_per_m2 = np.interp(
    common_time_s,
    results["DFN"]["time_s"],
    results["DFN"]["discharge_capacity_ah_per_m2"],
)

component_errors_v = {}

for label in component_variables:
    spme_component = np.interp(
        common_time_s,
        results["SPMe"]["time_s"],
        results["SPMe"][label],
    )
    dfn_component = np.interp(
        common_time_s,
        results["DFN"]["time_s"],
        results["DFN"][label],
    )
    component_errors_v[label] = spme_component - dfn_component
    print(
        label,
        "maximum absolute error [mV] =",
        round(float(np.max(np.abs(component_errors_v[label])) * 1000.0), 3),
    )


fig, ax = plt.subplots(figsize=(9, 5.5), constrained_layout=True)

for label, error_v in component_errors_v.items():
    ax.plot(
        capacity_axis_ah_per_m2,
        error_v * 1000.0,
        linewidth=2.0,
        label=label,
    )

ax.axhline(0.0, color="black", linewidth=0.8, alpha=0.5)
ax.set_xlabel("Discharge Capacity [A.h m$^{-2}$]")
ax.set_ylabel("SPMe - DFN component error [mV]")
ax.set_title("Reproduction of Marquis et al. (2019), Figure 3 structure")
ax.legend()
ax.grid(True, alpha=0.3)

plt.show()
```

### Walkthrough 5 explanation

We begin with `ParameterValues("Marquis2019")`, because PyBaMM includes a parameter set specifically tied to the Marquis SPMe work. That is exactly the kind of alignment you want when reproducing a paper: use the paper-linked parameterization when the tool makes it available.

The electrode area is important because the paper's x-axis is expressed in discharge capacity per unit area. PyBaMM gives us discharge capacity in ampere-hours, so we divide by the electrode area to match the paper's scale:

$$
Q_{\mathrm{area}} = \frac{Q_{\mathrm{discharged}}}{A_{\mathrm{electrode}}}.
\tag{6}
$$

We then define an explicit experiment: `Discharge at 3C until 3.2 V`. The reason to specify the voltage cutoff directly instead of relying on defaults is methodological honesty. The paper used `3.2 V`, and we want to follow that published choice.

For each model, we solve once and store two types of data: the discharge-capacity axis and the four voltage components we mapped from the paper notation.

Because the `SPMe` and `DFN` do not stop at exactly identical times, we create `common_time_s` and interpolate both solutions onto that shared interval. This matters. Comparing the raw arrays directly would be sloppy because the models do not report on identical internal time grids.

Finally, we subtract the DFN component from the SPMe component. The resulting curves are not the total voltage error; they are the component-wise differences underlying that total error.

### Walkthrough 5 expected output

On the pinned version, representative maximum absolute component errors are:

```text
Battery OCV error maximum absolute error [mV] = 8.29
Reaction overpotential error maximum absolute error [mV] = 8.666
Electrolyte ohmic error maximum absolute error [mV] = 5.212
Concentration overpotential error maximum absolute error [mV] = 4.0
```

The plot should show four error curves living close to zero over most of the discharge, then separating more noticeably as the discharge approaches its end. The exact magnitudes and line ordering may not match the paper pixel for pixel, but the qualitative story should: the SPMe tracks the DFN well through most of the discharge, and the component-level error grows as the system approaches the harder, end-of-discharge regime.

### Walkthrough 5 reproduction tolerance

This is the part many reproduction exercises fail to state clearly.

For this figure, "close enough" does **not** mean that every curve must match the published accepted-manuscript figure at the pixel level. We are using a modern PyBaMM implementation, modern defaults, and an inferred mapping between paper notation and exposed software variables. It is entirely reasonable for the exact magnitudes to differ.

For this figure, "close enough" means:

1. the same experiment definition is used
2. the same model pair is compared
3. the x-axis scaling is aligned with the paper
4. the qualitative trend is recovered: small component errors for most of the discharge and stronger divergence near the end
5. the methodological differences are written down, not hidden

That is a rigorous reproduction standard for a laptop-based methods chapter.

### Walkthrough 5 troubleshooting

1. You compare raw arrays without interpolation  
   Symptom: the subtraction fails or produces misleading results because the models stopped at different times.  
   Fix: always align the comparison axis first.

2. You use the `Chen2020` parameter set by habit  
   Symptom: the result no longer meaningfully targets the Marquis paper.  
   Fix: reproduction work should use the paper-linked parameterization whenever possible.

3. You claim exact quantitative agreement where you only have qualitative agreement  
   Symptom: the write-up sounds more certain than the method deserves.  
   Fix: be explicit about any inferred mapping or version drift. This is part of good research practice, not an admission of failure.

### Walkthrough 5 reflection

This exercise teaches reproduction as a research method rather than a classroom puzzle. You identified a target figure, matched the experiment definition, found a defensible parameter set, documented a variable-mapping choice, handled nonidentical solution grids correctly, and defined a reasonable success criterion. That is publishable-work behavior.

## Open-Ended Exercises

These exercises ask you to modify the guided code rather than merely rerun it. Try them before reading the worked solutions at the end of the chapter.

### Exercise 1: How does model ranking change with current?

Repeat Guided Walkthrough 4 for `2.5 A`, `5.0 A`, and `10.0 A`. Which model fidelity changes its error most dramatically as current increases? Does runtime change much relative to error?

Hints: keep the same comparison grid structure; put the current values in a loop; store RMS error versus DFN for each model and current.

### Exercise 2: How sensitive is the DFN to mesh resolution?

Using the low-level pipeline from Guided Walkthrough 1, compare a coarse mesh of `5` points per domain, the teaching mesh of `10` points per domain, and a finer mesh of `20` points per domain. Report the runtime and terminal voltage at `600 s`.

Hints: the only thing you need to change is `var_pts`; keep the model, parameters, and time grid the same; compare coarse and fine solutions against the `20`-point run.

### Exercise 3: What happens if you compare `Marquis2019` and `Chen2020` under the same model?

Run a `DFN` with `Chen2020` and a `DFN` with `Marquis2019` on the same nominal `1C` discharge for `1800 s`. Compare terminal voltage and x-averaged electrolyte concentration. What differences are due to chemistry and parameterization rather than model fidelity?

Hints: use the same code pattern as Guided Walkthrough 3; do not change the model, only the parameter set; remember that the two cells have different nominal capacities and geometry.

## Worked Solutions to the Open-Ended Exercises

### Solution to Exercise 1

```python
import time
import numpy as np
import pybamm


def compare_models_at_current(current_a):
    evaluation_times_s = np.linspace(0.0, 1800.0, 301)
    model_factories = {
        "SPM": pybamm.lithium_ion.SPM,
        "SPMe": pybamm.lithium_ion.SPMe,
        "DFN": pybamm.lithium_ion.DFN,
    }

    results = {}
    for model_name, model_factory in model_factories.items():
        parameter_values = pybamm.ParameterValues("Chen2020")
        parameter_values.update({"Current function [A]": current_a})
        simulation = pybamm.Simulation(model_factory(), parameter_values=parameter_values)

        start_time = time.perf_counter()
        solution = simulation.solve(evaluation_times_s)
        runtime_s = time.perf_counter() - start_time

        results[model_name] = {
            "runtime_s": runtime_s,
            "voltage_v": solution["Terminal voltage [V]"](evaluation_times_s),
        }

    dfn_voltage_v = results["DFN"]["voltage_v"]
    for model_name in ["SPM", "SPMe"]:
        rms_error_v = np.sqrt(np.mean((results[model_name]["voltage_v"] - dfn_voltage_v) ** 2))
        results[model_name]["rms_error_mV"] = 1000.0 * rms_error_v

    results["DFN"]["rms_error_mV"] = 0.0
    return results


for current_a in [2.5, 5.0, 10.0]:
    current_results = compare_models_at_current(current_a)
    print(f"\nCurrent = {current_a:.1f} A")
    for model_name in ["SPM", "SPMe", "DFN"]:
        print(
            f"{model_name:4s} | runtime = {current_results[model_name]['runtime_s']:.4f} s"
            f" | RMS error = {current_results[model_name]['rms_error_mV']:.3f} mV"
        )
```

What you should find is that the `SPM` error grows much faster with current than the `SPMe` error. That is the point. As electrolyte limitations become more important, the plain single-particle approximation loses accuracy faster than the electrolyte-aware reduced model does.

### Solution to Exercise 2

```python
import time
import numpy as np
import pybamm


def run_manual_dfn_with_mesh(points_per_domain):
    model = pybamm.lithium_ion.DFN()
    parameter_values = pybamm.ParameterValues("Chen2020")
    geometry = model.default_geometry

    parameter_values.process_model(model)
    parameter_values.process_geometry(geometry)

    var_pts = {
        "x_n": points_per_domain,
        "x_s": points_per_domain,
        "x_p": points_per_domain,
        "r_n": points_per_domain,
        "r_p": points_per_domain,
    }

    mesh = pybamm.Mesh(geometry, model.default_submesh_types, var_pts)
    discretisation = pybamm.Discretisation(mesh, model.default_spatial_methods)
    discretisation.process_model(model)

    solver = model.default_solver
    evaluation_times_s = np.linspace(0.0, 600.0, 51)

    start_time = time.perf_counter()
    solution = solver.solve(model, evaluation_times_s)
    runtime_s = time.perf_counter() - start_time

    terminal_voltage_v = solution["Terminal voltage [V]"](evaluation_times_s)
    return runtime_s, float(terminal_voltage_v[-1])


for points in [5, 10, 20]:
    runtime_s, final_voltage_v = run_manual_dfn_with_mesh(points)
    print(
        f"points per domain = {points:2d} | runtime = {runtime_s:.4f} s"
        f" | voltage at 600 s = {final_voltage_v:.4f} V"
    )
```

You should see the finer mesh take longer. The final voltage should converge rather than wander wildly. If it does wander wildly, that is a sign you either changed more than the mesh or ran into a setup mistake.

### Solution to Exercise 3

```python
import numpy as np
import matplotlib.pyplot as plt
import pybamm


evaluation_times_s = np.linspace(0.0, 1800.0, 301)
parameter_sets = ["Chen2020", "Marquis2019"]
results = {}

for parameter_set_name in parameter_sets:
    parameter_values = pybamm.ParameterValues(parameter_set_name)
    simulation = pybamm.Simulation(
        pybamm.lithium_ion.DFN(),
        parameter_values=parameter_values,
    )
    solution = simulation.solve(evaluation_times_s)

    results[parameter_set_name] = {
        "terminal_voltage_v": solution["Terminal voltage [V]"](evaluation_times_s),
        "xavg_electrolyte_concentration": solution[
            "X-averaged electrolyte concentration [mol.m-3]"
        ](evaluation_times_s),
    }


time_min = evaluation_times_s / 60.0

fig, axes = plt.subplots(2, 1, figsize=(9, 8), sharex=True, constrained_layout=True)

for parameter_set_name in parameter_sets:
    axes[0].plot(
        time_min,
        results[parameter_set_name]["terminal_voltage_v"],
        linewidth=2.0,
        label=parameter_set_name,
    )
    axes[1].plot(
        time_min,
        results[parameter_set_name]["xavg_electrolyte_concentration"],
        linewidth=2.0,
        label=parameter_set_name,
    )

axes[0].set_ylabel("Terminal Voltage [V]")
axes[0].set_title("Same DFN model, different parameter sets")
axes[0].legend()
axes[0].grid(True, alpha=0.3)

axes[1].set_ylabel("X-avg Electrolyte Concentration [mol.m$^{-3}$]")
axes[1].set_xlabel("Time [min]")
axes[1].legend()
axes[1].grid(True, alpha=0.3)

plt.show()
```

The main lesson is that "the model" is not the whole story. A DFN with one parameter set is not interchangeable with a DFN using another. Parameterization changes operating window, dynamic losses, concentration gradients, and therefore the interpretation of any later fitted or benchmarked result.

## What Changes for Sodium-Ion?

Early in the companion, this section is intentionally brief, but it matters.

The PyBaMM workflow itself changes very little for sodium-ion. The model object, the parameter-value pattern, the solve-extract-plot rhythm, and the fidelity comparison logic all transfer directly. What changes is the chemistry-specific content that fills those objects.

First, sodium-ion parameter sets are much sparser than lithium-ion parameter sets in the public PyBaMM ecosystem. That means you will often need to build or adapt your own `ParameterValues` object from literature rather than relying on a bundled cell.

Second, sodium-ion open-circuit curves, especially for hard-carbon negative electrodes, can be flatter and more structured than typical lithium-ion graphite curves. That affects both the interpretation of terminal-voltage differences and the difficulty of parameter estimation and state estimation later in the manual.

Third, validation is harder because public sodium-ion datasets are far thinner. In practice, you will often validate one part of a workflow against lithium-ion public data to test the method, then port the same method to sodium-ion with literature parameter values and more limited experimental references.

Fourth, low-temperature behavior and transport-property choices become more central sooner in sodium-ion studies. That means the distinction between `SPM`, `SPMe`, and `DFN` may matter differently depending on the sodium-ion question. Do not assume a ranking observed on a lithium-ion teaching benchmark transfers unchanged.

For now, the key lesson is this: Chapter 3 teaches the transferable software method. Later chapters will show how to swap in sodium-ion-specific assumptions honestly.

## Chapter Summary and Skill Checklist

- You installed and verified `pybamm==25.12.1` in a controlled research environment.
- You connected Textbook Chapter 8's DFN equations to PyBaMM's object hierarchy: model, parameters, geometry, mesh, discretization, solver, and simulation.
- You ran a default DFN simulation with the `Chen2020` parameter set and extracted terminal voltage, open-circuit voltage, discharge capacity, and approximate SOC.
- You inspected internal states including electrolyte concentration, particle concentration, and overpotential contributions.
- You compared `SPM`, `SPMe`, and `DFN` on a common current profile and quantified runtime versus DFN-relative voltage error.
- You parsed a public battery dataset and handled headerless columns, missing temperatures, and current-sign conventions correctly.
- You reproduced the structure of a published SPMe-versus-DFN figure from Marquis et al. (2019) while documenting the choices and ambiguities honestly.

The commands, functions, and patterns that should now be entering muscle memory are:

- `pybamm.lithium_ion.DFN()`
- `pybamm.lithium_ion.SPM()`
- `pybamm.lithium_ion.SPMe()`
- `pybamm.ParameterValues("Chen2020")`
- `parameter_values.update({...})`
- `pybamm.Simulation(...)`
- `solution["Variable name [units]"](time_grid)`
- spatial evaluation patterns such as `solution["Electrolyte concentration [mol.m-3]"](x=x_positions, t=1800.0)`
- clean benchmarking on a common reporting grid

You should now be able to answer "yes" to each of these:

- I can install PyBaMM in the environment built in Lab Chapter 1 and verify that it really works.
- I can explain the difference between a PyBaMM model object and a parameter set.
- I can run a DFN simulation without copying code blindly.
- I can extract internal variables rather than only terminal voltage.
- I can explain, with evidence, when `SPM`, `SPMe`, or `DFN` is the better choice for a given modeling task.
- I can reproduce a published figure honestly enough to document version drift and modeling choices instead of hiding them.

If any of those boxes are still unchecked, revisit the relevant walkthrough before moving into Chapter 4. Chapter 4 assumes this chapter feels natural.

## Deliverable

The deliverable for this chapter is:

> A notebook running all three model fidelities, comparing runtime and accuracy, with a written interpretation of when you'd choose which.

Approach it in three sections.

First, include a clean benchmark section that reproduces the `SPM` versus `SPMe` versus `DFN` comparison on a common time grid. Use the code pattern from Guided Walkthrough 4 and save both the voltage-comparison figure and the runtime-versus-error figure.

Second, include one internal-state section for the `DFN`, similar to Guided Walkthrough 3. At minimum, plot terminal voltage, x-averaged electrolyte concentration, and one particle-concentration profile. The point is to demonstrate that you understand what extra physical visibility the DFN buys you.

Third, write a short interpretation paragraph. It should not say only "`DFN` is most accurate." It should state when the extra fidelity is worth the runtime and when `SPMe` or `SPM` would be the better research choice.

A strong partial deliverable looks like this:

- one notebook file with all code cells runnable top to bottom
- one saved figure comparing voltage traces for the three fidelities
- one saved figure comparing runtime and RMS error
- one paragraph explaining which model you would use for parameter studies, which for synthetic-data generation, and which for quick exploratory sweeps

## Further Practice and Reading

1. PyBaMM documentation home: `https://docs.pybamm.org/en/stable/`  
   Bookmark this. It is the authoritative source for current PyBaMM APIs and notebooks.

2. PyBaMM parameter-set documentation: `https://docs.pybamm.org/en/stable/source/api/parameters/parameter_sets.html`  
   This is the page to revisit whenever you want to know what bundled parameter sets exist and how they are described.

3. Marquis et al. (2019), "An asymptotic derivation of a single particle model with electrolyte," DOI `10.1149/2.0341915jes`  
   This is the paper behind the SPMe reproduction exercise and one of the central references for reduced-order physics-based battery modeling.

4. Chen et al. (2020), "Development of Experimental Techniques for Parameterization of Multi-scale Lithium-ion Battery Models," DOI `10.1149/1945-7111/ab9050`  
   This is the reference behind the `Chen2020` parameter set used heavily in teaching and benchmarking.

5. Oxford Energy Trading Battery Degradation Dataset, DOI `10.5287/bodleian:gJPdDzvP4`  
   Keep this bookmarked. We only touched it lightly here, but Chapter 4 and later dataset-centric chapters will benefit from your early familiarity with its structure.

# Lab Chapter 5: Parameter Estimation in PyBaMM

## Chapter Opening

This chapter is where battery modeling becomes uncomfortable in the most productive possible way. Up to now, PyBaMM has let us run models, inspect variables, swap parameter sets, and impose realistic protocols. Parameter estimation asks a harder question: when the terminal voltage from a real or synthetic experiment does not match the model, which part of the model should move, by how much, and how honestly can we claim to have learned something physical? That question sits directly at the boundary between simulation fluency and publishable research competence.

Keep Textbook Chapter 8 open as you work. This chapter operationalizes the electrochemical model hierarchy you learned there, especially the way terminal voltage emerges from equilibrium potentials, transport losses, kinetic losses, and thermal effects rather than from one mysterious black-box transfer function. Keep Textbook Chapter 10 open as well. Its discussion of excitation richness, protocol design, and observability becomes concrete here. The central lesson of this lab is exactly the one hinted at in the theory text: a model parameter is only identifiable if the experiment excites the physics that parameter controls.

That is why parameter estimation is the hardest part of physics-based battery modeling. Writing down the DFN equations is difficult, but once the equations are fixed, the mathematics is at least well posed. Parameter estimation adds ambiguity. Many parameters push the voltage in similar directions. Some affect the response only weakly under a given protocol. Others are physically meaningful but numerically entangled. A beautiful fit can still be scientifically bad if it is obtained by letting the optimizer compensate for a poor protocol, a wrong chemistry, or a hidden preprocessing mistake.

This chapter teaches you to resist that trap. We will not pretend that a single current-voltage trace can recover the full DFN parameter set. That would be poor practice, and reviewers in this area know it. Instead, we will learn the workflow serious groups actually use on a laptop: start from a traceable literature parameter set, define a small subset of candidate parameters, screen them with sensitivities, fit only the parameters your data can plausibly inform, quantify uncertainty locally, and report the limitations clearly. That discipline is far more valuable than forcing an over-ambitious optimizer to return a table full of unjustified numbers.

The chapter moves in a deliberate sequence. First, we will bridge the theory of identifiability to PyBaMM's `InputParameter` and sensitivity machinery. Then we will rank candidate parameters by their effect on terminal voltage. After that, we will fit a two-parameter synthetic problem using `scipy.optimize.least_squares` and an analytic Jacobian obtained from PyBaMM sensitivities. Once that machinery is clear, we will wrap it into a reusable CSV-to-fit pipeline that reads current-voltage data, builds a forward model, estimates a small subset of parameters, and returns a fit report. We will then connect the workflow to a real public dataset using the Ecker discharge curves exposed through `pybamm.DataLoader`.

Part II already satisfied its formal reproduce-a-published-figure requirement in Chapter 3, but this chapter still includes a reproduction exercise because parameterization skill improves fastest when you work against a published target. We will reproduce, as carefully as the paper allows, the time-domain synthetic excitation illustrated in Figure 2 of Hallemans et al. (2024), *Physics-based battery model parametrisation from impedance data*. That paper's central message is directly relevant here: voltage-only fitting can be useful, but identifiability collapses quickly when the protocol is not informative enough. Reproducing that figure makes the warning concrete.

This chapter also matters for sodium-ion research more than it may appear at first glance. Today most public parameter sets, public validation traces, and polished PyBaMM examples are still richer on the lithium-ion side. That does not make this chapter a detour. It is training on the transferable part of the craft: defining candidate parameter subsets, screening them, fitting them responsibly, and documenting what the data cannot tell you. When you later move into sodium-ion work, the chemistry-specific content changes. The estimation discipline does not.

## Prerequisites Check

- Required software: the `sib-research` environment from Lab Chapter 1
- Required Python version: `Python 3.11+`
- Required Python packages: `pybamm==25.12.1`, `numpy`, `pandas`, `scipy`, `matplotlib`
- Optional exploratory package for the Bayesian detour: `pybop==26.3` in a separate sandbox environment
- Required textbook chapters: Textbook Chapter 8 is essential; Textbook Chapter 10 is essential; your sodium-ion chemistry chapter is recommended for the final comparison section
- Required prior lab chapters: Lab Chapters 1 through 4
- Estimated time: 14 to 18 hours if Chapter 4 felt comfortable; 18 to 22 hours if optimization and identifiability are new

If the PyBaMM object hierarchy from Sections 3.3 through 3.7 still feels shaky, revisit Chapter 3 before you start. If experiment construction and current-profile handling from Sections 4.3 through 4.6 felt brittle, revisit those too. This chapter assumes you can already build a simulation cleanly. Here we focus on deciding what to change inside that simulation and why.

## Environment Setup

We will keep the same PyBaMM pin used in Chapters 3 and 4 so the API, solver behavior, and data-loader examples remain consistent.

### Step 1: Activate your research environment

If you used `conda`:

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

### Step 2: Install the chapter dependencies

If Chapters 3 and 4 ran successfully, you may already have everything. If not, install the chapter stack explicitly:

```bash
python -m pip install pybamm==25.12.1 numpy pandas scipy matplotlib
```

If your shell exposes `python3` instead of `python`, use:

```bash
python3 -m pip install pybamm==25.12.1 numpy pandas scipy matplotlib
```

The optional Bayesian detour is easiest to keep isolated so it does not destabilize the base environment. If you want that extra section to be runnable later, create a second sandbox environment:

```bash
conda create -n pybop-sandbox python=3.11 -y
conda activate pybop-sandbox
python -m pip install pybop==26.3 pybamm==25.12.1
```

That separate environment is a teaching convenience. Standard practice in the field is to isolate inference tooling from the environment you use for your main production notebooks, because optimization packages and solver stacks evolve at different speeds.

### Step 3: Verify the install with a minimal sensitivity hello-world

Run this in a fresh notebook cell or terminal-backed Python session:

```python
import numpy as np
import pybamm


model = pybamm.BaseModel("sensitivity hello")
y = pybamm.Variable("y")
a = pybamm.InputParameter("a")

model.rhs = {y: a * y}
model.initial_conditions = {y: 1}
model.variables = {"y squared": y**2}

solver = pybamm.IDAKLUSolver(rtol=1e-10, atol=1e-10)
t_eval = np.linspace(0, 1, 11)

solution = solver.solve(
    model,
    t_eval,
    inputs={"a": 1.0},
    calculate_sensitivities=True,
)

print("PyBaMM version:", pybamm.__version__)
print("Last value of y^2:", round(float(solution["y squared"].data[-1]), 6))
print(
    "Last sensitivity d(y^2)/da:",
    round(float(solution["y squared"].sensitivities["a"][-1]), 6),
)
```

Expected output is close to:

```text
PyBaMM version: 25.12.1
Last value of y^2: 7.389056
Last sensitivity d(y^2)/da: 14.778112
```

Those numbers matter. The value $7.389056$ is approximately $e^2$, because $y(t)=e^t$ when $a=1$ and $y^2=e^{2t}$. The sensitivity is approximately $2e^2$, which is exactly what you want. This tiny check proves three things at once: PyBaMM imports correctly, the IDAKLU solver is available, and sensitivity propagation is working.

### Step 4: Confirm Jupyter is using the intended interpreter

Launch Jupyter:

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

The executable should point into your intended environment, and the version should print `25.12.1`.

### Common install failures and fixes

1. `ModuleNotFoundError: No module named 'pybamm'`  
   Symptom: terminal and notebook both fail on `import pybamm`.  
   Fix: the package is not installed in the active environment. Re-activate the environment and reinstall.

2. `import pybamm` works in the terminal but fails in Jupyter  
   Symptom: the notebook kernel is attached to another interpreter.  
   Fix: register the active environment as a kernel, then switch the notebook to that kernel.

3. `AttributeError` or missing-method errors around sensitivities  
   Symptom: code from this chapter fails on `calculate_sensitivities` or `InputParameter`.  
   Fix: you are likely on the wrong PyBaMM release. Reinstall the exact pin `pybamm==25.12.1`.

4. The first DFN sensitivity solve takes longer than expected  
   Symptom: a cell appears to hang on the first call.  
   Fix: wait a little. The first processed model build is often slower than later solves. If later solves are also extremely slow, lower `t_eval` density before assuming something is broken.

## Conceptual Bridge: From Textbook Identifiability to PyBaMM Input Parameters

In Textbook Chapter 8, the model was the star. You learned how concentration fields, potentials, kinetics, and transport combine to produce voltage. In this chapter, the model is no longer the only object on stage. We care about a second layer: the inverse problem. Given current and voltage data, what can we say about the parameters inside the model?

Mathematically, the forward model is a map from an input current history $i(t)$ and a parameter vector $\theta$ to a voltage response:

$$
v(t) = \mathcal{F}_{\theta}\{i(t)\}.
\tag{1}
$$

Equation (1) is the compact version of everything you learned in the theory text. The inverse problem turns it around. We have measured or synthetic voltage data $v_{\mathrm{data}}(t_n)$ at sample times $t_n$, and we try to find parameter values that make the model output match those data. In the simplest least-squares form,

$$
\hat{\theta}
=
\arg \min_{\theta}
\sum_{n=0}^{N-1}
\left(
v_{\mathrm{model}}(t_n; \theta)
-
v_{\mathrm{data}}(t_n)
\right)^2.
\tag{2}
$$

Equation (2) is easy to write and dangerously easy to misuse. It tempts beginners into believing that if the optimizer converges, the parameters must have been identified. That is false. A low residual means only that some parameter combination matched the chosen data under the chosen preprocessing and model assumptions. It does not mean each parameter is individually observable, nor that the recovered values are unique, nor that the fitted parameters will transfer to another protocol.

This is where identifiability enters. A parameter is informative under a dataset only if changing it changes the measured output in a distinguishable way. Local sensitivity is the first practical tool for asking that question:

$$
S_j(t) = \frac{\partial v(t; \theta)}{\partial \theta_j}.
\tag{3}
$$

If $S_j(t)$ is tiny across the entire experiment, the data barely react to parameter $\theta_j$. If two parameters have nearly collinear sensitivity curves, the optimizer may trade one against the other with little penalty. That is the software expression of what Textbook Chapter 10 described physically: a protocol must excite the physics you want to estimate.

PyBaMM represents this inverse-problem structure very cleanly. A parameter that you want to vary efficiently across many solves can be replaced with an `InputParameter`. In practice, that means taking a normally fixed quantity such as `"Current function [A]"` or `"Ambient temperature [K]"` and marking it as `[input]` inside the parameter set. PyBaMM then processes the model once and lets you supply different numeric values at solve time without rebuilding the whole symbolic system. That distinction matters a lot in optimization loops.

The mental mapping is:

| Inverse-problem idea | PyBaMM object or pattern | Why it matters |
| --- | --- | --- |
| Candidate fitted parameter | `"[input]"` inside `ParameterValues.update(...)` | Lets one processed model be reused across many solves |
| Synthetic or measured data | NumPy arrays or Pandas columns | These become the target in the residual function |
| Residual vector | `model_output - measured_output` | This is what `scipy.optimize.least_squares` minimizes |
| Sensitivity matrix | `solution["variable"].sensitivities[...]` | Provides local derivative information for ranking and Jacobians |
| Experimental design | `Experiment` or `Interpolant` current profile | Determines whether the data are informative at all |

There are three habits worth internalizing before we touch code.

First, fitting a small subset of parameters around a literature baseline is standard practice. Trying to identify the entire DFN parameter set from one voltage trace is not. The full parameter space is too large, too correlated, and too weakly excited for that to be defensible.

Second, a low residual is not the same as physical truth. If you let the optimizer adjust a parameter the experiment does not meaningfully excite, it may still return a number. That number is often just compensating for some other mismatch. Good parameter-estimation work is therefore as much about excluding unjustified parameters as it is about recovering justified ones.

Third, sensitivity information is local. When PyBaMM gives you $\partial v / \partial \theta_j$, it is telling you what happens near the current baseline parameter set. That is exactly what we need for screening candidate parameters and building efficient local Jacobians, but it is not a global guarantee that the entire parameter landscape is well behaved.

So the bridge from theory to tool is this. Textbook Chapter 8 taught you what the DFN and SPMe mean physically. Textbook Chapter 10 taught you that protocol richness controls observability. PyBaMM now gives you software objects that turn those ideas into a practical workflow: define a small candidate set, screen it with sensitivities, fit only what the data can support, and report the uncertainty honestly.

## Guided Walkthrough 1: Screening Candidate Parameters with Sensitivities

**Learning objective:** Use PyBaMM's built-in sensitivity machinery to rank candidate parameters before you fit anything.

The most expensive mistake in parameter estimation is running an optimizer before you know whether the experiment can distinguish your candidate parameters at all. In this walkthrough, we will build a DFN model with four candidate inputs, simulate a moderate 5 A discharge, compute terminal-voltage sensitivities, normalize them, and rank the parameters by how strongly they affect the output.

This is the first place where PyBaMM stops being just a simulator and becomes an estimation tool. We are not yet fitting data. We are asking a smarter preliminary question: if terminal voltage is all we measure, which parameters are worth fitting under this protocol?

### Walkthrough 1 code

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import pybamm


# Use a thermally coupled DFN so temperature-related parameters matter.
model = pybamm.lithium_ion.DFN(options={"thermal": "lumped"})

# Start from a published baseline chemistry.
parameter_values = pybamm.ParameterValues("Chen2020")

# Choose a small candidate set of scalar parameters that PyBaMM can treat as inputs.
# These are not the only possible choices. They are a teaching subset with distinct physics.
candidate_parameters = {
    "Current function [A]": 5.0,
    "Ambient temperature [K]": 298.15,
    "Initial concentration in electrolyte [mol.m-3]": 1000.0,
    "Total heat transfer coefficient [W.m-2.K-1]": 10.0,
}

parameter_values.update(
    {parameter_name: "[input]" for parameter_name in candidate_parameters}
)

solver = pybamm.IDAKLUSolver(rtol=1e-3, atol=1e-5)
simulation = pybamm.Simulation(
    model,
    parameter_values=parameter_values,
    solver=solver,
)

t_eval = np.linspace(0, 1200, 61)

solution = simulation.solve(
    [0, 1200],
    t_interp=t_eval,
    inputs=candidate_parameters,
    calculate_sensitivities=True,
)

terminal_voltage = solution["Terminal voltage [V]"].data

relative_sensitivities = {}
for parameter_name, baseline_value in candidate_parameters.items():
    raw_sensitivity = solution["Terminal voltage [V]"].sensitivities[parameter_name]
    relative_sensitivity = (
        baseline_value
        * raw_sensitivity
        / np.maximum(np.abs(terminal_voltage), 1e-6)
    )
    relative_sensitivities[parameter_name] = relative_sensitivity

# Rank the parameters by RMS relative sensitivity.
ranking_rows = []
for parameter_name, sensitivity_curve in relative_sensitivities.items():
    rms_score = np.sqrt(np.mean(sensitivity_curve**2))
    peak_score = np.max(np.abs(sensitivity_curve))
    ranking_rows.append(
        {
            "parameter": parameter_name,
            "rms_relative_sensitivity": rms_score,
            "peak_absolute_relative_sensitivity": peak_score,
        }
    )

ranking_table = (
    pd.DataFrame(ranking_rows)
    .sort_values("rms_relative_sensitivity", ascending=False)
    .reset_index(drop=True)
)

print(ranking_table)

# Build a correlation matrix between sensitivity shapes.
sensitivity_matrix = np.column_stack(
    [relative_sensitivities[name] for name in candidate_parameters]
)
correlation_matrix = np.corrcoef(sensitivity_matrix.T)

fig, axes = plt.subplots(1, 3, figsize=(16, 4.5))

axes[0].plot(t_eval / 60, terminal_voltage, color="black", linewidth=2)
axes[0].set_xlabel("Time [min]")
axes[0].set_ylabel("Terminal voltage [V]")
axes[0].set_title("Baseline DFN discharge")
axes[0].grid(True, alpha=0.3)

for parameter_name, sensitivity_curve in relative_sensitivities.items():
    axes[1].plot(t_eval / 60, sensitivity_curve, label=parameter_name)

axes[1].set_xlabel("Time [min]")
axes[1].set_ylabel("Relative sensitivity [-]")
axes[1].set_title("Voltage sensitivities")
axes[1].grid(True, alpha=0.3)
axes[1].legend(fontsize=8)

im = axes[2].imshow(correlation_matrix, vmin=-1, vmax=1, cmap="coolwarm")
axes[2].set_xticks(range(len(candidate_parameters)))
axes[2].set_yticks(range(len(candidate_parameters)))
axes[2].set_xticklabels(candidate_parameters.keys(), rotation=45, ha="right")
axes[2].set_yticklabels(candidate_parameters.keys())
axes[2].set_title("Sensitivity-shape correlation")
fig.colorbar(im, ax=axes[2], fraction=0.046, pad=0.04)

plt.tight_layout()
plt.show()
```

### Walkthrough 1 code explanation

We import `numpy`, `pandas`, `matplotlib`, and `pybamm` because we need numerical arrays, a neat ranking table, plots, and the model itself. Nothing unusual there.

The model line chooses a DFN with lumped thermal coupling:

```python
model = pybamm.lithium_ion.DFN(options={"thermal": "lumped"})
```

That `thermal` option matters. If we kept the model isothermal, temperature-related parameters such as ambient temperature and heat transfer coefficient would either have no effect or a much weaker effect on the terminal voltage. Because we want to screen thermal and electrochemical candidates together, the thermal state must be solved dynamically.

We then load the `Chen2020` parameter set as a clean literature baseline. This is standard practice. We are not starting from random guesses. We are starting from a defensible chemistry description and asking which deviations around that description the data can see.

The `candidate_parameters` dictionary defines four scalar inputs. `"Current function [A]"` is the most immediately observable quantity under discharge. `"Ambient temperature [K]"` influences kinetics and transport through temperature-dependent constitutive laws. `"Initial concentration in electrolyte [mol.m-3]"` acts here as a proxy for salt inventory and electrolyte-state uncertainty. `"Total heat transfer coefficient [W.m-2.K-1]"` controls how quickly heat leaves the lumped thermal domain.

Then comes the key PyBaMM trick:

```python
parameter_values.update(
    {parameter_name: "[input]" for parameter_name in candidate_parameters}
)
```

This tells PyBaMM that each of those named quantities should be supplied at solve time rather than baked permanently into the processed model. That is exactly what makes repeated solves inside screening or optimization loops practical.

We choose the IDAKLU solver because it is the recommended PyBaMM solver for sensitivity calculations. The tolerances `rtol=1e-3` and `atol=1e-5` are a compromise between speed and stability for a teaching example. If you tighten them, the solve becomes slower. If you loosen them too much, the sensitivity curves may become noisy enough to confuse the ranking.

The solve call is the central line:

```python
solution = simulation.solve(
    [0, 1200],
    t_interp=t_eval,
    inputs=candidate_parameters,
    calculate_sensitivities=True,
)
```

The `t_interp=t_eval` argument is important. PyBaMM only returns sensitivities at the time points used to represent the solution. By forcing the interpolated output grid to be exactly the time grid we want, we make later plotting and ranking straightforward.

Once the solve is complete, `solution["Terminal voltage [V]"].sensitivities[parameter_name]` gives the derivative of voltage with respect to the chosen parameter at every time point. Raw sensitivities have units, so direct comparison is misleading. That is why we convert to the relative form

$$
S_j^{\mathrm{rel}}(t)
=
\frac{\theta_j}{V(t)}
\frac{\partial V(t)}{\partial \theta_j}.
\tag{4}
$$

Equation (4) tells us the fractional influence of a fractional change in each parameter. The division by voltage magnitude prevents the comparison from being dominated by units.

We then compute two simple scalar scores from each sensitivity curve: its RMS magnitude and its peak absolute magnitude. The RMS score is the better default ranking metric because it reflects influence across the entire protocol rather than at one isolated instant.

Finally, we compute a correlation matrix between sensitivity shapes. This is not a formal identifiability proof, but it is a strong warning tool. If two sensitivity curves are nearly perfectly correlated, the optimizer may struggle to tell the associated parameters apart.

### Walkthrough 1 expected output

Your printed table should rank `"Current function [A]"` highest by RMS relative sensitivity. `"Ambient temperature [K]"` is usually next for this thermally coupled discharge, while the electrolyte initial concentration and heat-transfer coefficient are lower. The exact numbers will vary slightly with solver tolerances, but the ordering should be broadly stable.

The left plot, titled **Baseline DFN discharge**, should show time on the horizontal axis from `0` to `20` minutes and terminal voltage on the vertical axis in volts. The curve should begin a little above `4.0 V` and slope steadily downward. If your voltage increases with time or starts below cutoff, something is wrong.

The middle plot, titled **Voltage sensitivities**, should show four curves with visibly different shapes. The current sensitivity should have the largest magnitude and should mostly remain negative, meaning that increasing discharge current lowers terminal voltage. The ambient-temperature sensitivity should be smaller and often positive over much of the trajectory, meaning a warmer cell tends to sustain a slightly higher voltage under load. The other two curves should be weaker and more protocol-dependent.

The right plot, titled **Sensitivity-shape correlation**, should be a colored heatmap with `1` on the diagonal. Off-diagonal entries close to `1` or `-1` indicate parameter effects with similar shapes. Those pairs are harder to separate from voltage alone.

### Walkthrough 1 what could go wrong

#### 1. The solve fails with a convergence or event error

Symptom: PyBaMM stops before `1200 s`, or reports a voltage-cutoff event too early.  
Fix: reduce the current from `5.0 A` to `3.0 A` for a first run, or shorten the simulation window. High-rate DFN sensitivity solves are more fragile than plain forward solves.

#### 2. One or more sensitivity curves are identically zero

Symptom: a plotted curve lies exactly on zero at all times.  
Fix: first check whether the parameter actually influences the chosen model configuration. For example, thermal parameters are uninformative in an isothermal model. If the physics is right, confirm that the parameter name matches PyBaMM's exact key.

#### 3. The correlation matrix is full of `nan`

Symptom: the heatmap fails or contains missing values.  
Fix: one of the sensitivity curves is constant. This usually means that parameter does not affect the output on your time window. Remove it from the correlation calculation or pick a richer protocol.

### Walkthrough 1 reflection

This exercise taught the most important pre-fit habit in the chapter: do not optimize blindly. You now have a concrete PyBaMM workflow for screening candidate parameters, ranking them by output influence, and spotting pairs whose effects are too similar to separate cleanly. We will reuse this logic every time we decide whether a fitting problem is scientifically justified.

## Guided Walkthrough 2: Fitting a Two-Parameter Synthetic Problem with `least_squares`

**Learning objective:** Build a reusable least-squares fitting loop around a PyBaMM forward model and use analytic sensitivities as the Jacobian.

Now that we know how to screen parameters, we can fit a small subset responsibly. We will generate synthetic voltage data from a thermally coupled DFN, add a little measurement noise, and then recover two parameters: discharge current and ambient temperature.

This is a teaching shortcut, not standard experimental practice. In a real battery test, current is measured directly by the cycler, so you would rarely estimate it from voltage. We are including it because it gives a parameter with a strong, clean influence on the model output, which makes the mechanics of the optimizer easy to see. Standard practice starts with one or two strongly observable parameters before moving to harder quantities.

### Walkthrough 2 code

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.optimize import least_squares
import pybamm


rng = np.random.default_rng(42)

model = pybamm.lithium_ion.DFN(options={"thermal": "lumped"})
parameter_values = pybamm.ParameterValues("Chen2020")
parameter_values.update(
    {
        "Current function [A]": "[input]",
        "Ambient temperature [K]": "[input]",
    }
)

solver = pybamm.IDAKLUSolver(rtol=1e-3, atol=1e-5)
simulation = pybamm.Simulation(
    model,
    parameter_values=parameter_values,
    solver=solver,
)

t_eval = np.linspace(0, 1200, 60)
true_parameters = {
    "Current function [A]": 5.0,
    "Ambient temperature [K]": 298.15,
}

synthetic_solution = simulation.solve(
    [0, 1200],
    t_interp=t_eval,
    inputs=true_parameters,
)

true_voltage = synthetic_solution["Terminal voltage [V]"].data
measured_voltage = true_voltage + 0.0015 * rng.normal(size=t_eval.size)

parameter_names = ["Current function [A]", "Ambient temperature [K]"]
lower_bounds = np.array([1.0, 273.15])
upper_bounds = np.array([10.0, 323.15])
initial_guess = np.array([4.0, 305.15])

cache = {}


def solve_model_and_jacobian(theta):
    cache_key = tuple(np.round(theta, 10))
    if cache_key in cache:
        return cache[cache_key]

    inputs = dict(zip(parameter_names, theta))
    solution = simulation.solve(
        [0, 1200],
        t_interp=t_eval,
        inputs=inputs,
        calculate_sensitivities=True,
    )
    voltage = solution["Terminal voltage [V]"].data
    jacobian = np.column_stack(
        [
            solution["Terminal voltage [V]"].sensitivities[name]
            for name in parameter_names
        ]
    )
    cache[cache_key] = (voltage, jacobian)
    return voltage, jacobian


def residual_vector(theta):
    voltage, _ = solve_model_and_jacobian(theta)
    return voltage - measured_voltage


def residual_jacobian(theta):
    _, jacobian = solve_model_and_jacobian(theta)
    return jacobian


result = least_squares(
    residual_vector,
    x0=initial_guess,
    jac=residual_jacobian,
    bounds=(lower_bounds, upper_bounds),
    verbose=1,
)

fitted_voltage, fitted_jacobian = solve_model_and_jacobian(result.x)
residuals = fitted_voltage - measured_voltage

degrees_of_freedom = len(measured_voltage) - len(result.x)
residual_variance = 2 * result.cost / degrees_of_freedom
covariance_matrix = residual_variance * np.linalg.inv(
    fitted_jacobian.T @ fitted_jacobian
)
standard_errors = np.sqrt(np.diag(covariance_matrix))
confidence_interval_95 = 1.96 * standard_errors

report = pd.DataFrame(
    {
        "parameter": parameter_names,
        "true_value": [true_parameters[name] for name in parameter_names],
        "initial_guess": initial_guess,
        "fitted_value": result.x,
        "std_error": standard_errors,
        "half_width_95pct_ci": confidence_interval_95,
    }
)

print(report)
print("RMSE [V]:", np.sqrt(np.mean(residuals**2)))

fig, axes = plt.subplots(1, 2, figsize=(13, 4.5))

axes[0].plot(t_eval / 60, measured_voltage, "o", ms=4, label="Synthetic data")
axes[0].plot(t_eval / 60, fitted_voltage, "-", lw=2.5, label="Fitted DFN")
axes[0].set_xlabel("Time [min]")
axes[0].set_ylabel("Terminal voltage [V]")
axes[0].set_title("Model fit to synthetic data")
axes[0].grid(True, alpha=0.3)
axes[0].legend()

axes[1].plot(t_eval / 60, 1000 * residuals, color="tab:red", lw=2)
axes[1].axhline(0, color="black", linestyle="--", linewidth=1)
axes[1].set_xlabel("Time [min]")
axes[1].set_ylabel("Residual [mV]")
axes[1].set_title("Fit residuals")
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.show()
```

### Walkthrough 2 code explanation

The first half of the script constructs the forward model exactly once. That is worth emphasizing. In PyBaMM estimation workflows, you want to process the model once and vary only input parameters at solve time whenever possible. Rebuilding the processed model on every optimization iteration is a needless performance penalty.

We again use a lumped-thermal DFN and update two parameters to `[input]`. These are the two coordinates of our optimization vector $\theta$.

The synthetic data are created by solving the model at the known `true_parameters`, then adding Gaussian noise of standard deviation `1.5 mV`. That noise level is realistic enough to matter but small enough that the fit should still recover the truth closely. Synthetic data are invaluable in early estimation work because they separate algorithmic failure from data-quality failure. If you cannot recover parameters from your own synthetic data, you are not ready to trust the pipeline on experiments.

The `cache` dictionary is not mathematically required, but it is practically useful. `least_squares` may ask for the residual and the Jacobian at the same point, and without caching you would perform the same solve twice. The cache key rounds the parameter vector so floating-point noise does not create pointless duplicate entries.

Inside `solve_model_and_jacobian`, the line

```python
solution = simulation.solve(
    [0, 1200],
    t_interp=t_eval,
    inputs=inputs,
    calculate_sensitivities=True,
)
```

does the heavy lifting. PyBaMM returns both the voltage vector and its sensitivities with respect to each fitted parameter on the same time grid. The Jacobian for `least_squares` is therefore just a column stack of those sensitivity curves:

$$
J_{n,j}
=
\frac{\partial v(t_n; \theta)}{\partial \theta_j}.
\tag{5}
$$

This is one of the cleanest advantages of PyBaMM over ad hoc battery fitting scripts. You do not need to hand-derive finite-difference code for each model output. The solver carries forward sensitivities for you.

The residual function returns the vector

$$
r_n(\theta)
=
v_{\mathrm{model}}(t_n; \theta)
-
v_{\mathrm{data}}(t_n),
\tag{6}
$$

and `least_squares` minimizes $\sum_n r_n^2$. We supply explicit bounds because unconstrained physical parameters are an invitation to nonsense. Bounds are not a crutch. They are one of the ways you encode prior physical realism into the inverse problem.

After fitting, we compute a local covariance estimate from the Jacobian:

$$
\mathrm{Cov}(\hat{\theta})
\approx
\hat{\sigma}^2
\left(J^\top J\right)^{-1},
\tag{7}
$$

with

$$
\hat{\sigma}^2
=
\frac{2\,\mathrm{cost}}{N-p},
\tag{8}
$$

because SciPy reports `cost = \tfrac{1}{2}\sum_n r_n^2`. This covariance formula is a local linear approximation, not a global truth. That distinction matters. The 95% intervals derived from it are useful for honesty, but they are not Bayesian credible intervals and they are not reliable when the problem is strongly nonlinear or poorly conditioned.

### Walkthrough 2 expected output

The printed report should recover a current very close to `5.0 A` and an ambient temperature close to `298.15 K`. On a typical run with the random seed shown here, the recovered values land within a few thousandths of an ampere and within about `1 K` of the true temperature. Your exact numbers may differ slightly if solver tolerances or noise level change, but they should be close.

The reported RMSE should be on the order of the noise level, roughly one to a few millivolts. If the RMSE is tens of millivolts, the fit did not work.

The left plot should show circular data markers and a smooth fitted curve almost lying on top of them. Time runs from `0` to `20` minutes, voltage slopes downward, and the fit should be visually indistinguishable from the noisy data except for tiny point-to-line deviations. The right plot should show residuals centered near zero with no obvious drift or curvature. If the residuals show a systematic bow shape, you are not fitting the right physics even if the RMSE looks moderate.

### Walkthrough 2 what could go wrong

#### 1. `LinAlgError` when computing the covariance matrix

Symptom: `np.linalg.inv(J.T @ J)` fails.  
Fix: the Jacobian is close to singular, meaning the parameters are too correlated or one is too weakly observable. This is an identifiability warning, not just a numerical nuisance. Revisit Walkthrough 1 and simplify the candidate set.

#### 2. The optimizer stops at a bound

Symptom: the fitted current or temperature equals the exact lower or upper bound.  
Fix: sometimes the initial guess is poor, but more often the data do not constrain that parameter enough. Widen the protocol, improve the initial guess, or pick a better parameter subset rather than blindly expanding the bounds.

#### 3. The fit is good but the uncertainty is absurdly wide

Symptom: the curve overlays the data, but the confidence interval on a parameter is huge.  
Fix: this is the classic signature of correlated parameters. The optimizer found one good point, but the data do not isolate that point strongly. Report that honestly.

### Walkthrough 2 reflection

This exercise taught the central fitting pattern we will reuse for the rest of the manual: build one processed model, expose only a small candidate subset as inputs, generate a residual vector, pass an analytic Jacobian when available, and quantify local uncertainty instead of reporting point estimates alone. That pattern is the backbone of serious PyBaMM estimation work.

## Guided Walkthrough 3: Building a Reusable CSV-to-Fit Pipeline

**Learning objective:** Wrap the estimation workflow into a reusable function that reads a standardized CSV and fits a small, defensible parameter subset.

A chapter example becomes research infrastructure only when you can point it at a file and reuse it. In this walkthrough, we will build exactly that: a pipeline that expects a CSV with `time_s`, `current_a`, and `voltage_v`, constructs a PyBaMM current interpolant, and estimates ambient temperature and initial SOC.

Why this parameter pair? Because it is honest for a first reusable pipeline. `Ambient temperature [K]` is a true model parameter. `initial_soc` is an initial condition rather than a parameter in the strictest sense, but in real lab data it is often uncertain enough to deserve estimation or at least refinement. More importantly, this pair is usually recoverable from a dynamic current-voltage trace on a laptop without pretending that a single experiment can identify the entire electrochemical model.

### Walkthrough 3 code

```python
from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.optimize import least_squares
import pybamm


def create_synthetic_csv(csv_path):
    csv_path.parent.mkdir(parents=True, exist_ok=True)

    time_s = np.linspace(0, 1200, 121)
    current_a = np.piecewise(
        time_s,
        [
            time_s < 300,
            (time_s >= 300) & (time_s < 500),
            (time_s >= 500) & (time_s < 800),
            time_s >= 800,
        ],
        [5.0, 1.0, 4.0, 2.0],
    )

    model = pybamm.lithium_ion.SPMe(options={"thermal": "lumped"})
    parameter_values = pybamm.ParameterValues("Chen2020")
    parameter_values.update({"Ambient temperature [K]": "[input]"})
    parameter_values["Current function [A]"] = pybamm.Interpolant(
        time_s,
        current_a,
        pybamm.t,
    )

    simulation = pybamm.Simulation(
        model,
        parameter_values=parameter_values,
        solver=pybamm.IDAKLUSolver(rtol=1e-3, atol=1e-5),
    )

    solution = simulation.solve(
        t_interp=time_s,
        inputs={"Ambient temperature [K]": 299.15},
        initial_soc=0.82,
    )

    rng = np.random.default_rng(7)
    voltage_v = solution["Terminal voltage [V]"].data + 0.0015 * rng.normal(
        size=time_s.size
    )

    synthetic_frame = pd.DataFrame(
        {
            "time_s": time_s,
            "current_a": current_a,
            "voltage_v": voltage_v,
        }
    )
    synthetic_frame.to_csv(csv_path, index=False)
    return synthetic_frame


def standardize_battery_csv(csv_path):
    frame = pd.read_csv(csv_path)
    required_columns = {"time_s", "current_a", "voltage_v"}
    missing = required_columns.difference(frame.columns)
    if missing:
        raise ValueError(f"Missing required columns: {sorted(missing)}")

    frame = frame.copy()
    frame = frame.sort_values("time_s").reset_index(drop=True)
    frame = frame.dropna(subset=["time_s", "current_a", "voltage_v"])

    # Enforce numeric types and monotonic time.
    frame["time_s"] = pd.to_numeric(frame["time_s"])
    frame["current_a"] = pd.to_numeric(frame["current_a"])
    frame["voltage_v"] = pd.to_numeric(frame["voltage_v"])

    if (np.diff(frame["time_s"]) <= 0).any():
        raise ValueError("time_s must be strictly increasing")

    return frame


def build_simulation_from_dataframe(frame):
    model = pybamm.lithium_ion.SPMe(options={"thermal": "lumped"})
    parameter_values = pybamm.ParameterValues("Chen2020")
    parameter_values.update({"Ambient temperature [K]": "[input]"})
    parameter_values["Current function [A]"] = pybamm.Interpolant(
        frame["time_s"].to_numpy(),
        frame["current_a"].to_numpy(),
        pybamm.t,
    )

    simulation = pybamm.Simulation(
        model,
        parameter_values=parameter_values,
        solver=pybamm.IDAKLUSolver(rtol=1e-3, atol=1e-5),
    )
    return simulation


def fit_temperature_and_initial_soc(frame):
    simulation = build_simulation_from_dataframe(frame)
    time_s = frame["time_s"].to_numpy()
    measured_voltage = frame["voltage_v"].to_numpy()

    def residual(theta):
        ambient_temperature_k, initial_soc = theta
        solution = simulation.solve(
            t_interp=time_s,
            inputs={"Ambient temperature [K]": ambient_temperature_k},
            initial_soc=initial_soc,
        )
        predicted_voltage = solution["Terminal voltage [V]"].data
        return predicted_voltage - measured_voltage

    result = least_squares(
        residual,
        x0=np.array([297.15, 0.75]),
        bounds=(np.array([273.15, 0.4]), np.array([323.15, 1.0])),
        jac="2-point",
    )

    fitted_solution = simulation.solve(
        t_interp=time_s,
        inputs={"Ambient temperature [K]": result.x[0]},
        initial_soc=result.x[1],
    )
    fitted_voltage = fitted_solution["Terminal voltage [V]"].data
    residuals = fitted_voltage - measured_voltage

    # Local one-at-a-time ranking around the fitted point.
    delta_temperature = 1.0
    delta_soc = 0.005

    solution_temp_plus = simulation.solve(
        t_interp=time_s,
        inputs={"Ambient temperature [K]": result.x[0] + delta_temperature},
        initial_soc=result.x[1],
    )
    solution_soc_plus = simulation.solve(
        t_interp=time_s,
        inputs={"Ambient temperature [K]": result.x[0]},
        initial_soc=min(result.x[1] + delta_soc, 0.999),
    )

    temp_sensitivity_fd = (
        solution_temp_plus["Terminal voltage [V]"].data - fitted_voltage
    ) / delta_temperature
    soc_sensitivity_fd = (
        solution_soc_plus["Terminal voltage [V]"].data - fitted_voltage
    ) / delta_soc

    ranking = pd.DataFrame(
        {
            "quantity": ["Ambient temperature [K]", "initial_soc"],
            "rms_local_sensitivity": [
                np.sqrt(np.mean(temp_sensitivity_fd**2)),
                np.sqrt(np.mean(soc_sensitivity_fd**2)),
            ],
        }
    ).sort_values("rms_local_sensitivity", ascending=False)

    summary = {
        "ambient_temperature_k": result.x[0],
        "initial_soc": result.x[1],
        "rmse_v": float(np.sqrt(np.mean(residuals**2))),
        "fitted_voltage": fitted_voltage,
        "residuals": residuals,
        "ranking": ranking,
    }
    return summary


csv_path = Path("data/chapter5/synthetic_pulse_fit.csv")
create_synthetic_csv(csv_path)
frame = standardize_battery_csv(csv_path)
fit_summary = fit_temperature_and_initial_soc(frame)

print(frame.head())
print()
print("Recovered ambient temperature [K]:", round(fit_summary["ambient_temperature_k"], 3))
print("Recovered initial SOC [-]:", round(fit_summary["initial_soc"], 5))
print("RMSE [mV]:", round(1000 * fit_summary["rmse_v"], 3))
print()
print(fit_summary["ranking"])

fig, axes = plt.subplots(3, 1, figsize=(10, 9), sharex=True)

axes[0].plot(frame["time_s"] / 60, frame["current_a"], color="tab:blue", linewidth=2)
axes[0].set_ylabel("Current [A]")
axes[0].set_title("Input current profile")
axes[0].grid(True, alpha=0.3)

axes[1].plot(frame["time_s"] / 60, frame["voltage_v"], "o", ms=3, label="CSV data")
axes[1].plot(
    frame["time_s"] / 60,
    fit_summary["fitted_voltage"],
    "-",
    linewidth=2.5,
    label="Fitted SPMe",
)
axes[1].set_ylabel("Voltage [V]")
axes[1].set_title("Measured vs fitted voltage")
axes[1].grid(True, alpha=0.3)
axes[1].legend()

axes[2].plot(
    frame["time_s"] / 60,
    1000 * fit_summary["residuals"],
    color="tab:red",
    linewidth=2,
)
axes[2].axhline(0, color="black", linestyle="--", linewidth=1)
axes[2].set_xlabel("Time [min]")
axes[2].set_ylabel("Residual [mV]")
axes[2].set_title("Residual trace")
axes[2].grid(True, alpha=0.3)

plt.tight_layout()
plt.show()
```

### Walkthrough 3 code explanation

This script is longer because it is real workflow code, not just a one-off notebook cell. We define four helper functions so that each stage of the pipeline is explicit and reusable.

`create_synthetic_csv` generates a file that mimics what a real standardized experiment file should look like: time in seconds, current in amps, voltage in volts. The current profile is deliberately piecewise constant rather than perfectly smooth, because parameter estimation benefits from excitation richness. We use an SPMe rather than a DFN here because the point of this walkthrough is reusable structure and quick iteration. Standard practice is to prototype estimation loops with SPMe or SPM, then rerun the shortlisted candidate set on DFN once the workflow is stable.

The `standardize_battery_csv` function is defensive data engineering. It checks that the required columns exist, sorts by time, drops null rows, enforces numeric conversion, and rejects non-monotonic time. None of that is glamorous, but every serious estimation pipeline needs it. Most fitting disasters are not solver disasters. They are quietly bad data.

`build_simulation_from_dataframe` is where we convert current samples into a PyBaMM object. The key line is:

```python
parameter_values["Current function [A]"] = pybamm.Interpolant(
    frame["time_s"].to_numpy(),
    frame["current_a"].to_numpy(),
    pybamm.t,
)
```

This line tells PyBaMM to treat the current as an interpolated function of model time. That is how we move from a CSV trace to a continuous forcing function the model can solve against.

`fit_temperature_and_initial_soc` then wraps the inverse problem. We are fitting only two quantities: ambient temperature and initial SOC. Because `initial_soc` is passed through the `solve` call rather than as a standard input parameter, we use `jac="2-point"` in `least_squares` instead of an analytic Jacobian. That is a perfectly valid teaching choice. We already used PyBaMM's analytic sensitivities in Walkthroughs 1 and 2 for the parameters that support them cleanly. Here the priority is building a generic CSV pipeline that works with an initial-condition fit as well.

After fitting, we compute a simple local ranking by finite difference. This is intentionally modest. It is not a full global identifiability analysis. It is a quick local sensitivity check around the fitted point so the pipeline returns not just numbers, but some clue about which recovered quantity the data were most sensitive to.

### Walkthrough 3 expected output

The printed `head()` of the standardized frame should show three columns: `time_s`, `current_a`, and `voltage_v`. The first few current values should be `5.0 A`, because the synthetic profile begins at high discharge load.

The recovered ambient temperature should be close to `299.15 K`, and the recovered `initial_soc` should be close to `0.82`. Because the data contain noise and the problem is nonlinear, you should not expect perfect equality. Recovering temperature within about `1 K` and SOC within a few thousandths is a good result here.

The current plot should show four horizontal plateaus over `20` minutes. The middle voltage plot should show dots and a smooth fitted line almost overlapping them. The residual plot should bounce around zero, mostly within a few millivolts. If you see structured residual swings that line up with current-step boundaries, the parameter pair is not capturing enough physics.

### Walkthrough 3 what could go wrong

#### 1. `ValueError: time_s must be strictly increasing`

Symptom: your standardized CSV fails immediately.  
Fix: your source file likely has duplicate timestamps or a reset in the logging clock. Clean the file before fitting. Do not ignore this error. Interpolated current profiles need monotonic time.

#### 2. The fitted `initial_soc` pegs at `1.0` or `0.4`

Symptom: the optimizer lands exactly on a bound.  
Fix: either the data truly begin near a bound or the chosen model mismatch is being absorbed by SOC. That is a warning sign. Check whether the current sign convention and starting state are correct.

#### 3. The residuals are small overall but spike at current transitions

Symptom: the line tracks the data well except right after current steps.  
Fix: that usually means the model is missing a fast loss mechanism or the fit needs a parameter more directly tied to transient polarization. This is a classic case where a future ECM fit may complement the PyBaMM fit.

### Walkthrough 3 reflection

This exercise turned a chapter pattern into a reusable research tool. You now have a file-format contract, a data-cleaning step, a forward-model builder, a fitting routine, and a local post-fit ranking. That is exactly the kind of scaffold we will keep extending in later chapters.

## Dataset Integration: Using the Public Ecker Discharge Data

This chapter should touch real experimental data, and PyBaMM gives us a convenient small public dataset for doing exactly that. The Ecker discharge curves are bundled in the `pybamm-data` registry and exposed through `pybamm.DataLoader()`. The curves are taken from the parameterization and validation work associated with the `Ecker2015` parameter set, which makes them especially useful for teaching because the chemistry, model, and reference literature line up.

The practical attraction of these files is that they are tiny, easy to parse, and clean enough to focus on modeling rather than messy vendor formats. The limitation is equally important: they are only voltage-time pairs. Current is not stored as a full time series in the file because the tests are fixed-rate discharges. That means we must reconstruct the current column ourselves using the stated C-rate and the nominal capacity of the parameter set.

### Where to get the data

| Item | Source | Format | Approximate size | Notes |
| --- | --- | --- | --- | --- |
| `Ecker_1C.csv` | `pybamm.DataLoader()` from the PyBaMM data registry | CSV, 2 columns | Small, laptop-friendly | Time [s], Voltage [V] |
| `Ecker_5C.csv` | `pybamm.DataLoader()` from the PyBaMM data registry | CSV, 2 columns | Small, laptop-friendly | Time [s], Voltage [V] |

The data are distributed through the PyBaMM data registry and tied to the Ecker validation example in the official docs. The registry does not advertise a separate machine-readable license in the notebook output, so treat the files as research data accompanying the cited PyBaMM example and the original Ecker paper, and verify redistribution terms if you plan to publish them directly in another repository.

### Column meanings and common pitfalls

The raw Ecker CSVs contain:

| Raw column index | Meaning | Units |
| --- | --- | --- |
| `0` | elapsed time | seconds |
| `1` | terminal voltage | volts |

The common pitfalls are straightforward but important.

First, current is not included. You must reconstruct it. For a 1C discharge under the `Ecker2015` parameter set, current is nominal capacity times `1`. For a 5C discharge, it is nominal capacity times `5`.

Second, sign convention matters. In PyBaMM's lithium-ion models, discharge current is taken as positive. That matches the way we will reconstruct the Ecker current column here. If you import data from another source later, do not assume the same convention.

Third, because these files hold only voltage and time, they are best for single-rate validation and light estimation tasks. They are not enough to justify broad claims about parameter identifiability by themselves.

### Worked real-data example

```python
from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.optimize import least_squares
import pybamm


data_loader = pybamm.DataLoader()

raw_voltage_data = pd.read_csv(
    data_loader.get_data("Ecker_5C.csv"),
    header=None,
    names=["time_s", "voltage_v"],
)

parameter_values = pybamm.ParameterValues("Ecker2015")
nominal_capacity_ah = parameter_values["Nominal cell capacity [A.h]"]
discharge_current_a = 5.0 * nominal_capacity_ah

ecker_frame = raw_voltage_data.copy()
ecker_frame["current_a"] = discharge_current_a
ecker_frame = ecker_frame[["time_s", "current_a", "voltage_v"]]

output_path = Path("data/chapter5/ecker_5c_standardized.csv")
output_path.parent.mkdir(parents=True, exist_ok=True)
ecker_frame.to_csv(output_path, index=False)

# Build a thermally coupled validation model.
model = pybamm.lithium_ion.DFN(options={"thermal": "lumped"})
parameter_values = pybamm.ParameterValues("Ecker2015")
parameter_values.update({"Ambient temperature [K]": "[input]"})
parameter_values["Current function [A]"] = pybamm.Interpolant(
    ecker_frame["time_s"].to_numpy(),
    ecker_frame["current_a"].to_numpy(),
    pybamm.t,
)

simulation = pybamm.Simulation(
    model,
    parameter_values=parameter_values,
    solver=pybamm.IDAKLUSolver(rtol=1e-3, atol=1e-5),
)

time_s = ecker_frame["time_s"].to_numpy()
measured_voltage = ecker_frame["voltage_v"].to_numpy()

baseline_solution = simulation.solve(
    t_interp=time_s,
    inputs={"Ambient temperature [K]": 298.15},
    initial_soc=1.0,
)
baseline_voltage = baseline_solution["Terminal voltage [V]"].data


def residual(theta):
    ambient_temperature_k = theta[0]
    fitted_solution = simulation.solve(
        t_interp=time_s,
        inputs={"Ambient temperature [K]": ambient_temperature_k},
        initial_soc=1.0,
    )
    predicted_voltage = fitted_solution["Terminal voltage [V]"].data
    return predicted_voltage - measured_voltage


result = least_squares(
    residual,
    x0=np.array([298.15]),
    bounds=(np.array([273.15]), np.array([323.15])),
)

fitted_solution = simulation.solve(
    t_interp=time_s,
    inputs={"Ambient temperature [K]": result.x[0]},
    initial_soc=1.0,
)
fitted_voltage = fitted_solution["Terminal voltage [V]"].data

baseline_rmse_mv = 1000 * np.sqrt(np.mean((baseline_voltage - measured_voltage) ** 2))
fitted_rmse_mv = 1000 * np.sqrt(np.mean((fitted_voltage - measured_voltage) ** 2))

print("Standardized file written to:", output_path)
print("Nominal capacity [A.h]:", nominal_capacity_ah)
print("Assumed 5C discharge current [A]:", discharge_current_a)
print("Fitted ambient temperature [K]:", round(float(result.x[0]), 3))
print("Baseline RMSE [mV]:", round(float(baseline_rmse_mv), 3))
print("Fitted RMSE [mV]:", round(float(fitted_rmse_mv), 3))

fig, axes = plt.subplots(2, 1, figsize=(10, 7), sharex=True)

axes[0].plot(time_s / 60, measured_voltage, "o", ms=3, label="Measured Ecker 5C")
axes[0].plot(time_s / 60, baseline_voltage, lw=2, label="Baseline Ecker2015")
axes[0].plot(time_s / 60, fitted_voltage, lw=2.5, label="After temperature fit")
axes[0].set_ylabel("Voltage [V]")
axes[0].set_title("Real-data comparison on Ecker 5C discharge")
axes[0].grid(True, alpha=0.3)
axes[0].legend()

axes[1].plot(
    time_s / 60,
    1000 * (fitted_voltage - measured_voltage),
    color="tab:red",
    linewidth=2,
)
axes[1].axhline(0, color="black", linestyle="--", linewidth=1)
axes[1].set_xlabel("Time [min]")
axes[1].set_ylabel("Residual [mV]")
axes[1].set_title("Residual after one-parameter fit")
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.show()
```

This code is intentionally conservative. We fit only ambient temperature while holding `initial_soc=1.0`, because the file represents a named full-rate discharge and we want a real-data example that stays honest. You should expect the fitted temperature to remain in a plausible room-temperature neighborhood, not to wander to an absurd value. The fitted RMSE should improve relative to the baseline, but not magically drop to zero. That is the right lesson. Real data retain mismatch even after a sensible fit.

If you want a stronger estimation exercise on these files, use the 1C and 5C traces together and fit a shared parameter across both. That is much closer to the multi-condition logic used in publishable parameter studies.

## A Brief Bayesian Detour

Frequentist least-squares fitting is the right default for this chapter because it is fast, transparent, and easy to debug. But you should know where the field goes next. When parameter correlations become severe, when you care more about uncertainty structure than about one best-fit point, or when prior information matters strongly, a Bayesian workflow becomes attractive.

The practical PyBaMM-adjacent tool for that ecosystem is PyBOP. The conceptual shift is simple. Instead of looking only for the best-fit parameter vector $\hat{\theta}$, you ask for a posterior distribution:

$$
p(\theta \mid D)
\propto
p(D \mid \theta)\,p(\theta),
\tag{9}
$$

where $D$ is the dataset, $p(D \mid \theta)$ is the likelihood, and $p(\theta)$ is the prior. In plain language: what parameter values remain plausible after combining the data with what we already believed?

That approach is powerful, but it is not a magic cure. If the experiment is uninformative, the posterior simply reveals the uninformative structure more honestly. That is still useful. In fact, that honesty is one of the strongest arguments for Bayesian estimation in battery modeling. It shows you when the data really cannot decide.

For this companion, treat Bayesian inference as the next layer after you are comfortable with Chapters 5 and 12. Get the forward model stable. Learn to screen parameters. Learn to inspect residual structure. Then add Bayesian machinery. If you reverse that order, you often end up sampling your way around a bad deterministic pipeline.

## Reproduction Exercise: Reproducing Figure 2 from Hallemans et al. (2024)

The paper we will work from is:

Hallemans, N., Courtier, N. E., Please, C. P., Planden, B., Dhoot, R., Timms, R., Chapman, S. J., Howey, D., and Duncan, S. R. (2024). *Physics-based battery model parametrisation from impedance data*. arXiv:2412.10896.

We will reproduce **Figure 2**, which the authors describe as an illustration of a time-domain simulation of the SPMe. The paper uses that figure to frame the central limitation of voltage-only fitting: current and voltage traces are useful, but often not informative enough to recover all grouped parameters of a physics-based model. That message belongs directly inside this chapter.

### What makes this reproduction tricky

The paper gives us the figure, its purpose, and the fact that the synthetic study is built from a grouped SPMe linked to Chen2020-derived parameter values. What it does **not** fully specify in the published figure caption is the exact current waveform used to produce the upper panel. So this is a realistic reproduction task: the paper is scientifically useful, but not fully turnkey.

That means we need to make and document two choices:

1. We will use the built-in PyBaMM `SPMe` with the `Chen2020` parameter set rather than the appendix-specific grouped-parameter implementation.
2. We will reconstruct a piecewise current waveform that matches the figure's *function* rather than claiming pixel-perfect identity.

That is not a failure of reproduction. It is exactly the sort of judgment call real reproduction work requires. The honest standard here is not "identical screenshot." It is "same physical setup, same modeling intent, same qualitative behavior, and clearly documented deviations."

### Reproduction code

```python
import numpy as np
import matplotlib.pyplot as plt
import pybamm


# Reconstructed pulse-rich current profile inspired by Hallemans et al. Figure 2.
time_s = np.arange(0, 3600 + 10, 10)
current_a = np.zeros_like(time_s, dtype=float)

current_a[(time_s >= 0) & (time_s < 600)] = 2.5
current_a[(time_s >= 600) & (time_s < 900)] = 0.5
current_a[(time_s >= 900) & (time_s < 1500)] = 3.0
current_a[(time_s >= 1500) & (time_s < 1800)] = 1.0
current_a[(time_s >= 1800) & (time_s < 2400)] = 3.5
current_a[(time_s >= 2400) & (time_s < 3000)] = 1.5
current_a[(time_s >= 3000) & (time_s <= 3600)] = 2.0

model = pybamm.lithium_ion.SPMe(options={"thermal": "lumped"})
parameter_values = pybamm.ParameterValues("Chen2020")
parameter_values.update({"Ambient temperature [K]": 298.15})
parameter_values["Current function [A]"] = pybamm.Interpolant(
    time_s,
    current_a,
    pybamm.t,
)

simulation = pybamm.Simulation(
    model,
    parameter_values=parameter_values,
    solver=pybamm.IDAKLUSolver(rtol=1e-3, atol=1e-5),
)

solution = simulation.solve(t_interp=time_s, initial_soc=0.9)
voltage_v = solution["Terminal voltage [V]"].data

fig, axes = plt.subplots(2, 1, figsize=(10, 7), sharex=True)

axes[0].plot(time_s / 60, current_a, color="tab:blue", linewidth=2)
axes[0].set_ylabel("Current [A]")
axes[0].set_title("Reconstructed current profile inspired by Hallemans et al. Figure 2")
axes[0].grid(True, alpha=0.3)

axes[1].plot(time_s / 60, voltage_v, color="black", linewidth=2)
axes[1].set_xlabel("Time [min]")
axes[1].set_ylabel("Voltage [V]")
axes[1].set_title("SPMe voltage response")
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.show()
```

### How to judge whether the reproduction is successful

The top panel should show a stepped current profile over one hour with several changes in amplitude. The bottom panel should show a voltage trace that responds immediately to each current change, then relaxes into a slower downward trend as the discharge proceeds. Those are the key physical features of the published figure.

A successful reproduction here means:

- the protocol is pulse-rich rather than a boring constant-current sweep,
- the voltage reacts in the right qualitative way at each current transition,
- the overall trend remains physically plausible for an SPMe discharge,
- you document clearly that the exact waveform had to be reconstructed.

That is what "close enough" means in this case. If the paper had provided raw data, we would demand pointwise agreement. Because it does not, the appropriate standard is qualitative fidelity plus transparent documentation of the ambiguity.

### Why this reproduction matters

This figure is valuable because it makes the chapter's main warning visible. Even a pulse-rich time-domain trace contains limited information compared with a truly multi-condition parameterization campaign. If you later find yourself wanting to fit ten or fifteen electrochemical parameters from one or two voltage traces, come back to this figure and remember what the protocol is actually exciting.

## Open-Ended Exercises

These exercises are where you stop following and start adapting. Work them before reading the solutions.

### Exercise 1

Repeat Walkthrough 1 on the `SPMe` instead of the `DFN`. Keep the same four candidate parameters and the same 1200-second discharge. Does the ranking order change? Which sensitivity shapes become more or less correlated?

Hint: change only the model line at first. Keep the rest of the code identical so the comparison is fair.

### Exercise 2

Modify Walkthrough 2 so that you fit current and the total heat-transfer coefficient instead of current and ambient temperature. Does the optimizer recover both parameters cleanly from the same dataset?

Hint: use the sensitivity ranking from Walkthrough 1 before you expect success. If the heat-transfer coefficient is weakly observable, the fit may look numerically stable while still being scientifically weak.

### Exercise 3

Take the CSV pipeline from Walkthrough 3 and replace the piecewise-constant current profile with one that contains a rest period and a sharp high-current pulse. Refit `ambient_temperature` and `initial_soc`. Do the local sensitivity scores change?

Hint: protocols with sharp transitions often increase sensitivity to fast losses and initial-condition errors.

### Exercise 4

Use both `Ecker_1C.csv` and `Ecker_5C.csv` together. Fit a single shared ambient temperature that minimizes the combined residual across both files. Does a parameter that fits one rate also help at the other rate?

Hint: concatenate the residual vectors from the two simulations inside one objective function. Shared-parameter multi-condition fitting is closer to publishable practice than single-trace fitting.

## Worked Solutions to the Open-Ended Exercises

### Solution 1

On `SPMe`, the candidate ranking usually stays qualitatively similar: current remains dominant, ambient temperature stays important in the thermally coupled setting, and the weaker transport and heat-transfer terms remain lower. The main difference is often runtime and slight shape changes in the smaller-magnitude sensitivities. That is itself informative. A reduced-order model may preserve the gross ranking while changing the exact local geometry of the inverse problem.

### Solution 2

This exercise is meant to fail gracefully for many readers, and that is the lesson. The total heat-transfer coefficient often has a weaker and more delayed influence on terminal voltage than ambient temperature under a short discharge. In practice, the optimizer may recover current cleanly while leaving the heat-transfer coefficient poorly constrained or pushed toward a bound. That is not a software bug. It is an identifiability result.

### Solution 3

A rest period plus a sharp pulse usually increases the relative importance of `initial_soc` and of parameters tied to instantaneous or near-instantaneous voltage response. If your local sensitivity ranking shifts after changing the protocol, that is exactly what should happen. Parameter ranking is not a universal property of the model. It is a joint property of the model and the experiment.

### Solution 4

Joint fitting over `Ecker_1C.csv` and `Ecker_5C.csv` is the right direction. A single ambient temperature often improves consistency across the two traces more credibly than fitting each trace independently. The combined residual is usually larger than the best single-trace residual, but the result is more physically honest. That tradeoff is standard practice in multi-condition identification.

## What Changes for Sodium-Ion?

The estimation workflow from this chapter transfers to sodium-ion work more directly than the parameter values do. The biggest change is not the optimizer. It is the baseline parameterization you begin from and the data richness you can realistically obtain.

The first difference is OCV shape. Hard-carbon sodium-ion negative electrodes often contain flatter features and broader hysteresis-like behavior than common graphite lithium-ion systems. That can make voltage-only estimation less informative in certain SOC windows, especially for state-related quantities.

The second difference is public-data scarcity. On the lithium-ion side, we can lean on mature parameter sets such as `Chen2020` and `Ecker2015`, along with public validation traces. On the sodium-ion side, you will often have to work from sparse literature tables, digitized curves, or custom parameter subsets. That makes sensitivity screening even more important, not less.

The third difference is validation strategy. In sodium-ion work, it is often more honest to claim that you calibrated an *effective* reduced parameter subset around a literature baseline than to claim full electrochemical identification. That is not a weakness. It is careful science in a data-sparse setting.

As this manual progresses, we will return to that point repeatedly. For sodium-ion publishable work, your credibility depends less on having a huge fitted table and more on showing that you chose the subset, protocol, and validation conditions rationally.

## Chapter Summary and Skill Checklist

- You learned how to convert PyBaMM parameters into `InputParameter` objects for repeated solves.
- You used PyBaMM's built-in sensitivities to rank candidate parameters before fitting.
- You built a `least_squares` fitting loop around a DFN forward model and supplied an analytic Jacobian from sensitivities.
- You computed local uncertainty estimates from the fitted Jacobian and learned why they are only local approximations.
- You wrapped the workflow into a reusable CSV-to-fit pipeline using `pybamm.Interpolant`.
- You parsed and standardized real Ecker discharge data from the public PyBaMM data registry.
- You practiced reproduction on a recent paper while documenting ambiguity honestly instead of hiding it.

You should now be able to:

- decide whether a given protocol is informative enough for a chosen parameter subset,
- expose a PyBaMM parameter as `[input]` and vary it efficiently across solves,
- write a residual function for `scipy.optimize.least_squares`,
- extract terminal-voltage sensitivities from a PyBaMM solution,
- distinguish between a numerically good fit and a scientifically well-identified fit,
- standardize a current-voltage CSV into a format your fitting code can reuse,
- explain, in writing, why a given parameter was fitted and why another one was deliberately left fixed.

If you cannot check every box, revisit Walkthroughs 1 through 3 before moving on. Later chapters assume these habits, especially the habit of screening before fitting.

## Deliverable

The deliverable from the plan is:

> A working parameter-estimation pipeline that takes a CSV of current/voltage data and returns fitted DFN parameters with sensitivity rankings.

The practical way to approach that deliverable is in three passes.

First, make the CSV contract non-negotiable. Use the standardized three-column format from Walkthrough 3: `time_s`, `current_a`, `voltage_v`.

Second, begin with SPMe for speed while you debug the pipeline, then switch the final run to DFN after the code is stable and your candidate subset has already been screened. That is standard practice, not a compromise.

Third, keep the fitted subset small. A strong first deliverable is a notebook or script that:

- reads a CSV,
- plots the raw trace,
- ranks a short candidate list by local sensitivity,
- fits one or two justified quantities,
- writes a fit report with RMSE and parameter estimates,
- saves measured-vs-fitted and residual plots to `results/chapter5/`.

A worked partial target is the synthetic CSV pipeline from Walkthrough 3 plus the Ecker real-data example. If you can combine those two cleanly, you already have the skeleton of a publishable calibration appendix.

## Further Practice and Reading

1. PyBaMM official notebook: *Sensitivities and data fitting using PyBaMM*. Bookmark it because it is the canonical reference for the `calculate_sensitivities=True` workflow.
2. PyBaMM official notebook: *Comparing with Experimental Data*. This is the cleanest entry point for the Ecker validation traces.
3. Hallemans et al. (2024), *Physics-based battery model parametrisation from impedance data*, arXiv:2412.10896. Read it for a modern view of why voltage-only fitting is informative but limited.
4. Marquis, S. G., et al. (2019), *An asymptotic derivation of a single particle model with electrolyte*. This remains essential for understanding why reduced-order electrochemical models are so useful in fitting workflows.
5. PyBOP documentation and repository. Do not start there, but do bookmark it for the moment when you are ready to move from point estimation to uncertainty-aware inference.

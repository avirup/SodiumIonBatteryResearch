# Lab Chapter 13: Specialization Tracks

## Chapter Opening

This chapter is the fork in the road.

In the first twelve lab chapters you built the common toolkit: reproducible environments, scientific Python, PyBaMM, parameter estimation, equivalent-circuit modeling, Kalman filtering, aging models, electrothermal coupling, public dataset handling, and full-paper reproduction practice. Those skills are the shared floor of modern battery simulation research. Publishable work, however, rarely stays on the shared floor. A strong project usually becomes strong because it goes deep in one direction: state estimation, safety, machine-learning health prediction, grid storage, vehicle integration, or fast-charging control.

Keep Textbook Chapters 7, 8, 9, 10, 11, 12, and 13 open as you work. Track A operationalizes the estimator design and observability ideas from Textbook Chapter 10. Track B extends the thermal and abuse-modeling ideas from Textbook Chapters 8 and 12. Track C turns the degradation observables from Textbook Chapter 7 into a data-driven health-estimation workflow. Track D connects the cell and pack models from Textbook Chapters 8 and 11 to grid storage studies. Track E connects BMS models to the vehicle-load picture you saw in the systems chapters. Track F turns the fast-charge limits from Textbook Chapters 8, 9, and 13 into an optimal-control problem. You do not need to complete all six tracks before the capstone. You should complete one track carefully, and optionally skim or run another if your capstone proposal crosses boundaries.

The goal is not to make you an expert in six new fields in one chapter. That would be fake confidence, and fake confidence is expensive in research. The goal is to teach you how specialization feels when done properly: define the question, choose the right modeling fidelity, identify what data are available, build a minimal reproducible workflow, compare against a published reference, and write down what is still uncertain. Each track therefore has the same research-method skeleton even though the tools differ.

This chapter also changes the balance between guided work and independent work. Earlier chapters held your hand through nearly every line because the tools were new. Here, the walkthroughs are still complete and runnable, but they are written as launchpads. You will make design choices, record assumptions, and start turning a method into your own capstone. When you feel the work becoming less like a tutorial and more like a small research project, good. That is the point.

For sodium-ion batteries, specialization is especially important. Sodium-ion research has fewer public datasets, fewer validated parameter sets, and fewer mature tool examples than lithium-ion research. That does not make simulation-based SIB work impossible. It means your methodology must be explicit: validate the workflow on lithium-ion benchmark data when necessary, substitute sodium-ion OCV and transport assumptions carefully, and state which conclusions are chemistry-specific versus method-specific. The capstone in Chapter 14 will ask you to do exactly that.

## Prerequisites Check

- Required Python software for all tracks: Python `3.11`, `numpy==1.26.4`, `scipy==1.13.1`, `pandas==2.2.2`, `matplotlib==3.9.0`, `scikit-learn==1.5.0`, `tqdm==4.66.5`, and `jupyterlab==4.2.1`
- Required optional Python software: `pybamm==26.3.1` for Track F, `torch==2.3.1` for Track C, and `cvxpy==1.5.2` for Track D if you want the convex dispatch extension
- Required MATLAB software: MATLAB `R2024b` recommended for Tracks D and E; Simulink and Simscape Electrical are helpful but not required because this chapter includes Python equivalents for the laptop-only path
- Commercial-tool note: COMSOL Battery Design Module is discussed in Track B, but the runnable exercise uses an open Python finite-difference model so the chapter remains usable without a license
- Install command for the base environment: `python -m pip install numpy==1.26.4 scipy==1.13.1 pandas==2.2.2 matplotlib==3.9.0 scikit-learn==1.5.0 tqdm==4.66.5 jupyterlab==4.2.1`
- Install command for optional packages: `python -m pip install pybamm==26.3.1 cvxpy==1.5.2`
- CPU-only PyTorch install command: `python -m pip install torch==2.3.1 torchvision==0.18.1 torchaudio==2.3.1 --index-url https://download.pytorch.org/whl/cpu`
- Required textbook chapters: Textbook Chapters 7, 8, 9, 10, 11, 12, and 13
- Required prior lab chapters: Lab Chapters 1, 2, 7, 8, 9, 10, 11, and 12
- Estimated time: 10 to 16 hours for one track; 30 to 50 hours if you complete three tracks; much longer if you turn a track into the capstone

If your Kalman-filter algebra is shaky, revisit Lab Chapter 7 before Track A. If heat-generation signs and thermal boundary conditions feel slippery, reread Lab Chapter 9 before Track B. If you have not built the dataset loaders from Lab Chapter 11, do that before Track C. If optimization syntax is new, complete the `scipy.optimize` sections from Lab Chapter 2 before Track F.

## Environment Setup

Create one shared environment and one chapter workspace. The workspace is deliberately organized by track so you can run only what you need.

```bash
cd /home/avirup/SodiumIonBatteryResearch
python3.11 -m venv .venv-chapter13
source .venv-chapter13/bin/activate
python -m pip install --upgrade pip
python -m pip install numpy==1.26.4 scipy==1.13.1 pandas==2.2.2 matplotlib==3.9.0 scikit-learn==1.5.0 tqdm==4.66.5 jupyterlab==4.2.1
python -m pip install pybamm==26.3.1 cvxpy==1.5.2
python -m pip install torch==2.3.1 torchvision==0.18.1 torchaudio==2.3.1 --index-url https://download.pytorch.org/whl/cpu
mkdir -p SimulationCompanion/chapter13_specialization_tracks
cd SimulationCompanion/chapter13_specialization_tracks
mkdir -p data figures results track_a_state_estimation track_b_thermal_safety track_c_health_ml track_d_grid_storage track_e_ev_powertrain track_f_fast_charging
```

On Windows PowerShell, activate the environment with:

```powershell
.\.venv-chapter13\Scripts\Activate.ps1
```

Verify the base environment:

```python
import importlib.util

import matplotlib
import numpy as np
import pandas as pd
import scipy
import sklearn

print("NumPy:", np.__version__)
print("SciPy:", scipy.__version__)
print("pandas:", pd.__version__)
print("Matplotlib:", matplotlib.__version__)
print("scikit-learn:", sklearn.__version__)

for package_name in ["pybamm", "torch", "cvxpy"]:
    spec = importlib.util.find_spec(package_name)
    print(f"{package_name}: {'installed' if spec is not None else 'not installed'}")
```

Expected output:

```text
NumPy: 1.26.4
SciPy: 1.13.1
pandas: 2.2.2
Matplotlib: 3.9.0
scikit-learn: 1.5.0
pybamm: installed
torch: installed
cvxpy: installed
```

If PyTorch fails to install, remove Track C from your first pass and continue with another track. PyTorch CPU wheels are large, and network interruptions are common. If `cvxpy` fails because it cannot build a solver dependency, install it in a conda environment instead:

```bash
conda create -n chapter13 python=3.11 numpy scipy pandas matplotlib scikit-learn tqdm jupyterlab cvxpy -c conda-forge
conda activate chapter13
python -m pip install pybamm==26.3.1
```

If PyBaMM fails during Track F, first verify that you can still import `numpy`, `scipy`, and `matplotlib`. Track F includes a fallback equivalent-circuit fast-charge optimizer, so a PyBaMM installation problem should not stop the whole chapter.

## Conceptual Bridge: From General Competence to Specialization

The theory textbook gave you models as structured representations of physical ideas. The first twelve lab chapters gave you tools as structured ways to compute with those models. Specialization begins when the question becomes sharper than the general tool. "Model a battery" is not a research question. "How much does a flat hard-carbon OCV plateau degrade particle-filter SOC observability under current bias?" is a research question. "Can a simple early-cycle feature predict cycle life?" is a research question. "What charging protocol minimizes time while respecting plating and temperature constraints?" is a research question.

Each specialization track in this chapter asks you to make four choices.

First, choose the state variables. In Track A, the state may include SOC, RC polarization voltage, ohmic resistance, and capacity. In Track B, the state may be temperature at grid nodes plus reaction progress variables. In Track C, the "state" is not a physical state in the same sense; it is a learned hidden representation of voltage, capacity, and temperature history. In Track D, the state is energy stored in a grid asset. In Track E, the state includes vehicle speed, battery SOC, and sometimes motor or drivetrain dynamics. In Track F, the state is SOC, temperature, and possibly electrochemical concentration limits. If you cannot say what the state is, you cannot say what your model predicts.

Second, choose the observation. Most battery workflows observe terminal voltage, current, temperature, time, and sometimes capacity. That is sparse. The DFN contains electrolyte concentration and solid diffusion profiles, but a laptop dataset usually does not. Specialization often means learning how to infer hidden quantities from weak observations without pretending that the inference is stronger than it is.

Third, choose the constraint. Publishable simulation work is rarely about producing a curve in isolation. It is about a curve under constraints: voltage limits, temperature limits, computational budget, measurement noise, public data availability, maximum charging time, grid power rating, drive-cycle feasibility, or safety thresholds. The constraint tells you what "better" means.

Fourth, choose the validation target. This is where many student projects become vague. Validation does not require perfect agreement with a famous paper, but it does require a target. You can validate an estimator against synthetic truth, a machine-learning model against held-out cells, a thermal model against a published onset temperature, a grid dispatch model against an energy-balance check, or a fast-charge optimizer against a baseline CCCV protocol. Without validation, the project is a demonstration. With validation, it begins to look like research.

For sodium-ion batteries, these choices are less forgiving. SIB OCV curves can have long hard-carbon plateaus, different hysteresis, different low-temperature behavior, different safety envelopes, and different aging modes. Public sodium-ion datasets may not support the same validation depth as lithium-ion datasets. A careful SIB project therefore often uses a two-layer claim: "The workflow is validated on a lithium-ion benchmark; the sodium-ion case study uses chemistry-specific parameters and is interpreted as a simulation study until better SIB data are available." That sentence is not a weakness. It is honest methodology.

## How to Use This Chapter

Read the six track summaries first. Pick one primary track. Complete its guided walkthrough and open-ended exercises. Then write a one-page capstone pre-proposal using the template near the end of the chapter. If your proposal needs a second tool area, complete a second track lightly. Do not complete all tracks mechanically. Depth beats collection.

| Track | Best for capstone questions about | Main tool pattern | Runnable without paid software |
| --- | --- | --- | --- |
| A: Advanced state estimation | SOC under bias, joint SOC/SOH, parameter drift | Particle filtering and moving-horizon estimation | Yes |
| B: Thermal and safety | abuse heating, thermal runaway onset, pack propagation | Reaction-thermal ODE/PDE models, COMSOL mapping | Yes, with Python fallback |
| C: Data-driven health estimation | SOH prediction, early-cycle features, partial-charge data | Feature engineering and PyTorch sequence models | Yes |
| D: Grid storage applications | dispatch, degradation-aware revenue, renewable smoothing | Energy-balance optimization | Yes |
| E: EV powertrain integration | drive-cycle loading, pack sizing, BMS-in-the-loop studies | Longitudinal vehicle model plus battery ECM | Yes |
| F: Fast charging optimization | charge time, temperature limits, sodium-ion protocol design | Nonlinear optimization and model predictive control | Yes |

## Track A: Advanced State Estimation

### Track A Opening

Track A extends Lab Chapter 7 beyond EKF and UKF. Kalman filters are elegant when the posterior distribution is close to Gaussian and the model is smooth enough for linearization or sigma-point propagation. Battery systems do not always behave that kindly. OCV curves may be flat, current sensors drift, capacity changes slowly, and parameter uncertainty can dominate voltage noise. Particle filters and moving-horizon estimators are two standard responses. A particle filter represents uncertainty by a cloud of weighted samples. Moving-horizon estimation solves a constrained optimization problem over a recent time window.

This track operationalizes Textbook Chapter 10's estimator discussion and the OCV observability warnings from the sodium-ion chapter. The guiding question is simple: when OCV is flat and current bias exists, can a particle filter maintain a credible SOC estimate better than an EKF-style point estimate?

### Guided Walkthrough A1: Particle Filter for SOC and Capacity

**Learning objective:** Implement a bootstrap particle filter that jointly estimates SOC and usable capacity from voltage/current data generated by a simple ECM.

We will generate synthetic truth because particle filtering is easiest to learn when the hidden state is known. The model is a first-order Thevenin ECM:

$$
V_t = U(z) - R_0 I - v_1,
\tag{13.1}
$$

$$
\dot{v}_1 = -\frac{1}{R_1 C_1}v_1 + \frac{1}{C_1} I,
\tag{13.2}
$$

$$
\dot{z} = -\frac{I}{3600 Q}.
\tag{13.3}
$$

Here positive current means discharge. The particle state is $x = [z, v_1, Q]^\top$. Capacity changes very slowly, so we model it as a random walk. This is a teaching shortcut, but it mirrors real joint SOC/SOH estimators.

Create `track_a_state_estimation/particle_filter_soc.py`:

```python
from __future__ import annotations

from dataclasses import dataclass

import matplotlib.pyplot as plt
import numpy as np


@dataclass
class ECMParameters:
    r0_ohm: float = 0.035
    r1_ohm: float = 0.012
    c1_f: float = 2400.0
    nominal_capacity_ah: float = 2.4
    voltage_noise_std_v: float = 0.006


def lithium_like_ocv(soc: np.ndarray) -> np.ndarray:
    soc_clipped = np.clip(soc, 0.0, 1.0)
    return (
        3.05
        + 0.72 * soc_clipped
        + 0.08 * np.tanh((soc_clipped - 0.12) / 0.035)
        - 0.06 * np.tanh((soc_clipped - 0.88) / 0.045)
    )


def sodium_like_ocv(soc: np.ndarray) -> np.ndarray:
    soc_clipped = np.clip(soc, 0.0, 1.0)
    plateau = 2.92 + 0.10 * soc_clipped
    low_soc_knee = 0.18 * np.tanh((soc_clipped - 0.10) / 0.030)
    high_soc_knee = 0.16 * np.tanh((soc_clipped - 0.88) / 0.040)
    return plateau + low_soc_knee + high_soc_knee


def make_current_profile(time_s: np.ndarray) -> np.ndarray:
    current_a = np.zeros_like(time_s)
    for k, t in enumerate(time_s):
        if 300 <= t < 1300:
            current_a[k] = 1.4
        elif 1600 <= t < 2300:
            current_a[k] = -0.8
        elif 2600 <= t < 3800:
            current_a[k] = 1.0
        elif 4200 <= t < 5200:
            current_a[k] = 1.8
        elif 5600 <= t < 6600:
            current_a[k] = -1.0
    return current_a


def simulate_truth(
    time_s: np.ndarray,
    current_a: np.ndarray,
    params: ECMParameters,
    ocv_function,
    seed: int = 7,
) -> dict[str, np.ndarray]:
    rng = np.random.default_rng(seed)
    dt_s = np.diff(time_s, prepend=time_s[0])
    soc = np.zeros_like(time_s)
    v1 = np.zeros_like(time_s)
    capacity_ah = np.zeros_like(time_s)
    voltage_v = np.zeros_like(time_s)

    soc[0] = 0.86
    capacity_ah[0] = 2.20
    v1[0] = 0.0
    voltage_v[0] = ocv_function(np.array([soc[0]]))[0] - params.r0_ohm * current_a[0]

    tau_s = params.r1_ohm * params.c1_f
    for k in range(1, len(time_s)):
        dt = dt_s[k]
        capacity_ah[k] = capacity_ah[k - 1] - 1.2e-8 * abs(current_a[k - 1]) * dt
        soc[k] = soc[k - 1] - current_a[k - 1] * dt / (3600.0 * capacity_ah[k - 1])
        soc[k] = np.clip(soc[k], 0.02, 0.98)
        decay = np.exp(-dt / tau_s)
        v1[k] = decay * v1[k - 1] + params.r1_ohm * (1.0 - decay) * current_a[k - 1]
        clean_voltage = ocv_function(np.array([soc[k]]))[0] - params.r0_ohm * current_a[k] - v1[k]
        voltage_v[k] = clean_voltage + rng.normal(0.0, params.voltage_noise_std_v)

    return {
        "time_s": time_s,
        "current_a": current_a,
        "soc": soc,
        "v1_v": v1,
        "capacity_ah": capacity_ah,
        "voltage_v": voltage_v,
    }


def systematic_resample(weights: np.ndarray, rng: np.random.Generator) -> np.ndarray:
    n_particles = len(weights)
    positions = (rng.random() + np.arange(n_particles)) / n_particles
    cumulative_sum = np.cumsum(weights)
    indexes = np.zeros(n_particles, dtype=int)
    i = 0
    j = 0
    while i < n_particles:
        if positions[i] < cumulative_sum[j]:
            indexes[i] = j
            i += 1
        else:
            j += 1
    return indexes


def run_particle_filter(
    time_s: np.ndarray,
    current_a: np.ndarray,
    voltage_v: np.ndarray,
    params: ECMParameters,
    ocv_function,
    n_particles: int = 3000,
    seed: int = 11,
) -> dict[str, np.ndarray]:
    rng = np.random.default_rng(seed)
    n_steps = len(time_s)
    dt_s = np.diff(time_s, prepend=time_s[0])

    particles = np.zeros((n_particles, 3))
    particles[:, 0] = rng.normal(0.76, 0.08, n_particles)
    particles[:, 1] = rng.normal(0.0, 0.010, n_particles)
    particles[:, 2] = rng.normal(params.nominal_capacity_ah, 0.20, n_particles)
    particles[:, 0] = np.clip(particles[:, 0], 0.01, 0.99)
    particles[:, 2] = np.clip(particles[:, 2], 1.5, 3.0)

    weights = np.full(n_particles, 1.0 / n_particles)
    estimates = np.zeros((n_steps, 3))
    lower = np.zeros((n_steps, 3))
    upper = np.zeros((n_steps, 3))
    effective_n = np.zeros(n_steps)

    tau_s = params.r1_ohm * params.c1_f
    voltage_std = params.voltage_noise_std_v

    for k in range(n_steps):
        if k > 0:
            dt = dt_s[k]
            previous_current = current_a[k - 1]
            decay = np.exp(-dt / tau_s)
            particles[:, 0] -= previous_current * dt / (3600.0 * particles[:, 2])
            particles[:, 1] = decay * particles[:, 1] + params.r1_ohm * (1.0 - decay) * previous_current
            particles[:, 2] += rng.normal(0.0, 2.0e-5, n_particles)
            particles[:, 0] += rng.normal(0.0, 2.0e-4, n_particles)
            particles[:, 1] += rng.normal(0.0, 4.0e-4, n_particles)
            particles[:, 0] = np.clip(particles[:, 0], 0.01, 0.99)
            particles[:, 2] = np.clip(particles[:, 2], 1.5, 3.0)

        predicted_voltage = ocv_function(particles[:, 0]) - params.r0_ohm * current_a[k] - particles[:, 1]
        residual = voltage_v[k] - predicted_voltage
        likelihood = np.exp(-0.5 * (residual / voltage_std) ** 2) + 1.0e-300
        weights *= likelihood
        weights /= np.sum(weights)

        estimates[k] = np.average(particles, axis=0, weights=weights)
        for state_index in range(3):
            lower[k, state_index] = weighted_quantile(particles[:, state_index], weights, 0.05)
            upper[k, state_index] = weighted_quantile(particles[:, state_index], weights, 0.95)

        effective_n[k] = 1.0 / np.sum(weights**2)
        if effective_n[k] < 0.5 * n_particles:
            indexes = systematic_resample(weights, rng)
            particles = particles[indexes]
            weights.fill(1.0 / n_particles)

    return {
        "soc_est": estimates[:, 0],
        "v1_est": estimates[:, 1],
        "capacity_est": estimates[:, 2],
        "soc_lower": lower[:, 0],
        "soc_upper": upper[:, 0],
        "capacity_lower": lower[:, 2],
        "capacity_upper": upper[:, 2],
        "effective_n": effective_n,
    }


def weighted_quantile(values: np.ndarray, weights: np.ndarray, quantile: float) -> float:
    sorter = np.argsort(values)
    values_sorted = values[sorter]
    weights_sorted = weights[sorter]
    cumulative = np.cumsum(weights_sorted)
    return np.interp(quantile, cumulative, values_sorted)


def plot_particle_filter_results(truth: dict[str, np.ndarray], estimate: dict[str, np.ndarray], label: str) -> None:
    time_h = truth["time_s"] / 3600.0
    fig, axes = plt.subplots(4, 1, figsize=(9, 9), sharex=True)

    axes[0].plot(time_h, truth["current_a"], color="black", linewidth=1.3)
    axes[0].set_ylabel("Current (A)")
    axes[0].grid(True, alpha=0.3)

    axes[1].plot(time_h, truth["voltage_v"], color="tab:blue", linewidth=1.2)
    axes[1].set_ylabel("Voltage (V)")
    axes[1].grid(True, alpha=0.3)

    axes[2].plot(time_h, truth["soc"], color="black", linewidth=1.8, label="Truth")
    axes[2].plot(time_h, estimate["soc_est"], color="tab:red", linewidth=1.5, label="Particle filter")
    axes[2].fill_between(
        time_h,
        estimate["soc_lower"],
        estimate["soc_upper"],
        color="tab:red",
        alpha=0.20,
        label="90% interval",
    )
    axes[2].set_ylabel("SOC (-)")
    axes[2].legend(loc="best")
    axes[2].grid(True, alpha=0.3)

    axes[3].plot(time_h, truth["capacity_ah"], color="black", linewidth=1.8, label="Truth")
    axes[3].plot(time_h, estimate["capacity_est"], color="tab:green", linewidth=1.5, label="Estimate")
    axes[3].fill_between(
        time_h,
        estimate["capacity_lower"],
        estimate["capacity_upper"],
        color="tab:green",
        alpha=0.20,
    )
    axes[3].set_xlabel("Time (h)")
    axes[3].set_ylabel("Capacity (Ah)")
    axes[3].legend(loc="best")
    axes[3].grid(True, alpha=0.3)

    fig.suptitle(f"Track A particle filter: {label}")
    fig.tight_layout()
    plt.show()


def main() -> None:
    params = ECMParameters()
    time_s = np.arange(0.0, 7200.0 + 1.0, 2.0)
    current_a = make_current_profile(time_s)

    for label, ocv_function in [
        ("lithium-like sloped OCV", lithium_like_ocv),
        ("sodium-like flat OCV", sodium_like_ocv),
    ]:
        truth = simulate_truth(time_s, current_a, params, ocv_function)
        estimate = run_particle_filter(time_s, current_a, truth["voltage_v"], params, ocv_function)
        soc_rmse = np.sqrt(np.mean((truth["soc"] - estimate["soc_est"]) ** 2))
        capacity_error = estimate["capacity_est"][-1] - truth["capacity_ah"][-1]
        print(f"{label}")
        print(f"  SOC RMSE: {soc_rmse:.4f}")
        print(f"  Final capacity error: {capacity_error:+.4f} Ah")
        print(f"  Median effective particle count: {np.median(estimate['effective_n']):.0f}")
        plot_particle_filter_results(truth, estimate, label)


if __name__ == "__main__":
    main()
```

Run it:

```bash
python track_a_state_estimation/particle_filter_soc.py
```

The script begins by defining two OCV functions. The lithium-like curve has stronger slope over much of the SOC range, which means voltage carries useful information about SOC. The sodium-like curve deliberately contains a flatter mid-SOC plateau, which mimics a common hard-carbon challenge: voltage changes only weakly when SOC changes. This is not a complete sodium-ion OCV model. It is a controlled observability experiment.

The `simulate_truth` function creates the hidden SOC, RC voltage, capacity, and noisy terminal voltage. The `run_particle_filter` function then estimates the hidden state using only time, current, and voltage. The key update is the likelihood calculation: particles whose predicted voltage is close to the measured voltage receive larger weights. The resampling step prevents the filter from carrying thousands of particles with effectively zero weight.

Expected terminal output will vary slightly because the data and filter use random noise, but it should resemble:

```text
lithium-like sloped OCV
  SOC RMSE: 0.0100 to 0.0250
  Final capacity error: within about +/-0.12 Ah
  Median effective particle count: 1500 to 2800
sodium-like flat OCV
  SOC RMSE: 0.0200 to 0.0600
  Final capacity error: often larger than lithium-like case
  Median effective particle count: lower or more variable
```

The plots should contain four stacked panels. The current panel shows discharge pulses above zero and charge pulses below zero. The voltage panel follows those pulses, dropping under discharge and rising under charge. The SOC panel should show the black truth curve and the red particle-filter estimate. The red uncertainty band should widen during low-information periods and narrow when voltage is informative. The capacity panel should move slowly and should not jump sharply; sharp capacity jumps indicate too much process noise or particle collapse.

#### What could go wrong

If the SOC estimate moves in the wrong direction during discharge, your current sign convention is reversed. Equation (13.3) assumes positive current discharges the cell and decreases SOC.

If the uncertainty band collapses to a thin line early and the estimate becomes wrong, the filter is degenerating. Increase `n_particles`, increase process noise slightly, or resample when `effective_n < 0.7 * n_particles`.

If sodium-like and lithium-like results look identical, the OCV functions are probably not being passed correctly. Print `sodium_like_ocv(np.linspace(0.2, 0.8, 5))` and compare it to the lithium-like values.

If the code runs slowly, reduce `n_particles` to `1000` while debugging. Use `3000` or more for final plots.

#### Reflection

This exercise taught you the practical meaning of observability. The particle filter did not magically solve the flat-OCV problem; it represented uncertainty more honestly. That distinction matters. In a sodium-ion paper, a wider posterior under a hard-carbon plateau may be the correct result, not a failure.

### Track A Open-Ended Exercises

1. Add a current-sensor bias state to the particle filter. Hint: the propagation equation should use `current_a[k] + bias_a`, while the terminal voltage equation should also use the biased current in the ohmic drop.
2. Compare the particle filter against the EKF you wrote in Lab Chapter 7 on the same synthetic dataset. Hint: report SOC RMSE and 90% interval coverage, not only a pretty plot.
3. Replace the synthetic OCV curve with a sodium-ion OCV table digitized from a paper or dataset. Hint: use `np.interp` and record the source.

## Track B: Thermal and Safety

### Track B Opening

Track B is about thermal safety modeling without pretending that a laptop exercise is an abuse-test laboratory. Thermal runaway is chemically complex, geometry-dependent, and safety-critical. You should not use a teaching model to make product safety claims. You can, however, use a teaching model to understand the structure of runaway simulations: heat generation, heat removal, Arrhenius reaction rates, onset criteria, and propagation between cells.

COMSOL's Battery Design Module supports high-fidelity battery and pack simulations, including porous-electrode models, heat transfer, short-circuit studies, and thermal runaway propagation using event-based heat sources. That is the commercial tool path. The open path in this track is a finite-difference thermal model with Arrhenius heat release. It teaches the same modeling anatomy: source terms, conduction, convection, and threshold behavior.

### Guided Walkthrough B1: One-Dimensional Thermal Runaway Onset Model

**Learning objective:** Simulate temperature rise in a cell slab with heat loss and an Arrhenius side-reaction source.

We model a slab cell with through-thickness coordinate $x$. Temperature evolves as:

$$
\rho c_p \frac{\partial T}{\partial t}
= k \frac{\partial^2 T}{\partial x^2}
- h_a (T - T_\infty)
+ q_\mathrm{ohmic}
+ H A \exp\left(-\frac{E_a}{RT}\right)(1-\alpha),
\tag{13.4}
$$

$$
\frac{\partial \alpha}{\partial t}
= A \exp\left(-\frac{E_a}{RT}\right)(1-\alpha).
\tag{13.5}
$$

The reaction progress variable $\alpha$ is a teaching abstraction. Real thermal runaway models often use several reactions: SEI decomposition, anode-electrolyte reaction, cathode decomposition, electrolyte decomposition, separator failure, and internal shorting. Equation (13.5) gives us one controllable exothermic process.

Create `track_b_thermal_safety/runaway_slab.py`:

```python
from __future__ import annotations

from dataclasses import dataclass

import matplotlib.pyplot as plt
import numpy as np
from scipy.integrate import solve_ivp


@dataclass
class SlabParameters:
    thickness_m: float = 8.0e-3
    n_nodes: int = 31
    density_kg_m3: float = 2400.0
    heat_capacity_j_kg_k: float = 950.0
    conductivity_w_m_k: float = 0.65
    volumetric_heat_loss_w_m3_k: float = 1.8e4
    ambient_k: float = 298.15
    ohmic_heat_w_m3: float = 1.2e4
    reaction_enthalpy_j_m3: float = 1.8e8
    pre_exponential_1_s: float = 2.0e7
    activation_energy_j_mol: float = 8.5e4
    gas_constant_j_mol_k: float = 8.314462618


def second_derivative_neumann(temperature_k: np.ndarray, dx_m: float) -> np.ndarray:
    padded = np.empty(len(temperature_k) + 2)
    padded[1:-1] = temperature_k
    padded[0] = temperature_k[1]
    padded[-1] = temperature_k[-2]
    return (padded[:-2] - 2.0 * padded[1:-1] + padded[2:]) / dx_m**2


def rhs(_time_s: float, state: np.ndarray, params: SlabParameters) -> np.ndarray:
    n = params.n_nodes
    temperature_k = state[:n]
    alpha = state[n:]
    dx_m = params.thickness_m / (n - 1)

    arrhenius = params.pre_exponential_1_s * np.exp(
        -params.activation_energy_j_mol / (params.gas_constant_j_mol_k * temperature_k)
    )
    reaction_rate = arrhenius * np.clip(1.0 - alpha, 0.0, 1.0)
    reaction_heat = params.reaction_enthalpy_j_m3 * reaction_rate
    conduction = params.conductivity_w_m_k * second_derivative_neumann(temperature_k, dx_m)
    heat_loss = -params.volumetric_heat_loss_w_m3_k * (temperature_k - params.ambient_k)

    dtemperature_dt = (
        conduction + heat_loss + params.ohmic_heat_w_m3 + reaction_heat
    ) / (params.density_kg_m3 * params.heat_capacity_j_kg_k)
    dalpha_dt = reaction_rate
    return np.concatenate([dtemperature_dt, dalpha_dt])


def run_case(ambient_c: float, hot_spot_c: float, ohmic_heat_w_m3: float) -> dict[str, np.ndarray]:
    params = SlabParameters(
        ambient_k=ambient_c + 273.15,
        ohmic_heat_w_m3=ohmic_heat_w_m3,
    )
    x_m = np.linspace(0.0, params.thickness_m, params.n_nodes)
    initial_temperature_k = np.full(params.n_nodes, params.ambient_k)
    center = 0.5 * params.thickness_m
    initial_temperature_k += hot_spot_c * np.exp(-((x_m - center) / 1.5e-3) ** 2)
    initial_alpha = np.zeros(params.n_nodes)
    initial_state = np.concatenate([initial_temperature_k, initial_alpha])

    solution = solve_ivp(
        fun=lambda t, y: rhs(t, y, params),
        t_span=(0.0, 2500.0),
        y0=initial_state,
        method="BDF",
        max_step=2.0,
        rtol=1.0e-6,
        atol=1.0e-8,
        dense_output=False,
    )
    temperature_k = solution.y[: params.n_nodes, :]
    alpha = solution.y[params.n_nodes :, :]
    return {
        "time_s": solution.t,
        "x_m": x_m,
        "temperature_k": temperature_k,
        "alpha": alpha,
        "params": params,
    }


def plot_cases(cases: dict[str, dict[str, np.ndarray]]) -> None:
    fig, axes = plt.subplots(2, 1, figsize=(9, 7), sharex=True)
    for label, result in cases.items():
        max_temperature_c = result["temperature_k"].max(axis=0) - 273.15
        mean_alpha = result["alpha"].mean(axis=0)
        axes[0].plot(result["time_s"] / 60.0, max_temperature_c, linewidth=1.8, label=label)
        axes[1].plot(result["time_s"] / 60.0, mean_alpha, linewidth=1.8, label=label)
    axes[0].axhline(120.0, color="black", linestyle="--", linewidth=1.0, label="120 C marker")
    axes[0].set_ylabel("Maximum temperature (deg C)")
    axes[0].grid(True, alpha=0.3)
    axes[0].legend(loc="best")
    axes[1].set_xlabel("Time (min)")
    axes[1].set_ylabel("Mean reaction progress (-)")
    axes[1].grid(True, alpha=0.3)
    fig.tight_layout()
    plt.show()


def main() -> None:
    cases = {
        "mild: 25 C ambient, 10 C hot spot": run_case(25.0, 10.0, 1.2e4),
        "warm: 45 C ambient, 25 C hot spot": run_case(45.0, 25.0, 1.2e4),
        "abuse: 60 C ambient, 55 C hot spot": run_case(60.0, 55.0, 1.2e4),
    }
    for label, result in cases.items():
        max_temperature_c = result["temperature_k"].max() - 273.15
        final_alpha = result["alpha"].mean(axis=0)[-1]
        print(f"{label}")
        print(f"  Peak temperature: {max_temperature_c:.1f} deg C")
        print(f"  Final mean reaction progress: {final_alpha:.3f}")
    plot_cases(cases)


if __name__ == "__main__":
    main()
```

Run:

```bash
python track_b_thermal_safety/runaway_slab.py
```

The code uses a stiff solver because the Arrhenius source can change quickly once temperature rises. The `second_derivative_neumann` function applies zero-flux boundary conditions at the slab faces. That is a teaching choice. A convective boundary condition would be more physically direct, but the volumetric heat-loss term keeps the first model simple and stable.

Expected output should show the mild case remaining near ambient, the warm case rising modestly, and the abuse case either approaching or crossing the `120 deg C` marker depending on your machine's floating-point path. The plot should have two panels. The first panel shows maximum temperature versus time in minutes. Correct behavior is threshold-like: below a certain initial temperature the heat loss wins, but above it the exothermic term accelerates. The second panel shows mean reaction progress. If reaction progress reaches one immediately in every case, the pre-exponential factor is too large or the activation energy is too low.

#### What could go wrong

If `solve_ivp` fails with a step-size warning, reduce `pre_exponential_1_s` or increase `volumetric_heat_loss_w_m3_k`. Thermal runaway equations can become numerically stiff when the reaction accelerates.

If temperature falls below ambient during ohmic heating, check the sign of `heat_loss`. It should be negative when the cell is warmer than ambient.

If the temperature profile develops sawtooth oscillations across nodes, increase `n_nodes` moderately or reduce `max_step`. Oscillations usually mean the spatial discretization and time step are fighting.

If every case looks safe, raise `ambient_c`, raise `hot_spot_c`, or reduce the heat-loss coefficient. The point of the exercise is to observe threshold behavior, not to calibrate a real cell.

#### Reflection

This exercise gives you the skeleton of abuse modeling: heat source, heat sink, transport, and nonlinear acceleration. In COMSOL, the same terms appear as heat-transfer physics, material properties, events, source terms, and multiphysics couplings. The Python model is not a substitute for a validated safety model, but it makes the commercial-tool interface intelligible.

### Track B Dataset and Reproduction Exercise

Public, machine-readable thermal-runaway datasets are less standardized than cycling datasets. For a reproduction exercise, use a paper with a clearly reported temperature-time curve or onset-temperature comparison and reproduce the qualitative threshold behavior rather than claiming exact safety validation. A practical target is a Semenov-style onset comparison from the thermal-runaway literature, or a COMSOL application-library example if you have a license. COMSOL describes its Battery Design Module as supporting detailed porous-electrode batteries, heat transfer, short-circuiting, pack modeling, and thermal runaway propagation using thermal events. If you use COMSOL, export the maximum cell temperature versus time and compare it against the Python finite-difference model under matched heat-loss and source assumptions.

For a written reproduction, report three things: the original figure and citation, the source terms you included, and the source terms you omitted. "Close enough" means matching the qualitative onset/no-onset boundary and temperature order of magnitude, not matching a proprietary example curve point by point.

### Track B Open-Ended Exercises

1. Replace the volumetric heat-loss term with convective boundary conditions at the two slab surfaces. Hint: modify the ghost nodes in `second_derivative_neumann`.
2. Add a second reaction with a higher onset temperature and larger enthalpy. Hint: duplicate `alpha` into `alpha_1` and `alpha_2`.
3. Build a two-cell propagation model with thermal resistance between cells. Hint: start with two lumped temperatures before returning to a spatial grid.

## Track C: Data-Driven Health Estimation

### Track C Opening

Track C teaches a modern data-driven SOH workflow. Lab Chapter 8 showed capacity-fade models and incremental-capacity analysis. Lab Chapter 11 taught public dataset loading. Here we build a sequence model that predicts remaining useful life from early-cycle summaries. The point is not that neural networks are automatically better than feature engineering. The point is to learn a defensible machine-learning workflow: split by cell, normalize using training data only, compare against a simple baseline, and inspect errors.

The reproduction anchor is Severson et al., "Data-driven prediction of battery cycle life before capacity degradation," published in *Nature Energy* in 2019. The authors used early discharge voltage-curve features from 124 LFP/graphite cells and reported strong cycle-life prediction performance; the data are available through `https://data.matr.io/1`, and associated processing code is public. We will not exactly reproduce their full model here because that belongs in a full Chapter 12 project. We will reproduce the central idea: early-cycle voltage/capacity information contains predictive signal before obvious capacity fade appears.

### Dataset Integration

Preferred dataset: Severson/Attia/MIT-Stanford-Toyota battery cycle-life dataset at `https://data.matr.io/1`. Format: MATLAB `.mat`/HDF5-style batch files and processed structures. License and access terms should be checked on the dataset page when you download it. Size: large enough that you should download it intentionally rather than inside a notebook.

If you already completed Lab Chapter 11, place the processed per-cell summary table in:

```text
SimulationCompanion/chapter13_specialization_tracks/data/severson_cell_summaries.csv
```

The chapter code also creates a synthetic schema-compatible dataset if that file is absent. That fallback lets you learn the machine-learning workflow on a laptop, but it does not support scientific claims.

### Guided Walkthrough C1: LSTM Remaining-Life Predictor

**Learning objective:** Train a small PyTorch LSTM to predict cycle life from the first 100 capacity observations and compare it with a linear baseline.

Create `track_c_health_ml/lstm_cycle_life.py`:

```python
from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import torch
from sklearn.linear_model import Ridge
from sklearn.metrics import mean_absolute_percentage_error, mean_squared_error
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from torch import nn
from torch.utils.data import DataLoader, TensorDataset


DATA_PATH = Path("data/severson_cell_summaries.csv")


def make_synthetic_dataset(seed: int = 42) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    records = []
    n_cells = 124
    for cell_index in range(n_cells):
        true_life = rng.integers(350, 2200)
        early_slope = -rng.lognormal(mean=-7.2, sigma=0.45) * (2100.0 / true_life)
        curvature = -rng.lognormal(mean=-10.0, sigma=0.50) * (2100.0 / true_life)
        initial_capacity = rng.normal(1.10, 0.025)
        for cycle in range(1, 101):
            capacity = (
                initial_capacity
                + early_slope * cycle
                + curvature * cycle**2
                + rng.normal(0.0, 0.0018)
            )
            records.append(
                {
                    "cell_id": f"synthetic_{cell_index:03d}",
                    "cycle_index": cycle,
                    "discharge_capacity_ah": capacity,
                    "cycle_life": true_life,
                }
            )
    return pd.DataFrame.from_records(records)


def load_or_create_data() -> pd.DataFrame:
    if DATA_PATH.exists():
        data = pd.read_csv(DATA_PATH)
        required = {"cell_id", "cycle_index", "discharge_capacity_ah", "cycle_life"}
        missing = required.difference(data.columns)
        if missing:
            raise ValueError(f"{DATA_PATH} is missing columns: {sorted(missing)}")
        print(f"Loaded real summary data from {DATA_PATH}")
        return data
    print("Real Severson/MATR summary file not found; using synthetic teaching data.")
    return make_synthetic_dataset()


def build_sequences(data: pd.DataFrame, n_cycles: int = 100) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    sequences = []
    targets = []
    cell_ids = []
    for cell_id, group in data.groupby("cell_id"):
        ordered = group.sort_values("cycle_index")
        first_cycles = ordered[ordered["cycle_index"].between(1, n_cycles)]
        if len(first_cycles) != n_cycles:
            continue
        capacity = first_cycles["discharge_capacity_ah"].to_numpy(dtype=float)
        normalized_capacity = capacity / capacity[0]
        delta_capacity = normalized_capacity - normalized_capacity[0]
        cycle_axis = np.linspace(0.0, 1.0, n_cycles)
        sequence = np.column_stack([normalized_capacity, delta_capacity, cycle_axis])
        sequences.append(sequence)
        targets.append(float(first_cycles["cycle_life"].iloc[0]))
        cell_ids.append(cell_id)
    return np.stack(sequences), np.asarray(targets), np.asarray(cell_ids)


class CycleLifeLSTM(nn.Module):
    def __init__(self, n_features: int, hidden_size: int = 32) -> None:
        super().__init__()
        self.lstm = nn.LSTM(
            input_size=n_features,
            hidden_size=hidden_size,
            num_layers=1,
            batch_first=True,
        )
        self.regressor = nn.Sequential(
            nn.Linear(hidden_size, 32),
            nn.ReLU(),
            nn.Linear(32, 1),
        )

    def forward(self, sequence: torch.Tensor) -> torch.Tensor:
        output, _hidden = self.lstm(sequence)
        final_hidden = output[:, -1, :]
        return self.regressor(final_hidden).squeeze(-1)


def train_lstm(
    x_train: np.ndarray,
    y_train: np.ndarray,
    x_val: np.ndarray,
    y_val: np.ndarray,
    seed: int = 3,
) -> tuple[CycleLifeLSTM, StandardScaler, StandardScaler]:
    torch.manual_seed(seed)
    feature_scaler = StandardScaler()
    target_scaler = StandardScaler()

    n_train, n_steps, n_features = x_train.shape
    x_train_2d = x_train.reshape(-1, n_features)
    feature_scaler.fit(x_train_2d)
    x_train_scaled = feature_scaler.transform(x_train_2d).reshape(n_train, n_steps, n_features)
    x_val_scaled = feature_scaler.transform(x_val.reshape(-1, n_features)).reshape(
        x_val.shape[0], n_steps, n_features
    )
    y_train_scaled = target_scaler.fit_transform(y_train.reshape(-1, 1)).ravel()
    y_val_scaled = target_scaler.transform(y_val.reshape(-1, 1)).ravel()

    train_dataset = TensorDataset(
        torch.tensor(x_train_scaled, dtype=torch.float32),
        torch.tensor(y_train_scaled, dtype=torch.float32),
    )
    train_loader = DataLoader(train_dataset, batch_size=16, shuffle=True)

    model = CycleLifeLSTM(n_features=n_features)
    optimizer = torch.optim.Adam(model.parameters(), lr=2.0e-3, weight_decay=1.0e-4)
    loss_function = nn.MSELoss()

    x_val_tensor = torch.tensor(x_val_scaled, dtype=torch.float32)
    y_val_tensor = torch.tensor(y_val_scaled, dtype=torch.float32)

    best_state = None
    best_val_loss = np.inf
    patience = 40
    stale_epochs = 0

    for epoch in range(1, 501):
        model.train()
        train_losses = []
        for batch_x, batch_y in train_loader:
            optimizer.zero_grad()
            prediction = model(batch_x)
            loss = loss_function(prediction, batch_y)
            loss.backward()
            optimizer.step()
            train_losses.append(loss.item())

        model.eval()
        with torch.no_grad():
            val_loss = loss_function(model(x_val_tensor), y_val_tensor).item()

        if val_loss < best_val_loss:
            best_val_loss = val_loss
            best_state = {key: value.detach().clone() for key, value in model.state_dict().items()}
            stale_epochs = 0
        else:
            stale_epochs += 1

        if epoch % 50 == 0:
            print(f"Epoch {epoch:03d}: train MSE={np.mean(train_losses):.4f}, val MSE={val_loss:.4f}")

        if stale_epochs >= patience:
            print(f"Early stopping at epoch {epoch}")
            break

    if best_state is not None:
        model.load_state_dict(best_state)

    return model, feature_scaler, target_scaler


def predict_lstm(
    model: CycleLifeLSTM,
    feature_scaler: StandardScaler,
    target_scaler: StandardScaler,
    x: np.ndarray,
) -> np.ndarray:
    n_samples, n_steps, n_features = x.shape
    x_scaled = feature_scaler.transform(x.reshape(-1, n_features)).reshape(n_samples, n_steps, n_features)
    model.eval()
    with torch.no_grad():
        prediction_scaled = model(torch.tensor(x_scaled, dtype=torch.float32)).numpy()
    return target_scaler.inverse_transform(prediction_scaled.reshape(-1, 1)).ravel()


def ridge_baseline(x_train: np.ndarray, y_train: np.ndarray, x_test: np.ndarray) -> np.ndarray:
    features_train = np.column_stack(
        [
            x_train[:, -1, 0],
            x_train[:, -1, 1],
            x_train[:, 9, 0] - x_train[:, 99, 0],
            np.var(x_train[:, :, 1], axis=1),
        ]
    )
    features_test = np.column_stack(
        [
            x_test[:, -1, 0],
            x_test[:, -1, 1],
            x_test[:, 9, 0] - x_test[:, 99, 0],
            np.var(x_test[:, :, 1], axis=1),
        ]
    )
    scaler = StandardScaler()
    features_train_scaled = scaler.fit_transform(features_train)
    features_test_scaled = scaler.transform(features_test)
    model = Ridge(alpha=1.0)
    model.fit(features_train_scaled, y_train)
    return model.predict(features_test_scaled)


def plot_predictions(y_test: np.ndarray, predictions: dict[str, np.ndarray]) -> None:
    fig, ax = plt.subplots(figsize=(6.5, 6.0))
    min_value = min(y_test.min(), *(pred.min() for pred in predictions.values()))
    max_value = max(y_test.max(), *(pred.max() for pred in predictions.values()))
    ax.plot([min_value, max_value], [min_value, max_value], color="black", linewidth=1.0)
    for label, predicted in predictions.items():
        ax.scatter(y_test, predicted, s=42, alpha=0.75, label=label)
    ax.set_xlabel("Observed cycle life (cycles)")
    ax.set_ylabel("Predicted cycle life (cycles)")
    ax.set_title("Track C early-cycle life prediction")
    ax.grid(True, alpha=0.3)
    ax.legend(loc="best")
    fig.tight_layout()
    plt.show()


def main() -> None:
    data = load_or_create_data()
    sequences, targets, cell_ids = build_sequences(data)
    x_train_val, x_test, y_train_val, y_test, ids_train_val, ids_test = train_test_split(
        sequences,
        targets,
        cell_ids,
        test_size=0.20,
        random_state=5,
    )
    x_train, x_val, y_train, y_val = train_test_split(
        x_train_val,
        y_train_val,
        test_size=0.25,
        random_state=6,
    )

    print(f"Cells: train={len(y_train)}, val={len(y_val)}, test={len(y_test)}")
    model, feature_scaler, target_scaler = train_lstm(x_train, y_train, x_val, y_val)
    lstm_pred = predict_lstm(model, feature_scaler, target_scaler, x_test)
    ridge_pred = ridge_baseline(x_train_val, y_train_val, x_test)

    for label, prediction in [("LSTM", lstm_pred), ("Ridge baseline", ridge_pred)]:
        rmse = mean_squared_error(y_test, prediction, squared=False)
        mape = mean_absolute_percentage_error(y_test, prediction) * 100.0
        print(f"{label}: RMSE={rmse:.1f} cycles, MAPE={mape:.1f}%")

    plot_predictions(y_test, {"LSTM": lstm_pred, "Ridge baseline": ridge_pred})


if __name__ == "__main__":
    main()
```

Run:

```bash
python track_c_health_ml/lstm_cycle_life.py
```

The workflow is intentionally strict about splitting by cell. We never allow cycles from the same cell to appear in both training and test sets. The feature scaler is fit on training data only. The target scaler is also fit on training data only. These habits matter more than the LSTM architecture. A fancy model with leaked normalization is not publishable.

Expected output on synthetic data:

```text
Real Severson/MATR summary file not found; using synthetic teaching data.
Cells: train=74, val=25, test=25
Epoch 050: train MSE=0.8123, val MSE=0.9401
Epoch 100: train MSE=0.4218, val MSE=0.6105
LSTM: RMSE=roughly 150 to 350 cycles, MAPE=roughly 10 to 25%
Ridge baseline: RMSE=roughly 120 to 300 cycles, MAPE=roughly 8 to 22%
```

Do not be surprised if the ridge baseline beats the LSTM on small data. That is a lesson, not a failure. The Severson paper's core success came from physically meaningful voltage-curve features and careful model comparison, not from using the largest neural network available.

The prediction plot should show observed cycle life on the horizontal axis and predicted cycle life on the vertical axis. A perfect model lies on the diagonal black line. A common wrong result is a horizontal band, where the model predicts nearly the mean life for every cell. That means the model has not learned useful early-cycle signal.

#### What could go wrong

If PyTorch is not installed, run the CPU-only install command from the prerequisite box. If it still fails, run only the ridge baseline by commenting out the LSTM training block.

If training loss decreases but validation loss explodes, the model is overfitting. Reduce `hidden_size`, increase `weight_decay`, or stop earlier.

If the test error is unrealistically tiny on real data, check for leakage. Make sure `train_test_split` split cells, not individual rows.

If a real summary CSV fails, inspect column names. The required columns are `cell_id`, `cycle_index`, `discharge_capacity_ah`, and `cycle_life`.

#### Reflection

This track teaches the difference between a battery ML demo and a battery ML method. The method is not "train an LSTM." The method is: define the prediction target, build cell-level splits, normalize correctly, compare to a simple model, and interpret errors in the context of battery physics.

### Track C Open-Ended Exercises

1. Replace capacity-only sequences with voltage-curve features from the MATR dataset. Hint: interpolate each discharge curve onto a common capacity grid.
2. Reproduce the qualitative idea of Severson et al. Figure 2 by plotting a voltage-curve difference feature against cycle life. Hint: use cycle 100 minus cycle 10 features.
3. Adapt the workflow to a sodium-ion dataset from Mendeley or Zenodo. Hint: keep the model architecture unchanged and focus on units, cycle labels, and train/test split quality.

## Track D: Grid Storage Applications

### Track D Opening

Track D moves from cell behavior to grid-service behavior. A grid battery is still made of cells, but the research question changes. Instead of asking whether a terminal voltage trace matches a lab test, we ask whether an energy-storage asset can reduce peak load, smooth renewables, provide arbitrage, or operate without excessive degradation. The natural model is an energy-balance model with power limits, efficiency, SOC constraints, and sometimes degradation cost.

This track operationalizes the systems view from Textbook Chapter 11. It is deliberately not a power-flow chapter. We will model a single battery connected to an aggregate load and solar profile. That is enough to learn dispatch logic and create a capstone seed.

### Guided Walkthrough D1: Degradation-Aware Peak Shaving

**Learning objective:** Optimize a battery dispatch schedule that reduces grid peak demand while respecting SOC and power constraints.

Create `track_d_grid_storage/peak_shaving_dispatch.py`:

```python
from __future__ import annotations

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy.optimize import minimize


def make_grid_profile(n_hours: int = 48, seed: int = 21) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    time_h = np.arange(n_hours, dtype=float)
    daily = 1.8 + 0.55 * np.sin(2.0 * np.pi * (time_h - 7.0) / 24.0)
    evening_peak = 0.85 * np.exp(-0.5 * ((time_h % 24.0 - 19.0) / 2.2) ** 2)
    noise = rng.normal(0.0, 0.05, n_hours)
    load_mw = daily + evening_peak + noise
    solar_mw = 1.15 * np.maximum(0.0, np.sin(np.pi * (time_h % 24.0 - 6.0) / 12.0)) ** 1.7
    return pd.DataFrame({"time_h": time_h, "load_mw": load_mw, "solar_mw": solar_mw})


def simulate_soc(
    power_mw: np.ndarray,
    initial_soc: float,
    capacity_mwh: float,
    charge_efficiency: float,
    discharge_efficiency: float,
    dt_h: float,
) -> np.ndarray:
    soc = np.zeros(len(power_mw) + 1)
    soc[0] = initial_soc
    for k, power in enumerate(power_mw):
        if power >= 0.0:
            delta = -power * dt_h / (capacity_mwh * discharge_efficiency)
        else:
            delta = -power * dt_h * charge_efficiency / capacity_mwh
        soc[k + 1] = soc[k] + delta
    return soc


def objective(decision: np.ndarray, net_load_mw: np.ndarray, degradation_weight: float) -> float:
    battery_power_mw = decision[:-1]
    peak_mw = decision[-1]
    grid_power_mw = net_load_mw + battery_power_mw
    peak_penalty = 1.0e4 * np.sum(np.maximum(grid_power_mw - peak_mw, 0.0) ** 2)
    cycling_penalty = degradation_weight * np.sum(np.abs(battery_power_mw))
    return peak_mw + peak_penalty + cycling_penalty


def optimize_dispatch(profile: pd.DataFrame) -> dict[str, np.ndarray]:
    dt_h = 1.0
    capacity_mwh = 4.0
    power_limit_mw = 1.2
    initial_soc = 0.55
    soc_min = 0.15
    soc_max = 0.90
    eta_ch = 0.96
    eta_dis = 0.96
    degradation_weight = 0.012

    net_load_mw = profile["load_mw"].to_numpy() - profile["solar_mw"].to_numpy()
    n = len(net_load_mw)
    initial_peak = np.max(net_load_mw)
    x0 = np.zeros(n + 1)
    x0[-1] = initial_peak

    bounds = [(-power_limit_mw, power_limit_mw)] * n + [(0.0, 5.0)]

    constraints = []
    for step in range(n + 1):
        constraints.append(
            {
                "type": "ineq",
                "fun": lambda x, step=step: simulate_soc(
                    x[:-1], initial_soc, capacity_mwh, eta_ch, eta_dis, dt_h
                )[step]
                - soc_min,
            }
        )
        constraints.append(
            {
                "type": "ineq",
                "fun": lambda x, step=step: soc_max
                - simulate_soc(x[:-1], initial_soc, capacity_mwh, eta_ch, eta_dis, dt_h)[step],
            }
        )

    result = minimize(
        objective,
        x0,
        args=(net_load_mw, degradation_weight),
        method="SLSQP",
        bounds=bounds,
        constraints=constraints,
        options={"maxiter": 800, "ftol": 1.0e-9, "disp": False},
    )
    if not result.success:
        raise RuntimeError(result.message)

    battery_power_mw = result.x[:-1]
    soc = simulate_soc(battery_power_mw, initial_soc, capacity_mwh, eta_ch, eta_dis, dt_h)
    grid_power_mw = net_load_mw + battery_power_mw
    return {
        "battery_power_mw": battery_power_mw,
        "soc": soc,
        "grid_power_mw": grid_power_mw,
        "net_load_mw": net_load_mw,
        "optimized_peak_mw": result.x[-1],
        "baseline_peak_mw": initial_peak,
    }


def plot_dispatch(profile: pd.DataFrame, result: dict[str, np.ndarray]) -> None:
    time_h = profile["time_h"].to_numpy()
    fig, axes = plt.subplots(3, 1, figsize=(9, 8), sharex=True)
    axes[0].plot(time_h, profile["load_mw"], label="Load", linewidth=1.6)
    axes[0].plot(time_h, profile["solar_mw"], label="Solar", linewidth=1.6)
    axes[0].plot(time_h, result["grid_power_mw"], label="Grid after battery", linewidth=1.8)
    axes[0].set_ylabel("Power (MW)")
    axes[0].legend(loc="best")
    axes[0].grid(True, alpha=0.3)

    axes[1].step(time_h, result["battery_power_mw"], where="post", color="tab:red")
    axes[1].axhline(0.0, color="black", linewidth=0.8)
    axes[1].set_ylabel("Battery power (MW)")
    axes[1].grid(True, alpha=0.3)

    axes[2].step(np.arange(len(result["soc"])), result["soc"], where="post", color="tab:green")
    axes[2].set_xlabel("Time (h)")
    axes[2].set_ylabel("SOC (-)")
    axes[2].set_ylim(0.0, 1.0)
    axes[2].grid(True, alpha=0.3)
    fig.tight_layout()
    plt.show()


def main() -> None:
    profile = make_grid_profile()
    result = optimize_dispatch(profile)
    print(f"Baseline peak: {result['baseline_peak_mw']:.3f} MW")
    print(f"Optimized peak: {np.max(result['grid_power_mw']):.3f} MW")
    print(f"Peak reduction: {result['baseline_peak_mw'] - np.max(result['grid_power_mw']):.3f} MW")
    print(f"Final SOC: {result['soc'][-1]:.3f}")
    plot_dispatch(profile, result)


if __name__ == "__main__":
    main()
```

Run:

```bash
python track_d_grid_storage/peak_shaving_dispatch.py
```

The optimization decision contains one battery power value per hour plus one scalar peak target. Positive battery power means discharge into the load, reducing stored energy. Negative power means charging. The objective minimizes the peak target while penalizing violations and adding a small throughput penalty that stands in for degradation cost.

Expected output:

```text
Baseline peak: about 2.4 to 2.8 MW
Optimized peak: lower by about 0.2 to 0.7 MW
Peak reduction: positive
Final SOC: between 0.15 and 0.90
```

The plot should show the battery charging near solar surplus or low-load hours and discharging near evening peaks. The SOC panel should remain inside the allowed range. If SOC hits both bounds aggressively, the battery is being fully used. If SOC barely moves, the degradation penalty is too large or the peak is not binding.

#### What could go wrong

If SLSQP reports incompatible constraints, reduce the requested flexibility by increasing battery capacity or lowering the initial peak target indirectly by leaving the initial guess unchanged.

If the optimizer returns no battery use, set `degradation_weight = 0.0` temporarily. If dispatch appears then, your degradation penalty was dominating the peak objective.

If the grid power is larger after dispatch, inspect the sign convention. In this script positive `battery_power_mw` adds to `net_load_mw` as grid-facing demand because power is defined from grid to battery. If you prefer positive discharge, flip the sign consistently and rename the variable.

#### Reflection

Grid-storage modeling makes the battery part of an economic and operational system. The cell model still matters, but the publication figure is often dispatch, SOC, revenue, peak reduction, or degradation tradeoff. For sodium-ion, this is a natural application space because cost, safety, and stationary storage tolerance may matter more than gravimetric energy density.

### Track D Open-Ended Exercises

1. Add time-of-use energy prices and minimize cost instead of peak. Hint: the energy cost is `sum(price * grid_power * dt)`.
2. Add a degradation cost proportional to squared C-rate. Hint: this penalizes high-power bursts more strongly than throughput.
3. Compare lithium-ion and sodium-ion assumptions by changing round-trip efficiency, usable SOC window, and degradation penalty.

## Track E: EV Powertrain Integration

### Track E Opening

Track E connects BMS-scale battery models to vehicle loads. In an EV study, current is not an arbitrary profile. It is produced by road load, vehicle mass, acceleration, drivetrain efficiency, auxiliary loads, and regenerative braking limits. This track gives you a laptop version of the workflow you would later move into Simulink or Simscape: drive cycle to wheel power, wheel power to battery power, battery power to SOC and voltage.

The model is longitudinal and one-dimensional. That is enough to answer capstone questions about pack sizing, sodium-ion range penalties, low-temperature power limits, or estimator robustness under realistic drive-cycle excitation.

### Guided Walkthrough E1: Drive Cycle to Battery Current

**Learning objective:** Convert a speed trace into battery power, current, voltage, and SOC using a vehicle model plus a Thevenin battery pack.

Create `track_e_ev_powertrain/drive_cycle_pack.py`:

```python
from __future__ import annotations

from dataclasses import dataclass

import matplotlib.pyplot as plt
import numpy as np


@dataclass
class VehicleParameters:
    mass_kg: float = 1650.0
    frontal_area_m2: float = 2.25
    drag_coefficient: float = 0.28
    rolling_resistance: float = 0.010
    air_density_kg_m3: float = 1.20
    wheel_radius_m: float = 0.31
    drivetrain_efficiency: float = 0.91
    regen_efficiency: float = 0.65
    aux_power_w: float = 700.0


@dataclass
class PackParameters:
    capacity_ah: float = 95.0
    nominal_voltage_v: float = 360.0
    resistance_ohm: float = 0.085
    initial_soc: float = 0.82
    min_soc: float = 0.05
    max_regen_power_w: float = 55000.0


def make_drive_cycle(duration_s: int = 1800) -> tuple[np.ndarray, np.ndarray]:
    time_s = np.arange(0, duration_s + 1, 1.0)
    speed_m_s = np.zeros_like(time_s)
    for k, t in enumerate(time_s):
        urban = 10.0 + 7.0 * np.sin(2.0 * np.pi * t / 220.0)
        stop_wave = np.maximum(0.0, np.sin(2.0 * np.pi * t / 95.0))
        highway_burst = 13.0 * np.exp(-0.5 * ((t - 1050.0) / 260.0) ** 2)
        speed_m_s[k] = max(0.0, urban * stop_wave + highway_burst)
    return time_s, speed_m_s


def pack_ocv(soc: np.ndarray, chemistry: str) -> np.ndarray:
    soc_clipped = np.clip(soc, 0.0, 1.0)
    if chemistry == "sodium":
        return 285.0 + 55.0 * soc_clipped + 18.0 * np.tanh((soc_clipped - 0.88) / 0.05)
    return 310.0 + 85.0 * soc_clipped + 12.0 * np.tanh((soc_clipped - 0.12) / 0.04)


def compute_wheel_power(
    time_s: np.ndarray,
    speed_m_s: np.ndarray,
    vehicle: VehicleParameters,
) -> np.ndarray:
    dt_s = np.diff(time_s, prepend=time_s[0])
    dt_s[0] = 1.0
    acceleration_m_s2 = np.gradient(speed_m_s, time_s)
    aero_force_n = 0.5 * vehicle.air_density_kg_m3 * vehicle.drag_coefficient * vehicle.frontal_area_m2 * speed_m_s**2
    rolling_force_n = vehicle.mass_kg * 9.81 * vehicle.rolling_resistance * np.ones_like(speed_m_s)
    inertial_force_n = vehicle.mass_kg * acceleration_m_s2
    wheel_force_n = aero_force_n + rolling_force_n + inertial_force_n
    return wheel_force_n * speed_m_s


def simulate_pack(
    time_s: np.ndarray,
    wheel_power_w: np.ndarray,
    vehicle: VehicleParameters,
    pack: PackParameters,
    chemistry: str,
) -> dict[str, np.ndarray]:
    dt_s = np.diff(time_s, prepend=time_s[0])
    dt_s[0] = 1.0
    soc = np.zeros_like(time_s, dtype=float)
    voltage_v = np.zeros_like(time_s, dtype=float)
    current_a = np.zeros_like(time_s, dtype=float)
    battery_power_w = np.zeros_like(time_s, dtype=float)
    soc[0] = pack.initial_soc

    for k in range(len(time_s)):
        if wheel_power_w[k] >= 0.0:
            battery_power_w[k] = wheel_power_w[k] / vehicle.drivetrain_efficiency + vehicle.aux_power_w
        else:
            regen_power = max(wheel_power_w[k] * vehicle.regen_efficiency, -pack.max_regen_power_w)
            battery_power_w[k] = regen_power + vehicle.aux_power_w

        ocv = pack_ocv(np.array([soc[k]]), chemistry=chemistry)[0]
        discriminant = ocv**2 - 4.0 * pack.resistance_ohm * battery_power_w[k]
        if discriminant <= 0.0:
            current_a[k] = ocv / (2.0 * pack.resistance_ohm)
        else:
            current_a[k] = (ocv - np.sqrt(discriminant)) / (2.0 * pack.resistance_ohm)
        voltage_v[k] = ocv - pack.resistance_ohm * current_a[k]

        if k < len(time_s) - 1:
            soc[k + 1] = soc[k] - current_a[k] * dt_s[k + 1] / (3600.0 * pack.capacity_ah)
            soc[k + 1] = np.clip(soc[k + 1], pack.min_soc, 1.0)

    return {
        "soc": soc,
        "voltage_v": voltage_v,
        "current_a": current_a,
        "battery_power_w": battery_power_w,
    }


def plot_vehicle_results(time_s: np.ndarray, speed_m_s: np.ndarray, results: dict[str, dict[str, np.ndarray]]) -> None:
    time_min = time_s / 60.0
    fig, axes = plt.subplots(4, 1, figsize=(9, 9), sharex=True)
    axes[0].plot(time_min, speed_m_s * 3.6, color="black", linewidth=1.5)
    axes[0].set_ylabel("Speed (km/h)")
    axes[0].grid(True, alpha=0.3)

    for label, result in results.items():
        axes[1].plot(time_min, result["battery_power_w"] / 1000.0, linewidth=1.4, label=label)
        axes[2].plot(time_min, result["voltage_v"], linewidth=1.4, label=label)
        axes[3].plot(time_min, result["soc"], linewidth=1.4, label=label)
    axes[1].set_ylabel("Battery power (kW)")
    axes[2].set_ylabel("Pack voltage (V)")
    axes[3].set_ylabel("SOC (-)")
    axes[3].set_xlabel("Time (min)")
    for ax in axes[1:]:
        ax.legend(loc="best")
        ax.grid(True, alpha=0.3)
    fig.tight_layout()
    plt.show()


def main() -> None:
    vehicle = VehicleParameters()
    lithium_pack = PackParameters(capacity_ah=95.0, nominal_voltage_v=360.0, resistance_ohm=0.080)
    sodium_pack = PackParameters(capacity_ah=88.0, nominal_voltage_v=320.0, resistance_ohm=0.105)
    time_s, speed_m_s = make_drive_cycle()
    wheel_power_w = compute_wheel_power(time_s, speed_m_s, vehicle)
    results = {
        "lithium-ion pack": simulate_pack(time_s, wheel_power_w, vehicle, lithium_pack, "lithium"),
        "sodium-ion pack": simulate_pack(time_s, wheel_power_w, vehicle, sodium_pack, "sodium"),
    }
    for label, result in results.items():
        energy_kwh = np.trapz(result["battery_power_w"], time_s) / 3.6e6
        print(f"{label}")
        print(f"  Energy used: {energy_kwh:.2f} kWh")
        print(f"  Final SOC: {result['soc'][-1]:.3f}")
        print(f"  Minimum voltage: {result['voltage_v'].min():.1f} V")
    plot_vehicle_results(time_s, speed_m_s, results)


if __name__ == "__main__":
    main()
```

Run:

```bash
python track_e_ev_powertrain/drive_cycle_pack.py
```

The code converts speed into acceleration, aerodynamic drag, rolling resistance, and inertial force. Wheel power is then mapped to battery power using drivetrain efficiency and regenerative-braking efficiency. The pack model solves the quadratic relation $P = V I = (U - R I)I$ for current at each time step.

Expected output:

```text
lithium-ion pack
  Energy used: a few kWh
  Final SOC: slightly below 0.82
  Minimum voltage: above 300 V
sodium-ion pack
  Energy used: similar kWh
  Final SOC: lower than lithium case if capacity is lower
  Minimum voltage: lower than lithium case
```

The plot should show speed in the top panel, battery power spikes during acceleration, voltage sag during high-power events, and SOC declining slowly over the 30-minute drive. A wrong result often shows negative SOC change during acceleration, which means the current sign convention or power sign has been flipped.

#### Reflection

This exercise gives your BMS algorithms a realistic load source. It also gives sodium-ion vehicle studies a sober framing: lower pack voltage, different resistance, and lower usable capacity can be studied quantitatively, not only discussed qualitatively.

### Track E Open-Ended Exercises

1. Add road grade to the wheel-force equation. Hint: grade force is $mg\sin(\theta)$.
2. Impose a sodium-ion low-temperature power limit and quantify the drive-cycle speed segments where demanded power exceeds available power.
3. Export the current trace and feed it into the SOC estimator from Track A.

## Track F: Fast Charging Optimization

### Track F Opening

Track F is the most natural bridge into a sodium-ion simulation capstone. Fast charging is a constrained-control problem. The controller wants high current because high current reduces time. The cell objects because voltage, temperature, diffusion gradients, plating risk, and degradation all worsen when current is too aggressive. Lithium-ion fast-charge optimization is a mature field; sodium-ion fast-charge optimization is younger, which makes careful simulation studies valuable.

The reproduction anchor is Attia et al., "Closed-loop optimization of fast-charging protocols for batteries with machine learning," published in *Nature* in 2020. That paper optimized six-step, ten-minute charging protocols using early cycle-life prediction and Bayesian optimization. We will not reproduce the full closed-loop campaign. Instead, we reproduce the protocol-design idea: represent a fast-charge policy as a small number of current steps, evaluate it with a cell model, and compare charging time, temperature rise, and constraint violation.

### Guided Walkthrough F1: Step-Protocol Fast-Charge Optimization

**Learning objective:** Use nonlinear optimization to find a multi-step charging protocol that reaches a target SOC quickly without exceeding voltage and temperature limits.

Create `track_f_fast_charging/fast_charge_optimizer.py`:

```python
from __future__ import annotations

from dataclasses import dataclass

import matplotlib.pyplot as plt
import numpy as np
from scipy.optimize import differential_evolution


@dataclass
class ChargeModel:
    capacity_ah: float = 2.5
    r0_ohm: float = 0.045
    thermal_mass_j_k: float = 520.0
    heat_transfer_w_k: float = 1.15
    ambient_c: float = 25.0
    initial_soc: float = 0.10
    target_soc: float = 0.80
    voltage_limit_v: float = 3.95
    temperature_limit_c: float = 42.0
    max_charge_current_a: float = 7.5


def sodium_ocv(soc: np.ndarray) -> np.ndarray:
    soc_clipped = np.clip(soc, 0.0, 1.0)
    return 2.55 + 0.62 * soc_clipped + 0.10 * np.tanh((soc_clipped - 0.12) / 0.035) + 0.20 * np.tanh((soc_clipped - 0.90) / 0.045)


def simulate_protocol(currents_a: np.ndarray, durations_s: np.ndarray, model: ChargeModel) -> dict[str, np.ndarray]:
    dt_s = 2.0
    time_values = [0.0]
    soc_values = [model.initial_soc]
    temp_values = [model.ambient_c]
    voltage_values = [sodium_ocv(np.array([model.initial_soc]))[0]]
    current_values = [0.0]

    time_s = 0.0
    soc = model.initial_soc
    temperature_c = model.ambient_c

    for current_a, duration_s in zip(currents_a, durations_s):
        n_steps = int(np.ceil(duration_s / dt_s))
        for _ in range(n_steps):
            if soc >= model.target_soc:
                break
            charge_current_a = max(0.0, current_a)
            soc += charge_current_a * dt_s / (3600.0 * model.capacity_ah)
            soc = min(soc, 1.0)
            ocv = sodium_ocv(np.array([soc]))[0]
            voltage_v = ocv + model.r0_ohm * charge_current_a
            heat_w = charge_current_a**2 * model.r0_ohm
            dtemp_dt = (heat_w - model.heat_transfer_w_k * (temperature_c - model.ambient_c)) / model.thermal_mass_j_k
            temperature_c += dtemp_dt * dt_s
            time_s += dt_s
            time_values.append(time_s)
            soc_values.append(soc)
            temp_values.append(temperature_c)
            voltage_values.append(voltage_v)
            current_values.append(-charge_current_a)
        if soc >= model.target_soc:
            break

    return {
        "time_s": np.asarray(time_values),
        "soc": np.asarray(soc_values),
        "temperature_c": np.asarray(temp_values),
        "voltage_v": np.asarray(voltage_values),
        "current_a": np.asarray(current_values),
    }


def protocol_objective(decision: np.ndarray, model: ChargeModel) -> float:
    currents_a = decision[:4]
    durations_s = decision[4:]
    result = simulate_protocol(currents_a, durations_s, model)
    final_soc = result["soc"][-1]
    charge_time_s = result["time_s"][-1]
    voltage_violation = np.maximum(result["voltage_v"] - model.voltage_limit_v, 0.0)
    temp_violation = np.maximum(result["temperature_c"] - model.temperature_limit_c, 0.0)
    soc_shortfall = max(model.target_soc - final_soc, 0.0)
    roughness = np.sum(np.diff(currents_a) ** 2)
    return (
        charge_time_s / 60.0
        + 5000.0 * soc_shortfall**2
        + 800.0 * np.max(voltage_violation) ** 2
        + 30.0 * np.max(temp_violation) ** 2
        + 0.02 * roughness
    )


def optimize_protocol(model: ChargeModel) -> tuple[np.ndarray, np.ndarray, dict[str, np.ndarray]]:
    bounds = [(0.5, model.max_charge_current_a)] * 4 + [(180.0, 900.0)] * 4
    result = differential_evolution(
        lambda x: protocol_objective(x, model),
        bounds=bounds,
        seed=12,
        maxiter=70,
        popsize=12,
        polish=True,
        tol=1.0e-5,
        updating="immediate",
    )
    currents_a = result.x[:4]
    durations_s = result.x[4:]
    simulation = simulate_protocol(currents_a, durations_s, model)
    return currents_a, durations_s, simulation


def make_baseline(model: ChargeModel) -> dict[str, np.ndarray]:
    currents_a = np.array([2.5, 2.5, 2.5, 2.5])
    durations_s = np.array([900.0, 900.0, 900.0, 900.0])
    return simulate_protocol(currents_a, durations_s, model)


def plot_fast_charge(baseline: dict[str, np.ndarray], optimized: dict[str, np.ndarray], model: ChargeModel) -> None:
    fig, axes = plt.subplots(4, 1, figsize=(9, 9), sharex=True)
    for label, result in [("baseline", baseline), ("optimized", optimized)]:
        time_min = result["time_s"] / 60.0
        axes[0].step(time_min, result["current_a"], where="post", linewidth=1.5, label=label)
        axes[1].plot(time_min, result["soc"], linewidth=1.5, label=label)
        axes[2].plot(time_min, result["voltage_v"], linewidth=1.5, label=label)
        axes[3].plot(time_min, result["temperature_c"], linewidth=1.5, label=label)
    axes[2].axhline(model.voltage_limit_v, color="black", linestyle="--", linewidth=1.0)
    axes[3].axhline(model.temperature_limit_c, color="black", linestyle="--", linewidth=1.0)
    axes[0].set_ylabel("Current (A)")
    axes[1].set_ylabel("SOC (-)")
    axes[2].set_ylabel("Voltage (V)")
    axes[3].set_ylabel("Temp. (deg C)")
    axes[3].set_xlabel("Time (min)")
    for ax in axes:
        ax.grid(True, alpha=0.3)
        ax.legend(loc="best")
    fig.tight_layout()
    plt.show()


def main() -> None:
    model = ChargeModel()
    currents_a, durations_s, optimized = optimize_protocol(model)
    baseline = make_baseline(model)
    print("Optimized protocol:")
    for index, (current, duration) in enumerate(zip(currents_a, durations_s), start=1):
        print(f"  Step {index}: {current:.2f} A for {duration / 60.0:.1f} min")
    for label, result in [("baseline", baseline), ("optimized", optimized)]:
        print(label)
        print(f"  Charge time: {result['time_s'][-1] / 60.0:.1f} min")
        print(f"  Final SOC: {result['soc'][-1]:.3f}")
        print(f"  Peak voltage: {result['voltage_v'].max():.3f} V")
        print(f"  Peak temperature: {result['temperature_c'].max():.2f} deg C")
    plot_fast_charge(baseline, optimized, model)


if __name__ == "__main__":
    main()
```

Run:

```bash
python track_f_fast_charging/fast_charge_optimizer.py
```

The optimizer chooses four current levels and four step durations. In the plot, current is negative because the companion's canonical sign convention treats charge current as negative. Inside the optimizer, we use positive `charge_current_a` to keep the charging equations readable, then store the reported current as negative.

Expected output:

```text
Optimized protocol:
  Step 1: high current for several minutes
  Step 2: moderate/high current
  Step 3: lower current as voltage rises
  Step 4: lower or unused step
baseline
  Charge time: longer
  Final SOC: near 0.80
  Peak voltage: below or near 3.95 V
  Peak temperature: below 42 C
optimized
  Charge time: shorter
  Final SOC: near 0.80
  Peak voltage: near the limit
  Peak temperature: near or below the limit
```

The correct optimized result should look like a constrained-control solution: aggressive early, gentler later. If it uses maximum current all the way through while violating voltage and temperature, the penalty weights are too small. If it barely charges, the SOC shortfall penalty is too small.

#### What could go wrong

If optimization is slow, lower `maxiter` to `25` while debugging. Restore it for final runs.

If the optimized protocol is not better than baseline, run again with a different seed. Differential evolution is stochastic.

If voltage exceeds the limit by a large amount, increase the `800.0` penalty multiplier.

If the protocol is physically strange, such as alternating high-low-high-low currents, increase the roughness penalty.

#### Reflection

This is the smallest useful fast-charge optimization loop: parameterize a protocol, simulate it, penalize constraint violations, and compare with a baseline. A publishable version would replace the simple ECM/thermal model with PyBaMM SPMe or DFN, include plating or sodium-specific degradation constraints, and validate the assumptions against experimental data.

### Track F Reproduction Exercise

Reproduce the qualitative structure of Attia et al. Figure 2 from the 2020 closed-loop fast-charging paper: a multi-step charging protocol represented by step currents over a fixed fast-charge window. Your reproduction does not need their proprietary experimental outcome model. It must show:

1. a baseline constant-current protocol,
2. at least three candidate multi-step protocols,
3. the resulting SOC, voltage, and temperature trajectories from your model,
4. a table ranking the protocols by charge time and constraint margin.

Where the paper is ambiguous for your simplified model, document your choice. For example, if you do not know the exact cell resistance, choose a plausible value, run a sensitivity case, and say so. "Close enough" means your reproduction captures the experimental-design logic of multi-step protocol search, not the exact cycle-life results of the original campaign.

### Track F Open-Ended Exercises

1. Replace the ECM with a PyBaMM SPM or SPMe model. Hint: use `pybamm.Experiment` with current steps and read terminal voltage and temperature if thermal coupling is enabled.
2. Add a sodium-ion low-temperature case by setting `ambient_c = 0.0` and changing resistance. Quantify how the optimized protocol changes.
3. Convert the open-loop protocol optimizer into receding-horizon MPC. Hint: optimize only the next four steps, apply the first, update the state, and repeat.

## What Changes for Sodium-Ion?

Sodium-ion specialization is not a find-and-replace operation on lithium-ion workflows. Each track changes in a different way.

In state estimation, hard-carbon OCV plateaus and hysteresis can reduce voltage-based SOC observability. A filter that looks excellent on an NMC/graphite OCV curve may become uncertain or biased on a sodium-ion curve. That does not mean the filter is wrong; it means the measurement is less informative.

In thermal and safety work, sodium-ion cells may offer different abuse behavior depending on cathode, anode, electrolyte, format, and state of charge. You should not claim sodium-ion safety superiority from a generic Arrhenius model. Use the model to structure questions, then cite chemistry-specific abuse data when making claims.

In data-driven health estimation, the largest public benchmark datasets are still lithium-ion. For sodium-ion, use lithium-ion data to validate the workflow and sodium-ion data to test chemistry-specific hypotheses. Keep those claims separate.

In grid storage, sodium-ion assumptions may be favorable: cost, material abundance, safety tolerance, and stationary volume constraints can matter more than gravimetric energy density. Dispatch models are a good place to quantify how much lower efficiency or lower energy density can be tolerated.

In EV integration, sodium-ion penalties show up directly as pack mass, pack volume, voltage sag, power limits, and range. A fair simulation should compare at the pack level, not merely at the cell nominal voltage level.

In fast charging, sodium-ion may benefit from different low-temperature kinetics and may suffer different degradation limits. Replace lithium-specific plating constraints with sodium-specific constraints only when you have a defensible source. If you do not, call the constraint a proxy.

## Chapter Summary and Skill Checklist

- You learned how to choose a specialization track based on a capstone research direction.
- You implemented a particle filter for joint SOC and capacity estimation.
- You simulated thermal-runaway threshold behavior with an open finite-difference model.
- You trained a small LSTM and compared it against a simple health-prediction baseline.
- You optimized a grid battery dispatch schedule under SOC and power constraints.
- You converted a drive cycle into EV battery current, voltage, and SOC.
- You optimized a multi-step sodium-ion fast-charge protocol under voltage and temperature limits.
- You practiced separating workflow validation on lithium-ion data from sodium-ion case-study claims.

Commands, functions, and patterns that should now feel familiar:

- `systematic_resample`, weighted quantiles, and effective particle count
- Arrhenius heat-release terms and stiff `solve_ivp` calls with `method="BDF"`
- cell-level train/validation/test splits for battery ML
- `torch.utils.data.TensorDataset`, `DataLoader`, and early stopping
- constrained dispatch with `scipy.optimize.minimize`
- drive-cycle road-load equations
- protocol optimization with `scipy.optimize.differential_evolution`

You should now be able to:

- Explain why flat OCV regions make SOC estimation harder.
- Build a particle filter and interpret its uncertainty band.
- Write a simple thermal safety model without confusing it for a certified safety tool.
- Train a battery health model without leaking test data into training.
- Formulate a grid-storage dispatch problem with energy and power constraints.
- Generate a battery current profile from a vehicle speed trace.
- Define and optimize a multi-step charging protocol.
- State what must change before a lithium-ion workflow can support a sodium-ion claim.

## Deliverable

The deliverable for this chapter is a completed track-specific project with documentation. Choose one track and create a folder named:

```text
SimulationCompanion/chapter13_specialization_tracks/results/track_<letter>_project
```

Your project folder should contain:

- a runnable script or notebook,
- at least one figure suitable for a technical report,
- a short `README.md` explaining the research question, assumptions, and how to run the code,
- a validation paragraph comparing your result with a baseline or published reference,
- a sodium-ion adaptation paragraph explaining what changed from the lithium-ion or generic workflow.

A good Track F deliverable, for example, would compare CCCV, constant-current, and optimized four-step sodium-ion charging under the same voltage and temperature limits. A good Track A deliverable would compare EKF and particle-filter SOC estimation under a sodium-like OCV plateau and current bias. A good Track C deliverable would reproduce an early-cycle feature plot from the MATR dataset and then test whether the same code can parse a sodium-ion cycling dataset.

## Capstone Pre-Proposal Template

Before starting Chapter 14, write one page using this structure:

```markdown
# Capstone Pre-Proposal

## Working Title

## Primary Track

## Research Question

## Model or Dataset

## Baseline

## Sodium-Ion Adaptation

## Validation Target

## Expected Figure 1

## Main Risk

## Definition of Done
```

The most important lines are `Research Question`, `Baseline`, and `Validation Target`. If those are vague, the capstone will drift. If those are sharp, the rest can evolve.

## Further Practice and Reading

Peter M. Attia, Aditya Grover, Norman Jin, Kristen A. Severson, and coauthors, "Closed-loop optimization of fast-charging protocols for batteries with machine learning," *Nature* 578, 397-402, 2020, https://doi.org/10.1038/s41586-020-1994-5.

Kristen A. Severson, Peter M. Attia, Norman Jin, and coauthors, "Data-driven prediction of battery cycle life before capacity degradation," *Nature Energy* 4, 383-391, 2019, https://doi.org/10.1038/s41560-019-0356-8. Dataset: https://data.matr.io/1.

PyTorch official previous-version installation guide for pinned CPU and CUDA wheels: https://docs.pytorch.org/get-started/previous-versions/.

COMSOL Battery Design Module overview, especially the sections on porous electrodes, battery packs, short-circuiting, and thermal runaway propagation: https://www.comsol.com/battery-design-module.

PyBaMM documentation and examples for replacing the simplified fast-charge model in Track F with SPM, SPMe, or DFN simulations: https://docs.pybamm.org/.

The next chapter is Lab Chapter 14: The Capstone Project.

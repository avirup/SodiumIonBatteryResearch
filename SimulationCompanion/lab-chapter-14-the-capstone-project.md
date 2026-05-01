# Lab Chapter 14: The Capstone Project

## Chapter Opening

This chapter is where the companion stops giving you isolated exercises and asks you to behave like a researcher.

Up to now, each lab chapter has protected you from one kind of chaos. PyBaMM chapters protected you from writing a battery model from scratch before you understood the tool. MATLAB chapters protected you from state-estimation abstraction by letting you build ECMs and filters one piece at a time. Dataset chapters protected you from public-data disorder by teaching file conventions, sign conventions, cycle detection, and reproducible loaders. The reproduction chapter protected you from the false confidence that comes from running only examples written for you.

The capstone removes some of that scaffolding. You will choose a modest sodium-ion research question, position it against the literature, design a simulation study, run an organized set of experiments, analyze the results, and produce four artifacts: a reproducible GitHub-style repository, an 8-12 page technical report in IEEE conference style, a one-page poster, and a research log that records decisions and pivots. The project is intentionally small. It is not supposed to become a dissertation in one chapter. It is supposed to be a complete dry run of the research process.

Keep Textbook Chapter 8 open for physics-based model assumptions, Textbook Chapter 10 open for equivalent-circuit and BMS language, Textbook Chapter 11 open for thermal modeling, and the sodium-ion chapter open for chemistry-specific interpretation. This chapter operationalizes the whole theory textbook, especially the difference between a numerical result and a defensible research claim. A result says, "my script produced a curve." A research claim says, "under these assumptions, with these parameter ranges, this performance metric changes in this direction, and here is why the conclusion survives reasonable checks."

Because many readers will still not have access to sodium-ion laboratory data, the main guided project uses a transparent virtual sodium-ion cell rather than pretending that a public dataset solves every validation problem. We will build a first-order equivalent-circuit model with a hard-carbon-like OCV curve, temperature-dependent resistance, a lumped thermal state, and a protocol runner for discharge and pulse experiments. This model is simpler than a DFN, but it is honest, fast, and fully inspectable. You will use it to study a capstone question that is realistic enough to matter: how do hard-carbon OCV shape, internal resistance, and ambient temperature affect usable energy and voltage-limit behavior under pulsed loads?

That question is not the only valid capstone. It is the worked spine of this chapter. Once you can run it end to end, you can replace the virtual cell with a PyBaMM SPMe or DFN workflow, an ECM identified from CALCE or NASA lithium-ion data, a sodium-ion OCV curve digitized from a paper, or a fast-charge optimization study from Lab Chapter 13. The important thing is not this exact model. The important thing is the research workflow: scope, literature positioning, methodology, organized execution, analysis, figure production, writing, poster design, and self-review.

## Prerequisites Check

- Required software: Python `3.11`, `numpy==1.26.4`, `scipy==1.13.1`, `pandas==2.2.2`, `matplotlib==3.9.0`, `seaborn==0.13.2`, `jinja2==3.1.4`, and `pyyaml==6.0.2`
- Optional software: `pybamm==26.3.1` if you want to extend the capstone with a physics-based simulation; a LaTeX distribution or Overleaf account if you want to compile the IEEE-style report template
- Install command: `python -m pip install numpy==1.26.4 scipy==1.13.1 pandas==2.2.2 matplotlib==3.9.0 seaborn==0.13.2 jinja2==3.1.4 pyyaml==6.0.2`
- Required textbook chapters: Textbook Chapters 8, 10, 11, and the sodium-ion chapter
- Required prior lab chapters: Lab Chapters 1, 2, 4, 6, 9, 11, and 12 are essential; Lab Chapters 3, 5, 7, 8, 10, and 13 are strongly recommended depending on your chosen topic
- Public data background: Lab Chapter 11 for CALCE, NASA, Oxford, Severson/MATR, Mendeley, Zenodo, and sodium-ion data limitations
- Estimated time: 20 to 35 hours for the guided capstone; 40 to 80 hours for a polished independent variant

If your Python ODE workflow feels rusty, revisit Lab Chapter 2 before starting. If equivalent-circuit language feels shaky, revisit Lab Chapter 6. If you are tempted to make the project enormous, reread the scoping section of this chapter twice. Ambition is useful only after the project can still be finished.

## Environment Setup

The capstone environment is deliberately boring. We will use a small stack that is stable, easy to install, and adequate for a publishable-methods dry run. The main model uses `scipy.solve_ivp` rather than a battery-specific solver because the capstone is about research execution, not about hiding the model inside a package. If you extend the project with PyBaMM, use the environment from Lab Chapters 3-5 or 9 and record the version in your research log.

Create a fresh environment from the repository root:

```bash
cd /home/avirup/SodiumIonBatteryResearch
python3.11 -m venv .venv-chapter14
source .venv-chapter14/bin/activate
python -m pip install --upgrade pip
python -m pip install numpy==1.26.4 scipy==1.13.1 pandas==2.2.2 matplotlib==3.9.0 seaborn==0.13.2 jinja2==3.1.4 pyyaml==6.0.2
```

On Windows PowerShell, use:

```powershell
cd C:\path\to\SodiumIonBatteryResearch
py -3.11 -m venv .venv-chapter14
.\.venv-chapter14\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install numpy==1.26.4 scipy==1.13.1 pandas==2.2.2 matplotlib==3.9.0 seaborn==0.13.2 jinja2==3.1.4 pyyaml==6.0.2
```

Create the capstone workspace:

```bash
mkdir -p SimulationCompanion/chapter14_capstone_workspace
cd SimulationCompanion/chapter14_capstone_workspace
mkdir -p config data/raw data/processed figures logs reports src tables
touch logs/research-log.md
```

Verify the installation:

```python
import jinja2
import matplotlib
import numpy as np
import pandas as pd
import scipy
import seaborn as sns
import yaml

print("NumPy:", np.__version__)
print("SciPy:", scipy.__version__)
print("pandas:", pd.__version__)
print("Matplotlib:", matplotlib.__version__)
print("seaborn:", sns.__version__)
print("Jinja2:", jinja2.__version__)
print("PyYAML:", yaml.__version__)

time_s = np.linspace(0.0, 10.0, 6)
voltage_v = 3.1 - 0.02 * time_s
print(pd.DataFrame({"time_s": time_s, "voltage_v": voltage_v}))
```

Expected output:

```text
NumPy: 1.26.4
SciPy: 1.13.1
pandas: 2.2.2
Matplotlib: 3.9.0
seaborn: 0.13.2
Jinja2: 3.1.4
PyYAML: 6.0.2
   time_s  voltage_v
0     0.0       3.10
1     2.0       3.06
2     4.0       3.02
3     6.0       2.98
4     8.0       2.94
5    10.0       2.90
```

Common setup failures are ordinary here. `ModuleNotFoundError` means the notebook kernel is not the environment you installed into. Install a kernel with `python -m ipykernel install --user --name battery-chapter14 --display-name "Battery Chapter 14"` and select it in Jupyter. A plotting backend warning usually means you are running on a headless system; use `plt.savefig(...)` as the chapter code does. A LaTeX compile error is not a Python failure. The report template will still be generated as `.tex`, and you can compile it later in Overleaf.

## Conceptual Bridge: From Labs to a Research Artifact

In the theory textbook, you learned to ask what a battery does. In the lab companion, you learned to ask how a tool represents what the battery does. In the capstone, the question changes again: what can you claim, and why should anyone believe you?

A publishable simulation project has five layers. The first layer is the physical question. For example, "Does a hard-carbon sodium-ion OCV plateau make SOC estimation harder?" or "How much usable energy is lost at low temperature for a pulsed load?" The second layer is the model. This may be an ECM, an SPMe, a DFN, a thermal model, a degradation model, or a hybrid. The third layer is the protocol: what current, voltage limits, temperature boundary conditions, and parameter variations you impose. The fourth layer is the analysis: what metrics you compute and what comparisons you make. The fifth layer is the artifact: code, data, figures, tables, report, poster, and log.

Most weak simulation projects fail by mixing these layers. They change a parameter without saying what physical question it answers. They run a protocol without recording why it was chosen. They show a beautiful voltage curve but never define a metric. They report a finding without checking whether it survives a reasonable perturbation. The capstone workflow keeps the layers separate enough that a reviewer can audit them.

The model in this chapter is a first-order Thevenin ECM with a lumped thermal state. Its states are SOC $z$, RC polarization voltage $v_1$, and cell temperature $T$. We use the discharge-positive current convention from earlier chapters. The continuous-time equations are

$$
\frac{dz}{dt} = -\frac{\eta I(t)}{3600 Q_\mathrm{Ah}},
\tag{14.1}
$$

$$
\frac{dv_1}{dt} = -\frac{v_1}{R_1 C_1} + \frac{I(t)}{C_1},
\tag{14.2}
$$

$$
C_\mathrm{th}\frac{dT}{dt} = I(t)^2\left(R_0(T,z) + R_1\right) - hA\left(T - T_\infty\right).
\tag{14.3}
$$

The terminal voltage is

$$
V(t) = U_\mathrm{ocv}(z,T) - I(t)R_0(T,z) - v_1.
\tag{14.4}
$$

Equation (14.1) is Coulomb counting. Equation (14.2) is the polarization branch you used in Lab Chapter 6. Equation (14.3) is the lumped thermal balance from Lab Chapter 9, simplified to irreversible heat. Equation (14.4) is the ECM voltage equation. This is not a full electrochemical sodium-ion model. It cannot predict electrolyte concentration, particle diffusion, plating, SEI growth, or electrode-specific potentials. That limitation is a feature for the capstone: every assumption is visible.

The sodium-ion content enters through three choices. First, the OCV curve is hard-carbon-like: it includes a sloping region and a low-voltage plateau, rather than borrowing a graphite lithium-ion OCV shape. Second, nominal voltage and voltage limits are sodium-ion-like, roughly 1.5-3.8 V for a generic full cell. Third, the low-temperature resistance penalty is treated as a parameter to sweep, because public SIB validation data are sparse and chemistry-dependent. We will be explicit that the model is a virtual cell calibrated for method development, not a validated commercial cell.

This is standard practice when done honestly. Researchers often use virtual cells to test algorithms, isolate mechanisms, or design experiments before high-quality data exist. The habit to internalize is not "synthetic data are as good as experiments." They are not. The habit is "synthetic studies can support methodological claims when their assumptions, parameter ranges, and validation limits are stated plainly." That distinction will keep your capstone from overclaiming.

## Guided Walkthrough 1: Scope a Capstone as a Testable Research Question

**Learning objective:** Convert a broad sodium-ion interest into a small, testable capstone question with deliverables and decision rules.

Before writing code, we need a project definition that can survive contact with time. The most common capstone failure is starting with a theme instead of a question. "Sodium-ion fast charging" is a theme. "Under a fixed 10-minute pulsed-load profile, how do low-temperature resistance penalty and OCV plateau width change usable delivered energy before a 1.5 V cutoff?" is a question. The second one tells you what to simulate, what to vary, what to measure, and what figure might appear in the report.

Create `config/capstone_scope.yaml`:

```yaml
project:
  title: "Pulsed-load usable energy in a virtual hard-carbon sodium-ion cell"
  short_name: "sib_pulsed_energy_capstone"
  research_question: >
    How do hard-carbon OCV plateau width, internal resistance, and ambient
    temperature affect usable energy and voltage-limit behavior under a
    repeated pulsed discharge load?
  claim_type: "simulation-method dry run with virtual sodium-ion parameters"
  primary_metric: "usable_energy_wh"
  secondary_metrics:
    - "minimum_voltage_v"
    - "peak_temperature_c"
    - "cutoff_time_s"
    - "voltage_sag_v"
  fixed_assumptions:
    cell_capacity_ah: 3.0
    lower_voltage_cutoff_v: 1.5
    upper_voltage_cutoff_v: 3.8
    initial_soc: 1.0
    initial_temperature_c: 25.0
    pulse_current_a: 6.0
    pulse_duration_s: 20.0
    rest_duration_s: 40.0
    number_of_pulses: 60
  factors:
    ambient_temperature_c: [0.0, 25.0, 45.0]
    resistance_scale: [0.8, 1.0, 1.3]
    plateau_width_scale: [0.75, 1.0, 1.25]
  success_criteria:
    - "All simulations finish without numerical failure."
    - "Every figure and table is generated by a script."
    - "The report states that the sodium-ion cell is virtual, not experimentally validated."
    - "At least one sensitivity conclusion is supported by a table and a figure."
```

Now create `src/print_scope.py`:

```python
from pathlib import Path

import yaml


def main() -> None:
    scope_path = Path("config/capstone_scope.yaml")
    with scope_path.open("r", encoding="utf-8") as file:
        scope = yaml.safe_load(file)

    project = scope["project"]
    print("Capstone title:")
    print(project["title"])
    print()
    print("Research question:")
    print(project["research_question"].strip())
    print()
    print("Primary metric:", project["primary_metric"])
    print("Factors:")
    for name, values in project["factors"].items():
        print(f"  - {name}: {values}")
    print()
    print("Success criteria:")
    for criterion in project["success_criteria"]:
        print(f"  - {criterion}")


if __name__ == "__main__":
    main()
```

Run:

```bash
python src/print_scope.py
```

Expected output:

```text
Capstone title:
Pulsed-load usable energy in a virtual hard-carbon sodium-ion cell

Research question:
How do hard-carbon OCV plateau width, internal resistance, and ambient
temperature affect usable energy and voltage-limit behavior under a
repeated pulsed discharge load?

Primary metric: usable_energy_wh
Factors:
  - ambient_temperature_c: [0.0, 25.0, 45.0]
  - resistance_scale: [0.8, 1.0, 1.3]
  - plateau_width_scale: [0.75, 1.0, 1.25]
```

The YAML file is not just configuration. It is a contract with yourself. If halfway through the capstone you want to add degradation, fast charging, pack imbalance, and a neural network estimator, this file reminds you what you promised to finish first. You can write a future-work paragraph later. You cannot write a paper from a project that never converged.

What could go wrong? If `yaml.safe_load` fails, check indentation. YAML is whitespace-sensitive, and tabs are a bad idea. If the script cannot find the file, run it from `SimulationCompanion/chapter14_capstone_workspace`, not from the repository root. If your research question still contains words like "optimize batteries" or "investigate sodium-ion performance" without a metric, rewrite it before coding.

This exercise taught the first capstone habit: a project starts as a falsifiable workflow, not as a folder full of scripts. We will reuse the scope file in later walkthroughs so that the code and report inherit the same assumptions.

## Guided Walkthrough 2: Build the Virtual Sodium-Ion Cell Model

**Learning objective:** Implement a transparent ECM-thermal sodium-ion virtual cell that can be run under arbitrary current profiles.

We now build the model. The code is longer than a notebook toy because it has to become part of a capstone repository. We will use dataclasses for parameters, explicit functions for OCV and resistance, and a single simulation function that returns a tidy `DataFrame`. This is the pattern you want in research code: one well-tested place where the model lives, not duplicated equations scattered across notebooks.

Create `src/sib_virtual_cell.py`:

```python
from __future__ import annotations

from dataclasses import dataclass
from typing import Callable

import numpy as np
import pandas as pd
from scipy.integrate import solve_ivp


@dataclass(frozen=True)
class CellParameters:
    capacity_ah: float = 3.0
    r0_ohm: float = 0.040
    r1_ohm: float = 0.018
    c1_f: float = 2400.0
    thermal_capacity_j_per_k: float = 520.0
    heat_transfer_w_per_k: float = 0.85
    coulombic_efficiency: float = 0.998
    reference_temperature_c: float = 25.0
    resistance_temperature_coeff_per_c: float = 0.022
    resistance_soc_coeff: float = 0.35
    lower_voltage_cutoff_v: float = 1.5
    upper_voltage_cutoff_v: float = 3.8
    plateau_width_scale: float = 1.0
    resistance_scale: float = 1.0


def hard_carbon_ocv(soc: np.ndarray | float, plateau_width_scale: float = 1.0) -> np.ndarray:
    """Return a smooth hard-carbon-like full-cell OCV curve in volts.

    The curve is a virtual sodium-ion OCV shape for methods work. It is not a
    fitted commercial-cell parameterization.
    """
    soc_array = np.asarray(soc, dtype=float)
    z = np.clip(soc_array, 0.0, 1.0)

    low_soc_rise = 0.72 / (1.0 + np.exp(-(z - 0.09) / 0.025))
    plateau = 1.92 + 0.10 * np.tanh((z - 0.28) / (0.16 * plateau_width_scale))
    high_soc_rise = 0.78 / (1.0 + np.exp(-(z - 0.78) / 0.060))
    gentle_slope = 0.30 * z

    return plateau + low_soc_rise + high_soc_rise + gentle_slope


def ohmic_resistance(
    soc: float,
    temperature_c: float,
    parameters: CellParameters,
) -> float:
    """Return SOC- and temperature-dependent ohmic resistance."""
    z = float(np.clip(soc, 0.0, 1.0))
    low_soc_penalty = 1.0 + parameters.resistance_soc_coeff * (1.0 - z) ** 2
    delta_t = parameters.reference_temperature_c - temperature_c
    temperature_penalty = np.exp(parameters.resistance_temperature_coeff_per_c * delta_t)
    return (
        parameters.r0_ohm
        * parameters.resistance_scale
        * low_soc_penalty
        * temperature_penalty
    )


def make_pulsed_current_profile(
    pulse_current_a: float,
    pulse_duration_s: float,
    rest_duration_s: float,
    number_of_pulses: int,
) -> tuple[np.ndarray, np.ndarray]:
    """Create a repeated discharge-pulse/rest current profile."""
    times = [0.0]
    currents = [0.0]
    current_time = 0.0

    for _ in range(number_of_pulses):
        times.extend([current_time, current_time + pulse_duration_s])
        currents.extend([pulse_current_a, pulse_current_a])
        current_time += pulse_duration_s

        times.extend([current_time, current_time + rest_duration_s])
        currents.extend([0.0, 0.0])
        current_time += rest_duration_s

    return np.asarray(times, dtype=float), np.asarray(currents, dtype=float)


def make_constant_current_profile(
    current_a: float,
    duration_s: float,
) -> tuple[np.ndarray, np.ndarray]:
    """Create a constant-current profile with discharge-positive convention."""
    return np.asarray([0.0, duration_s]), np.asarray([current_a, current_a])


def interpolate_current(
    profile_time_s: np.ndarray,
    profile_current_a: np.ndarray,
) -> Callable[[float], float]:
    """Build a zero-order-hold-like current interpolation function."""
    def current_function(time_s: float) -> float:
        return float(np.interp(time_s, profile_time_s, profile_current_a))

    return current_function


def simulate_cell(
    profile_time_s: np.ndarray,
    profile_current_a: np.ndarray,
    parameters: CellParameters,
    ambient_temperature_c: float,
    initial_soc: float = 1.0,
    initial_temperature_c: float = 25.0,
    sample_period_s: float = 1.0,
) -> pd.DataFrame:
    """Simulate the virtual cell and return a tidy time-series table."""
    current = interpolate_current(profile_time_s, profile_current_a)
    end_time_s = float(profile_time_s[-1])
    evaluation_time_s = np.arange(0.0, end_time_s + sample_period_s, sample_period_s)

    def rhs(time_s: float, state: np.ndarray) -> list[float]:
        soc, polarization_v, temperature_c = state
        applied_current_a = current(time_s)
        r0 = ohmic_resistance(soc, temperature_c, parameters)

        dsoc_dt = (
            -parameters.coulombic_efficiency
            * applied_current_a
            / (3600.0 * parameters.capacity_ah)
        )
        dpolarization_dt = (
            -polarization_v / (parameters.r1_ohm * parameters.c1_f)
            + applied_current_a / parameters.c1_f
        )
        heat_generation_w = applied_current_a**2 * (r0 + parameters.r1_ohm)
        heat_rejection_w = parameters.heat_transfer_w_per_k * (
            temperature_c - ambient_temperature_c
        )
        dtemperature_dt = (
            heat_generation_w - heat_rejection_w
        ) / parameters.thermal_capacity_j_per_k

        return [dsoc_dt, dpolarization_dt, dtemperature_dt]

    solution = solve_ivp(
        rhs,
        t_span=(0.0, end_time_s),
        y0=[initial_soc, 0.0, initial_temperature_c],
        t_eval=evaluation_time_s,
        method="BDF",
        rtol=1e-7,
        atol=1e-9,
    )

    if not solution.success:
        raise RuntimeError(f"Cell simulation failed: {solution.message}")

    soc = np.clip(solution.y[0], 0.0, 1.0)
    polarization_v = solution.y[1]
    temperature_c = solution.y[2]
    current_a = np.asarray([current(t) for t in solution.t])
    r0_ohm = np.asarray(
        [
            ohmic_resistance(z, temp_c, parameters)
            for z, temp_c in zip(soc, temperature_c)
        ]
    )
    ocv_v = hard_carbon_ocv(soc, parameters.plateau_width_scale)
    terminal_voltage_v = ocv_v - current_a * r0_ohm - polarization_v
    power_w = terminal_voltage_v * current_a

    frame = pd.DataFrame(
        {
            "time_s": solution.t,
            "current_a": current_a,
            "soc": soc,
            "ocv_v": ocv_v,
            "r0_ohm": r0_ohm,
            "polarization_v": polarization_v,
            "terminal_voltage_v": terminal_voltage_v,
            "temperature_c": temperature_c,
            "ambient_temperature_c": ambient_temperature_c,
            "power_w": power_w,
        }
    )

    frame["energy_wh"] = (
        np.cumsum(frame["power_w"].to_numpy()) * sample_period_s / 3600.0
    )
    frame["below_cutoff"] = (
        frame["terminal_voltage_v"] <= parameters.lower_voltage_cutoff_v
    )
    return frame


def summarize_run(frame: pd.DataFrame, parameters: CellParameters) -> dict[str, float]:
    """Compute capstone metrics for one simulation run."""
    below_cutoff = frame["below_cutoff"].to_numpy()
    if below_cutoff.any():
        cutoff_index = int(np.argmax(below_cutoff))
        usable = frame.iloc[: cutoff_index + 1]
        cutoff_time_s = float(frame.loc[cutoff_index, "time_s"])
    else:
        usable = frame
        cutoff_time_s = float(frame["time_s"].iloc[-1])

    loaded = usable[usable["current_a"] > 0.0]
    if loaded.empty:
        voltage_sag_v = 0.0
    else:
        voltage_sag_v = float(
            (loaded["ocv_v"] - loaded["terminal_voltage_v"]).max()
        )

    return {
        "usable_energy_wh": float(usable["energy_wh"].iloc[-1]),
        "minimum_voltage_v": float(usable["terminal_voltage_v"].min()),
        "peak_temperature_c": float(usable["temperature_c"].max()),
        "cutoff_time_s": cutoff_time_s,
        "final_soc": float(usable["soc"].iloc[-1]),
        "voltage_sag_v": voltage_sag_v,
        "lower_voltage_cutoff_v": parameters.lower_voltage_cutoff_v,
    }
```

Now create a quick sanity script, `src/run_single_case.py`:

```python
from pathlib import Path

import matplotlib.pyplot as plt

from sib_virtual_cell import (
    CellParameters,
    make_pulsed_current_profile,
    simulate_cell,
    summarize_run,
)


def main() -> None:
    Path("data/processed").mkdir(parents=True, exist_ok=True)
    Path("figures").mkdir(parents=True, exist_ok=True)

    parameters = CellParameters()
    profile_time_s, profile_current_a = make_pulsed_current_profile(
        pulse_current_a=6.0,
        pulse_duration_s=20.0,
        rest_duration_s=40.0,
        number_of_pulses=60,
    )

    result = simulate_cell(
        profile_time_s=profile_time_s,
        profile_current_a=profile_current_a,
        parameters=parameters,
        ambient_temperature_c=25.0,
        initial_soc=1.0,
        initial_temperature_c=25.0,
        sample_period_s=1.0,
    )
    result.to_csv("data/processed/single_case_timeseries.csv", index=False)

    summary = summarize_run(result, parameters)
    for key, value in summary.items():
        print(f"{key}: {value:.4f}")

    fig, axes = plt.subplots(4, 1, figsize=(8.0, 8.0), sharex=True)
    axes[0].plot(result["time_s"] / 60.0, result["current_a"], color="tab:blue")
    axes[0].set_ylabel("Current (A)")
    axes[0].grid(True, alpha=0.3)

    axes[1].plot(result["time_s"] / 60.0, result["terminal_voltage_v"], color="tab:red")
    axes[1].axhline(parameters.lower_voltage_cutoff_v, color="black", linestyle="--")
    axes[1].set_ylabel("Voltage (V)")
    axes[1].grid(True, alpha=0.3)

    axes[2].plot(result["time_s"] / 60.0, result["soc"], color="tab:green")
    axes[2].set_ylabel("SOC (-)")
    axes[2].grid(True, alpha=0.3)

    axes[3].plot(result["time_s"] / 60.0, result["temperature_c"], color="tab:orange")
    axes[3].set_ylabel("Temp. (deg C)")
    axes[3].set_xlabel("Time (min)")
    axes[3].grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig("figures/single_case_timeseries.png", dpi=200)
    plt.close(fig)


if __name__ == "__main__":
    main()
```

Run:

```bash
python src/run_single_case.py
```

Expected output will look like this, with small numerical differences depending on SciPy:

```text
usable_energy_wh: 5x.xxxx
minimum_voltage_v: 2.xxxx
peak_temperature_c: 2x.xxxx
cutoff_time_s: 3600.0000
final_soc: 0.33xx
voltage_sag_v: 0.xxxx
lower_voltage_cutoff_v: 1.5000
```

The plot `figures/single_case_timeseries.png` should have four stacked panels. The current panel should show repeated square pulses: 6 A for 20 s, then 0 A for 40 s. The voltage panel should sag during each pulse and partially recover during rest. The SOC panel should decrease only during pulses and flatten during rests. The temperature panel should rise during the pulse train and approach a modest steady value. A wrong result would show SOC increasing during discharge, voltage rising during load, or temperature decreasing below ambient while current is applied.

What could go wrong? If the voltage looks too high, remember that the OCV is a virtual full-cell curve and inspect `hard_carbon_ocv` over SOC. If temperature explodes, your heat-transfer or resistance parameters are too severe. If the solver is slow, increase `sample_period_s` to `2.0` for exploratory work and return to `1.0` for final figures. If the cutoff triggers immediately, check that current is discharge-positive and that the lower cutoff is not accidentally set near the initial voltage.

This exercise taught the second capstone habit: keep the model in a reusable module, run a one-case sanity check, and inspect physical signs before launching a parameter sweep.

## Guided Walkthrough 3: Run an Organized Simulation Study

**Learning objective:** Replace ad-hoc scripting with a reproducible experiment sweep driven by the scope file.

Now we run the actual capstone experiment. The factors are ambient temperature, resistance scale, and plateau-width scale. With three values each, we have 27 runs. That is small enough for a laptop and large enough to support a sensitivity-style figure. The code will save every time series and one summary table. This matters because you should never have to rerun simulations just to make a new plot.

Create `src/run_capstone_sweep.py`:

```python
from itertools import product
from pathlib import Path

import pandas as pd
import yaml

from sib_virtual_cell import (
    CellParameters,
    make_pulsed_current_profile,
    simulate_cell,
    summarize_run,
)


def main() -> None:
    Path("data/processed/timeseries").mkdir(parents=True, exist_ok=True)
    Path("tables").mkdir(parents=True, exist_ok=True)

    with Path("config/capstone_scope.yaml").open("r", encoding="utf-8") as file:
        scope = yaml.safe_load(file)["project"]

    assumptions = scope["fixed_assumptions"]
    factors = scope["factors"]

    profile_time_s, profile_current_a = make_pulsed_current_profile(
        pulse_current_a=assumptions["pulse_current_a"],
        pulse_duration_s=assumptions["pulse_duration_s"],
        rest_duration_s=assumptions["rest_duration_s"],
        number_of_pulses=assumptions["number_of_pulses"],
    )

    summary_rows = []
    run_index = 0

    for ambient_c, resistance_scale, plateau_scale in product(
        factors["ambient_temperature_c"],
        factors["resistance_scale"],
        factors["plateau_width_scale"],
    ):
        run_index += 1
        run_id = (
            f"run_{run_index:03d}_Tamb_{ambient_c:g}_"
            f"R_{resistance_scale:g}_P_{plateau_scale:g}"
        ).replace(".", "p")

        parameters = CellParameters(
            capacity_ah=assumptions["cell_capacity_ah"],
            lower_voltage_cutoff_v=assumptions["lower_voltage_cutoff_v"],
            upper_voltage_cutoff_v=assumptions["upper_voltage_cutoff_v"],
            resistance_scale=float(resistance_scale),
            plateau_width_scale=float(plateau_scale),
        )

        frame = simulate_cell(
            profile_time_s=profile_time_s,
            profile_current_a=profile_current_a,
            parameters=parameters,
            ambient_temperature_c=float(ambient_c),
            initial_soc=assumptions["initial_soc"],
            initial_temperature_c=assumptions["initial_temperature_c"],
            sample_period_s=1.0,
        )
        frame["run_id"] = run_id
        frame["resistance_scale"] = resistance_scale
        frame["plateau_width_scale"] = plateau_scale

        frame.to_csv(f"data/processed/timeseries/{run_id}.csv", index=False)

        summary = summarize_run(frame, parameters)
        summary.update(
            {
                "run_id": run_id,
                "ambient_temperature_c": ambient_c,
                "resistance_scale": resistance_scale,
                "plateau_width_scale": plateau_scale,
            }
        )
        summary_rows.append(summary)
        print(
            f"{run_id}: energy={summary['usable_energy_wh']:.2f} Wh, "
            f"minV={summary['minimum_voltage_v']:.2f} V, "
            f"Tmax={summary['peak_temperature_c']:.1f} C"
        )

    summary_table = pd.DataFrame(summary_rows)
    ordered_columns = [
        "run_id",
        "ambient_temperature_c",
        "resistance_scale",
        "plateau_width_scale",
        "usable_energy_wh",
        "minimum_voltage_v",
        "peak_temperature_c",
        "cutoff_time_s",
        "final_soc",
        "voltage_sag_v",
        "lower_voltage_cutoff_v",
    ]
    summary_table = summary_table[ordered_columns]
    summary_table.to_csv("tables/capstone_summary.csv", index=False)

    print()
    print("Wrote tables/capstone_summary.csv")
    print(summary_table.head())


if __name__ == "__main__":
    main()
```

Run:

```bash
python src/run_capstone_sweep.py
```

Expected output should print 27 lines, one per run. The cold, high-resistance cases should generally have lower minimum voltage, larger voltage sag, and higher resistive heating during pulses. The plateau-width effect may be subtler than resistance or ambient temperature; that itself is a finding. The summary table should contain 27 rows.

This code deserves a block-by-block reading. `itertools.product` is the experiment design: every combination of factor values is run once. The `run_id` encodes the factor values so a CSV file can be traced back to the table without opening metadata. The parameter object is rebuilt for each run rather than mutated in place, which avoids state leakage. The raw time series are saved separately from the summary metrics. That separation is standard practice: figures often need time series, while tables and statistics need summaries.

What could go wrong? If only one or two runs are produced, check YAML indentation under `factors`. If every case has the same result, verify that `resistance_scale` and `plateau_width_scale` are passed into `CellParameters`. If file names contain awkward characters, keep the `.replace(".", "p")` step or use a cleaner run-index-only naming scheme with metadata in the table. If a reviewer later asks for an additional factor level, add it to YAML and rerun the sweep; do not hand-edit `capstone_summary.csv`.

This exercise taught the third capstone habit: organized experimentation is a data product. The sweep script, time-series files, and summary table together are the computational experiment.

## Guided Walkthrough 4: Analyze Results and Produce Publication-Quality Figures

**Learning objective:** Turn simulation outputs into defensible figures, tables, and written findings.

A figure is not decoration. A figure is an argument. In a short technical report, each figure should answer one question. Here we will make three figures: an OCV family plot to show what the plateau-width parameter means, a representative time-series plot to show model behavior, and a heatmap of usable energy to show the main capstone result.

Create `src/make_capstone_figures.py`:

```python
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

from sib_virtual_cell import hard_carbon_ocv


def configure_plots() -> None:
    sns.set_theme(context="paper", style="whitegrid")
    plt.rcParams.update(
        {
            "figure.dpi": 150,
            "savefig.dpi": 300,
            "font.size": 9,
            "axes.labelsize": 9,
            "axes.titlesize": 10,
            "legend.fontsize": 8,
            "xtick.labelsize": 8,
            "ytick.labelsize": 8,
        }
    )


def make_ocv_figure() -> None:
    soc = np.linspace(0.0, 1.0, 400)
    fig, ax = plt.subplots(figsize=(5.4, 3.4))
    for scale in [0.75, 1.0, 1.25]:
        ax.plot(
            soc,
            hard_carbon_ocv(soc, plateau_width_scale=scale),
            linewidth=2.0,
            label=f"Plateau scale {scale:g}",
        )
    ax.set_xlabel("State of charge (-)")
    ax.set_ylabel("Open-circuit voltage (V)")
    ax.set_title("Virtual hard-carbon sodium-ion OCV family")
    ax.legend(frameon=False)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("figures/fig1_ocv_family.png")
    plt.close(fig)


def make_representative_timeseries(summary: pd.DataFrame) -> None:
    nominal = summary[
        (summary["ambient_temperature_c"] == 25.0)
        & (summary["resistance_scale"] == 1.0)
        & (summary["plateau_width_scale"] == 1.0)
    ].iloc[0]
    frame = pd.read_csv(f"data/processed/timeseries/{nominal['run_id']}.csv")

    fig, axes = plt.subplots(3, 1, figsize=(6.4, 5.6), sharex=True)
    time_min = frame["time_s"] / 60.0

    axes[0].plot(time_min, frame["current_a"], color="#1f77b4", linewidth=1.3)
    axes[0].set_ylabel("Current (A)")

    axes[1].plot(time_min, frame["terminal_voltage_v"], color="#d62728", linewidth=1.5)
    axes[1].plot(time_min, frame["ocv_v"], color="#444444", linewidth=1.1, linestyle="--")
    axes[1].axhline(1.5, color="black", linewidth=1.0, linestyle=":")
    axes[1].set_ylabel("Voltage (V)")
    axes[1].legend(["Terminal", "OCV", "Cutoff"], frameon=False, loc="best")

    axes[2].plot(time_min, frame["temperature_c"], color="#ff7f0e", linewidth=1.5)
    axes[2].set_ylabel("Temperature (deg C)")
    axes[2].set_xlabel("Time (min)")

    for ax in axes:
        ax.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig("figures/fig2_nominal_timeseries.png")
    plt.close(fig)


def make_energy_heatmaps(summary: pd.DataFrame) -> None:
    plateau_values = sorted(summary["plateau_width_scale"].unique())
    fig, axes = plt.subplots(1, len(plateau_values), figsize=(9.2, 3.2), sharey=True)

    for ax, plateau_scale in zip(axes, plateau_values):
        subset = summary[summary["plateau_width_scale"] == plateau_scale]
        pivot = subset.pivot(
            index="ambient_temperature_c",
            columns="resistance_scale",
            values="usable_energy_wh",
        )
        sns.heatmap(
            pivot,
            annot=True,
            fmt=".1f",
            cmap="viridis",
            cbar=ax is axes[-1],
            cbar_kws={"label": "Usable energy (Wh)"},
            ax=ax,
        )
        ax.set_title(f"Plateau scale {plateau_scale:g}")
        ax.set_xlabel("Resistance scale")
        ax.set_ylabel("Ambient temp. (deg C)" if ax is axes[0] else "")

    fig.tight_layout()
    fig.savefig("figures/fig3_usable_energy_heatmaps.png")
    plt.close(fig)


def write_ranked_table(summary: pd.DataFrame) -> None:
    ranked = summary.sort_values("usable_energy_wh", ascending=False).copy()
    ranked["usable_energy_wh"] = ranked["usable_energy_wh"].round(2)
    ranked["minimum_voltage_v"] = ranked["minimum_voltage_v"].round(3)
    ranked["peak_temperature_c"] = ranked["peak_temperature_c"].round(2)
    ranked["voltage_sag_v"] = ranked["voltage_sag_v"].round(3)
    ranked.head(10).to_csv("tables/top_10_cases.csv", index=False)
    ranked.tail(10).to_csv("tables/bottom_10_cases.csv", index=False)


def main() -> None:
    Path("figures").mkdir(parents=True, exist_ok=True)
    configure_plots()
    summary = pd.read_csv("tables/capstone_summary.csv")

    make_ocv_figure()
    make_representative_timeseries(summary)
    make_energy_heatmaps(summary)
    write_ranked_table(summary)

    print("Wrote:")
    print("  figures/fig1_ocv_family.png")
    print("  figures/fig2_nominal_timeseries.png")
    print("  figures/fig3_usable_energy_heatmaps.png")
    print("  tables/top_10_cases.csv")
    print("  tables/bottom_10_cases.csv")


if __name__ == "__main__":
    main()
```

Run:

```bash
python src/make_capstone_figures.py
```

Figure 1 should show three smooth OCV curves versus SOC. All curves should have a sodium-ion-like lower nominal voltage than graphite/NMC lithium-ion cells, and the plateau-scale parameter should visibly change the width of the flatter middle region. Figure 2 should show the nominal pulsed current, terminal voltage sagging below OCV during each pulse, and cell temperature rising modestly. Figure 3 should show three heatmaps. The axes are ambient temperature and resistance scale; each panel is a plateau-width scale. Correct heatmaps should show a clear energy penalty as resistance increases, especially in colder conditions. If every heatmap cell has the same number, your sweep did not actually vary the parameters.

Now inspect the top and bottom tables:

```bash
python - <<'PY'
import pandas as pd

print("Top cases")
print(pd.read_csv("tables/top_10_cases.csv")[[
    "ambient_temperature_c",
    "resistance_scale",
    "plateau_width_scale",
    "usable_energy_wh",
    "minimum_voltage_v",
    "peak_temperature_c",
]])

print("\nBottom cases")
print(pd.read_csv("tables/bottom_10_cases.csv")[[
    "ambient_temperature_c",
    "resistance_scale",
    "plateau_width_scale",
    "usable_energy_wh",
    "minimum_voltage_v",
    "peak_temperature_c",
]])
PY
```

The best cases should cluster around warmer ambient temperature and lower resistance scale. The worst cases should cluster around cold ambient temperature and higher resistance scale. Plateau width may reorder cases within those clusters. That gives you the skeleton of a Results paragraph: resistance and temperature dominate usable energy under this protocol; OCV plateau shape changes voltage margin and cutoff timing but is secondary for the selected factor range.

What could go wrong? A heatmap can hide uncertainty by looking more authoritative than the model deserves. Label the model as virtual. If figure text is too small, increase `context` or figure size but do not cram more panels into one figure. If your report has more than one main conclusion per figure, split the figure or simplify the claim. If a trend surprises you, inspect a representative time series before writing a mechanism story.

This exercise taught the fourth capstone habit: analysis is the bridge between simulation and claim. A good figure tells the reader what comparison you made and what changed.

## Guided Walkthrough 5: Generate the Report, Poster Skeleton, and Research Log

**Learning objective:** Create paper-ready artifacts from the same project metadata and results used by the code.

The deliverable is not complete until the written artifacts exist. We will generate a lightweight IEEE-style report template and a poster outline. You will still write the prose yourself, but the script will insert the title, research question, assumptions, factor table, and key result placeholders. This prevents the common failure where the report and code quietly disagree.

Create `src/generate_artifacts.py`:

```python
from datetime import date
from pathlib import Path

import pandas as pd
import yaml
from jinja2 import Template


REPORT_TEMPLATE = r"""
\documentclass[conference]{IEEEtran}
\usepackage{graphicx}
\usepackage{booktabs}
\usepackage{siunitx}
\usepackage{amsmath}

\title{ {{ title }} }
\author{\IEEEauthorblockN{Your Name}
\IEEEauthorblockA{Department of Electrical Engineering\\
Your Institution\\
email@example.com}}

\begin{document}
\maketitle

\begin{abstract}
This capstone studies {{ research_question }} The study uses a transparent
virtual sodium-ion equivalent-circuit and lumped-thermal model. The purpose is
to demonstrate a reproducible simulation research workflow, not to claim
validated performance for a commercial sodium-ion cell.
\end{abstract}

\section{Introduction}
Write one paragraph on why sodium-ion batteries are relevant for cost,
materials availability, safety, or low-temperature applications. Write one
paragraph narrowing the problem to pulsed-load usable energy. End with the
research question and the contribution of this capstone.

\section{Model and Assumptions}
The virtual cell uses a first-order Thevenin model with SOC, polarization
voltage, and lumped cell temperature as states. Current is positive during
discharge. The terminal voltage is
\begin{equation}
V = U_\mathrm{ocv}(z) - I R_0(z,T) - v_1 .
\end{equation}
State clearly that the OCV curve is hard-carbon-like but synthetic. Report the
fixed assumptions in Table~\ref{tab:assumptions}.

\begin{table}[h]
\centering
\caption{Fixed assumptions used in the capstone simulation.}
\label{tab:assumptions}
\begin{tabular}{ll}
\toprule
Quantity & Value \\
\midrule
Capacity & {{ capacity_ah }} Ah \\
Lower voltage cutoff & {{ lower_voltage_cutoff_v }} V \\
Initial SOC & {{ initial_soc }} \\
Pulse current & {{ pulse_current_a }} A \\
Pulse/rest duration & {{ pulse_duration_s }} s / {{ rest_duration_s }} s \\
Number of pulses & {{ number_of_pulses }} \\
\bottomrule
\end{tabular}
\end{table}

\section{Methodology}
Describe the full-factorial sweep over ambient temperature, resistance scale,
and OCV plateau-width scale. State the primary metric, usable delivered energy,
and the secondary metrics: minimum voltage, peak temperature, cutoff time, and
voltage sag.

\section{Results}
Insert Fig.~\ref{fig:ocv}, Fig.~\ref{fig:timeseries}, and
Fig.~\ref{fig:heatmap}. Write the results in comparison language: higher/lower
than, more/less sensitive than, dominated by, limited by.

\begin{figure}[h]
\centering
\includegraphics[width=0.95\linewidth]{../figures/fig1_ocv_family.png}
\caption{Virtual hard-carbon sodium-ion OCV family.}
\label{fig:ocv}
\end{figure}

\begin{figure}[h]
\centering
\includegraphics[width=0.95\linewidth]{../figures/fig2_nominal_timeseries.png}
\caption{Nominal pulsed-load simulation.}
\label{fig:timeseries}
\end{figure}

\begin{figure}[h]
\centering
\includegraphics[width=0.95\linewidth]{../figures/fig3_usable_energy_heatmaps.png}
\caption{Usable energy across the capstone factor sweep.}
\label{fig:heatmap}
\end{figure}

\section{Discussion}
Discuss what the virtual study can and cannot support. Explain why cold
temperature and resistance scaling affect voltage sag. Explain whether plateau
width produced a first-order or second-order effect under this protocol.

\section{Limitations and Future Work}
List the most important limitations: synthetic OCV, no electrode-resolved
physics, no aging, simplified heat generation, and no direct sodium-ion
experimental validation. Then identify one concrete next step.

\section{Conclusion}
State the main finding in one careful sentence. Do not overclaim.

\bibliographystyle{IEEEtran}
\begin{thebibliography}{1}
\bibitem{plett2015}
G. L. Plett, \emph{Battery Management Systems, Volume II: Equivalent-Circuit
Methods}. Artech House, 2015.
\bibitem{pybamm2021}
V. Sulzer et al., ``Python Battery Mathematical Modelling (PyBaMM),''
\emph{Journal of Open Research Software}, vol. 9, no. 1, 2021.
\bibitem{hwang2017}
J.-Y. Hwang, S.-T. Myung, and Y.-K. Sun, ``Sodium-ion batteries: present and
future,'' \emph{Chemical Society Reviews}, vol. 46, pp. 3529--3614, 2017.
\end{thebibliography}

\end{document}
"""


POSTER_TEMPLATE = """# {{ title }}

## Research Question
{{ research_question }}

## Why It Matters
Write three short sentences: sodium-ion motivation, pulsed-load relevance, and
why simulation helps before experimental data are available.

## Method
- Virtual hard-carbon-like sodium-ion ECM plus lumped thermal model
- Full-factorial sweep over ambient temperature, resistance scale, and OCV
  plateau-width scale
- Primary metric: {{ primary_metric }}

## Main Figures
1. OCV family
2. Nominal pulsed-load time series
3. Usable-energy heatmaps

## Key Result
Replace this paragraph with your strongest quantitative comparison from
tables/top_10_cases.csv and tables/bottom_10_cases.csv.

## Limitations
Synthetic OCV, no electrode-resolved validation, simplified thermal model, and
no direct sodium-ion experimental dataset.

## Next Step
Replace the virtual OCV/resistance assumptions with a digitized or measured
sodium-ion cell dataset.
"""


def append_log(scope: dict, summary: pd.DataFrame) -> None:
    log_path = Path("logs/research-log.md")
    best = summary.sort_values("usable_energy_wh", ascending=False).iloc[0]
    worst = summary.sort_values("usable_energy_wh", ascending=True).iloc[0]
    entry = f"""

## {date.today().isoformat()} - Capstone sweep completed

Research question: {scope["research_question"].strip()}

The full-factorial sweep produced {len(summary)} runs. The best usable-energy
case was `{best["run_id"]}` with {best["usable_energy_wh"]:.2f} Wh. The lowest
usable-energy case was `{worst["run_id"]}` with {worst["usable_energy_wh"]:.2f}
Wh. The current interpretation is that resistance scaling and ambient
temperature dominate the selected pulsed-load protocol. This needs to be stated
as a virtual-cell result, not as a validated sodium-ion performance claim.
"""
    with log_path.open("a", encoding="utf-8") as file:
        file.write(entry)


def main() -> None:
    Path("reports").mkdir(parents=True, exist_ok=True)

    with Path("config/capstone_scope.yaml").open("r", encoding="utf-8") as file:
        scope = yaml.safe_load(file)["project"]

    assumptions = scope["fixed_assumptions"]
    summary = pd.read_csv("tables/capstone_summary.csv")

    report_context = {
        "title": scope["title"],
        "research_question": scope["research_question"].strip(),
        "primary_metric": scope["primary_metric"],
        **assumptions,
    }
    report_text = Template(REPORT_TEMPLATE).render(**report_context)
    poster_text = Template(POSTER_TEMPLATE).render(
        title=scope["title"],
        research_question=scope["research_question"].strip(),
        primary_metric=scope["primary_metric"],
    )

    Path("reports/capstone_report.tex").write_text(report_text.strip() + "\n", encoding="utf-8")
    Path("reports/capstone_poster_outline.md").write_text(poster_text, encoding="utf-8")
    append_log(scope, summary)

    print("Wrote reports/capstone_report.tex")
    print("Wrote reports/capstone_poster_outline.md")
    print("Appended logs/research-log.md")


if __name__ == "__main__":
    main()
```

Run:

```bash
python src/generate_artifacts.py
```

You should now have `reports/capstone_report.tex`, `reports/capstone_poster_outline.md`, and a research-log entry. The report will not be finished. It is a scaffold with the correct sections, figures, assumptions, and citations. Your job is to turn placeholders into argument. The poster outline is deliberately sparse because a poster is not a compressed paper. It needs one research question, one method block, one main result, and one honest limitation.

What could go wrong? If the report cannot find figures when compiled, remember that LaTeX paths are relative to the report file. The template uses `../figures/...` because `capstone_report.tex` lives in `reports/`. If Jinja2 reports an undefined variable, check that the YAML assumption name matches the template name. If your research log remains empty, confirm that `tables/capstone_summary.csv` exists before running the artifact generator.

This exercise taught the fifth capstone habit: write artifacts from the same metadata that drives the code. Consistency is not a moral virtue; it is an engineering practice.

## Dataset Integration: Using Public Data Without Pretending It Is Sodium-Ion Validation

For this capstone, public lithium-ion datasets are useful for workflow validation and scale checking, not for sodium-ion chemistry validation. CALCE HPPC data can help you compare whether your virtual resistance and polarization magnitudes are plausible. NASA aging data can help you practice extracting capacity and temperature traces. Oxford and Severson/MATR data can help you benchmark cycle-life feature workflows. None of those datasets proves a sodium-ion claim.

If you want to include a public-data appendix, use the loader from Lab Chapter 11 and add a short script that computes voltage sag during pulses from a CALCE HPPC file. The columns should be normalized to `time_s`, `current_a`, `voltage_v`, and `temperature_c`. Compute pulse sag as the difference between pre-pulse rest voltage and loaded voltage after a fixed delay. Then compare the order of magnitude with `voltage_sag_v` from this capstone. The comparison can say, "the virtual cell's pulse sag is within the broad range seen in public 18650 lithium-ion HPPC data." It cannot say, "the sodium-ion model is validated."

For sodium-ion data, search Mendeley Data, Zenodo, and journal supplementary information using terms such as `sodium-ion battery OCV`, `hard carbon full cell cycling data`, `Na-ion pouch cell pulse`, and the specific cathode chemistry. Record the URL, license, file size, instrument if stated, temperature, voltage limits, and current sign convention. If the only available information is a plot in a PDF, use WebPlotDigitizer and cite the original paper. Treat digitized curves as approximate: report that they were digitized, include the digitization file, and avoid overfitting.

## Reproduction Exercise: Reproduce a Published OCV Shape Qualitatively

For the Part VI reproduction requirement, use this chapter to reproduce a qualitative hard-carbon sodium-ion OCV feature rather than an entire paper. Read Hwang, Myung, and Sun, "Sodium-ion batteries: present and future," *Chemical Society Reviews*, 2017, and one recent hard-carbon full-cell or half-cell paper relevant to your chosen chemistry. Identify a figure showing the sloping-plus-plateau voltage behavior of hard carbon or a sodium-ion full cell. Your task is not to copy the data exactly unless the source provides numerical data. Your task is to tune `hard_carbon_ocv` so that the simulated curve has the same qualitative regions: low-SOC rise, plateau or quasi-plateau, high-SOC rise, and realistic full-cell voltage range.

Document the reproduction in `logs/research-log.md`. Include the citation, figure number, whether data were available or digitized, what you changed in the OCV function, and what mismatch remains. "Close enough" means the curve supports the capstone mechanism being studied. If your claim depends on the exact derivative $dU/dz$, qualitative reproduction is not enough; you must digitize or obtain the original data.

This exercise is valuable because it forces you to separate visual mechanism matching from validation. A sodium-ion OCV curve borrowed from the literature can make a virtual study more realistic, but it does not validate resistance, thermal behavior, aging, or dynamic polarization.

## What Changes for Sodium-Ion?

Sodium-ion changes the capstone in four practical ways. First, parameter availability is weaker. You may find OCV curves and cycling summaries, but full DFN parameter sets with transport, kinetic, and thermodynamic functions are much rarer than for common lithium-ion chemistries. Second, hard-carbon OCV shapes can have broad plateaus that reduce voltage sensitivity to SOC in some ranges, which matters for SOC estimation, pulse recovery interpretation, and voltage-limit control. Third, nominal voltage and energy density differ, so direct Wh comparisons to lithium-ion must be framed carefully. Fourth, validation strategy changes: you will often validate the workflow on lithium-ion benchmark data, then use sodium-ion-specific literature only for the chemistry-sensitive pieces.

For a publishable sodium-ion simulation paper, be painfully explicit about which parameters are sodium-ion-specific, which are borrowed analogues, which are fitted, and which are varied in sensitivity analysis. Reviewers are usually tolerant of sparse data when the uncertainty is acknowledged. They are much less tolerant of lithium-ion assumptions silently relabeled as sodium-ion.

## Open-Ended Exercises

### Exercise 1: Add a constant-current discharge comparison

Modify the sweep so each parameter combination is simulated under both the pulsed profile and a constant-current discharge with the same average current. Hint: the pulsed profile uses 6 A for one-third of the time, so the average current is 2 A. Add a column named `protocol` to the summary table.

Worked solution outline: use `make_constant_current_profile(current_a=2.0, duration_s=3600.0)` and wrap the existing sweep body in a loop over two protocol definitions. Save time series under file names that include `protocol`.

### Exercise 2: Replace the synthetic OCV curve with digitized data

Find a sodium-ion OCV or low-rate voltage curve in a paper or dataset. Use WebPlotDigitizer to export SOC and voltage points as CSV. Replace `hard_carbon_ocv` with an interpolation function using `np.interp`. Hint: enforce monotonic SOC ordering and clip extrapolation at the endpoints.

Worked solution outline: read the CSV with pandas, sort by SOC, normalize SOC to 0-1 if necessary, and write `return np.interp(z, soc_points, voltage_points)`. Add the source citation and digitization notes to the research log.

### Exercise 3: Add one uncertainty band

Choose one uncertain scalar parameter, such as `r0_ohm` or `heat_transfer_w_per_k`, and run five values around the nominal value. Plot usable energy as a band rather than a single heatmap value. Hint: keep the original three-factor sweep fixed and add uncertainty only for the nominal plateau scale to avoid a runaway experiment count.

Worked solution outline: create a second sweep script named `run_uncertainty_sweep.py`, vary `r0_ohm` over `[0.032, 0.036, 0.040, 0.044, 0.048]`, group by ambient temperature and resistance scale, and plot minimum-to-maximum usable energy with `fill_between`.

### Exercise 4: Write the self-review before polishing the report

Before editing prose, write a one-page reviewer report on your own capstone. Use three headings: "Major concerns," "Minor concerns," and "What would make the claim stronger." Hint: if you cannot find any major concerns, you are being too friendly to yourself.

Worked solution outline: at least one major concern should mention the virtual nature of the sodium-ion parameters. Another should mention missing experimental validation. A strong minor concern might mention the simplified heat-generation model. A constructive strengthening step might be replacing the OCV curve with digitized data or adding a PyBaMM comparison.

## Chapter Summary and Skill Checklist

- You scoped a capstone question tightly enough to finish.
- You wrote project assumptions and factors in a machine-readable YAML file.
- You implemented a virtual sodium-ion ECM plus thermal model in reusable Python code.
- You ran a full-factorial simulation sweep and saved both time series and summary metrics.
- You produced publication-style figures and ranked result tables.
- You generated report and poster scaffolds from project metadata.
- You practiced sodium-ion-specific caution: virtual parameters are useful, but they are not validation.

Commands and functions that should now be in muscle memory:

- `python src/print_scope.py`
- `python src/run_single_case.py`
- `python src/run_capstone_sweep.py`
- `python src/make_capstone_figures.py`
- `python src/generate_artifacts.py`
- `CellParameters`
- `simulate_cell`
- `summarize_run`
- `pd.read_csv`
- `DataFrame.to_csv`
- `plt.savefig`

You should now be able to:

- Define a simulation research question with explicit metrics and factors.
- Keep assumptions, code, figures, tables, and writing synchronized.
- Build a small but complete computational experiment repository.
- Explain what a virtual sodium-ion model can and cannot claim.
- Produce a short IEEE-style report skeleton from your results.
- Review your own work with enough skepticism to improve it before someone else does.

## Deliverable

The deliverable is a complete capstone package:

- A GitHub-style repository folder with reproducible code
- A short technical report, 8-12 pages in IEEE conference structure
- A one-page poster or poster outline
- A research log documenting decisions, failures, and pivots

For the guided capstone, the repository is `SimulationCompanion/chapter14_capstone_workspace`. A strong submission contains the `config`, `src`, `tables`, `figures`, `reports`, and `logs` folders; a `README.md` explaining how to rerun the project; and a report that states one careful finding supported by Figure 3 and the ranked tables. Do not bury the limitation that the sodium-ion cell is virtual. Put it in the abstract, methods, and discussion. That honesty makes the project stronger, not weaker.

## Further Practice and Reading

Read Plett's *Battery Management Systems, Volume II* for equivalent-circuit modeling discipline, especially the habit of validating against held-out data. Bookmark the PyBaMM documentation and Sulzer et al.'s PyBaMM paper if you extend the capstone to SPMe or DFN simulations. Read Hwang, Myung, and Sun's 2017 *Chemical Society Reviews* article for sodium-ion context and chemistry-specific caution. For public data practice, return to the CALCE Battery Data Archive, NASA PCoE battery aging data, Oxford Battery Degradation Dataset, and the Severson/MATR fast-charge dataset from Lab Chapter 11. Community resources worth keeping close are the PyBaMM GitHub repository, the PyBaMM discussion forum or Discord, MATLAB File Exchange examples for battery ECMs, and reproducibility checklists from journals in energy storage and computational modeling.

The next chapter is beyond the planned companion: at this point you should either polish the capstone into a submission-quality internal report or branch it into a real research project with stronger sodium-ion data, a physics-based model, or an experimentally validated parameter set.

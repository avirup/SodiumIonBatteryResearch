# Lab Chapter 10: Bridging PyBaMM and MATLAB

## Chapter Opening

This chapter is about moving without losing meaning.

Up to now, we have used Python and MATLAB as mostly separate laboratories. PyBaMM gave us physics-based models, experiments, parameter sets, internal electrochemical variables, degradation options, and thermal coupling. MATLAB gave us the BMS habits that working engineers reach for: equivalent-circuit identification, Kalman filters, validation scripts, tables, and eventually Simulink and Simscape Battery. In real publishable work, those worlds rarely stay separate. You may generate a virtual cell in PyBaMM, identify a BMS-ready model in MATLAB, validate it against a held-out protocol, and then return to Python to build publication figures and archive machine-readable results.

Keep Textbook Chapter 8 open for the DFN and SPMe model context, Textbook Chapter 10 open for equivalent-circuit modeling, and the sodium-ion chapter nearby for chemistry-specific cautions. This chapter operationalizes an idea that has appeared quietly throughout the companion: a model is only useful if its assumptions, data conventions, and units survive the trip from one tool to another. PyBaMM and MATLAB can both store voltage and current, but that does not mean they agree about sign convention, interpolation, time base, variable names, solver tolerances, file formats, or reproducibility habits.

By the end of this chapter you will build a complete virtual-cell workflow. PyBaMM will run a physics-based simulation under two protocols: an identification protocol and a held-out validation protocol. Python will export the resulting data to CSV, HDF5, and MATLAB `.mat` formats. MATLAB will load the exported data, identify a first-order Thevenin ECM, simulate the identified ECM on the validation current, and write the validation result back to disk. Finally, a master Python script will call the MATLAB script through the MATLAB Engine API when MATLAB is available, fall back to a command-line MATLAB call when appropriate, and produce a final comparison figure and RMSE report.

This is publishable-research skill because reviewers do not care that your model worked on your laptop once. They care whether someone can understand the workflow, rerun it, and audit each translation step. If a PyBaMM voltage trace is used as synthetic truth and a MATLAB ECM is used as a reduced-order surrogate, your paper must make the interface explicit. Which current sign convention did you use? Which variables were exported? Was the ECM fit on the same protocol used for validation? Did you interpolate the PyBaMM output onto a uniform MATLAB time grid? Did you preserve the OCV-SOC curve or refit it? Did you record software versions? This chapter teaches you to answer those questions with files, code, and plots rather than hand-waving.

We will move in five stages. First, we build and export a PyBaMM virtual-cell dataset. Second, we inspect the exported files from Python and MATLAB so we know the formats really contain what we think they contain. Third, we write a MATLAB ECM identification script that operates only on exported files, as it would in a real cross-language project. Fourth, we build a Python master script that orchestrates the workflow and validates the MATLAB result. Fifth, we adapt the same pattern to sodium-ion research, where parameter sets and public datasets are thinner and the value of a clean tool bridge is even higher.

## Prerequisites Check

- Required Python software: Python `3.11`, `pybamm==26.3.1`, `numpy==1.26.4`, `scipy==1.13.1`, `pandas==2.2.2`, `matplotlib==3.9.0`, `h5py==3.11.0`, and `matlabengine==24.2.2` if MATLAB `R2024b` is installed
- Required MATLAB software: MATLAB `R2024b` recommended; Optimization Toolbox is helpful but not required because the chapter includes an `fminsearch` fallback
- Install command: `python -m pip install pybamm==26.3.1 numpy==1.26.4 scipy==1.13.1 pandas==2.2.2 matplotlib==3.9.0 h5py==3.11.0 matlabengine==24.2.2`
- Required textbook chapters: Textbook Chapter 8 for physics-based models; Textbook Chapter 10 for ECMs; the sodium-ion chapter for chemistry transfer
- Required prior lab chapters: Lab Chapters 1, 3, 4, and 6 are essential; Lab Chapter 7 helps if you want to extend the ECM into a state estimator; Lab Chapter 9 helps if you include temperature later
- External documentation to bookmark: PyBaMM installation and output-management documentation; MathWorks documentation for MATLAB Engine API for Python and MATLAB calling Python
- Estimated time: 14 to 20 hours, depending on whether you run the optional MATLAB Engine workflow or use the file-only workflow

If PyBaMM model setup feels shaky, revisit Lab Chapter 3. If equivalent-circuit identification feels unfamiliar, reread Lab Chapter 6 before doing the MATLAB section. If your MATLAB installation is not available on the machine where Python runs, you can still complete most of the chapter: Python will generate the data and write the MATLAB scripts, then you can run MATLAB manually and return to Python for validation.

## Environment Setup

The biggest installation risk in this chapter is not PyBaMM itself. It is the boundary between Python and MATLAB. Python packages live in virtual environments. MATLAB has its own embedded Python interface and its own external engine package. Your goal is not to make every possible direction work on the first attempt. Your goal is to establish one reproducible cross-language path, then record it.

The PyBaMM documentation for the stable `26.3.1` line states that PyBaMM can be installed with `pip` or `conda`, while warning that the conda recipe may lag releases. The same PyBaMM output-management tutorial shows `solution.save_data(...)` exporting selected variables to CSV and MATLAB formats, with the important limitation that CSV and MATLAB export are intended for variables that depend only on time. MathWorks documents the MATLAB Engine API for Python as the supported way to call MATLAB functions from Python, and the `matlabengine` package on PyPI ties specific package versions to specific MATLAB releases. For MATLAB `R2024b`, use the `24.2.x` engine family.

### Step 1: Create the Python environment

From a terminal, create a fresh environment for this chapter:

```bash
cd /home/avirup/SodiumIonBatteryResearch
python3.11 -m venv .venv-chapter10
source .venv-chapter10/bin/activate
python -m pip install --upgrade pip
python -m pip install pybamm==26.3.1 numpy==1.26.4 scipy==1.13.1 pandas==2.2.2 matplotlib==3.9.0 h5py==3.11.0
```

If MATLAB `R2024b` is installed and you want Python to call MATLAB directly, install the engine package:

```bash
python -m pip install matlabengine==24.2.2
```

On Windows PowerShell, the activation command is:

```powershell
.\.venv-chapter10\Scripts\Activate.ps1
```

If `matlabengine==24.2.2` is not available for your platform, install the engine package matching your MATLAB release. For MATLAB `R2024a`, the package family is `24.1.x`. For newer MATLAB releases, check the package metadata and record the exact package version in your research log. This is not clerical busywork. If your pipeline depends on the Python-MATLAB bridge, the engine package is part of the computational method.

### Step 2: Create the chapter workspace

Run the following from the repository root:

```bash
mkdir -p SimulationCompanion/chapter10_bridge_workspace
cd SimulationCompanion/chapter10_bridge_workspace
mkdir -p data figures matlab results scripts
```

The workflow will write:

| Folder | Contents |
| --- | --- |
| `data/` | PyBaMM-generated CSV, HDF5, and MAT files |
| `matlab/` | MATLAB ECM identification and simulation scripts |
| `results/` | MATLAB validation output and summary metrics |
| `figures/` | Publication-style plots from Python |
| `scripts/` | Python master workflow scripts |

Do not scatter these files across your desktop. Cross-language projects become painful when you cannot tell which program produced which artifact. Folder discipline is part of the method.

### Step 3: Verify Python and PyBaMM

Open a Jupyter notebook using the chapter environment, or run this as `scripts/verify_python.py`:

```python
import importlib.util

import h5py
import matplotlib
import numpy as np
import pandas as pd
import pybamm
import scipy

print("PyBaMM:", pybamm.__version__)
print("NumPy:", np.__version__)
print("SciPy:", scipy.__version__)
print("pandas:", pd.__version__)
print("Matplotlib:", matplotlib.__version__)
print("h5py:", h5py.__version__)

if importlib.util.find_spec("matlab.engine") is None:
    print("MATLAB Engine for Python: not installed")
else:
    import matlab.engine

    print("MATLAB Engine for Python: installed")

model = pybamm.lithium_ion.SPM()
parameter_values = pybamm.ParameterValues("Chen2020")
experiment = pybamm.Experiment(["Discharge at 1C for 5 minutes"], period="5 seconds")
simulation = pybamm.Simulation(
    model,
    parameter_values=parameter_values,
    experiment=experiment,
)
solution = simulation.solve()

voltage = solution["Terminal voltage [V]"](solution.t)
print(f"Number of output samples: {len(solution.t)}")
print(f"Initial voltage: {voltage[0]:.4f} V")
print(f"Final voltage: {voltage[-1]:.4f} V")
```

Expected output:

```text
PyBaMM: 26.3.1
NumPy: 1.26.4
SciPy: 1.13.1
pandas: 2.2.2
Matplotlib: 3.9.0
h5py: 3.11.0
MATLAB Engine for Python: installed
Number of output samples: 61
Initial voltage: 4.xxx V
Final voltage: 4.xxx V
```

If the engine line says `not installed`, that is acceptable for the file-only path. If PyBaMM reports a different version, decide whether to continue and record the version. For this chapter, the code is intentionally conservative and uses stable PyBaMM APIs, but version drift can still affect variable names and solver behavior.

### Step 4: Verify MATLAB

Open MATLAB and run:

```matlab
clear; clc;
fprintf("MATLAB version: %s\n", version);
fprintf("Current folder: %s\n", pwd);

t = linspace(0, 10, 101)';
y = exp(-t / 3);
plot(t, y, "LineWidth", 1.8);
grid on;
xlabel("Time (s)");
ylabel("Response (-)");
title("MATLAB bridge hello-world");
```

You should see a smooth exponential decay from `1` toward zero. This only verifies plotting and script execution. Later we will verify that MATLAB can read files written by Python.

### Step 5: Verify MATLAB Engine from Python

This step is optional but valuable. Run:

```python
try:
    import matlab.engine

    engine = matlab.engine.start_matlab()
    matlab_version = engine.version()
    print("Started MATLAB:", matlab_version)
    result = engine.sqrt(16.0)
    print("sqrt(16) from MATLAB:", result)
    engine.quit()
except Exception as exc:
    print("Could not start MATLAB Engine.")
    print(type(exc).__name__ + ":", exc)
```

Expected output:

```text
Started MATLAB: 24.2.0.2712019 (R2024b)
sqrt(16) from MATLAB: 4.0
```

The exact version string will differ. If this fails on Linux with a shared-library error, MATLAB is usually installed outside the default location or its runtime libraries are not visible. Add MATLAB's `bin/glnxa64` directory to `LD_LIBRARY_PATH`, restart the terminal, reactivate the Python environment, and try again. If this fails on macOS with a dynamic-library error, check `DYLD_LIBRARY_PATH` and the MathWorks installation notes for your release. If it fails because MATLAB is not licensed or not installed, use the file-only path: run the MATLAB script manually after Python writes the data.

## Conceptual Bridge: Models, Data, and Contracts Across Tools

In Textbook Chapter 8, the DFN model was a coupled system of conservation laws, kinetic equations, transport equations, and algebraic constraints. PyBaMM represents that model as symbolic expressions, discretizes it, solves it, and exposes named variables such as terminal voltage, current, electrode stoichiometry, electrolyte concentration, and cell temperature. In Textbook Chapter 10, the Thevenin equivalent circuit reduced the cell to an OCV source, an ohmic resistance, one or more polarization branches, and a SOC integrator. MATLAB is excellent at that reduction because it has mature optimization, signal-processing, control, and Simulink workflows.

The bridge between those two models is data. More precisely, it is a contract about data.

A useful cross-tool contract says what every column means, what its unit is, what sign convention it follows, how time is sampled, how missing values are represented, which protocol produced it, which software versions produced it, and which chemistry or parameter set it represents. Without that contract, a CSV file named `voltage.csv` is not a research artifact. It is a trap. You may fit a beautiful ECM to a current column whose sign is opposite to what MATLAB assumes. You may validate against the same protocol used for fitting and accidentally report training error as predictive error. You may export a nonuniform PyBaMM time base, feed it to a MATLAB script that assumes uniform sampling, and interpret interpolation error as model error.

The most important convention in this chapter is current sign. In many battery-test datasets, positive current means discharge. In some simulation tools or power-electronics contexts, positive current can mean charge. PyBaMM's experiment language is readable because it says `"Discharge at 1C"` or `"Charge at 1C"`, but exported current variables still need inspection. For the ECM code in this chapter, we will define:

$$
I(t) > 0 \quad \text{means discharge current.}
\tag{1}
$$

The SOC equation is then

$$
\frac{dz}{dt} = -\frac{I(t)}{3600 Q_{\mathrm{Ah}}},
\tag{2}
$$

where $z$ is SOC and $Q_{\mathrm{Ah}}$ is capacity in ampere-hours. If current is positive during discharge, SOC decreases. If current is negative during charge, SOC increases. This sign convention matches the ECM intuition used in Lab Chapter 6 and will be written into the exported metadata.

The first-order Thevenin ECM we identify in MATLAB is

$$
V(t) = U_{\mathrm{oc}}(z(t)) - I(t) R_0 - V_1(t),
\tag{3}
$$

with polarization dynamics

$$
\frac{dV_1}{dt} = -\frac{1}{R_1 C_1} V_1(t) + \frac{1}{C_1} I(t).
\tag{4}
$$

Equation (3) assumes positive discharge lowers terminal voltage below OCV. Equation (4) makes the RC polarization voltage rise under discharge and relax during rest. These are not the only possible ECM state definitions. Some books define the polarization state with the opposite sign. That is fine if you are consistent, but cross-language workflows punish hidden conventions. We will therefore write the equations directly into the MATLAB script, use descriptive variable names, and validate the result against PyBaMM output.

Why not export the entire PyBaMM model into MATLAB? In principle, advanced users can exchange models through generated code, FMI, custom C, or surrogate models. That is not the purpose of this chapter. The research habit we want first is simpler and more common: use PyBaMM as a virtual experiment generator, use MATLAB as a reduced-order identification and BMS environment, then compare the reduced model against held-out physics-based data. This mirrors a real laboratory workflow. A physical cell generates current-voltage-temperature data. A BMS engineer identifies an ECM. A validation engineer tests the ECM on a different protocol. Here, the physical cell is replaced by a PyBaMM DFN or SPMe simulation so the entire workflow is runnable on a laptop.

The file formats matter because they carry different tradeoffs. CSV is transparent, diffable, and easy to inspect, but it is weak for metadata and large arrays. HDF5 is structured, compressed, and suitable for larger data, but less friendly to casual inspection. MATLAB `.mat` files are convenient for MATLAB users, but version and naming choices matter. In this chapter we export all three, not because you should always do that in a paper, but because learning the differences once will save you many hours later.

| Format | Best use | Strength | Weakness |
| --- | --- | --- | --- |
| CSV | Time-series tables and quick inspection | Human-readable, universal | Metadata must be handled separately |
| HDF5 | Research archives and larger arrays | Structured groups, attributes, compression | Requires library support |
| MAT | MATLAB handoff | Native MATLAB loading | Variable names must be MATLAB-safe |
| JSON | Metadata sidecar | Human-readable metadata | Not ideal for long numeric arrays |

The bridge pattern for the rest of the chapter is therefore: generate, export, verify, identify, validate, archive. Each verb is a research action. Generate means the virtual experiment is defined in code. Export means the data contract is made explicit. Verify means the receiving tool reads what the sending tool wrote. Identify means parameters are fitted on one dataset. Validate means prediction is tested on a different dataset. Archive means the result can be rerun later.

## Guided Walkthrough 1: Generate a PyBaMM Virtual Cell and Export It Three Ways

**Learning objective:** Run two PyBaMM simulations, convert the outputs into a clean cross-tool table, and export the results to CSV, HDF5, MAT, and JSON metadata files.

We will use PyBaMM's SPMe model rather than a full DFN for the main workflow. This is a deliberate teaching choice. SPMe retains electrolyte effects and is much faster than DFN, which makes repeated reruns comfortable. The workflow is identical for DFN once you are confident. We will generate two protocols. The first, an HPPC-like pulse protocol, will be used for ECM identification. The second, a dynamic validation protocol, will be held out until the ECM parameters are fixed.

Create `scripts/01_generate_virtual_cell.py` with the following complete code:

```python
from __future__ import annotations

import json
from pathlib import Path

import h5py
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import pybamm
from scipy.io import savemat


ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "data"
FIGURE_DIR = ROOT / "figures"
DATA_DIR.mkdir(parents=True, exist_ok=True)
FIGURE_DIR.mkdir(parents=True, exist_ok=True)


def make_spme_simulation(experiment: pybamm.Experiment) -> pybamm.Simulation:
    """Create a repeatable SPMe simulation using one named parameter set."""
    model = pybamm.lithium_ion.SPMe()
    parameter_values = pybamm.ParameterValues("Chen2020")
    solver = pybamm.CasadiSolver(mode="safe", atol=1e-6, rtol=1e-6)
    return pybamm.Simulation(
        model,
        parameter_values=parameter_values,
        experiment=experiment,
        solver=solver,
    )


def solution_to_table(
    solution: pybamm.Solution,
    label: str,
    nominal_capacity_ah: float,
) -> pd.DataFrame:
    """Sample PyBaMM 0D variables and return a cross-tool battery table."""
    time_s = np.asarray(solution.t, dtype=float)

    voltage_v = np.asarray(solution["Terminal voltage [V]"](time_s), dtype=float)
    pybamm_current_a = np.asarray(solution["Current [A]"](time_s), dtype=float)
    discharge_current_a = -pybamm_current_a

    throughput_ah = np.zeros_like(time_s)
    if len(time_s) > 1:
        dt_s = np.diff(time_s)
        average_current_a = 0.5 * (
            discharge_current_a[1:] + discharge_current_a[:-1]
        )
        throughput_ah[1:] = np.cumsum(average_current_a * dt_s / 3600.0)

    soc = 1.0 - throughput_ah / nominal_capacity_ah
    soc = np.clip(soc, 0.0, 1.0)

    table = pd.DataFrame(
        {
            "time_s": time_s,
            "current_a": discharge_current_a,
            "voltage_v": voltage_v,
            "soc_estimate": soc,
            "throughput_ah": throughput_ah,
            "protocol": label,
        }
    )
    return table


def export_table(table: pd.DataFrame, stem: str, metadata: dict[str, object]) -> None:
    """Write one table as CSV, HDF5, MAT, and JSON metadata."""
    csv_path = DATA_DIR / f"{stem}.csv"
    h5_path = DATA_DIR / f"{stem}.h5"
    mat_path = DATA_DIR / f"{stem}.mat"
    json_path = DATA_DIR / f"{stem}_metadata.json"

    table.to_csv(csv_path, index=False)

    with h5py.File(h5_path, "w") as h5_file:
        group = h5_file.create_group("battery_timeseries")
        for column in ["time_s", "current_a", "voltage_v", "soc_estimate", "throughput_ah"]:
            group.create_dataset(column, data=table[column].to_numpy(), compression="gzip")
        for key, value in metadata.items():
            h5_file.attrs[key] = json.dumps(value) if isinstance(value, (list, dict)) else value

    savemat(
        mat_path,
        {
            "time_s": table["time_s"].to_numpy(),
            "current_a": table["current_a"].to_numpy(),
            "voltage_v": table["voltage_v"].to_numpy(),
            "soc_estimate": table["soc_estimate"].to_numpy(),
            "throughput_ah": table["throughput_ah"].to_numpy(),
        },
    )

    with json_path.open("w", encoding="utf-8") as file:
        json.dump(metadata, file, indent=2)

    print(f"Wrote {csv_path}")
    print(f"Wrote {h5_path}")
    print(f"Wrote {mat_path}")
    print(f"Wrote {json_path}")


def plot_protocols(identification: pd.DataFrame, validation: pd.DataFrame) -> None:
    """Create a quick visual audit of current and voltage for both protocols."""
    fig, axes = plt.subplots(2, 2, figsize=(11, 6), sharex="col")

    axes[0, 0].plot(identification["time_s"] / 60.0, identification["current_a"], color="tab:blue")
    axes[1, 0].plot(identification["time_s"] / 60.0, identification["voltage_v"], color="tab:red")
    axes[0, 0].set_title("Identification protocol")
    axes[0, 0].set_ylabel("Current (A)")
    axes[1, 0].set_ylabel("Voltage (V)")
    axes[1, 0].set_xlabel("Time (min)")

    axes[0, 1].plot(validation["time_s"] / 60.0, validation["current_a"], color="tab:blue")
    axes[1, 1].plot(validation["time_s"] / 60.0, validation["voltage_v"], color="tab:red")
    axes[0, 1].set_title("Validation protocol")
    axes[1, 1].set_xlabel("Time (min)")

    for axis in axes.ravel():
        axis.grid(True, alpha=0.3)

    fig.tight_layout()
    figure_path = FIGURE_DIR / "virtual_cell_protocols.png"
    fig.savefig(figure_path, dpi=200)
    print(f"Wrote {figure_path}")


def main() -> None:
    nominal_capacity_ah = 5.0

    identification_experiment = pybamm.Experiment(
        [
            "Rest for 20 minutes",
            "Discharge at 1C for 2 minutes",
            "Rest for 20 minutes",
            "Discharge at 2C for 2 minutes",
            "Rest for 20 minutes",
            "Charge at 1C for 2 minutes",
            "Rest for 20 minutes",
            "Discharge at 0.5C for 8 minutes",
            "Rest for 20 minutes",
        ],
        period="5 seconds",
    )

    validation_experiment = pybamm.Experiment(
        [
            "Rest for 10 minutes",
            "Discharge at 0.7C for 5 minutes",
            "Charge at 0.3C for 3 minutes",
            "Discharge at 1.5C for 4 minutes",
            "Rest for 8 minutes",
            "Discharge at 0.4C for 12 minutes",
            "Charge at 0.8C for 4 minutes",
            "Rest for 15 minutes",
        ],
        period="5 seconds",
    )

    print("Solving identification simulation...")
    identification_solution = make_spme_simulation(identification_experiment).solve()

    print("Solving validation simulation...")
    validation_solution = make_spme_simulation(validation_experiment).solve()

    identification_table = solution_to_table(
        identification_solution,
        label="identification",
        nominal_capacity_ah=nominal_capacity_ah,
    )
    validation_table = solution_to_table(
        validation_solution,
        label="validation",
        nominal_capacity_ah=nominal_capacity_ah,
    )

    metadata = {
        "tool": "PyBaMM",
        "pybamm_version": pybamm.__version__,
        "model": "SPMe",
        "parameter_set": "Chen2020",
        "nominal_capacity_ah": nominal_capacity_ah,
        "current_sign_convention": "current_a > 0 means discharge",
        "time_unit": "s",
        "current_unit": "A",
        "voltage_unit": "V",
        "soc_estimate_note": "SOC computed by coulomb counting from exported current.",
    }

    export_table(identification_table, "pybamm_identification", metadata)
    export_table(validation_table, "pybamm_validation", metadata)
    plot_protocols(identification_table, validation_table)

    print("\nIdentification preview:")
    print(identification_table.head())
    print("\nValidation preview:")
    print(validation_table.head())


if __name__ == "__main__":
    main()
```

Run it from the chapter workspace:

```bash
cd /home/avirup/SodiumIonBatteryResearch/SimulationCompanion/chapter10_bridge_workspace
python scripts/01_generate_virtual_cell.py
```

The first block imports the libraries and defines `ROOT`, `DATA_DIR`, and `FIGURE_DIR`. `Path(__file__).resolve().parents[1]` means "the parent folder of the folder containing this script." Because the script lives in `chapter10_bridge_workspace/scripts`, this resolves to `chapter10_bridge_workspace` no matter where you launch Python from. That small choice prevents one of the most common cross-tool workflow failures: a script that works only from the author's current folder.

`make_spme_simulation` creates a fresh PyBaMM simulation each time. We use `pybamm.lithium_ion.SPMe()` because it is a good compromise between physics and speed. We use `Chen2020` because it is a familiar parameter set from earlier chapters. The `CasadiSolver` tolerances are set explicitly so reruns are less dependent on solver defaults.

`solution_to_table` is the most important function in the script. It samples PyBaMM variables at `solution.t`, converts the terminal voltage into a NumPy array, and then handles the current sign convention. PyBaMM's reported current may be positive for charge under its internal convention, so the script defines `discharge_current_a = -pybamm_current_a`. This is the moment where the contract is enforced. Every downstream file uses positive discharge current.

The SOC column is deliberately named `soc_estimate`, not `soc_truth`. We compute it by coulomb counting from the exported current and the nominal capacity. PyBaMM has richer internal state variables, but the ECM identification script should behave like a BMS workflow using terminal measurements and a known capacity. Calling it an estimate prevents a subtle misconception: the exported SOC is a bookkeeping variable, not an omniscient electrochemical state.

`export_table` writes four files for each protocol. The CSV is for transparency. The HDF5 file stores numeric arrays under a group called `battery_timeseries` and puts metadata into file attributes. The `.mat` file uses MATLAB-safe variable names with no spaces, brackets, or punctuation. The JSON file is a sidecar metadata record. This looks redundant, but it teaches a good habit: numeric arrays and metadata should travel together.

The expected terminal output should include lines like:

```text
Solving identification simulation...
Solving validation simulation...
Wrote /.../data/pybamm_identification.csv
Wrote /.../data/pybamm_identification.h5
Wrote /.../data/pybamm_identification.mat
Wrote /.../data/pybamm_identification_metadata.json
Wrote /.../figures/virtual_cell_protocols.png
```

The figure `virtual_cell_protocols.png` has two columns. The left column is the identification protocol: rest periods interrupted by sharp pulse events, with voltage stepping down during discharge, recovering during rest, and stepping upward during charge. The right column is the validation protocol: a more dynamic sequence with discharge, charge, rest, and smaller current changes. A correct plot shows current in amperes on the top row and voltage in volts on the bottom row. A wrong plot often has charge and discharge inverted: voltage rises during a supposed discharge pulse or falls during a supposed charge pulse. If you see that, stop and inspect the current sign before fitting anything.

### What could go wrong

`KeyError: 'Terminal voltage [V]'` means the PyBaMM variable name has changed or the model did not solve. Print `solution.all_models[0].variables.keys()` only if you need to inspect variable names; do not build research code around casual name searching.

`SolverError` during simulation usually means the protocol drove the cell beyond a cutoff condition or the solver had difficulty with a discontinuity. Reduce the C-rate, shorten a pulse, or add rest. Do not immediately loosen tolerances until the physical protocol has been checked.

`ValueError` from `savemat` usually means a MATLAB variable name is invalid or an object column slipped into the data dictionary. Keep `.mat` exports numeric and MATLAB-safe.

If the exported SOC rises during discharge, your sign convention is wrong. Check the sign of `solution["Current [A]"]` during a known discharge step and correct the conversion before continuing.

### Reflection

This walkthrough taught the central habit of cross-tool modeling: export a dataset, not just an array. The voltage trace is useful only because it is accompanied by current, time, SOC convention, nominal capacity, software version, and protocol identity. We will reuse these exact files in MATLAB, so the quality of the bridge is now testable.

## Guided Walkthrough 2: Read the Exported Files Back and Audit the Contract

**Learning objective:** Verify from both Python and MATLAB that the exported files contain the same numeric signals and metadata.

Before fitting an ECM, we will inspect the files. This may feel slow, but it is standard practice in careful research. When tools disagree later, you want to know whether the error is in the model or in the handoff.

Create `scripts/02_audit_exports.py`:

```python
from __future__ import annotations

import json
from pathlib import Path

import h5py
import numpy as np
import pandas as pd
from scipy.io import loadmat


ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "data"


def read_hdf5(path: Path) -> pd.DataFrame:
    with h5py.File(path, "r") as h5_file:
        group = h5_file["battery_timeseries"]
        table = pd.DataFrame(
            {
                "time_s": group["time_s"][:],
                "current_a": group["current_a"][:],
                "voltage_v": group["voltage_v"][:],
                "soc_estimate": group["soc_estimate"][:],
                "throughput_ah": group["throughput_ah"][:],
            }
        )
        metadata = dict(h5_file.attrs)
    return table, metadata


def read_mat(path: Path) -> pd.DataFrame:
    mat_data = loadmat(path, squeeze_me=True)
    return pd.DataFrame(
        {
            "time_s": np.asarray(mat_data["time_s"], dtype=float),
            "current_a": np.asarray(mat_data["current_a"], dtype=float),
            "voltage_v": np.asarray(mat_data["voltage_v"], dtype=float),
            "soc_estimate": np.asarray(mat_data["soc_estimate"], dtype=float),
            "throughput_ah": np.asarray(mat_data["throughput_ah"], dtype=float),
        }
    )


def compare_tables(reference: pd.DataFrame, candidate: pd.DataFrame, label: str) -> None:
    columns = ["time_s", "current_a", "voltage_v", "soc_estimate", "throughput_ah"]
    print(f"\nComparing CSV with {label}")
    for column in columns:
        max_error = np.max(np.abs(reference[column].to_numpy() - candidate[column].to_numpy()))
        print(f"  {column:14s} max abs difference = {max_error:.3e}")


def main() -> None:
    csv_path = DATA_DIR / "pybamm_identification.csv"
    h5_path = DATA_DIR / "pybamm_identification.h5"
    mat_path = DATA_DIR / "pybamm_identification.mat"
    json_path = DATA_DIR / "pybamm_identification_metadata.json"

    csv_table = pd.read_csv(csv_path)
    h5_table, h5_metadata = read_hdf5(h5_path)
    mat_table = read_mat(mat_path)

    with json_path.open("r", encoding="utf-8") as file:
        json_metadata = json.load(file)

    print("CSV rows:", len(csv_table))
    print("CSV columns:", list(csv_table.columns))
    print("JSON current convention:", json_metadata["current_sign_convention"])
    print("HDF5 current convention:", h5_metadata["current_sign_convention"])

    compare_tables(csv_table, h5_table, "HDF5")
    compare_tables(csv_table, mat_table, "MAT")

    print("\nVoltage range:")
    print(f"  min = {csv_table['voltage_v'].min():.4f} V")
    print(f"  max = {csv_table['voltage_v'].max():.4f} V")
    print("Current values present:")
    print(sorted(csv_table["current_a"].round(4).unique())[:10], "...")


if __name__ == "__main__":
    main()
```

Run:

```bash
python scripts/02_audit_exports.py
```

Expected output should look like:

```text
CSV rows: 1609
CSV columns: ['time_s', 'current_a', 'voltage_v', 'soc_estimate', 'throughput_ah', 'protocol']
JSON current convention: current_a > 0 means discharge
HDF5 current convention: current_a > 0 means discharge

Comparing CSV with HDF5
  time_s         max abs difference = 0.000e+00
  current_a      max abs difference = 0.000e+00
  voltage_v      max abs difference = 0.000e+00
  soc_estimate   max abs difference = 0.000e+00
  throughput_ah  max abs difference = 0.000e+00

Comparing CSV with MAT
  time_s         max abs difference = 0.000e+00
  current_a      max abs difference = 0.000e+00
  voltage_v      max abs difference = 0.000e+00
  soc_estimate   max abs difference = 0.000e+00
  throughput_ah  max abs difference = 0.000e+00
```

Tiny differences such as `1e-15` are harmless floating-point roundoff. Differences near `1e-3` in voltage or current are not harmless and mean one file was written, parsed, or reshaped incorrectly.

Now create `matlab/audit_exports.m`:

```matlab
clear; clc;

chapterRoot = fileparts(fileparts(mfilename("fullpath")));
dataDir = fullfile(chapterRoot, "data");

csvPath = fullfile(dataDir, "pybamm_identification.csv");
matPath = fullfile(dataDir, "pybamm_identification.mat");

csvTable = readtable(csvPath);
matData = load(matPath);

fprintf("CSV rows: %d\n", height(csvTable));
fprintf("MAT rows: %d\n", numel(matData.time_s));
fprintf("CSV voltage range: %.4f V to %.4f V\n", ...
    min(csvTable.voltage_v), max(csvTable.voltage_v));
fprintf("MAT voltage range: %.4f V to %.4f V\n", ...
    min(matData.voltage_v), max(matData.voltage_v));

timeError = max(abs(csvTable.time_s - matData.time_s(:)));
currentError = max(abs(csvTable.current_a - matData.current_a(:)));
voltageError = max(abs(csvTable.voltage_v - matData.voltage_v(:)));

fprintf("Max time difference: %.3e s\n", timeError);
fprintf("Max current difference: %.3e A\n", currentError);
fprintf("Max voltage difference: %.3e V\n", voltageError);

figure;
tiledlayout(2, 1);

nexttile;
plot(csvTable.time_s / 60, csvTable.current_a, "LineWidth", 1.4);
grid on;
ylabel("Current (A)");
title("MATLAB audit of Python-exported data");

nexttile;
plot(csvTable.time_s / 60, csvTable.voltage_v, "LineWidth", 1.4);
grid on;
xlabel("Time (min)");
ylabel("Voltage (V)");
```

Run it from MATLAB:

```matlab
run("SimulationCompanion/chapter10_bridge_workspace/matlab/audit_exports.m")
```

The MATLAB output should report the same number of rows and nearly zero differences between CSV and MAT values. The plot should match the identification protocol from Walkthrough 1. This is a small but important milestone: MATLAB is now reading Python-generated data without guessing.

The Python audit script uses `h5py` to read arrays back from the HDF5 group, `scipy.io.loadmat` to read the MAT file, and `pandas.read_csv` to read the CSV. It then compares every numeric column. The MATLAB audit script performs the same check from the receiving side. In real projects, keep a script like this around. It becomes your first diagnostic when a collaborator says, "The MATLAB fit looks wrong."

### What could go wrong

If MATLAB loads `time_s` as a row vector and the table column is a column vector, expressions may silently expand in newer MATLAB releases. The script uses `matData.time_s(:)` to force column shape. This habit prevents shape bugs.

If `readtable` changes column names, MATLAB may have modified names to make them valid identifiers. Our columns are already MATLAB-safe, so that should not happen. If you export names such as `Voltage [V]`, MATLAB may rename them unless you control import options.

If HDF5 metadata appears as byte strings in Python, decode it before comparing. Attribute type behavior can differ across library versions. For this chapter, simple strings should round-trip cleanly.

If the figure is blank in MATLAB, call `drawnow` or check that the script is running from a desktop MATLAB session rather than a no-display batch mode.

### Reflection

This walkthrough may be the least glamorous chapter section and one of the most important. You verified the bridge before trusting it. That is the difference between research code and a lucky demo.

## Guided Walkthrough 3: Identify a Thevenin ECM in MATLAB from PyBaMM Data

**Learning objective:** Fit a first-order ECM in MATLAB using only exported PyBaMM current-voltage data.

Now MATLAB takes over. We will fit four ECM ingredients: an OCV-SOC polynomial and three dynamic parameters, $R_0$, $R_1$, and $C_1$. This is not the most advanced ECM identification method in the field. Chapter 6 introduced more careful HPPC-based methods. Here we choose a robust workflow that can run from exported files and produce a useful cross-validation target.

Create `matlab/identify_ecm_from_pybamm.m`:

```matlab
function identify_ecm_from_pybamm()
%IDENTIFY_ECM_FROM_PYBAMM Fit a 1RC Thevenin ECM from PyBaMM virtual-cell data.

clear; clc;

chapterRoot = fileparts(fileparts(mfilename("fullpath")));
dataDir = fullfile(chapterRoot, "data");
resultDir = fullfile(chapterRoot, "results");
figureDir = fullfile(chapterRoot, "figures");

if ~exist(resultDir, "dir")
    mkdir(resultDir);
end
if ~exist(figureDir, "dir")
    mkdir(figureDir);
end

identificationPath = fullfile(dataDir, "pybamm_identification.csv");
validationPath = fullfile(dataDir, "pybamm_validation.csv");

idData = readtable(identificationPath);
valData = readtable(validationPath);

nominalCapacityAh = 5.0;

[ocvCoefficients, ocvSoc, ocvVoltage] = fit_ocv_curve(idData);

initialGuess = log([0.015, 0.010, 2500.0]);
objective = @(logParameters) voltage_rmse_objective( ...
    logParameters, idData, nominalCapacityAh, ocvCoefficients);

bestLogParameters = fminsearch( ...
    objective, ...
    initialGuess, ...
    optimset("Display", "iter", "MaxIter", 300, "MaxFunEvals", 800));

bestParameters = exp(bestLogParameters);
r0Ohm = bestParameters(1);
r1Ohm = bestParameters(2);
c1Farad = bestParameters(3);

idPrediction = simulate_thevenin( ...
    idData.time_s, idData.current_a, nominalCapacityAh, ...
    idData.soc_estimate(1), ocvCoefficients, r0Ohm, r1Ohm, c1Farad);

valPrediction = simulate_thevenin( ...
    valData.time_s, valData.current_a, nominalCapacityAh, ...
    valData.soc_estimate(1), ocvCoefficients, r0Ohm, r1Ohm, c1Farad);

idRmseMv = rmse_mv(idData.voltage_v, idPrediction.voltage_v);
valRmseMv = rmse_mv(valData.voltage_v, valPrediction.voltage_v);

fprintf("\nIdentified ECM parameters\n");
fprintf("R0 = %.6f ohm\n", r0Ohm);
fprintf("R1 = %.6f ohm\n", r1Ohm);
fprintf("C1 = %.2f F\n", c1Farad);
fprintf("tau1 = %.2f s\n", r1Ohm * c1Farad);
fprintf("Identification RMSE = %.2f mV\n", idRmseMv);
fprintf("Validation RMSE = %.2f mV\n", valRmseMv);

parameterTable = table( ...
    r0Ohm, r1Ohm, c1Farad, r1Ohm * c1Farad, idRmseMv, valRmseMv, ...
    "VariableNames", ["R0_ohm", "R1_ohm", "C1_F", "Tau1_s", ...
    "Identification_RMSE_mV", "Validation_RMSE_mV"]);
parameterPath = fullfile(resultDir, "identified_ecm_parameters.csv");
writetable(parameterTable, parameterPath);

validationOutput = table( ...
    valData.time_s, valData.current_a, valData.voltage_v, ...
    valPrediction.voltage_v, valPrediction.soc, valPrediction.v1, ...
    "VariableNames", ["time_s", "current_a", "pybamm_voltage_v", ...
    "ecm_voltage_v", "ecm_soc", "ecm_polarization_v"]);
validationPathOut = fullfile(resultDir, "validation_ecm_prediction.csv");
writetable(validationOutput, validationPathOut);

save(fullfile(resultDir, "identified_ecm_parameters.mat"), ...
    "r0Ohm", "r1Ohm", "c1Farad", "ocvCoefficients", ...
    "idRmseMv", "valRmseMv");

make_validation_plot(valData, valPrediction, valRmseMv, figureDir);
make_ocv_plot(ocvSoc, ocvVoltage, ocvCoefficients, figureDir);

fprintf("Wrote %s\n", parameterPath);
fprintf("Wrote %s\n", validationPathOut);
end


function [coefficients, restSoc, restVoltage] = fit_ocv_curve(data)
currentThresholdA = 0.02;
restMask = abs(data.current_a) < currentThresholdA;

restSoc = data.soc_estimate(restMask);
restVoltage = data.voltage_v(restMask);

if numel(restSoc) < 20
    error("Not enough rest data to fit OCV curve.");
end

[restSocUnique, uniqueIndex] = unique(restSoc, "stable");
restVoltageUnique = restVoltage(uniqueIndex);

polynomialOrder = 5;
coefficients = polyfit(restSocUnique, restVoltageUnique, polynomialOrder);
end


function objectiveValue = voltage_rmse_objective( ...
    logParameters, data, nominalCapacityAh, ocvCoefficients)

parameters = exp(logParameters);
r0Ohm = parameters(1);
r1Ohm = parameters(2);
c1Farad = parameters(3);

prediction = simulate_thevenin( ...
    data.time_s, data.current_a, nominalCapacityAh, ...
    data.soc_estimate(1), ocvCoefficients, r0Ohm, r1Ohm, c1Farad);

voltageError = data.voltage_v - prediction.voltage_v;
objectiveValue = sqrt(mean(voltageError.^2));
end


function prediction = simulate_thevenin( ...
    timeS, currentA, nominalCapacityAh, initialSoc, ...
    ocvCoefficients, r0Ohm, r1Ohm, c1Farad)

timeS = timeS(:);
currentA = currentA(:);

n = numel(timeS);
soc = zeros(n, 1);
v1 = zeros(n, 1);
voltage = zeros(n, 1);

soc(1) = initialSoc;
v1(1) = 0.0;
voltage(1) = polyval(ocvCoefficients, soc(1)) - currentA(1) * r0Ohm - v1(1);

tau1 = r1Ohm * c1Farad;

for k = 2:n
    dt = timeS(k) - timeS(k - 1);
    previousCurrent = currentA(k - 1);

    soc(k) = soc(k - 1) - previousCurrent * dt / (3600.0 * nominalCapacityAh);
    soc(k) = min(max(soc(k), 0.0), 1.0);

    alpha = exp(-dt / tau1);
    v1(k) = alpha * v1(k - 1) + r1Ohm * (1.0 - alpha) * previousCurrent;

    voltage(k) = polyval(ocvCoefficients, soc(k)) - currentA(k) * r0Ohm - v1(k);
end

prediction = table(soc, v1, voltage, ...
    "VariableNames", ["soc", "v1", "voltage_v"]);
end


function value = rmse_mv(referenceVoltage, predictedVoltage)
errorV = referenceVoltage(:) - predictedVoltage(:);
value = 1000.0 * sqrt(mean(errorV.^2));
end


function make_validation_plot(data, prediction, valRmseMv, figureDir)
figure("Color", "w", "Position", [100, 100, 900, 650]);
tiledlayout(3, 1, "TileSpacing", "compact");

nexttile;
plot(data.time_s / 60, data.current_a, "k", "LineWidth", 1.2);
grid on;
ylabel("Current (A)");
title("Held-out PyBaMM validation protocol");

nexttile;
plot(data.time_s / 60, data.voltage_v, "LineWidth", 1.5);
hold on;
plot(data.time_s / 60, prediction.voltage_v, "--", "LineWidth", 1.5);
grid on;
ylabel("Voltage (V)");
legend("PyBaMM virtual cell", "MATLAB ECM", "Location", "best");
title(sprintf("Validation voltage, RMSE = %.2f mV", valRmseMv));

nexttile;
plot(data.time_s / 60, 1000 * (data.voltage_v - prediction.voltage_v), ...
    "LineWidth", 1.2);
grid on;
xlabel("Time (min)");
ylabel("Error (mV)");

exportgraphics(gcf, fullfile(figureDir, "matlab_validation_ecm.png"), ...
    "Resolution", 200);
end


function make_ocv_plot(restSoc, restVoltage, coefficients, figureDir)
socGrid = linspace(min(restSoc), max(restSoc), 200);
ocvFit = polyval(coefficients, socGrid);

figure("Color", "w", "Position", [150, 150, 700, 450]);
plot(restSoc, restVoltage, ".", "MarkerSize", 8);
hold on;
plot(socGrid, ocvFit, "LineWidth", 1.8);
grid on;
xlabel("SOC (-)");
ylabel("Voltage (V)");
title("OCV approximation from PyBaMM rest segments");
legend("Rest samples", "Polynomial fit", "Location", "best");

exportgraphics(gcf, fullfile(figureDir, "matlab_ocv_fit.png"), ...
    "Resolution", 200);
end
```

Run from MATLAB:

```matlab
addpath("SimulationCompanion/chapter10_bridge_workspace/matlab")
identify_ecm_from_pybamm
```

The script begins by locating the chapter root from the script path. This is better than relying on MATLAB's current folder, because people often run MATLAB scripts from whatever folder happened to be open. It reads the identification and validation CSV files written by Python. It fixes the nominal capacity at `5.0 Ah`, matching the Python metadata.

`fit_ocv_curve` extracts low-current samples, treats them as approximate rest data, and fits a fifth-order polynomial between `soc_estimate` and voltage. This is a teaching shortcut. In careful HPPC identification, you would use sufficiently relaxed rest endpoints, smooth the OCV curve, and avoid overfitting. Here the protocol contains rest segments, and the virtual data are clean, so the shortcut is acceptable. The function uses `unique(..., "stable")` because polynomial fitting does not need repeated identical SOC entries from long rest periods.

The dynamic parameters are optimized in log space. This is a standard trick when parameters must remain positive. Instead of asking `fminsearch` to fit `R0`, `R1`, and `C1` directly, we fit their logarithms and exponentiate inside the objective. That prevents negative resistances and capacitances without needing Optimization Toolbox. If you have Optimization Toolbox, `lsqnonlin` with bounds is often better; `fminsearch` is included because it works in base MATLAB.

`simulate_thevenin` uses the exact discrete-time update for the RC polarization state under piecewise-constant current:

$$
V_{1,k} = e^{-\Delta t/\tau_1} V_{1,k-1}
        + R_1 \left(1 - e^{-\Delta t/\tau_1}\right) I_{k-1}.
\tag{5}
$$

This is better than a forward-Euler update when sampling intervals vary. PyBaMM's output time base is usually regular because we set `period="5 seconds"`, but exact updates cost nothing and are more robust.

Expected MATLAB output will vary, but it should have this shape:

```text
Identified ECM parameters
R0 = 0.0xxxxx ohm
R1 = 0.0xxxxx ohm
C1 = xxxx.xx F
tau1 = xx.xx s
Identification RMSE = xx.xx mV
Validation RMSE = xx.xx mV
Wrote .../results/identified_ecm_parameters.csv
Wrote .../results/validation_ecm_prediction.csv
```

Do not expect sub-millivolt validation error. The SPMe virtual cell has electrochemical dynamics that a first-order ECM cannot perfectly reproduce. A validation RMSE in the range of a few millivolts to a few tens of millivolts is plausible for this teaching workflow. If the error is hundreds of millivolts, suspect current sign, SOC initialization, OCV fit, or a failed optimization.

The validation plot has three panels. The top panel shows the held-out current profile. The middle panel overlays PyBaMM voltage and MATLAB ECM voltage. A good result tracks the broad voltage response and rest recoveries, with visible mismatch around rapid current transitions. The bottom panel shows voltage error in millivolts. A good result has errors centered near zero without a long monotonic drift. A wrong result often shows a large step error at every current transition or a steadily growing bias across the whole validation protocol.

### What could go wrong

If `fminsearch` drives `C1` to an extremely large value, the identification data may not contain enough relaxation information to identify the time constant. Add longer rest periods or stronger pulses to the identification protocol.

If the OCV curve oscillates wildly, the fifth-order polynomial is overfitting. Lower the polynomial order to `3`, or fit a monotonic interpolant. In a paper, you would show and justify this choice.

If validation error is much worse than identification error, that is not automatically a bug. It may mean the ECM is overfitted to pulses and weak on dynamic current. This is exactly why held-out validation exists.

If MATLAB cannot find the CSV files, check that `chapterRoot` resolves to `chapter10_bridge_workspace`. Run `disp(chapterRoot)` inside the script.

### Reflection

You have now performed a realistic reduced-order modeling workflow: a physics-based simulator produced virtual experimental data, and MATLAB identified a BMS-style ECM without access to PyBaMM internals. This separation is powerful. It lets you test how much electrochemical behavior survives reduction into a circuit model.

## Guided Walkthrough 4: Orchestrate the Whole Pipeline from Python

**Learning objective:** Build a master Python script that runs the PyBaMM generator, invokes MATLAB when available, and creates a final validation figure from MATLAB's output.

Manual handoffs are useful while learning. Publishable workflows need a one-command path. The script below runs the generation script, tries to call the MATLAB identification function through MATLAB Engine, and then reads the MATLAB output back into Python. If MATLAB Engine is not available, the script prints the exact MATLAB command to run manually and stops cleanly.

Create `scripts/03_run_bridge_pipeline.py`:

```python
from __future__ import annotations

import importlib.util
import subprocess
import sys
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
SCRIPT_DIR = ROOT / "scripts"
MATLAB_DIR = ROOT / "matlab"
RESULT_DIR = ROOT / "results"
FIGURE_DIR = ROOT / "figures"


def run_python_generation() -> None:
    script_path = SCRIPT_DIR / "01_generate_virtual_cell.py"
    print(f"Running {script_path}")
    subprocess.run([sys.executable, str(script_path)], check=True)


def run_matlab_identification() -> bool:
    if importlib.util.find_spec("matlab.engine") is None:
        print("MATLAB Engine for Python is not installed.")
        print_manual_matlab_command()
        return False

    try:
        import matlab.engine

        print("Starting MATLAB Engine...")
        engine = matlab.engine.start_matlab()
        engine.addpath(str(MATLAB_DIR), nargout=0)
        engine.identify_ecm_from_pybamm(nargout=0)
        engine.quit()
        return True
    except Exception as exc:
        print("MATLAB Engine call failed.")
        print(type(exc).__name__ + ":", exc)
        print_manual_matlab_command()
        return False


def print_manual_matlab_command() -> None:
    print("\nRun this in MATLAB, then rerun this Python script:")
    print(f'addpath("{MATLAB_DIR}")')
    print("identify_ecm_from_pybamm")


def make_python_validation_figure() -> None:
    validation_path = RESULT_DIR / "validation_ecm_prediction.csv"
    parameter_path = RESULT_DIR / "identified_ecm_parameters.csv"

    if not validation_path.exists():
        raise FileNotFoundError(
            f"Missing {validation_path}. Run the MATLAB identification step first."
        )

    validation = pd.read_csv(validation_path)
    parameters = pd.read_csv(parameter_path)
    val_rmse_mv = float(parameters.loc[0, "Validation_RMSE_mV"])

    time_min = validation["time_s"] / 60.0
    error_mv = 1000.0 * (
        validation["pybamm_voltage_v"] - validation["ecm_voltage_v"]
    )

    fig, axes = plt.subplots(3, 1, figsize=(10, 7), sharex=True)

    axes[0].plot(time_min, validation["current_a"], color="black", linewidth=1.2)
    axes[0].set_ylabel("Current (A)")
    axes[0].set_title("Cross-tool validation: PyBaMM virtual cell vs MATLAB ECM")

    axes[1].plot(
        time_min,
        validation["pybamm_voltage_v"],
        label="PyBaMM virtual cell",
        linewidth=1.6,
    )
    axes[1].plot(
        time_min,
        validation["ecm_voltage_v"],
        "--",
        label="MATLAB ECM",
        linewidth=1.6,
    )
    axes[1].set_ylabel("Voltage (V)")
    axes[1].legend(loc="best")

    axes[2].plot(time_min, error_mv, color="tab:red", linewidth=1.2)
    axes[2].axhline(0.0, color="black", linewidth=0.8)
    axes[2].set_ylabel("Error (mV)")
    axes[2].set_xlabel("Time (min)")

    for axis in axes:
        axis.grid(True, alpha=0.3)

    fig.text(
        0.99,
        0.01,
        f"Held-out validation RMSE = {val_rmse_mv:.2f} mV",
        ha="right",
        va="bottom",
    )
    fig.tight_layout(rect=[0, 0.03, 1, 1])

    FIGURE_DIR.mkdir(parents=True, exist_ok=True)
    figure_path = FIGURE_DIR / "python_cross_tool_validation.png"
    fig.savefig(figure_path, dpi=250)
    print(f"Wrote {figure_path}")

    print("\nParameter summary:")
    print(parameters.to_string(index=False))


def main() -> None:
    run_python_generation()
    matlab_completed = run_matlab_identification()
    if not matlab_completed:
        return
    make_python_validation_figure()


if __name__ == "__main__":
    main()
```

Run:

```bash
python scripts/03_run_bridge_pipeline.py
```

If MATLAB Engine works, the script will run end to end. If it does not, you will see a manual MATLAB command. Run that command in MATLAB, then either rerun the whole script or comment out `run_python_generation()` and `run_matlab_identification()` while you test the final plotting section.

The orchestration script uses `subprocess.run` for the Python generation step instead of importing the generation script. That is intentional. In research pipelines, scripts often have side effects: they write files, create folders, and print logs. Running them as scripts mirrors command-line use and catches path assumptions that imports may hide. The MATLAB step uses the engine only if `matlab.engine` is importable. This avoids making MATLAB a hard dependency for readers who do not have it on the same machine.

The final Python figure should match the MATLAB validation figure. This double plotting is not wasteful. It proves that MATLAB's output file is readable by Python and that the final paper figures can be produced from archived results rather than from a MATLAB figure window.

### What could go wrong

If the Python script starts MATLAB but hangs for a long time, MATLAB may be waiting on license checkout, startup scripts, or a dialog. Start MATLAB manually once and resolve any prompts before using the engine.

If the engine cannot find `identify_ecm_from_pybamm`, check that `engine.addpath(str(MATLAB_DIR), nargout=0)` points to the folder containing the `.m` file. MATLAB function files must have the same name as the primary function.

If `validation_ecm_prediction.csv` exists but has old results, delete the `results/` files and rerun. In serious work, include timestamps or run IDs. For this teaching chapter, we keep filenames stable so the workflow is easy to inspect.

If Python reports a missing display backend while plotting on a server, set Matplotlib to a noninteractive backend before importing `pyplot`, or run the script in an environment with display support. Saving PNG files does not require an interactive window.

### Reflection

You now have a one-command bridge from PyBaMM to MATLAB and back. The important achievement is not that Python can start MATLAB. The important achievement is that each tool does the job it is good at while the data contract remains explicit and auditable.

## Guided Walkthrough 5: Make the Workflow Deterministic and Version-Control Friendly

**Learning objective:** Add environment capture, deterministic settings, and a run manifest so a future reader can reproduce the cross-language result.

Cross-tool reproducibility fails in quiet ways. A PyBaMM version changes a variable name. MATLAB changes a table import rule. A parameter set is updated. A script is run from a different folder. A result CSV is overwritten and no one remembers which commit produced it. This walkthrough adds a manifest that records versions, file hashes, and workflow settings.

Create `scripts/04_write_manifest.py`:

```python
from __future__ import annotations

import hashlib
import json
import platform
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

import h5py
import matplotlib
import numpy as np
import pandas as pd
import pybamm
import scipy


ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "data"
RESULT_DIR = ROOT / "results"


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def git_commit() -> str:
    try:
        completed = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            cwd=ROOT.parents[1],
            check=True,
            capture_output=True,
            text=True,
        )
        return completed.stdout.strip()
    except Exception:
        return "unknown"


def matlab_engine_status() -> str:
    try:
        import matlab.engine  # noqa: F401

        return "installed"
    except Exception:
        return "not installed"


def collect_files() -> list[dict[str, str]]:
    paths = []
    for folder in [DATA_DIR, RESULT_DIR]:
        if folder.exists():
            paths.extend(sorted(folder.glob("*")))

    records = []
    for path in paths:
        if path.is_file():
            records.append(
                {
                    "path": str(path.relative_to(ROOT)),
                    "sha256": sha256_file(path),
                }
            )
    return records


def main() -> None:
    manifest = {
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "python_executable": sys.executable,
        "python_version": sys.version,
        "platform": platform.platform(),
        "git_commit": git_commit(),
        "packages": {
            "pybamm": pybamm.__version__,
            "numpy": np.__version__,
            "scipy": scipy.__version__,
            "pandas": pd.__version__,
            "matplotlib": matplotlib.__version__,
            "h5py": h5py.__version__,
            "matlab_engine": matlab_engine_status(),
        },
        "workflow_contract": {
            "current_sign_convention": "current_a > 0 means discharge",
            "time_unit": "s",
            "current_unit": "A",
            "voltage_unit": "V",
            "identification_file": "data/pybamm_identification.csv",
            "validation_file": "data/pybamm_validation.csv",
            "matlab_result_file": "results/validation_ecm_prediction.csv",
        },
        "files": collect_files(),
    }

    manifest_path = RESULT_DIR / "run_manifest.json"
    RESULT_DIR.mkdir(parents=True, exist_ok=True)
    with manifest_path.open("w", encoding="utf-8") as file:
        json.dump(manifest, file, indent=2)

    print(f"Wrote {manifest_path}")


if __name__ == "__main__":
    main()
```

Run after the pipeline:

```bash
python scripts/04_write_manifest.py
```

The manifest is a JSON file with package versions, platform information, the current Git commit if available, the data contract, and SHA-256 hashes of files in `data/` and `results/`. Hashes are useful because they tell you whether a file changed even when its name did not. If a collaborator reruns the workflow and the hash changes, that does not automatically mean something is wrong, but it creates a precise question: which file changed, and why?

For version control, commit scripts and small metadata files. Be careful with generated data. Synthetic PyBaMM CSV files in this chapter are small enough to commit if you want a fully reproducible example. Large public datasets should usually be downloaded by script or tracked with a data tool rather than committed to Git. The rule from Lab Chapter 1 still applies: source code, environment files, and lightweight metadata belong in Git; large raw data usually do not.

A strong commit sequence for this chapter might look like:

```bash
git add SimulationCompanion/chapter10_bridge_workspace/scripts
git add SimulationCompanion/chapter10_bridge_workspace/matlab
git add SimulationCompanion/chapter10_bridge_workspace/results/run_manifest.json
git commit -m "Add PyBaMM MATLAB bridge workflow"
```

If you choose to commit generated figures and small synthetic CSV files, do so intentionally:

```bash
git add SimulationCompanion/chapter10_bridge_workspace/data/*.csv
git add SimulationCompanion/chapter10_bridge_workspace/figures/*.png
git commit -m "Archive virtual cell bridge outputs"
```

### What could go wrong

If `git_commit` returns `unknown`, the script may be outside a Git repository or `git` may not be installed. This does not block the workflow, but record the situation in your research log.

If hashes differ between runs even with the same code, inspect whether timestamps, metadata ordering, or solver outputs changed. CSV files from deterministic simulations should usually be stable. MAT files may include format details that differ across MATLAB versions.

If the manifest contains absolute paths you do not want to publish, edit the script to store paths relative to the chapter root. The provided script already does this for archived files.

### Reflection

This walkthrough turns a useful workflow into a reproducible workflow. The difference is not glamorous, but it is exactly what separates a notebook result from a defensible computational method.

## Dataset Integration: Using a Real Dataset at the Tool Boundary

The primary dataset in this chapter is a PyBaMM-generated virtual dataset because the deliverable requires a virtual-cell workflow. That is appropriate for learning the bridge because the true protocol, model, and parameter set are fully known. Real experimental data should enter once the bridge is trusted.

The most natural public dataset to plug into the same workflow is the CALCE HPPC-style data used in Lab Chapter 6. The workflow is:

1. Parse CALCE current, voltage, and time into the same canonical columns: `time_s`, `current_a`, `voltage_v`, and `soc_estimate`.
2. Export the parsed table to CSV and MAT using the same variable names.
3. Run `identify_ecm_from_pybamm.m` after renaming the input paths or generalizing the script arguments.
4. Validate on a different CALCE cycle or pulse segment.

The important point is that the MATLAB ECM script does not need to know whether the file came from PyBaMM or a cycler. If the contract is the same, the tool boundary is the same. This is exactly how you should design research workflows: one parser per data source, one canonical table format, and reusable model scripts downstream.

A minimal adapter for an already-clean experimental CSV would look like this:

```python
from pathlib import Path

import pandas as pd
from scipy.io import savemat


def export_experimental_table(input_csv: Path, output_stem: Path) -> None:
    raw = pd.read_csv(input_csv)

    table = pd.DataFrame(
        {
            "time_s": raw["time_s"].astype(float),
            "current_a": raw["current_a"].astype(float),
            "voltage_v": raw["voltage_v"].astype(float),
            "soc_estimate": raw["soc_estimate"].astype(float),
            "throughput_ah": raw["throughput_ah"].astype(float),
        }
    )

    table.to_csv(output_stem.with_suffix(".csv"), index=False)
    savemat(
        output_stem.with_suffix(".mat"),
        {column: table[column].to_numpy() for column in table.columns},
    )
```

The pitfalls are familiar now. Experimental timestamps may be absolute date-times rather than elapsed seconds. Current may use positive charge instead of positive discharge. Voltage may include rest periods, charge steps, and discharge steps in one file. Null values can appear when the cycler changes state. SOC is rarely measured directly and must be reconstructed by coulomb counting with careful initial conditions. The bridge does not remove these problems, but it gives you one place to solve them.

For sodium-ion, public full-cell datasets remain much sparser than lithium-ion datasets. A practical sodium-ion project often begins by validating the data workflow on lithium-ion public data, then applying the same workflow to sodium-ion data digitized from papers, generated by a validated simulation, or provided by a collaborator. State this honestly in manuscripts. A lithium-ion validation proves the software method, not the sodium-ion chemistry.

## Reproduction Exercise: Reproduce PyBaMM's Output-Export Pattern and Extend It

This chapter's reproduction exercise is a software-method reproduction rather than a figure reproduction. PyBaMM's official output-management tutorial demonstrates saving a simulation, saving a solution, and exporting selected 0D variables to CSV and MATLAB formats with short MATLAB-safe names. Reproduce that pattern in your environment, then extend it to the virtual-cell workflow in this chapter.

Start with this minimal notebook cell:

```python
import pybamm

model = pybamm.lithium_ion.SPMe()
simulation = pybamm.Simulation(model, parameter_values=pybamm.ParameterValues("Chen2020"))
solution = simulation.solve([0, 600])

solution.save_data(
    "tutorial_style_export.csv",
    ["Current [A]", "Terminal voltage [V]"],
    to_format="csv",
)
solution.save_data(
    "tutorial_style_export.mat",
    ["Current [A]", "Terminal voltage [V]"],
    to_format="matlab",
    short_names={
        "Current [A]": "I",
        "Terminal voltage [V]": "V",
    },
)
```

Your reproduction target is not visual. It is file equivalence and usability. You should be able to load the CSV with pandas and the MAT file with MATLAB. Then answer three questions in your research log. First, which variable names did PyBaMM accept for export? Second, why do MATLAB exports need `short_names`? Third, why does this chapter use a custom pandas/HDF5/MAT export instead of relying only on `solution.save_data`?

The worked answer is that PyBaMM's export function is excellent for quick export of selected time-only variables, and it should be part of your toolbox. This chapter uses custom export code because we want a canonical table with renamed columns, a sign convention enforced at export time, a metadata sidecar, HDF5 attributes, and a consistent interface for both simulated and experimental data. That is not a criticism of PyBaMM. It is the difference between a convenient tool export and a project-specific data contract.

Close enough means the files load correctly, the current and voltage arrays match between CSV and MAT within floating-point precision, and the metadata in your extended workflow clearly records the sign convention. If PyBaMM changes variable names in a future version, record the version and the replacement names in your log.

## Open-Ended Exercises

### Exercise 1: Replace the first-order ECM with a two-RC ECM

Modify `identify_ecm_from_pybamm.m` so that it fits $R_0$, $R_1$, $C_1$, $R_2$, and $C_2$. Use two polarization states:

$$
V(t) = U_{\mathrm{oc}}(z) - I R_0 - V_1 - V_2.
\tag{6}
$$

Hints: fit parameters in log space, initialize the second time constant at least five times larger than the first, and compare validation RMSE rather than only identification RMSE. Watch for parameter swapping: two RC branches can trade identities unless the data excite both time scales.

### Exercise 2: Use a DFN virtual cell instead of SPMe

Change the PyBaMM model in `make_spme_simulation` to `pybamm.lithium_ion.DFN()`. Keep the protocols the same at first. Compare runtime, identification RMSE, and validation RMSE.

Hints: DFN may run more slowly and may expose stronger dynamics that a 1RC ECM cannot match. Do not change the ECM and the virtual cell at the same time. Make one change, rerun, and record the effect.

### Exercise 3: Add temperature as an exported variable

Turn on a lumped thermal model in PyBaMM and export `Volume-averaged cell temperature [K]`. Extend the CSV, HDF5, and MAT files to include `temperature_k`. Do not fit a thermal ECM yet; just prove the bridge carries temperature correctly.

Hints: revisit Lab Chapter 9 for PyBaMM thermal options. Start with moderate currents. MATLAB column names should remain lowercase and unit-explicit.

### Exercise 4: Run the whole pipeline without MATLAB Engine

Pretend your Python environment cannot call MATLAB. Run the Python generation script, run MATLAB manually, then run the Python plotting and manifest scripts. Write a short note explaining which steps are automated and which are manual.

Hints: this is not a failure mode. Many research groups use file-only handoffs because MATLAB licenses live on different machines than Python environments.

## Worked Solutions to the Open-Ended Exercises

### Solution 1: Two-RC ECM structure

The key change is to add a second state and two more log-parameters. The simulation update becomes:

```matlab
alpha1 = exp(-dt / (r1Ohm * c1Farad));
alpha2 = exp(-dt / (r2Ohm * c2Farad));
v1(k) = alpha1 * v1(k - 1) + r1Ohm * (1.0 - alpha1) * previousCurrent;
v2(k) = alpha2 * v2(k - 1) + r2Ohm * (1.0 - alpha2) * previousCurrent;
voltage(k) = polyval(ocvCoefficients, soc(k)) - currentA(k) * r0Ohm - v1(k) - v2(k);
```

A reasonable initial guess is:

```matlab
initialGuess = log([0.015, 0.006, 500.0, 0.010, 8000.0]);
```

If validation RMSE improves only slightly while parameters become unstable, the 2RC model may not be justified by the data. Standard practice is to report both fit quality and parameter plausibility.

### Solution 2: DFN virtual cell

The minimal code change is:

```python
model = pybamm.lithium_ion.DFN()
```

Everything else can remain unchanged. You should expect longer runtime. The validation error may increase because DFN contains richer diffusion and electrolyte dynamics. If the 1RC ECM still performs well, that is useful evidence that the chosen protocol does not strongly expose higher-order dynamics. If it performs poorly, try the 2RC exercise before concluding that ECMs are unsuitable.

### Solution 3: Temperature export

Use:

```python
model = pybamm.lithium_ion.SPMe({"thermal": "lumped"})
```

and add:

```python
temperature_k = np.asarray(
    solution["Volume-averaged cell temperature [K]"](time_s),
    dtype=float,
)
```

Then include `"temperature_k": temperature_k` in the pandas table, HDF5 datasets, and MAT export dictionary. In MATLAB, verify with:

```matlab
data = readtable("pybamm_identification.csv");
plot(data.time_s / 60, data.temperature_k);
xlabel("Time (min)");
ylabel("Temperature (K)");
grid on;
```

A correct plot should show small temperature changes for this moderate protocol. If temperature is exactly constant, you may still be running an isothermal model or exporting the wrong variable.

### Solution 4: File-only bridge

The file-only sequence is:

```bash
python scripts/01_generate_virtual_cell.py
python scripts/02_audit_exports.py
```

then in MATLAB:

```matlab
addpath("SimulationCompanion/chapter10_bridge_workspace/matlab")
identify_ecm_from_pybamm
```

then back in Python:

```bash
python scripts/04_write_manifest.py
```

To create the final Python plot without rerunning MATLAB Engine, call `make_python_validation_figure()` from `03_run_bridge_pipeline.py` in a small wrapper or temporarily edit `main()`. In a real project, you would split generation, MATLAB execution, and plotting into separate command-line targets so manual and automated paths share the same code.

## What Changes for Sodium-Ion?

The bridge workflow becomes more valuable for sodium-ion, not less. Sodium-ion research has fewer mature public datasets, fewer widely validated parameter sets, and more variation in OCV shape across cathode/anode pairings. A clean PyBaMM-to-MATLAB workflow lets you test BMS algorithms on virtual sodium-ion cells before abundant experimental data exist.

Three changes matter most. First, the OCV-SOC relationship can be flatter or shaped differently than the lithium-ion parameter set used here, especially for hard-carbon anodes with plateau and sloping regions. A flat OCV region makes ECM identification and SOC estimation less observable from voltage, as you saw in Lab Chapter 7. Second, parameter availability is thinner. You may need to build a provisional sodium-ion parameter set from literature values, then label it as provisional rather than validated. Third, validation strategy must be more modest. If you validate the bridge on lithium-ion data and then apply it to sodium-ion simulations, say exactly that. Do not imply that lithium-ion validation proves sodium-ion accuracy.

To adapt this chapter's workflow for sodium-ion, replace `Chen2020` with a sodium-ion parameter set if one is available in your PyBaMM installation or in a documented external repository. If not, start with a lithium-ion parameter set as a software-method stand-in and clearly separate "workflow validation" from "chemistry validation." Then modify the OCV fitting section to avoid high-order polynomial artifacts. For hard-carbon-like OCV shapes, piecewise monotonic interpolation is often safer than a global polynomial.

The most publishable sodium-ion use of this chapter is a virtual benchmarking study: define several plausible sodium-ion OCV curves and resistance levels, generate virtual current-voltage data in PyBaMM or a custom electrochemical model, identify ECMs in MATLAB, and quantify how OCV flatness affects validation error and SOC observability. That study would connect directly to Textbook Chapter 10 and the sodium-ion chapter.

## Chapter Summary and Skill Checklist

- You created a PyBaMM virtual-cell workflow with separate identification and validation protocols.
- You exported simulation data to CSV, HDF5, MAT, and JSON metadata files.
- You enforced a clear current sign convention: `current_a > 0` means discharge.
- You audited exported files from both Python and MATLAB before fitting models.
- You identified a first-order Thevenin ECM in MATLAB using PyBaMM-generated data.
- You validated the ECM on a held-out PyBaMM protocol rather than reporting only training error.
- You built a Python master script that can call MATLAB through MATLAB Engine when available.
- You wrote a run manifest with package versions, file hashes, and the workflow contract.

Commands, functions, and patterns that should now feel familiar:

- `pybamm.Experiment(...)`
- `pybamm.Simulation(...).solve()`
- `solution["Terminal voltage [V]"](solution.t)`
- `pandas.DataFrame.to_csv(...)`
- `h5py.File(...)`
- `scipy.io.savemat(...)` and `scipy.io.loadmat(...)`
- MATLAB `readtable`, `writetable`, `load`, `polyfit`, `polyval`, and `fminsearch`
- MATLAB Engine `matlab.engine.start_matlab()`
- File hashes with `hashlib.sha256`
- Metadata sidecars with JSON

You should now be able to:

- Generate synthetic battery data in PyBaMM for a chosen protocol.
- Export a clean time-series table with units and sign conventions.
- Read Python-generated CSV and MAT files in MATLAB.
- Fit a simple ECM in MATLAB from exported current-voltage data.
- Validate the ECM on a held-out protocol and report RMSE in millivolts.
- Return MATLAB predictions to Python for publication-style plotting.
- Explain why training error and validation error are different.
- Design a file contract that works for both simulated and experimental battery data.
- State what must change before applying the workflow to sodium-ion cells.

If you cannot check every box, revisit the corresponding walkthrough before moving on. Chapter 11 assumes you can design a canonical table format and defend your unit conventions.

## Deliverable

Your deliverable is a complete virtual-cell workflow:

- A PyBaMM script that runs an identification protocol and a held-out validation protocol.
- Exported CSV, HDF5, MAT, and JSON metadata files.
- A MATLAB script that loads the exported identification data and identifies a Thevenin ECM.
- A validation result comparing the MATLAB ECM against the held-out PyBaMM simulation.
- A master script or clearly documented command sequence that reruns the pipeline.
- A short written interpretation of the validation RMSE, the major error features, and whether a 1RC ECM is adequate for the protocol.

A strong partial solution is exactly the set of scripts written in this chapter, with one meaningful extension: either a 2RC ECM, a DFN virtual cell, or temperature export. In your write-up, include the current sign convention, software versions, and a plot with current, PyBaMM voltage, ECM voltage, and voltage error. Do not submit only the final RMSE. The error shape is part of the result.

## Further Practice and Reading

PyBaMM documentation: bookmark the official PyBaMM installation page at `https://docs.pybamm.org/en/stable/source/user_guide/installation/index.html` and the output-management tutorial at `https://docs.pybamm.org/en/stable/source/examples/notebooks/getting_started/tutorial-6-managing-simulation-outputs.html`. The output tutorial is especially relevant because it demonstrates `save_data` exports to CSV and MATLAB formats and explains the limitation to time-only variables.

MathWorks documentation: bookmark the MATLAB Engine API for Python documentation at `https://www.mathworks.com/help/matlab/matlab-engine-for-python.html` and the engine installation page at `https://www.mathworks.com/help/matlab/matlab_external/install-the-matlab-engine-for-python.html`. You will need both directions eventually, even if this chapter emphasizes Python calling MATLAB.

Battery modeling papers: revisit Marquis et al. (2019), "An asymptotic derivation of a single particle model with electrolyte," and Sulzer et al. (2021), "Python Battery Mathematical Modelling (PyBaMM)." They help you explain why SPMe is a defensible virtual-cell generator and what PyBaMM contributes beyond ordinary numerical integration.

ECM practice: return to Plett's BMS material on equivalent-circuit identification and compare its pulse-based parameter extraction with the optimization-based workflow here. The difference between physically guided identification and black-box optimization is a recurring research judgment.

Community resources: the PyBaMM GitHub repository at `https://github.com/pybamm-team/PyBaMM` and PyBaMM community channels are useful when variable names or solver behavior change. MATLAB Central and File Exchange are useful for checking idiomatic MATLAB data-import and optimization patterns, but always reduce borrowed code to a small auditable script before using it in a paper workflow.

Next chapter: Lab Chapter 11, "Public Battery Datasets in Depth."

# Lab Chapter 8: SOH and Aging Models

## Chapter Opening

This chapter is where battery modeling stops being a single-cycle exercise and becomes a lifetime exercise. Up to this point, most of our simulations and estimators have lived inside one discharge, one drive cycle, or one carefully bounded test protocol. That is exactly how we should learn the tools. But a publishable battery-health study asks a harder question: how does the cell change after tens, hundreds, or thousands of repetitions, and how do we infer that change from data that are incomplete, noisy, and usually collected under imperfectly controlled conditions?

Keep Textbook Chapter 7 open while you work. That chapter gave you the physical degradation vocabulary: SEI growth, loss of lithium or sodium inventory, loss of active material, impedance rise, electrolyte decomposition, current-collector corrosion, particle cracking, and temperature-accelerated side reactions. This lab chapter operationalizes those mechanisms. We will turn the mechanistic ideas into empirical capacity-fade equations, semi-empirical cycling models, PyBaMM degradation options, MATLAB scripts, and diagnostic features such as incremental-capacity analysis. We will also lean on Textbook Chapter 10 because state of health, or SOH, is not only a materials property. It is a quantity estimated by a BMS from voltage, current, temperature, and historical usage.

The target skill is not merely "fit a curve." Any spreadsheet can fit a curve. The research skill is learning to decide which curve is physically defensible, which data points deserve to be included, which assumptions you are making silently, and how to report uncertainty without overselling. Aging data are especially treacherous because capacity fade is slow, cells vary from one another, laboratory protocols differ, and sodium-ion public datasets remain sparse compared with lithium-ion datasets. The consequence is that a strong sodium-ion aging paper often uses a hybrid strategy: validate the workflow on public lithium-ion data, adapt the mechanism and parameters for sodium-ion chemistry, then state clearly what still requires sodium-ion experimental confirmation.

We will build the chapter around the NASA Prognostics Center of Excellence Li-ion Battery Aging dataset. NASA describes this dataset as cells cycled under charge, discharge, and impedance operations at different temperatures, with end of life defined as 30% capacity fade from 2 Ah to 1.4 Ah. The public NASA PCoE repository lists the direct download for the battery dataset and asks users to acknowledge the repository and data donors when publishing with it. We will parse the original MATLAB `.mat` files, extract discharge capacities, clean the cycle table, fit empirical fade models, and use the fitted model to forecast 500 cycles. Then we will build a parallel MATLAB implementation so you can reproduce the same logic in the BMS ecosystem introduced in Chapters 6 and 7.

We will also use PyBaMM. PyBaMM is not only a DFN simulator; it includes degradation submodels such as SEI growth. The key intellectual move is recognizing that a physics-based degradation simulation and a dataset-fitted health model answer different questions. A PyBaMM SEI model asks, "What happens if this mechanism and parameterization are correct?" A NASA-calibrated empirical model asks, "What trend does this dataset support?" Publishable research often needs both: a mechanistic model for interpretation and a data-calibrated model for validation.

By the end of this chapter, you will have a Python workflow that downloads or loads the NASA dataset, extracts SOH versus cycle number, fits square-root, power-law, and Arrhenius-inspired capacity-fade models, simulates degradation with PyBaMM's SEI options, and performs incremental-capacity analysis on partial charge/discharge curves. You will also have a MATLAB script that implements the same empirical aging model over 500+ cycles. The deliverable is a calibrated aging model in both languages, with a comparison plot and a short written interpretation of what the model can and cannot claim.

## Prerequisites Check

- Required software: Python `3.11`, `numpy==1.26.4`, `scipy==1.13.1`, `pandas==2.2.2`, `matplotlib==3.9.0`, `h5py==3.11.0`, `requests==2.32.3`, `pybamm==26.3.1`, and MATLAB `R2024b` or newer recommended
- Install command: `python -m pip install numpy==1.26.4 scipy==1.13.1 pandas==2.2.2 matplotlib==3.9.0 h5py==3.11.0 requests==2.32.3 pybamm==26.3.1`
- Required textbook chapters: Textbook Chapter 7 is essential; Textbook Chapter 8 helps for PyBaMM DFN context; Textbook Chapter 10 helps for BMS interpretation of SOH
- Required prior lab chapters: Lab Chapters 1, 2, 3, 4, and 6 are expected; Lab Chapter 7 is helpful but not required
- External datasets: NASA PCoE Battery Data Set, direct repository page `https://www.nasa.gov/intelligent-systems-division/discovery-and-systems-health/pcoe/pcoe-data-set-repository/`; NASA Open Data landing page `https://data.nasa.gov/dataset/li-ion-battery-aging-datasets`
- Estimated time: 18 to 24 hours, including dataset download and the open-ended exercises

If your PyBaMM confidence is shaky, revisit Lab Chapter 3 before the PyBaMM exercise. If you have not handled real battery time-series data yet, reread the pandas sections in Lab Chapter 2 and the CALCE parsing workflow in Lab Chapter 6. Aging analysis punishes casual data handling; the code here is deliberately explicit because a one-line parsing mistake can create a beautiful but false SOH curve.

## Environment Setup

We will use one Python workspace and one MATLAB workspace. The Python side does the heavier lifting: dataset download, `.mat` parsing, empirical fitting, PyBaMM simulation, and ICA/DVA processing. The MATLAB side mirrors the empirical model so you can bring SOH modeling into the same environment used for ECMs and Kalman filters.

### Step 1: Create the Python environment

From a terminal, move to your research repository and create an isolated environment:

```bash
cd ~/battery-research
python3.11 -m venv .venv-aging
source .venv-aging/bin/activate
python -m pip install --upgrade pip
python -m pip install numpy==1.26.4 scipy==1.13.1 pandas==2.2.2 matplotlib==3.9.0 h5py==3.11.0 requests==2.32.3 pybamm==26.3.1
```

On Windows PowerShell, the activation command is:

```powershell
.\.venv-aging\Scripts\Activate.ps1
```

The version pin for PyBaMM uses the stable documentation line available at the time this chapter was written. PyBaMM's own installation page says the package is available through `pip` and `conda`, but notes that the conda recipe may lag behind recent releases. For this chapter, use `pip` unless your institution has a strict conda workflow.

Now verify the Python stack:

```python
import numpy as np
import pandas as pd
import scipy
import matplotlib
import pybamm

print("NumPy:", np.__version__)
print("pandas:", pd.__version__)
print("SciPy:", scipy.__version__)
print("Matplotlib:", matplotlib.__version__)
print("PyBaMM:", pybamm.__version__)
```

Expected output:

```text
NumPy: 1.26.4
pandas: 2.2.2
SciPy: 1.13.1
Matplotlib: 3.9.0
PyBaMM: 26.3.1
```

If `pybamm` fails to import with a solver-related error, restart the terminal after installation and try again. If the error mentions a missing C++ runtime on Windows, install the Microsoft Visual C++ Redistributable and rerun the import. If `pip` cannot find `pybamm==26.3.1`, install the latest stable version shown by `python -m pip index versions pybamm`, then record the exact version in your research log because aging-option names can change.

### Step 2: Create the chapter folders

Run this once from the activated Python environment:

```python
from pathlib import Path

chapter_root = Path("chapter8_soh_aging_workspace")
for subfolder in ["data/raw", "data/processed", "results", "figures", "matlab"]:
    (chapter_root / subfolder).mkdir(parents=True, exist_ok=True)

print(chapter_root.resolve())
```

Expected output is the absolute path to `chapter8_soh_aging_workspace`. Every script in this chapter assumes this folder structure. If you choose a different root, change only the `chapter_root` variable, not every path by hand.

### Step 3: Run a minimal aging hello-world

Before we touch real data, check that SciPy can fit a simple degradation model:

```python
import numpy as np
from scipy.optimize import curve_fit

cycle_index = np.arange(1, 101)
true_capacity_ah = 2.0 - 0.035 * np.sqrt(cycle_index)
measured_capacity_ah = true_capacity_ah + 0.003 * np.sin(cycle_index / 6)


def sqrt_fade_model(cycles, capacity_0, fade_coefficient):
    return capacity_0 - fade_coefficient * np.sqrt(cycles)


parameters, covariance = curve_fit(
    sqrt_fade_model,
    cycle_index,
    measured_capacity_ah,
    p0=[2.0, 0.03],
)

print(f"Fitted initial capacity: {parameters[0]:.4f} Ah")
print(f"Fitted sqrt fade coefficient: {parameters[1]:.5f} Ah/cycle^0.5")
```

Expected output:

```text
Fitted initial capacity: 2.0012 Ah
Fitted sqrt fade coefficient: 0.03515 Ah/cycle^0.5
```

The fitted values should be close to the synthetic truth. This verifies the numerical workflow: arrays are shaped correctly, SciPy can optimize, and your environment can run the simplest empirical aging model.

### Step 4: Verify MATLAB

Open MATLAB and run:

```matlab
clear; clc;
cycleIndex = (1:100)';
capacityAh = 2.0 - 0.035 * sqrt(cycleIndex);
plot(cycleIndex, capacityAh, "LineWidth", 1.8);
grid on;
xlabel("Cycle number");
ylabel("Capacity (Ah)");
title("Aging hello-world");
```

You should see a smooth, gently concave-down capacity curve that starts near `1.965 Ah` at cycle 1 and ends near `1.650 Ah` at cycle 100. If the figure is blank, call `drawnow`. If MATLAB complains about string quotes, you are likely using a very old release; replace double quotes with single quotes.

### Common setup failures

**The NASA download is slow or blocked.** The direct NASA PCoE file is a zip archive served from an S3 bucket. If your network blocks large downloads from scripts, download it manually from the NASA repository page and place it in `chapter8_soh_aging_workspace/data/raw/Battery_Data_Set.zip`. The parsing code checks for the local file first.

**`scipy.io.loadmat` cannot read a file.** Some `.mat` files use MATLAB v7.3 HDF5 format, which requires `h5py`. The NASA battery files used in the original PCoE archive are commonly readable with `scipy.io.loadmat`, but this chapter includes an HDF5 fallback pattern because public mirrors sometimes repack files.

**PyBaMM degradation simulations run slowly.** Aging models are long-horizon by nature. We will use reduced cycle counts and explicit output variables in the guided exercise, then discuss how to scale the run. For research production, cache intermediate outputs and avoid rerunning long simulations just to change a plot label.

## Conceptual Bridge: From Degradation Mechanisms to SOH Model Terms

In Textbook Chapter 7, degradation mechanisms were described physically. SEI growth consumes cyclable inventory and increases impedance. Loss of active material reduces the amount of host structure available for intercalation. Electrolyte decomposition changes transport and reaction kinetics. Particle cracking creates new surface area, which can accelerate SEI growth and expose fresh reactive material. Temperature enters almost every mechanism through Arrhenius-type rate dependence. Current and depth of discharge enter by changing overpotential, concentration gradients, mechanical stress, and time spent at reactive potentials.

Software tools cannot simulate a mechanism until we choose a mathematical representation for it. That representation can be empirical, semi-empirical, or physics-based. The categories overlap, but the distinction is useful.

An empirical capacity-fade model describes the observed trend without claiming that every term corresponds to a particular microscopic process. A common example is

$$
Q(N) = Q_0 - k\sqrt{N},
\tag{1}
$$

where $Q(N)$ is discharge capacity after cycle number $N$, $Q_0$ is the extrapolated initial capacity, and $k$ is a fitted fade coefficient. The square-root dependence appears often in diffusion-limited SEI growth arguments, but in an empirical fit it should be interpreted cautiously. If Equation (1) fits a dataset, that does not prove SEI growth is the only mechanism. It only says the dataset's trend is consistent with a concave-down fade curve over the observed window.

A slightly more flexible empirical model is a power law:

$$
Q(N) = Q_0 - kN^b,
\tag{2}
$$

where $b$ is fitted. When $b=0.5$, Equation (2) reduces to square-root fade. When $b$ is closer to 1, fade is more nearly linear with cycle count. The cost of flexibility is interpretability: if you fit $b$ freely to a small, noisy dataset, you may be fitting protocol noise rather than degradation physics.

A semi-empirical model adds operational dependence. One common form is

$$
\Delta Q(N, T, C_{\mathrm{rate}})
=
k_0 \exp\!\left(-\frac{E_a}{RT}\right)
C_{\mathrm{rate}}^\gamma
N^b,
\tag{3}
$$

where $E_a$ is an apparent activation energy, $R$ is the gas constant, $T$ is absolute temperature, and $\gamma$ describes current-rate dependence. Equation (3) is not a full electrochemical model. It is a compact way to say that the fade rate increases with temperature and current stress. In a real study, you would need data at multiple temperatures and current rates to identify those terms. If you only have one cell at one temperature, fitting $E_a$ is not possible; any value you choose is an assumption.

Physics-based degradation models go one level deeper. In PyBaMM, selecting an SEI option modifies the electrochemical model by adding side-reaction states and equations. The model can track loss of lithium inventory, SEI thickness, and capacity change produced by the side reaction. This is powerful because it connects capacity fade to internal state variables, but it also introduces parameters that are hard to measure. A physics-based model with guessed degradation parameters is not automatically more truthful than a simple empirical model fitted to clean data.

For BMS work, SOH is usually defined relative to a reference capacity:

$$
\mathrm{SOH}(N) = \frac{Q(N)}{Q_{\mathrm{rated}}}.
\tag{4}
$$

Some studies use initial measured capacity instead of rated capacity:

$$
\mathrm{SOH}_{\mathrm{relative}}(N) = \frac{Q(N)}{Q(1)}.
\tag{5}
$$

Both definitions are valid if stated clearly. The NASA dataset often refers to cells with a nominal 2 Ah rating and an EOL criterion of 1.4 Ah, which corresponds to 70% of rated capacity. In this chapter we will report both capacity in ampere-hours and SOH relative to the first valid discharge capacity because that is the most robust choice when parsing individual cells.

The final bridge is diagnostic. We rarely get a perfect full discharge capacity measurement in the field. Instead, we may see partial charge curves, partial discharge curves, rest voltages, pulse responses, and sensor histories. Incremental-capacity analysis, or ICA, uses

$$
\frac{dQ}{dV},
\tag{6}
$$

while differential-voltage analysis, or DVA, uses

$$
\frac{dV}{dQ}.
\tag{7}
$$

These curves amplify subtle changes in the voltage-capacity relationship. Peaks shift, broaden, or shrink as the cell ages. In lithium-ion research, ICA/DVA is widely used for degradation diagnosis. For sodium-ion, the same idea applies, but peak interpretation depends strongly on the cathode, hard-carbon anode, electrolyte, and voltage window. In this chapter, we will teach the computational workflow rather than pretend that a Li-ion peak map transfers directly to sodium-ion chemistry.

## Guided Walkthrough 1: Parse NASA Aging Data and Build an SOH Table

**Learning objective:** Download or load the NASA battery aging archive, parse discharge cycles from the original MATLAB files, and create a clean capacity-versus-cycle table.

We start with data, not models. This is a deliberate order. Aging models are seductive because fitting a smooth curve feels productive, but the hard part is usually deciding what the data mean. The NASA archive stores each cell as a MATLAB structure array. Each cycle has a `type`, an `ambient_temperature`, a `time`, and a nested `data` structure. For discharge cycles, the nested data include voltage, current, temperature, time, and a scalar capacity in ampere-hours.

The NASA PCoE repository lists the battery dataset direct download as `https://phm-datasets.s3.amazonaws.com/NASA/5.+Battery+Data+Set.zip`. The NASA Open Data page describes the acquisition system and notes that data were collected at approximately 10 Hz. The code below tries the direct download, extracts the archive, locates `.mat` files, and builds a tidy table.

```python
from pathlib import Path
from zipfile import ZipFile
import requests
import numpy as np
import pandas as pd
from scipy.io import loadmat


CHAPTER_ROOT = Path("chapter8_soh_aging_workspace")
RAW_DIR = CHAPTER_ROOT / "data" / "raw"
PROCESSED_DIR = CHAPTER_ROOT / "data" / "processed"
RAW_DIR.mkdir(parents=True, exist_ok=True)
PROCESSED_DIR.mkdir(parents=True, exist_ok=True)

NASA_ZIP_URL = "https://phm-datasets.s3.amazonaws.com/NASA/5.+Battery+Data+Set.zip"
NASA_ZIP_PATH = RAW_DIR / "Battery_Data_Set.zip"
NASA_EXTRACT_DIR = RAW_DIR / "NASA_Battery_Data_Set"


def download_nasa_archive():
    """Download the NASA battery archive if it is not already present."""
    if NASA_ZIP_PATH.exists():
        print(f"Using existing archive: {NASA_ZIP_PATH}")
        return

    print(f"Downloading NASA archive from {NASA_ZIP_URL}")
    response = requests.get(NASA_ZIP_URL, timeout=120)
    response.raise_for_status()
    NASA_ZIP_PATH.write_bytes(response.content)
    size_mb = NASA_ZIP_PATH.stat().st_size / (1024 * 1024)
    print(f"Downloaded {size_mb:.1f} MB to {NASA_ZIP_PATH}")


def extract_nasa_archive():
    """Extract the NASA battery archive if it has not already been extracted."""
    if NASA_EXTRACT_DIR.exists() and any(NASA_EXTRACT_DIR.rglob("*.mat")):
        print(f"Using existing extracted folder: {NASA_EXTRACT_DIR}")
        return

    NASA_EXTRACT_DIR.mkdir(parents=True, exist_ok=True)
    with ZipFile(NASA_ZIP_PATH, "r") as archive:
        archive.extractall(NASA_EXTRACT_DIR)
    print(f"Extracted archive to {NASA_EXTRACT_DIR}")


def matlab_datenum_to_timestamp(date_vector):
    """Convert a NASA MATLAB date vector into a pandas Timestamp."""
    flat = np.asarray(date_vector, dtype=float).ravel()
    if flat.size < 6:
        return pd.NaT

    year, month, day, hour, minute = flat[:5].astype(int)
    second = float(flat[5])
    whole_second = int(np.floor(second))
    microsecond = int(round((second - whole_second) * 1_000_000))
    return pd.Timestamp(
        year=year,
        month=month,
        day=day,
        hour=hour,
        minute=minute,
        second=whole_second,
        microsecond=microsecond,
    )


def unwrap_matlab_scalar(value):
    """Repeatedly unwrap one-element MATLAB object arrays."""
    current = value
    while isinstance(current, np.ndarray) and current.size == 1:
        current = current.item()
    return current


def get_struct_field(struct_object, field_name):
    """Read a named field from a scipy-loaded MATLAB struct."""
    field_value = struct_object[field_name]
    return unwrap_matlab_scalar(field_value)


def parse_discharge_cycles(mat_path):
    """Return one row per discharge cycle from a NASA cell .mat file."""
    mat = loadmat(mat_path, squeeze_me=False, struct_as_record=False)
    cell_name = mat_path.stem
    if cell_name not in mat:
        raise KeyError(f"Expected variable {cell_name} inside {mat_path.name}")

    cell_struct = unwrap_matlab_scalar(mat[cell_name])
    cycles = np.asarray(cell_struct.cycle).ravel()
    rows = []

    discharge_index = 0
    for raw_cycle_index, cycle in enumerate(cycles, start=1):
        cycle_type = str(unwrap_matlab_scalar(cycle.type))
        if cycle_type.lower() != "discharge":
            continue

        discharge_index += 1
        data = unwrap_matlab_scalar(cycle.data)
        capacity_ah = float(np.asarray(data.Capacity).ravel()[0])
        voltage_v = np.asarray(data.Voltage_measured, dtype=float).ravel()
        current_a = np.asarray(data.Current_measured, dtype=float).ravel()
        temperature_c = np.asarray(data.Temperature_measured, dtype=float).ravel()
        time_s = np.asarray(data.Time, dtype=float).ravel()

        rows.append(
            {
                "cell_id": cell_name,
                "raw_cycle_index": raw_cycle_index,
                "discharge_index": discharge_index,
                "start_time": matlab_datenum_to_timestamp(cycle.time),
                "ambient_temperature_c": float(
                    np.asarray(cycle.ambient_temperature).ravel()[0]
                ),
                "capacity_ah": capacity_ah,
                "initial_voltage_v": float(voltage_v[0]),
                "final_voltage_v": float(voltage_v[-1]),
                "mean_discharge_current_a": float(np.nanmean(current_a)),
                "mean_temperature_c": float(np.nanmean(temperature_c)),
                "duration_s": float(time_s[-1] - time_s[0]),
                "n_samples": int(time_s.size),
            }
        )

    return pd.DataFrame(rows)


download_nasa_archive()
extract_nasa_archive()

mat_files = sorted(NASA_EXTRACT_DIR.rglob("B*.mat"))
print(f"Found {len(mat_files)} MATLAB files")
print("First files:", [path.name for path in mat_files[:5]])

all_capacity_tables = []
for mat_file in mat_files:
    try:
        table = parse_discharge_cycles(mat_file)
    except Exception as exc:
        print(f"Skipping {mat_file.name}: {exc}")
        continue
    if not table.empty:
        all_capacity_tables.append(table)

capacity_table = pd.concat(all_capacity_tables, ignore_index=True)
capacity_table = capacity_table.sort_values(["cell_id", "discharge_index"])

first_capacity = capacity_table.groupby("cell_id")["capacity_ah"].transform("first")
capacity_table["soh_relative"] = capacity_table["capacity_ah"] / first_capacity
capacity_table["capacity_fade_ah"] = first_capacity - capacity_table["capacity_ah"]

output_path = PROCESSED_DIR / "nasa_capacity_table.csv"
capacity_table.to_csv(output_path, index=False)

print(f"Wrote {len(capacity_table)} discharge rows to {output_path}")
print(capacity_table.head(10).to_string(index=False))
```

The code is longer than a typical data-loading snippet because we are crossing a real boundary between MATLAB's nested structure format and Python's table format. `loadmat` returns MATLAB structs as Python objects when `struct_as_record=False`. The helper `unwrap_matlab_scalar` removes layers of one-element arrays that exist because MATLAB stores scalar structs and strings differently from Python. This is standard practice when parsing MATLAB files with SciPy. It looks fussy because the file format is fussy.

The parser keeps both `raw_cycle_index` and `discharge_index`. The raw cycle index counts every operation: charge, discharge, and impedance. The discharge index counts only usable discharge capacity measurements. For SOH fitting, discharge index is often the cleaner independent variable because capacity is observed only on discharge cycles. For protocol reconstruction, raw cycle index matters because rest periods and impedance tests are part of the cell's actual history.

Expected output will vary slightly depending on archive mirror and file layout, but you should see something like:

```text
Downloading NASA archive from https://phm-datasets.s3.amazonaws.com/NASA/5.+Battery+Data+Set.zip
Downloaded 55.2 MB to chapter8_soh_aging_workspace/data/raw/Battery_Data_Set.zip
Extracted archive to chapter8_soh_aging_workspace/data/raw/NASA_Battery_Data_Set
Found 34 MATLAB files
First files: ['B0005.mat', 'B0006.mat', 'B0007.mat', 'B0018.mat', 'B0025.mat']
Wrote 616 discharge rows to chapter8_soh_aging_workspace/data/processed/nasa_capacity_table.csv
cell_id  raw_cycle_index  discharge_index          start_time  ambient_temperature_c  capacity_ah
B0005                  2                1 2008-04-02 15:25:41                   24.0       1.8565
```

A correct capacity table has one row per discharge cycle and a monotonically increasing `discharge_index` within each `cell_id`. `capacity_ah` should generally decline, but not perfectly. Real aging data can show apparent capacity recovery after rest periods or temperature changes. If every capacity is identical, you parsed the wrong field. If capacities are negative, you accidentally integrated current with the wrong sign rather than using NASA's `Capacity` field.

### What could go wrong

**The direct download returns an HTTP error.** Download the zip manually from the NASA PCoE repository page and place it at `chapter8_soh_aging_workspace/data/raw/Battery_Data_Set.zip`. Then rerun the script; it will skip the download.

**`Found 0 MATLAB files`.** Inspect the extracted folder. Some zip tools create an extra nested directory. Change `NASA_EXTRACT_DIR.rglob("B*.mat")` to `NASA_EXTRACT_DIR.rglob("*.mat")` and print the discovered paths.

**`Expected variable B0005 inside B0005.mat`.** Some mirrors rename the top-level MATLAB variable. Open the file keys with `print(loadmat(mat_file).keys())` and adjust `cell_name`.

**Capacity appears to increase with aging.** Check that you are comparing one cell at a time. Do not sort all cells only by cycle number, because different cells have different initial capacities and protocols.

### Reflection

This exercise taught the first serious aging lesson: SOH begins as a data-engineering problem. Before fitting, forecasting, or invoking degradation mechanisms, you need a defensible table that says which cell, which cycle, which capacity, which temperature, and which time base you are using. We will reuse `nasa_capacity_table.csv` throughout the chapter.

## Guided Walkthrough 2: Fit Empirical Capacity-Fade Models

**Learning objective:** Fit square-root and power-law capacity-fade models to NASA capacity data and compare their residuals, confidence intervals, and 500-cycle predictions.

Now that we have a clean capacity table, we can fit models. We will choose one NASA cell for a detailed walk-through, then write the code so it can be applied to every cell. The square-root model is the disciplined starting point because it has only two parameters. The power-law model adds a third parameter and often improves fit, but it can extrapolate badly if the observed cycle window is short.

```python
from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit


CHAPTER_ROOT = Path("chapter8_soh_aging_workspace")
PROCESSED_DIR = CHAPTER_ROOT / "data" / "processed"
FIGURE_DIR = CHAPTER_ROOT / "figures"
RESULTS_DIR = CHAPTER_ROOT / "results"
FIGURE_DIR.mkdir(parents=True, exist_ok=True)
RESULTS_DIR.mkdir(parents=True, exist_ok=True)

capacity_table = pd.read_csv(PROCESSED_DIR / "nasa_capacity_table.csv")
available_cells = sorted(capacity_table["cell_id"].unique())
print("Available cells:", available_cells)

CELL_ID = "B0005" if "B0005" in available_cells else available_cells[0]
cell_data = capacity_table.loc[capacity_table["cell_id"] == CELL_ID].copy()
cell_data = cell_data.sort_values("discharge_index")

cycles = cell_data["discharge_index"].to_numpy(dtype=float)
capacity_ah = cell_data["capacity_ah"].to_numpy(dtype=float)
initial_measured_capacity = capacity_ah[0]


def sqrt_capacity_model(cycle_number, capacity_0, sqrt_fade_coefficient):
    return capacity_0 - sqrt_fade_coefficient * np.sqrt(cycle_number)


def power_law_capacity_model(cycle_number, capacity_0, fade_coefficient, exponent):
    return capacity_0 - fade_coefficient * np.power(cycle_number, exponent)


sqrt_parameters, sqrt_covariance = curve_fit(
    sqrt_capacity_model,
    cycles,
    capacity_ah,
    p0=[initial_measured_capacity, 0.02],
    bounds=([1.0, 0.0], [2.5, 0.5]),
)

power_parameters, power_covariance = curve_fit(
    power_law_capacity_model,
    cycles,
    capacity_ah,
    p0=[initial_measured_capacity, 0.02, 0.5],
    bounds=([1.0, 0.0, 0.05], [2.5, 1.0, 2.0]),
    maxfev=20_000,
)

sqrt_prediction = sqrt_capacity_model(cycles, *sqrt_parameters)
power_prediction = power_law_capacity_model(cycles, *power_parameters)

sqrt_residual = capacity_ah - sqrt_prediction
power_residual = capacity_ah - power_prediction


def rmse(values):
    return float(np.sqrt(np.mean(np.square(values))))


sqrt_rmse = rmse(sqrt_residual)
power_rmse = rmse(power_residual)

sqrt_standard_error = np.sqrt(np.diag(sqrt_covariance))
power_standard_error = np.sqrt(np.diag(power_covariance))

print(f"Cell: {CELL_ID}")
print(
    "Square-root model: "
    f"Q0={sqrt_parameters[0]:.4f} Ah +/- {1.96 * sqrt_standard_error[0]:.4f}, "
    f"k={sqrt_parameters[1]:.5f} +/- {1.96 * sqrt_standard_error[1]:.5f}, "
    f"RMSE={sqrt_rmse:.5f} Ah"
)
print(
    "Power-law model: "
    f"Q0={power_parameters[0]:.4f} Ah +/- {1.96 * power_standard_error[0]:.4f}, "
    f"k={power_parameters[1]:.5f} +/- {1.96 * power_standard_error[1]:.5f}, "
    f"b={power_parameters[2]:.3f} +/- {1.96 * power_standard_error[2]:.3f}, "
    f"RMSE={power_rmse:.5f} Ah"
)

forecast_cycles = np.arange(1, 501, dtype=float)
sqrt_forecast = sqrt_capacity_model(forecast_cycles, *sqrt_parameters)
power_forecast = power_law_capacity_model(forecast_cycles, *power_parameters)

eol_capacity_ah = 0.70 * initial_measured_capacity


def first_eol_cycle(cycle_grid, capacity_grid, threshold_ah):
    below = np.flatnonzero(capacity_grid <= threshold_ah)
    if below.size == 0:
        return np.nan
    return float(cycle_grid[below[0]])


sqrt_eol = first_eol_cycle(forecast_cycles, sqrt_forecast, eol_capacity_ah)
power_eol = first_eol_cycle(forecast_cycles, power_forecast, eol_capacity_ah)

print(f"Relative 70% EOL threshold: {eol_capacity_ah:.4f} Ah")
print(f"Square-root forecast EOL cycle: {sqrt_eol}")
print(f"Power-law forecast EOL cycle: {power_eol}")

fig, axes = plt.subplots(2, 1, figsize=(8.0, 7.0), sharex=False)

axes[0].plot(cycles, capacity_ah, "o", label="NASA discharge capacity", markersize=4)
axes[0].plot(forecast_cycles, sqrt_forecast, "-", label="Square-root fit")
axes[0].plot(forecast_cycles, power_forecast, "--", label="Power-law fit")
axes[0].axhline(eol_capacity_ah, color="black", linestyle=":", label="70% relative EOL")
axes[0].set_xlabel("Discharge cycle number")
axes[0].set_ylabel("Capacity (Ah)")
axes[0].set_title(f"Capacity fade model comparison for NASA cell {CELL_ID}")
axes[0].grid(True, alpha=0.3)
axes[0].legend()

axes[1].plot(cycles, sqrt_residual * 1000, "o-", label="Square-root residual")
axes[1].plot(cycles, power_residual * 1000, "s-", label="Power-law residual")
axes[1].axhline(0.0, color="black", linewidth=1.0)
axes[1].set_xlabel("Discharge cycle number")
axes[1].set_ylabel("Residual (mAh)")
axes[1].grid(True, alpha=0.3)
axes[1].legend()

fig.tight_layout()
figure_path = FIGURE_DIR / f"{CELL_ID}_capacity_fade_models.png"
fig.savefig(figure_path, dpi=200)
print(f"Saved figure to {figure_path}")

fit_summary = pd.DataFrame(
    [
        {
            "cell_id": CELL_ID,
            "model": "sqrt",
            "capacity_0_ah": sqrt_parameters[0],
            "fade_coefficient": sqrt_parameters[1],
            "exponent": 0.5,
            "rmse_ah": sqrt_rmse,
            "forecast_eol_cycle": sqrt_eol,
        },
        {
            "cell_id": CELL_ID,
            "model": "power_law",
            "capacity_0_ah": power_parameters[0],
            "fade_coefficient": power_parameters[1],
            "exponent": power_parameters[2],
            "rmse_ah": power_rmse,
            "forecast_eol_cycle": power_eol,
        },
    ]
)
fit_summary.to_csv(RESULTS_DIR / f"{CELL_ID}_aging_fit_summary.csv", index=False)
print(fit_summary.to_string(index=False))
```

The `curve_fit` calls estimate model parameters by minimizing squared voltage-independent capacity errors. The bounds matter. Without bounds, the power-law model can choose a negative fade coefficient and an odd exponent that fits early noise but violates physical monotonic fade. Bounds do not make the model true, but they prevent obviously nonphysical parameter combinations.

The plot has two panels. The top panel shows capacity in ampere-hours versus discharge cycle number. The NASA measurements should appear as discrete markers. The square-root fit should be a smooth concave-down curve. The power-law fit may lie closer to the data if the cell has a fade trend that is not exactly square-root. The horizontal dotted line marks 70% of the first measured capacity, a relative EOL definition. The bottom panel shows residuals in mAh. Correct residuals should scatter around zero rather than show a large systematic wave. A systematic wave means the model is missing a regime change, a protocol effect, or a recovery effect.

Expected terminal output will look like this in structure:

```text
Available cells: ['B0005', 'B0006', 'B0007', 'B0018', 'B0025']
Cell: B0005
Square-root model: Q0=1.9021 Ah +/- 0.0184, k=0.02416 +/- 0.00172, RMSE=0.01890 Ah
Power-law model: Q0=1.8726 Ah +/- 0.0127, k=0.00682 +/- 0.00240, b=0.756 +/- 0.071, RMSE=0.01480 Ah
Relative 70% EOL threshold: 1.2996 Ah
Square-root forecast EOL cycle: 487.0
Power-law forecast EOL cycle: 331.0
Saved figure to chapter8_soh_aging_workspace/figures/B0005_capacity_fade_models.png
```

Do not expect both models to predict the same EOL cycle. That difference is the point. Long-horizon aging forecasts can be dominated by model form even when short-horizon RMSE differs only slightly.

### What could go wrong

**The power-law fit returns an exponent at the bound.** That usually means the dataset does not support a freely fitted exponent. Report that honestly and prefer the simpler square-root model.

**The fitted initial capacity is larger than any measured capacity.** That is normal because `Q0` is an extrapolated intercept. It becomes suspicious only if it is far outside the plausible rated-capacity range.

**The forecast capacity becomes negative before 500 cycles.** Your power-law exponent or coefficient is too aggressive for extrapolation. Restrict the forecast horizon or use a more physically constrained model.

**Residuals show step changes.** Investigate temperature, rest duration, and protocol changes. A single smooth model may be inappropriate across all regimes.

### Reflection

This exercise separated fitting from forecasting. Fitting asks how well a model explains observed data. Forecasting asks what the model implies outside the observed window. Reviewers care about that distinction because many aging models look excellent on a known history and fail when extrapolated.

## Guided Walkthrough 3: Add Temperature and Current Stress Terms

**Learning objective:** Extend the empirical model into a semi-empirical stress model and learn when the dataset cannot identify a parameter.

The NASA cells were cycled at different temperatures and discharge conditions. That makes the dataset useful for health-model validation, but it does not automatically make every stress term identifiable. A common mistake is to fit an Arrhenius activation energy from one cell or one narrow temperature range. We will instead fit a simple pooled model across cells and treat the result as an apparent stress correlation, not a universal mechanism.

We will use the table fields `ambient_temperature_c` and `mean_discharge_current_a`. NASA current sign conventions can vary by field and file. We will use the absolute value of the mean discharge current as a stress magnitude. This is standard practice for a capacity-fade correlation, but it hides charge/discharge asymmetry. In a paper, state that choice.

```python
from pathlib import Path
import numpy as np
import pandas as pd
from scipy.optimize import least_squares
import matplotlib.pyplot as plt


CHAPTER_ROOT = Path("chapter8_soh_aging_workspace")
PROCESSED_DIR = CHAPTER_ROOT / "data" / "processed"
FIGURE_DIR = CHAPTER_ROOT / "figures"
RESULTS_DIR = CHAPTER_ROOT / "results"

capacity_table = pd.read_csv(PROCESSED_DIR / "nasa_capacity_table.csv")
capacity_table = capacity_table.sort_values(["cell_id", "discharge_index"]).copy()

capacity_table["cycle_scaled"] = capacity_table["discharge_index"].astype(float)
capacity_table["temperature_k"] = capacity_table["ambient_temperature_c"] + 273.15
capacity_table["current_stress_a"] = capacity_table["mean_discharge_current_a"].abs()
capacity_table["initial_capacity_ah"] = capacity_table.groupby("cell_id")[
    "capacity_ah"
].transform("first")
capacity_table["fade_ah"] = (
    capacity_table["initial_capacity_ah"] - capacity_table["capacity_ah"]
)

fit_data = capacity_table.dropna(
    subset=["fade_ah", "cycle_scaled", "temperature_k", "current_stress_a"]
).copy()
fit_data = fit_data.loc[fit_data["cycle_scaled"] > 0]

gas_constant = 8.314462618
reference_temperature_k = 298.15
reference_current_a = fit_data["current_stress_a"].median()


def semi_empirical_fade(parameters, table):
    log_k_ref, activation_energy_j_mol, current_exponent, cycle_exponent = parameters
    temperature_factor = np.exp(
        (-activation_energy_j_mol / gas_constant)
        * ((1.0 / table["temperature_k"].to_numpy()) - (1.0 / reference_temperature_k))
    )
    current_factor = np.power(
        table["current_stress_a"].to_numpy() / reference_current_a,
        current_exponent,
    )
    cycle_factor = np.power(table["cycle_scaled"].to_numpy(), cycle_exponent)
    return np.exp(log_k_ref) * temperature_factor * current_factor * cycle_factor


def residual_function(parameters, table):
    predicted_fade_ah = semi_empirical_fade(parameters, table)
    measured_fade_ah = table["fade_ah"].to_numpy()
    return predicted_fade_ah - measured_fade_ah


initial_guess = np.array([
    np.log(0.01),
    25_000.0,
    0.5,
    0.5,
])

lower_bounds = np.array([
    np.log(1e-5),
    0.0,
    0.0,
    0.1,
])

upper_bounds = np.array([
    np.log(1.0),
    80_000.0,
    3.0,
    1.5,
])

result = least_squares(
    residual_function,
    initial_guess,
    args=(fit_data,),
    bounds=(lower_bounds, upper_bounds),
    loss="soft_l1",
    f_scale=0.02,
    max_nfev=20_000,
)

log_k_ref, activation_energy_j_mol, current_exponent, cycle_exponent = result.x
fit_data["predicted_fade_ah"] = semi_empirical_fade(result.x, fit_data)
fit_data["predicted_capacity_ah"] = (
    fit_data["initial_capacity_ah"] - fit_data["predicted_fade_ah"]
)
fit_data["residual_mah"] = (
    fit_data["capacity_ah"] - fit_data["predicted_capacity_ah"]
) * 1000

rmse_ah = np.sqrt(
    np.mean((fit_data["capacity_ah"] - fit_data["predicted_capacity_ah"]) ** 2)
)

print("Semi-empirical pooled stress model")
print(f"k_ref: {np.exp(log_k_ref):.6f} Ah/cycle^b")
print(f"apparent activation energy: {activation_energy_j_mol / 1000:.2f} kJ/mol")
print(f"current exponent: {current_exponent:.3f}")
print(f"cycle exponent: {cycle_exponent:.3f}")
print(f"capacity RMSE: {rmse_ah:.5f} Ah")
print(f"optimizer success: {result.success}, message: {result.message}")

summary_path = RESULTS_DIR / "nasa_pooled_stress_model_predictions.csv"
fit_data.to_csv(summary_path, index=False)
print(f"Wrote predictions to {summary_path}")

fig, axes = plt.subplots(1, 2, figsize=(11.0, 4.5))

for cell_id, group in fit_data.groupby("cell_id"):
    axes[0].plot(
        group["discharge_index"],
        group["capacity_ah"],
        "o",
        markersize=3,
        label=f"{cell_id} measured",
        alpha=0.65,
    )
    axes[0].plot(
        group["discharge_index"],
        group["predicted_capacity_ah"],
        "-",
        linewidth=1.4,
        label=f"{cell_id} predicted",
    )

axes[0].set_xlabel("Discharge cycle number")
axes[0].set_ylabel("Capacity (Ah)")
axes[0].set_title("Pooled semi-empirical aging model")
axes[0].grid(True, alpha=0.3)
axes[0].legend(fontsize=7, ncol=2)

axes[1].hist(fit_data["residual_mah"], bins=30, edgecolor="black")
axes[1].axvline(0.0, color="black", linewidth=1.0)
axes[1].set_xlabel("Capacity residual (mAh)")
axes[1].set_ylabel("Count")
axes[1].set_title("Residual distribution")
axes[1].grid(True, alpha=0.3)

fig.tight_layout()
figure_path = FIGURE_DIR / "nasa_pooled_stress_model.png"
fig.savefig(figure_path, dpi=200)
print(f"Saved figure to {figure_path}")
```

The temperature factor in this model is written relative to a reference temperature so that `k_ref` remains numerically reasonable. The expression is equivalent to an Arrhenius scaling, but centered at 298.15 K. The robust `soft_l1` loss reduces the influence of occasional apparent capacity recovery or anomalous cycles. This is one of several valid approaches. Another defensible approach would be to identify and remove outlier cycles before fitting with ordinary least squares. The important habit is to state the choice.

The expected figure has measured and predicted capacity traces for several cells on the left. A good model captures broad trends but will not pass through every point. The right panel shows residuals in mAh. A narrow residual distribution centered near zero is good. A strongly skewed distribution suggests systematic underprediction or overprediction. Separate residual clusters often mean different cells or protocols need separate model terms.

The printed apparent activation energy should be treated carefully. If the optimizer pushes it to `0` or `80 kJ/mol`, the dataset and model form are not identifying it. That is a result, not a failure. It means your paper should not claim a measured activation energy from this fit.

### What could go wrong

**The optimizer succeeds but the parameters are physically strange.** Check whether all cells have the same ambient temperature or current stress. Parameters cannot be identified without variation.

**The model predicts negative fade for early cycles.** This implementation cannot predict negative fade because the model is multiplicative and positive. If your modified model does, constrain it.

**The current exponent is meaningless.** NASA discharge current is only one part of the stress history. Charge protocol and rest time also matter. Do not over-interpret a current exponent fitted from discharge summary rows alone.

### Reflection

This exercise taught a subtle research lesson: adding physics-sounding terms does not guarantee physical identification. Semi-empirical aging models are useful, but only when the dataset contains the variation needed to support the terms you fit.

## Guided Walkthrough 4: Simulate SEI-Driven Aging in PyBaMM

**Learning objective:** Run a PyBaMM lithium-ion model with an SEI degradation option and extract capacity-relevant aging variables over repeated cycles.

PyBaMM lets us express degradation through model options rather than manually coding every side reaction. In Textbook Chapter 7, SEI growth was a parasitic reaction that consumes cyclable inventory. In PyBaMM, selecting an SEI option adds the corresponding submodel to the electrochemical model. The exact list of available options can change across PyBaMM releases, so we will use a defensive pattern: create a DFN model with a conservative SEI option, run a short repeated experiment, and print available degradation variables before plotting.

This example is lithium-ion because PyBaMM's built-in parameter sets are much richer for Li-ion than for sodium-ion. The workflow is still valuable for sodium-ion research. Once you have a sodium-ion parameter set and side-reaction parameters, the same simulation structure applies.

```python
from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import pybamm


CHAPTER_ROOT = Path("chapter8_soh_aging_workspace")
FIGURE_DIR = CHAPTER_ROOT / "figures"
RESULTS_DIR = CHAPTER_ROOT / "results"
FIGURE_DIR.mkdir(parents=True, exist_ok=True)
RESULTS_DIR.mkdir(parents=True, exist_ok=True)

pybamm.set_logging_level("NOTICE")

model = pybamm.lithium_ion.DFN(
    {
        "SEI": "solvent-diffusion limited",
        "SEI porosity change": "true",
    }
)

parameter_values = pybamm.ParameterValues("OKane2022")

experiment = pybamm.Experiment(
    [
        (
            "Discharge at 1C until 2.5 V",
            "Rest for 10 minutes",
            "Charge at 1C until 4.2 V",
            "Hold at 4.2 V until C/20",
            "Rest for 10 minutes",
        )
    ]
    * 20
)

solver = pybamm.CasadiSolver(mode="safe", dt_max=60)

simulation = pybamm.Simulation(
    model,
    parameter_values=parameter_values,
    experiment=experiment,
    solver=solver,
)

solution = simulation.solve()

print("Simulation solved.")
print(f"Number of cycles in solution: {len(solution.cycles)}")

candidate_variables = [
    "Loss of lithium inventory [%]",
    "Loss of capacity to negative SEI [A.h]",
    "X-averaged negative SEI thickness [m]",
    "Terminal voltage [V]",
    "Current [A]",
    "Discharge capacity [A.h]",
]

available_variables = []
for variable_name in candidate_variables:
    if variable_name in solution.all_models[0].variables:
        available_variables.append(variable_name)
        print(f"Available: {variable_name}")
    else:
        print(f"Not available in this PyBaMM version/model: {variable_name}")

cycle_rows = []
for cycle_number, cycle_solution in enumerate(solution.cycles, start=1):
    row = {"cycle_number": cycle_number}

    for variable_name in available_variables:
        variable = cycle_solution[variable_name]
        entries = np.asarray(variable.entries).ravel()
        if entries.size == 0:
            continue
        safe_name = (
            variable_name.lower()
            .replace(" ", "_")
            .replace("[", "")
            .replace("]", "")
            .replace(".", "")
            .replace("/", "_per_")
            .replace("%", "percent")
        )
        row[f"final_{safe_name}"] = float(entries[-1])

    cycle_rows.append(row)

cycle_summary = pd.DataFrame(cycle_rows)
summary_path = RESULTS_DIR / "pybamm_sei_cycle_summary.csv"
cycle_summary.to_csv(summary_path, index=False)
print(cycle_summary.tail().to_string(index=False))
print(f"Wrote PyBaMM cycle summary to {summary_path}")

fig, axes = plt.subplots(2, 1, figsize=(8.0, 7.0), sharex=True)

plot_columns = [
    column for column in cycle_summary.columns
    if "loss_of_lithium_inventory" in column
]

if plot_columns:
    axes[0].plot(
        cycle_summary["cycle_number"],
        cycle_summary[plot_columns[0]],
        "o-",
        linewidth=1.8,
    )
    axes[0].set_ylabel("LLI (%)")
else:
    axes[0].text(
        0.5,
        0.5,
        "LLI variable not available",
        ha="center",
        va="center",
        transform=axes[0].transAxes,
    )
    axes[0].set_ylabel("Diagnostic")

sei_columns = [column for column in cycle_summary.columns if "sei_thickness" in column]
if sei_columns:
    axes[1].plot(
        cycle_summary["cycle_number"],
        cycle_summary[sei_columns[0]] * 1e9,
        "s-",
        linewidth=1.8,
    )
    axes[1].set_ylabel("SEI thickness (nm)")
else:
    axes[1].text(
        0.5,
        0.5,
        "SEI thickness variable not available",
        ha="center",
        va="center",
        transform=axes[1].transAxes,
    )
    axes[1].set_ylabel("Diagnostic")

axes[1].set_xlabel("Cycle number")
for axis in axes:
    axis.grid(True, alpha=0.3)

fig.suptitle("PyBaMM DFN simulation with SEI aging")
fig.tight_layout()
figure_path = FIGURE_DIR / "pybamm_sei_aging_summary.png"
fig.savefig(figure_path, dpi=200)
print(f"Saved figure to {figure_path}")
```

The important line is the model construction:

```python
model = pybamm.lithium_ion.DFN(
    {
        "SEI": "solvent-diffusion limited",
        "SEI porosity change": "true",
    }
)
```

That dictionary changes the governing model by adding degradation physics. The parameter set `OKane2022` is chosen because it was developed for degradation studies and is a better starting point for SEI-related simulations than a purely fresh-cell parameter set. The experiment repeats a discharge, rest, charge, CV hold, and rest sequence 20 times. Twenty cycles is not enough for a lifetime study, but it is enough to verify that the workflow produces monotonically evolving degradation variables.

The expected plot has two panels. The first panel should show loss of lithium inventory increasing with cycle number if that variable is available. The second should show SEI thickness increasing, usually slowly and monotonically. If the axes are flat, the degradation rate may be too small over 20 cycles or the plotted variable is not the right one for your PyBaMM version. Increase the cycle count only after you know the short run works.

### What could go wrong

**PyBaMM raises an option error.** Print `pybamm.lithium_ion.DFN().options.possible_options` or consult the installed PyBaMM docs for your version. Degradation option names have changed across releases.

**The solver fails midway through the experiment.** Reduce `dt_max`, use `mode="safe"`, or run fewer cycles. Solver failures in aging simulations often come from stiff side reactions and voltage cutoffs interacting.

**The run takes too long.** Start with the SPM or SPMe using the same degradation options where supported. Use the DFN only after you know which variables and protocol you need.

**No capacity fade appears.** Degradation over 20 cycles may be small. Plot internal degradation variables first, then scale the cycle count.

### Reflection

This exercise showed the difference between fitting observed SOH and simulating a degradation mechanism. PyBaMM gives mechanistic access, but that access comes with parameter and solver responsibilities. You should now be able to run a small degradation simulation, extract internal health variables, and decide whether the result is numerically plausible.

## Guided Walkthrough 5: Implement the Same Aging Model in MATLAB

**Learning objective:** Reproduce the fitted empirical capacity-fade model in MATLAB and generate a 500-cycle SOH forecast.

MATLAB remains common in BMS workflows, and your Chapter 6 and Chapter 7 scripts are already in MATLAB. Here we implement the square-root and power-law models from Walkthrough 2 using a small CSV exported from Python. This mirrors a realistic workflow: Python parses messy public data; MATLAB uses the fitted parameters inside a controls or estimator prototype.

First, make sure the Python script from Walkthrough 2 wrote `chapter8_soh_aging_workspace/results/B0005_aging_fit_summary.csv` or the corresponding file for your chosen cell. Then run this MATLAB script from the repository root.

```matlab
clear; close all; clc;

chapterRoot = fullfile(pwd, "chapter8_soh_aging_workspace");
resultsDir = fullfile(chapterRoot, "results");
figuresDir = fullfile(chapterRoot, "figures");

if ~exist(figuresDir, "dir")
    mkdir(figuresDir);
end

fitFiles = dir(fullfile(resultsDir, "*_aging_fit_summary.csv"));
if isempty(fitFiles)
    error("No aging fit summary CSV found. Run the Python fitting walkthrough first.");
end

fitPath = fullfile(fitFiles(1).folder, fitFiles(1).name);
fitSummary = readtable(fitPath, "TextType", "string");
disp(fitSummary);

sqrtRow = fitSummary(fitSummary.model == "sqrt", :);
powerRow = fitSummary(fitSummary.model == "power_law", :);

cycleNumber = (1:500)';

sqrtCapacityAh = sqrtRow.capacity_0_ah ...
    - sqrtRow.fade_coefficient .* sqrt(cycleNumber);

powerCapacityAh = powerRow.capacity_0_ah ...
    - powerRow.fade_coefficient .* cycleNumber .^ powerRow.exponent;

initialCapacityAh = sqrtCapacityAh(1);
sqrtSoh = sqrtCapacityAh ./ initialCapacityAh;
powerSoh = powerCapacityAh ./ initialCapacityAh;

eolThreshold = 0.70;
sqrtEolIndex = find(sqrtSoh <= eolThreshold, 1, "first");
powerEolIndex = find(powerSoh <= eolThreshold, 1, "first");

if isempty(sqrtEolIndex)
    sqrtEolText = "not reached by cycle 500";
else
    sqrtEolText = "cycle " + string(sqrtEolIndex);
end

if isempty(powerEolIndex)
    powerEolText = "not reached by cycle 500";
else
    powerEolText = "cycle " + string(powerEolIndex);
end

fprintf("Square-root model EOL: %s\n", sqrtEolText);
fprintf("Power-law model EOL: %s\n", powerEolText);

forecastTable = table( ...
    cycleNumber, ...
    sqrtCapacityAh, ...
    powerCapacityAh, ...
    sqrtSoh, ...
    powerSoh);

forecastPath = fullfile(resultsDir, "matlab_500_cycle_forecast.csv");
writetable(forecastTable, forecastPath);
fprintf("Wrote MATLAB forecast to %s\n", forecastPath);

figure("Color", "w");
tiledlayout(2, 1);

nexttile;
plot(cycleNumber, sqrtCapacityAh, "LineWidth", 1.8);
hold on;
plot(cycleNumber, powerCapacityAh, "--", "LineWidth", 1.8);
yline(0.70 * initialCapacityAh, ":", "70% relative EOL");
grid on;
xlabel("Cycle number");
ylabel("Capacity (Ah)");
title("MATLAB 500-cycle capacity forecast");
legend("Square-root model", "Power-law model", "Location", "best");

nexttile;
plot(cycleNumber, 100 * sqrtSoh, "LineWidth", 1.8);
hold on;
plot(cycleNumber, 100 * powerSoh, "--", "LineWidth", 1.8);
yline(70, ":", "70% SOH");
grid on;
xlabel("Cycle number");
ylabel("SOH (%)");
title("SOH forecast");
legend("Square-root model", "Power-law model", "Location", "best");

figurePath = fullfile(figuresDir, "matlab_500_cycle_soh_forecast.png");
exportgraphics(gcf, figurePath, "Resolution", 200);
fprintf("Saved figure to %s\n", figurePath);
```

The MATLAB code is intentionally close to the equations. `sqrtCapacityAh` implements Equation (1). `powerCapacityAh` implements Equation (2). The `find` calls determine whether the forecast crosses 70% SOH within 500 cycles. This is not a probabilistic RUL estimate; it is a deterministic forecast under the fitted model.

The expected figure has two panels. The upper panel shows capacity in ampere-hours for cycles 1 through 500. The lower panel shows SOH in percent. If the power-law exponent is larger than 0.5, the dashed power-law curve may fall faster than the square-root curve at long cycle counts. If the exponent is smaller than 0.5, it may fade more slowly. The gap between curves is a visual reminder that extrapolation depends heavily on model form.

### What could go wrong

**MATLAB cannot find the CSV.** Check your current folder with `pwd`. The script assumes you run from the same root that contains `chapter8_soh_aging_workspace`.

**`readtable` imports model names as cell arrays.** Use a newer MATLAB release or replace `fitSummary.model == "sqrt"` with `strcmp(fitSummary.model, "sqrt")`.

**The forecast starts below 100% SOH.** We define SOH relative to `sqrtCapacityAh(1)`, not the fitted intercept at cycle 0. If you prefer rated capacity, replace `initialCapacityAh` with the rated value and state that choice.

### Reflection

This exercise made the Python-MATLAB boundary concrete. For research, you should not maintain two independent aging models by hand. Fit once, export parameters, and consume those parameters in the second environment with a short, auditable script.

## Guided Walkthrough 6: SOH from Partial Curves with ICA and DVA

**Learning objective:** Compute incremental-capacity and differential-voltage features from NASA discharge curves and track how the features change with aging.

Capacity fade is not always available directly. In field systems, we may only observe partial charge or discharge segments. ICA and DVA help extract health-sensitive features from voltage-capacity curves. The method is numerically delicate because differentiation amplifies noise. We will therefore smooth the voltage-capacity curve before differentiating.

NASA discharge data include measured voltage, current, time, and capacity. We will reconstruct cumulative discharged capacity from current and time so the method does not depend on the scalar `Capacity` field. This is also where sign convention matters. We use absolute current magnitude because discharge current may be stored as positive or negative depending on source.

```python
from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.io import loadmat
from scipy.signal import savgol_filter


CHAPTER_ROOT = Path("chapter8_soh_aging_workspace")
RAW_DIR = CHAPTER_ROOT / "data" / "raw"
FIGURE_DIR = CHAPTER_ROOT / "figures"
RESULTS_DIR = CHAPTER_ROOT / "results"

NASA_EXTRACT_DIR = RAW_DIR / "NASA_Battery_Data_Set"


def unwrap_matlab_scalar(value):
    current = value
    while isinstance(current, np.ndarray) and current.size == 1:
        current = current.item()
    return current


def load_discharge_time_series(mat_path, selected_discharge_numbers):
    mat = loadmat(mat_path, squeeze_me=False, struct_as_record=False)
    cell_name = mat_path.stem
    cell_struct = unwrap_matlab_scalar(mat[cell_name])
    cycles = np.asarray(cell_struct.cycle).ravel()

    selected = {}
    discharge_index = 0
    for raw_cycle_index, cycle in enumerate(cycles, start=1):
        cycle_type = str(unwrap_matlab_scalar(cycle.type)).lower()
        if cycle_type != "discharge":
            continue

        discharge_index += 1
        if discharge_index not in selected_discharge_numbers:
            continue

        data = unwrap_matlab_scalar(cycle.data)
        time_s = np.asarray(data.Time, dtype=float).ravel()
        voltage_v = np.asarray(data.Voltage_measured, dtype=float).ravel()
        current_a = np.asarray(data.Current_measured, dtype=float).ravel()
        temperature_c = np.asarray(data.Temperature_measured, dtype=float).ravel()

        dt_s = np.diff(time_s, prepend=time_s[0])
        discharged_capacity_ah = np.cumsum(np.abs(current_a) * dt_s) / 3600.0
        discharged_capacity_ah -= discharged_capacity_ah[0]

        selected[discharge_index] = pd.DataFrame(
            {
                "time_s": time_s,
                "voltage_v": voltage_v,
                "current_a": current_a,
                "temperature_c": temperature_c,
                "discharged_capacity_ah": discharged_capacity_ah,
            }
        )

    return selected


def compute_ica_dva(curve, voltage_window=(2.8, 4.1), n_grid=600):
    clean = curve.dropna(subset=["voltage_v", "discharged_capacity_ah"]).copy()
    clean["remaining_capacity_ah"] = (
        clean["discharged_capacity_ah"].max() - clean["discharged_capacity_ah"]
    )
    clean = clean.sort_values("voltage_v")
    clean = clean.drop_duplicates(subset="voltage_v")
    clean = clean.loc[
        (clean["voltage_v"] >= voltage_window[0])
        & (clean["voltage_v"] <= voltage_window[1])
    ]

    voltage_grid = np.linspace(
        clean["voltage_v"].min(),
        clean["voltage_v"].max(),
        n_grid,
    )
    capacity_grid = np.interp(
        voltage_grid,
        clean["voltage_v"].to_numpy(),
        clean["remaining_capacity_ah"].to_numpy(),
    )

    window_length = 51
    if window_length >= n_grid:
        window_length = n_grid - 1 if n_grid % 2 == 0 else n_grid
    if window_length % 2 == 0:
        window_length += 1

    smoothed_capacity = savgol_filter(
        capacity_grid,
        window_length=window_length,
        polyorder=3,
    )

    dqdv = np.gradient(smoothed_capacity, voltage_grid)
    dvdq = np.gradient(voltage_grid, smoothed_capacity)

    return pd.DataFrame(
        {
            "voltage_v": voltage_grid,
            "remaining_capacity_ah": smoothed_capacity,
            "dqdv_ah_per_v": dqdv,
            "dvdq_v_per_ah": dvdq,
        }
    )


capacity_table = pd.read_csv(CHAPTER_ROOT / "data" / "processed" / "nasa_capacity_table.csv")
available_cells = sorted(capacity_table["cell_id"].unique())
cell_id = "B0005" if "B0005" in available_cells else available_cells[0]
mat_candidates = sorted(NASA_EXTRACT_DIR.rglob(f"{cell_id}.mat"))
if not mat_candidates:
    raise FileNotFoundError(f"Could not find {cell_id}.mat inside {NASA_EXTRACT_DIR}")

cell_capacity = capacity_table.loc[capacity_table["cell_id"] == cell_id]
first_cycle = int(cell_capacity["discharge_index"].min())
middle_cycle = int(cell_capacity["discharge_index"].median())
last_cycle = int(cell_capacity["discharge_index"].max())
selected_cycles = [first_cycle, middle_cycle, last_cycle]

curves = load_discharge_time_series(mat_candidates[0], selected_cycles)
ica_tables = {}
feature_rows = []

for discharge_index, curve in curves.items():
    ica_table = compute_ica_dva(curve)
    ica_tables[discharge_index] = ica_table

    peak_index = int(np.nanargmax(ica_table["dqdv_ah_per_v"].to_numpy()))
    peak_voltage = float(ica_table["voltage_v"].iloc[peak_index])
    peak_height = float(ica_table["dqdv_ah_per_v"].iloc[peak_index])

    feature_rows.append(
        {
            "cell_id": cell_id,
            "discharge_index": discharge_index,
            "ica_peak_voltage_v": peak_voltage,
            "ica_peak_height_ah_per_v": peak_height,
        }
    )

features = pd.DataFrame(feature_rows)
features_path = RESULTS_DIR / f"{cell_id}_ica_features.csv"
features.to_csv(features_path, index=False)
print(features.to_string(index=False))
print(f"Wrote ICA features to {features_path}")

fig, axes = plt.subplots(2, 1, figsize=(8.0, 7.0), sharex=True)

for discharge_index, table in ica_tables.items():
    label = f"Discharge {discharge_index}"
    axes[0].plot(table["voltage_v"], table["dqdv_ah_per_v"], label=label)
    axes[1].plot(table["voltage_v"], table["dvdq_v_per_ah"], label=label)

axes[0].set_ylabel("dQ/dV (Ah/V)")
axes[0].set_title(f"Incremental-capacity aging features for {cell_id}")
axes[0].grid(True, alpha=0.3)
axes[0].legend()

axes[1].set_xlabel("Voltage (V)")
axes[1].set_ylabel("dV/dQ (V/Ah)")
axes[1].set_title("Differential-voltage curves")
axes[1].grid(True, alpha=0.3)
axes[1].legend()

fig.tight_layout()
figure_path = FIGURE_DIR / f"{cell_id}_ica_dva_curves.png"
fig.savefig(figure_path, dpi=200)
print(f"Saved figure to {figure_path}")
```

The function `compute_ica_dva` first converts discharged capacity into remaining capacity. That step handles the discharge sign convention: as voltage increases along the sorted curve, remaining capacity should also increase, giving positive `dQ/dV` peaks. Sorting then lets us interpolate capacity as a function of voltage on a uniform voltage grid. The Savitzky-Golay filter smooths capacity before differentiation. The chosen `window_length=51` is a teaching value, not a universal constant. Too small a window produces noisy derivatives; too large a window erases real peaks.

The expected ICA plot shows one or more broad peaks in `dQ/dV` versus voltage. As the cell ages, peaks may shift in voltage, change height, or broaden. The DVA plot often looks sharper and can show large spikes if the capacity grid has flat or noisy regions. If your DVA panel is dominated by extreme vertical spikes, increase smoothing or restrict the voltage window.

The feature table should have three rows: early, middle, and late discharge. A useful feature changes systematically with aging. If peak voltage moves randomly, the feature may be too sensitive to noise, the voltage window may be wrong, or the selected cycles may include protocol differences.

### What could go wrong

**`np.gradient` produces infinities.** The smoothed capacity curve has repeated values, so `dV/dQ` divides by an almost-zero capacity difference. Increase smoothing or use ICA only for that segment.

**ICA peaks look upside down.** You may have sorted discharge data in a way that reverses capacity direction. Inspect `capacity_grid` and ensure it increases over the voltage grid used for differentiation.

**Peak features change because temperature changed.** ICA/DVA features are temperature-sensitive. Do not compare curves at different temperatures without saying so.

### Reflection

This exercise introduced SOH estimation from partial curves. It is not a replacement for capacity measurement, but it is a powerful diagnostic family. Later, in the specialization chapter, these features can become inputs to data-driven SOH models.

## Dataset Integration Notes

The NASA Battery Aging dataset is public and widely used for prognostics benchmarking. NASA's repository page identifies it as the "Battery Data Set" from B. Saha and K. Goebel at NASA Ames, with the direct archive link `https://phm-datasets.s3.amazonaws.com/NASA/5.+Battery+Data+Set.zip`. The NASA Open Data listing describes the experiments as charge, discharge, and impedance operations at different temperatures, with discharges to preset voltage thresholds and an EOL criterion of 30% fade from 2 Ah to 1.4 Ah.

The raw files are MATLAB `.mat` files. The top-level object is a cell-specific structure such as `B0005`. Inside it, `cycle` is a structure array. Each cycle has a `type`, commonly `charge`, `discharge`, or `impedance`. Discharge cycles include measured voltage, current, temperature, current at load, voltage at load, time, and a scalar capacity. The most common pitfalls are timestamp conversion, current sign convention, and comparing raw operation index with discharge-only index. We handled all three explicitly.

This is lithium-ion data. For sodium-ion research, the method generalizes but the fitted parameters do not. You can validate your data workflow, model-selection procedure, uncertainty reporting, and ICA/DVA code on NASA, then adapt the chemistry-specific interpretation to sodium-ion. The sparse public SIB situation means you may need to digitize capacity-fade curves from papers, use supplementary tables when available, or collaborate with an experimental group. When using digitized SIB data, report digitization error and do not overfit a high-parameter model to extracted points.

## Reproduction Exercise: Reproduce a Published Capacity-Fade Figure

**Target paper:** Kristen A. Severson, Peter M. Attia, Norman Jin, Nicholas Perkins, Benben Jiang, Zi Yang, Michael H. Chen, Muratahan Aykol, Patrick K. Herring, Dimitrios Fraggedakis, Martin Z. Bazant, Stephen J. Harris, William C. Chueh, and Richard D. Braatz, "Data-driven prediction of battery cycle life before capacity degradation," *Nature Energy*, 2019.

**Figure target:** Reproduce the central idea of the paper's capacity-fade trajectories: discharge capacity as a function of cycle number for multiple commercial LiFePO4/graphite cells, with cells showing different lifetimes under fast-charging protocols. The exact visual style of the journal figure is less important than reproducing the scientific content: many cells show little early capacity loss, then diverge strongly in cycle life.

This reproduction is included because it teaches the most important aging-research habit: capacity curves alone can be misleading early in life. Severson and coauthors showed that early-cycle voltage features can predict cycle life before obvious capacity degradation. We will not reproduce the machine-learning model here; that belongs in Chapter 13's data-driven SOH track. We will reproduce the capacity trajectory visualization and document every ambiguity.

The dataset associated with the Severson/Attia/Stanford-MIT-Toyota work has been distributed through public project pages and mirrors. Because access URLs and packaging have changed over time, use the official paper and its data availability statement first, then record the exact dataset URL, checksum if available, and date accessed in your research log. If you cannot obtain the dataset during this chapter, use the NASA capacity table to reproduce the figure style and mark it as a method reproduction rather than a data reproduction.

Here is a complete plotting script that works with a generic capacity table. If you have the Severson table, save it as `severson_capacity_table.csv` with columns `cell_id`, `cycle_number`, and `discharge_capacity_ah`. If not, the script falls back to NASA.

```python
from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


CHAPTER_ROOT = Path("chapter8_soh_aging_workspace")
PROCESSED_DIR = CHAPTER_ROOT / "data" / "processed"
FIGURE_DIR = CHAPTER_ROOT / "figures"
FIGURE_DIR.mkdir(parents=True, exist_ok=True)

severson_path = PROCESSED_DIR / "severson_capacity_table.csv"
nasa_path = PROCESSED_DIR / "nasa_capacity_table.csv"

if severson_path.exists():
    source_name = "Severson et al. public fast-charge dataset"
    raw = pd.read_csv(severson_path)
    capacity_table = raw.rename(
        columns={
            "cycle_number": "cycle",
            "discharge_capacity_ah": "capacity_ah",
        }
    )[["cell_id", "cycle", "capacity_ah"]].copy()
else:
    source_name = "NASA fallback method reproduction"
    raw = pd.read_csv(nasa_path)
    capacity_table = raw.rename(
        columns={
            "discharge_index": "cycle",
        }
    )[["cell_id", "cycle", "capacity_ah"]].copy()

capacity_table = capacity_table.dropna()
capacity_table = capacity_table.sort_values(["cell_id", "cycle"])
capacity_table["initial_capacity_ah"] = capacity_table.groupby("cell_id")[
    "capacity_ah"
].transform("first")
capacity_table["normalized_capacity"] = (
    capacity_table["capacity_ah"] / capacity_table["initial_capacity_ah"]
)

cell_lifetimes = (
    capacity_table.loc[capacity_table["normalized_capacity"] <= 0.80]
    .groupby("cell_id")["cycle"]
    .min()
    .rename("cycle_life_80_percent")
)
capacity_table = capacity_table.merge(
    cell_lifetimes,
    left_on="cell_id",
    right_index=True,
    how="left",
)

ordered_cells = (
    capacity_table.groupby("cell_id")["cycle_life_80_percent"]
    .min()
    .sort_values()
    .index
    .tolist()
)

if not ordered_cells:
    ordered_cells = sorted(capacity_table["cell_id"].unique())

fig, axis = plt.subplots(figsize=(8.5, 5.2))

for cell_id in ordered_cells:
    group = capacity_table.loc[capacity_table["cell_id"] == cell_id]
    lifetime = group["cycle_life_80_percent"].iloc[0]
    if np.isnan(lifetime):
        line_alpha = 0.45
        line_width = 1.0
    else:
        line_alpha = 0.85
        line_width = 1.3

    axis.plot(
        group["cycle"],
        group["normalized_capacity"],
        linewidth=line_width,
        alpha=line_alpha,
    )

axis.axhline(0.80, color="black", linestyle=":", linewidth=1.2)
axis.set_xlabel("Cycle number")
axis.set_ylabel("Discharge capacity normalized to first cycle")
axis.set_title(f"Capacity-fade trajectories: {source_name}")
axis.grid(True, alpha=0.3)
axis.set_ylim(0.65, 1.05)

figure_path = FIGURE_DIR / "reproduction_capacity_fade_trajectories.png"
fig.tight_layout()
fig.savefig(figure_path, dpi=250)

print(f"Source used: {source_name}")
print(f"Number of cells plotted: {capacity_table['cell_id'].nunique()}")
print(f"Saved reproduction figure to {figure_path}")
```

If you use the Severson dataset, a close reproduction should show many capacity trajectories beginning near 1.0 normalized capacity, remaining close together early, and then separating as cells age at different rates. If you use NASA fallback data, the plot will have fewer cells and shorter trajectories. That is not a failed exercise; it is a method reproduction rather than a dataset reproduction. Label it accordingly.

Where the paper is ambiguous, write down your choice. Did you normalize by cycle 1 capacity or nominal capacity? Did you define cycle life at 80% capacity or another threshold? Did you exclude early formation cycles? Did you smooth capacity? A reproduction log that records these choices is more valuable than a plot that looks polished but cannot be audited.

Close enough means the qualitative structure and axis definitions match the paper, and any quantitative differences are explainable by preprocessing choices. It does not mean pixel-perfect recreation of journal typography.

## Open-Ended Exercises

### Exercise 1: Model selection across all NASA cells

Fit square-root and power-law models to every NASA cell. Create a table with one row per cell and model containing RMSE, exponent, and 70% EOL forecast. Which model would you choose for a conservative RUL estimate, and why?

Hint: Wrap the fitting code from Walkthrough 2 in a function that accepts a cell-specific dataframe. Use `try` and `except` so that one bad cell does not stop the full sweep.

### Exercise 2: Train on early life, test on late life

For one cell, fit the square-root model using only the first 40% of discharge capacity measurements. Forecast the remaining 60%. Report train RMSE, test RMSE, and EOL forecast error if the cell reaches EOL.

Hint: Split by row order, not by random sampling. Aging is a time-series problem.

### Exercise 3: ICA feature robustness

Repeat the ICA calculation with Savitzky-Golay window lengths of 21, 51, and 101. How much does the peak voltage move? Is the feature robust enough to use in a paper?

Hint: Store peak voltage and peak height for each window length in a dataframe.

### Exercise 4: Sodium-ion stress thought experiment

Take the fitted square-root model and reduce the OCV diagnostic sensitivity by assuming the useful ICA peak height is 50% lower, as might happen in a flatter voltage region. What changes in your SOH estimator design?

Hint: This is a written exercise. Discuss observability, need for longer windows, and the role of temperature and impedance features.

## Worked Solutions

### Solution 1

```python
from pathlib import Path
import numpy as np
import pandas as pd
from scipy.optimize import curve_fit


CHAPTER_ROOT = Path("chapter8_soh_aging_workspace")
capacity_table = pd.read_csv(CHAPTER_ROOT / "data" / "processed" / "nasa_capacity_table.csv")


def sqrt_capacity_model(cycle_number, capacity_0, sqrt_fade_coefficient):
    return capacity_0 - sqrt_fade_coefficient * np.sqrt(cycle_number)


def power_law_capacity_model(cycle_number, capacity_0, fade_coefficient, exponent):
    return capacity_0 - fade_coefficient * np.power(cycle_number, exponent)


def rmse(residual):
    return float(np.sqrt(np.mean(np.square(residual))))


def first_eol_cycle(cycles, capacity, threshold):
    below = np.flatnonzero(capacity <= threshold)
    return np.nan if below.size == 0 else float(cycles[below[0]])


rows = []
for cell_id, group in capacity_table.groupby("cell_id"):
    group = group.sort_values("discharge_index")
    cycles = group["discharge_index"].to_numpy(dtype=float)
    capacity = group["capacity_ah"].to_numpy(dtype=float)
    if len(cycles) < 10:
        continue

    forecast_cycles = np.arange(1, 501, dtype=float)
    eol_threshold = 0.70 * capacity[0]

    sqrt_parameters, _ = curve_fit(
        sqrt_capacity_model,
        cycles,
        capacity,
        p0=[capacity[0], 0.02],
        bounds=([1.0, 0.0], [2.5, 0.5]),
    )
    sqrt_fit = sqrt_capacity_model(cycles, *sqrt_parameters)
    sqrt_forecast = sqrt_capacity_model(forecast_cycles, *sqrt_parameters)
    rows.append(
        {
            "cell_id": cell_id,
            "model": "sqrt",
            "rmse_ah": rmse(capacity - sqrt_fit),
            "exponent": 0.5,
            "forecast_eol_cycle": first_eol_cycle(
                forecast_cycles, sqrt_forecast, eol_threshold
            ),
        }
    )

    try:
        power_parameters, _ = curve_fit(
            power_law_capacity_model,
            cycles,
            capacity,
            p0=[capacity[0], 0.02, 0.5],
            bounds=([1.0, 0.0, 0.05], [2.5, 1.0, 2.0]),
            maxfev=20_000,
        )
        power_fit = power_law_capacity_model(cycles, *power_parameters)
        power_forecast = power_law_capacity_model(forecast_cycles, *power_parameters)
        rows.append(
            {
                "cell_id": cell_id,
                "model": "power_law",
                "rmse_ah": rmse(capacity - power_fit),
                "exponent": power_parameters[2],
                "forecast_eol_cycle": first_eol_cycle(
                    forecast_cycles, power_forecast, eol_threshold
                ),
            }
        )
    except RuntimeError:
        rows.append(
            {
                "cell_id": cell_id,
                "model": "power_law",
                "rmse_ah": np.nan,
                "exponent": np.nan,
                "forecast_eol_cycle": np.nan,
            }
        )

model_selection = pd.DataFrame(rows)
print(model_selection.sort_values(["cell_id", "model"]).to_string(index=False))
model_selection.to_csv(
    CHAPTER_ROOT / "results" / "all_cells_model_selection.csv",
    index=False,
)
```

A conservative RUL estimate is usually the model that predicts earlier EOL, provided it is not obviously nonphysical. If the power-law exponent is unstable or at a bound, prefer the square-root model and report that the flexible model was not identifiable.

### Solution 2

```python
from pathlib import Path
import numpy as np
import pandas as pd
from scipy.optimize import curve_fit


CHAPTER_ROOT = Path("chapter8_soh_aging_workspace")
capacity_table = pd.read_csv(CHAPTER_ROOT / "data" / "processed" / "nasa_capacity_table.csv")


def sqrt_capacity_model(cycle_number, capacity_0, sqrt_fade_coefficient):
    return capacity_0 - sqrt_fade_coefficient * np.sqrt(cycle_number)


def rmse(values):
    return float(np.sqrt(np.mean(np.square(values))))


cell_id = "B0005" if "B0005" in set(capacity_table["cell_id"]) else capacity_table["cell_id"].iloc[0]
cell = capacity_table.loc[capacity_table["cell_id"] == cell_id].sort_values("discharge_index")
split_index = int(np.floor(0.40 * len(cell)))

train = cell.iloc[:split_index]
test = cell.iloc[split_index:]

parameters, _ = curve_fit(
    sqrt_capacity_model,
    train["discharge_index"].to_numpy(dtype=float),
    train["capacity_ah"].to_numpy(dtype=float),
    p0=[train["capacity_ah"].iloc[0], 0.02],
    bounds=([1.0, 0.0], [2.5, 0.5]),
)

train_prediction = sqrt_capacity_model(
    train["discharge_index"].to_numpy(dtype=float),
    *parameters,
)
test_prediction = sqrt_capacity_model(
    test["discharge_index"].to_numpy(dtype=float),
    *parameters,
)

print(f"Cell: {cell_id}")
print(f"Train rows: {len(train)}, test rows: {len(test)}")
print(f"Train RMSE: {rmse(train['capacity_ah'].to_numpy() - train_prediction):.5f} Ah")
print(f"Test RMSE: {rmse(test['capacity_ah'].to_numpy() - test_prediction):.5f} Ah")
```

The test RMSE is the number to care about. If the train RMSE is excellent but the test RMSE is poor, the early-life data did not identify the later fade trend.

### Solution 3

Use the ICA code from Walkthrough 6 and replace `window_length = 51` with a function argument. A robust feature should not move more than a few millivolts across reasonable smoothing windows. If peak voltage shifts by tens of millivolts, the feature is not stable enough without a more careful preprocessing study.

### Solution 4

A flatter sodium-ion voltage region reduces the information content of voltage-derived health features, just as a flat OCV region weakens SOC observability in Chapter 7. The estimator should use longer time windows, include impedance or pulse-response features, and avoid claiming precise SOH from a small partial voltage segment. For a publishable sodium-ion study, pair ICA/DVA with capacity checks from occasional reference cycles or with physics-based constraints from a calibrated cell model.

## What Changes for Sodium-Ion?

The workflow changes less than the interpretation. A sodium-ion cell still has capacity, cycle number, temperature, current, voltage curves, and SOH. You can still parse cycling data, fit fade models, simulate candidate mechanisms, and compute ICA/DVA. The chemistry-specific changes are in the OCV shape, degradation mechanisms, parameter availability, and validation strategy.

Hard-carbon sodium-ion anodes often show voltage plateaus and sloping regions that differ from graphite. Cathode families such as layered oxides, polyanionic compounds, and Prussian blue analogues have different structural degradation pathways and voltage signatures. SEI chemistry is also different because electrolyte composition, sodium solvation, and interphase transport are not lithium copies with a different ion label. Therefore, do not take a PyBaMM Li-ion SEI parameter set, rename lithium to sodium, and call it a sodium-ion aging model.

For sodium-ion publishable work, use lithium-ion public data to validate the software workflow, then adapt the model with sodium-ion parameter sets and sodium-ion literature constraints. If you have only sparse SIB capacity data, fit low-parameter models, report uncertainty broadly, and avoid mechanistic claims that the data cannot support. If you digitize SIB capacity curves from papers, include digitization error and cite the original figure. Reviewers will accept careful limitation statements; they will not accept hidden overreach.

## Chapter Summary and Skill Checklist

- You parsed the NASA PCoE Battery Data Set from MATLAB `.mat` structures into a tidy SOH table.
- You fitted square-root and power-law capacity-fade models and compared residuals and 500-cycle forecasts.
- You built a pooled semi-empirical stress model with temperature and current terms, while learning when such terms are not identifiable.
- You ran a PyBaMM DFN simulation with SEI aging options and extracted cycle-level degradation variables.
- You reproduced the empirical aging forecast in MATLAB for BMS-oriented workflows.
- You computed ICA and DVA curves from raw discharge data and extracted peak features.
- You practiced a published-figure reproduction workflow for capacity-fade trajectories.

Commands, functions, and patterns that should now feel familiar:

- `requests.get`, `ZipFile.extractall`, `Path.rglob`
- `scipy.io.loadmat` with MATLAB struct unwrapping
- `pandas.groupby`, `transform`, `to_csv`, and table joins
- `scipy.optimize.curve_fit` and `least_squares`
- `pybamm.lithium_ion.DFN`, degradation `options`, `pybamm.Experiment`, `Simulation.solve`
- MATLAB `readtable`, `writetable`, `tiledlayout`, `exportgraphics`
- Savitzky-Golay smoothing with `scipy.signal.savgol_filter`
- ICA/DVA derivatives using `np.gradient`

You should now be able to:

- Build a clean capacity-versus-cycle table from a public aging dataset.
- State clearly whether SOH is relative to rated capacity or first measured capacity.
- Fit and compare empirical aging models without confusing fit quality with forecast reliability.
- Add stress terms only when the dataset contains enough variation to support them.
- Run a small PyBaMM degradation simulation and identify relevant health variables.
- Port fitted aging parameters into MATLAB and forecast SOH over 500+ cycles.
- Compute ICA/DVA features and explain their sensitivity to smoothing and temperature.
- Explain what must change before applying a Li-ion aging workflow to sodium-ion cells.

## Deliverable

Your deliverable is an aging model calibrated to NASA data in Python and a parallel implementation in MATLAB, with a comparison of predictions over 500+ cycles. The minimum acceptable submission contains:

- `nasa_capacity_table.csv` with one row per discharge cycle.
- A Python notebook or script that fits square-root and power-law models to at least one NASA cell.
- A 500-cycle Python forecast plot with capacity and SOH.
- A MATLAB script that reads the fitted parameters and reproduces the 500-cycle forecast.
- A short written analysis comparing the two model forms and explaining which forecast you would trust more.
- One ICA/DVA figure comparing early, middle, and late life for one cell.
- A reproduction log for the published capacity-fade figure exercise.

A strong submission also includes all-cell model selection, early-life train/test forecasting, residual plots, and a paragraph on sodium-ion adaptation.

## Further Practice and Reading

Bookmark the NASA PCoE repository page for dataset access and citation guidance: `https://www.nasa.gov/intelligent-systems-division/discovery-and-systems-health/pcoe/pcoe-data-set-repository/`. Also keep the NASA Open Data listing for metadata on the Li-ion Battery Aging dataset: `https://data.nasa.gov/dataset/li-ion-battery-aging-datasets`.

For PyBaMM, bookmark the official installation documentation and degradation examples at `https://docs.pybamm.org/`. PyBaMM's release notes are worth reading before long aging studies because degradation option names and compatible submodels can change.

For aging-data context, read Saha and Goebel's NASA battery dataset citation, Severson et al. (2019) on early prediction of battery cycle life, and Attia et al. (2020) on closed-loop fast-charging optimization. For sodium-ion aging, look for recent review papers and cell-specific cycling studies rather than assuming lithium-ion degradation parameters transfer directly.

Chapter 9 is next: **Thermal Modeling and Electrothermal Coupling**.

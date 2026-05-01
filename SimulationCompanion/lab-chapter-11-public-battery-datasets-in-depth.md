# Lab Chapter 11: Public Battery Datasets in Depth

## Chapter Opening

This chapter is where battery research becomes less tidy and more real. Up to now, most of our workflows have used either simulations we controlled or small datasets chosen for one task: an ECM fit, a Kalman-filter test, an aging curve, or a thermal parameter estimate. Publishable research almost never stays that clean. You will download public data from several laboratories, discover that files are named inconsistently, learn that current signs are not universal, find that some timestamps reset every cycle while others never reset, and build a loader that turns this mess into a reproducible research asset.

Keep Textbook Chapters 2, 6, 7, 8, 10, and 13 open as you work. This chapter operationalizes the measurement assumptions behind the electrochemical data you learned in Textbook Chapter 2, the degradation observables from Textbook Chapter 7, the cell-model validation logic from Textbook Chapter 8, the BMS signal conventions from Textbook Chapter 10, and the sodium-ion research constraints from Textbook Chapter 13. The theory textbook taught you what voltage, current, capacity, SOC, SOH, temperature, and impedance mean. This chapter teaches you how those quantities arrive on your laptop, how they get damaged by file formats and test conventions, and how to make them usable without laundering away the uncertainty.

The skill target is not "download a dataset." Anyone can do that. The target is dataset competence: finding credible sources, recording licenses and citations, parsing raw files into consistent units, detecting cycles, handling rest periods, validating sign conventions, and writing a small Python package that lets later chapters treat public data as a stable input. This is the difference between a notebook that worked once and a research workflow that survives peer review.

For sodium-ion work, this skill matters even more than it does for lithium-ion. Public lithium-ion datasets are mature enough that you can usually validate a workflow on NASA, CALCE, Oxford, Sandia, or Severson-style fast-charge data. Public sodium-ion datasets are improving quickly, but they remain sparse, uneven, and often chemistry-specific. A sodium-ion researcher must therefore be bilingual: fluent in large lithium-ion benchmark datasets for method validation, and careful with smaller sodium-ion datasets for chemistry-specific interpretation. When the data do not exist, you must be able to say exactly what was validated, what was adapted, and what remains an assumption.

By the end of this chapter, you will have a reusable Python module named `batterydata` with loaders for at least four dataset families: CALCE-style Excel/text files, NASA PCoE MATLAB files, Oxford MATLAB files, and Severson/MATR batch files. You will also add a generic CSV loader for newer Mendeley and Zenodo sodium-ion releases, because public sodium-ion datasets often arrive as ordinary spreadsheets rather than famous benchmark formats. The deliverable is a small, properly structured package that returns the same column names and units no matter where the raw data came from.

We will move in six stages. First, we map the public dataset landscape and install the tools needed for mixed file formats. Second, we define a tidy battery-data schema. Third, we write and test a generic loader on a tiny synthetic dataset so the software structure is clear before real files arrive. Fourth, we add dataset-specific parsers for CALCE, NASA, Oxford, and Severson/MATR. Fifth, we clean, cycle-detect, and summarize public time series in a uniform way. Sixth, we reproduce a simplified version of the key voltage-curve feature idea from Severson et al.'s fast-charge cycle-life paper, using the public MATR dataset when available and a small schema-compatible fixture when the full download is not present.

## Prerequisites Check

- Required software: Python `3.11`, `numpy==1.26.4`, `pandas==2.2.2`, `scipy==1.13.1`, `matplotlib==3.9.0`, `h5py==3.11.0`, `requests==2.32.3`, `openpyxl==3.1.5`, `tqdm==4.66.5`, and `pytest==8.3.2`
- Install command: `python -m pip install numpy==1.26.4 pandas==2.2.2 scipy==1.13.1 matplotlib==3.9.0 h5py==3.11.0 requests==2.32.3 openpyxl==3.1.5 tqdm==4.66.5 pytest==8.3.2`
- Required textbook chapters: Textbook Chapters 2, 7, 8, 10, and 13
- Required prior lab chapters: Lab Chapters 1 and 2 are essential; Lab Chapters 4, 6, 7, and 8 are strongly recommended
- Public sources used in this chapter: CALCE Battery Data Archive, NASA PCoE Li-ion Battery Aging Datasets, Oxford Battery Degradation Dataset 1, Severson/Attia/MIT-Stanford-Toyota MATR dataset, and selected Mendeley/Zenodo sodium-ion datasets
- Estimated time: 16 to 24 hours if you download and inspect the large datasets; 8 to 10 hours if you use only the small fixtures and read the large-download instructions

If pandas group-by operations feel shaky, revisit Lab Chapter 2 before starting Walkthrough 3. If capacity, Coulomb counting, or current sign conventions feel shaky, revisit Lab Chapter 6. If SOH versus cycle number feels fuzzy, revisit Lab Chapter 8. Dataset work rewards patience more than cleverness. A slow, explicit parser with checks is better than a clever one-liner that silently flips charge and discharge.

## Environment Setup

We will create a dedicated environment because dataset chapters tend to accumulate file-format dependencies. You do not need PyBaMM in this chapter. We are building the data foundation that PyBaMM, MATLAB, and your own estimation scripts will consume later.

### Step 1: Create the Python environment

From the repository root, run:

```bash
cd /home/avirup/SodiumIonBatteryResearch
python3.11 -m venv .venv-chapter11
source .venv-chapter11/bin/activate
python -m pip install --upgrade pip
python -m pip install numpy==1.26.4 pandas==2.2.2 scipy==1.13.1 matplotlib==3.9.0 h5py==3.11.0 requests==2.32.3 openpyxl==3.1.5 tqdm==4.66.5 pytest==8.3.2
```

On Windows PowerShell, use:

```powershell
cd C:\path\to\SodiumIonBatteryResearch
py -3.11 -m venv .venv-chapter11
.\.venv-chapter11\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install numpy==1.26.4 pandas==2.2.2 scipy==1.13.1 matplotlib==3.9.0 h5py==3.11.0 requests==2.32.3 openpyxl==3.1.5 tqdm==4.66.5 pytest==8.3.2
```

If `python3.11` is not found, run `python --version`. Any Python `3.10` or newer should work for this chapter, but record the exact version in your research log. Public dataset code often becomes part of a supplementary repository, and future readers need to know what you used.

### Step 2: Create the chapter workspace

Run:

```bash
mkdir -p SimulationCompanion/chapter11_dataset_workspace
cd SimulationCompanion/chapter11_dataset_workspace
mkdir -p batterydata data/raw data/processed figures notebooks tests
touch batterydata/__init__.py
```

The chapter workspace has three jobs. `data/raw` stores files exactly as downloaded. `data/processed` stores normalized CSV or Parquet outputs produced by your loaders. `batterydata` stores the reusable package. Resist the temptation to edit raw files by hand. If you fix a column name, skip a header row, or change a sign convention, do it in code so the decision is inspectable.

### Step 3: Verify the install

Paste this into a fresh notebook or run it as `python verify_chapter11.py`:

```python
import h5py
import matplotlib
import numpy as np
import openpyxl
import pandas as pd
import scipy

print("NumPy:", np.__version__)
print("pandas:", pd.__version__)
print("SciPy:", scipy.__version__)
print("Matplotlib:", matplotlib.__version__)
print("h5py:", h5py.__version__)
print("openpyxl:", openpyxl.__version__)

demo = pd.DataFrame(
    {
        "time_s": [0.0, 1.0, 2.0],
        "current_a": [0.0, -1.0, -1.0],
        "voltage_v": [3.20, 3.25, 3.30],
    }
)
print(demo)
```

Expected output:

```text
NumPy: 1.26.4
pandas: 2.2.2
SciPy: 1.13.1
Matplotlib: 3.9.0
h5py: 3.11.0
openpyxl: 3.1.5
   time_s  current_a  voltage_v
0     0.0        0.0       3.20
1     1.0       -1.0       3.25
2     2.0       -1.0       3.30
```

The current is negative during charge in this chapter's canonical schema. That is a deliberate choice, not a universal truth. Many cyclers and datasets use positive current for charge. We will normalize to the BMS convention used in earlier lab chapters: positive current means discharge from the cell into the load; negative current means charge into the cell.

### Common setup failures and fixes

`ImportError: Missing optional dependency 'openpyxl'` means pandas is trying to read Excel files without the Excel engine installed. Rerun the install command and restart the notebook kernel.

`OSError: Unable to open file` from `h5py` usually means one of two things: the file path is wrong, or the `.mat` file is not MATLAB v7.3/HDF5. We will provide both `scipy.io.loadmat` and `h5py` patterns because public MATLAB files come in both styles.

`Permission denied` when writing under `data/raw` usually means your notebook is running from a different directory or the folder was created by another user. Print `Path.cwd()` inside Python and create folders from that working directory.

Large downloads may fail halfway. For this chapter, manual download is acceptable. Place downloaded files under `SimulationCompanion/chapter11_dataset_workspace/data/raw` and let the parser find them. Do not make the parser depend on a fragile one-time download URL unless the dataset provider publishes a stable API.

## Conceptual Bridge: From Electrochemical Observables to Dataset Objects

In the theory textbook, a cell experiment is cleanly described by functions of time: current $I(t)$, terminal voltage $V(t)$, temperature $T(t)$, capacity $Q(t)$, and perhaps impedance $Z(\omega, t)$. In real public data, those functions are chopped into files, cycles, steps, sheets, MATLAB structs, HDF5 groups, and filenames. The first job of a dataset workflow is to rebuild the experimental trace without inventing information.

The minimum object we need is a tidy time-series table. In this chapter, every loader will return a `pandas.DataFrame` with a standard set of columns:

| Column | Unit | Required | Meaning |
| --- | --- | --- | --- |
| `dataset` | text | yes | Source family, such as `NASA` or `CALCE` |
| `cell_id` | text | yes | Cell identifier inside the source |
| `cycle_index` | integer | no | Cycle number if known or detected |
| `step_index` | integer | no | Step number within a cycle if known |
| `time_s` | s | yes | Elapsed time within the returned record |
| `current_a` | A | yes | Positive for discharge, negative for charge |
| `voltage_v` | V | yes | Terminal voltage |
| `temperature_c` | deg C | no | Cell, chamber, or surface temperature |
| `capacity_ah` | Ah | no | Reported or integrated capacity |
| `mode` | text | no | `charge`, `discharge`, `rest`, `impedance`, or `unknown` |
| `source_file` | text | yes | Raw file path or name |

This schema is intentionally modest. We are not trying to store every metadata field from every dataset. We are defining the small common denominator needed for modeling, estimation, and reproducibility. If a dataset has impedance spectra, electrode-specific metadata, chamber humidity, diagnostic-cycle labels, or protocol IDs, keep those in separate tables. Do not force all public data into one bloated master table. A stable narrow table plus source-specific metadata is easier to audit.

The most important convention is current sign. In electrochemistry papers, the sign convention often follows the instrument or the author. In BMS and power electronics, positive current is often discharge. Some Arbin exports mark charge current as positive, some public processing scripts flip it, and some datasets provide both current and capacity columns whose signs do not agree. This is the data version of the sign convention problem you met in Textbook Chapter 2. We will normalize to positive discharge and negative charge, then write that convention into the package docstring.

Capacity is the second trap. A cycler may report charge capacity and discharge capacity as positive increasing quantities inside each step. A modeling workflow may want signed Coulomb count:

$$
q(t) = \frac{1}{3600}\int_0^t I(\tau)\,d\tau.
\tag{1}
$$

Under our convention, Equation (1) increases during discharge and decreases during charge. That is useful for physics and BMS work, but it is not the same as the reported discharge-capacity column in many datasets. A clean loader should preserve the source capacity if present and, when needed, compute a clearly named derived column such as `throughput_ah` or `signed_capacity_ah`.

Cycle detection is the third trap. A "cycle" may mean one charge-discharge pair, one discharge-charge pair, one test record in a MATLAB struct, one diagnostic every hundred drive cycles, or one row in a capacity-summary table. Dataset loaders should prefer provider cycle labels when they exist. If they do not exist, your detection algorithm should be explicit and conservative. In this chapter, we will detect transitions between charge, discharge, and rest using current thresholds, then assign cycle numbers at discharge starts. This is standard practice for exploratory data cleaning, but it is not a substitute for reading the dataset documentation.

The final bridge is provenance. A model can tolerate small measurement noise; a paper cannot tolerate unclear provenance. Every processed table should remember where it came from, which loader version produced it, what sign convention was applied, and which rows were dropped. You do not need a heavyweight database. A `source_file` column, a `README.md`, and a few validation plots already put you ahead of many public notebooks.

## Guided Walkthrough 1: Build the Package Skeleton and Canonical Schema

**Learning objective:** Create a reusable `batterydata` package and implement schema validation before touching real public data.

We begin with structure because dataset code grows quickly. If you write one notebook cell per dataset, you will have four nearly identical parsers and no confidence that the outputs agree. Instead, we will write a tiny package with a schema module, utility functions, and tests. The first loader will use a synthetic CSV so that the schema is easy to see.

Create `batterydata/schema.py`:

```python
from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable

import numpy as np
import pandas as pd


CANONICAL_COLUMNS = [
    "dataset",
    "cell_id",
    "cycle_index",
    "step_index",
    "time_s",
    "current_a",
    "voltage_v",
    "temperature_c",
    "capacity_ah",
    "mode",
    "source_file",
]

REQUIRED_COLUMNS = [
    "dataset",
    "cell_id",
    "time_s",
    "current_a",
    "voltage_v",
    "source_file",
]


@dataclass(frozen=True)
class ValidationResult:
    """Container for schema validation messages."""

    is_valid: bool
    messages: tuple[str, ...]


def empty_canonical_frame() -> pd.DataFrame:
    """Return an empty DataFrame with the canonical battery-data columns."""
    return pd.DataFrame(columns=CANONICAL_COLUMNS)


def add_missing_optional_columns(frame: pd.DataFrame) -> pd.DataFrame:
    """Add missing canonical columns and return columns in canonical order."""
    normalized = frame.copy()
    for column in CANONICAL_COLUMNS:
        if column not in normalized.columns:
            normalized[column] = np.nan
    return normalized[CANONICAL_COLUMNS]


def validate_canonical_frame(frame: pd.DataFrame) -> ValidationResult:
    """Validate the columns, required values, and basic units of a frame."""
    messages: list[str] = []

    for column in REQUIRED_COLUMNS:
        if column not in frame.columns:
            messages.append(f"Missing required column: {column}")

    if messages:
        return ValidationResult(False, tuple(messages))

    for column in REQUIRED_COLUMNS:
        if frame[column].isna().any():
            messages.append(f"Required column contains null values: {column}")

    numeric_columns = ["time_s", "current_a", "voltage_v"]
    for column in numeric_columns:
        if not pd.api.types.is_numeric_dtype(frame[column]):
            messages.append(f"Column must be numeric: {column}")

    if pd.api.types.is_numeric_dtype(frame["time_s"]):
        time_values = frame["time_s"].to_numpy(dtype=float)
        if np.any(np.diff(time_values) < -1e-9):
            messages.append("time_s is not monotonically nondecreasing")

    if pd.api.types.is_numeric_dtype(frame["voltage_v"]):
        voltage_values = frame["voltage_v"].to_numpy(dtype=float)
        finite_voltage = voltage_values[np.isfinite(voltage_values)]
        if finite_voltage.size and (
            finite_voltage.min() < 0.0 or finite_voltage.max() > 6.0
        ):
            messages.append("voltage_v has values outside the expected 0-6 V range")

    return ValidationResult(len(messages) == 0, tuple(messages))


def require_columns(frame: pd.DataFrame, columns: Iterable[str]) -> None:
    """Raise a helpful error if a raw input frame is missing expected columns."""
    missing = [column for column in columns if column not in frame.columns]
    if missing:
        available = ", ".join(str(column) for column in frame.columns)
        missing_text = ", ".join(missing)
        raise ValueError(
            f"Missing required raw columns: {missing_text}. "
            f"Available columns are: {available}"
        )
```

Create `batterydata/generic.py`:

```python
from __future__ import annotations

from pathlib import Path

import pandas as pd

from .schema import add_missing_optional_columns, validate_canonical_frame


def load_generic_csv(
    path: str | Path,
    dataset: str,
    cell_id: str,
    column_map: dict[str, str],
    current_sign: str = "positive_discharge",
) -> pd.DataFrame:
    """Load a CSV file and map its columns into the canonical schema.

    Parameters
    ----------
    path:
        CSV file path.
    dataset:
        Short dataset label to store in the output.
    cell_id:
        Cell identifier to store in the output.
    column_map:
        Mapping from raw column names to canonical names.
    current_sign:
        Either ``positive_discharge`` or ``positive_charge``.
    """
    path = Path(path)
    raw = pd.read_csv(path)
    renamed = raw.rename(columns=column_map)

    output = pd.DataFrame()
    for canonical_name in column_map.values():
        output[canonical_name] = renamed[canonical_name]

    output["dataset"] = dataset
    output["cell_id"] = cell_id
    output["source_file"] = str(path)

    if current_sign == "positive_charge":
        output["current_a"] = -1.0 * output["current_a"].astype(float)
    elif current_sign != "positive_discharge":
        raise ValueError("current_sign must be positive_discharge or positive_charge")

    output = add_missing_optional_columns(output)
    result = validate_canonical_frame(output)
    if not result.is_valid:
        message = "\n".join(result.messages)
        raise ValueError(f"Canonical validation failed for {path}:\n{message}")

    return output
```

Update `batterydata/__init__.py`:

```python
from .generic import load_generic_csv
from .schema import CANONICAL_COLUMNS, validate_canonical_frame

__all__ = [
    "CANONICAL_COLUMNS",
    "load_generic_csv",
    "validate_canonical_frame",
]
```

Now create a tiny fixture file by running this in Python:

```python
from pathlib import Path

import pandas as pd

fixture_path = Path("data/raw/tiny_sodium_like_cycle.csv")
fixture_path.parent.mkdir(parents=True, exist_ok=True)

fixture = pd.DataFrame(
    {
        "Time_sec": [0, 10, 20, 30, 40, 50, 60],
        "Current_A": [0.0, 1.0, 1.0, 0.0, -0.8, -0.8, 0.0],
        "Voltage_V": [3.10, 3.03, 2.98, 3.05, 3.15, 3.22, 3.20],
        "Temp_C": [25.0, 25.1, 25.1, 25.1, 25.2, 25.2, 25.2],
    }
)
fixture.to_csv(fixture_path, index=False)
print(fixture_path.resolve())
```

Load it:

```python
from batterydata import load_generic_csv, validate_canonical_frame

frame = load_generic_csv(
    "data/raw/tiny_sodium_like_cycle.csv",
    dataset="teaching_fixture",
    cell_id="Na_fixture_001",
    column_map={
        "Time_sec": "time_s",
        "Current_A": "current_a",
        "Voltage_V": "voltage_v",
        "Temp_C": "temperature_c",
    },
    current_sign="positive_discharge",
)

print(frame)
print(validate_canonical_frame(frame))
```

Expected output is a seven-row table with the canonical columns in a consistent order. `current_a` should be positive during the early discharge-like segment and negative during the later charge-like segment. The validation result should report `is_valid=True` and an empty message tuple.

The key line in `load_generic_csv` is the `column_map`. We do not ask every raw dataset to use our names. We ask every loader to explain how raw names map into our names. The `current_sign` argument makes the sign convention explicit. If a source uses positive current for charge, the loader flips it once at the boundary.

### What Could Go Wrong

If Python cannot import `batterydata`, your notebook is probably not running from `SimulationCompanion/chapter11_dataset_workspace`. Print `Path.cwd()` and either change directories or install the package in editable mode later with `python -m pip install -e .`.

If validation complains that `time_s` is not monotonic, check whether the source file resets time at each step. This is common. You can either return one step at a time or reconstruct absolute time before validation.

If validation complains about voltage outside `0-6 V`, inspect units. Some files report millivolts. Divide by `1000` before returning `voltage_v`.

### Reflection

This exercise taught the core habit of the chapter: normalize at the boundary and validate immediately. The schema is small enough to remember but strict enough to catch the most expensive mistakes. We will now apply the same pattern to public datasets that are much less polite than our fixture.

## Guided Walkthrough 2: Parse CALCE Excel and Text Files

**Learning objective:** Load CALCE cycling files into the canonical schema while preserving source-specific quirks.

The CALCE Battery Data Archive is a practical starting point because it contains real cell cycling files from a battery research group, not a machine-learning benchmark preprocessed into convenient arrays. The archive includes LiCoO2 prismatic CS2 cells. The CALCE page states that CS2 cells have a nominal capacity around `1100 mAh` and that most were tested with Arbin equipment, while some files are text files from CADEX equipment. Publication use should cite the CALCE database and relevant CALCE/contributor papers.

Download location: `https://calce.umd.edu/battery-data` or the older archive page `https://web.calce.umd.edu/batteries/data/`. File sizes vary by cell and test. Expect Excel files or text files, often grouped by cell. The archive terms are not the same as a permissive software license; read the page and cite it properly.

Create `batterydata/calce.py`:

```python
from __future__ import annotations

from pathlib import Path

import numpy as np
import pandas as pd

from .schema import add_missing_optional_columns, validate_canonical_frame


CALCE_COLUMN_ALIASES = {
    "time_s": ["Test_Time(s)", "Test Time (s)", "Time(s)", "time_s", "Time"],
    "current_a": ["Current(A)", "Current (A)", "Current", "I(A)", "current_a"],
    "voltage_v": ["Voltage(V)", "Voltage (V)", "Voltage", "Ecell/V", "voltage_v"],
    "temperature_c": ["Temperature(C)", "Temperature (C)", "Temp(C)", "temperature_c"],
    "cycle_index": ["Cycle_Index", "Cycle Index", "Cycle", "cycle_index"],
    "step_index": ["Step_Index", "Step Index", "Step", "step_index"],
}


def _find_column(raw: pd.DataFrame, aliases: list[str]) -> str | None:
    normalized_lookup = {str(column).strip(): column for column in raw.columns}
    for alias in aliases:
        if alias in normalized_lookup:
            return normalized_lookup[alias]
    lower_lookup = {str(column).strip().lower(): column for column in raw.columns}
    for alias in aliases:
        key = alias.strip().lower()
        if key in lower_lookup:
            return lower_lookup[key]
    return None


def _read_calce_file(path: Path) -> pd.DataFrame:
    if path.suffix.lower() in {".xlsx", ".xls"}:
        return pd.read_excel(path, engine="openpyxl")
    if path.suffix.lower() in {".csv"}:
        return pd.read_csv(path)
    return pd.read_csv(path, sep=None, engine="python")


def load_calce_file(
    path: str | Path,
    cell_id: str,
    current_sign: str = "positive_charge",
) -> pd.DataFrame:
    """Load one CALCE-style file into the canonical schema.

    CALCE files are not perfectly uniform across cells and instruments.
    This loader searches for common column aliases and returns a validated
    canonical table.
    """
    path = Path(path)
    raw = _read_calce_file(path)
    raw = raw.dropna(axis=0, how="all").dropna(axis=1, how="all")

    mapped: dict[str, pd.Series] = {}
    for canonical_name, aliases in CALCE_COLUMN_ALIASES.items():
        raw_column = _find_column(raw, aliases)
        if raw_column is not None:
            mapped[canonical_name] = raw[raw_column]

    required = ["time_s", "current_a", "voltage_v"]
    missing = [column for column in required if column not in mapped]
    if missing:
        raise ValueError(f"{path} is missing required CALCE columns: {missing}")

    output = pd.DataFrame(mapped)
    output["dataset"] = "CALCE"
    output["cell_id"] = cell_id
    output["source_file"] = str(path)

    output["time_s"] = pd.to_numeric(output["time_s"], errors="coerce")
    output["current_a"] = pd.to_numeric(output["current_a"], errors="coerce")
    output["voltage_v"] = pd.to_numeric(output["voltage_v"], errors="coerce")

    if "temperature_c" in output.columns:
        output["temperature_c"] = pd.to_numeric(output["temperature_c"], errors="coerce")

    if current_sign == "positive_charge":
        output["current_a"] = -output["current_a"]
    elif current_sign != "positive_discharge":
        raise ValueError("current_sign must be positive_charge or positive_discharge")

    output = output.dropna(subset=["time_s", "current_a", "voltage_v"])
    output = output.sort_values("time_s").reset_index(drop=True)
    output = add_missing_optional_columns(output)

    result = validate_canonical_frame(output)
    if not result.is_valid:
        raise ValueError("\n".join(result.messages))

    return output
```

Add it to `batterydata/__init__.py`:

```python
from .calce import load_calce_file
from .generic import load_generic_csv
from .schema import CANONICAL_COLUMNS, validate_canonical_frame

__all__ = [
    "CANONICAL_COLUMNS",
    "load_calce_file",
    "load_generic_csv",
    "validate_canonical_frame",
]
```

Try the loader on a CALCE file you downloaded:

```python
from pathlib import Path

from batterydata import load_calce_file

calce_path = Path("data/raw/CALCE/CS2_35_example.xlsx")

if calce_path.exists():
    calce = load_calce_file(calce_path, cell_id="CS2_35")
    print(calce.head())
    print(calce[["time_s", "current_a", "voltage_v", "temperature_c"]].describe())
else:
    print("Place a CALCE Excel or text file at:", calce_path)
```

Now plot a quick sanity check:

```python
import matplotlib.pyplot as plt

if calce_path.exists():
    fig, axes = plt.subplots(2, 1, figsize=(9, 6), sharex=True)
    axes[0].plot(calce["time_s"] / 3600, calce["voltage_v"], linewidth=1.0)
    axes[0].set_ylabel("Voltage (V)")
    axes[0].grid(True)

    axes[1].plot(calce["time_s"] / 3600, calce["current_a"], linewidth=1.0)
    axes[1].axhline(0.0, color="black", linewidth=0.8)
    axes[1].set_xlabel("Time (h)")
    axes[1].set_ylabel("Current (A)")
    axes[1].grid(True)

    fig.suptitle("CALCE canonical loader sanity check")
    fig.tight_layout()
    plt.show()
```

A correct plot should show voltage rising during charge segments and falling during discharge segments. Because we normalized to positive-discharge current, the voltage should generally fall when `current_a` is positive and rise when `current_a` is negative. If those relationships are reversed, your `current_sign` argument is wrong for that file.

### What Could Go Wrong

If Excel reading fails, the file may be an old `.xls` file that needs a different engine. Install `xlrd` with `python -m pip install xlrd==2.0.1`, or open the file once in LibreOffice and export to `.xlsx` while preserving the raw copy.

If the parser cannot find `Current(A)` or `Voltage(V)`, inspect `raw.columns`. CALCE files have changed over time and mirrored copies sometimes rename headers. Add the observed header to `CALCE_COLUMN_ALIASES` rather than renaming the raw file.

If current looks like milliamps, check magnitudes. A CS2 `1C` current should be around `1.1 A`, not `1100 A`. Divide by `1000` in a source-specific branch and document it.

### Reflection

CALCE teaches the first public-data lesson: even a respected archive is not a single format. A good loader searches for known aliases, validates units, and keeps the raw source visible. We did not hide the mess; we contained it.

## Guided Walkthrough 3: Parse NASA PCoE MATLAB Battery Files

**Learning objective:** Extract charge, discharge, and impedance records from NASA-style MATLAB structs.

The NASA PCoE Li-ion Battery Aging Datasets are among the most-used battery-health public datasets. NASA's Open Data page describes Li-ion cells run through charge, discharge, and EIS operations at different temperatures, with repeated cycling causing accelerated aging. The page also notes that some discharge thresholds were below the OEM-recommended `2.7 V`, which matters when you interpret capacity fade. The Open Data portal lists the license as not specified, so treat NASA attribution and dataset citation as mandatory.

Download location: `https://data.nasa.gov/dataset/li-ion-battery-aging-datasets` and the NASA PCoE repository pages linked from it. The common archive contains MATLAB `.mat` files named by battery, such as `B0005.mat`. File sizes are modest compared with Oxford and MATR.

Create `batterydata/nasa.py`:

```python
from __future__ import annotations

from pathlib import Path
from typing import Any

import numpy as np
import pandas as pd
from scipy.io import loadmat

from .schema import add_missing_optional_columns, validate_canonical_frame


def _mat_struct_to_dict(obj: Any) -> Any:
    if hasattr(obj, "_fieldnames"):
        return {field: _mat_struct_to_dict(getattr(obj, field)) for field in obj._fieldnames}
    if isinstance(obj, np.ndarray) and obj.dtype == object:
        if obj.size == 1:
            return _mat_struct_to_dict(obj.item())
        return [_mat_struct_to_dict(item) for item in obj.ravel()]
    return obj


def _as_1d_float_array(value: Any) -> np.ndarray:
    array = np.asarray(value, dtype=float).squeeze()
    if array.ndim == 0:
        return array.reshape(1)
    return array


def load_nasa_mat(path: str | Path, cell_id: str | None = None) -> pd.DataFrame:
    """Load a NASA PCoE battery .mat file into the canonical schema."""
    path = Path(path)
    cell_id = cell_id or path.stem
    mat = loadmat(path, squeeze_me=True, struct_as_record=False)

    if cell_id not in mat:
        candidate_keys = [key for key in mat if not key.startswith("__")]
        if len(candidate_keys) != 1:
            raise ValueError(f"Could not identify NASA cell key in {path}: {candidate_keys}")
        root_key = candidate_keys[0]
    else:
        root_key = cell_id

    root = _mat_struct_to_dict(mat[root_key])
    cycles = root["cycle"]
    if isinstance(cycles, dict):
        cycles = [cycles]

    frames: list[pd.DataFrame] = []
    for cycle_number, cycle in enumerate(cycles, start=1):
        operation_type = str(cycle.get("type", "unknown")).lower()
        if operation_type not in {"charge", "discharge"}:
            continue

        data = cycle["data"]
        time_s = _as_1d_float_array(data["Time"])
        voltage_v = _as_1d_float_array(data["Voltage_measured"])
        current_raw = _as_1d_float_array(data["Current_measured"])

        if "Temperature_measured" in data:
            temperature_c = _as_1d_float_array(data["Temperature_measured"])
        else:
            temperature_c = np.full_like(time_s, np.nan)

        length = min(len(time_s), len(voltage_v), len(current_raw), len(temperature_c))
        frame = pd.DataFrame(
            {
                "dataset": "NASA_PCoE",
                "cell_id": cell_id,
                "cycle_index": cycle_number,
                "step_index": 1,
                "time_s": time_s[:length],
                "current_a": current_raw[:length],
                "voltage_v": voltage_v[:length],
                "temperature_c": temperature_c[:length],
                "mode": operation_type,
                "source_file": str(path),
            }
        )

        if operation_type == "charge":
            frame["current_a"] = -frame["current_a"].abs()
        elif operation_type == "discharge":
            frame["current_a"] = frame["current_a"].abs()

        if "Capacity" in data and operation_type == "discharge":
            capacity_value = float(np.asarray(data["Capacity"]).squeeze())
            frame["capacity_ah"] = capacity_value

        frames.append(frame)

    if not frames:
        raise ValueError(f"No charge or discharge records found in {path}")

    output = pd.concat(frames, ignore_index=True)
    output = add_missing_optional_columns(output)
    result = validate_canonical_frame(
        output.sort_values(["cycle_index", "time_s"]).reset_index(drop=True)
    )
    if not result.is_valid:
        raise ValueError("\n".join(result.messages))

    return output
```

Update `batterydata/__init__.py`:

```python
from .calce import load_calce_file
from .generic import load_generic_csv
from .nasa import load_nasa_mat
from .schema import CANONICAL_COLUMNS, validate_canonical_frame

__all__ = [
    "CANONICAL_COLUMNS",
    "load_calce_file",
    "load_generic_csv",
    "load_nasa_mat",
    "validate_canonical_frame",
]
```

Run:

```python
from pathlib import Path

from batterydata import load_nasa_mat

nasa_path = Path("data/raw/NASA/B0005.mat")

if nasa_path.exists():
    nasa = load_nasa_mat(nasa_path)
    print(nasa.head())
    print(nasa.groupby("mode")["cycle_index"].nunique())
    capacities = (
        nasa.dropna(subset=["capacity_ah"])
        .groupby("cycle_index", as_index=False)["capacity_ah"]
        .first()
    )
    print(capacities.head())
else:
    print("Place B0005.mat at:", nasa_path)
```

Plot capacity fade:

```python
import matplotlib.pyplot as plt

if nasa_path.exists():
    capacities = (
        nasa.dropna(subset=["capacity_ah"])
        .groupby("cycle_index", as_index=False)["capacity_ah"]
        .first()
    )

    fig, ax = plt.subplots(figsize=(8, 4.5))
    ax.plot(capacities["cycle_index"], capacities["capacity_ah"], marker="o", markersize=3)
    ax.set_xlabel("NASA record index")
    ax.set_ylabel("Discharge capacity (Ah)")
    ax.set_title("NASA PCoE B0005 capacity fade")
    ax.grid(True)
    fig.tight_layout()
    plt.show()
```

The correct plot should show capacity declining from near `2 Ah` toward the end-of-life region. Do not expect a perfectly smooth curve. Real capacity estimates move with temperature, cutoff, rest, and measurement noise. The x-axis is record index, not necessarily a pure cycle count, because the NASA MATLAB struct includes different operation records. That distinction matters in a paper.

### What Could Go Wrong

If `loadmat` fails with "Unknown mat file type", the file may be MATLAB v7.3. Use `h5py.File(path)` to inspect its groups, then write a separate HDF5 reader. Do not force an HDF5 file through `scipy.io.loadmat`.

If capacity appears on charge records, inspect the NASA struct. The common PCoE files store `Capacity` mainly for discharge records. For SOH work, extract capacity from discharge records unless the documentation says otherwise.

If time resets every record, that is normal. Our validation checks monotonicity within the concatenated frame can become too strict for multi-cycle data. In production, validate per `(cell_id, cycle_index, mode)` group or reconstruct an absolute experiment clock.

### Reflection

NASA teaches the second public-data lesson: a MATLAB file can contain a hierarchy, not just a table. The parser's job is to flatten the hierarchy without losing the operation type and cycle context. The moment we extract capacity fade, we also learn to be honest about what the x-axis means.

## Guided Walkthrough 4: Build Cleaning and Cycle-Detection Utilities

**Learning objective:** Convert canonical time-series data into analysis-ready segments with mode labels, cycle indices, and integrated throughput.

Some datasets provide cycle labels. Others do not. Some labels exist but are inconvenient for the question you want to ask. This walkthrough builds reusable cleaning functions that operate after dataset-specific parsing. They do not know whether the source was CALCE, NASA, Oxford, Severson, or a Mendeley sodium-ion CSV. They only require the canonical schema.

Create `batterydata/cleaning.py`:

```python
from __future__ import annotations

import numpy as np
import pandas as pd


def infer_mode_from_current(
    frame: pd.DataFrame,
    current_threshold_a: float = 0.02,
) -> pd.DataFrame:
    """Infer charge, discharge, and rest labels from canonical current."""
    output = frame.copy()
    current = output["current_a"].astype(float)
    mode = np.full(len(output), "rest", dtype=object)
    mode[current > current_threshold_a] = "discharge"
    mode[current < -current_threshold_a] = "charge"
    output["mode"] = mode
    return output


def assign_cycles_from_discharge_starts(frame: pd.DataFrame) -> pd.DataFrame:
    """Assign cycle numbers whenever the mode enters discharge."""
    output = frame.copy().reset_index(drop=True)
    if "mode" not in output.columns or output["mode"].isna().all():
        output = infer_mode_from_current(output)

    mode = output["mode"].fillna("unknown").to_numpy()
    starts = np.zeros(len(output), dtype=bool)
    for index in range(len(output)):
        previous = mode[index - 1] if index > 0 else "rest"
        starts[index] = mode[index] == "discharge" and previous != "discharge"

    cycle_index = np.cumsum(starts)
    cycle_index[cycle_index == 0] = 1
    output["cycle_index"] = cycle_index.astype(int)
    return output


def add_integrated_columns(frame: pd.DataFrame) -> pd.DataFrame:
    """Add signed capacity and absolute throughput using trapezoidal integration."""
    output = frame.copy().reset_index(drop=True)
    time_s = output["time_s"].to_numpy(dtype=float)
    current_a = output["current_a"].to_numpy(dtype=float)

    delta_t_s = np.diff(time_s, prepend=time_s[0])
    delta_t_s = np.where(delta_t_s < 0.0, 0.0, delta_t_s)

    signed_delta_ah = current_a * delta_t_s / 3600.0
    output["signed_capacity_ah"] = np.cumsum(signed_delta_ah)
    output["throughput_ah"] = np.cumsum(np.abs(signed_delta_ah))
    return output


def summarize_cycles(frame: pd.DataFrame) -> pd.DataFrame:
    """Return one row per cycle with basic voltage, current, and capacity metrics."""
    working = frame.copy()
    if "cycle_index" not in working.columns or working["cycle_index"].isna().all():
        working = assign_cycles_from_discharge_starts(working)
    if "throughput_ah" not in working.columns:
        working = add_integrated_columns(working)

    rows = []
    for cycle_index, group in working.groupby("cycle_index", dropna=True):
        rows.append(
            {
                "dataset": group["dataset"].iloc[0],
                "cell_id": group["cell_id"].iloc[0],
                "cycle_index": int(cycle_index),
                "duration_s": float(group["time_s"].max() - group["time_s"].min()),
                "voltage_min_v": float(group["voltage_v"].min()),
                "voltage_max_v": float(group["voltage_v"].max()),
                "current_min_a": float(group["current_a"].min()),
                "current_max_a": float(group["current_a"].max()),
                "throughput_ah": float(
                    group["throughput_ah"].iloc[-1] - group["throughput_ah"].iloc[0]
                ),
            }
        )

    return pd.DataFrame(rows)
```

Update `batterydata/__init__.py`:

```python
from .calce import load_calce_file
from .cleaning import (
    add_integrated_columns,
    assign_cycles_from_discharge_starts,
    infer_mode_from_current,
    summarize_cycles,
)
from .generic import load_generic_csv
from .nasa import load_nasa_mat
from .schema import CANONICAL_COLUMNS, validate_canonical_frame

__all__ = [
    "CANONICAL_COLUMNS",
    "add_integrated_columns",
    "assign_cycles_from_discharge_starts",
    "infer_mode_from_current",
    "load_calce_file",
    "load_generic_csv",
    "load_nasa_mat",
    "summarize_cycles",
    "validate_canonical_frame",
]
```

Test it on the tiny fixture:

```python
from batterydata import (
    add_integrated_columns,
    assign_cycles_from_discharge_starts,
    infer_mode_from_current,
    load_generic_csv,
    summarize_cycles,
)

frame = load_generic_csv(
    "data/raw/tiny_sodium_like_cycle.csv",
    dataset="teaching_fixture",
    cell_id="Na_fixture_001",
    column_map={
        "Time_sec": "time_s",
        "Current_A": "current_a",
        "Voltage_V": "voltage_v",
        "Temp_C": "temperature_c",
    },
)

clean = infer_mode_from_current(frame, current_threshold_a=0.05)
clean = assign_cycles_from_discharge_starts(clean)
clean = add_integrated_columns(clean)
summary = summarize_cycles(clean)

print(clean[["time_s", "current_a", "mode", "cycle_index", "signed_capacity_ah", "throughput_ah"]])
print(summary)
```

Expected output: the rows with `1.0 A` should be labeled `discharge`, the rows with `-0.8 A` should be labeled `charge`, and rest rows should be labeled `rest`. The signed capacity increases during discharge and decreases during charge. Throughput only increases. The summary should contain one cycle with voltage range around `2.98-3.30 V`.

### What Could Go Wrong

If all rows become `rest`, your current threshold is too high or your current is in milliamps. Lower `current_threshold_a` or convert units.

If every pulse becomes a new cycle, the current profile has intermittent rests inside discharge. In that case, assign cycles from source labels or use a more careful state machine that tolerates short rests.

If integrated capacity is far too large, inspect `time_s`. Some files use minutes or hours while naming the column "time". Convert to seconds before canonical validation.

### Reflection

This exercise separates source parsing from analysis cleaning. That separation is worth protecting. A NASA parser should not contain the same cycle-detection code as a CALCE parser. Once everything is canonical, one cleaning function serves every dataset.

## Guided Walkthrough 5: Add Oxford and Severson/MATR Loaders

**Learning objective:** Handle large benchmark MATLAB datasets using defensive extraction functions.

Oxford Battery Degradation Dataset 1 contains long-term cycling of eight Kokam `740 mAh` Li-ion pouch cells. The ORA record lists DOI `10.5287/bodleian:KO2kdmYGg`, publication date 2017, and a main `.mat` file of about `253.8 MB`. The dataset is valuable because it includes long-term degradation with periodic characterization tests, but the structure is nested and large enough that you should inspect before loading everything repeatedly.

The Severson/Attia/MIT-Stanford-Toyota dataset accompanies the 2019 Nature Energy paper "Data-driven prediction of battery cycle life before capacity degradation." The paper states that the dataset contains `124` commercial LFP/graphite cells fast-charged under varied policies, with cycle lives from about `150` to `2300` cycles, and that data are available at `https://data.matr.io/1`. This dataset is important because it shifted the field toward early-cycle feature prediction.

Create `batterydata/mat_benchmarks.py`:

```python
from __future__ import annotations

from pathlib import Path
from typing import Any

import h5py
import numpy as np
import pandas as pd
from scipy.io import loadmat

from .schema import add_missing_optional_columns


def list_hdf5_tree(path: str | Path, max_items: int = 80) -> list[str]:
    """Return a short text listing of an HDF5 or MATLAB v7.3 file tree."""
    path = Path(path)
    lines: list[str] = []

    def visitor(name: str, obj: h5py.Dataset | h5py.Group) -> None:
        if len(lines) >= max_items:
            return
        if isinstance(obj, h5py.Dataset):
            lines.append(f"{name} dataset shape={obj.shape} dtype={obj.dtype}")
        else:
            lines.append(f"{name} group")

    with h5py.File(path, "r") as handle:
        handle.visititems(visitor)
    return lines


def _loadmat_dict(path: Path) -> dict[str, Any]:
    return loadmat(path, squeeze_me=True, struct_as_record=False)


def _get_field(obj: Any, field: str) -> Any:
    if isinstance(obj, dict):
        return obj[field]
    return getattr(obj, field)


def _as_array(value: Any) -> np.ndarray:
    return np.asarray(value).squeeze()


def load_oxford_example_cell(
    path: str | Path,
    cell_key: str = "Cell1",
    max_cycles: int | None = 5,
) -> pd.DataFrame:
    """Load a small subset of Oxford Dataset 1 into the canonical schema.

    The Oxford dataset has several nested versions in circulation. This
    function handles the common MATLAB struct pattern and is intentionally
    conservative: it loads a limited number of cycles for inspection.
    """
    path = Path(path)
    mat = _loadmat_dict(path)
    public_keys = [key for key in mat if not key.startswith("__")]
    root = mat[public_keys[0]]

    cell = _get_field(root, cell_key) if hasattr(root, cell_key) else _get_field(root, cell_key.lower())
    cycles = _get_field(cell, "cyc")
    cycles_array = np.atleast_1d(cycles)

    frames: list[pd.DataFrame] = []
    selected_cycles = cycles_array[:max_cycles] if max_cycles is not None else cycles_array

    for cycle_number, cycle in enumerate(selected_cycles, start=1):
        try:
            time_s = _as_array(_get_field(cycle, "t"))
            voltage_v = _as_array(_get_field(cycle, "v"))
            current_a = _as_array(_get_field(cycle, "q"))
        except (AttributeError, KeyError):
            continue

        length = min(len(time_s), len(voltage_v), len(current_a))
        frame = pd.DataFrame(
            {
                "dataset": "Oxford",
                "cell_id": cell_key,
                "cycle_index": cycle_number,
                "time_s": time_s[:length].astype(float),
                "current_a": current_a[:length].astype(float),
                "voltage_v": voltage_v[:length].astype(float),
                "source_file": str(path),
            }
        )
        frames.append(frame)

    if not frames:
        raise ValueError(
            "No Oxford cycles were extracted. Inspect the MATLAB keys and adapt "
            "field names t/v/q to the version you downloaded."
        )

    return add_missing_optional_columns(pd.concat(frames, ignore_index=True))


def load_severson_batch_summary(path: str | Path) -> pd.DataFrame:
    """Load cycle-life summary fields from a Severson/MATR batch .mat file."""
    path = Path(path)
    mat = _loadmat_dict(path)
    public_keys = [key for key in mat if not key.startswith("__")]
    batch = mat[public_keys[0]]
    cells = np.atleast_1d(batch)

    rows = []
    for index, cell in enumerate(cells):
        policy = getattr(cell, "policy_readable", f"cell_{index}")
        cycle_life = float(np.asarray(getattr(cell, "cycle_life")).squeeze())
        rows.append(
            {
                "dataset": "Severson_MATR",
                "cell_id": f"cell_{index:03d}",
                "policy": str(policy),
                "cycle_life": cycle_life,
                "source_file": str(path),
            }
        )
    return pd.DataFrame(rows)
```

The Oxford loader above is intentionally not magical. Public copies of the Oxford `.mat` file may expose different struct names depending on how they were saved or mirrored. The `list_hdf5_tree` helper is there for v7.3-style files; `_loadmat_dict` is there for traditional MATLAB files. If the fields are not `t`, `v`, and `q` in your copy, inspect the keys and adapt the three field names in one place.

Try the inspection workflow:

```python
from pathlib import Path

from batterydata.mat_benchmarks import (
    list_hdf5_tree,
    load_oxford_example_cell,
    load_severson_batch_summary,
)

oxford_path = Path("data/raw/Oxford/Oxford_Battery_Degradation_Dataset_1.mat")
severson_path = Path("data/raw/Severson/2017-05-12_batchdata_updated_struct_errorcorrect.mat")

if oxford_path.exists():
    try:
        oxford = load_oxford_example_cell(oxford_path, cell_key="Cell1", max_cycles=3)
        print(oxford.head())
    except NotImplementedError:
        print("\n".join(list_hdf5_tree(oxford_path)))
    except Exception as exc:
        print("Oxford structure needs inspection:", exc)

if severson_path.exists():
    summary = load_severson_batch_summary(severson_path)
    print(summary.head())
    print(summary["cycle_life"].describe())
else:
    print("Download Severson/MATR batch data from https://data.matr.io/1")
```

### What Could Go Wrong

If the Oxford loader raises the custom "No Oxford cycles were extracted" error, do not panic. Run `loadmat(path).keys()` and inspect the first public object with `dir(obj)`. The dataset is stable, but MATLAB structs are not pleasant to generalize blindly.

If the Severson loader cannot find `cycle_life`, check whether you downloaded processed batch files from the Braatz GitHub repository or raw files from MATR. The public ecosystem includes both. Adapt the summary loader to the file you actually cite.

If the full `.mat` file consumes too much memory, load summaries first. Do not repeatedly load a 250 MB or multi-GB file inside plotting cells. Convert the fields you need to a processed Parquet or CSV file once and record the loader version.

### Reflection

This exercise taught the third public-data lesson: large benchmark datasets are not just larger CSV files. They are research artifacts with internal structure. The right workflow is inspect, extract the minimum needed, cache the normalized result, and keep enough provenance to make the extraction reproducible.

## Guided Walkthrough 6: Reproduce a Severson-Style Early-Cycle Voltage Feature

**Learning objective:** Reproduce the central idea behind Severson et al.'s voltage-curve feature: early-cycle voltage differences can predict cycle life better than early capacity alone.

Severson et al. reported that features based on discharge voltage curves from early cycles predicted cycle life surprisingly well, even before obvious capacity degradation appeared. We will reproduce a simplified version of that idea. The full paper uses carefully processed voltage-capacity curves and machine-learning models. Our reproduction target is narrower: compute the variance of the difference between two early-cycle discharge voltage curves and plot it against cycle life.

This is a reproduction exercise, not a claim that our few lines duplicate every preprocessing choice in the paper. The paper and associated code should be your authority. Our goal is to learn how a public dataset becomes a figure-like research object, and where ambiguity enters.

Create `batterydata/severson_features.py`:

```python
from __future__ import annotations

import numpy as np
import pandas as pd


def voltage_difference_variance(
    capacity_ah: np.ndarray,
    voltage_cycle_a: np.ndarray,
    voltage_cycle_b: np.ndarray,
) -> float:
    """Return log10 variance of voltage difference between two cycles."""
    capacity_ah = np.asarray(capacity_ah, dtype=float)
    voltage_cycle_a = np.asarray(voltage_cycle_a, dtype=float)
    voltage_cycle_b = np.asarray(voltage_cycle_b, dtype=float)

    valid = (
        np.isfinite(capacity_ah)
        & np.isfinite(voltage_cycle_a)
        & np.isfinite(voltage_cycle_b)
    )
    if valid.sum() < 10:
        raise ValueError("At least 10 valid points are required")

    difference = voltage_cycle_b[valid] - voltage_cycle_a[valid]
    variance = float(np.var(difference))
    return float(np.log10(variance))


def make_teaching_severson_fixture() -> pd.DataFrame:
    """Create a small Severson-like table for code-path testing."""
    rng = np.random.default_rng(42)
    rows = []
    capacity_grid = np.linspace(0.0, 1.05, 120)
    synthetic_cells = [
        ("cell_A", 2100, 0.002),
        ("cell_B", 1400, 0.006),
        ("cell_C", 850, 0.014),
        ("cell_D", 420, 0.030),
    ]

    for cell_id, cycle_life, drift_scale in synthetic_cells:
        base_voltage = 3.35 - 0.45 * capacity_grid + 0.04 * np.tanh((0.55 - capacity_grid) / 0.08)
        cycle_10 = base_voltage + rng.normal(0.0, 0.0008, size=capacity_grid.size)
        cycle_100 = base_voltage - drift_scale * (capacity_grid - 0.5) ** 2
        cycle_100 += rng.normal(0.0, 0.0008, size=capacity_grid.size)

        feature = voltage_difference_variance(capacity_grid, cycle_10, cycle_100)
        rows.append(
            {
                "cell_id": cell_id,
                "cycle_life": cycle_life,
                "log10_variance_delta_v": feature,
            }
        )

    return pd.DataFrame(rows)
```

Run the fixture reproduction:

```python
import matplotlib.pyplot as plt

from batterydata.severson_features import make_teaching_severson_fixture

features = make_teaching_severson_fixture()
print(features)

fig, ax = plt.subplots(figsize=(7, 4.5))
ax.scatter(features["log10_variance_delta_v"], features["cycle_life"], s=70)
for _, row in features.iterrows():
    ax.annotate(row["cell_id"], (row["log10_variance_delta_v"], row["cycle_life"]))
ax.set_xlabel("log10 variance of Delta V between early cycles")
ax.set_ylabel("Cycle life")
ax.set_title("Severson-style teaching reproduction")
ax.grid(True)
fig.tight_layout()
plt.show()
```

A correct plot should show an inverse relationship: cells with more negative `log10_variance_delta_v`, meaning smaller early voltage-curve change, should have longer cycle life. Cells with larger variance should have shorter cycle life. The synthetic fixture is intentionally tiny, so do not report correlation statistics from it as a scientific result.

When using the full MATR dataset, replace `make_teaching_severson_fixture()` with extracted voltage-capacity arrays from the public batch files. The essential processing steps are:

1. Choose two early cycles, commonly cycle 10 and cycle 100 in the Severson paper's feature discussion.
2. Interpolate both discharge voltage curves onto a common discharge-capacity grid.
3. Compute the pointwise voltage difference.
4. Compute a scalar feature such as variance or minimum of the difference.
5. Compare that feature against measured cycle life.

Where the paper is ambiguous or your downloaded file version differs, document the choice. Did you use discharge capacity or normalized capacity? Did you exclude cells that failed before cycle 100? Did you interpolate in voltage-capacity space or time space? Did you use all batches or one batch? "Close enough" for this lab means reproducing the qualitative inverse relationship and obtaining a scatter plot with the same interpretation, not matching every number in the paper.

### What Could Go Wrong

If your full-data scatter plot has no trend, check that cycle numbers are aligned. Off-by-one cycle indexing is common when MATLAB arrays and Python arrays meet.

If the variance is exactly zero for many cells, you may be subtracting the same curve from itself or using a repeated reference due to a bad dictionary key.

If short-life cells lack cycle 100, do not silently drop them without reporting it. The act of excluding failed-before-100 cells changes the population.

### Reflection

This exercise is the heart of Part V. A published figure is not a picture; it is a chain of data access, parsing, cleaning, feature construction, and judgment calls. You now have the beginning of a reproducible chain.

## Dataset Integration: Public Sources and Practical Download Notes

Use this table as a starting map, not as a substitute for reading each dataset's documentation.

| Dataset | URL | Typical format | Approximate scale | License or terms note | Best use |
| --- | --- | --- | --- | --- | --- |
| CALCE Battery Data Archive | `https://calce.umd.edu/battery-data` | Excel, text | Cell-specific files | Cite CALCE database and contributor papers | Cycling, capacity fade, ECM practice |
| NASA PCoE Li-ion Battery Aging | `https://data.nasa.gov/dataset/li-ion-battery-aging-datasets` | MATLAB `.mat` | Moderate | NASA Open Data page lists license not specified | SOH, aging, temperature traces |
| Oxford Battery Degradation Dataset 1 | `https://ora.ox.ac.uk/objects/uuid:03ba4b01-cfed-46d3-9b1a-7d4a7bdf6fac` | MATLAB `.mat` | About 254 MB main file | ORA terms of use, DOI `10.5287/bodleian:KO2kdmYGg` | Long-term degradation and diagnostic cycles |
| Severson/MATR fast-charge dataset | `https://data.matr.io/1` | MATLAB `.mat`, processed structs | Large, 124 cells | Check MATR and paper terms | Early prediction of cycle life |
| Sandia battery datasets | Sandia data portals and GitHub mirrors vary by project | CSV, HDF5, reports | Varies | Check each project page | Abuse, aging, grid-storage conditions |
| Commercial Na-ion Ragone dataset | `https://data.mendeley.com/datasets/j44rvwcpff` | Dataset files from Mendeley | Moderate | CC BY 4.0 | Sodium-ion power/energy characterization |
| NFM sodium-ion degradation dataset | `https://data.mendeley.com/datasets/4mztcdc4gt` | Dataset files from Mendeley | Published 2026 | CC BY 4.0 | Sodium-ion SOH and degradation |
| Sodium-ion SOC dataset | `https://zenodo.org/records/13836819` | Zenodo files | Moderate | Zenodo record terms | Sodium-ion pulse and drive-cycle SOC |
| High-throughput Na-ion formation/cycling | `https://zenodo.org/records/7981011` | Zenodo files | Large | Zenodo record terms | Chemistry screening and formation data |

For Mendeley and Zenodo datasets, the generic CSV loader is often the right first tool. Download the archive manually, inspect the column names, and write a short `column_map`. Because these datasets are newer and less standardized, do not assume that every file has time, current, voltage, and temperature. Some provide only cycle summaries or figure-support spreadsheets.

The sparse sodium-ion situation is changing quickly. As of this chapter's writing, examples include commercial sodium-ion Ragone characterization, NFM sodium-ion degradation data, sodium-ion SOC pulse/drive-cycle data, and high-throughput sodium-ion formation/cycling records. That is good news, but it does not remove the need for caution. A sodium-ion dataset may represent one commercial cell, one cathode family, one temperature, or one test protocol. Generalizing from it requires much more care than validating a data-cleaning workflow on it.

## Open-Ended Exercises

### Exercise 1: Add a Sandia-Style CSV Loader

Find one Sandia battery dataset or another national-lab battery CSV dataset with time, current, and voltage columns. Write a `load_sandia_csv` function that wraps `load_generic_csv` but fixes the dataset label and any sign convention. Save one processed file to `data/processed`.

Hints: start with a single file, not the whole archive. Print `raw.columns`. Plot current and voltage before trusting the sign convention.

### Exercise 2: Add a Sodium-Ion Mendeley or Zenodo Loader

Choose either the commercial sodium-ion Ragone characterization dataset on Mendeley or the Zenodo sodium-ion SOC dataset. Download one file, inspect the columns, and load it into the canonical schema. Write a short note explaining which metadata are missing compared with the Li-ion benchmark datasets.

Hints: if the dataset is an Excel workbook, use `pd.read_excel(sheet_name=None)` to list sheets. If the file contains cycle summaries rather than raw time series, create a separate summary table rather than forcing it into the time-series schema.

### Exercise 3: Stress-Test Cycle Detection

Construct a synthetic current profile with two discharge pulses separated by a short rest, then a long rest, then charge. Test `assign_cycles_from_discharge_starts`. Decide whether the short rest should split the cycle. Modify the function or write a new one that tolerates rests shorter than `60 s`.

Hints: a robust state machine should use both mode and rest duration. Do not solve this with a fragile row-count threshold unless the sampling period is fixed.

### Exercise 4: Extend the Severson Reproduction

Using the full MATR data if available, compute two features for each cell: variance of `Delta V` between cycles 10 and 100, and minimum of `Delta V` between cycles 10 and 100. Plot each feature against cycle life. Which feature looks more monotonic?

Hints: interpolate onto a shared capacity grid. Exclude or separately mark cells that do not have cycle 100. Compare your choices to the public Braatz processing code.

## Worked Solutions to Open-Ended Exercises

A compact Sandia-style wrapper looks like this:

```python
from pathlib import Path

from batterydata import load_generic_csv


def load_sandia_csv(path: str | Path, cell_id: str):
    return load_generic_csv(
        path=path,
        dataset="Sandia_or_national_lab",
        cell_id=cell_id,
        column_map={
            "TestTime_s": "time_s",
            "Current_A": "current_a",
            "Voltage_V": "voltage_v",
            "Temperature_C": "temperature_c",
        },
        current_sign="positive_discharge",
    )
```

The exact raw names will differ. The important pattern is that the wrapper records the source label and hides repetitive column-map code.

A sodium-ion Mendeley CSV loader should look similar, but the research note matters more than the code. For example, if a Ragone file contains discharge energy and power but no raw time axis, do not pretend it is a time series. Create a `ragone_summary.csv` with columns such as `cell_id`, `current_a`, `specific_energy_wh_kg`, and `specific_power_w_kg`, then cite it as a summary dataset.

A rest-tolerant cycle detector can be sketched as:

```python
import numpy as np
import pandas as pd


def assign_cycles_with_rest_tolerance(frame: pd.DataFrame, max_rest_s: float = 60.0) -> pd.DataFrame:
    output = frame.copy().reset_index(drop=True)
    mode = output["mode"].fillna("unknown").to_numpy()
    time_s = output["time_s"].to_numpy(dtype=float)

    cycle = 0
    in_discharge_episode = False
    rest_start_s = None
    cycle_indices = []

    for index, current_mode in enumerate(mode):
        if current_mode == "discharge":
            if not in_discharge_episode:
                cycle += 1
                in_discharge_episode = True
            rest_start_s = None
        elif current_mode == "rest" and in_discharge_episode:
            if rest_start_s is None:
                rest_start_s = time_s[index]
            elif time_s[index] - rest_start_s > max_rest_s:
                in_discharge_episode = False
        elif current_mode == "charge":
            in_discharge_episode = False
            rest_start_s = None

        cycle_indices.append(max(cycle, 1))

    output["cycle_index"] = np.asarray(cycle_indices, dtype=int)
    return output
```

For the Severson extension, a well-structured result table has one row per cell:

```python
severson_feature_table = pd.DataFrame(
    {
        "cell_id": ["example_cell"],
        "cycle_life": [1200],
        "log10_var_delta_v_10_100": [-4.8],
        "min_delta_v_10_100": [-0.014],
        "used_cycle_10": [True],
        "used_cycle_100": [True],
    }
)
print(severson_feature_table)
```

The two boolean columns are not decoration. They make exclusions visible when you move from a teaching fixture to a real benchmark.

## What Changes for Sodium-Ion?

The loader architecture barely changes for sodium-ion. Time is still time, current is still current, voltage is still voltage, and temperature is still temperature. The interpretation changes sharply.

First, voltage windows differ. A sodium-ion cell may operate over `2.0-4.0 V`, `1.5-4.2 V`, or another chemistry-specific range. Do not let the schema validator's generic `0-6 V` check become a chemistry claim. Add chemistry metadata when you know it.

Second, OCV shape and plateau behavior differ. A flat hard-carbon plateau can make SOC inference and voltage-curve features behave differently from graphite/LFP or graphite/NMC cells. A feature that predicts Li-ion cycle life may be numerically computable for sodium-ion but physically less meaningful without validation.

Third, public sodium-ion datasets are less standardized. Some are figure-support datasets, some are commercial-cell characterization files, and some are high-throughput materials-screening records. You may need separate loaders for time-series cycling, Ragone summaries, EIS spectra, and extracted figure curves.

Fourth, validation strategy changes. For a sodium-ion methods paper, it is acceptable to validate the parser and feature workflow on lithium-ion benchmarks, then apply it to sodium-ion data as a case study. It is not acceptable to imply that a Li-ion-trained lifetime model is validated for sodium-ion just because the code runs.

## Chapter Summary and Skill Checklist

- You built a reusable `batterydata` package.
- You defined a canonical battery time-series schema with consistent units.
- You normalized current to positive discharge and negative charge.
- You wrote a generic CSV loader for Mendeley, Zenodo, and lab-export files.
- You wrote CALCE and NASA parsers with source-specific handling.
- You inspected Oxford and Severson/MATR benchmark structures.
- You added cleaning utilities for mode inference, cycle assignment, and throughput integration.
- You reproduced a simplified Severson-style early-cycle voltage-feature figure.
- You identified why sodium-ion dataset interpretation is harder than sodium-ion file parsing.

Commands, functions, and patterns to keep in muscle memory:

- `pd.read_csv(...)`, `pd.read_excel(...)`, and `scipy.io.loadmat(...)`
- `h5py.File(path, "r")` for MATLAB v7.3/HDF5 inspection
- `load_generic_csv(..., column_map=..., current_sign=...)`
- `validate_canonical_frame(frame)`
- `infer_mode_from_current(frame, current_threshold_a=...)`
- `assign_cycles_from_discharge_starts(frame)`
- `add_integrated_columns(frame)`
- `groupby("cycle_index")` for cycle summaries
- Always preserve `source_file`

You should now be able to:

- Find public battery datasets and record their source, format, and license terms.
- Explain why current sign conventions must be normalized explicitly.
- Parse mixed CSV, Excel, text, and MATLAB battery files.
- Convert public data into consistent columns and units.
- Detect common dataset problems before fitting a model.
- Build a loader that later PyBaMM, MATLAB, ECM, and BMS workflows can reuse.
- State clearly what is and is not validated when adapting Li-ion workflows to sodium-ion data.

## Deliverable

Your deliverable is a Python package directory named `batterydata` inside `SimulationCompanion/chapter11_dataset_workspace`, plus a short report named `chapter11_dataset_loader_report.md`.

The package must provide a unified interface to at least four public dataset families. A strong submission includes:

```text
batterydata/
    __init__.py
    schema.py
    generic.py
    calce.py
    nasa.py
    cleaning.py
    mat_benchmarks.py
    severson_features.py
tests/
    test_schema.py
    test_cleaning.py
data/
    raw/
    processed/
figures/
```

Your report should answer:

1. Which four datasets did you support?
2. What raw formats did they use?
3. What sign convention did each source appear to use?
4. What rows, columns, or files did your loader drop?
5. Which sodium-ion dataset did you inspect, and what was missing relative to Li-ion benchmarks?
6. Which figure or feature did you reproduce, and how close was it?

A worked partial solution is already present in the guided walkthroughs. To make it research-grade, add two tests:

```python
import pandas as pd

from batterydata import validate_canonical_frame
from batterydata.cleaning import infer_mode_from_current


def test_canonical_validation_accepts_minimal_frame():
    frame = pd.DataFrame(
        {
            "dataset": ["demo"],
            "cell_id": ["cell"],
            "time_s": [0.0],
            "current_a": [1.0],
            "voltage_v": [3.2],
            "source_file": ["memory"],
        }
    )
    assert validate_canonical_frame(frame).is_valid


def test_mode_inference_uses_positive_discharge():
    frame = pd.DataFrame({"current_a": [1.0, -1.0, 0.0]})
    output = infer_mode_from_current(frame, current_threshold_a=0.05)
    assert output["mode"].tolist() == ["discharge", "charge", "rest"]
```

Run the tests with:

```bash
python -m pytest -q
```

Expected output:

```text
2 passed
```

## Further Practice and Reading

Key papers and datasets:

1. Severson, K. A., Attia, P. M., Jin, N., et al. "Data-driven prediction of battery cycle life before capacity degradation." *Nature Energy* 4, 383-391 (2019). Dataset: `https://data.matr.io/1`.
2. Birkl, C. R. and Howey, D. A. Oxford Battery Degradation Dataset 1. DOI `10.5287/bodleian:KO2kdmYGg`.
3. NASA PCoE Li-ion Battery Aging Datasets: `https://data.nasa.gov/dataset/li-ion-battery-aging-datasets`.
4. CALCE Battery Data Archive: `https://calce.umd.edu/battery-data`.
5. Commercial sodium-ion cell and sodium-ion degradation datasets on Mendeley and Zenodo, especially `https://data.mendeley.com/datasets/j44rvwcpff`, `https://data.mendeley.com/datasets/4mztcdc4gt`, and `https://zenodo.org/records/13836819`.

Official and community resources:

1. pandas documentation for IO tools: `https://pandas.pydata.org/docs/user_guide/io.html`.
2. SciPy `loadmat` documentation: `https://docs.scipy.org/doc/scipy/reference/generated/scipy.io.loadmat.html`.
3. h5py documentation: `https://docs.h5py.org/`.
4. Braatz group public code for the Severson cycle-life dataset: `https://github.com/rdbraatz/data-driven-prediction-of-battery-cycle-life-before-capacity-degradation`.
5. WebPlotDigitizer for extracting curves from papers when sodium-ion raw data are unavailable: `https://automeris.io/WebPlotDigitizer/`.

Chapter 12 is next: The Reproduction Project.

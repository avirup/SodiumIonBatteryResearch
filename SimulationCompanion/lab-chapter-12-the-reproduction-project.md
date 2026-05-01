# Lab Chapter 12: The Reproduction Project

## Chapter Opening

This chapter is the hinge between learning tools and becoming useful with them.

So far, you have built simulations, parameter estimators, equivalent-circuit models, Kalman filters, aging workflows, thermal models, cross-language pipelines, and public-dataset loaders. Each of those skills matters. None of them, by itself, proves that you can do research. Research competence appears when you can take an outside result, read it without mystifying it, rebuild the computational path, document every choice you had to make, and explain why your reproduction is close, different, or impossible.

That is the skill of this chapter. We will reproduce a published battery paper in the practical, non-romantic sense of the word. We will not pretend that every paper is fully reproducible. Many are not. We will not pretend that exact numerical equality is always possible. It usually is not, because software versions, hidden preprocessing choices, random seeds, proprietary instruments, and missing metadata all matter. Instead, we will practice the standard that a serious reviewer or future collaborator will respect: clear scope, clean environment, faithful implementation, documented deviations, quantitative comparison, and a write-up that separates what the paper says from what you inferred.

Keep Textbook Chapters 2, 7, 8, 10, 12, and 13 open. This chapter operationalizes the measurement discipline from Textbook Chapter 2, the degradation interpretation from Textbook Chapter 7, the model hierarchy from Textbook Chapter 8, the BMS workflow logic from Textbook Chapter 10, the thermal and safety caution from Textbook Chapter 12, and the sodium-ion constraints from Textbook Chapter 13. It also draws directly on Lab Chapters 1, 2, 8, 10, and 11. Lab Chapter 11 gave you dataset loaders; this chapter makes those loaders answer to an external paper.

For the fully guided reproduction path, we will use Severson et al., "Data-driven prediction of battery cycle life before capacity degradation," published in *Nature Energy* in 2019. The paper is valuable for this manual because it is influential, it has public data, it has public data-processing code, and it exposes exactly the kind of ambiguity that reproduction work teaches you to handle. The paper reports that voltage-curve features from early cycles can predict cycle life before obvious capacity fade appears. We will reproduce a Figure 2-style result: voltage-curve features from early cycles are much more predictive of cycle life than early discharge capacity alone. Where the full MATR dataset is not available on your laptop, the chapter provides a deterministic schema-compatible fixture so every script still runs end to end. That fixture is for learning the workflow, not for making scientific claims.

By the end of the chapter, you will have a `chapter12_reproduction_project` repository with a pinned environment, a paper-selection scorecard, a reproduction checklist, a research log, a runnable reproduction script, generated figures, numerical comparison metrics, and a short manuscript-style report. The deliverable is not a pretty notebook. It is a small, auditable reproduction package that another graduate student could clone, run, criticize, and extend.

## Prerequisites Check

- Required software: Python `3.11`, `numpy==1.26.4`, `pandas==2.2.2`, `scipy==1.13.1`, `matplotlib==3.9.0`, `h5py==3.11.0`, `pyyaml==6.0.2`, `requests==2.32.3`, and `pytest==8.3.2`
- Optional software: Git `2.40` or newer; JupyterLab `4.x`; MATLAB `R2024b` if you choose an ECM or BMS reproduction instead of the guided Python path
- Install command: `python -m pip install numpy==1.26.4 pandas==2.2.2 scipy==1.13.1 matplotlib==3.9.0 h5py==3.11.0 pyyaml==6.0.2 requests==2.32.3 pytest==8.3.2`
- Required textbook chapters: Textbook Chapters 2, 7, 8, 10, 12, and 13
- Required prior lab chapters: Lab Chapters 1, 2, and 11 are essential; Lab Chapters 6, 8, 9, and 10 are recommended depending on the paper you choose
- Public sources used in this chapter: Severson et al. (2019), the MATR data portal, the Braatz group public processing repository, PyBaMM documentation, and the Marquis et al. SPMe paper as an alternative physics-model reproduction target
- Estimated time: 12 to 16 hours with the built-in fixture; 24 to 40 hours if you download, inspect, and reproduce against the full MATR dataset

If Git still feels awkward, revisit Lab Chapter 1 before starting. If pandas grouping and plotting feel shaky, revisit Lab Chapter 2. If public battery data still feels like a pile of miscellaneous files, revisit Lab Chapter 11. Reproduction work is mostly not about brilliance. It is about not losing track of what you did.

## Environment Setup

We will create a fresh environment and a fresh project folder. This is not optional ceremony. Reproduction work is a test of whether your computation can be separated from your memory of how you ran it.

### Step 1: Create the environment

From the repository root, run:

```bash
cd /home/avirup/SodiumIonBatteryResearch
python3.11 -m venv .venv-chapter12
source .venv-chapter12/bin/activate
python -m pip install --upgrade pip
python -m pip install numpy==1.26.4 pandas==2.2.2 scipy==1.13.1 matplotlib==3.9.0 h5py==3.11.0 pyyaml==6.0.2 requests==2.32.3 pytest==8.3.2
```

On Windows PowerShell, use:

```powershell
cd C:\path\to\SodiumIonBatteryResearch
py -3.11 -m venv .venv-chapter12
.\.venv-chapter12\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install numpy==1.26.4 pandas==2.2.2 scipy==1.13.1 matplotlib==3.9.0 h5py==3.11.0 pyyaml==6.0.2 requests==2.32.3 pytest==8.3.2
```

The guided reproduction does not require PyBaMM, scikit-learn, or MATLAB. That is deliberate. We will implement the regression in transparent NumPy so that the reader can inspect every mathematical step. If you choose a PyBaMM reproduction target from the open-ended exercises, use the pinned PyBaMM environment from Lab Chapter 10.

### Step 2: Create the project workspace

Run:

```bash
mkdir -p SimulationCompanion/chapter12_reproduction_project
cd SimulationCompanion/chapter12_reproduction_project
mkdir -p data/raw data/processed figures reports src tests logs references
touch logs/research-log.md
touch references/source-notes.md
```

This folder is intentionally shaped like a miniature paper repository. `data/raw` is for files exactly as downloaded. `data/processed` is for generated tables. `src` is for reusable code. `figures` is for generated plots. `reports` is for the final write-up. `logs` is for dated decisions. `references` is for notes about the paper, dataset, and code sources.

Now create a `README.md`:

````markdown
# Chapter 12 Reproduction Project

This repository reproduces selected results from a published battery paper.

Target paper:

- Severson, K. A., Attia, P. M., Jin, N., et al. "Data-driven prediction of battery cycle life before capacity degradation." Nature Energy 4, 383-391 (2019). https://doi.org/10.1038/s41560-019-0356-8

Scope:

- Reproduce a Figure 2-style result showing that early-cycle voltage-curve features are more predictive of cycle life than early discharge capacity alone.
- Use the public MATR dataset when available.
- Use a deterministic fixture only for workflow verification when the full dataset is absent.

Run:

```bash
python src/reproduce_severson_voltage_feature.py
```
````

The README is part of the method. It tells a future reader what you are trying to reproduce before they read any code.

### Step 3: Verify the install

Create `src/verify_environment.py`:

```python
import h5py
import matplotlib
import numpy as np
import pandas as pd
import scipy
import yaml

print("NumPy:", np.__version__)
print("pandas:", pd.__version__)
print("SciPy:", scipy.__version__)
print("Matplotlib:", matplotlib.__version__)
print("h5py:", h5py.__version__)
print("PyYAML:", yaml.__version__)

times = np.array([0.0, 1.0, 2.0, 3.0])
voltage = np.array([3.55, 3.48, 3.42, 3.36])
capacity = np.trapz(np.ones_like(times), times) / 3600.0

print(f"Demo voltage drop: {voltage[0] - voltage[-1]:.3f} V")
print(f"Demo integrated capacity: {capacity:.6f} Ah")
```

Run:

```bash
python src/verify_environment.py
```

Expected output:

```text
NumPy: 1.26.4
pandas: 2.2.2
SciPy: 1.13.1
Matplotlib: 3.9.0
h5py: 3.11.0
PyYAML: 6.0.2
Demo voltage drop: 0.190 V
Demo integrated capacity: 0.000833 Ah
```

The exact package versions should match. If Matplotlib prints `3.9.1` or pandas prints `2.2.3`, the chapter code will probably still run, but record the difference in `logs/research-log.md`. Reproduction is not only about what breaks. It is also about what did not break under a slightly different environment.

### Common setup failures and fixes

`python3.11: command not found` means Python 3.11 is not installed or not on your shell path. Use `python --version` to see what you have. Python 3.10 or 3.12 should be acceptable for this chapter, but write the actual version in the research log.

`ModuleNotFoundError: No module named 'yaml'` means `pyyaml` did not install into the active environment. Confirm the prompt shows `.venv-chapter12`, then rerun the install command.

`Permission denied` while creating folders usually means you are not in a writable project directory. Print `pwd` or `Get-Location`, then return to the repository root.

`Matplotlib is currently using agg` is not an error. It means Matplotlib is writing images without opening an interactive window. That is normal in a reproducible script.

## Conceptual Bridge: From Reading a Paper to Rebuilding a Computational Claim

In the theory textbook, a claim was usually attached to a derivation. You could follow the equations from assumptions to consequences. In a computational battery paper, the claim is attached to a chain of choices. Some choices are visible: the dataset, the model class, the loss function, the solver, the plotted variables. Other choices are quiet: the version of a library, the exact train-test split, the interpolation grid, the row filters, the current sign convention, the point at which rest periods were removed, and the random seed.

Reproduction means turning that quiet chain into an explicit object.

The first mental shift is that a figure is not just a picture. A figure is the final artifact of a pipeline:

$$
\text{raw data} \rightarrow \text{cleaning} \rightarrow \text{features or model states} \rightarrow \text{estimation} \rightarrow \text{metrics} \rightarrow \text{plot}.
\tag{1}
$$

When you reproduce a figure, you are not tracing over it. You are rebuilding Equation (1). If your result differs, the difference may be in any arrow of that pipeline. A beginner often jumps straight to "my model is wrong." A reproducibility-minded researcher asks smaller questions. Did I load the same cells? Did I use the same cycle range? Did I interpolate voltage onto the same capacity axis? Did I split train and test the same way? Did I transform the target variable before regression? Did I plot on the same axis scale?

The second shift is that "close enough" is not a feeling. It is a predeclared tolerance. For a voltage trace simulated by the same deterministic code, close enough may mean sub-millivolt agreement. For a reproduction of a published scatter plot from a public dataset with incomplete code, close enough may mean the same qualitative ordering, similar coefficient signs, and an error metric within a documented range. For a model trained with a random split that the paper does not disclose, exact pointwise equality is not a fair target. Your job is to state the tolerance before you see whether you passed.

The third shift is that ambiguity is not failure. Ambiguity is data. When a paper does not specify a smoothing window, a solver tolerance, or a train-test split, you have learned something important about the reproducibility of the result. Standard practice is not to hide that gap. Standard practice is to write down the ambiguity, choose a defensible default, run a sensitivity check when feasible, and report whether the conclusion depends on the choice.

The fourth shift is especially important for sodium-ion research. Many sodium-ion papers have smaller datasets, less standardized parameter reporting, fewer public raw files, and chemistry-specific voltage curves that make lithium-ion workflows only partly transferable. A reproduction project in sodium-ion may therefore reproduce a method rather than a dataset. For example, you may validate a feature-extraction workflow on the public lithium-ion MATR dataset, then apply the same workflow to a smaller sodium-ion cycling dataset from Zenodo or Mendeley. That is valid if you say it plainly: "The computational method was reproduced on the public Li-ion benchmark; the sodium-ion application is an adaptation, not a direct reproduction."

The final shift is that a failed reproduction can still be successful research training. If you discover that a paper cannot be reproduced because the data are not public, the code depends on obsolete proprietary software, or a key preprocessing step is missing, that is not wasted effort. Your final product becomes a reproducibility audit. It can still teach you how to read methods sections, how to isolate missing information, and how to design your own future papers so someone else does not suffer the same fog.

## Guided Walkthrough 1: Choose a Reproduction Target with a Scorecard

**Learning objective:** Convert paper selection from a vague preference into a documented, defensible decision.

Before writing code, we choose a paper. This step is easy to underestimate. A beautiful paper with private data and no code may be excellent science but a poor first reproduction project. A modest paper with public data, clear figures, and runnable scripts may teach you much more. In this walkthrough, we will create a paper-selection scorecard and apply it to four candidate papers.

Create `src/paper_scorecard.py`:

```python
from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class CandidatePaper:
    short_name: str
    citation: str
    tool_family: str
    data_available: int
    code_available: int
    environment_clarity: int
    figure_specificity: int
    sodium_transfer: int
    difficulty: int
    notes: str

    def score(self) -> int:
        positive = (
            self.data_available
            + self.code_available
            + self.environment_clarity
            + self.figure_specificity
            + self.sodium_transfer
        )
        return positive - self.difficulty


def main() -> None:
    candidates = [
        CandidatePaper(
            short_name="Severson2019",
            citation=(
                "Severson et al., Data-driven prediction of battery cycle life "
                "before capacity degradation, Nature Energy, 2019"
            ),
            tool_family="Python/MATLAB data workflow",
            data_available=5,
            code_available=4,
            environment_clarity=3,
            figure_specificity=5,
            sodium_transfer=4,
            difficulty=3,
            notes=(
                "Public MATR data and public processing code; modeling code is not "
                "fully open, so reproduce a feature/result rather than every model."
            ),
        ),
        CandidatePaper(
            short_name="Marquis2019",
            citation=(
                "Marquis et al., An asymptotic derivation of a single particle "
                "model with electrolyte, Journal of The Electrochemical Society, 2019"
            ),
            tool_family="PyBaMM physics-based simulation",
            data_available=3,
            code_available=5,
            environment_clarity=4,
            figure_specificity=4,
            sodium_transfer=3,
            difficulty=4,
            notes=(
                "Strong PyBaMM fit; best if you want reduced-order electrochemical "
                "model reproduction rather than public-data handling."
            ),
        ),
        CandidatePaper(
            short_name="PlettECM",
            citation=(
                "Plett, Battery Management Systems, Volume II, equivalent-circuit "
                "model identification examples"
            ),
            tool_family="MATLAB ECM and BMS algorithms",
            data_available=3,
            code_available=3,
            environment_clarity=4,
            figure_specificity=3,
            sodium_transfer=4,
            difficulty=3,
            notes=(
                "Excellent for BMS method reproduction; less direct as a published "
                "paper figure unless paired with a public HPPC dataset."
            ),
        ),
        CandidatePaper(
            short_name="PyBaMM2021",
            citation=(
                "Sulzer et al., Python Battery Mathematical Modelling (PyBaMM), "
                "Journal of Open Research Software, 2021"
            ),
            tool_family="PyBaMM software paper",
            data_available=4,
            code_available=5,
            environment_clarity=5,
            figure_specificity=3,
            sodium_transfer=3,
            difficulty=2,
            notes=(
                "Very reproducible software context; better for validating a tool "
                "workflow than for reproducing a battery-science claim."
            ),
        ),
    ]

    ranked = sorted(candidates, key=lambda paper: paper.score(), reverse=True)

    print("Reproduction target scorecard")
    print("=" * 34)
    for paper in ranked:
        print(f"{paper.short_name}: {paper.score():2d} points")
        print(f"  Tool family: {paper.tool_family}")
        print(f"  Citation: {paper.citation}")
        print(f"  Notes: {paper.notes}")
        print()


if __name__ == "__main__":
    main()
```

Run:

```bash
python src/paper_scorecard.py
```

Expected output:

```text
Reproduction target scorecard
==================================
Severson2019: 18 points
  Tool family: Python/MATLAB data workflow
  Citation: Severson et al., Data-driven prediction of battery cycle life before capacity degradation, Nature Energy, 2019
  Notes: Public MATR data and public processing code; modeling code is not fully open, so reproduce a feature/result rather than every model.

PyBaMM2021: 18 points
  Tool family: PyBaMM software paper
  Citation: Sulzer et al., Python Battery Mathematical Modelling (PyBaMM), Journal of Open Research Software, 2021
  Notes: Very reproducible software context; better for validating a tool workflow than for reproducing a battery-science claim.

Marquis2019: 15 points
  Tool family: PyBaMM physics-based simulation
  Citation: Marquis et al., An asymptotic derivation of a single particle model with electrolyte, Journal of The Electrochemical Society, 2019
  Notes: Strong PyBaMM fit; best if you want reduced-order electrochemical model reproduction rather than public-data handling.

PlettECM: 14 points
  Tool family: MATLAB ECM and BMS algorithms
  Citation: Plett, Battery Management Systems, Volume II, equivalent-circuit model identification examples
  Notes: Excellent for BMS method reproduction; less direct as a published paper figure unless paired with a public HPPC dataset.
```

The scoring is intentionally simple. Each positive dimension is scored from `0` to `5`, and difficulty is subtracted. The `CandidatePaper` dataclass stores each paper as a structured object so the criteria can be audited. `score()` adds the reproducibility strengths and subtracts difficulty. This is not a universal metric. It is a thinking tool.

Severson2019 and PyBaMM2021 tie in this example. We choose Severson2019 because it asks more of the skills built in this companion: public data handling, feature extraction, regression, figure comparison, and degradation interpretation. PyBaMM2021 is easier to run, but it is more of a software demonstration than a battery-research reproduction.

### What could go wrong

If your output order differs for tied scores, nothing is wrong. Python sorting is stable, but if you edit candidate scores, the order will change.

If you are tempted to set every candidate score to `5`, slow down. The purpose is not to flatter the papers. The purpose is to choose a target that can teach you.

If a candidate has no public data and no code, do not choose it for your first reproduction project. Save it for a literature critique.

### Reflection

This exercise taught you to treat paper selection as part of the research method. Later, when you design your own sodium-ion project, you will use the same logic in reverse: make your paper easy to reproduce by publishing data, code, versions, and figure-generation scripts.

## Guided Walkthrough 2: Build the Reproduction Checklist

**Learning objective:** Translate a paper into a checklist of computational claims, required files, assumptions, and tolerances.

Reading for reproduction is different from reading for comprehension. When you read for comprehension, you ask, "What did the authors find?" When you read for reproduction, you ask, "What exact sequence of operations would make this figure appear?" We will build a machine-readable checklist in YAML so it can live beside the code.

Create `references/reproduction-checklist.yaml`:

```yaml
project:
  target_paper: "Severson et al. 2019 Nature Energy"
  target_result: "Figure 2-style early voltage-curve feature prediction"
  reproduction_type: "partial computational reproduction"
  date_started: "2026-05-01"

sources:
  paper_url: "https://doi.org/10.1038/s41560-019-0356-8"
  data_url: "https://data.matr.io/1/"
  processing_code_url: "https://github.com/rdbraatz/data-driven-prediction-of-battery-cycle-life-before-capacity-degradation"

claim:
  plain_language: >
    Features derived from differences between early discharge voltage curves
    predict cycle life better than early discharge capacity alone.
  figure_target: >
    Reproduce the qualitative structure of Figure 2: voltage-curve features
    separate short-lived and long-lived cells and support useful cycle-life
    prediction.

required_inputs:
  - name: "MATR batch data"
    status: "optional_full_dataset"
    local_path: "data/raw"
  - name: "Schema-compatible fixture"
    status: "included_in_script"
    local_path: "generated_when_full_dataset_absent"

known_ambiguities:
  - "Exact train/test split may differ from the paper unless the original split is recovered."
  - "The public repository includes data processing code, while full modeling code availability is limited."
  - "Different public file formats may store cycle dictionaries with slightly different names."
  - "A fixture can verify the workflow but cannot validate the scientific claim."

tolerances:
  fixture_mode:
    required: "Script completes, figures are generated, and voltage-feature model beats capacity baseline."
  full_data_mode:
    required: "Qualitative agreement with Figure 2 and documented error metric; exact match not required without identical split and preprocessing."

outputs:
  - "figures/severson_feature_scatter.png"
  - "figures/severson_prediction_comparison.png"
  - "data/processed/feature_table.csv"
  - "reports/reproduction-summary.md"
```

Now create `src/read_checklist.py`:

```python
from pathlib import Path

import yaml


def main() -> None:
    checklist_path = Path("references/reproduction-checklist.yaml")
    checklist = yaml.safe_load(checklist_path.read_text(encoding="utf-8"))

    print("Target paper:", checklist["project"]["target_paper"])
    print("Target result:", checklist["project"]["target_result"])
    print()
    print("Known ambiguities:")
    for item in checklist["known_ambiguities"]:
        print(f"- {item}")
    print()
    print("Expected outputs:")
    for item in checklist["outputs"]:
        print(f"- {item}")


if __name__ == "__main__":
    main()
```

Run:

```bash
python src/read_checklist.py
```

Expected output:

```text
Target paper: Severson et al. 2019 Nature Energy
Target result: Figure 2-style early voltage-curve feature prediction

Known ambiguities:
- Exact train/test split may differ from the paper unless the original split is recovered.
- The public repository includes data processing code, while full modeling code availability is limited.
- Different public file formats may store cycle dictionaries with slightly different names.
- A fixture can verify the workflow but cannot validate the scientific claim.

Expected outputs:
- figures/severson_feature_scatter.png
- figures/severson_prediction_comparison.png
- data/processed/feature_table.csv
- reports/reproduction-summary.md
```

The checklist separates the paper, the data, the claim, the ambiguities, and the outputs. This separation matters. A common beginner mistake is to write "reproduce Severson paper" as if that were a single task. It is too large. We are reproducing one result class: early-cycle voltage features outperform early capacity features for cycle-life prediction.

The `reproduction_type` field says `partial computational reproduction`. That is honest. We are not reproducing the electrochemical experiments that generated the cells. We are not reproducing every model variant in the paper. We are reproducing a computational claim using public or schema-compatible data.

### What could go wrong

If `yaml.safe_load` fails with a parser error, check indentation. YAML is whitespace-sensitive. Use spaces, not tabs.

If the checklist file is not found, run the command from `SimulationCompanion/chapter12_reproduction_project`, not from the repository root.

If the checklist feels too bureaucratic, remember that future-you is a collaborator. Future-you will not remember why a deviation was acceptable unless present-you writes it down.

### Reflection

This exercise taught you to define scope before writing code. In publishable simulation work, that habit prevents two bad outcomes: claiming more than you reproduced, and abandoning a useful partial reproduction because it was not an impossible perfect one.

## Guided Walkthrough 3: Create a Research Log and Deviation Register

**Learning objective:** Record reproduction decisions in a way that can become a methods paragraph or supplementary note.

A research log is not a diary. It is a low-friction record of decisions that affect interpretation. The most important entries are often small: "Used deterministic split because original split was not recovered," or "Fixture generated with voltage-feature correlation so pipeline could be tested before downloading data." These are the entries that save you when a reviewer asks what changed.

Append this to `logs/research-log.md`:

```markdown
# Research Log

## 2026-05-01

Started Lab Chapter 12 reproduction project.

Target paper:

Severson, K. A., Attia, P. M., Jin, N., et al. "Data-driven prediction of battery cycle life before capacity degradation." Nature Energy 4, 383-391 (2019). https://doi.org/10.1038/s41560-019-0356-8

Target result:

Reproduce a Figure 2-style result showing that early-cycle voltage-curve features are more predictive of cycle life than early discharge capacity alone.

Planned deviations:

1. Use a deterministic schema-compatible fixture when the full MATR dataset is not present.
2. Use a transparent ridge regression implemented in NumPy rather than attempting to exactly match every model variant in the paper.
3. Treat the reproduction as partial unless the full public data and original split are recovered.

Acceptance criteria:

1. In fixture mode, the voltage-feature model must produce lower test mean absolute percentage error than the capacity-baseline model.
2. In full-data mode, the output should qualitatively match the paper's Figure 2 claim: early voltage-curve features contain predictive information not visible in early capacity alone.
3. Every generated figure must be produced by a script, not manually edited.
```

Now create `src/register_deviation.py`:

```python
from __future__ import annotations

from datetime import date
from pathlib import Path


def append_deviation(title: str, reason: str, consequence: str) -> None:
    log_path = Path("logs/research-log.md")
    entry = (
        f"\n## {date.today().isoformat()} - Deviation: {title}\n\n"
        f"Reason:\n\n{reason}\n\n"
        f"Consequence:\n\n{consequence}\n"
    )
    with log_path.open("a", encoding="utf-8") as handle:
        handle.write(entry)


def main() -> None:
    append_deviation(
        title="Fixture mode allowed before full MATR download",
        reason=(
            "The public MATR data can be large and may require manual download. "
            "The chapter must remain runnable on a fresh laptop without network access."
        ),
        consequence=(
            "Fixture-mode figures validate the software workflow only. They must not "
            "be described as reproducing the scientific result from the paper."
        ),
    )
    print("Deviation recorded in logs/research-log.md")


if __name__ == "__main__":
    main()
```

Run:

```bash
python src/register_deviation.py
```

Expected output:

```text
Deviation recorded in logs/research-log.md
```

Open `logs/research-log.md`. You should see a new dated deviation section. The exact date will be the date on your machine.

The code uses `date.today().isoformat()` so the entry is machine-generated and unambiguous. The `append_deviation` function asks for three fields: title, reason, and consequence. That structure is enough for most reproduction choices. Do not write "changed preprocessing" as a title and move on. A deviation without consequence is not useful.

### What could go wrong

If the date differs from the chapter date, that is fine. Use your actual date. Reproduction logs should reflect reality.

If the script appends the same deviation twice, leave it for now or manually remove the duplicate before committing. Later, in a real repository, you would avoid repeated log entries by making the register a table with unique identifiers.

If you dislike generated log entries, you may write them manually. The important rule is that the log exists and is version-controlled.

### Reflection

This exercise taught you to treat deviations as first-class research objects. In your own sodium-ion paper, this habit will help you distinguish a justified adaptation from a hidden change that undermines the claim.

## Dataset Integration: The MATR Battery Cycle-Life Dataset

The guided reproduction targets the dataset used by Severson et al. The paper reports a dataset of 124 commercial lithium iron phosphate/graphite cells cycled under fast-charging conditions, with cycle lives spanning roughly 150 to 2300 cycles. The Nature Energy article states that the datasets are available at `https://data.matr.io/1/`, and the public Braatz group repository provides data-processing code and loading examples.

Download location:

| Source | URL | Notes |
| --- | --- | --- |
| Paper | `https://doi.org/10.1038/s41560-019-0356-8` | Version of record and figure reference |
| Dataset portal | `https://data.matr.io/1/` | Public data portal for the MATR battery dataset |
| Processing repository | `https://github.com/rdbraatz/data-driven-prediction-of-battery-cycle-life-before-capacity-degradation` | Public loading and processing code |

The full data may appear as MATLAB `.mat` files, Python pickle files, or processed batch files depending on the portal mirror and the specific download. In the public processing repository, each cell is described by descriptors, per-cycle summary data, and within-cycle data. The summary fields include quantities such as cycle number, discharge capacity, charge capacity, internal resistance, temperature summaries, and charge time. The cycle data include time, current, voltage, temperature, charge capacity, discharge capacity, and derived voltage-curve arrays such as interpolated discharge capacity.

The sign convention is a pitfall. The public data are already processed for the paper's workflow, so in this chapter we do not reinterpret current signs for electrochemical simulation. We work primarily with discharge voltage-capacity curves and cycle-life labels. If you later feed these data into an ECM or PyBaMM workflow, return to the current-sign normalization rules from Lab Chapter 11.

The second pitfall is that "cycle 10" and "cycle 100" mean indexed cycles inside the processed dataset, not necessarily the tenth and hundredth rows after arbitrary filtering. The script below uses the cycle dictionaries by key when available. In fixture mode, we generate cycles with explicit integer labels so the same feature code is exercised.

The third pitfall is that the original paper's full modeling choices are not all contained in the public processing repository. This is normal in reproduction work. We therefore define our target carefully: reproduce the feature logic and a Figure 2-style relationship, not every model variant from the article.

## Guided Walkthrough 4: Reproduce the Voltage-Feature Workflow

**Learning objective:** Build a complete, runnable reproduction script that extracts early-cycle voltage features, trains transparent baseline models, and writes figures and metrics.

The key idea from the target paper is that changes in discharge voltage curves over early cycles contain information about later cycle life before capacity fade is obvious. A simple version of that idea compares the discharge curve at cycle 100 with the discharge curve at cycle 10 on a common capacity grid:

$$
\Delta Q_{100-10}(V) = Q_{100}(V) - Q_{10}(V).
\tag{2}
$$

The paper uses features derived from this difference curve. We will compute three transparent features: the variance, minimum, and mean of $\Delta Q_{100-10}(V)$. We will compare those voltage-curve features with a baseline that uses early discharge capacity. We will train ridge regression on log cycle life:

$$
\hat{\theta} = \left(X^\top X + \lambda I\right)^{-1} X^\top y,
\tag{3}
$$

where $X$ is the standardized feature matrix and $y = \log_{10}(\text{cycle life})$. The intercept is not regularized. This is not a claim that ridge regression is the exact model used in every part of the paper. It is a transparent model that lets us test the core feature claim with auditable code.

Create `src/reproduce_severson_voltage_feature.py`:

```python
from __future__ import annotations

import math
import pickle
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


RAW_DATA_DIR = Path("data/raw")
PROCESSED_DIR = Path("data/processed")
FIGURE_DIR = Path("figures")
REPORT_DIR = Path("reports")


@dataclass(frozen=True)
class CellRecord:
    cell_id: str
    cycle_life: float
    qd_cycle_10: np.ndarray
    qd_cycle_100: np.ndarray
    early_capacity_ah: float
    source: str


def ensure_directories() -> None:
    for directory in [RAW_DATA_DIR, PROCESSED_DIR, FIGURE_DIR, REPORT_DIR]:
        directory.mkdir(parents=True, exist_ok=True)


def make_voltage_grid() -> np.ndarray:
    return np.linspace(3.6, 2.0, 1000)


def synthesize_fixture(n_cells: int = 124, seed: int = 12) -> list[CellRecord]:
    rng = np.random.default_rng(seed)
    voltage_grid = make_voltage_grid()
    records: list[CellRecord] = []

    for index in range(n_cells):
        cell_id = f"fixture_cell_{index:03d}"
        latent_health = rng.normal(0.0, 1.0)
        log_cycle_life = 3.05 + 0.22 * latent_health + rng.normal(0.0, 0.05)
        cycle_life = float(10**log_cycle_life)

        base_capacity = 1.08 + rng.normal(0.0, 0.015)
        early_capacity = base_capacity + 0.004 * latent_health + rng.normal(0.0, 0.006)

        normalized_voltage = (voltage_grid - voltage_grid.min()) / (
            voltage_grid.max() - voltage_grid.min()
        )
        curve_shape = 0.08 * np.sin(2 * np.pi * normalized_voltage)
        qd_cycle_10 = (
            base_capacity * (1.0 - normalized_voltage)
            + curve_shape
            + rng.normal(0.0, 0.0015, size=voltage_grid.size)
        )

        degradation_signature = -0.010 * latent_health
        localized_feature = np.exp(-((voltage_grid - 3.25) / 0.18) ** 2)
        broad_feature = 0.35 + 0.65 * normalized_voltage
        delta_q = degradation_signature * localized_feature * broad_feature
        qd_cycle_100 = qd_cycle_10 + delta_q + rng.normal(
            0.0, 0.0015, size=voltage_grid.size
        )

        records.append(
            CellRecord(
                cell_id=cell_id,
                cycle_life=cycle_life,
                qd_cycle_10=qd_cycle_10,
                qd_cycle_100=qd_cycle_100,
                early_capacity_ah=float(early_capacity),
                source="fixture",
            )
        )

    return records


def find_pickle_files() -> list[Path]:
    return sorted(RAW_DATA_DIR.glob("*.pkl")) + sorted(RAW_DATA_DIR.glob("*.pickle"))


def first_existing_key(mapping: dict[str, Any], candidates: list[str]) -> str | None:
    for candidate in candidates:
        if candidate in mapping:
            return candidate
    return None


def extract_cycle_life(cell: dict[str, Any]) -> float | None:
    for key in ["cycle_life", "cycleLife", "Cycle life", "cycle life"]:
        if key in cell:
            return float(np.asarray(cell[key]).squeeze())
    return None


def extract_summary_capacity(cell: dict[str, Any]) -> float | None:
    summary_key = first_existing_key(cell, ["summary", "summaries"])
    if summary_key is None:
        return None
    summary = cell[summary_key]
    if not isinstance(summary, dict):
        return None
    capacity_key = first_existing_key(
        summary,
        ["QD", "QDischarge", "discharge_capacity", "Discharge Capacity (Ah)"],
    )
    if capacity_key is None:
        return None
    capacity = np.asarray(summary[capacity_key], dtype=float).ravel()
    if capacity.size < 10:
        return None
    return float(capacity[min(9, capacity.size - 1)])


def extract_qd_curve(cycle: dict[str, Any]) -> np.ndarray | None:
    for key in ["Qdlin", "Qd", "QD", "discharge_capacity"]:
        if key in cycle:
            curve = np.asarray(cycle[key], dtype=float).ravel()
            if curve.size >= 50:
                return curve
    return None


def load_records_from_pickle(path: Path) -> list[CellRecord]:
    with path.open("rb") as handle:
        payload = pickle.load(handle)

    if isinstance(payload, dict) and "batch" in payload:
        payload = payload["batch"]

    if not isinstance(payload, dict):
        return []

    records: list[CellRecord] = []
    for cell_id, cell in payload.items():
        if not isinstance(cell, dict):
            continue

        cycle_life = extract_cycle_life(cell)
        if cycle_life is None or not np.isfinite(cycle_life):
            continue

        cycles_key = first_existing_key(cell, ["cycles", "cycle"])
        if cycles_key is None or not isinstance(cell[cycles_key], dict):
            continue

        cycles = cell[cycles_key]
        cycle_10 = cycles.get("10", cycles.get(10))
        cycle_100 = cycles.get("100", cycles.get(100))
        if not isinstance(cycle_10, dict) or not isinstance(cycle_100, dict):
            continue

        qd_cycle_10 = extract_qd_curve(cycle_10)
        qd_cycle_100 = extract_qd_curve(cycle_100)
        if qd_cycle_10 is None or qd_cycle_100 is None:
            continue

        min_size = min(qd_cycle_10.size, qd_cycle_100.size)
        if min_size < 50:
            continue

        early_capacity = extract_summary_capacity(cell)
        if early_capacity is None:
            early_capacity = float(np.nanmax(qd_cycle_10))

        records.append(
            CellRecord(
                cell_id=str(cell_id),
                cycle_life=float(cycle_life),
                qd_cycle_10=qd_cycle_10[:min_size],
                qd_cycle_100=qd_cycle_100[:min_size],
                early_capacity_ah=float(early_capacity),
                source=path.name,
            )
        )

    return records


def load_records() -> list[CellRecord]:
    pickle_files = find_pickle_files()
    records: list[CellRecord] = []
    for path in pickle_files:
        records.extend(load_records_from_pickle(path))

    if records:
        print(f"Loaded {len(records)} cell records from {len(pickle_files)} pickle file(s).")
        return records

    print("No compatible MATR pickle files found in data/raw.")
    print("Using deterministic fixture data for workflow verification.")
    return synthesize_fixture()


def resample_curve(curve: np.ndarray, target_size: int = 1000) -> np.ndarray:
    source_axis = np.linspace(0.0, 1.0, curve.size)
    target_axis = np.linspace(0.0, 1.0, target_size)
    return np.interp(target_axis, source_axis, curve)


def build_feature_table(records: list[CellRecord]) -> pd.DataFrame:
    rows: list[dict[str, float | str]] = []
    for record in records:
        q10 = resample_curve(record.qd_cycle_10)
        q100 = resample_curve(record.qd_cycle_100)
        delta_q = q100 - q10
        rows.append(
            {
                "cell_id": record.cell_id,
                "cycle_life": record.cycle_life,
                "log10_cycle_life": math.log10(record.cycle_life),
                "early_capacity_ah": record.early_capacity_ah,
                "delta_q_mean": float(np.mean(delta_q)),
                "delta_q_min": float(np.min(delta_q)),
                "delta_q_variance": float(np.var(delta_q)),
                "source": record.source,
            }
        )
    frame = pd.DataFrame(rows)
    frame = frame.replace([np.inf, -np.inf], np.nan).dropna()
    return frame


def deterministic_split(frame: pd.DataFrame, test_fraction: float = 0.25) -> tuple[np.ndarray, np.ndarray]:
    ordered = frame.sort_values("cell_id").reset_index(drop=True)
    indices = np.arange(len(ordered))
    test_mask = indices % int(round(1.0 / test_fraction)) == 0
    train_indices = ordered.index[~test_mask].to_numpy()
    test_indices = ordered.index[test_mask].to_numpy()
    return train_indices, test_indices


@dataclass(frozen=True)
class Standardizer:
    mean: np.ndarray
    scale: np.ndarray

    def transform(self, values: np.ndarray) -> np.ndarray:
        return (values - self.mean) / self.scale


def fit_standardizer(values: np.ndarray) -> Standardizer:
    mean = values.mean(axis=0)
    scale = values.std(axis=0)
    scale = np.where(scale == 0.0, 1.0, scale)
    return Standardizer(mean=mean, scale=scale)


def fit_ridge_regression(features: np.ndarray, target: np.ndarray, regularization: float = 1.0) -> np.ndarray:
    design = np.column_stack([np.ones(features.shape[0]), features])
    penalty = np.eye(design.shape[1]) * regularization
    penalty[0, 0] = 0.0
    coefficients = np.linalg.solve(design.T @ design + penalty, design.T @ target)
    return coefficients


def predict_ridge(features: np.ndarray, coefficients: np.ndarray) -> np.ndarray:
    design = np.column_stack([np.ones(features.shape[0]), features])
    return design @ coefficients


def mean_absolute_percentage_error(observed: np.ndarray, predicted: np.ndarray) -> float:
    return float(np.mean(np.abs((observed - predicted) / observed)) * 100.0)


def train_and_evaluate(
    frame: pd.DataFrame,
    feature_columns: list[str],
    model_name: str,
) -> dict[str, float | str | np.ndarray]:
    train_indices, test_indices = deterministic_split(frame)
    x = frame[feature_columns].to_numpy(dtype=float)
    y = frame["log10_cycle_life"].to_numpy(dtype=float)

    standardizer = fit_standardizer(x[train_indices])
    x_train = standardizer.transform(x[train_indices])
    x_test = standardizer.transform(x[test_indices])

    coefficients = fit_ridge_regression(x_train, y[train_indices], regularization=1.0)
    predicted_log = predict_ridge(x_test, coefficients)

    observed_cycles = 10 ** y[test_indices]
    predicted_cycles = 10 ** predicted_log
    mape = mean_absolute_percentage_error(observed_cycles, predicted_cycles)

    return {
        "model_name": model_name,
        "feature_columns": ", ".join(feature_columns),
        "test_mape_percent": mape,
        "observed_cycles": observed_cycles,
        "predicted_cycles": predicted_cycles,
        "test_cell_ids": frame.iloc[test_indices]["cell_id"].to_numpy(),
    }


def plot_feature_scatter(frame: pd.DataFrame) -> None:
    figure, axes = plt.subplots(1, 2, figsize=(11.0, 4.5), constrained_layout=True)

    scatter0 = axes[0].scatter(
        frame["early_capacity_ah"],
        frame["cycle_life"],
        c=frame["cycle_life"],
        cmap="viridis",
        s=36,
        edgecolor="black",
        linewidth=0.3,
    )
    axes[0].set_xlabel("Early discharge capacity (Ah)")
    axes[0].set_ylabel("Cycle life (cycles)")
    axes[0].set_title("Capacity baseline")
    axes[0].grid(True, alpha=0.3)

    axes[1].scatter(
        frame["delta_q_variance"],
        frame["cycle_life"],
        c=frame["cycle_life"],
        cmap="viridis",
        s=36,
        edgecolor="black",
        linewidth=0.3,
    )
    axes[1].set_xlabel(r"Variance of $\Delta Q_{100-10}(V)$")
    axes[1].set_ylabel("Cycle life (cycles)")
    axes[1].set_title("Voltage-curve feature")
    axes[1].grid(True, alpha=0.3)

    colorbar = figure.colorbar(scatter0, ax=axes, shrink=0.9)
    colorbar.set_label("Cycle life (cycles)")
    figure.savefig(FIGURE_DIR / "severson_feature_scatter.png", dpi=200)
    plt.close(figure)


def plot_prediction_comparison(results: list[dict[str, float | str | np.ndarray]]) -> None:
    figure, axes = plt.subplots(1, len(results), figsize=(11.0, 4.5), constrained_layout=True)
    if len(results) == 1:
        axes = [axes]

    for axis, result in zip(axes, results):
        observed = np.asarray(result["observed_cycles"], dtype=float)
        predicted = np.asarray(result["predicted_cycles"], dtype=float)
        axis.scatter(observed, predicted, s=42, edgecolor="black", linewidth=0.3)
        lower = min(observed.min(), predicted.min())
        upper = max(observed.max(), predicted.max())
        axis.plot([lower, upper], [lower, upper], color="black", linestyle="--", linewidth=1.2)
        axis.set_xscale("log")
        axis.set_yscale("log")
        axis.set_xlabel("Observed cycle life")
        axis.set_ylabel("Predicted cycle life")
        axis.set_title(f"{result['model_name']}\nMAPE = {result['test_mape_percent']:.1f}%")
        axis.grid(True, which="both", alpha=0.3)

    figure.savefig(FIGURE_DIR / "severson_prediction_comparison.png", dpi=200)
    plt.close(figure)


def write_summary(frame: pd.DataFrame, results: list[dict[str, float | str | np.ndarray]]) -> None:
    lines = [
        "# Reproduction Summary",
        "",
        "Target paper: Severson et al. (2019), Nature Energy.",
        "",
        f"Number of cells used: {len(frame)}",
        f"Data source mode: {', '.join(sorted(frame['source'].unique()))}",
        "",
        "## Model Comparison",
        "",
        "| Model | Features | Test MAPE (%) |",
        "| --- | --- | ---: |",
    ]

    for result in results:
        lines.append(
            f"| {result['model_name']} | {result['feature_columns']} | "
            f"{result['test_mape_percent']:.2f} |"
        )

    voltage_result = next(item for item in results if item["model_name"] == "voltage features")
    capacity_result = next(item for item in results if item["model_name"] == "capacity baseline")
    lines.extend(
        [
            "",
            "## Interpretation",
            "",
        ]
    )
    if float(voltage_result["test_mape_percent"]) < float(capacity_result["test_mape_percent"]):
        lines.append(
            "The voltage-feature model outperformed the early-capacity baseline in this run. "
            "In fixture mode, this verifies that the workflow can recover the planted signal. "
            "In full-data mode, this supports the qualitative Figure 2-style claim."
        )
    else:
        lines.append(
            "The voltage-feature model did not outperform the capacity baseline in this run. "
            "Inspect the data source, cycle extraction, train-test split, and feature definitions "
            "before drawing a scientific conclusion."
        )

    lines.extend(
        [
            "",
            "## Deviations",
            "",
            "- This script uses transparent ridge regression rather than attempting to reproduce every model variant in the paper.",
            "- If no compatible public data file is present, the script uses a deterministic fixture for workflow verification only.",
        ]
    )

    (REPORT_DIR / "reproduction-summary.md").write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    ensure_directories()
    records = load_records()
    feature_table = build_feature_table(records)

    if len(feature_table) < 20:
        raise RuntimeError("Need at least 20 valid cell records for a meaningful split.")

    feature_table.to_csv(PROCESSED_DIR / "feature_table.csv", index=False)

    capacity_result = train_and_evaluate(
        feature_table,
        feature_columns=["early_capacity_ah"],
        model_name="capacity baseline",
    )
    voltage_result = train_and_evaluate(
        feature_table,
        feature_columns=["delta_q_mean", "delta_q_min", "delta_q_variance"],
        model_name="voltage features",
    )
    results = [capacity_result, voltage_result]

    plot_feature_scatter(feature_table)
    plot_prediction_comparison(results)
    write_summary(feature_table, results)

    print("Reproduction run complete.")
    print(f"Cells used: {len(feature_table)}")
    for result in results:
        print(
            f"{result['model_name']}: "
            f"test MAPE = {result['test_mape_percent']:.2f}%"
        )
    print("Wrote data/processed/feature_table.csv")
    print("Wrote figures/severson_feature_scatter.png")
    print("Wrote figures/severson_prediction_comparison.png")
    print("Wrote reports/reproduction-summary.md")


if __name__ == "__main__":
    main()
```

Run:

```bash
python src/reproduce_severson_voltage_feature.py
```

Expected terminal output in fixture mode:

```text
No compatible MATR pickle files found in data/raw.
Using deterministic fixture data for workflow verification.
Reproduction run complete.
Cells used: 124
capacity baseline: test MAPE = xx.xx%
voltage features: test MAPE = yy.yy%
Wrote data/processed/feature_table.csv
Wrote figures/severson_feature_scatter.png
Wrote figures/severson_prediction_comparison.png
Wrote reports/reproduction-summary.md
```

The exact MAPE values may differ slightly across NumPy versions, but the voltage-feature model should beat the capacity baseline in fixture mode. That is because the fixture deliberately plants a voltage-curve signal correlated with cycle life while making early capacity only weakly informative. Again: fixture mode verifies the workflow, not the paper.

Open `figures/severson_feature_scatter.png`. The figure has two panels. The left panel plots early discharge capacity on the x-axis and cycle life on the y-axis. In fixture mode, the points should look like a broad cloud with only a weak trend. The right panel plots the variance of $\Delta Q_{100-10}(V)$ on the x-axis and cycle life on the y-axis. You should see a clearer monotonic relationship. The color scale also encodes cycle life, so a correct plot has a smoother color progression in the voltage-feature panel than in the capacity panel.

Open `figures/severson_prediction_comparison.png`. This figure also has two panels. Each panel plots observed cycle life on the x-axis and predicted cycle life on the y-axis using log-log axes. The dashed diagonal line is perfect prediction. The capacity-baseline panel should show wider scatter away from the diagonal. The voltage-feature panel should cluster more tightly around the diagonal. A wrong result would show the voltage-feature panel as no better than capacity in fixture mode; that usually means the feature calculation was changed or the target was shuffled.

Open `data/processed/feature_table.csv`. You should see one row per cell with columns for cycle life, early capacity, and the three voltage features. Open `reports/reproduction-summary.md`. It should contain a small table comparing the two models and a short interpretation.

The code deserves careful reading. `CellRecord` defines the minimum object needed for this reproduction: cell ID, cycle life, discharge-capacity curves at cycles 10 and 100, early capacity, and source. `synthesize_fixture` builds a deterministic surrogate dataset with the same shape as the real workflow. It uses a latent health variable to generate cycle life and to perturb the difference between cycle-10 and cycle-100 voltage-capacity curves. The fixture is realistic enough to exercise the code, but it is not a substitute for the MATR data.

`load_records_from_pickle` is intentionally defensive. Public research files drift. Some dictionaries use string keys, others use integer keys. Some summary fields are named `QD`; others have longer names. The loader searches candidate keys and skips cells that do not contain the required fields. This is standard practice when reproducing from public processed data.

`build_feature_table` computes Equation (2) after resampling both curves to a common length. The paper's actual workflow uses linearly interpolated discharge curves, so this resampling step is conceptually aligned even though our implementation is simplified. `train_and_evaluate` uses a deterministic cell-ID split so the result can be rerun without randomness. That split is one of our documented deviations.

The ridge implementation is deliberately visible. `fit_standardizer` computes training-set mean and standard deviation. `fit_ridge_regression` builds the design matrix, adds an intercept, and solves Equation (3). The target is log cycle life because battery lifetime errors are naturally relative; predicting 200 instead of 300 cycles is not the same practical error as predicting 2000 instead of 2100 cycles.

### What could go wrong

If the script says fewer than 20 valid records were found after you download data, inspect the data structure with a small exploratory script. The public file may not be the same pickle layout expected by this minimal loader. Use Lab Chapter 11's parser patterns to adapt the key names.

If the voltage-feature model does not beat the capacity baseline in fixture mode, check that `delta_q = q100 - q10` was not reversed and that `cycle_life` was not shuffled. The planted signal is mild but real.

If the figure files are blank, confirm that Matplotlib installed correctly and that the script ran from the chapter project root. The script writes relative paths such as `figures/...`.

If full-data mode gives worse results than expected, do not immediately change the model until it looks good. First document the result, then test specific hypotheses: cycle indexing, train-test split, feature definitions, outlier cells, and whether the loaded batch matches the paper's analyzed set.

### Reflection

This exercise taught the central move of computational reproduction: make a claim operational. "Voltage curves predict cycle life" became a feature table, a model, a metric, and two figures. The simplifications are visible, which means they can be criticized and improved.

## Guided Walkthrough 5: Add Tests So the Reproduction Does Not Rot

**Learning objective:** Write small tests that protect the feature calculation and regression workflow from accidental changes.

A reproduction repository is not finished when the script runs once. It is finished when you can change a parser, rerun the tests, and know whether the core assumptions survived. We will add a small `pytest` suite.

Create `tests/test_reproduction_workflow.py`:

```python
import sys
from pathlib import Path

import numpy as np

PROJECT_ROOT = Path(__file__).resolve().parents[1]
SRC_DIR = PROJECT_ROOT / "src"
sys.path.insert(0, str(SRC_DIR))

from reproduce_severson_voltage_feature import (  # noqa: E402
    build_feature_table,
    mean_absolute_percentage_error,
    synthesize_fixture,
    train_and_evaluate,
)


def test_fixture_has_expected_number_of_records() -> None:
    records = synthesize_fixture(n_cells=30, seed=12)
    assert len(records) == 30
    assert all(record.qd_cycle_10.size == 1000 for record in records)
    assert all(record.qd_cycle_100.size == 1000 for record in records)


def test_feature_table_contains_voltage_features() -> None:
    records = synthesize_fixture(n_cells=30, seed=12)
    table = build_feature_table(records)
    assert len(table) == 30
    assert "delta_q_variance" in table.columns
    assert np.isfinite(table["delta_q_variance"]).all()
    assert (table["cycle_life"] > 0).all()


def test_voltage_features_beat_capacity_on_fixture() -> None:
    records = synthesize_fixture(n_cells=124, seed=12)
    table = build_feature_table(records)
    capacity_result = train_and_evaluate(
        table,
        feature_columns=["early_capacity_ah"],
        model_name="capacity baseline",
    )
    voltage_result = train_and_evaluate(
        table,
        feature_columns=["delta_q_mean", "delta_q_min", "delta_q_variance"],
        model_name="voltage features",
    )
    assert voltage_result["test_mape_percent"] < capacity_result["test_mape_percent"]


def test_mape_is_zero_for_perfect_prediction() -> None:
    observed = np.array([100.0, 200.0, 300.0])
    predicted = np.array([100.0, 200.0, 300.0])
    assert mean_absolute_percentage_error(observed, predicted) == 0.0
```

Run:

```bash
pytest -q
```

Expected output:

```text
....                                                                     [100%]
4 passed in x.xx s
```

The first test confirms that the fixture produces the requested number of records and that the two curves have the expected length. The second test confirms that feature extraction creates finite voltage features and positive cycle lives. The third test protects the teaching purpose of the fixture: voltage features should beat capacity in this controlled surrogate. The fourth test checks the metric itself.

These tests are not a proof that the paper is reproduced. They are guardrails around the code. If a future edit reverses the sign of $\Delta Q$, drops the wrong rows, or changes the deterministic fixture, the tests will make the change visible.

### What could go wrong

If `pytest` cannot import `reproduce_severson_voltage_feature`, confirm the test file is inside `tests` and that you are running from the project root. The test inserts `src` into `sys.path`.

If the voltage-feature test fails by a tiny amount after you edit the fixture, inspect the generated scatter plot. You may have weakened the planted signal. Decide whether that was intentional and document it.

If tests pass but full-data reproduction fails, remember what the tests cover. They protect code mechanics, not the truth of external data assumptions.

### Reflection

This exercise taught you to test a research workflow without pretending that tests answer scientific questions. Good tests keep the machinery honest so your scientific attention can go to the assumptions.

## Guided Walkthrough 6: Write the Reproduction Report

**Learning objective:** Turn code outputs, deviations, and figures into a concise reproduction write-up.

The final report should be short enough that someone will read it and specific enough that someone can criticize it. It should not sound like a victory lap. It should sound like a careful account of what was attempted, what was reproduced, what differed, and what remains unresolved.

Create `reports/final-reproduction-report.md`:

```markdown
# Reproduction Report: Severson et al. 2019 Voltage-Feature Workflow

## Target

This project partially reproduces a central computational claim from Severson et al. (2019): early-cycle discharge voltage-curve features contain predictive information about battery cycle life before obvious capacity degradation appears.

The target is a Figure 2-style result, not a full reproduction of every model in the paper.

## Sources

- Paper: https://doi.org/10.1038/s41560-019-0356-8
- Public data portal: https://data.matr.io/1/
- Public processing code: https://github.com/rdbraatz/data-driven-prediction-of-battery-cycle-life-before-capacity-degradation

## Computational Environment

- Python: record output from `python --version`
- NumPy: record output from `python src/verify_environment.py`
- pandas: record output from `python src/verify_environment.py`
- Matplotlib: record output from `python src/verify_environment.py`

## Method

For each cell, the workflow extracts discharge-capacity curves at cycle 10 and cycle 100. Both curves are resampled onto a common normalized grid. The difference curve is computed as:

$$
\Delta Q_{100-10}(V) = Q_{100}(V) - Q_{10}(V).
$$

Three voltage-curve features are computed from this difference curve: mean, minimum, and variance. A capacity baseline uses early discharge capacity only. Both feature sets are used to fit ridge regression models to log10 cycle life with a deterministic cell-ID split.

## Outputs

- `data/processed/feature_table.csv`
- `figures/severson_feature_scatter.png`
- `figures/severson_prediction_comparison.png`
- `reports/reproduction-summary.md`

## Result

Paste the model-comparison table from `reports/reproduction-summary.md` here.

In fixture mode, the voltage-feature model should outperform the capacity baseline. This verifies that the code path can recover a known voltage-feature signal. In full-data mode, the same comparison should be interpreted as a partial reproduction of the paper's Figure 2-style claim.

## Deviations from the Paper

1. The script uses transparent ridge regression instead of attempting to reproduce every proprietary or unavailable model variant.
2. The train-test split is deterministic by cell ID unless the original split is recovered.
3. A deterministic fixture is used when full MATR files are absent.
4. Feature extraction is simplified to three summary statistics of the cycle-100 minus cycle-10 difference curve.

## Reproduction Status

Status: partial reproduction.

The workflow is reproducible as code. Scientific agreement with the paper requires running against the full public MATR dataset and checking the resulting figures and metrics against the published Figure 2 claim.

## Lessons Learned

Write three paragraphs:

1. What was easy to reproduce?
2. What depended on undocumented or ambiguous choices?
3. How would you design your own sodium-ion study to be easier to reproduce?
```

This report is a template, but it is not a placeholder in the lazy sense. Every section has a job. The target prevents scope drift. The sources make provenance explicit. The method describes the pipeline. The deviations protect honesty. The status prevents overclaiming.

Now update the report after you run the script. Paste the model-comparison table from `reports/reproduction-summary.md`. Add the actual Python version. Add a paragraph describing whether you used fixture mode or full-data mode.

### What could go wrong

If the report becomes longer than the code, tighten it. A reproduction report is not a second paper.

If you feel embarrassed by the deviations, do not hide them. Deviation is normal. Hidden deviation is the problem.

If you used fixture mode, say so in the first page. Do not let a reader discover it in the code.

### Reflection

This exercise taught you to write the kind of computational methods note that makes a reproduction useful. Your future sodium-ion papers should include this level of clarity from the beginning.

## Open-Ended Exercises

### Exercise 1: Replace the fixture with the full public MATR data

Download the public data from the MATR portal and place compatible `.pkl` files in `data/raw`. Run `python src/reproduce_severson_voltage_feature.py`. If the loader fails, inspect the file structure and adapt `load_records_from_pickle`.

Hints: start by printing `type(payload)` and the first three keys. Then inspect one cell dictionary. Look for descriptors, summary fields, and cycles. Do not edit raw files.

Worked solution outline: The correct solution is not one universal code block because public mirrors differ. The successful adaptation should still produce `CellRecord` objects with `cycle_life`, `qd_cycle_10`, `qd_cycle_100`, and `early_capacity_ah`. Add every key-name change to the research log.

### Exercise 2: Reproduce a Marquis et al. SPMe comparison instead

Use PyBaMM to compare SPM, SPMe, and DFN voltage curves under the same discharge protocol. Choose one figure from Marquis et al. that compares model fidelity, then reproduce the qualitative ordering: DFN as reference, SPMe closer than SPM at higher C-rate.

Hints: start from Lab Chapter 3. Pin `pybamm==26.3.1`. Use `pybamm.lithium_ion.SPM()`, `pybamm.lithium_ion.SPMe()`, and `pybamm.lithium_ion.DFN()`. Keep the parameter set fixed.

Worked partial solution:

```python
import matplotlib.pyplot as plt
import pybamm

parameter_values = pybamm.ParameterValues("Chen2020")
experiment = pybamm.Experiment(["Discharge at 2C until 2.8 V"], period="10 seconds")

models = {
    "SPM": pybamm.lithium_ion.SPM(),
    "SPMe": pybamm.lithium_ion.SPMe(),
    "DFN": pybamm.lithium_ion.DFN(),
}

solutions = {}
for name, model in models.items():
    simulation = pybamm.Simulation(
        model,
        parameter_values=parameter_values,
        experiment=experiment,
    )
    solutions[name] = simulation.solve()

plt.figure(figsize=(7.0, 4.5))
for name, solution in solutions.items():
    time_min = solution.t / 60.0
    voltage = solution["Terminal voltage [V]"](solution.t)
    plt.plot(time_min, voltage, label=name)

plt.xlabel("Time (min)")
plt.ylabel("Terminal voltage (V)")
plt.title("Model-fidelity comparison under 2C discharge")
plt.grid(True, alpha=0.3)
plt.legend()
plt.tight_layout()
plt.savefig("figures/marquis_style_model_comparison.png", dpi=200)
plt.show()
```

In a correct result, all three voltage curves begin near the same voltage. The SPM curve should deviate more strongly from the DFN curve as electrolyte effects matter, while the SPMe curve should usually sit closer to the DFN reference. The exact shape depends on parameter set and protocol, so document your choices.

### Exercise 3: Turn the reproduction into a sodium-ion adaptation

Find a public sodium-ion cycling dataset from Mendeley, Zenodo, or a paper supplement. Apply the same feature idea: compare early-cycle voltage-capacity curves and test whether difference-curve features correlate with later capacity retention.

Hints: keep the target modest. Use capacity retention at a fixed later cycle if full end-of-life is unavailable. Sodium-ion OCV curves can be flatter or more stepped depending on hard carbon and cathode chemistry, so inspect the voltage window before blindly reusing the LFP feature grid.

Worked solution outline: Your report should say "adaptation" rather than "reproduction." Validate the code path on Severson-style data first, then apply it to sodium-ion. Compare the direction and stability of features, not only the regression score.

### Exercise 4: Perform a tolerance sensitivity study

Modify the reproduction script to test cycle pairs `(20, 80)`, `(10, 100)`, and `(5, 50)`. Compare whether the voltage-feature model still beats capacity.

Hints: refactor `CellRecord` if you use real data with multiple cycle pairs. In fixture mode, generate additional cycle curves by extending the synthetic function.

Worked solution outline: A strong result should not depend completely on one arbitrary pair. If the conclusion changes sharply, that is not automatically bad, but it must be reported. In the Severson paper, the cycle-index dependence is itself an object of study.

## Reproduction Exercise: Figure 2-Style Result from Severson et al.

Your required reproduction exercise for this Part is the guided Severson project above. The target paper is:

Severson, K. A., Attia, P. M., Jin, N., Perkins, N., Jiang, B., Yang, Z., Chen, M. H., Aykol, M., Herring, P. K., Fraggedakis, D., Bazant, M. Z., Harris, S. J., Chueh, W. C., and Braatz, R. D. "Data-driven prediction of battery cycle life before capacity degradation." *Nature Energy* 4, 383-391 (2019). DOI: `10.1038/s41560-019-0356-8`.

The specific target is a Figure 2-style result, not pixel-level reconstruction. Figure 2 in the paper emphasizes the predictive value of voltage-curve features from the first 100 cycles. Our reproduction computes $\Delta Q_{100-10}(V)$ features and compares them with early discharge capacity. The paper's exact feature set and model variants are richer than this teaching implementation, so the reproduction tolerance is qualitative in fixture mode and semi-quantitative in full-data mode.

Close enough means the following. In fixture mode, the voltage-feature model must outperform the capacity baseline because that validates the code path against a known signal. In full-data mode, the feature scatter should show visibly more structure for voltage-curve features than for early capacity, and the prediction comparison should show lower relative error for voltage features under the documented split. If the exact MAPE does not match the paper, that is acceptable only if you document differences in split, file version, feature definition, and model class.

Where the paper is ambiguous, choose the most conservative interpretation. Do not tune choices until the result looks like the paper. Make one defensible implementation, log it, and then run sensitivity checks. If a sensitivity check changes the conclusion, that becomes part of the reproduction result.

## What Changes for Sodium-Ion?

The reproduction habit transfers directly to sodium-ion. The details do not.

Sodium-ion public datasets are sparser, and many papers still provide processed plots rather than raw cycling files. That changes the reproduction target. For a lithium-ion benchmark paper, you may reproduce a figure from raw public data. For a sodium-ion paper, you may need to reproduce a model structure, digitize a published curve with WebPlotDigitizer, or validate a method on lithium-ion data before adapting it to a small sodium-ion dataset.

The voltage-feature idea also needs chemistry awareness. LFP/graphite cells have their own voltage-curve structure. Hard-carbon sodium-ion anodes and Prussian white or layered-oxide cathodes can produce different plateau shapes, hysteresis, and sloping regions. A feature such as variance of $\Delta Q(V)$ may still be useful, but the voltage window and interpolation grid must follow the sodium-ion cell's actual operating range. Do not impose a `3.6` to `2.0` V grid on a sodium-ion dataset just because this chapter used it for an LFP-style workflow.

Cycle life labels may also differ. A sodium-ion study might report capacity retention after 100 cycles rather than end-of-life cycle count. That is not a defect; it is a different target variable. Your reproduction report should state whether you predicted cycle life, retained capacity, resistance growth, Coulombic efficiency trend, or another observable.

Finally, sodium-ion reproduction often has a stronger materials-methods component. If a result depends on electrolyte formulation, cathode water content, presodiation, electrode balancing, or formation protocol, a laptop-only reproduction cannot reproduce the experiment. It can reproduce the analysis. Say that plainly.

## Chapter Summary and Skill Checklist

- You selected a reproduction target with a documented scorecard instead of intuition alone.
- You converted a paper claim into a checklist with sources, ambiguities, tolerances, and expected outputs.
- You created a research log and deviation register.
- You built a complete Figure 2-style reproduction workflow for the Severson et al. cycle-life paper.
- You implemented transparent feature extraction, ridge regression, plotting, testing, and reporting.
- You learned how to distinguish fixture-mode workflow verification from full-data scientific reproduction.
- You mapped the reproduction workflow onto sodium-ion adaptation constraints.

Commands, functions, and patterns that should now be in muscle memory:

- `python -m venv .venv-chapter12`
- `python -m pip install ...`
- `pytest -q`
- `dataclass` for structured paper and cell records
- `yaml.safe_load(...)` for machine-readable checklists
- `Path(...).mkdir(parents=True, exist_ok=True)` for reproducible folders
- `np.interp(...)` for curve resampling
- `np.linalg.solve(...)` for transparent ridge regression
- deterministic train-test splitting when original random splits are unavailable
- research-log entries for deviations and ambiguity

You should now be able to:

- Choose a reproduction paper that is feasible for your tools and time.
- Define the exact figure or claim you are reproducing.
- List missing information before it causes confusion.
- Build a small repository that separates raw data, processed data, source code, figures, reports, and logs.
- Reproduce a voltage-feature workflow from public or schema-compatible battery cycling data.
- Write a reproduction report that is honest about scope and deviations.
- Explain how a lithium-ion reproduction workflow can be adapted, carefully, to sodium-ion research.

If you cannot check every box, do not rush into Lab Chapter 13. Reproduction is the bridge from coursework to research. It is worth making this bridge sturdy.

## Deliverable

Your deliverable is a GitHub-ready repository at `SimulationCompanion/chapter12_reproduction_project` containing:

- `README.md` describing the target paper, scope, and run command
- `references/reproduction-checklist.yaml`
- `logs/research-log.md`
- `src/paper_scorecard.py`
- `src/read_checklist.py`
- `src/register_deviation.py`
- `src/reproduce_severson_voltage_feature.py`
- `tests/test_reproduction_workflow.py`
- `data/processed/feature_table.csv` generated by the reproduction script
- `figures/severson_feature_scatter.png`
- `figures/severson_prediction_comparison.png`
- `reports/reproduction-summary.md`
- `reports/final-reproduction-report.md`

Approach the deliverable in three passes. First, make fixture mode run cleanly and commit it. Second, add full public data if you have time and adapt the loader without breaking the tests. Third, revise the final report so it clearly says what mode you used and what scientific conclusion is justified.

The worked partial solution is the code in this chapter. Your own final solution should add your machine's environment output, your actual research-log entries, and any loader changes needed for the data files you downloaded.

## Further Practice and Reading

Severson et al. (2019), "Data-driven prediction of battery cycle life before capacity degradation," *Nature Energy*, is the main target paper for this chapter. Bookmark the DOI page and the MATR data portal.

The Braatz group GitHub repository `rdbraatz/data-driven-prediction-of-battery-cycle-life-before-capacity-degradation` is worth reading because it shows the public processing structure and also teaches an important reproduction lesson: public processing code is not always the same as full modeling code.

Marquis et al. (2019), "An asymptotic derivation of a single particle model with electrolyte," *Journal of The Electrochemical Society*, is the recommended physics-model reproduction alternative. It connects directly to PyBaMM's SPMe implementation.

Sulzer et al. (2021), "Python Battery Mathematical Modelling (PyBaMM)," *Journal of Open Research Software*, is a useful software-paper reproduction target and a citation to include when PyBaMM is part of your method.

The official PyBaMM documentation at `https://docs.pybamm.org/en/stable/` is the first place to check when a model reproduction fails because of version drift. For community help, use the PyBaMM Discourse linked from the PyBaMM website, and include a minimal runnable script when you ask a question.

Next chapter: Lab Chapter 13, "Specialization Tracks."

# Battery Simulation and Research Tools: A Hands-On Companion

- **Target duration:** 16-20 weeks part-time (roughly 10-15 hours/week)
- **Prerequisites:** Completion of the battery technology textbook; working Python (NumPy, SciPy, Matplotlib, Jupyter) and MATLAB (scripting, plotting, basic Simulink)
- **Goal:** Proficiency in the simulation tools, data workflows, and reproduction practices required to produce publishable simulation-based sodium-ion battery research
- **Companion to:** *Battery Technology for Electrical Engineers* (the self-study textbook)

## Part I: Foundations and Environment (Weeks 1-2)

### Lab Chapter 1: The Research Computing Environment

**Skill objective:** Set up a reproducible research environment and develop habits that will not embarrass you later.

#### 1.1-1.9 Topics

1. Why reproducibility matters in simulation research
2. Python environments: conda vs venv, why you need isolation
3. Installing the scientific stack with pinned versions
4. Jupyter Lab setup and workflow conventions
5. MATLAB setup and toolbox verification (Simulink, Simscape, Simscape Battery, Control System Toolbox, Optimization Toolbox)
6. Git and GitHub basics for research: init, commit, branch, remote, `.gitignore` for data files
7. Research log conventions: dated markdown entries, what to record, what to skip
8. Folder structure for a research project (`data/`, `notebooks/`, `src/`, `results/`, `papers/`)
9. A "hello battery" sanity check in both Python and MATLAB

**Deliverable:** A GitHub repository with a working environment, a research log template, and a passing sanity check in both Python and MATLAB. Commit history shows at least 10 meaningful commits.

### Lab Chapter 2: Scientific Python Refresher for Battery Work

**Skill objective:** Solve a battery-flavored ODE in Python with confidence.

#### 2.1-2.7 Topics

1. NumPy patterns you'll use constantly: vectorization, broadcasting, array slicing
2. `scipy.solve_ivp`: choosing solvers (`RK45`, `BDF`, `LSODA`), tolerances, and when each matters
3. Parameter fitting with `scipy.optimize`: least squares, bounds, initial guesses
4. Matplotlib for publication-quality plots: axes, legends, units, color conventions
5. Pandas for time-series battery data: reading CSVs, resampling, indexing by time
6. Worked example: simulating an RC discharge from Textbook Chapter 10
7. Worked example: fitting an RC model to synthetic noisy data

**Deliverable:** A notebook that simulates a second-order RC (Thevenin) equivalent circuit discharge, adds noise, and fits the parameters back. Bonus: wrap it as a reusable function.

## Part II: PyBaMM Fundamentals (Weeks 3-6)

### Lab Chapter 3: Your First PyBaMM Simulation

**Skill objective:** Run, modify, and interpret a built-in DFN simulation.

#### 3.1-3.8 Topics

1. Installing PyBaMM with pinned versions; verifying the install
2. The PyBaMM object hierarchy: model, parameter values, geometry, mesh, solver, simulation
3. Bridge from Textbook Chapter 8: how DFN equations become PyBaMM objects
4. Running a default DFN simulation on a Chen2020 parameter set
5. Accessing and plotting internal variables: concentrations, potentials, overpotentials
6. Interpreting every curve: terminal voltage, SOC, electrolyte concentration, particle concentrations
7. Switching between DFN, SPM, and SPMe: when each is appropriate
8. Comparing the three model fidelities on the same duty cycle

**Reproduction exercise:** Reproduce Figure 3 from Marquis et al. (2019), "An asymptotic derivation of a single particle model with electrolyte," which is the canonical SPMe paper and is fully PyBaMM-compatible.

**Deliverable:** A notebook running all three model fidelities, comparing runtime and accuracy, with a written interpretation of when you'd choose which.

### Lab Chapter 4: Parameters, Experiments, and Drive Cycles

**Skill objective:** Drive PyBaMM simulations with realistic, user-defined conditions.

#### 4.1-4.8 Topics

1. The parameter set as a Python object: inspecting, modifying, saving
2. Replacing functions (OCV curves, diffusion coefficients) with your own
3. The `Experiment` class: defining multi-step protocols (CC, CV, CCCV, rest, pulse)
4. Running a full charge-discharge cycle with proper rest periods
5. Importing real drive cycle data (UDDS, WLTP, US06)
6. Running a drive cycle in PyBaMM and interpreting the results
7. Temperature as an input: isothermal vs thermal coupling
8. Common errors: solver convergence failures, negative concentrations, voltage cutoffs

**Dataset integration:** Download and parse a UDDS current profile; run it through PyBaMM.

**Open-ended exercise:** Design an experiment that emulates a GITT characterization protocol and extract the quasi-OCV from the simulated output.

**Deliverable:** A notebook that runs a realistic drive cycle on a commercial-like cell and produces publication-quality plots of voltage, current, SOC, and internal concentrations.

### Lab Chapter 5: Parameter Estimation in PyBaMM

**Skill objective:** Fit PyBaMM model parameters to experimental data.

#### 5.1-5.8 Topics

1. Why parameter estimation is the hardest part of physics-based modeling
2. Identifiability: which parameters can you actually recover from terminal voltage alone
3. PyBaMM's `ParameterValues` updating workflow inside an optimizer
4. Using `scipy.optimize.least_squares` with a PyBaMM forward model
5. Bayesian alternatives: a brief introduction to PyBaMM-compatible MCMC (if relevant)
6. Practical issues: simulation cost, parallelization, smart initial guesses
7. Sensitivity analysis with PyBaMM's built-in sensitivity module
8. How to report fitted parameters honestly (confidence intervals, sensitivity bounds)

**Reproduction exercise:** Reproduce the parameter identification workflow from a recent PyBaMM paper (choose one from 2023-2025 that explicitly shares its fitted parameters).

**Deliverable:** A working parameter estimation pipeline that takes a CSV of current/voltage data and returns fitted DFN parameters with sensitivity rankings.

## Part III: Equivalent Circuit Modeling and BMS Algorithms in MATLAB (Weeks 7-11)

### Lab Chapter 6: Equivalent Circuit Models from Scratch

**Skill objective:** Build, simulate, and identify ECMs of increasing complexity.

#### 6.1-6.8 Topics

1. Bridge from Textbook Chapter 10: why ECMs dominate BMS work despite DFN being more accurate
2. Rint, Thevenin (1RC), 2RC, and fractional-order models in Simulink
3. Using Simscape Battery's built-in cell blocks
4. Simulating CC, CCCV, and pulse tests
5. Parameter identification from HPPC data: Plett's method
6. Parameter identification from drive cycle data
7. Validating an identified ECM against held-out data
8. The OCV-SOC curve: measurement, smoothing, and differentiation

**Dataset integration:** Use the CALCE battery dataset (specifically the INR 18650-20R HPPC data) to identify an ECM end to end.

**Reproduction exercise:** Reproduce the ECM identification workflow from Plett's *BMS Volume 2*, Chapter 2.

**Deliverable:** A MATLAB script that takes raw HPPC data and returns an identified 2RC model with a validation RMSE report.

### Lab Chapter 7: SOC Estimation with Kalman Filters

**Skill objective:** Implement an Extended Kalman Filter for SOC estimation from scratch.

#### 7.1-7.8 Topics

1. Bridge from Textbook Chapters 10 and the algorithms document: EKF intuition for an EE
2. State-space formulation of the ECM for SOC estimation
3. Linearization: computing Jacobians for the ECM
4. The EKF loop: predict, measure, update
5. Tuning process and measurement noise (the hardest part)
6. UKF as an alternative; sigma-point intuition and implementation
7. Handling voltage sensor bias and current sensor drift
8. Performance metrics: RMSE, max error, convergence time

**Reproduction exercise:** Complete Plett Coursera Course 3's EKF assignment and then reproduce the SOC estimation results from one published *IEEE Transactions on Transportation Electrification* paper that uses EKF.

**Open-ended exercise:** What happens to your EKF when you feed it simulated data from a hard-carbon SIB cell with a flat OCV plateau? Quantify the degradation and propose a fix.

**Deliverable:** A MATLAB implementation of both EKF and UKF for SOC estimation, benchmarked on CALCE data, with a written analysis of which performs better and why.

### Lab Chapter 8: SOH and Aging Models

**Skill objective:** Track battery health over hundreds of cycles using empirical and semi-empirical aging models.

#### 8.1-8.8 Topics

1. Bridge from Textbook Chapter 7: mapping degradation mechanisms to model terms
2. Empirical capacity fade models (square-root-of-time, Arrhenius temperature dependence)
3. Semi-empirical models coupling SEI growth to cycling conditions
4. Implementing an aging model in PyBaMM (it has built-in SEI models)
5. Implementing an aging model in MATLAB/Simulink
6. Long-cycle simulation: computational tricks, time stepping, output management
7. SOH estimation from partial charging curves (ICA/DVA methods)
8. How to handle aging with sparse SIB data

**Dataset integration:** NASA Battery Aging dataset: parse, clean, and use for model validation.

**Reproduction exercise:** Reproduce a capacity fade curve from a recent aging-model paper on either Li-ion or Na-ion cells.

**Deliverable:** An aging model calibrated to NASA data in Python and a parallel implementation in MATLAB, with a comparison of predictions over 500+ cycles.

## Part IV: Thermal, Coupled, and Multi-Physics Work (Weeks 12-14)

### Lab Chapter 9: Thermal Modeling and Electrothermal Coupling

**Skill objective:** Predict cell temperature under realistic duty cycles and couple thermal behavior to electrical models.

#### 9.1-9.8 Topics

1. Bridge from Textbook Chapter 8 (thermal): Bernardi's equation as a PyBaMM/Simulink block
2. Lumped thermal models: writing and solving the energy balance
3. PyBaMM's thermal options: isothermal, lumped, 1D, 2D
4. Coupling thermal to electrochemical: what it means and what it costs
5. Simulink thermal modeling with Simscape thermal components
6. Fast charging under thermal constraints: setting up the optimization problem
7. Low-temperature performance: why SIB wins here and how to quantify it in simulation
8. Introduction to COMSOL Battery Design Module (overview only, deeper dive optional)

**Reproduction exercise:** Reproduce a fast-charging protocol comparison figure from a recent paper.

**Deliverable:** A coupled electrothermal PyBaMM simulation of a CCCV charge under three ambient temperatures, with written interpretation of the tradeoffs observed.

### Lab Chapter 10: Bridging PyBaMM and MATLAB

**Skill objective:** Move data and models between the Python and MATLAB ecosystems fluently.

#### 10.1-10.7 Topics

1. Why you'll need both tools on the same project
2. Exporting PyBaMM simulation results to CSV, HDF5, and MAT formats
3. Calling Python from MATLAB and MATLAB from Python
4. Building a "virtual cell" workflow: DFN in PyBaMM generates synthetic data, ECM identification runs in MATLAB
5. Cross-validation between physics-based and circuit-based models
6. Version control and environment management when a project spans two languages
7. Reproducibility across tools: making sure runs are deterministic

**Deliverable:** A complete virtual-cell workflow. PyBaMM runs a DFN simulation under a drive cycle; the results are exported; MATLAB loads them and identifies an ECM; the ECM is then validated against a held-out PyBaMM run. The whole pipeline runs from one master script.

## Part V: Datasets, Reproduction, and Research Practice (Weeks 15-17)

### Lab Chapter 11: Public Battery Datasets in Depth

**Skill objective:** Find, parse, clean, and use every major public battery dataset competently.

#### 11.1-11.11 Topics

1. The dataset landscape: what's out there and what's missing for SIB
2. CALCE: structure, conventions, quirks
3. NASA Battery Aging: structure, conventions, common pitfalls
4. Oxford Battery Degradation Dataset
5. Stanford/MIT/Toyota (Severson et al.) dataset for fast-charging research
6. Sandia National Labs battery datasets
7. Mendeley Data and Zenodo: how to search, how to evaluate quality
8. The sparse SIB dataset situation: what exists, and how to extract data from published figures using WebPlotDigitizer
9. Arbin and Biologic file formats
10. Data cleaning patterns: handling rest periods, detecting cycles, removing bad segments
11. Building a reusable dataset loader

**Deliverable:** A Python package (one module, properly structured) that provides a unified interface to at least four public datasets with consistent column names and units.

### Lab Chapter 12: The Reproduction Project

**Skill objective:** Reproduce a published simulation paper end to end, the single highest-value exercise in this companion.

#### 12.1-12.9 Topics

1. Why full reproduction is the fastest path to research competence
2. Choosing a reproducible paper: what to look for, what to avoid
3. Reading a paper for reproduction (different from reading for comprehension)
4. Building a reproduction checklist from the paper
5. Handling ambiguity: when the paper doesn't specify something, what do you do
6. Dealing with version drift: tools have changed since the paper was published
7. Getting "close enough": what reproduction tolerance is reasonable
8. Writing up your reproduction: what to document, what to share
9. When reproduction fails: diagnosing whether it's you or the paper

**Main exercise:** Pick one paper from a curated shortlist (the chapter will recommend three or four candidates spanning PyBaMM DFN work, ECM-based state estimation, and aging models) and reproduce it end to end. Document the full process in a research log.

**Deliverable:** A GitHub repository containing a full reproduction of a chosen paper, including the original figures, your reproductions, a log of every deviation and why, and a short write-up of what you learned.

## Part VI: Specialization and Capstone (Weeks 18-20)

### Lab Chapter 13: Specialization Tracks

**Skill objective:** Deepen one or two tool areas that match the research direction you chose from your Run 2 proposals.

This chapter branches into tracks. The reader picks the track(s) matching their shortlisted proposals.

#### 13.1-13.6 Tracks

1. Track A: Advanced state estimation: particle filters, moving horizon estimation, joint estimation of SOC and parameters
2. Track B: Thermal and safety: COMSOL Battery Design Module deep dive, thermal runaway modeling
3. Track C: Data-driven health estimation: PyTorch for LSTM/transformer-based SOH, feature engineering from partial charging curves
4. Track D: Grid storage applications: MATLAB Simscape Electrical, battery-grid interface modeling
5. Track E: EV powertrain integration: Simulink vehicle dynamics, full pack modeling
6. Track F: Fast charging optimization: optimal control formulations, nonlinear MPC

**For each track:** An extended tutorial, a dataset (where applicable), and a reproduction exercise specific to that track.

**Deliverable:** A completed track-specific project with documentation.

### Lab Chapter 14: The Capstone Project

**Skill objective:** Execute a mini research project that integrates everything from this companion and produces a paper-ready artifact.

#### 14.1-14.8 Topics

1. Choosing a capstone scope: small enough to finish, large enough to matter
2. Literature positioning: where does your capstone sit in the existing work
3. Methodology design: what will you simulate, what will you vary, how will you validate
4. Running the study: organized experimentation, not ad-hoc scripting
5. Analyzing results: what counts as a finding
6. Producing publication-quality figures and tables
7. Writing a short technical report in the structure of an IEEE paper (abstract, intro, methods, results, discussion, conclusion)
8. Self-review: checking your own work with the eye of a reviewer

**Capstone deliverables:**

- A GitHub repository with reproducible code
- A short technical report (8-12 pages, IEEE conference format)
- A poster (one-page visual summary)
- A research log documenting every major decision and pivot

The capstone is intentionally modest in ambition; it's not meant to be a real paper, but a full dry run of the research process. If the capstone goes well and the finding is interesting, it may well become a real paper. More often it becomes the foundation for one.

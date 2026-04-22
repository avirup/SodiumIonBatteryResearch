# Chapter 14: The SIB Research Landscape

## Chapter Opening

You have now spent thirteen chapters building a complete physical, chemical, and engineering understanding of battery technology, with sodium-ion batteries as a recurring thread that became the explicit focus in Chapters 6 and 13, and received dedicated SIB-adaptation sections in Chapters 8, 11, and 12. You understand what sodium-ion batteries are, why they exist, how they work physically, how they fail, how they are managed, and exactly where they differ from lithium-ion at every level of the engineering hierarchy. That understanding is the foundation. This chapter is the map of where to go next.

The situation you are entering as a simulation-focused SIB researcher is genuinely unusual. It resembles, more than anything else, the position of researchers who entered lithium-ion battery modelling in approximately 2010–2012. The Doyle-Fuller-Newman model existed (published 1993). The electrochemical fundamentals were understood. A handful of validated parameter sets were available. But the ecosystem of validated degradation models, physics-based BMS algorithms, system-level studies, digital twin frameworks, and grid integration analyses that now constitutes the mature LIB simulation literature — most of that did not exist yet, and the researchers who built it between 2010 and 2020 published prolifically into a receptive and growing field. That is the window you are standing in for SIBs today, with one important advantage over those researchers: you have the entire LIB literature as a methodology library. Every technique that was laboriously developed for lithium-ion over fifteen years is available for you to re-parameterise and re-validate for sodium-ion.

This chapter is organised in three parts. We begin with the past — surveying what has been accomplished in SIB simulation and modelling up through approximately early 2026, and identifying the key papers that defined each sub-domain. We then examine the present — the commercial landscape as it stands, the research groups most actively pushing the frontier, the tools and datasets available to you right now, and the publication venues where SIB simulation work can be published. Finally, and most importantly, we map the future in detail — the specific open problems, the research proposals that address them, and the strategic sequencing advice that will help you build a coherent publication portfolio.

By the end of this chapter you will have a concrete, actionable research plan. You will know which problem to attack first, which dataset to use, which tool to deploy, and which journal to target. The research is waiting.

---

> **Prerequisites Check**
>
> This chapter draws on the entire book and on the uploaded research landscape documents. All chapters are prerequisite. Specifically:
>
> - Chapter 13 (all sections) — the physical differences that motivate every research gap in Part 3 of this chapter
> - Chapters 10–12 — the BMS algorithms whose absence for SIBs defines the largest gap area
> - Chapters 7–8 — the degradation and thermal physics whose SIB parameterisation is almost entirely missing

---

## 14.1 The SIB Modelling Literature: What Has Been Accomplished

### The Scale of the Gap

To understand the research opportunity, you first need to understand the scale of what is missing. A 2025 scientometric review counted 15,682 peer-reviewed SIB papers published from 2000 to 2024 — but the overwhelming majority are materials-science papers: cathode synthesis, anode processing, electrolyte composition, and structural characterisation. The engineering-modelling literature that matches the focus of this book — equivalent circuit models, electrochemical models, thermal models, BMS algorithms, state estimation, degradation prediction, and system-level optimisation — remains much smaller. In practical terms, validated SIB ECM, DFN, and state-estimation papers still number in the dozens rather than the thousands familiar in the Li-ion literature. Most of that engineering-focused SIB work has appeared only since 2021–2022.

This is not a gap that will close quickly by itself. The Chinese research institutions that dominate SIB publication output (Section 14.3) are overwhelmingly focused on materials: cathode synthesis at Hu Yong-Sheng's IOP-CAS group, hard carbon precursor development at Wuhan University and Central South University, PBA chemistry at multiple institutions. The engineering simulation work — ECM parameterisation, state estimation, degradation modelling, pack-level simulation — is what the materials community does not typically produce and what an electrical engineering researcher is specifically positioned to contribute.

### The Foundational Papers: An Annotated History

**2018 — Baseline reviews.** Chayambuka et al. published "Sodium-Ion Battery Materials and Electrochemical Properties Reviewed" in *Advanced Energy Materials*, establishing the first comprehensive survey of SIB electrode materials properties from a modelling-relevant perspective — cataloguing the range of specific capacities, diffusion coefficients, and exchange current densities needed to parameterise any physics-based model.

**2021 — First ECM papers.** Xiang et al. published "Equivalent circuit modeling of sodium-ion batteries" in the *Journal of Energy Storage*, systematically comparing 1RC, 2RC, and 3RC topologies for a 1 Ah pouch SIB cell using Bayesian Information Criterion model selection, finding 3RC optimal. This established the ECM baseline for SIBs, analogous to Chen and Rincón-Mora's 2006 paper for lithium-ion.

**2022 — First validated DFN model.** Chayambuka, Mulder, Danilov, and Notten published "Physics-based modeling of sodium-ion batteries, Part I: Experimental parameter determination" and "Part II: Model and validation" in *Electrochimica Acta*. These two papers represent the inflection point in SIB simulation research. Part I systematically characterised an NVPF/hard-carbon SIB cell to extract the full set of DFN parameters: solid-state diffusion coefficients for both electrodes, electrolyte transport parameters, exchange current densities, and OCV-SOC curves. Part II assembled these into a working P2D model validated against discharge curves at 0.1C to 1.4C with less than 2% voltage error. The resulting parameterisation is now the standard starting point for PyBaMM's sodium-ion DFN example.

**2023 — First IEEE conference paper on SIB ECM.** Rabab et al. published "Equivalent Circuit Model For Sodium-Ion Batteries With Physical-Based Representations Of Their Non-Linearities" at IEEE VPPC 2023 in Milan — the first identifiable SIB simulation paper in any IEEE venue. It presented a modified ECM for the Tiamat NVPF/HC 18650 cell that separated charge transfer, SEI, and diffusion phenomena with Arrhenius temperature dependence for each component. This paper's existence confirms that IEEE conference venues are receptive to SIB simulation work. The following year, Sandri et al. published "Electrical Circuit Model for Sodium-Ion Batteries" at IECON 2024 Chicago, comparing 1RC through 4RC models for SIB accuracy-complexity trade-offs.

**2023 — First SOC estimation paper.** Xiang et al. in the *Journal of Energy Storage* published "A comprehensive study on state-of-charge and state-of-health estimation of sodium-ion batteries," using a PSO-optimised third-order RC model with EKF, UKF, and particle filter comparison. The field of SIB state estimation began with this single paper.

**2024 — Commercial cell characterisation becomes available.** Laufen et al. published "Multi-method characterization of a commercial 1.2 Ah sodium-ion battery cell indicates drop-in potential" in *Cell Reports Physical Science*, with extensive supplementary information including EIS at 21 SOC levels, C-rate testing, and cyclic-aging diagnostics. In the same year, Bischof et al. published "Evaluation of commercial 18650 and 26700 sodium-ion cells and comparison with well-established lithium-ion cells" in *Journal of Power Sources Advances*. These papers transformed SIB simulation from a largely chemistry-level discussion into one grounded in real commercial cell data.

**2024 — PyBaMM and COMSOL make sodium-ion continuum simulation easier to access.** By late 2024, the PyBaMM documentation included a sodium-ion DFN example based on `pybamm.sodium_ion.BasicDFN()` and the Chayambuka/COMSOL parameterisation, while COMSOL provided an official "1D Isothermal Sodium-Ion Battery" application example (Application Library ID: 117341). Together, these two resources made ready-to-run sodium-ion continuum simulation substantially more accessible.

**2025 — The first dedicated SIB DFN/SPMe/SPM comparison paper.** Garapati et al. published "Perspective and comparative analysis of physics-based models for sodium-ion batteries" in *Electrochimica Acta* — a simulation-based comparison of DFN, SPMe, and SPM for SIBs. This paper is important because it shows that simulation-focused SIB modelling work is publishable in a mainstream battery journal and because it frames reduced-order electrochemical modelling for SIBs as a research topic in its own right.

**2025 — Wang et al. open dataset.** The first substantive open SIB cycling dataset was deposited on Zenodo (ID: 13836819), containing pulse characterisation at multiple C-rates and six temperatures (−5°C to 45°C) plus driving cycle validation data for both a 3.2 Ah Transimage cell and a 10 Ah HiNa cell. This dataset is the foundation upon which most current and near-future SIB BMS algorithm papers will be built.

### The Current State in Numbers

As of early 2026, the complete SIB engineering simulation literature can be enumerated in a single table — an exercise that would be absurd for Li-ion, where each row would contain thousands of entries:

| Topic | SIB Papers (approx.) |
| --- | --- |
| Validated ECM papers | 4–5 |
| Fully validated DFN parameter sets | 1 (Chayambuka2022, NVPF/HC) |
| SOC estimation papers | 3–8 (EKF, UKF, PF, LSTM+UKF hybrids) |
| DFN comparison studies | 1 (DFN vs SPMe vs SPM) |
| Simplified electrochemical model papers | 1 |
| Standalone validated SPMe papers | 0 |
| Global sensitivity analyses | 0 |
| Model-order reduction studies | 0 |
| Physics-based degradation models | 1 (2025, calendar ageing only) |
| Cycle-ageing physics-based models | 0 |
| Multi-mechanism degradation models | 0 |
| Thermal runaway kinetics models | 0 |
| Pack-level balancing simulation papers | 0 |
| Grid dispatch optimisation studies | 0 |
| Digital twin frameworks | 0 |

Compare this to the Li-ion simulation literature, which contains tens of thousands of papers in each of these categories. The gap is not a gap — it is an ocean.

**Timeline of SIB Simulation Milestones.** The following diagram summarises the chronological development of SIB engineering simulation. Sketch or recreate this timeline and pin it above your desk — it tells you at a glance which sub-fields have prior art and which are empty.

```text
2018  Chayambuka — modelling-relevant SIB property review (Adv. Energy Mater.)
  |
2021  Xiang — early SIB ECM benchmark (J. Energy Storage), 1RC/2RC/3RC comparison
  |
2022  Chayambuka — validated DFN parameter set, NVPF/HC (Electrochim. Acta)
  |
2023  Rabab — IEEE SIB ECM paper @ VPPC
      Xiang — early SIB SOC/SOH estimation paper (J. Energy Storage)
  |
2024  Laufen — commercial 1.2 Ah 18650 SIB characterisation (Cell Rep. Phys. Sci.)
      Sandri — SIB ECM comparison @ IECON
      PyBaMM docs — sodium-ion DFN example documented
      COMSOL — official 1D Na-ion model example available
      Wang — open SIB pulse/driving-cycle dataset (Zenodo)
  |
2025  Garapati — DFN vs SPMe vs SPM comparison (Electrochim. Acta)
  |
2026  ← YOU ARE HERE
      Every row with "0 papers" in the table above is an open door.
```

---

## 14.2 The Commercial Landscape: What Exists to Model

Modelling and simulation research is only valuable if it models something real. The commercial landscape of sodium-ion batteries as of early-to-mid 2026 provides a growing set of real cells, real packs, and real deployment scenarios to anchor simulation work.

### The Dominant Player: CATL and the Naxtra

CATL's market position in SIB is analogous to their position in LIB: dominant, accelerating, and setting the performance and cost benchmarks against which everything else is measured.

CATL announced its first-generation sodium-ion battery for Chery models in April 2023. On April 21, 2025, CATL unveiled the second-generation **Naxtra**, describing it as the world's first mass-produced sodium-ion battery. CATL's published figures for the passenger-car cell include 175 Wh/kg gravimetric energy density and a claimed cycle life of over 10,000 cycles; for low-temperature performance, CATL emphasises operation from −40°C to +70°C and strong retained power in extreme cold. On February 5, 2026, CATL and CHANGAN announced the world's first mass-production sodium-ion passenger vehicle and said it was scheduled to reach the market in mid-2026.

CATL's "Freevoy Dual-Power Battery" architecture is a direct simulation research opportunity. CATL has explicitly described dual-chemistry pack configurations, including sodium-ion plus LFP. A heterogeneous pack containing cells of different chemistry, different OCV curve shapes, different temperature characteristics, and different ageing rates creates state-estimation and balancing challenges that are genuinely novel and commercially relevant. Think of it as a series string of resistors where each resistor has a different temperature coefficient and a different ageing law — your balancing and estimation algorithms must track each component's individual state, not just the string aggregate. Every BMS technique from Chapters 10–12 must be re-derived for the two-chemistry case.

**For the simulation researcher**: CATL has not released open characterisation data for Naxtra cells. However, the cell's Chinese market specifications (available through Chinese battery industry databases and published technical reports) provide enough boundary conditions for model-building: nominal voltage, capacity, DCIR at multiple temperatures, and cycle life under stated conditions.

### HiNa Battery Technology

HiNa (中科海钠, or China Science Sodium Battery Technology) is the direct academic-to-industry pipeline from IOP-CAS, co-founded by Prof. Hu Yong-Sheng and Academician Chen Liquan. HiNa's GWh-class production line in Fuyang, Anhui Province, began rolling out products in late 2022. The company has also supplied cells to grid-storage demonstrations, including an officially announced 10 MWh project in Guangxi in May 2024 and the 50 MW/100 MWh Datang Hubei installation reported in July 2024.

HiNa publicly lists several commercial sodium-ion formats, including 185 Ah prismatic cells, and reports product-level energy densities roughly spanning 120–165 Wh/kg depending on application. Their copper-containing layered-oxide / hard-carbon chemistry is especially relevant because the Wang Zenodo dataset includes a commercial 10 Ah HiNa cell, giving simulation researchers at least one openly accessible data source anchored to this ecosystem.

HiNa's heavy-truck and grid-storage applications represent compelling system-level case studies for efficiency and dispatch modelling.

### Tiamat Energy

Tiamat occupies a unique niche in the SIB landscape: a high-power, high-voltage commercial sodium-ion platform based on NVPF (Na₃V₂(PO₄)₂F₃) cathodes and hard-carbon anodes. Tiamat's current cylindrical datasheet reports a 3.7 V nominal, 1 Ah, 3.5 Wh 18650 cell with 15 mΩ AC internal resistance at 1 kHz and peak discharge current up to 35 A. In the peer-reviewed literature, related Tiamat NVPF/HC cells have demonstrated very strong high-rate behaviour and multi-thousand-cycle life.

For the simulation researcher, Tiamat's ecosystem is uniquely attractive: the Chayambuka NVPF/HC parameterisation gives a starting point for physics-based modelling, the Tiamat datasheets provide commercial boundary conditions, and later peer-reviewed Tiamat work reports high-power performance up to 20C discharge with improved cycle life in newer generations. This makes Tiamat an especially good candidate for high-power application modelling such as frequency regulation, power tools, and fast-charge studies.

### The Western Landscape: Setbacks and Survivors

The Western commercial SIB landscape has experienced significant turbulence. **Natron Energy** reached commercial-scale sodium-ion production in the U.S. in 2024 and marketed UL-listed products, but by September 2025 the company had announced that it had ceased operations. **Northvolt** filed for Chapter 11 protection in the U.S. in November 2024 and entered Swedish bankruptcy in March 2025; Lyten announced in August 2025 that it would acquire Northvolt's remaining assets and IP. **Bedrock Materials**, a Stanford spinout working on sodium-ion cathode materials, halted development in April 2025.

**Peak Energy** is the sole remaining major US SIB commercial player, having secured a $500 million deployment deal with Jupiter Power for 4.75 GWh of grid storage through 2030 — the first large-scale US grid-scale SIB deployment. Their NFPP (Na₄Fe₃(PO₄)₂(P₂O₇)) cathode chemistry claims 30% less degradation than LFP in grid storage applications. In Europe, **Tiamat** and **Altris** (Sweden, developing Prussian white cathode with bio-derived hard carbon in a partnership with Clarios) continue to advance toward commercialisation. **Faradion** (now part of Reliance Industries India) is targeting the Indian two- and three-wheeler EV market and residential storage, with a Jamnagar gigafactory planned.

### Commercial Status Summary Table

| Company | Country | Cathode | Anode | Wh/kg | Cycle Life | Form Factor | Primary Application | Status (early 2026) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CATL (Naxtra) | China | Layered oxide family | Hard carbon | 175 | >10,000 (claimed) | Automotive cells / packs | EV, grid storage | Mass-production launch announced |
| HiNa | China | Cu-containing layered oxide | Hard carbon | 120–165 (company-stated range) | Product-dependent; 185 Ah ESS cell listed at >=6000 | Prismatic | Grid storage, vehicles | GWh-scale production and deployments |
| Tiamat | France | NVPF | Hard carbon | 105 | Multi-thousand-cycle, product-dependent | 18650 cylindrical, prismatic | High-power applications | Commercialized cells, gigafactory planned |
| Peak Energy | USA | NFPP | Undisclosed | Not publicly disclosed | Not publicly disclosed | Grid-scale ESS format | Grid storage | Early commercial agreements announced |
| Altris | Sweden | Prussian white | Hard carbon | 160 | Not publicly disclosed | Commercial-sized cell | Grid storage, low-voltage mobility partnerships | Pilot / partnership stage |
| Faradion / Reliance | UK/India | Layered oxide family | Hard carbon | Not publicly fixed | Not publicly fixed | Technology platform | Storage, two/three-wheelers, mobility | Reliance-owned, Jamnagar manufacturing plans announced |

---

## 14.3 The Research Ecosystem: Groups, Institutions, and the Chinese Factor

### Chinese Research Dominance: Understanding the Context

No serious engagement with the SIB research literature is possible without confronting the scale of Chinese research dominance. Scientometric work through 2024 shows China as the dominant contributor to SIB publications, and the present commercial build-out of sodium-ion manufacturing is also heavily China-centred. For an EE researcher in India or elsewhere, the practical implication is twofold: the literature you must engage with is predominantly Chinese in origin, and the industrial momentum is also concentrated there.

For an EE researcher in India or elsewhere, the practical implication is twofold. First, the literature you must engage with is predominantly Chinese in origin. Many of the most important recent results are published in Chinese-language journals (particularly *Energy Storage Science and Technology*, 储能科学与技术) or in English-language journals with Chinese first authors and Chinese institutional affiliations. Second, and more strategically important: Chinese research dominance in SIB is concentrated in materials science. The system-level engineering simulation work — ECM parameterisation, BMS algorithm development, pack-level degradation modelling, grid integration — is not where Chinese groups are primarily publishing. This is exactly the gap that an EE researcher is positioned to fill, and it is a gap that will remain open for several years even as materials research saturates.

### The Key Groups

**IOP-CAS, Beijing (Prof. Hu Yong-Sheng)**: The single most influential SIB research group globally. Hu's group bridges fundamental materials discovery with commercialisation through HiNa Battery and is central to the modern Chinese sodium-ion ecosystem.

**ICCAS, Beijing (Prof. Guo Yuguo)**: Electrolyte innovations and interface engineering, especially relevant to studies that include electrolyte transport and interphase physics.

**Wuhan University (Prof. Cao Yuliang)**: Polyanionic cathodes, tunnel-type oxides, and hard-carbon anodes, with strong links between academic work and commercial cathode/anode development.

**USTC, Hefei (Prof. Yu Yan)**: A prolific group spanning PBA cathodes, sodium-metal concepts, and data-assisted materials screening.

**Tsinghua University (Prof. Zhang Qiang)**: Solid-state electrolytes and battery safety, directly relevant to future thermal and abuse-modelling work.

**Key non-Chinese groups**: The **Dahn group** at Dalhousie University (Canada) brings its systematic multi-cell cycling methodology to SIBs, particularly for P2-type layered oxides. The **Grey group** at Cambridge contributes operando NMR characterisation that clarifies hard carbon storage mechanisms. The **Tapia-Ruiz group** (Lancaster/Imperial, UK) focuses on layered oxide structure-property relationships. The **Chayambuka group** (formerly TU/Eindhoven) produced the foundational DFN model that anchors the simulation literature. **Tiamat Energy** itself has published extensively through Rabab et al. on NVPF ECM characterisation.

### Navigating the Chinese Research Literature: A Practical Guide

If you have never searched a Chinese academic database, the prospect can feel daunting. Here is a minimal practical toolkit. **CNKI** (cnki.net, also accessible via oversea.cnki.net for non-Chinese institutions) is the dominant Chinese academic database, analogous to Web of Science for Chinese-language publications. Search in English — CNKI indexes English titles and abstracts for most papers, even those published in Chinese-language journals. For papers published only in Chinese, Google Translate and DeepL produce readable translations of abstracts and figure captions, which is usually sufficient to determine whether a paper's data or methodology is relevant to your simulation work.

**Google Scholar** indexes most Chinese SIB publications that have English-language abstracts, so your first search tool remains familiar. When you find a relevant Chinese-authored paper on Scholar, check whether it cites or is cited by Chinese-language papers that Scholar does not index — those are the papers to look up on CNKI.

**Institutional repositories** at IOP-CAS (iop.cas.cn), Wuhan University, and USTC host preprints and supplementary data. HiNa's technical publications are sometimes available through Chinese battery industry portals. For the most recent commercial SIB specifications and industry news, **GaogongLithium** (gg-lb.com) and **SPIR Energy** (spir-energy.com) provide Chinese battery industry analysis with some English-language coverage.

The key message: do not avoid Chinese-authored literature because of the language barrier. The data in Chinese SIB papers — OCV curves, cycle life plots, EIS spectra, DSC traces — is language-independent, and these data are exactly what you need for simulation parameterisation.

---

## 14.4 Simulation Tools: The Complete Arsenal

Every tool you need for publishable SIB simulation research is available right now, most of it open-source. This section describes each tool, its SIB readiness, and what it is good for.

### PyBaMM: The Primary Tool

**PyBaMM** (Python Battery Mathematical Modelling) is an open-source Python framework developed primarily at Oxford and now maintained by the PyBaMM team. It implements DFN, SPM, SPMe, and multiple degradation models for battery simulation. Current PyBaMM documentation includes a working sodium-ion DFN model via `pybamm.sodium_ion.BasicDFN()`, an official sodium-ion example notebook, and parameter values derived from the Chayambuka/COMSOL sodium-ion implementation. The same framework also supports electrochemical-thermal coupling, with SIB-specific parameterisation left to the user when the literature provides the needed values. PyBOP integrates naturally with this workflow for parameter optimisation.

PyBaMM is the right tool for DFN and SPMe simulation, sensitivity analysis, model order reduction comparisons, and degradation model development. Its Python ecosystem makes it compatible with machine learning libraries (scikit-learn, PyTorch, TensorFlow) for hybrid physics-ML approaches. The PyBaMM Discourse forum and GitHub repository are active, and sodium-ion questions receive responses.

A minimal script to run the SIB DFN model. Verify the exact API against the current PyBaMM documentation at `docs.pybamm.org`, as class names and module paths may change between versions:

```python
import pybamm

model = pybamm.sodium_ion.BasicDFN()
param = pybamm.ParameterValues("Chayambuka2022")
sim = pybamm.Simulation(model, parameter_values=param)
sol = sim.solve([0, 3600])  # 1-hour discharge
sim.plot()
```

On a typical laptop this can run in seconds to tens of seconds and produces terminal voltage, electrolyte concentration profiles, solid-phase concentrations, and overpotential decompositions. It is the starting point for essentially all physics-based SIB simulation research.

### COMSOL Multiphysics

COMSOL's Battery Design Module provides a downloadable "1D Isothermal Sodium-Ion Battery" model (Application Library path: `Battery_Design_Module/Batteries,_SodiumIon/sodium_ion_battery_1d`) using the same Chayambuka2022 parameters. COMSOL's advantage over PyBaMM is multi-physics coupling: 3D geometry, mechanical stress, complex thermal boundary conditions, and full Navier-Stokes electrolyte flow (for flow battery extensions). For 2D or 3D mechanical abuse simulations, nail penetration modelling, or thermal runaway propagation in three-dimensional pack geometries, COMSOL is the appropriate tool.

A COMSOL webinar series specifically addressing sodium-ion batteries and "emerging battery technologies" is available through COMSOL's learning centre. Contact resistance modelling was added in COMSOL 6.2.

### MATLAB/Simulink with Simscape Battery

MATLAB remains the dominant tool for BMS algorithm development — Kalman filters, extended Kalman filters, sigma-point Kalman filters, recursive least squares parameter identification, and equivalent circuit model simulation are all most naturally implemented in MATLAB. Plett's three-volume *Battery Management Systems* textbook (specifically Volumes I and II for ECM methods, Volume III for physics-based methods) provides MATLAB code for every algorithm developed in Chapters 10–12 of this textbook. The Coursera specialisation "Algorithms for Battery Management Systems" by Plett delivers hands-on MATLAB implementations of these algorithms.

MATLAB's Simscape Battery module provides a physics-based battery simulation environment suitable for pack-level electro-thermal simulation. It is chemistry-agnostic at the systems level and can be parameterised for SIBs using published characterisation data. The primary limitation is that it does not have a native SIB parameter set — parameterisation requires extracting values from the published literature and entering them manually.

### Other Tools

**LIONSIMBA** (Lithium-Ion Simulation BAttery toolbox) is an open-source MATLAB P2D finite-volume implementation whose clean numerical structure makes it a useful benchmark and algorithmic reference, even though it was developed for Li-ion. The equations are structurally identical for SIBs; parameter substitution is the only change required.

**BattMo** (Battery Modelling Toolbox) is an MRST-based open-source continuum modelling stack supporting 1D through 3D electrochemical-thermal models with automatic differentiation for sensitivity analysis and optimisation. It is actively developed and accepts contributions. Its public material is still centred mainly on Li-ion workflows, but it is a promising extensible framework for researchers who want more direct control over continuum-model implementations.

**PyBOP** (Python Battery Optimisation) is an open-source Python package for battery model parameter identification using deterministic and stochastic optimisation methods, including Bayesian parameter estimation. It interfaces directly with PyBaMM and enables publishable parameterisation pipelines with full uncertainty quantification.

### The Simulation Workflow

The recommended workflow for a simulation-first SIB paper follows a natural progression that mirrors the structure of the eventual paper itself. You begin by identifying a published SIB dataset from Section 14.5, or by using PyBaMM's synthetic data generation capability if no suitable experimental data exists. If your parameterisation requires data from published figures rather than raw numerical files, you digitise those curves using **WebPlotDigitizer** (automeris.io) — a step that many simulation researchers overlook but that is standard practice and methodologically accepted.

With data in hand, you build or adapt the model: PyBaMM for DFN or SPMe physics-based models, MATLAB for ECM-based BMS work. Parameter identification follows, using PyBOP's Bayesian estimation for PyBaMM models or MATLAB's `lsqcurvefit` for ECMs. The critical methodological discipline is to validate against held-out data — different temperatures, different C-rates, or different ageing states than those used for identification. A model validated only on its training data is not publishable.

With a validated model, you generate the publishable result: SOC estimation accuracy metrics, model-order comparison figures, degradation predictions, or thermal behaviour characterisation. Finally — and this step disproportionately increases citation impact — you document the code and upload it to GitHub or Zenodo with a CC BY licence. In a nascent field like SIB simulation, open-source code is not just good practice; it is the mechanism by which your work becomes the foundation that later researchers build on.

---

## 14.5 Open Datasets: What Is Available and How to Use It

SIB datasets are scarce compared to Li-ion. By early 2026, only a small number of openly accessible SIB experimental datasets were easy to identify, compared with the much larger open Li-ion ecosystem. This scarcity is both a challenge and an opportunity: the scarcity is itself a publishable observation, and strategies for working around it constitute part of any simulation paper's methodological contribution.

### SIB-Specific Datasets

**Wang et al. 2024 — Zenodo 13836819**: The single most valuable open SIB dataset, deposited in late 2024. Contains pulse characterisation at 0.25C–3C current rates and six temperatures (−5°C to 45°C) covering the full SOC range (0%–100% in 10% increments), plus FUDS, UDDS, and DST driving cycle data, for two commercial SIB cells: a **Transimage 3.2 Ah** layered oxide/hard carbon cell and a **HiNa 10 Ah** layered oxide/hard carbon cell. Six cell samples per type. Total data size approximately 256 MB. Licence: CC BY 4.0. This dataset is the primary target for any SIB SOC estimation paper, ECM parameterisation study, or temperature-dependent modelling work. If you do one thing before your first SIB simulation paper, download and explore this dataset.

**BatteryLife NaIon Subset — Zenodo 14934405**: Part of a large 998-cell multi-chemistry cycling dataset (from the KDD 2025 competition), including 18650 cylindrical SIB cells (Zhuhai Punashidai cells at 2C–6C cycling rates, 2.0–4.0 V window, 25°C). Best used for battery lifetime prediction and cross-chemistry transfer learning.

**Iontech SIB Characterisation — GitHub**: An open-source comparative characterisation dataset containing two commercial layered oxide/HC SIB cells alongside an LFP reference cell. Includes OCV curves, galvanostatic EIS at multiple SOC levels, DC resistance tests, and rate capability curves. Well-suited for ECM parameterisation and impedance modelling, and for the SIB-vs-LIB comparison that gives any SIB paper its context.

**Laufen et al. 2024 — Cell Reports Physical Science (OA)**: A detailed characterisation of a commercial 1.2 Ah 18650 sodium-ion cell, including EIS at 21 SOC levels, C-rate tests (0.1C to 5C), cyclic ageing with micro-CT imaging, and electrode porosity/thickness measurements from post-mortem physical analysis. The supplementary files provide numbers directly usable for ECM and DFN parameterisation. Licence: CC BY 4.0.

**Droese et al. 2025 — depositonce.tu-berlin.de**: A recent dataset that includes HPPC tests, OCV measurements, and checkup capacity measurements across multiple temperatures for a commercial SIB cell alongside LIB baselines. This is particularly well-suited for ECM fitting (extracting $R_0$, $R_1$, $C_1$, $R_2$, $C_2$ as functions of SOC and temperature) and for temperature-dependent thermal modelling.

### Li-Ion Datasets for Methodology Transfer

Because SIB datasets are scarce, a common and methodologically defensible approach is to develop and validate algorithms on well-characterised Li-ion datasets first, then demonstrate transferability to SIBs using the available SIB data. This "develop on Li-ion, transfer to Na-ion" approach has been explicitly validated: PyBaMM confirms that the DFN model structure — the coupled PDE system for solid-phase diffusion, electrolyte transport, and Butler-Volmer kinetics — is mathematically identical for Li-ion and Na-ion, with different parameter values. The important caveat is that the standard DFN assumes a single intercalation mechanism in each electrode, which is a good approximation for graphite but only partially captures hard carbon's two-mechanism storage (intercalation in the slope region and pore-filling in the plateau region, as discussed in Chapter 13). For the purposes of methodology transfer — developing algorithms, testing estimation frameworks, benchmarking model-order reduction — the structural identity holds. For precision parameterisation of the hard carbon anode, more detailed models may eventually be needed. The Laufen et al. paper explicitly states that LIB characterisation methods transfer to SIBs.

The most valuable Li-ion datasets for this transfer learning approach:

**Severson et al. (Stanford/MIT/Toyota)** — data.matr.io/1: 124 LFP/graphite cells, 72 fast-charging protocols, 4C discharge, 30°C. The richest single dataset for machine learning lifetime prediction; features extracted from early cycles predict long-term cycle life. Pre-training a degradation model on this dataset before fine-tuning on the limited SIB data is one of the most productive transfer-learning strategies available.

**228-cell NMC Ageing Dataset** — Nature Scientific Data 2024 (LG INR18650HG2): 228 cells under 76 conditions, covering calendar ageing, cyclic ageing, and drive-cycle ageing at 0–40°C with 2-second resolution. The most comprehensive single aging dataset available; ideal for pre-training degradation models before adaptation to SIBs.

**CALCE** (University of Maryland) — calce.umd.edu/battery-data: 100+ cells across LCO, LFP, NMC; partial cycling, storage ageing at −40°C to 50°C, OCV tests. Best for SOH estimation methodology development.

**NASA PCoE** — NASA data portal: ~34 Li-ion 18650 cells at 4/24/43°C, with EIS. Classic RUL prediction benchmark; ECM structure transfers directly to SIBs.

### Synthetic Data from PyBaMM

When experimental data is unavailable, PyBaMM's `Chayambuka2022` DFN model can generate physically consistent synthetic SIB data for any C-rate, temperature profile, or ageing scenario. This approach — using a validated physics-based model to generate synthetic training and validation data — is accepted in JES, Electrochimica Acta, Batteries, and Journal of Energy Storage when the synthetic data generation process is transparent and the model is properly cited. The Garapati et al. paper shows how this style of simulation-only comparison can be positioned in a mainstream battery journal.

---

## 14.6 Publication Venues: Where to Publish SIB Simulation Work

Not all journals welcome simulation-only battery papers, and the publication strategy for a researcher with no wet-lab access must be calibrated carefully. The table below summarises the key venues, their practical fit, and the kinds of SIB-oriented papers they are most likely to welcome. Because journal metrics and editorial priorities change, always re-check current aims, scope, and recent articles before submission.

| Venue | Simulation-Only Work? | SIB-Relevant Track Record | Best EE Angle |
| --- | --- | --- | --- |
| IEEE Trans. Smart Grid | Yes | Battery-storage and dispatch papers; little visible SIB-specific history | Microgrid integration, dispatch optimisation |
| IEEE Access | Yes | Broad battery-management coverage | ECM/SOC algorithms for SIB |
| IEEE Trans. Transportation Electrification | Possible | EV BMS and electrified transport | SIB BMS for EVs |
| IEEE Trans. Industrial Electronics | Limited | Strong BMS tradition, but often prefers stronger validation | Estimation/control with solid validation |
| Journal of Energy Storage | Yes | Multiple SIB ECM/SOC papers | ECM, SOC/SOH, BMS |
| Applied Energy | Yes | Techno-economic and system-level battery work | Grid integration, system-level simulation |
| eTransportation | Yes | EV thermal/BMS modelling, emerging SIB relevance | EV thermal/BMS modelling |
| Journal of Power Sources | Conditional | Battery modelling papers including SIB references | Validated P2D/ECM |
| Journal of The Electrochemical Society | Yes | Electrochemical-model and parameterisation papers | P2D, SPM, electrochemical modelling |
| Electrochimica Acta | Yes | SIB DFN/SPMe comparison already published | Physics-based model comparison |
| Batteries | Yes | SIB BMS/SOC papers already present | BMS, SOC, thermal, general modelling |
| Energies | Yes | Power-engineering and storage-system papers | System-level, grid, power engineering |

The most simulation-friendly venues for EE SIB work are **Journal of Energy Storage**, **Applied Energy**, and **Electrochimica Acta**. **IEEE Transactions on Smart Grid** is especially attractive for grid-integration work because the SIB literature there still appears sparse.

For conference publications to build a track record, **IEEE VPPC**, **IECON**, and **ITEC** are reasonable targets because they already accept simulation-heavy battery papers and at least some SIB-related work has appeared in adjacent themes.

**Batteries** deserves special mention for early-career researchers because it has already published SIB BMS papers and is structurally friendly to modelling papers that are carefully validated.

**Journals to avoid for EE simulation work**: materials-dominant venues such as *Journal of Energy Chemistry*, *Energy Storage Materials*, and *Nano Energy* are usually a poor fit for simulation-only engineering papers unless the modelling is tightly integrated with new experimental electrochemistry.

### Practical Submission Advice for Simulation-Only Papers

Three mistakes sink simulation-only battery papers at the review stage, and all three are avoidable. First, failing to validate against experimental data. Even if your entire simulation uses synthetic data from PyBaMM, you must demonstrate that the underlying model (which generated the synthetic data) has been validated against real experimental measurements — cite the Chayambuka validation or closely related commercial-cell validation papers. A simulation paper with no connection to experimental reality will struggle at most venues.

Second, omitting sensitivity analysis. Reviewers of simulation papers invariably ask "how sensitive are your results to parameter uncertainty?" If you have not performed at least a local sensitivity analysis (and ideally a global one using Sobol indices — see Proposal 6), you will receive a major revision request. Build sensitivity analysis into your methodology from the start.

Third, framing the paper as a Li-ion methods paper that happens to use SIB parameters. Reviewers want to see SIB-specific insight: what is different about this problem for sodium-ion? What fails, what works better, what requires modification? If your paper's contribution would be identical for any battery chemistry, it is a methods paper, not an SIB paper — and the venue selection and framing must reflect that distinction.

---

## 14.7 The Research Gaps: Thirteen Areas Where SIB Simulation Is Empty

This section maps the thirteen most important research gaps in SIB simulation, ordered roughly from most-urgent to most-ambitious. Each gap description establishes the current state of the literature, identifies the Li-ion analogue that has not been ported, and characterises the contribution an EE simulation researcher can make. These gaps are a practical synthesis of the literature reviewed through April 2026; read statements such as "no paper" or "no framework" as meaning that I did not identify a clearly established SIB literature base in that area, not as a proof that every possible paper worldwide has been exhausted.

### Gap 1: SOC/SOH Estimation — Algorithm Breadth Is Missing

Only six to eight papers address SIB SOC estimation as of early 2026, covering EKF, UKF, adaptive UKF, particle filter, LSTM+UKF hybrid, GRU+AUKF, and one fractional-order variant. Methods that have never been applied to SIBs include: sliding mode observer, H-infinity filter, cubature Kalman filter, moving horizon estimation, physics-based Luenberger observer, formal observability analysis (observability Gramian computation), and Transformer-based deep learning architectures for SOC.

A crucial positive fact for SIB SOC estimation — noted explicitly in published commercial cell characterisation studies (e.g., Laufen et al. 2024; Bischof et al. 2024, KIT) — is that SIB layered oxide/hard carbon cells exhibit a **more monotonic and sloped** OCV curve than LFP. These studies confirm that the steepness of the quasi-OCV curve enables conventional diagnostic methods that rely on mapping OCV to SOC, an essential advantage over LFP/C cells. Higher $dE_\text{OCV}/d\text{SOC}$ means better Kalman filter observability (larger $\mathbf{C}_{11}$ element, as derived in Chapter 10), faster convergence, and less SOC uncertainty from voltage measurement. The one caveat — hard carbon's plateau region near 0 V vs. Na/Na⁺, typically responsible for 20–40% of total capacity — creates a band of reduced observability exactly as analysed in Chapters 10 and 13. This means SIB SOC estimation is easier than LFP estimation (for most of the SOC range) but harder in the plateau region. This duality is a natural research framing: demonstrate the advantage, characterise the limitation, propose and evaluate a solution.

### Gap 2: ECM Parameter Database — No Open Repository Exists

The Li-ion community has extensive open ECM parameter databases: LG M50 on Zenodo, Panasonic 18650 via CALCE, Samsung INR through multiple published papers. The SIB community has none. Every SIB modelling group must start from scratch with parameterisation.

The existing SIB ECM literature (Xiang 2021, Rabab 2023, Jiao 2025) has not produced publicly deposited parameter tables in machine-readable format. No hysteresis ECM exists for SIB (despite hard carbon exhibiting well-documented OCV hysteresis in the plateau region). No coupled electro-thermal ECM exists. No calendar-ageing-dependent ECM exists. No systematic comparison across chemistries (layered oxide vs PBA vs NVPF) has been published.

### Gap 3: DFN Parameter Sets — Only One Validated Set Exists

The Chayambuka2022 NVPF/HC parameter set is the only fully validated DFN parameter set for SIBs in PyBaMM. There is no validated parameter set for the more commercially important O3 layered oxide/HC chemistry (which accounts for the majority of commercial SIB cells from CATL, HiNa, and Faradion). There is no validated parameter set for PBA/HC chemistry. There is no standalone validated SPMe. There is no global sensitivity analysis. There are no systematic model-order reduction studies.

### Gap 4: Thermal Modelling and Runaway Kinetics

Experimental SIB thermal safety data is now substantial (Section 14.1), but no computational thermal model has been built to match it. No Arrhenius-based thermal runaway kinetics model has been parameterised for SIB materials (comparable to Hatchard 2001, Spotnitz & Franklin 2003, or Feng 2018 for Li-ion). No validated numerical thermal runaway propagation model exists for SIB packs. The Bernardi heat generation equation has been adapted for SIBs conceptually (Chapter 8) but no paper has published SIB-specific entropy coefficient $\partial E/\partial T$ measurements across the full SOC range. Overcharge simulation and external short-circuit thermal modelling are absent.

### Gap 5: Physics-Based Degradation Modelling

The first physics-based SIB degradation model appeared only in 2025 (calendar ageing, SEI growth), and it modelled only the SEI contribution. No cycle-ageing physics-based model exists. No multi-mechanism model addresses the O3→P3 phase transition fatigue identified in Chapter 13. No PBA-specific degradation mechanisms (water release, vacancy evolution) have been modelled. No particle-cracking model for hard carbon exists. The hard carbon structural evolution with cycling — the gradual graphitisation that changes OCV shape and $D_s$ over thousands of cycles — has not been modelled at all.

### Gap 6: System-Level BMS — Balancing, Power Limits, Diagnostics

I did not identify an established SIB literature on cell balancing simulation (passive or active), incremental-capacity diagnostics, or formal SIB-focused FMEA. Likewise, I did not find a widely cited power-limit framework adapted to SIB's higher DCIR and different temperature characteristics. The CATL "Freevoy" hybrid SIB+LFP pack concept — which requires a BMS that manages two chemistries with different OCV curves, different temperature responses, and different ageing rates simultaneously — still appears essentially untouched in the open simulation literature.

### Gap 7: Grid Integration and Energy Management

SIB cost and performance advantages (lower material cost, better low-temperature performance, wide operating temperature range, potential for 0 V discharge for transport) create distinct grid-storage use cases that still appear thinly modelled. I did not identify a mature SIB-specific literature on dispatch optimisation, degradation-aware energy management, or lifetime cost modelling that properly accounts for SIB's cycle-life advantage relative to LFP.

### Gap 8: Fast Charging Optimisation

Commercial announcements from CATL and Tiamat both emphasise fast charging or high-power operation. Fast charging is therefore one of SIB's differentiating advantages over LFP, but I did not identify a mature literature on SIB-specific model-predictive charging. The constraint structure for SIB fast charging differs from Li-ion: the primary hard constraint is the sodium-plating onset (anode potential approaching 0 V vs. Na/Na+), which depends on temperature, SOC, and the hard carbon's two-mechanism storage. An MPC framework that explicitly uses the DFN model to enforce the plating constraint while maximising charging speed would therefore be both novel and commercially relevant.

### Gap 9: Low-Temperature Performance Modelling

SIB's low-temperature advantage is real and well-documented experimentally, but I did not identify a mature computational literature that explains it systematically through the Butler-Volmer framework. The activation-energy difference between carbonate-electrolyte SIBs (little advantage) and ether-electrolyte SIBs (substantially smaller low-temperature charge-transfer penalty) also appears under-parameterised in DFN and ECM studies.

### Gap 10: Hybrid and Second-Life Applications

CATL has publicly described hybrid SIB+LFP pack architectures, but this heterogeneous-chemistry problem still appears essentially unmodelled in the open simulation literature. I also did not identify a clear techno-economic or simulation literature on second-life SIB applications. A careful second-life SIB analysis would therefore be among the first papers in this area.

### Gap 11: Machine Learning and Data-Driven Approaches

I did not identify established SIB papers using Transformer-based SOH estimation, chemistry-transfer learning for degradation modelling, PINN-based state estimation, or Gaussian-process RUL prediction. That makes this entire family of methods unusually open compared with Li-ion.

### Gap 12: Digital Twins

I did not identify a mature, openly documented SIB digital-twin framework. A digital twin — a continuously updated simulation model whose parameters evolve with measured cell behaviour in real time — requires the combination of ECM or DFN modelling, Kalman filter-based parameter identification, and connection to real-time sensor data. For Li-ion, digital twins are already a live industrial topic. For SIB, an early paper that clearly proposes and demonstrates a digital-twin architecture (even using synthetic data from PyBaMM to represent the "real" cell) could become a defining reference in this space.

### Gap 13: Sodium Plating — Onset Prediction and Prevention

The threshold conditions for sodium plating on hard carbon anodes — as a function of C-rate, temperature, and SOC — have not been characterised in a simulation model. Chapter 13 established that the driving force for plating (anode potential near 0 V vs. Na/Na⁺) is always present near the top of charge in SIB cells, and that the margin against plating is smaller than for graphite in LIBs. A simulation model that predicts the onset of sodium plating using DFN or SPMe with Butler-Volmer kinetics, calibrated against published experimental observations of plating (voltage plateau on discharge, CE reduction), and used to derive safe fast-charging limits — this is both technically achievable and commercially important.

---

## 14.8 Twenty-Five Research Proposals

The following proposals translate the thirteen gap areas into concrete, actionable research projects. They are classified by difficulty, estimated time to first submission, target venue tier, and hardware requirement. The Tier definitions are: Tier 1 = high-impact (Applied Energy, eTransportation, J. Power Sources, IEEE Trans. Smart Grid, JES, Electrochimica Acta); Tier 2 = solid mid-range (J. Energy Storage, IEEE TTE); Tier 3 = accessible (IEEE Access, Batteries MDPI, Energies MDPI).

### Fast Track (3–6 months, Tier 2–3, no hardware needed)

**Proposal 1: Kalman Filter Benchmark for SIB SOC Estimation**
Implement and compare EKF, UKF, SRUKF, and AEKF (Adaptive EKF) on the same two-RC ECM parameterised from the Wang et al. 2024 Zenodo SIB dataset. Evaluate SOC accuracy (RMSE, MAE) at three temperatures (−5°C, 25°C, 45°C) and three driving profiles (FUDS, UDDS, DST). The SIB-specific contribution: quantify the observability improvement relative to LFP cells using the observability Gramian framework. Target: **IEEE Access** or **Batteries**. This is the most straightforward first SIB paper for an EE with MATLAB skills.

**Proposal 2: Sliding Mode Observer for SIB**
Implement a sliding mode observer (SMO) for SIB SOC estimation — a method widely used for Li-ion robustness that has never been applied to SIBs. Use the Wang et al. Zenodo dataset for validation. The SMO's insensitivity to parameter uncertainty makes it attractive for SIBs where the ECM parameters are less well-characterised than for Li-ion. Compare against EKF from Proposal 1. Target: **Journal of Energy Storage**.

**Proposal 3: Open-Source SIB ECM Parameter Database**
Build and publicly deposit a structured ECM parameter database for 2–3 commercial SIB cells using the Wang et al., Laufen et al., and Droese et al. datasets for parameterisation. Include temperature-dependent $R_0$, $R_1$, $C_1$, $R_2$, $C_2$ across 5 temperatures and 10 SOC levels, OCV-SOC curves for both charge and discharge directions, and Arrhenius fits for the temperature dependence. Deposit on Zenodo with CC BY 4.0. Publish in **Data in Brief** (Elsevier, fast turnaround for data papers) or **Batteries MDPI** with a companion methodology paper. This paper fills the single most cited gap in SIB simulation: the absence of publicly available parameterised models.

**Proposal 4: Fractional-Order ECM vs Integer-Order Comparison for SIB**
Implement a fractional-order impedance element (constant phase element, CPE) alongside standard integer-order RC models and compare accuracy-complexity trade-offs for the SIB cell characterised in the Laufen et al. (2024) dataset (which includes full EIS at 21 SOC levels, making it ideal for fractional-order model identification). Jiao et al. (2025) published the first fractional-order SIB ECM — your contribution is the systematic comparison and the explicit connection to the EIS-derived parameters. Target: **Energies MDPI** or **Batteries MDPI**.

### Medium Track (5–8 months, Tier 1–2, no hardware needed)

**Proposal 5: Formal Observability Analysis of SIB vs LFP vs NMC**
Derive the analytical expression for the observability Gramian of the two-RC ECM as a function of the OCV slope $dE_\text{OCV}/d\text{SOC}$. Compute and plot the observability Gramian eigenvalue as a function of SOC for three cell chemistries (SIB layered oxide/HC, LFP/graphite, NMC/graphite) using published OCV curves. Quantify the observability advantage of SIB over LFP throughout most of the SOC range, and the observability reduction in the SIB plateau. Propose the optimal SOC windows for voltage-based recalibration in each chemistry. Pure analytical work — no datasets required. Target: **IEEE Trans. Transportation Electrification**.

**Proposal 6: Global Sensitivity Analysis of the SIB DFN Parameter Set**
Perform a Sobol indices global sensitivity analysis on the Chayambuka2022 DFN parameter set using PyBaMM. Identify which parameters most influence terminal voltage prediction accuracy, capacity utilisation, and thermal behaviour. Compare the sensitivity rankings for SIBs against published Li-ion sensitivity analyses (which show electrolyte diffusion coefficient and electrode particle radius as dominant at high C-rates). The SIB-specific result — different rankings from the hard carbon two-mechanism storage and the higher charge-transfer resistance — is the publishable finding. Target: **Electrochimica Acta** (where the DFN comparison paper already appeared).

**Proposal 7: First Standalone Validated SPMe for SIB**
The single-particle model with electrolyte dynamics (SPMe) is the work-horse of physics-based BMS estimation — computationally cheap enough for real-time implementation but more accurate than the simple SPM. No standalone validated SIB SPMe exists. Implement it in PyBaMM (the framework already exists; parameter substitution is required), validate against the DFN at multiple C-rates and temperatures, characterise the accuracy-speed trade-off, and implement a Luenberger observer based on the SPMe for real-time SOC estimation. Target: **Journal of Power Sources**.

**Proposal 8: Coupled Electrochemical-Thermal SIB Model**
Couple the PyBaMM SIB DFN model with a lumped thermal model (spherical or cylindrical cell geometry) and validate against published SIB thermal data from the characterisation literature. The PyBaMM thermal coupling framework already exists for Li-ion — this is a parameter substitution and extension project. The novel contribution: SIB-specific entropy coefficient $\partial E/\partial T$ estimation from published OCV-temperature data, and the first systematic comparison of SIB vs LFP heat generation as a function of C-rate and temperature using coupled electrochemical-thermal simulation. Target: **Journal of Power Sources** or **eTransportation**.

**Proposal 9: Thermal Runaway Kinetics Model for SIB**
Extract Arrhenius kinetic parameters for SIB thermal runaway reactions from published DSC (differential scanning calorimetry) and ARC data: SEI decomposition onset temperature and heat of decomposition for hard carbon SEI, oxygen release onset and enthalpy for NVPF/NFM cathodes, and electrolyte combustion parameters. Use these parameters to build a five-reaction Arrhenius thermal runaway model in COMSOL or MATLAB and validate against published ARC test data for SIB cells. Target: **Journal of the Electrochemical Society**.

**Proposal 12: Semi-Empirical Ageing Model for SIB**
Build a capacity fade and resistance rise model for SIBs following the Wang et al. (2014) empirical framework for Li-ion: $Q_\text{loss} = B \exp(-E_a/RT)\sqrt{t}$ for calendar ageing and a power-law cycle ageing term. Fit parameters from the BatteryLife dataset (which includes SIB cycle ageing data at 2C–6C rates) and validate against the Wang et al. Zenodo pulse characterisation data (which shows capacity evolution across multiple temperatures). Compare the SIB ageing parameters against published Li-ion values. Target: **Journal of Energy Storage**.

**Proposal 16: City EV Drive Cycle Simulation with SIB**
Simulate a small electric vehicle (representative of Indian or Chinese city EVs) over urban drive cycles (WLTC Class 1 or 2, Indian MIDC, Chinese CLTC) using an SIB pack model (ECM parameters from Proposal 3). Compare range, energy efficiency, cabin heating requirements, and pack temperature evolution against an equivalent LFP pack. Quantify the low-temperature range advantage (SIB) against the energy-density disadvantage (SIB). This is the kind of system-level validation that contextualises single-cell models and is directly publishable. Target: **Journal of Energy Storage** or **Energies MDPI**.

**Proposal 17: Cell Balancing Simulation for SIB Packs**
This is one of the three highest-priority proposals for first-mover advantage. No paper on cell balancing for SIB packs exists. Simulate passive and active balancing for a 16s SIB string using a multi-cell ECM model, implementing the balancing algorithms from Chapter 11 with SIB-specific complications: the flat-OCV plateau makes voltage-triggered balancing unreliable in the plateau region; OCV hysteresis causes spurious triggers; the higher DCIR changes the passive balancing time constants. Implement SOC-based balancing triggers from an EKF state estimator and compare against voltage-based triggers. Target: **IEEE Access** or **Journal of Energy Storage**. Because this paper occupies a completely empty space, it requires zero competitive framing — simply "this has not been done, here it is" is sufficient justification.

**Proposal 23: Second-Life SIB Techno-Economic Model**
Project forward: when will SIB cells from the first major commercial deployments (2023–2025) reach end-of-life (80% capacity retention)? At CATL's claimed 10,000 cycles, for cells cycled daily at 1C, this is approximately 27 years — almost certainly exceeding the cell's calendar life, which means calendar ageing would likely determine end-of-life rather than cycle count. (This inference assumes calendar ageing rates comparable to Li-ion; SIB-specific calendar ageing data is still sparse — see Gap 5.) At HiNa's more conservative 4,500 cycles at 1C daily, end-of-life is approximately 12 years. Model the second-life residual value of these cells for residential storage applications, using a coupled degradation model and a techno-economic framework. Compare against LFP second-life economics. Target: **Journal of Energy Storage** or **Energies MDPI**.

**Proposal 25: SIB Frequency Regulation Simulation**
Simulate an SIB BESS (10 MW/20 MWh) responding to a real frequency regulation signal (PJM RegD signal, publicly available) and compare performance, revenue, and degradation cost against an LFP BESS with equivalent energy capacity. The modelling hypothesis is that SIB's strong power capability and cold-weather behaviour should make it especially attractive for frequency-regulation duty. This appears to be a very open problem in the SIB literature. Target: **IEEE Transactions on Smart Grid** or **Applied Energy**.

### Ambitious Track (6–12 months, Tier 1, no hardware)

**Proposal 11: Multi-Mechanism Degradation Model for SIB**
Build the first comprehensive physics-based degradation model for SIBs, incorporating: SEI growth on hard carbon (parabolic $\sqrt{t}$ law, Arrhenius temperature dependence); O3→P3 phase transition fatigue in the cathode (damage accumulation as a function of desodiation depth); sodium plating on hard carbon (onset criterion based on local anode potential, plating rate from Butler-Volmer); hard carbon structural evolution (gradual change in $D_s$ and OCV shape over cycling). Implement in PyBaMM using the existing degradation framework. Validate each mechanism independently against published experimental data. Target: **Journal of Power Sources**.

**Proposal 13: Transfer Learning Li→Na for SOH Estimation**
Pre-train a capacity fade prediction model on the 228-cell NMC ageing dataset (Nature Scientific Data 2024), then fine-tune on the limited SIB ageing data (BatteryLife NaIon subset, Laufen et al. cyclic ageing). Compare against a model trained from scratch on SIB data only. Demonstrate that transfer learning closes the SIB data scarcity gap. Use domain adaptation techniques to account for the chemistry differences. Target: **Applied Energy**.

**Proposal 14: Physics-Informed Neural Network (PINN) for SIB State Estimation**
Implement a PINN for SIB state estimation: the neural network predicts terminal voltage, with the DFN governing equations enforced as physics constraints in the training loss. This approach combines the flexibility of data-driven methods with the physical validity guarantees of physics-based models — particularly valuable for SIBs where data is scarce and the physics constraints prevent overfitting. Validate against the Wang et al. Zenodo dataset. Target: **Applied Energy** (where PINN for batteries papers are beginning to appear).

**Proposal 15: MPC Optimal Fast Charging Protocol for SIB**
Formulate a model predictive control (MPC) problem for SIB fast charging: maximise charging speed (minimise time to target SOC) subject to hard constraints on cell temperature ($T < 50°C$), terminal voltage ($V < V_\text{max}$), and negative-electrode potential remaining above the sodium-plating threshold (i.e. the local negative-electrode potential versus Na/Na+ should stay positive). Implement in MATLAB using the SPMe as the prediction model (Proposal 7 provides the SPMe). Demonstrate 15–30% reduction in charging time compared to CC-CV at the same safety constraints, across temperatures from 0°C to 45°C. Target: **eTransportation**.

**Proposal 19: SIB Digital Twin Framework**
Design and implement an early SIB digital twin: an architecture that continuously updates an ECM or reduced-order electrochemical model from streaming current-voltage data using a dual EKF (one filter for state estimation, one for parameter identification). Demonstrate the framework on synthetic data generated from PyBaMM (with deliberately introduced parameter drift to represent ageing), tracking capacity fade and resistance rise over simulated years of operation. Define the software architecture, data flow, and computational requirements. Target: **Applied Energy** or **eTransportation**.

**Proposal 20: Grid Dispatch Optimisation for SIB BESS**
Formulate a stochastic optimal dispatch problem for a grid-scale SIB BESS (100 MW/400 MWh, representative of the Jupiter Power/Peak Energy deployment): maximise revenue from energy arbitrage and ancillary services subject to degradation constraints, temperature-dependent power limits, and SIB-specific cycling constraints. Compare the optimal dispatch strategy for SIB vs LFP under real electricity price and ancillary service price data (ISO-NE or PJM market data, publicly available). Target: **IEEE Transactions on Smart Grid**.

**Proposal 21: Hybrid Li/Na Pack Energy Management**
Model CATL's "Freevoy" hybrid SIB+LFP pack concept: cells of two different chemistries in the same series string, with different OCV curves, different DCIR, different temperature characteristics, and different ageing rates. Develop a state-estimation framework that maintains separate SOC estimates for SIB and LFP cells simultaneously, a balancing strategy that accounts for their different OCV shapes, and an energy-management strategy that dispatches the SIB cells preferentially in conditions where they have the performance advantage (low temperature, high power demand) and the LFP cells preferentially where they have the advantage (high energy demand, moderate temperature). Target: **eTransportation**.

**Proposal 22: Sodium Plating Onset Prediction Model**
Build the first computational model for sodium plating onset in hard carbon anodes: derive the plating onset criterion (local anode potential $\leq$ 0 V vs. Na/Na⁺) from the DFN model, compute the onset C-rate as a function of temperature and SOC, and validate against published experimental observations of plating signatures (CE reduction, voltage plateau on discharge, post-mortem sodium metal observation) in hard carbon half-cells and full cells. Parameterise the model from published half-cell data. Derive safe charging current limits as a function of temperature. Target: **Journal of the Electrochemical Society**.

**Proposal 24: Transformer-Based SOH Estimation for SIB**
Implement a Transformer architecture for SIB SOH estimation, exploiting the self-attention mechanism to identify the most informative time segments in the charging/discharging voltage-current profile. Pre-train on the 228-cell NMC dataset and fine-tune on SIB ageing data. Compare against LSTM-based methods from the Li-ion literature. The novelty framing: Transformers applied to SIB degradation prediction, with explicit transfer learning methodology for chemistry-to-chemistry transfer. Target: **Applied Energy**.

### Summary Table of All 25 Proposals

| # | Topic | Difficulty | Time (months) | Target Venue | Hardware? |
| --- | --- | --- | --- | --- | --- |
| 1 | Kalman filter benchmark for SIB SOC | Low | 4–6 | Batteries / IEEE Access | No |
| 2 | Sliding mode observer for SIB | Low-Med | 4–5 | J. Energy Storage | No |
| 3 | Open-source SIB ECM parameter database | Low | 3–5 | Data in Brief / Batteries | Optional |
| 4 | Fractional vs integer ECM comparison | Low | 4–5 | Energies / Batteries | No |
| 5 | Formal observability analysis SIB vs LFP vs NMC | Medium | 5–7 | IEEE Trans. Transport. Electrif. | No |
| 6 | Global sensitivity analysis SIB DFN | Medium | 4–6 | Electrochimica Acta | No |
| 7 | First standalone validated SPMe for SIB | Medium | 5–7 | J. Power Sources | No |
| 8 | Coupled electrochemical-thermal SIB model | Medium | 6–8 | J. Power Sources | No |
| 9 | TR Arrhenius kinetics model for SIB | Med-High | 6–9 | J. Electrochem. Soc. | No |
| 10 | TR propagation simulation SIB vs LIB packs | High | 8–12 | Applied Energy | Optional |
| 11 | Multi-mechanism degradation model SIB | High | 8–12 | J. Power Sources | No |
| 12 | Semi-empirical ageing model for SIB | Medium | 5–7 | J. Energy Storage | No |
| 13 | Transfer learning Li→Na for SOH | Med-High | 6–9 | Applied Energy | No |
| 14 | PINN for SIB state estimation | High | 8–10 | Applied Energy | No |
| 15 | MPC optimal fast charging for SIB | High | 8–12 | eTransportation | No |
| 16 | City EV drive cycle simulation with SIB | Low-Med | 5–7 | J. Energy Storage / Energies | No |
| 17 | Cell balancing simulation for SIB packs | Low-Med | 5–7 | IEEE Access / J. Energy Storage | No |
| 18 | Low-temperature SIB simulation vs LFP | Medium | 6–8 | J. Power Sources | No |
| 19 | SIB digital twin framework | High | 8–12 | Applied Energy | No |
| 20 | Grid dispatch optimisation for SIB BESS | Medium | 6–8 | IEEE Trans. Smart Grid | No |
| 21 | Hybrid SIB+LFP pack energy management | Med-High | 7–10 | eTransportation | No |
| 22 | Sodium plating onset prediction model | Med-High | 6–9 | J. Electrochem. Soc. | No |
| 23 | Second-life SIB techno-economic model | Low-Med | 4–6 | J. Energy Storage | No |
| 24 | Transformer-based SOH for SIB | Med-High | 7–10 | Applied Energy | No |
| 25 | SIB frequency regulation simulation | Medium | 5–7 | IEEE Trans. Smart Grid | No |

### Proposal Dependencies: What Enables What

Not all 25 proposals are independent. Several share datasets, models, or intermediate results, and completing one makes subsequent proposals faster. The most important dependency chains are:

Proposal 3 (ECM parameter database) feeds directly into Proposals 1, 2, 4, 16, 17, and 21 — any work requiring parameterised ECMs benefits from the database. This is why Proposal 3 appears in the recommended three-paper arc as Paper 1.

Proposal 7 (standalone SPMe) feeds into Proposals 15 (MPC fast charging, which uses the SPMe as the prediction model) and 22 (sodium plating, which uses SPMe to compute anode potentials).

Proposal 6 (global sensitivity analysis) informs Proposals 8 (coupled electrochemical-thermal model, by identifying which thermal parameters matter most) and 11 (multi-mechanism degradation, by identifying which degradation parameters are most sensitive).

Proposal 12 (semi-empirical ageing model) feeds into Proposals 20 (grid dispatch, which needs a degradation cost model), 23 (second-life economics, which needs a lifetime projection), and 25 (frequency regulation, which needs degradation-aware dispatch).

If you plan to pursue more than three proposals, map these dependencies before choosing your sequence. A well-ordered research programme reuses intermediate results; a poorly ordered one repeats work.

---

## 14.9 Strategic Sequencing: Building a Research Portfolio

The proposals above are not equally urgent or equally strategic. Here is a recommended approach to sequencing them for maximum impact and minimum wasted effort.

### The First Paper: Build Credibility Quickly

Your first SIB simulation paper should be one that (a) uses established methodology, (b) requires no hardware, (c) has available data, and (d) addresses a topic with no existing SIB competition. Proposals 1, 3, 17, and 23 all satisfy these criteria.

**Proposal 17** (cell balancing simulation) stands out as the ideal first paper for an unusual reason: despite being a moderately complex topic, it occupies a completely empty space — no cell balancing paper for SIBs exists anywhere. The methodology is well-established (Chapters 9 and 11 of this book provide it), the dataset requirement is modest (any ECM from Proposal 3 or the published Xiang 2021 parameters is sufficient), and the SIB-specific complications (flat OCV, hysteresis) give the paper genuine novelty rather than mere replication. A first SIB cell balancing paper in IEEE Access or Journal of Energy Storage would face zero competitive papers and be the defining reference in that space for years.

**Proposal 3** (ECM parameter database) is the highest-utility first paper if your goal is to enable your own subsequent work. The parameter database becomes the foundation for Proposals 1, 2, 7, 8, 11, 12, and 16 — it pays dividends across your entire research trajectory while also being a citable contribution in its own right.

### The Three-Paper Arc

The most impactful structured approach is a connected three-paper arc:

**Paper 1**: ECM parameter database (Proposal 3) — establishes validated parameters for 2–3 commercial SIB cells. 3–5 months. Batteries MDPI or Data in Brief.

**Paper 2**: SOC estimation benchmark (Proposal 1) using the parameters from Paper 1 — demonstrates that your ECM parameters enable accurate state estimation across temperatures and driving profiles. 4–5 months. IEEE Access or Journal of Energy Storage.

**Paper 3**: EV drive cycle simulation (Proposal 16) using the same model — demonstrates system-level application, contextualises the SOC accuracy in an EV use case. 5–6 months. Journal of Energy Storage.

This arc produces three publications in approximately 12–15 months, each building on the previous, forming a coherent research narrative around "validated SIB modelling from parameter identification through BMS algorithm to application." The coherent narrative increases citation cross-linking: Paper 2 cites Paper 1, Paper 3 cites both, and external papers that discover any one will discover the others through the citation trail.

### Landmark Papers: The High-Impact Opportunities

Three proposals stand out as potentially high-citation landmark papers that will be extensively cited as the SIB engineering simulation field matures:

**Proposal 19** (SIB Digital Twin) — an early digital-twin framework for SIBs could become the reference paper for subsequent SIB digital-twin implementations. Even a conceptual framework demonstration on synthetic PyBaMM data establishes the architecture that later papers can build on. Applied Energy or eTransportation.

**Proposal 21** (Hybrid SIB+LFP Pack) — CATL's Freevoy architecture has already been publicly announced with a sodium-LFP configuration. An early energy-management paper for a heterogeneous-chemistry pack would therefore address a concrete industrial target and is likely to be cited by later Freevoy-style modelling papers. eTransportation.

**Proposal 20** (Grid Dispatch with SIB) — as SIB grid storage installations scale up (Peak Energy's 4.75 GWh Jupiter Power contract, HiNa's Chinese grid deployments), the demand for grid-level SIB modelling will grow. The first grid dispatch optimisation paper for SIB will anchor that literature. IEEE Transactions on Smart Grid.

### The Timing Advantage

The single most important strategic insight is this: the SIB simulation field is approximately where lithium-ion simulation was in 2010–2012. The researchers who entered Li-ion simulation in that period and produced systematic, well-parameterised, open-source-committed work became the most-cited contributors to the field. The papers that established ECM parameter databases, validated DFN models for commercial cells, and first applied EKF/Kalman frameworks to Li-ion BMS now accumulate hundreds or thousands of citations annually.

The same window is open for SIBs today. Every systematic, well-executed, publicly deposited piece of SIB simulation infrastructure you create will accumulate citations as the field grows — because later researchers will need a foundation to build on, and if your work is the only foundation available, they will build on it. Open-source code, open datasets, and reproducible simulation pipelines are not just good scientific practice; for a first-mover in a nascent field, they are the mechanism by which early papers accumulate disproportionate long-term citation impact.

---

## Worked Interpretation Exercise: Planning Your First Research Paper

Let us apply the chapter's framework to a concrete planning exercise that will take you from this page to a submitted manuscript.

**Step 1 — Choose your entry proposal**: Based on your background and the time available, select one of the Fast Track proposals. If you have strong MATLAB/Simulink skills and have worked through Plett's BMS courses: Proposal 1 (Kalman filter benchmark). If you are more comfortable with Python and PyBaMM: Proposal 6 (global sensitivity analysis). If you want the fastest path to a completely uncontested publication: Proposal 17 (cell balancing).

**Step 2 — Download your primary dataset**: For Proposals 1, 2, 12, and 16: Zenodo ID 13836819 (Wang et al. SIB dataset). For Proposal 4: Laufen et al. supplementary data from *Cell Reports Physical Science* (2024). For Proposals 6, 7, 8: use PyBaMM's `Chayambuka2022` parameter set for synthetic data generation. For Proposal 3: combine Wang et al. Zenodo + Droese et al. (TU Berlin depositonce) + Iontech GitHub.

**Step 3 — Set up your simulation environment**: For ECM/BMS work: MATLAB with Plett's code from his Coursera course as a starting template. For DFN/SPMe work: `pip install pybamm` and run the sodium-ion DFN notebook from `docs.pybamm.org`. For parameter identification: install PyBOP (`pip install pybop`). For data digitisation from published figures: WebPlotDigitizer at automeris.io.

**Step 4 — Define your contribution precisely**: Write one sentence that states your paper's contribution in the form "This paper [does X specific thing] for [SIB / SIB cells / SIB packs] which has not been done before, using [method] validated against [dataset], showing [key result]." If you cannot write this sentence, you do not yet have a paper — you have a project. Return to step 1.

**Step 5 — Write the paper structure before writing the paper**: Abstract (4 sentences: context, gap, contribution, key result). Introduction (1,500–2,000 words: SIB background, simulation gap, previous SIB simulation work, your specific contribution). Methods (model, parameterisation, datasets, algorithm). Results (figures and tables showing the key result). Discussion (why the result matters, limitations). Conclusion. Write the structure before filling it in — this prevents the common error of accumulating results without a coherent narrative.

**Step 6 — Submit to your target venue and move to the next proposal**: Do not wait for review to begin the next paper. If you have followed the three-paper arc structure (Proposal 3 → 1 → 16), Paper 2 can begin as soon as Paper 1 is submitted.

---

## Chapter Summary

- **The landscape in brief:** The SIB commercial ecosystem has crossed the threshold from research to commercial reality: CATL has publicly launched Naxtra at 175 Wh/kg with >10,000 claimed cycles, HiNa has GWh-scale production and grid-storage deployments, and Tiamat offers a high-power commercial NVPF platform. The Chinese research and industrial ecosystem remains dominant and is focused primarily on materials science. The engineering simulation literature — ECM parameterisation, state estimation, degradation modelling, thermal simulation, pack management, grid integration — is still comparatively sparse.
- **The open-source toolkit is ready:** PyBaMM `pybamm.sodium_ion.BasicDFN()`, COMSOL's 1D Na-ion example, MATLAB/Simulink for BMS algorithms, PyBOP for parameter identification, and WebPlotDigitizer for data extraction from published curves.
- **A small but usable open SIB dataset stack** is available: Wang et al. Zenodo 13836819 (primary), the BatteryLife NaIon subset, Iontech characterisation data, Laufen et al. (2024), and Droese et al. (2025). These datasets, combined with the 228-cell NMC and Severson et al. LFP datasets for methodology development, are enough to support a serious research portfolio.
- **The publication route is proven:** Batteries MDPI for fast early papers; Journal of Energy Storage for first journal papers in ECM/SOC; Applied Energy for system-level work; IEEE Transactions on Smart Grid for grid integration; eTransportation for EV-framed high-impact papers; Electrochimica Acta and JES for physics-based modelling. IEEE conferences (VPPC, IECON, ITEC) as proven SIB conference venues.
- **Thirteen gap areas and 25 concrete proposals** span from straightforward replications (3–6 months, Tier 3) to landmark contributions (8–12 months, Tier 1). The three highest first-mover-advantage proposals are Proposal 17 (cell balancing), Proposal 19 (digital twin), and Proposal 20 (grid dispatch). The three-paper arc of Proposals 3 → 1 → 16 provides the fastest path to a coherent three-publication research portfolio.
- **The strategic insight:** SIBs are where Li-ion was in 2010–2012. The researchers who built the Li-ion simulation infrastructure in that window became the field's most-cited contributors. That window is open for SIBs today. Enter it now.

---

## Deliverable

The chapter plan originally asked you to read three recent SIB review papers and produce a tagged "open questions" document — materials problems versus systems/modelling problems. That exercise is now subsumed by the more comprehensive deliverable below, which integrates the open-questions analysis into a full research plan. If you have not yet read three recent SIB review papers, do so before attempting this deliverable; the Garapati et al. (2025) and Chayambuka et al. (2022) papers from the Further Reading list count as two.

Your task is to produce a **Research Plan Document** of approximately 2,000–3,000 words that covers:

**Section 1 — Your selected entry proposal** (from the Fast Track or Medium Track): State the proposal, justify your selection, and describe the specific methodology you will use (which dataset, which tool, which algorithm, which metric of success).

**Section 2 — Your three-paper arc**: Define Paper 1, Paper 2, and Paper 3 — the connected sequence of proposals that builds a coherent research narrative. Specify the target venue for each.

**Section 3 — Your SIB Parameter Table** (from Chapter 13's deliverable): The completed version of the table with every DFN parameter filled in or explicitly noted as "not characterised in the literature." The gaps in this table are your highest-priority experimental needs.

**Section 4 — Timeline**: A Gantt chart or similar visualisation showing paper 1 submission in month 4–6, paper 2 submission in month 8–10, and paper 3 in month 14–16. Include milestone events: dataset download and exploration (week 1–2), model implementation and initial results (month 1–2), draft paper (month 3–4), submission (month 4–6).

This research plan is the product of everything in this book. It integrates the electrochemistry (Chapters 1–4), the chemistry families (Chapters 5–6), the degradation physics (Chapter 7), the thermal science (Chapter 8), the systems engineering (Chapters 9–12), the SIB-specific modifications (Chapter 13), and the landscape (Chapter 14) into a concrete personal research programme. Write it with care — it is the document you will return to repeatedly as your research progresses.

---

## Further Reading

1. **Chayambuka, K. et al., "Physics-based modeling of sodium-ion batteries, Part I: Experimental parameter determination; Part II: Model and validation," *Electrochimica Acta* (2022).** The foundational DFN parameter set that underlies `pybamm.sodium_ion.BasicDFN()`. The two-part series is the most important single reference in SIB simulation, establishing both the parameterisation methodology and the model validation approach. Reading both parts carefully before beginning any DFN simulation work will save months of uncertainty about model assumptions.

2. **Garapati, M. et al., "Perspective and comparative analysis of physics-based models for sodium-ion batteries," *Electrochimica Acta* 514, 145573 (2025).** The most recent and most complete comparison of DFN, SPMe, and SPM for SIBs, published open-access. This paper defines the current state of the art in SIB electrochemical modelling and is the reference against which any Proposal 5, 6, or 7 paper will be compared.

3. **Wang, Y. et al., "Data for: Accurate state-of-charge estimation for sodium-ion batteries based on a low-complexity model with hierarchical learning," Zenodo ID: 13836819 (2024).** The primary experimental dataset for SIB BMS algorithm development. Download and explore this dataset before beginning any SOC estimation paper. The README describes the measurement protocol, the cell specifications, and the data format. The dataset's existence means that Proposals 1, 2, 12, and 16 can begin immediately without purchasing cells.

4. **Laufen, T. et al., "Multi-method characterization of a commercial 1.2 Ah sodium-ion battery cell indicates drop-in potential," *Cell Reports Physical Science* (2024).** One of the most comprehensive published characterisations of a commercial SIB cell, including EIS at 21 SOC levels, micro-CT imaging, and post-mortem physical analysis. Supplementary data provides numbers directly usable for ECM and DFN parameterisation. This paper is the experimental reference for Proposals 3, 4, 8, and 9.

5. **Sulzer, V. et al., "Python Battery Mathematical Modelling (PyBaMM)," *Journal of Open Research Software* 9 (1), 14 (2021).** The PyBaMM software paper — cite this alongside the `Chayambuka2022` parameter set whenever using PyBaMM's sodium-ion DFN. The paper describes the software architecture, the model library, and the validation approach. The PyBaMM GitHub repository (github.com/pybamm-team/PyBaMM) and Discourse forum (pybamm.discourse.group) are the primary technical support resources for anyone building SIB simulations with PyBaMM.

6. **Plett, G. L., *Battery Management Systems, Volume I: Battery Modeling* and *Volume II: Equivalent-Circuit Methods*, Artech House (2015).** The EE-canonical reference for every ECM, Kalman filter, and state estimation algorithm referenced in this chapter's proposals. If you are implementing Proposals 1, 2, 3, 4, 5, or 17, Plett's MATLAB code — available through his Coursera specialisation "Algorithms for Battery Management Systems" — provides tested starting implementations that you can adapt for SIB parameters. These are the books to have open on your desk alongside PyBaMM documentation.

---

*This is the final chapter of the book. You now have the physics, the chemistry, the engineering, and the research roadmap. The battery technology field — and specifically the sodium-ion simulation sub-field — is ready for exactly the kind of rigorous, open, simulation-based research that a well-trained electrical engineer can produce. Begin.*

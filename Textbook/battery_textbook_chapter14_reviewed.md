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

To understand the research opportunity, you first need to understand the scale of what is missing. A scientometric analysis of the SIB literature through 2025 identified approximately 15,682 peer-reviewed SIB papers in total — but the overwhelming majority of these are materials science papers: cathode synthesis, anode processing, electrolyte composition, structural characterisation. The sub-literature specifically addressing the engineering modelling concerns that fill this book — equivalent circuit models, electrochemical models, thermal models, BMS algorithms, state estimation, degradation prediction, system-level optimisation — is perhaps 50–100 times smaller than the equivalent LIB engineering modelling literature. To give you a concrete sense of scale: a Google Scholar search for "lithium-ion equivalent circuit model" returns tens of thousands of results; "sodium-ion equivalent circuit model" returns fewer than fifty. The asymmetry holds across every topic in Chapters 9 through 12. In practical terms: for every topic in Chapters 9 through 12 of this book, there are hundreds or thousands of Li-ion papers and perhaps three to eight SIB papers. Most of those SIB papers were published after 2022.

This is not a gap that will close quickly by itself. The Chinese research institutions that dominate SIB publication output (Section 14.3) are overwhelmingly focused on materials: cathode synthesis at Hu Yong-Sheng's IOP-CAS group, hard carbon precursor development at Wuhan University and Central South University, PBA chemistry at multiple institutions. The engineering simulation work — ECM parameterisation, state estimation, degradation modelling, pack-level simulation — is what the materials community does not typically produce and what an electrical engineering researcher is specifically positioned to contribute.

### The Foundational Papers: An Annotated History

**2018 — Baseline reviews.** Chayambuka et al. published "Sodium-Ion Battery Materials and Electrochemical Properties Reviewed" in *Advanced Energy Materials*, establishing the first comprehensive survey of SIB electrode materials properties from a modelling-relevant perspective — cataloguing the range of specific capacities, diffusion coefficients, and exchange current densities needed to parameterise any physics-based model.

**2021 — First ECM papers.** Xiang et al. published "Equivalent circuit modeling of sodium-ion batteries" in the *Journal of Energy Storage*, systematically comparing 1RC, 2RC, and 3RC topologies for a 1 Ah pouch SIB cell using Bayesian Information Criterion model selection, finding 3RC optimal. This established the ECM baseline for SIBs, analogous to Chen and Rincón-Mora's 2006 paper for lithium-ion.

**2022 — First validated DFN model.** Chayambuka, Mulder, Danilov, and Notten published "Physics-based modeling of sodium-ion batteries, Part I: Experimental parameter determination" and "Part II: Model and validation" in *Electrochimica Acta*. These two papers represent the inflection point in SIB simulation research. Part I systematically characterised a Tiamat NVPF/hard carbon cell to extract the full set of DFN parameters: solid-state diffusion coefficients for both electrodes, electrolyte transport parameters, exchange current densities, and OCV-SOC curves. Part II assembled these into a working P2D model validated against discharge curves at 0.1C to 1.4C with less than 2% voltage error. This parameter set was subsequently adopted by PyBaMM (v24.11) as `Chayambuka2022` — the standard SIB DFN parameter set that any researcher can use today without additional characterisation work.

**2023 — First IEEE conference paper on SIB ECM.** Rabab et al. published "Equivalent Circuit Model For Sodium-Ion Batteries With Physical-Based Representations Of Their Non-Linearities" at IEEE VPPC 2023 in Milan — the first identifiable SIB simulation paper in any IEEE venue. It presented a modified ECM for the Tiamat NVPF/HC 18650 cell that separated charge transfer, SEI, and diffusion phenomena with Arrhenius temperature dependence for each component. This paper's existence confirms that IEEE conference venues are receptive to SIB simulation work. The following year, Sandri et al. published "Electrical Circuit Model for Sodium-Ion Batteries" at IECON 2024 Chicago, comparing 1RC through 4RC models for SIB accuracy-complexity trade-offs.

**2023 — First SOC estimation paper.** Xiang et al. in the *Journal of Energy Storage* published "A comprehensive study on state-of-charge and state-of-health estimation of sodium-ion batteries," using a PSO-optimised third-order RC model with EKF, UKF, and particle filter comparison. The field of SIB state estimation began with this single paper.

**2024 — Commercial cell characterisation becomes available.** Laufen et al. published "Multi-method characterisation of a commercial 1.2 Ah 18650 sodium-ion battery cell" in *Cell Reports Physical Science* with supplementary data — providing EIS at 21 SOC levels, C-rate tests, cyclic ageing with micro-CT, and validated ECM parameters for a real commercial 18650 SIB cell. Bischof et al. at KIT published "Evaluation of commercial 18650 and 26700 sodium-ion cells" in their institutional repository. These papers transformed SIB simulation from a purely theoretical exercise into one grounded in real commercial cell data.

**2024 — PyBaMM and COMSOL integration.** The PyBaMM development team integrated the Chayambuka2022 parameter set (named after the paper's 2022 publication year) into PyBaMM v24.11, released in November 2024, creating `pybamm.sodium_ion.BasicDFN()` — the first ready-to-run, open-source, validated physics-based SIB model. Simultaneously, COMSOL added an official "1D Isothermal Sodium-Ion Battery" model (Application Library ID: 117341) using the same parameter set. These two events together made it possible for any engineer with a laptop to simulate an SIB cell without any experimental work.

**2025 — The first SIB DFN comparison paper.** Garapati et al. published "Perspective and comparative analysis of physics-based models for sodium-ion batteries" in *Electrochimica Acta* — a purely simulation-based comparison of DFN, SPMe, and SPM for SIBs. This paper's existence is important for two reasons: it demonstrates that simulation-only SIB modelling work is publishable at a Q1 Elsevier journal, and it establishes SPM/SPMe for SIBs as a research topic. The first physics-based SIB degradation model appeared the same year, alongside the first electrochemical-thermal coupling models, the first microstructure-resolved SIB model (Cardenas-Sierra et al., ChemRxiv preprint), and the first ML-enhanced P2D hybrid (Liu et al.).

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
2018  Chayambuka — first modelling-relevant SIB property review (Adv. Energy Mater.)
  |
2021  Xiang — first SIB ECM (J. Energy Storage), 1RC/2RC/3RC comparison
  |
2022  Chayambuka — first validated DFN parameter set, NVPF/HC (Electrochim. Acta)
  |
2023  Rabab — first IEEE SIB simulation paper, ECM @ VPPC
      Xiang — first SIB SOC estimation paper (J. Energy Storage)
  |
2024  Laufen — first full commercial SIB cell characterisation (Cell Rep. Phys. Sci.)
      Sandri — SIB ECM comparison @ IECON
      PyBaMM v24.11 — pybamm.sodium_ion.BasicDFN() released
      COMSOL — official 1D Na-ion model added
      Wang — first open SIB cycling dataset (Zenodo)
  |
2025  Garapati — DFN vs SPMe vs SPM comparison (Electrochim. Acta)
      First physics-based SIB degradation model (calendar SEI)
      First electrochemical-thermal coupling models
      First ML-enhanced P2D hybrid
  |
2026  ← YOU ARE HERE
      Every row with "0 papers" in the table above is an open door.
```

---

## 14.2 The Commercial Landscape: What Exists to Model

Modelling and simulation research is only valuable if it models something real. The commercial landscape of sodium-ion batteries as of early-to-mid 2026 provides a growing set of real cells, real packs, and real deployment scenarios to anchor simulation work.

### The Dominant Player: CATL and the Naxtra

CATL's market position in SIB is analogous to their position in LIB: dominant, accelerating, and setting the performance and cost benchmarks against which everything else is measured.

Their first-generation SIB (Prussian white / hard carbon, prismatic, ~160 Wh/kg) began shipping in 2023 for the Chery iCar EV. Their second-generation product, the **Naxtra**, launched in April 2025, represents a step change: 175 Wh/kg gravimetric energy density, >10,000 cycle life (claimed, pending independent verification), 5C fast charging (80% SOC in 15 minutes), and operation from −40°C to +70°C. The Naxtra achieves 93% capacity retention at −30°C and maintains highway-speed driving capability at −40°C — numbers that exceed any published LFP performance at low temperature. The first mass-production passenger vehicle using the Naxtra pack is the Changan Nevo A06 (45 kWh SIB pack, >400 km range), expected in mid-2026.

CATL's "Freevoy Dual-Power Battery" concept — mixing SIB and LFP cells in a single hybrid pack — is a direct simulation research opportunity. A heterogeneous pack containing cells of different chemistry, different OCV curve shapes, different temperature characteristics, and different ageing rates creates state estimation and balancing challenges that are genuinely novel and commercially relevant. Think of it as a series string of resistors where each resistor has a different temperature coefficient and a different aging law — your balancing and estimation algorithms must track each component's individual state, not just the string aggregate. Every BMS technique from Chapters 10–12 must be re-derived for the two-chemistry case. This specific application has no Li-ion analogue.

**For the simulation researcher**: CATL has not released open characterisation data for Naxtra cells. However, the cell's Chinese market specifications (available through Chinese battery industry databases and published technical reports) provide enough boundary conditions for model-building: nominal voltage, capacity, DCIR at multiple temperatures, and cycle life under stated conditions.

### HiNa Battery Technology

HiNa (中科海钠, or China Science Sodium Battery Technology) is the direct academic-to-industry pipeline from IOP-CAS, co-founded by Prof. Hu Yong-Sheng and Academician Chen Liquan, widely regarded as a founding figure of Chinese lithium battery research. HiNa operates a GWh-scale production line in Fuyang, Anhui Province, since late 2022, and has delivered cells to multiple commercial applications including a 100 MWh grid storage system in Hubei Province (42 battery containers, 185 Ah cells, operational July 2024) — the world's largest sodium-ion energy storage installation at its commissioning.

HiNa's commercial cell portfolio spans 12 Ah, 80 Ah, 240 Ah, and their latest "Haixing" commercial vehicle cell at >165 Wh/kg with >8,000 cycle life. Their O3-type cathode (NaCuFeMnO₂ family, cobalt-free and nickel-free) paired with anthracite-derived hard carbon represents the most well-characterised commercial SIB chemistry for which published simulation data exists. The Laufen et al. (2024) characterisation paper, the Wang et al. (2025) Zenodo dataset (which includes a HiNa 10 Ah cell alongside a Transimage 3.2 Ah cell), and multiple Chinese-language publications from HiNa's technical partners provide the richest available data for SIB simulation validation.

HiNa's heavy truck applications — where their packs show 15% lower energy consumption per kilometre compared to LIB packs, attributed to deeper permissible discharge — represent a compelling system-level simulation case study for efficiency modelling.

### Tiamat Energy

Tiamat occupies a unique niche in the SIB landscape: the **highest-voltage commercial SIB** (3.7 V nominal — matching NMC-type Li-ion cells, and exceeding LFP's 3.2 V) using NVPF (Na₃V₂(PO₄)₂F₃) cathodes, with the **highest power density** (up to 35C peak discharge, 2–5 kW/kg). Their 18650 format cell (1.0 Ah, 3.5 Wh, 15 mΩ internal resistance at 1 kHz) is the cell characterised by Chayambuka et al. and whose parameter set anchors the PyBaMM sodium-ion DFN implementation.

For the simulation researcher, Tiamat's cell is uniquely attractive: it is the most comprehensively documented commercial SIB cell, the Chayambuka2022 DFN parameter set gives a starting point for physics-based modelling, and published datasheets (available through Tiamat's website and through the Rabab et al. ECM paper) provide boundary conditions. The cell's 3,200-cycle life at 2C/5C cycling and >90% capacity retention at 20C discharge also make it the best SIB candidate for high-power application modelling (fast-charging infrastructure, frequency regulation, power tools).

### The Western Landscape: Setbacks and Survivors

The Western commercial SIB landscape has experienced significant turbulence. **Natron Energy**, which had delivered sodium-ion batteries for data centre UPS applications at commercial scale, ceased all operations on September 3, 2025, unable to obtain UL certification in time to fulfil $25 million in orders — a reminder that technical performance alone does not guarantee commercial survival. **Northvolt** filed for Chapter 11 in November 2024 and Swedish bankruptcy in March 2025; its SIB intellectual property was acquired by Lyten (a lithium-sulphur company) in August 2025. **Bedrock Materials** (a Stanford spinout) wound down due to cost competition from falling lithium prices.

**Peak Energy** is the sole remaining major US SIB commercial player, having secured a $500 million deployment deal with Jupiter Power for 4.75 GWh of grid storage through 2030 — the first large-scale US grid-scale SIB deployment. Their NFPP (Na₄Fe₃(PO₄)₂(P₂O₇)) cathode chemistry claims 30% less degradation than LFP in grid storage applications. In Europe, **Tiamat** and **Altris** (Sweden, developing Prussian white cathode with bio-derived hard carbon in a partnership with Clarios) continue to advance toward commercialisation. **Faradion** (now part of Reliance Industries India) is targeting the Indian two- and three-wheeler EV market and residential storage, with a Jamnagar gigafactory planned.

### Commercial Status Summary Table

| Company | Country | Cathode | Anode | Wh/kg | Cycle Life | Form Factor | Primary Application | Status (early 2026) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CATL (Naxtra) | China | Multi-element layered oxide | Hard carbon | 175 | >10,000 (claimed) | Prismatic | EV, grid storage | Mass production |
| HiNa | China | O3 NaCuFeMnO₂ | Hard carbon | 140–166 | 4,500–13,000+ (best reported) | Prismatic | Grid storage, heavy trucks | GWh production |
| BYD | China | Layered oxide (est.) | Hard carbon | 160 (target) | 10,000 (target) | Prismatic (est.) | EV | Pilot (30 GWh line) |
| Tiamat | France | NVPF | Hard carbon | 105 | 3,200 | 18650 cylindrical | High-power (freq. reg., power tools) | Pilot, 5 GWh planned |
| Peak Energy | USA | NFPP | Undisclosed | Undisclosed | Competitive | Prismatic (est.) | Grid storage | Early commercial |
| Altris | Sweden | Prussian white | Hard carbon | >160 | Undisclosed | Prismatic | Grid storage | Pilot production |
| Faradion | UK/India | O3 NaNiMnMgTiO₂ | Hard carbon | 150–160 | >1,000 | Pouch | Two/three-wheelers, residential | Pre-production |

---

## 14.3 The Research Ecosystem: Groups, Institutions, and the Chinese Factor

### Chinese Research Dominance: Understanding the Context

No serious engagement with the SIB research literature is possible without confronting the scale of Chinese research dominance. Scientometric analysis of 2000–2024 SIB publications identifies approximately 15,682 peer-reviewed papers, with China as the overwhelmingly dominant contributor. By early 2026, 16 of 20 planned SIB factories worldwide are located in China, and China accounts for an estimated 95% of global SIB manufacturing capacity. As of 2025, the Chinese government's 14th Five-Year Plan for Scientific and Technological Innovation explicitly lists SIB as a funded priority, and the National Key Technologies R&D Programme directly funds IOP-CAS SIB research (grant 2022YFB3807800). Provincial governments have signed production agreements for hundreds of GWh of capacity.

For an EE researcher in India or elsewhere, the practical implication is twofold. First, the literature you must engage with is predominantly Chinese in origin. Many of the most important recent results are published in Chinese-language journals (particularly *Energy Storage Science and Technology*, 储能科学与技术) or in English-language journals with Chinese first authors and Chinese institutional affiliations. Second, and more strategically important: Chinese research dominance in SIB is concentrated in materials science. The system-level engineering simulation work — ECM parameterisation, BMS algorithm development, pack-level degradation modelling, grid integration — is not where Chinese groups are primarily publishing. This is exactly the gap that an EE researcher is positioned to fill, and it is a gap that will remain open for several years even as materials research saturates.

### The Key Groups

**IOP-CAS, Beijing (Prof. Hu Yong-Sheng)**: The single most influential SIB research group globally. Hu's group bridges fundamental materials discovery with commercialisation through HiNa Battery. His publication record includes a landmark *Science* (2020) paper using machine learning to predict layered oxide compositions, multiple *Nature Energy* papers (2024 on interfacial engineering achieving >200 Wh/kg at the cell level; 2026 on a polymerisable non-flammable electrolyte achieving zero thermal runaway in 3.5 Ah cells), and extensive work on hard carbon anodes (416 mAh/g with P-O-C cross-linking, *Energy Storage Materials* 2024). Core group members Lu Yaxiang, Rong Xiaohui, and Qi Xingguo co-author nearly all major publications. Their HiNa cells are among the best-characterised commercial SIB cells and the best candidates for simulation validation work.

**ICCAS, Beijing (Prof. Guo Yuguo)**: Electrolyte innovations and interface engineering. Published a comprehensive review in *Chemical Society Reviews* (2024) covering gel polymer and quasi-solid electrolytes for SIBs — directly relevant to any simulation study that includes electrolyte transport physics.

**Wuhan University (Prof. Cao Yuliang)**: Polyanionic cathodes, tunnel-type oxides, and hard carbon anodes. Has published foundational work on hard carbon electrochemistry (>1,000 citations for the hollow carbon nanowire study, *Nano Letters* 2012). Also founded Jiana Energy for SIB cathode and anode production, providing a direct commercial application context.

**USTC, Hefei (Prof. Yu Yan)**: A prolific group spanning PBA cathodes, high-entropy alloy nanolayers for anode-free sodium metal batteries, and ML-assisted materials screening. Published the most comprehensive PBA modification study (Ni/Cu co-doping, *Advanced Materials* 2024).

**Tsinghua University (Prof. Zhang Qiang)**: Solid-state electrolytes and battery safety. Published a fluorinated polyether electrolyte enabling room-temperature solid-state SIB operation in *Nature* (2025) — directly relevant to thermal safety modelling.

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

**PyBaMM** (Python Battery Mathematical Modelling) is an open-source Python framework developed primarily at Oxford and now maintained by the PyBaMM team. It implements DFN, SPM, SPMe, and multiple degradation models for battery simulation. As of v24.11 (November 2024), it includes a working SIB DFN model via `pybamm.sodium_ion.BasicDFN()`, the `Chayambuka2022` parameter set (NVPF/HC, NaPF₆ in EC:PC electrolyte), an official example notebook demonstrating discharge simulation, OCV curves, concentration profiles, and overpotential decomposition (`pybamm.docs.sodium-ion`), support for electrochemical-thermal coupling using the same framework as Li-ion (requiring new SIB-specific parameter values), and PyBOP integration for parameter optimisation.

PyBaMM is the right tool for DFN and SPMe simulation, sensitivity analysis, model order reduction comparisons, and degradation model development. Its Python ecosystem makes it compatible with machine learning libraries (scikit-learn, PyTorch, TensorFlow) for hybrid physics-ML approaches. The PyBaMM Discourse forum and GitHub repository are active, and sodium-ion questions receive responses.

A minimal script to run the SIB DFN model. Verify the exact API against the current PyBaMM documentation at `docs.pybamm.org`, as class names and module paths may change between versions:

```python
import pybamm

# Verify current API at docs.pybamm.org — module paths may differ by version
model = pybamm.sodium_ion.BasicDFN()
param = pybamm.ParameterValues("Chayambuka2022")
sim = pybamm.Simulation(model, parameter_values=param)
sol = sim.solve([0, 3600])  # 1-hour discharge
sim.plot()
```

This runs on a laptop in under 30 seconds and produces terminal voltage, electrolyte concentration profiles, solid-phase concentrations, and overpotential decompositions. It is the starting point for essentially all physics-based SIB simulation research.

### COMSOL Multiphysics

COMSOL's Battery Design Module provides a downloadable "1D Isothermal Sodium-Ion Battery" model (Application Library path: `Battery_Design_Module/Batteries,_SodiumIon/sodium_ion_battery_1d`) using the same Chayambuka2022 parameters. COMSOL's advantage over PyBaMM is multi-physics coupling: 3D geometry, mechanical stress, complex thermal boundary conditions, and full Navier-Stokes electrolyte flow (for flow battery extensions). For 2D or 3D mechanical abuse simulations, nail penetration modelling, or thermal runaway propagation in three-dimensional pack geometries, COMSOL is the appropriate tool.

A COMSOL webinar series specifically addressing sodium-ion batteries and "emerging battery technologies" is available through COMSOL's learning centre. Contact resistance modelling was added in COMSOL 6.2.

### MATLAB/Simulink with Simscape Battery

MATLAB remains the dominant tool for BMS algorithm development — Kalman filters, extended Kalman filters, sigma-point Kalman filters, recursive least squares parameter identification, and equivalent circuit model simulation are all most naturally implemented in MATLAB. Plett's three-volume *Battery Management Systems* textbook (specifically Volumes I and II for ECM methods, Volume III for physics-based methods) provides MATLAB code for every algorithm developed in Chapters 10–12 of this textbook. The Coursera specialisation "Algorithms for Battery Management Systems" by Plett delivers hands-on MATLAB implementations of these algorithms.

MATLAB's Simscape Battery module provides a physics-based battery simulation environment suitable for pack-level electro-thermal simulation. It is chemistry-agnostic at the systems level and can be parameterised for SIBs using published characterisation data. The primary limitation is that it does not have a native SIB parameter set — parameterisation requires extracting values from the published literature and entering them manually.

### Other Tools

**LIONSIMBA** (Lithium-Ion Simulation BAttery toolbox) is an open-source MATLAB P2D finite-volume implementation whose clean numerical structure makes it a useful benchmark and algorithmic reference, even though it was developed for Li-ion. The equations are structurally identical for SIBs; parameter substitution is the only change required.

**BattMo** (Battery Modelling Toolbox) is an MRST-based open-source continuum modelling stack supporting 1D through 3D electrochemical-thermal models with automatic differentiation for sensitivity analysis and optimisation. It is actively developed and accepts contributions. The recent 2025 arXiv paper describes its capabilities for multi-physics battery simulation.

**PyBOP** (Python Battery Optimisation) is an open-source Python package for battery model parameter identification using deterministic and stochastic optimisation methods, including Bayesian parameter estimation. It interfaces directly with PyBaMM and enables publishable parameterisation pipelines with full uncertainty quantification.

### The Simulation Workflow

The recommended workflow for a simulation-first SIB paper follows a natural progression that mirrors the structure of the eventual paper itself. You begin by identifying a published SIB dataset from Section 14.5, or by using PyBaMM's synthetic data generation capability if no suitable experimental data exists. If your parameterisation requires data from published figures rather than raw numerical files, you digitise those curves using **WebPlotDigitizer** (automeris.io) — a step that many simulation researchers overlook but that is standard practice and methodologically accepted.

With data in hand, you build or adapt the model: PyBaMM for DFN or SPMe physics-based models, MATLAB for ECM-based BMS work. Parameter identification follows, using PyBOP's Bayesian estimation for PyBaMM models or MATLAB's `lsqcurvefit` for ECMs. The critical methodological discipline is to validate against held-out data — different temperatures, different C-rates, or different ageing states than those used for identification. A model validated only on its training data is not publishable.

With a validated model, you generate the publishable result: SOC estimation accuracy metrics, model-order comparison figures, degradation predictions, or thermal behaviour characterisation. Finally — and this step disproportionately increases citation impact — you document the code and upload it to GitHub or Zenodo with a CC BY licence. In a nascent field like SIB simulation, open-source code is not just good practice; it is the mechanism by which your work becomes the foundation that later researchers build on.

---

## 14.5 Open Datasets: What Is Available and How to Use It

SIB datasets are scarce compared to Li-ion. Only five substantive open SIB experimental datasets existed as of early 2026, compared to fifteen or more major open Li-ion datasets. This scarcity is both a challenge and an opportunity: the scarcity is itself a publishable observation, and strategies for working around it constitute part of any simulation paper's methodological contribution.

### SIB-Specific Datasets

**Wang et al. 2024 — Zenodo 13836819**: The single most valuable open SIB dataset, deposited in late 2024. Contains pulse characterisation at 0.25C–3C current rates and six temperatures (−5°C to 45°C) covering the full SOC range (0%–100% in 10% increments), plus FUDS, UDDS, and DST driving cycle data, for two commercial SIB cells: a **Transimage 3.2 Ah** layered oxide/hard carbon cell and a **HiNa 10 Ah** layered oxide/hard carbon cell. Six cell samples per type. Total data size approximately 256 MB. Licence: CC BY 4.0. This dataset is the primary target for any SIB SOC estimation paper, ECM parameterisation study, or temperature-dependent modelling work. If you do one thing before your first SIB simulation paper, download and explore this dataset.

**BatteryLife NaIon Subset — Zenodo 14934405**: Part of a large 998-cell multi-chemistry cycling dataset (from the KDD 2025 competition), including 18650 cylindrical SIB cells (Zhuhai Punashidai cells at 2C–6C cycling rates, 2.0–4.0 V window, 25°C). Best used for battery lifetime prediction and cross-chemistry transfer learning.

**Iontech SIB Characterisation — GitHub**: An open-source comparative characterisation dataset containing two commercial layered oxide/HC SIB cells alongside an LFP reference cell. Includes OCV curves, galvanostatic EIS at multiple SOC levels, DC resistance tests, and rate capability curves. Well-suited for ECM parameterisation and impedance modelling, and for the SIB-vs-LIB comparison that gives any SIB paper its context.

**Laufen et al. 2024 — Cell Reports Physical Science (OA)**: A detailed characterisation of a commercial 1.2 Ah 18650 sodium-ion cell (NaFeMnCu oxide/HC, likely from a Chinese manufacturer), including EIS at 21 SOC levels, C-rate tests (0.1C to 5C), cyclic ageing with micro-CT imaging, and electrode porosity/thickness measurements from post-mortem physical analysis. The supplementary data PDF provides the numbers directly usable for DFN parameterisation. Licence: CC BY 4.0.

**Droese et al. 2025 — depositonce.tu-berlin.de**: A recent dataset that includes HPPC tests, OCV measurements, and checkup capacity measurements across multiple temperatures for a commercial SIB cell alongside LIB baselines. This is particularly well-suited for ECM fitting (extracting $R_0$, $R_1$, $C_1$, $R_2$, $C_2$ as functions of SOC and temperature) and for temperature-dependent thermal modelling.

### Li-Ion Datasets for Methodology Transfer

Because SIB datasets are scarce, a common and methodologically defensible approach is to develop and validate algorithms on well-characterised Li-ion datasets first, then demonstrate transferability to SIBs using the available SIB data. This "develop on Li-ion, transfer to Na-ion" approach has been explicitly validated: PyBaMM confirms that the DFN model structure — the coupled PDE system for solid-phase diffusion, electrolyte transport, and Butler-Volmer kinetics — is mathematically identical for Li-ion and Na-ion, with different parameter values. The important caveat is that the standard DFN assumes a single intercalation mechanism in each electrode, which is a good approximation for graphite but only partially captures hard carbon's two-mechanism storage (intercalation in the slope region and pore-filling in the plateau region, as discussed in Chapter 13). For the purposes of methodology transfer — developing algorithms, testing estimation frameworks, benchmarking model-order reduction — the structural identity holds. For precision parameterisation of the hard carbon anode, more detailed models may eventually be needed. The Laufen et al. paper explicitly states that LIB characterisation methods transfer to SIBs.

The most valuable Li-ion datasets for this transfer learning approach:

**Severson et al. (Stanford/MIT/Toyota)** — data.matr.io/1: 124 LFP/graphite cells, 72 fast-charging protocols, 4C discharge, 30°C. The richest single dataset for machine learning lifetime prediction; features extracted from early cycles predict long-term cycle life. Pre-training a degradation model on this dataset before fine-tuning on the limited SIB data is one of the most productive transfer-learning strategies available.

**228-cell NMC Ageing Dataset** — Nature Scientific Data 2024 (LG INR18650HG2): 228 cells under 76 conditions, covering calendar ageing, cyclic ageing, and drive-cycle ageing at 0–40°C with 2-second resolution. The most comprehensive single aging dataset available; ideal for pre-training degradation models before adaptation to SIBs.

**CALCE** (University of Maryland) — calce.umd.edu/battery-data: 100+ cells across LCO, LFP, NMC; partial cycling, storage ageing at −40°C to 50°C, OCV tests. Best for SOH estimation methodology development.

**NASA PCoE** — NASA data portal: ~34 Li-ion 18650 cells at 4/24/43°C, with EIS. Classic RUL prediction benchmark; ECM structure transfers directly to SIBs.

### Synthetic Data from PyBaMM

When experimental data is unavailable, PyBaMM's `Chayambuka2022` DFN model can generate physically consistent synthetic SIB data for any C-rate, temperature profile, or ageing scenario. This approach — using a validated physics-based model to generate synthetic training and validation data — is accepted in JES, Electrochimica Acta, Batteries, and Journal of Energy Storage when the synthetic data generation process is transparent and the model is properly cited. The Garapati et al. (2025) *Electrochimica Acta* paper demonstrates this approach for a Q1 journal publication.

---

## 14.6 Publication Venues: Where to Publish SIB Simulation Work

Not all journals welcome simulation-only battery papers, and the publication strategy for a researcher with no wet-lab access must be calibrated carefully. The table below summarises the key venues, their simulation policies, and their SIB track records. *This is the single most practically important table in this chapter.*

| Venue | Impact Factor | Sim-Only? | SIB Papers Found? | Best EE Angle |
| --- | --- | --- | --- | --- |
| IEEE Trans. Smart Grid | 8.6 | ✅ Yes | BESS papers, no SIB yet | Microgrid integration, dispatch optimisation |
| IEEE Access | 3.6 | ✅ Yes (most lenient) | Li-ion SOC reviews | ECM/SOC algorithms for SIB |
| IEEE Trans. Transport. Electrif. | 7.0 | ⚠ Possible | Related BMS papers | SIB BMS for EVs |
| IEEE Trans. Industrial Electronics | 7.2 | ⚠ Very limited | Li-ion SOC/SOH | Strongly prefers experimental validation |
| J. Energy Storage (Elsevier) | 8.1 | ✅ Yes | **Multiple SIB ECM/SOC** | ECM, SOC/SOH, BMS |
| Applied Energy (Elsevier) | 11.2 | ✅ Yes | SIB techno-economic | Grid integration, system-level |
| eTransportation (Elsevier) | 16.6 | ✅ Yes | Li-ion BMS, growing SIB | EV thermal/BMS modelling |
| J. Power Sources (Elsevier) | 7.9 | ⚠ Conditional | SIB modelling refs | Validated P2D/ECM |
| J. Electrochem. Society (ECS) | 3.3 | ✅ Yes | **SIB P2D papers** | P2D, SPM, electrochemical modelling |
| Electrochimica Acta (Elsevier) | 5.5 | ✅ Yes | **SIB DFN/SPMe comparison** | Physics-based model comparison |
| Batteries (MDPI) | 4.8 | ✅ Yes | **SIB SOC (LSTM+UKF)** | BMS, SOC, thermal, any modelling |
| Energies (MDPI) | 3.0 | ✅ Yes | SIB safety/characterisation | System-level, grid, power engineering |

The most simulation-friendly Tier 1 venues for EE SIB work are **Journal of Energy Storage** (IF 8.1, proven SIB ECM home, 40–50% acceptance for well-executed simulation), **Applied Energy** (IF 11.2, system-level simulation standard, SIB grid integration papers appearing since 2024), and **Electrochimica Acta** (IF 5.5, simulation-only explicitly accepted, DFN comparison paper published 2025). **IEEE Transactions on Smart Grid** (IF 8.6) has no SIB papers yet — which means the first SIB simulation papers here will face zero competition and benefit from first-mover citation advantage.

For conference publications to build a track record: **IEEE VPPC** (Rabab et al. 2023 first SIB IEEE paper, ~50% acceptance), **IECON** (Sandri et al. 2024, ~45–55% acceptance), and **ITEC** (SOC estimation papers, ~50–60% acceptance). These IEEE conferences accept simulation papers and provide peer-reviewed publication credit comparable to journal papers for conference proceedings.

**MDPI Batteries** deserves special mention for early-career researchers: IF 4.8, dedicated BMS simulation section, ~19-day median first decision, 50–65% acceptance rate, and it has already published SIB SOC estimation papers. It is the fastest legitimate path to a first SIB journal publication.

**Journals to avoid for EE simulation work**: Journal of Energy Chemistry (IF 14.9, materials only), Energy Storage Materials (IF 18–20, materials only), Nano Energy (IF 17.9, materials only), eScience (IF 42.9 — inflated by a small article base in its early years; materials-focused despite the name). The high impact factors of these venues are irrelevant — they will desk-reject simulation-only engineering papers.

### Practical Submission Advice for Simulation-Only Papers

Three mistakes sink simulation-only battery papers at the review stage, and all three are avoidable. First, failing to validate against experimental data. Even if your entire simulation uses synthetic data from PyBaMM, you must demonstrate that the underlying model (which generated the synthetic data) has been validated against real experimental measurements — cite the Chayambuka2022 validation or the Garapati et al. comparison. A simulation paper with no connection to experimental reality will be desk-rejected at every venue except MDPI.

Second, omitting sensitivity analysis. Reviewers of simulation papers invariably ask "how sensitive are your results to parameter uncertainty?" If you have not performed at least a local sensitivity analysis (and ideally a global one using Sobol indices — see Proposal 6), you will receive a major revision request. Build sensitivity analysis into your methodology from the start.

Third, framing the paper as a Li-ion methods paper that happens to use SIB parameters. Reviewers want to see SIB-specific insight: what is different about this problem for sodium-ion? What fails, what works better, what requires modification? If your paper's contribution would be identical for any battery chemistry, it is a methods paper, not an SIB paper — and the venue selection and framing must reflect that distinction.

---

## 14.7 The Research Gaps: Thirteen Areas Where SIB Simulation Is Empty

This section maps the thirteen most important research gaps in SIB simulation, ordered roughly from most-urgent to most-ambitious. Each gap description establishes the current state of the literature, identifies the Li-ion analogue that has not been ported, and characterises the contribution an EE simulation researcher can make. These gaps were identified through systematic analysis of the SIB simulation literature through early 2026 and form the basis of the 25 concrete proposals in Section 14.8.

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

No paper has addressed SIB cell balancing simulation (passive or active). No paper has implemented incremental capacity analysis (ICA, $dQ/dV$ diagnostics) for SIB cells. No formal SIB FMEA exists in the published literature. No power limit calculation framework adapted to SIB's higher DCIR and different temperature characteristics exists. The CATL "Freevoy" hybrid SIB+LFP pack concept — which requires a BMS that manages two chemistries with different OCV curves, different temperature responses, and different ageing rates simultaneously — has received no simulation treatment whatsoever.

### Gap 7: Grid Integration and Energy Management

SIB cost and performance advantages (lower material cost, better low-temperature performance, wide operating temperature range, potential for 0 V discharge for transport) create distinct grid storage use cases that have never been quantitatively modelled. No SIB-specific grid dispatch optimisation study exists. No degradation-aware energy management system for SIB BESS has been published. No SIB frequency regulation study exists (despite Tiamat's cells being specifically marketed for this application). No lifetime cost modelling that properly accounts for SIB's cycle life advantage relative to LFP has appeared.

### Gap 8: Fast Charging Optimisation

CATL claims 5C charging for Naxtra (80% SOC in 15 minutes). Tiamat claims 35C capability. Fast charging is one of SIB's differentiating advantages over LFP, but no model predictive control (MPC) or optimised charging protocol has been developed for SIB. The constraint structure for SIB fast charging differs from Li-ion: the primary hard constraint is the sodium plating onset (anode potential approaching 0 V vs. Na/Na⁺), which depends on temperature, SOC, and the hard carbon's two-mechanism storage. An MPC framework that explicitly uses the DFN model to enforce the plating constraint while maximising charging speed represents a novel and commercially relevant contribution.

### Gap 9: Low-Temperature Performance Modelling

SIB's low-temperature advantage is real and well-documented experimentally (CATL Naxtra at 93% at −30°C; HiNa at 70% at −40°C) but has not been modelled computationally. No simulation study has quantified the physical origin of the low-temperature advantage through the Butler-Volmer framework (as Chapter 13 established qualitatively). The activation energy difference between carbonate-electrolyte SIBs (no significant advantage) and ether-electrolyte SIBs (4–5× smaller $R_\text{ct}$ growth factor at −20°C) has not been parameterised in a DFN or ECM simulation context.

### Gap 10: Hybrid and Second-Life Applications

CATL's hybrid SIB+LFP pack is commercially deployed but completely unmodelled in simulation. No energy management strategy for a heterogeneous chemistry pack has been published. Second-life SIB battery applications (repurposing end-of-life SIB packs, which will begin appearing in volume around 2028–2030 from early deployments) have received no techno-economic or simulation treatment. SIB second-life analysis would be one of the first papers in this area globally.

### Gap 11: Machine Learning and Data-Driven Approaches

No Transformer-based SOH estimation has been applied to SIBs. No transfer learning study has demonstrated the Li→Na chemistry transfer for degradation modelling (despite PyBaMM confirming structural model identity). No physics-informed neural network (PINN) has been developed for SIB state estimation, despite PINN being an active frontier for Li-ion. No Gaussian process regression-based RUL prediction exists for SIBs.

### Gap 12: Digital Twins

No SIB digital twin framework exists. A digital twin — a continuously updated simulation model whose parameters evolve with measured cell behaviour in real time — requires the combination of ECM or DFN modelling, Kalman filter-based parameter identification, and connection to real-time sensor data. For Li-ion, digital twins are now commercially deployed in several EV platforms. For SIB, the first paper to propose and demonstrate a digital twin architecture (even using synthetic data from PyBaMM to represent the "real" cell) will be the defining reference in this space.

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
Simulate an SIB BESS (10 MW/20 MWh) responding to a real frequency regulation signal (PJM RegD signal, publicly available) and compare performance, revenue, and degradation cost against an LFP BESS with equivalent energy capacity. SIB's 5C sustained rate capability (vs LFP's 1–2C) should produce substantially higher frequency regulation performance scores under PJM's pay-for-performance framework. This is the first SIB frequency regulation simulation anywhere. Target: **IEEE Transactions on Smart Grid** or **Applied Energy**.

### Ambitious Track (6–12 months, Tier 1, no hardware)

**Proposal 11: Multi-Mechanism Degradation Model for SIB**
Build the first comprehensive physics-based degradation model for SIBs, incorporating: SEI growth on hard carbon (parabolic $\sqrt{t}$ law, Arrhenius temperature dependence); O3→P3 phase transition fatigue in the cathode (damage accumulation as a function of desodiation depth); sodium plating on hard carbon (onset criterion based on local anode potential, plating rate from Butler-Volmer); hard carbon structural evolution (gradual change in $D_s$ and OCV shape over cycling). Implement in PyBaMM using the existing degradation framework. Validate each mechanism independently against published experimental data. Target: **Journal of Power Sources**.

**Proposal 13: Transfer Learning Li→Na for SOH Estimation**
Pre-train a capacity fade prediction model on the 228-cell NMC ageing dataset (Nature Scientific Data 2024), then fine-tune on the limited SIB ageing data (BatteryLife NaIon subset, Laufen et al. cyclic ageing). Compare against a model trained from scratch on SIB data only. Demonstrate that transfer learning closes the SIB data scarcity gap. Use domain adaptation techniques to account for the chemistry differences. Target: **Applied Energy**.

**Proposal 14: Physics-Informed Neural Network (PINN) for SIB State Estimation**
Implement a PINN for SIB state estimation: the neural network predicts terminal voltage, with the DFN governing equations enforced as physics constraints in the training loss. This approach combines the flexibility of data-driven methods with the physical validity guarantees of physics-based models — particularly valuable for SIBs where data is scarce and the physics constraints prevent overfitting. Validate against the Wang et al. Zenodo dataset. Target: **Applied Energy** (where PINN for batteries papers are beginning to appear).

**Proposal 15: MPC Optimal Fast Charging Protocol for SIB**
Formulate a model predictive control (MPC) problem for SIB fast charging: maximise charging speed (minimise time to target SOC) subject to hard constraints on cell temperature ($T < 50°C$), terminal voltage ($V < V_\text{max}$), and anode potential remaining above the sodium plating threshold (the local anode overpotential $\eta_\text{anode} = \phi_s - \phi_e - U_\text{eq,anode} > 0$, ensuring sodium metal deposition does not become thermodynamically favourable). Implement in MATLAB using the SPMe as the prediction model (Proposal 7 provides the SPMe). Demonstrate 15–30% reduction in charging time compared to CC-CV at the same safety constraints, across temperatures from 0°C to 45°C. Target: **eTransportation**.

**Proposal 19: SIB Digital Twin Framework**
Design and implement the first SIB digital twin: an architecture that continuously updates an ECM or reduced-order electrochemical model from streaming current-voltage data using a dual EKF (one filter for state estimation, one for parameter identification). Demonstrate the framework on synthetic data generated from PyBaMM (with deliberately introduced parameter drift to represent ageing), tracking capacity fade and resistance rise over simulated years of operation. Define the software architecture, data flow, and computational requirements. Target: **Applied Energy** or **eTransportation**.

**Proposal 20: Grid Dispatch Optimisation for SIB BESS**
Formulate a stochastic optimal dispatch problem for a grid-scale SIB BESS (100 MW/400 MWh, representative of the Jupiter Power/Peak Energy deployment): maximise revenue from energy arbitrage and ancillary services subject to degradation constraints, temperature-dependent power limits, and SIB-specific cycling constraints. Compare the optimal dispatch strategy for SIB vs LFP under real electricity price and ancillary service price data (ISO-NE or PJM market data, publicly available). Target: **IEEE Transactions on Smart Grid**.

**Proposal 21: Hybrid Li/Na Pack Energy Management**
Model CATL's "Freevoy" hybrid SIB+LFP pack: cells of two different chemistries in the same series string, with different OCV curves, different DCIR, different temperature characteristics, and different ageing rates. Develop a state estimation framework that maintains separate SOC estimates for SIB and LFP cells simultaneously, a balancing strategy that accounts for their different OCV shapes, and an energy management strategy that dispatches the SIB cells preferentially in conditions where they have the performance advantage (low temperature, high power demand) and the LFP cells preferentially where they have the advantage (high energy demand, moderate temperature). Target: **eTransportation**.

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

**Proposal 19** (SIB Digital Twin) — the first digital twin framework for SIBs will be the reference paper for all subsequent digital twin implementations in SIB systems. Even a conceptual framework demonstration on synthetic PyBaMM data establishes the architecture that later papers will build on. Applied Energy or eTransportation.

**Proposal 21** (Hybrid SIB+LFP Pack) — CATL's Freevoy is deployed in real vehicles. The first energy management paper for a heterogeneous chemistry pack addresses a commercially deployed product and will be cited by every subsequent Freevoy modelling paper. eTransportation.

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

- **The landscape in brief:** The SIB commercial ecosystem has crossed the threshold from research to commercial reality: CATL Naxtra at 175 Wh/kg and >10,000 claimed cycles, HiNa at GWh-scale production with 100 MWh grid deployments, Tiamat offering the highest-power commercial SIB at 35C discharge. The Chinese research and industrial ecosystem dominates production (95% of manufacturing capacity) but is focused primarily on materials science. The engineering simulation literature — ECM parameterisation, state estimation, degradation modelling, thermal simulation, pack management, grid integration — is almost entirely absent.
- **The open-source toolkit is ready:** PyBaMM `pybamm.sodium_ion.BasicDFN()` with `Chayambuka2022` parameters, COMSOL's 1D Na-ion model, MATLAB/Simulink for BMS algorithms, PyBOP for parameter identification, and WebPlotDigitizer for data extraction from published curves.
- **Five open SIB datasets** are available: Wang et al. Zenodo 13836819 (primary), BatteryLife NaIon subset, Iontech characterisation, Laufen et al. (2024), and Droese et al. (2025) with supplementary data. These datasets, combined with the 228-cell NMC and Severson et al. LFP datasets for methodology development, are sufficient to support a full research portfolio.
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

3. **Wang, Y. et al., SIB SOC Estimation Dataset, Zenodo ID: 13836819 (2024–2025).** The primary experimental dataset for SIB BMS algorithm development. Download and explore this dataset before beginning any SOC estimation paper. The README describes the measurement protocol, the cell specifications, and the data format. The dataset's existence means that Proposals 1, 2, 12, and 16 can begin immediately without purchasing cells.

4. **Laufen, T. et al., "Multi-method characterisation of a commercial 1.2 Ah 18650 sodium-ion battery cell," *Cell Reports Physical Science* (2024).** The most comprehensive published characterisation of a commercial SIB cell, including EIS at 21 SOC levels, micro-CT imaging, and post-mortem physical analysis. Supplementary data provides numbers directly usable for ECM and DFN parameterisation. This paper is the experimental reference for Proposals 3, 4, 8, and 9.

5. **Sulzer, V. et al., "Python Battery Mathematical Modelling (PyBaMM)," *Journal of Open Research Software* 9 (1), 14 (2021).** The PyBaMM software paper — cite this alongside the `Chayambuka2022` parameter set whenever using PyBaMM's sodium-ion DFN. The paper describes the software architecture, the model library, and the validation approach. The PyBaMM GitHub repository (github.com/pybamm-team/PyBaMM) and Discourse forum (pybamm.discourse.group) are the primary technical support resources for anyone building SIB simulations with PyBaMM.

6. **Plett, G. L., *Battery Management Systems, Volume I: Battery Modeling* and *Volume II: Equivalent-Circuit Methods*, Artech House (2015).** The EE-canonical reference for every ECM, Kalman filter, and state estimation algorithm referenced in this chapter's proposals. If you are implementing Proposals 1, 2, 3, 4, 5, or 17, Plett's MATLAB code — available through his Coursera specialisation "Algorithms for Battery Management Systems" — provides tested starting implementations that you can adapt for SIB parameters. These are the books to have open on your desk alongside PyBaMM documentation.

---

*This is the final chapter of the book. You now have the physics, the chemistry, the engineering, and the research roadmap. The battery technology field — and specifically the sodium-ion simulation sub-field — is ready for exactly the kind of rigorous, open, simulation-based research that a well-trained electrical engineer can produce. Begin.*

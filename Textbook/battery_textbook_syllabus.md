# Battery Technology for Electrical Engineers: A Self-Study Curriculum

**Target duration:** 8–10 weeks part-time (roughly 8–12 hours/week)  
**Prerequisites:** Undergraduate EE (circuits, linear algebra, ODEs, basic control theory)  
**Goal:** Fluency in battery literature and readiness to begin SIB simulation research  

---

## Part I: Foundations (Weeks 1–2)

### Chapter 1: Electrochemistry for Engineers  

**Learning objective:** Read a half-reaction and understand what's physically happening.

1.1 What is a battery? Galvanic vs electrolytic cells  
1.2 Oxidation, reduction, and half-reactions  
1.3 Anode, cathode, electrolyte, separator, current collector — anatomy of a cell  
1.4 Standard electrode potentials and the electrochemical series  
1.5 The Nernst equation and what it predicts  
1.6 Activity vs concentration (and why the distinction matters later)  
1.7 Faraday's laws of electrolysis — linking charge to mass  
1.8 Gibbs free energy and cell voltage  

**Deliverable:** Write out the half-reactions for a Li-ion cell (graphite/LCO) and a Na-ion cell (hard carbon/layered oxide). Calculate theoretical cell voltage from standard potentials.  

**Primary source:** Atkins, Physical Chemistry, electrochemistry chapter. Supplement with Huggins, Advanced Batteries, Ch. 1–2.  

---

### Chapter 2: How a Battery Works in Operation  

**Learning objective:** Explain, without equations, what happens inside a cell during charge and discharge.

2.1 Intercalation — the guest-host mechanism  
2.2 Why intercalation hosts matter (layered, spinel, olivine, polyanionic structures)  
2.3 The solid-electrolyte interphase (SEI): formation, function, consequences  
2.4 The electric double layer and double-layer capacitance  
2.5 Charge transfer kinetics at the electrode-electrolyte interface  
2.6 Mass transport: diffusion, migration, convection  
2.7 Kinetic vs transport limitations — which dominates when  
2.8 Introduction to the Butler-Volmer equation (intuition only; derivation comes later)  

**Deliverable:** Draw a labeled diagram of a Li-ion cell during discharge showing ion flow, electron flow, and where each loss mechanism occurs.  

**Primary source:** Huggins, Advanced Batteries, Ch. 3–4. Reddy's Linden's Handbook of Batteries Ch. 1 for breadth.  

---

## Part II: The Language of Batteries (Week 3)

### Chapter 3: Performance Metrics and Terminology  

**Learning objective:** Read a commercial cell datasheet and interpret every number and curve.

3.1 Capacity (Ah) vs energy (Wh); specific vs volumetric  
3.2 C-rate and what "1C" actually means  
3.3 State of charge, depth of discharge, state of health  
3.4 Open-circuit voltage vs terminal voltage; why OCV curve shape matters for BMS  
3.5 Internal resistance and the three polarizations (ohmic, activation, concentration)  
3.6 Coulombic, voltage, and energy efficiency  
3.7 Cycle life vs calendar life; what counts as "a cycle"  
3.8 Self-discharge  
3.9 CC-CV charging protocol  
3.10 Characterization tests: HPPC, GITT, PITT, EIS — what each measures and why  

**Deliverable:** Download a CATL or Samsung cell datasheet and a HiNa SIB datasheet. Write a one-page interpretation of each, explaining every graph and specification in your own words.  

**Primary source:** Battery University articles (free, online). Plett, Battery Management Systems Vol. 1, Ch. 1–2.  

---

## Part III: Cells and Chemistries (Week 4)

### Chapter 4: Cell Construction  

**Learning objective:** Know how a cell is physically built and why construction choices matter.

4.1 Form factors: cylindrical (18650, 21700, 4680), pouch, prismatic  
4.2 Electrode manufacturing: slurry, coating, calendaring, slitting  
4.3 Formation cycling and why first cycles differ  
4.4 Current collectors (Cu, Al) and why SIB can use Al on both sides  

---

### Chapter 5: Lithium-Ion Chemistry Families  

**Learning objective:** Name the major Li-ion chemistries and their tradeoffs without looking them up.

5.1 LCO, LFP, NMC, NCA, LMO, LTO — cathodes and anodes  
5.2 Energy, power, safety, cost, cycle life tradeoffs  
5.3 Which chemistry wins in which application (EV, grid, consumer, power tool)  

---

### Chapter 6: Sodium-Ion Chemistry Families  

**Learning objective:** Map the SIB landscape and identify which chemistries are commercialized.

6.1 Cathodes: layered oxides (O3, P2 types), polyanionic (NVPF, NFPP), Prussian blue analogues  
6.2 Anodes: hard carbon (dominant), soft carbon, alloys, titanates  
6.3 Electrolytes and why SIB electrolytes differ from Li-ion  
6.4 Commercial cells: CATL, HiNa, Faradion/Reliance, Natron, Altris, Tiamat  
6.5 Why Na+ is harder to work with than Li+ (larger ion, different host requirements)  

**Deliverable:** Build a comparison table of five commercial SIB cells vs five commercial Li-ion cells across all Chapter 3 metrics.  

**Primary source:** Reddy, Linden's Handbook of Batteries. For SIB: Hu Yong-Sheng review papers (search Google Scholar, read his two most-cited SIB reviews from 2018 onward).  

---

## Part IV: Why Batteries Die (Week 5)

### Chapter 7: Degradation Mechanisms  

**Learning objective:** Explain the physical origin of capacity fade and power fade in a specific cell under specific operating conditions.

7.1 The three modes: loss of lithium/sodium inventory, loss of active material, impedance growth  
7.2 SEI growth — the dominant calendar aging mechanism  
7.3 Lithium/sodium plating — when and why  
7.4 Particle cracking and mechanical fatigue  
7.5 Transition metal dissolution and crosstalk  
7.6 Electrolyte decomposition and gas generation  
7.7 Calendar aging vs cycle aging — different physics, different models  
7.8 Stressors: temperature, SOC, DOD, C-rate, voltage limits  

**Deliverable:** Read Birkl et al. (2017) "Degradation diagnostics for lithium ion cells" twice. Write a one-page summary in your own words identifying which mechanisms are diagnosable from external measurements alone.  

**Primary source:** Birkl et al. 2017 review. Supplement with Vetter et al. 2005 — older but foundational.  

---

## Part V: Thermal Behavior (Week 6, first half)

### Chapter 8: Heat in Batteries  

**Learning objective:** Predict whether a cell will overheat under a given duty cycle.

8.1 Sources of heat generation: ohmic, polarization, entropic (reversible)  
8.2 Bernardi's equation for heat generation  
8.3 Heat transfer out of a cell; thermal time constants  
8.4 Safe operating windows and why they exist  
8.5 Thermal runaway: triggers, stages, propagation  
8.6 Why low temperature hurts performance and high temperature accelerates aging  
8.7 Why SIB is safer than Li-ion (and how to quantify that)  

**Deliverable:** Hand-calculate steady-state heat generation for a commercial cell at 1C discharge using datasheet internal resistance. Compare to a rough convective cooling estimate.  

---

## Part VI: Battery Systems and BMS (Weeks 6–8)

### Chapter 9: Pack Architecture  

9.1 Series and parallel configurations; nomenclature (e.g., 96s2p)  
9.2 Cell-to-cell variation and its consequences  
9.3 Contactors, precharge, fuses, current sensing  
9.4 CAN bus and BMS communication basics  

---

### Chapter 10: State Estimation  

**Learning objective:** Understand why SOC estimation is non-trivial and what each method trades off.

10.1 Coulomb counting and its drift problem  
10.2 OCV-based SOC lookup and why flat OCV curves (SIB hard carbon!) break it  
10.3 Model-based estimation: the ECM + Kalman filter approach  
10.4 SOH estimation: capacity vs resistance based  
10.5 Remaining useful life (RUL) prediction  

---

### Chapter 11: Cell Balancing  

11.1 Why cells drift; consequences of imbalance  
11.2 Passive balancing (resistive bleed)  
11.3 Active balancing topologies  
11.4 When to balance (top, bottom, or throughout)  

---

### Chapter 12: Functional Safety (Brief)  

12.1 ISO 26262 and ASIL ratings — awareness level only  
12.2 BMS failure modes and protective functions  

**Deliverable:** Complete Plett's Coursera specialization "Algorithms for Battery Management Systems," Courses 1 and 2 at minimum. Work through the MATLAB assignments even if loosely.  

**Primary source:** Plett, Battery Management Systems Vol. 1 and Vol. 2. This is the EE-friendly canonical text — read it cover to cover during this part.  

---

## Part VII: Sodium-Ion Deep Dive (Weeks 9–10)

### Chapter 13: What's Different About Sodium  

**Learning objective:** Identify every place existing Li-ion modeling and BMS methods need adaptation for SIB.

13.1 Na+ vs Li+: ionic radius, mass, standard potential, diffusion  
13.2 Hard carbon anode behavior: the slope region vs the plateau region  
13.3 Why the plateau breaks OCV-based SOC estimation  
13.4 Al current collectors on both sides — cost and implications  
13.5 Low-temperature advantage — physical origin  
13.6 Safety advantage — physical origin  
13.7 SEI differences in SIB  
13.8 Degradation modes unique to or amplified in SIB  

---

### Chapter 14: The SIB Research Landscape  

14.1 Major research groups (Hu Yong-Sheng, Tarascon, Passerini, Palacín, Adelhelm)  
14.2 Chinese research dominance — where to look (CNKI, IOP-CAS, Chinese journals)  
14.3 Commercial landscape update (who shipped what in 2025–2026)  
14.4 Where the open problems are — and which are addressable by EE simulation  

**Deliverable:** Read three recent (2024–2026) SIB review papers. Produce a personal "open questions" document listing every problem mentioned as unsolved, tagged by whether it's a materials problem or a systems/modeling problem.  

**Primary source:** Hu Yong-Sheng reviews. Recent Nature Energy and Joule review articles on SIB. Faraday Institution SIB reports if available.

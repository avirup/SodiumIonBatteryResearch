# Battery Technology for Electrical Engineers (and Sodium-Ion Focus)

This repo contains a self-study, engineering-first battery textbook written for electrical engineers who want to understand (and model) modern rechargeable batteries—especially **sodium-ion batteries (SIBs)**—without having to “become a chemist first”.

The text builds a translation layer from familiar EE concepts (energy, RC dynamics, impedance, estimation) to battery concepts (half-reactions, overpotentials, diffusion limits, SEI, degradation), with the explicit goal of getting you fluent enough to read battery papers and start simulation/modeling research.

## Who this benefits

- **Electrical engineers** transitioning into battery research or battery systems work (BMS, pack engineering, modeling).
- **Graduate students** who need a structured ramp into the battery literature (Li-ion first, then SIB).
- **Simulation-focused researchers** who need the physical meaning behind common model parameters and measurements.
- **Practicing engineers** who want to read a cell datasheet and understand the “why” behind the curves.

## Prerequisites

- Undergraduate EE: circuits, basic linear algebra, ODEs, and comfort with units.
- Helpful (not required): basic thermodynamics intuition (Gibbs free energy, equilibrium).

## How to use this repo

- Read the chapters in order (`battery_textbook_chapter1_edited.md` → `battery_textbook_chapter7_edited.md`).
- Follow the self-study plan in `battery_textbook_syllabus.md`.
- Treat the deliverables in the syllabus as checkpoints; they’re designed to force “active” understanding.

## Repo contents

- `battery_textbook_chapter1_edited.md` — Electrochemistry for engineers (half-reactions, Nernst, Faraday, voltage as free energy)
- `battery_textbook_chapter2_revised.md` — What happens inside a working cell (SEI, kinetics, transport, overpotentials)
- `battery_textbook_chapter3_revised.md` — Metrics + terminology (C-rate, OCV, resistance, efficiency, HPPC/GITT/PITT/EIS)
- `battery_textbook_chapter4_revised.md` — Cell construction (form factors, electrodes, formation, manufacturing ↔ model parameters)
- `battery_textbook_chapter5_revised.md` — Lithium-ion chemistry families and tradeoffs (LCO/LFP/NMC/NCA/LMO/LTO, application fit)
- `battery_textbook_chapter6_revised.md` — Sodium-ion chemistry families (why SIB, cathodes/anodes/electrolytes, commercialization landscape)
- `battery_textbook_chapter7_edited.md` — Degradation mechanisms (inventory loss, active material loss, impedance growth; diagnosis mindset)
- `battery_textbook_syllabus.md` — 8–10 week self-study curriculum (with deliverables and suggested sources)

## Brief syllabus (8–10 weeks, part-time)

This is the short version of `battery_textbook_syllabus.md`.

### Part I — Foundations (Weeks 1–2)

- **Ch. 1:** Electrochemistry for engineers (half-reactions, potentials, Nernst, Faraday, Gibbs free energy → voltage)
- **Ch. 2:** How a battery works in operation (intercalation, SEI, double layer, kinetics vs diffusion limits; Butler–Volmer intuition)

### Part II — The language of batteries (Week 3)

- **Ch. 3:** Performance metrics + test methods (capacity/energy, C-rate, SOC/SOH, resistance/polarization, CC–CV, HPPC/GITT/PITT/EIS)

### Part III — Cells and chemistries (Week 4)

- **Ch. 4:** Cell construction + manufacturing choices that drive performance and modeling parameters
- **Ch. 5:** Li-ion families and application tradeoffs (energy–power–safety–cost–life “Pareto” thinking)
- **Ch. 6:** Sodium-ion families and why they matter (cost/supply chain; hard carbon + SIB-specific implications)

### Part IV — Why batteries die (Week 5)

- **Ch. 7:** Degradation taxonomy and mechanisms; how to reason from external measurements to internal causes

### Part V+ (Weeks 6–10, planned/outlined in the syllabus)

The syllabus also outlines an extension track covering thermal behavior, pack architecture, BMS estimation/balancing/safety, and a deeper SIB research landscape review.

## Status / scope note

The repo currently contains Chapters **1–7** plus a longer curriculum outline that sketches Chapters **8–14** as future/self-directed study topics.

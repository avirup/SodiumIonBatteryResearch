# Chapter 3: Performance Metrics and Terminology

## Chapter Opening

Imagine picking up a cell datasheet for the first time. It is a dense document, usually two to four pages, packed with numbers, graphs, and abbreviations. There is a discharge capacity at multiple C-rates, a family of voltage curves, a cycle life plot that descends to 80% of something, a table of temperatures with associated capacities, a graph labelled "DCIR" with values in milliohms, a note about CC-CV charging, and perhaps a Ragone plot tucked into a corner. If you have been reading this book from the beginning, you now know enough electrochemistry to understand *why* these numbers exist — you know about half-reactions, overpotentials, diffusion limitations, and the three-component voltage equation. What you may not yet have is the engineering vocabulary to *name* what you are looking at and to connect each measurement on the datasheet to the physical processes beneath it.

That is this chapter's job.

Think of it as a translation dictionary — not from English to another language, but from electrochemistry to the language that battery engineers use day to day. Terms like C-rate, state of health, depth of discharge, and Coulombic efficiency are not arbitrary jargon. Every one of them encodes a specific physical meaning, and understanding that meaning precisely — rather than approximately — is what separates an engineer who can read a datasheet from one who can design around its limitations.

By the end of this chapter, you will be able to download a datasheet for any commercial cell and interpret every number, every graph, and every curve in physical terms. You will also understand the major characterisation techniques used to measure cell properties — HPPC, GITT, PITT, and EIS — at the level of understanding what each technique measures and why, even before we have derived all the underlying equations. That understanding will anchor the more mathematical treatment in later chapters.

We will work with real numbers throughout. Battery engineering is a quantitative field, and fluency with the relevant scales — milliohm-level resistances, milliampere-hour capacities, few-percent efficiency differences — is as important as conceptual understanding.

---

> **Prerequisites Check**
>
> From your EE background:
> - RC circuits and impedance in the complex plane (essential for Section 3.10, EIS)
> - Basic concepts of efficiency and power (Section 3.6)
> - Familiarity with Bode plots and frequency-domain thinking (helpful for Section 3.10)
>
> From Chapter 1:
> - Faraday's laws connecting charge to mass (Section 1.7) — needed for Section 3.1
> - The Nernst equation and its connection to OCV (Section 1.5) — needed for Section 3.4
>
> From Chapter 2:
> - The three overpotentials (ohmic, activation, concentration) and their time constants (Section 2.7) — needed for Sections 3.5 and 3.10
> - Butler-Volmer equation and exchange current density (Section 2.8) — needed for Section 3.10
> - The SEI and first-cycle irreversibility (Section 2.3) — needed for Section 3.6
>
> If anything from Chapter 2 is unclear, especially the three-overpotential framework, review Section 2.7 before proceeding to Section 3.5.

---

## 3.1 Capacity (Ah) vs. Energy (Wh): Specific vs. Volumetric

The first and most fundamental metric of a battery is its **capacity** — how much charge it can store and deliver. Before we can define capacity precisely, we need to agree on what we mean, because the word is used in two senses that are related but not identical.

### Charge Capacity

The **charge capacity** $Q$ of a cell is the total charge it can deliver under specified conditions, measured in ampere-hours (Ah) or milliampere-hours (mAh). The defining relationship is:

$$Q = \int_0^{t_d} I(t)\, dt \tag{3.1}$$

where $I(t)$ is the discharge current (in amperes) and $t_d$ is the time until the voltage reaches a specified **cutoff voltage** $V_\text{cutoff}$. For a constant-current discharge at current $I$:

$$Q = I \cdot t_d \tag{3.2}$$

This is the simplest case: a 3.0 Ah cell discharged at 1.0 A for 3 hours delivers 3.0 Ah. But capacity is not a single fixed number — it depends on the rate of discharge, the temperature, and the cutoff voltage. A cell rated at 3.0 Ah at C/5 (a slow discharge over 5 hours) might deliver only 2.6 Ah at 1C (discharged in one hour) because concentration overpotential depletes the surface of the electrode before the bulk is exhausted, causing the voltage to hit the cutoff early. We will quantify this rate dependence in Section 3.2.

### Energy

**Energy** $E$ is what you actually want from a battery in most applications. It is the integral of power over time:

$$E = \int_0^{t_d} V(t)\, I(t)\, dt \tag{3.3}$$

and it is measured in watt-hours (Wh) or kilowatt-hours (kWh). For a constant-current discharge:

$$E = \bar{V} \cdot Q \tag{3.4}$$

where $\bar{V}$ is the average discharge voltage. The relationship $E = \bar{V} \cdot Q$ is the most important equation in practical battery engineering — it says that energy is the product of how much charge you move and at what average voltage you move it. Both factors matter.

A cell with a capacity of 3.0 Ah at a nominal voltage of 3.6 V contains $3.0 \times 3.6 = 10.8$ Wh of energy. The same capacity at 3.2 V (LFP chemistry) contains only $3.0 \times 3.2 = 9.6$ Wh — 11% less, just from the lower chemistry voltage.

**Students sometimes confuse capacity (Ah) with energy (Wh).** They are related by voltage but are distinct quantities. When a BMS calculates "state of charge" using coulomb counting, it tracks charge (Ah), not energy (Wh). When comparing battery packs across chemistries with different nominal voltages, energy (Wh) is the fair comparison. A system that says "100 Ah pack" without specifying voltage is only telling you half the story.

### Specific and Volumetric Metrics

Capacity and energy per se are extensive quantities — they scale with the size of the cell. More useful for comparing different cells and chemistries are the normalised, **intensive** quantities:

**Gravimetric (specific) capacity**: $C_m = Q / m$ [Ah/kg or mAh/g], where $m$ is the cell mass.

**Volumetric capacity**: $C_V = Q / V_\text{cell}$ [Ah/L or mAh/cm³], where $V_\text{cell}$ is the cell volume.

**Gravimetric (specific) energy density**: $\mathcal{E}_m = E / m$ [Wh/kg].

**Volumetric energy density**: $\mathcal{E}_V = E / V_\text{cell}$ [Wh/L].

**Power density**: $P_m = P / m$ [W/kg] or $P_V = P / V_\text{cell}$ [W/L].

These metrics allow comparison across cells of different sizes. When someone says "a NMC cell has 250 Wh/kg," they are giving the gravimetric energy density — the energy stored per kilogram of complete cell mass (including casing, current collectors, electrolyte, and everything else). This cell-level number is typically 2–4× lower than the material-level theoretical number we calculated in Chapter 1, because the cathode and anode active materials together typically make up only 35–55% of the total cell mass for an energy-optimised commercial cell, and somewhat less for power-optimised or low-cost designs. The remaining mass is electrolyte, separator, current collectors, binder and conductive additives, can or pouch packaging, tabs, and safety hardware.

The distinction between **cell-level** and **material-level** (or electrode-level) metrics is another frequent source of confusion in the literature. A researcher publishing on a new cathode material might report "310 mAh/g" — this is the specific capacity of the active material alone. The cell-level specific energy will be much lower. Always check what mass (or volume) the denominator refers to.

A representative table of cell-level specific energies for common chemistries (approximate, commercial cells, room temperature, mid-2020s state of practice):

| Chemistry | Nominal Voltage (V) | Specific Energy (Wh/kg) | Volumetric Energy (Wh/L) |
|---|---|---|---|
| LCO (consumer) | 3.7 | 200–260 | 550–700 |
| NMC811 (EV) | 3.7 | 230–280 | 600–750 |
| NCA (EV) | 3.6 | 220–270 | 600–700 |
| LFP (EV/grid) | 3.2 | 150–200 | 350–450 |
| LMO (low-cost) | 3.8 | 100–130 | 250–330 |
| SIB (hard carbon / layered oxide) | 3.1–3.2 | 100–160 | 250–400 |

The SIB numbers are lower than the best lithium-ion chemistries — reflecting the lower cell voltage and lower specific capacity of current SIB electrode materials — but competitive with LFP, particularly in cost. We will revisit these comparisons in detail in Chapters 5 and 6.

A useful calibration for an EE: the best electrolytic capacitors store about 0.05–0.1 Wh/kg, the best supercapacitors about 5–10 Wh/kg, lead-acid batteries about 30–40 Wh/kg, current commercial lithium-ion cells about 200–280 Wh/kg, and gasoline (for context) about 12,000 Wh/kg before accounting for engine efficiency. Lithium-ion sits roughly three orders of magnitude denser than capacitors and one order of magnitude less dense than hydrocarbon fuel — close enough to fuel to displace it in mobility applications, far enough above capacitors to make stationary energy storage practical at grid scale.

---

## 3.2 C-Rate and What "1C" Actually Means

The **C-rate** is one of the most commonly used and most commonly misunderstood terms in battery engineering. It is not a unit — it is a normalised rate of charge or discharge relative to the cell's capacity.

### Definition

The C-rate is defined such that a discharge at **1C** completely discharges a cell (from full to empty) in exactly one hour. A charge at **1C** fully charges a cell in one hour. More generally, a discharge at **$n$C** completes in $1/n$ hours; a charge at **$n$C** completes in $1/n$ hours.

The current corresponding to 1C is:

$$I_{1C} = \frac{Q_\text{rated}}{1 \text{ hour}} \tag{3.5}$$

For a cell with rated capacity 3.0 Ah, $I_{1C} = 3.0$ A. A 2C discharge draws 6.0 A; a C/5 (0.2C) discharge draws 0.6 A.

This is the reason C-rate is useful: it allows comparison across cells of different sizes. A 1C discharge of a 3 Ah cell (3 A) and a 1C discharge of a 300 Ah bus battery (300 A) place the same relative electrochemical stress on both cells — both will nominally empty in one hour, and both have the same ratio of current to available lithium inventory.

### The Complication: Capacity Depends on C-Rate

Here is the subtlety that trips up beginners. The rated capacity $Q_\text{rated}$ used to define 1C is itself measured at a specific (usually low) rate, often C/5 or C/10. But the actual deliverable capacity decreases at higher rates, because concentration overpotential drives the terminal voltage to the cutoff before all the charge has been extracted. So the "capacity" in the denominator of the C-rate definition is not the capacity at that C-rate — it is a reference capacity at a standard rate.

**A common misconception.** Beginners often assume that C-rate is just a unit conversion: "5C means I extract the same energy in one-fifth the time." This is wrong on two fronts. First, a discharge at 5C delivers *less total capacity* than the rated value, because concentration overpotential drives the terminal voltage to the cutoff before the bulk of the active material is exhausted. Second, the *average* discharge voltage at 5C is lower than at C/5, because the cell is operating with larger overpotentials throughout the discharge. Both effects reduce the delivered energy. So a 5C discharge gives you (less than) 5× the power, for (less than) 1/5 the time, at a lower average voltage — and the energy you actually extract is considerably less than the rated $\bar V \cdot Q$ value. The Ragone plot we will see shortly is the standard way of visualising this energy-power tradeoff.

As a rule of thumb for a good-quality NMC cell: the deliverable capacity at 2C is about 93–96% of the rated capacity; at 5C it is roughly 80–90%; at 10C it may be 60–75%. These numbers degrade significantly at low temperature.

### Practical Notes

The C-rate convention is not perfectly consistent across the industry. Some manufacturers define 1C based on the actual delivered capacity at that rate, which leads to circular definitions. Others define it based on the nominal capacity printed on the label, which may differ from the measured capacity. Always check how a manufacturer defines their C-rate when interpreting datasheet curves.

When you see a Ragone plot — a plot of specific power vs. specific energy, usually on a log-log scale — the diagonal lines of constant discharge time are lines of constant C-rate. A point at 200 Wh/kg and 200 W/kg is a 1-hour discharge (1C); a point at 200 Wh/kg and 2000 W/kg is a 6-minute discharge (10C). The Ragone plot is the standard graphical way to show the power-energy tradeoff.

---

## 3.3 State of Charge, Depth of Discharge, State of Health

Three state variables appear constantly in battery management systems and in the literature. Defining them precisely matters because imprecise use of these terms causes confusion in both modelling and engineering.

### State of Charge

**State of charge (SOC)** is the fraction of the cell's usable charge capacity that is currently stored, expressed as a percentage or decimal:

$$\text{SOC} = \frac{Q_\text{remaining}}{Q_\text{max}} \times 100\% \tag{3.6}$$

where $Q_\text{remaining}$ is the charge currently available for discharge (under the same conditions used to measure $Q_\text{max}$) and $Q_\text{max}$ is the maximum deliverable capacity of the cell in its current state of health.

SOC = 100% means the cell is fully charged. SOC = 0% means the cell is at its lower cutoff voltage under the reference conditions — not that all lithium has been extracted from the electrode (the lower cutoff voltage is set conservatively above the structural instability limits of the electrodes).

The critical point is that SOC is defined relative to $Q_\text{max}$, which itself degrades over the cell's life. A cell that once had $Q_\text{max} = 3.0$ Ah and now has $Q_\text{max} = 2.7$ Ah (after degradation) can still reach SOC = 100% — it just stores less total charge. SOC tracks *fractional* fill level, not absolute charge.

### Depth of Discharge

**Depth of discharge (DOD)** is the complement of SOC:

$$\text{DOD} = 1 - \text{SOC} = \frac{Q_\text{discharged}}{Q_\text{max}} \tag{3.7}$$

DOD = 0% means fully charged (SOC = 100%). DOD = 100% means fully discharged (SOC = 0%). DOD is preferred in degradation discussions because stress on the electrodes is often framed as how deeply the cell was discharged: a DOD of 80% (which means SOC swung from 100% to 20%) is more mechanically stressful than a DOD of 20% (SOC swings from 60% to 40%), because the volume change of the electrode materials scales with lithiation range.

The relationship between cycle life and DOD is a key degradation parameter. We will establish empirical models for it in Chapter 7, but qualitatively: shallow cycling (low DOD) dramatically extends cycle life. A cell rated for 500 full cycles (100% DOD) might survive 3,000+ cycles if cycled over only 20% DOD, because the electrode volume changes are much smaller and the SEI stress is reduced.

### State of Health

**State of health (SOH)** is a scalar metric (percentage or decimal) that captures how degraded a cell is relative to its beginning-of-life specifications. It is not a single standardised quantity — the industry uses several definitions, and you will see all of them in the literature.

The two most common definitions are **capacity-based SOH** and **resistance-based SOH**:

$$\text{SOH}_Q = \frac{Q_\text{max}(t)}{Q_\text{max}(t=0)} \times 100\% \tag{3.8}$$

$$\text{SOH}_R = \frac{R_0(t=0)}{R_0(t)} \times 100\% \tag{3.9}$$

where $Q_\text{max}(t)$ is the current maximum capacity and $Q_\text{max}(t=0)$ is the beginning-of-life capacity; $R_0(t)$ is the current internal resistance and $R_0(t=0)$ is the beginning-of-life resistance.

The conventional **end-of-life (EOL)** criterion for traction batteries is SOH$_Q = 80\%$ — that is, when the cell retains only 80% of its original capacity. This is somewhat arbitrary (why not 75% or 85%?), but it has become a de facto industry standard for EV batteries. The choice reflects a balance between two pressures: on the one hand, drivers tolerate a noticeable but not crippling range loss at 80%; on the other, capacity fade in many lithium-ion chemistries accelerates noticeably below ~80%, so the "knee" of the fade curve provides a natural stopping point. Different applications use different thresholds — grid storage often targets 70%, aviation as high as 90%.

A subtlety: capacity-fade SOH and resistance-rise SOH do not always track together. A cell might retain 85% of its capacity (SOH$_Q$ = 85%) but have tripled its internal resistance (SOH$_R$ ≈ 33%). This happens in cells that have suffered electrolyte decomposition and extensive SEI growth — resistance increases rapidly while capacity fade is slower. Conversely, some degradation modes (lithium plating, active material loss) primarily affect capacity without dramatically increasing resistance initially. For a BMS that needs a single SOH number, choosing which definition to use — or how to combine both — is a non-trivial design decision. We will return to SOH estimation in Chapter 10.

---

## 3.4 Open-Circuit Voltage vs. Terminal Voltage; Why OCV Curve Shape Matters for BMS

The distinction between **open-circuit voltage (OCV)** and **terminal voltage** ($V_\text{terminal}$) is fundamental to everything from Nernst-equation thermodynamics to BMS state estimation, yet the two are often conflated in casual usage.

### Open-Circuit Voltage

The **open-circuit voltage** is the voltage measured across the cell's terminals when no current is flowing — or, more precisely, when the cell has been allowed to relax to thermodynamic equilibrium after any prior current. Conceptually, OCV is the equilibrium electrode potential difference between the two electrodes, as the Nernst equation predicts for the current composition (SOC) of each electrode.

There is a subtlety here that rewards careful attention. Measuring true OCV — genuine thermodynamic equilibrium — requires the cell to rest for a long time after any perturbation. For a lithium-ion cell that has just finished a discharge, the concentration gradients within the porous electrodes (built up during the discharge) take minutes to hours to fully relax by diffusion. During this relaxation, the measured open-circuit voltage drifts slowly toward its true equilibrium value. The measurement you take 30 seconds after current stops is not true OCV — it is a **relaxed terminal voltage** that still contains some residual overpotential. Full relaxation of a thick electrode can take 2–8 hours.

For battery modelling purposes, the OCV curve $E_\text{OCV}(\text{SOC})$ is the fundamental thermodynamic input. It is measured by charging or discharging the cell in very small increments with long rest periods in between (the GITT technique, described in Section 3.10), or by using extremely low C-rates (C/50 or lower). The OCV curve is also called the **equilibrium potential curve** or (if measured at very low rate as an approximation) the **quasi-equilibrium discharge curve**.

Why does relaxation take hours rather than seconds? The slow relaxation is the long-time tail of solid-state diffusion: after the current stops, lithium concentrations within the active particles are non-uniform (high at the surface during charge, depleted at the surface during discharge), and re-equilibration occurs by diffusion through the particles, which is slow. The relevant time constant is $\tau_\text{diff} \sim r^2 / D_s$, where $r$ is the particle radius and $D_s$ is the solid-state diffusion coefficient. For a 5 µm NMC particle with $D_s \sim 10^{-14}\,\text{m}^2/\text{s}$, $\tau_\text{diff} \sim (5 \times 10^{-6})^2 / 10^{-14} = 2{,}500$ seconds, or about 40 minutes. For thicker electrodes, additional liquid-phase relaxation in the porous matrix adds further slow components. The picture an EE should hold is that of an RC ladder network with a wide spread of time constants — and full relaxation requires waiting out the longest of them.

### Terminal Voltage

The **terminal voltage** is what you actually measure across the cell terminals during operation — under current. It differs from OCV by the sum of overpotentials. During discharge, all three overpotentials subtract from the equilibrium OCV:

$$V_\text{terminal} = E_\text{OCV}(\text{SOC}) - \eta_\Omega - \eta_\text{act} - \eta_\text{conc} \tag{3.10}$$

During charge, all three overpotentials add to the equilibrium OCV:

$$V_\text{terminal} = E_\text{OCV}(\text{SOC}) + \eta_\Omega + \eta_\text{act} + \eta_\text{conc} \tag{3.11}$$

In discharge, the voltage is pulled below OCV by the overpotentials. In charge, it is pushed above OCV. The size of these deviations — the "spread" between the charge and discharge curves at a given SOC — is a measure of the cell's internal loss.

### Why OCV Curve Shape Matters for BMS

The shape of the OCV-vs-SOC curve has enormous practical consequences for the accuracy of SOC estimation in a battery management system.

If the OCV curve is steep — voltage changes significantly with SOC — then a small voltage measurement error translates to a small SOC error. The voltage is an informative signal for SOC. The OCV curves of NMC and NCA cathodes are moderately sloped throughout most of their range, making voltage-based SOC estimation reasonably reliable for these chemistries.

If the OCV curve is flat — voltage barely changes with SOC over a wide range — then voltage measurement is nearly useless for SOC estimation in that region. A 10 mV measurement error might correspond to a 20% SOC uncertainty. LFP cathodes have an extremely flat OCV plateau (nearly constant at ~3.42 V vs. Li/Li⁺ at room temperature) over 80–90% of their SOC range, making voltage-based SOC lookup effectively useless for most of the operating range. BMS algorithms for LFP cells must therefore rely almost entirely on coulomb counting (integrated current), which accumulates error over time. This is a hard problem, and it is an active area of BMS research.

Hard carbon anodes in sodium-ion batteries present an even more extreme version of this problem. Their OCV curve has a very flat plateau at low potential (below ~0.1 V vs. Na/Na⁺) that accounts for a substantial fraction of the cell capacity (recall the plateau from the worked exercise in Chapter 1). The full cell OCV of a hard carbon/layered oxide SIB therefore has a flat region that is even harder to work with than LFP. This is one of the most practically important challenges for SIB BMS design, and we will address it specifically in Chapters 10 and 13.

### Hysteresis

One more subtlety about OCV: many battery chemistries exhibit **OCV hysteresis** — the OCV measured after charging to a given SOC is slightly higher than the OCV measured after discharging to the same SOC. The cell remembers (weakly and temporarily) the direction from which it arrived at its current SOC.

The physical origin of hysteresis varies by chemistry. In LFP it arises from the first-order two-phase transformation between LiFePO₄ and FePO₄: each particle has to nucleate the new phase before the transformation can proceed, and the nucleation barrier is asymmetric in the two directions. At the ensemble level, this produces the so-called many-particle hysteresis (Dreyer et al., *Nature Materials*, 2010), where a population of particles charging at slightly different thresholds traces out a different mean voltage than the same population discharging. Volume mismatch and elastic stress between the two phases also contribute, but the path-dependence of the phase transition is the dominant effect. In hard carbon, hysteresis is related to the different energetics of sodium entering vs. leaving the nanopore sites. In NMC, it is smaller but present, related to phase transitions and lithium ordering within the host lattice.

The practical implication is that a BMS that uses an OCV lookup table must use separate charge and discharge OCV curves, or accept a systematic SOC bias depending on the recent direction of operation. Ignoring hysteresis introduces errors of 10–30 mV in OCV, which corresponds to SOC errors of several percent in steep-curve regions and much larger errors in flat-curve regions.

---

## 3.5 Internal Resistance and the Three Polarizations

A cell's **internal resistance** is a catch-all term for the collection of mechanisms that cause the terminal voltage to deviate from OCV under current. (You will see two words used interchangeably for these voltage deviations in the literature: **overpotential** and **polarisation**. They mean the same thing — the deviation of the electrode potential from its equilibrium value caused by the passage of current. We use both in this book to keep the reader fluent in both conventions.) We introduced the three overpotentials in Chapter 2 (Section 2.7); now we connect them to how resistance is measured and reported.

### DC Internal Resistance (DCIR)

The simplest measure of internal resistance is:

$$R_\text{int} = \frac{E_\text{OCV} - V_\text{terminal}}{I} = \frac{\Delta V}{I} \tag{3.12}$$

This is the **DC internal resistance** (DCIR) or apparent DC resistance. The single most important fact about DCIR is that *it is not a single number* — its value depends on how long after the current step you measure it.

The cleanest way for an EE to picture this is as a Thévenin source ($E_\text{OCV}$) in series with a small network: a pure resistor $R_\Omega$, then a parallel RC block ($R_\text{ct}$ in parallel with $C_\text{dl}$), then a long diffusion tail. When you step the current at $t=0$:

- At $t = 0^+$, only the resistor reacts (the capacitor is a short to instantaneous changes), so $\Delta V/I = R_\Omega$.
- Over the next milliseconds to ~1 second, the parallel RC charges up with time constant $\tau_\text{ct} = R_\text{ct} C_\text{dl}$, and the apparent resistance climbs toward $R_\Omega + R_\text{ct}$.
- Over the next many seconds, concentration gradients build up inside the porous electrode and inside the active particles, and a slow additional "diffusion drop" continues to grow. There is no clean exponential here — diffusion is a distributed process, and the drop grows roughly as $\sqrt{t}$ until the particle interior is depleted.

So an HPPC test reporting "10-second DCIR = 35 mΩ" is not measuring a property of the cell, it is measuring the integral of the cell's response over a particular 10-second window. A 1-second test on the same cell would give a smaller number; a 60-second test, a larger one. Pulse duration is part of the measurement, not a footnote.

### The Three Components Revisited

From Chapter 2, recall:

**Ohmic resistance $R_\Omega$** comes from: the ionic resistance of the electrolyte (dominant), the electronic resistance of the electrode matrices and current collectors (usually small), and contact resistances. This component responds instantaneously. In a fresh, room-temperature 18650 NMC cell, $R_\Omega$ is typically 20–40 mΩ. It increases as the electrolyte ages (solvent evaporation, salt decomposition) and as the SEI grows (adds an ionic resistance layer on every particle surface).

**Charge-transfer resistance $R_\text{ct}$** comes from the activation overpotential. Linearising the Butler–Volmer equation around $\eta_\text{act}=0$ (small-overpotential limit, as we did in Chapter 2) gives

$$R_\text{ct} = \frac{RT}{n F i_0 A},$$

where $i_0$ is the exchange current density, $A$ is the active electrode area, $n$ is the number of electrons transferred per ion, $R$ is the gas constant, $T$ is the absolute temperature, and $F$ is Faraday's constant. It is strongly temperature-dependent (Arrhenius, through $i_0$) and increases significantly at low temperatures. For a fresh NMC cell at 25°C, $R_\text{ct}$ is comparable to or slightly larger than $R_\Omega$; at $-20$°C, it can be 5–15× larger, dominating the total impedance.

**Diffusion (concentration) "resistance" $R_\text{diff}$** is not truly a resistance in the ohmic sense. It is a frequency-dependent impedance — the Warburg impedance — whose magnitude scales as $|Z_W| \propto 1/\sqrt{\omega}$ and whose phase is fixed at $-45^\circ$. (We will see in Section 3.10 why diffusion gives this odd half-power behaviour.) But in DC pulse tests of a few seconds duration, it contributes to the apparent voltage drop and can be loosely characterised as an effective resistance over that time window.

### Total Apparent Resistance vs. True Ohmic Resistance

Battery datasheets report **DC internal resistance (DCIR)** measured by a specific protocol, typically a 10–30 second current pulse at 50% SOC and 25°C. This number includes contributions from all three components over the measurement window. It is useful for comparing cells and for BMS power calculations, but it is not a material property — it is a system property that depends on temperature, SOC, SOH, and pulse duration.

For electrochemical modelling, the distinction between $R_\Omega$, $R_\text{ct}$, and $R_\text{diff}$ is essential — lumping them into a single DCIR discards information needed to predict performance under different conditions. The electrochemical impedance spectroscopy technique (Section 3.10) is the standard method for separating these contributions.

---

## 3.6 Coulombic, Voltage, and Energy Efficiency

Efficiency metrics quantify how much of the energy you put into a cell during charging you can recover during discharging. Three distinct efficiency definitions are important in battery engineering, and they measure different things.

### Coulombic Efficiency

**Coulombic efficiency** (CE, also called **faradaic efficiency**) is the ratio of charge discharged to charge charged over one complete cycle:

$$\text{CE} = \frac{Q_\text{discharge}}{Q_\text{charge}} \times 100\% \tag{3.13}$$

For a perfectly reversible cell with no side reactions, CE would be 100% — every coulomb put in during charge comes out during discharge. In real cells, CE is always less than 100% because some charge goes into side reactions: SEI growth, electrolyte decomposition, lithium plating. For a fresh lithium-ion cell in a stable state (not its first few cycles), CE is typically 99.8–99.95% per cycle.

This might sound impressively close to 100%, but the engineering implication of even a tenth-of-a-percent shortfall is alarming once you compound it over many cycles. Each cycle, a fraction $(1 - \text{CE})$ of the cycled charge is lost irreversibly to side reactions — typically going into incremental SEI growth on the anode. Over $N$ cycles, the cumulative loss is approximately

$$\Delta Q_\text{lost} \approx (1 - \text{CE}) \times N \times Q_\text{cycle}.$$

Plugging in CE = 99.8% and $N = 500$: $\Delta Q_\text{lost} \approx 0.002 \times 500 \times Q_\text{cycle} = 1.0 \times Q_\text{cycle}$. The cell has irreversibly converted the equivalent of one full cycle's worth of active lithium into SEI byproducts. For a cell whose capacity-fade EOL criterion is 80% (loss of 20%), losing one cycle's worth of inventory is a substantial fraction of its lifetime budget. This is why a 0.1% absolute improvement in CE — from 99.8% to 99.9% — *halves* the inventory loss rate and dramatically extends cycle life. The same arithmetic explains why lithium metal anodes, with their stubborn 95–99.5% CE, remain commercially elusive: at CE = 98%, the same 500 cycles consume ten full cycles' worth of lithium, which the cell does not have.

**First-cycle Coulombic efficiency (ICE)** is distinguished from cycle-averaged CE. As discussed in Chapter 2, the ICE reflects the large irreversible charge consumed by SEI formation in the first cycle, typically 85–95% for graphite and 75–85% for hard carbon.

### Voltage Efficiency

**Voltage efficiency** is the ratio of the average discharge voltage to the average charge voltage:

$$\eta_V = \frac{\bar{V}_\text{discharge}}{\bar{V}_\text{charge}} \tag{3.14}$$

Since charging always occurs at a higher average voltage than discharging (overpotentials add during charge and subtract during discharge), $\eta_V < 1$. For a cell with modest internal resistance, $\eta_V$ might be 95–98%.

### Energy (Round-Trip) Efficiency

**Energy efficiency** (also called **round-trip efficiency** or **RTE**) is the ratio of energy recovered during discharge to energy invested during charge:

$$\eta_E = \frac{E_\text{discharge}}{E_\text{charge}} = \frac{\bar{V}_\text{discharge} \cdot Q_\text{discharge}}{\bar{V}_\text{charge} \cdot Q_\text{charge}} = \eta_V \cdot \text{CE} \tag{3.15}$$

Round-trip efficiency is the product of voltage efficiency and Coulombic efficiency. For a high-quality lithium-ion cell cycled at 1C: CE ≈ 99.9%, $\eta_V$ ≈ 96%, so $\eta_E$ ≈ 95.9%. At higher C-rates, voltage efficiency drops (larger overpotentials) and energy efficiency degrades.

For grid storage applications, round-trip efficiency directly translates to operating economics: if the RTE is 92%, then for every 100 kWh of grid electricity purchased to charge a battery, only 92 kWh can be sold when discharged. Over millions of cycles at the grid scale, efficiency differences of a few percentage points represent enormous cumulative energy losses.

---

## 3.7 Cycle Life vs. Calendar Life; What Counts as "A Cycle"

**Cycle life** and **calendar life** are two distinct degradation trajectories with different physical origins, different accelerating stressors, and different modelling approaches. Understanding the distinction is essential for predicting battery longevity in real applications.

### Cycle Life

**Cycle life** is the number of charge-discharge cycles a cell can complete before its SOH (usually capacity-based) falls below a specified threshold (typically 80%). It is measured under defined cycling conditions: fixed DOD, C-rate, temperature, voltage window.

A typical specification might read: "500 cycles at 100% DOD, 1C charge/discharge, 25°C, to 80% retention." This is a useful benchmark, but it is immediately limited: real applications cycle at variable DOD, variable temperature, and variable C-rate. No single cycle life number captures the full picture.

**What counts as "a cycle"?** This is more ambiguous than it sounds. Options include:

A full cycle is a complete charge from 0% to 100% SOC plus a complete discharge from 100% to 0% SOC. This is simple but ignores the reality that most applications never use the full SOC range.

A partial cycle is counted by the charge throughput: one "equivalent full cycle" (EFC) is defined as $2Q_\text{rated}$ of total charge throughput (one full charge plus one full discharge worth of charge). Under this convention, ten shallow cycles of DOD 10% each count as one EFC.

A **rainflow counting** algorithm (borrowed from mechanical fatigue analysis) is the most sophisticated approach: it identifies all charge-discharge cycles of varying depth in an arbitrary current profile, weights each by its DOD, and accumulates damage. This is what sophisticated BMS algorithms use for SOH tracking.

### Calendar Life

**Calendar life** is the degradation that occurs over time regardless of cycling — simply from sitting at a given SOC and temperature. The dominant mechanism is continuous SEI growth (even at rest, the anode is at a low potential where the electrolyte is thermodynamically unstable, so the SEI creeps forward), along with electrolyte oxidation at the cathode. Calendar aging is particularly insidious because it continues even when the battery is not being used.

Calendar aging is strongly accelerated by elevated temperature and high SOC. The temperature dependence is Arrhenius, so every 10°C increase in storage temperature roughly doubles the calendar aging rate. The SOC dependence arises because at high SOC the anode is more lithiated (lower potential), where the thermodynamic drive for electrolyte reduction is stronger, so the SEI grows faster.

The practical implication for storage: if you are going to store a lithium-ion cell for months, store it at around 30–50% SOC in a cool place (10–15°C). Do not leave it fully charged in a warm environment.

For SIB cells, calendar aging is less well-characterised than for lithium-ion, but preliminary evidence suggests the SEI on hard carbon in sodium-ion electrolytes may be more stable (less continuous growth) than on graphite in lithium-ion electrolytes, which would be a calendar-life advantage for SIBs. This is an active area of research.

The two ageing modes can be summarised side by side:

| Aspect | Cycle ageing | Calendar ageing |
|---|---|---|
| Driver | Charge throughput (cycles, DOD, C-rate) | Time spent at a given (T, SOC) |
| Dominant mechanism (LIB) | SEI growth at exposed anode surfaces, particle cracking, lithium plating | SEI growth at the equilibrium anode potential, cathode electrolyte oxidation |
| Strongest stressor | High DOD, high C-rate, voltage extremes | High temperature, high SOC |
| Temperature dependence | Mixed (high T accelerates side reactions, low T accelerates plating) | Arrhenius — roughly doubles per +10°C |
| Mitigation | Limit DOD, moderate C-rate, narrow voltage window | Store cool and at moderate SOC (~30–50%) |
| Modelling approach | Cycle-based or throughput-based fade laws; rainflow counting | Time × Arrhenius × SOC-dependent rate law |

Real cells experience both simultaneously, and a complete fade model superposes the two contributions. We will build such a model in Chapter 7.

---

## 3.8 Self-Discharge

**Self-discharge** is the spontaneous loss of stored charge over time when a cell is open-circuit (not connected to any load or charger). It is distinct from calendar aging: self-discharge refers to the loss of charge (SOC decreases over days or weeks), while calendar aging refers to capacity fade and resistance rise over months or years. A cell can self-discharge significantly over a month without meaningfully degrading in calendar aging terms, and vice versa.

Self-discharge has several distinct physical origins, and a real cell typically exhibits all of them simultaneously to varying degrees. The dominant mechanism for a healthy lithium-ion cell at room temperature is slow electrochemical side reaction at the anode, but in degraded cells, in cells with manufacturing defects, or in chemistries with shuttle-active impurities, other mechanisms can take over.

**Electrochemical side reactions at low rate**: The same reactions that form the SEI during cycling continue very slowly at rest. This consumes a tiny current continuously, slowly depleting the stored charge. For a well-formed SEI, this rate is very small.

**Electronic leakage through the separator**: If the separator is imperfect — has a micro-short or contamination — electrons can cross from anode to cathode directly, mimicking a small load and discharging the cell. Even a 1 MΩ "leakage resistance" across a 3.7 V cell corresponds to a continuous discharge current of 3.7 µA, which over a month (2.6 × 10⁶ s) amounts to 9.6 C or about 2.7 mAh — negligible for a 3 Ah cell, but an important specification for long-life applications.

**Electrolyte redox shuttle**: In some chemistries, a dissolved species (often an impurity or a deliberately added molecule) can be electrochemically oxidised at the positive electrode and reduced at the negative electrode in a continuous cycle, shuttling charge from cathode to anode and discharging the cell. This is a problem in overcharged cells and is intentionally exploited in some chemistries as an overcharge protection mechanism.

Self-discharge rates for lithium-ion cells are typically 1–5% per month at room temperature, increasing with temperature. This is much lower than for older technologies (NiMH: 20–30% per month; lead-acid: 5–15% per month) and is one of the reasons lithium-ion has won the portable electronics market.

---

## 3.9 CC-CV Charging Protocol

Almost every lithium-ion cell is charged using the **constant-current constant-voltage (CC-CV)** protocol, and for good reason. Understanding why CC-CV is used — and why simpler alternatives do not work well — requires combining the OCV concept, the overpotential framework, and the practical voltage limits of the cell.

### The Protocol

A CC-CV charge proceeds in two phases:

**Phase 1, Constant Current (CC):** The charger supplies a fixed current (typically C/2 or 1C for fast charging, C/5 for careful charging). The cell voltage rises as the SOC increases. The charger continues at constant current until the cell voltage reaches the **upper cutoff voltage** $V_\text{max}$ (typically 4.2 V for NMC/NCA cells, 4.35–4.4 V for high-voltage NMC, 3.65 V for LFP).

**Phase 2, Constant Voltage (CV):** Once the terminal voltage reaches $V_\text{max}$, the charger holds the voltage constant at $V_\text{max}$ and allows the current to taper down naturally. The current decreases as the cell's internal state approaches full charge (overpotentials diminish as the lithium concentration gradient relaxes and the electrode composition approaches its equilibrium fully-charged state). Charging is considered complete when the current drops below a threshold, typically C/20 or C/50.

### Why CC-CV Is Used

The upper cutoff voltage $V_\text{max}$ is a safety limit, not an arbitrary choice. For NMC cells, exceeding 4.2–4.3 V causes lithium over-extraction from the cathode, leading to structural instability, metal dissolution, and electrolyte oxidation. For graphite anodes, operating below about 0.0 V vs. Li/Li⁺ causes lithium plating — metallic lithium depositing on the graphite surface rather than inserting intercalation — which is both a safety hazard (lithium dendrites can puncture the separator) and an irreversible capacity loss mechanism.

The CC phase is efficient and fast — it charges the cell to roughly 70–80% SOC in a fraction of the total charging time. The CV phase fills the remaining 20–30% but takes proportionally longer because the current tapers exponentially. Approximately 75% of the total charge is delivered in the CC phase (in about 30–40% of total charging time for a 1C charge), and 25% in the CV phase (in about 60–70% of total charging time).

The CC-CV protocol implicitly protects against overvoltage at the electrode level. During CC charging, the terminal voltage is being held below $V_\text{max}$ by design. Once the terminal voltage reaches $V_\text{max}$, allowing the current to taper in CV mode ensures the overpotentials decrease and the voltage does not continue to rise — the cell is approaching equilibrium from above, not being driven further into it.

A note on sodium-ion cells: they use the same CC-CV protocol, but the voltage limits differ by chemistry. Typical SIB upper cutoff voltages are 4.0–4.2 V (layered oxide cathodes) with lower cutoffs around 1.5–2.0 V, compared to 3.0 V for lithium-ion. The wider lower voltage limit for SIBs is partly because hard carbon has a lower practical discharge limit and partly because some SIB cathodes (particularly Prussian blue analogues) have a relatively low and flat discharge curve that must be accessed down to 2.0 V.

---

## 3.10 Characterisation Tests: HPPC, GITT, PITT, EIS

This section is where the toolkit of battery characterisation is introduced. Each technique probes a different aspect of the cell's physics, and understanding what each measures — and crucially, why — requires applying almost everything from Chapters 1 and 2.

### HPPC: Hybrid Pulse Power Characterisation

The **Hybrid Pulse Power Characterisation (HPPC)** test, developed at the Idaho National Laboratory for the U.S. Department of Energy's Advanced Technology Development programme, is the standard method for measuring a cell's internal resistance and power capability as a function of SOC. It is described in the USABC (United States Advanced Battery Consortium) test manual and is used by virtually every EV battery developer.

**The protocol:** Starting from a known SOC (often 90%), the cell rests for one hour to reach OCV. Then a discharge pulse at a fixed current (typically 1C or 2C) is applied for exactly 10 seconds, followed by a 40-second rest, followed by a charge pulse at the same current for 10 seconds, followed by another rest. This pulse triplet is then repeated at decreasing SOC levels (stepping down 10% at a time, so the full test covers 90%, 80%, 70%, ... 10% SOC), with a slow discharge segment between each triplet to step down the SOC.

**What it measures:** The immediate voltage drop at the onset of each pulse gives the ohmic resistance $R_\Omega = \Delta V_\text{instant} / I$. The total voltage change after the 10-second pulse gives the DCIR at 10 seconds, which includes contributions from charge-transfer and early diffusion in addition to ohmic resistance. The difference between the 10-second DCIR and the instantaneous DCIR reflects the kinetic and transport contributions that build up over the pulse duration.

By repeating the measurement at multiple SOC levels, HPPC generates $R(SOC)$ curves — internal resistance as a function of state of charge. These curves typically show elevated resistance at very high and very low SOC (due to the SOC-dependence of $i_0$ described in Chapter 2) and a broad minimum at intermediate SOC.

**What it does not measure:** HPPC is a blunt instrument. It lumps all time-scale-dependent losses (activation, diffusion) into whatever window the 10-second pulse captures. It cannot cleanly separate $R_\text{ct}$ from $R_\text{diff}$, and it does not provide information about the electrode-level origin of the resistance. For those purposes, EIS is required.

**Engineering use:** HPPC data are the standard input for equivalent circuit model (ECM) parameter identification, which feeds into BMS algorithms for power prediction and SOC estimation. We will see this application in Chapter 10.

### GITT: Galvanostatic Intermittent Titration Technique

The **Galvanostatic Intermittent Titration Technique (GITT)** was introduced by Weppner and Huggins in 1977 and remains one of the most powerful methods for measuring the thermodynamic OCV curve and the solid-state diffusion coefficient within electrode materials.

**The protocol:** The cell (or, more commonly, a half-cell with a reference electrode) is subjected to a series of short, low-current pulses, each followed by a long open-circuit rest period. A typical GITT sequence: apply a C/20 current pulse for 10 minutes; rest for 2–4 hours (or until the voltage has relaxed to within a few millivolts of a stable value); record the equilibrium OCV; apply the next pulse; and so on. This is repeated throughout the full SOC range.

**What it measures, Part 1 — the OCV curve:** The end-of-rest voltage (after the long relaxation) at each step is the equilibrium OCV at that SOC. By taking many small steps, GITT traces out the complete OCV-vs-SOC curve with excellent accuracy. This is how the OCV curves used in BMS OCV-SOC lookup tables are measured.

**What it measures, Part 2 — the solid-state diffusion coefficient $D_s$:** During the current pulse, the voltage transient follows a characteristic shape for solid-state diffusion. Solving Fick's second law in a semi-infinite slab with a constant inward flux gives the surface concentration as

$$c_s(t) - c_0 = \frac{2I}{z_i F A}\sqrt{\frac{t}{\pi D_s}}$$

The measured voltage change tracks this surface concentration through the local slope of the equilibrium OCV curve, $dE/dx$ (where $x$ is the dimensionless composition of the host). Converting concentration to composition with the molar volume $V_m$ gives the standard Weppner–Huggins short-time form:

$$\Delta E(t) = \frac{2I\,V_m}{z_i F A\,\sqrt{\pi D_s}}\left|\frac{dE}{dx}\right|\sqrt{t} \tag{3.16}$$

where $I$ is the applied current, $V_m$ is the molar volume of the electrode material, $z_i$ is the charge number of the inserting ion, $A$ is the electrode geometric area, and $D_s$ is the solid-state diffusion coefficient. The key insight is that the GITT measurement gives us *two* slopes: the slope of $\Delta E$ vs. $\sqrt{t}$ during the current pulse, and the slope $dE/dx$ taken from the equilibrium OCV curve traced out by the rest-period endpoints. Together they pin down $D_s$:

$$D_s = \frac{4}{\pi}\left(\frac{I\,V_m}{z_i F A}\right)^{2}\left(\frac{dE/dx}{dE/d\sqrt{t}}\right)^{2}$$

This is a remarkable result: from a simple current step and voltage measurement, you can extract the diffusion coefficient of lithium (or sodium) inside the electrode particles — a quantity that would otherwise require sophisticated isotope labelling or neutron scattering experiments. GITT is the workhorse technique for characterising new electrode materials.

**Limitations of GITT:** The extraction of $D_s$ from equation (3.16) assumes a specific geometry (usually planar or spherical particles of uniform size), uniform current distribution, and negligible electrolyte transport effects. In real porous electrodes, these assumptions are approximate. The values of $D_s$ extracted from GITT on porous electrodes should be treated as effective apparent diffusivities rather than true single-particle quantities.

### PITT: Potentiostatic Intermittent Titration Technique

The **Potentiostatic Intermittent Titration Technique (PITT)** is the potential-controlled complement of GITT. Instead of applying current pulses and measuring voltage, PITT applies voltage steps and measures the current response.

**The protocol:** The electrode is held at a potential for long enough to reach equilibrium. Then the potential is stepped by a small increment (e.g., 5–10 mV). The resulting current transient decays as lithium diffuses into (or out of) the electrode particles. The integral of the current transient gives the charge transferred at that potential step, which corresponds to the number of lithium ions inserted per voltage increment — the differential capacity $dQ/dV$.

**What it measures:** PITT measures both the diffusion coefficient (from the shape of the current transient, analogous to GITT) and the differential capacity $dQ/dV$. The differential capacity curve — which is $dQ/dV$ plotted against voltage — is a highly sensitive fingerprint of the electrode's thermodynamic behaviour. Peaks in $dQ/dV$ correspond to phase transitions or lithium-ordering events in the host material; flat plateaus in $Q$-vs-$V$ appear as sharp peaks in $dQ/dV$. The incremental capacity analysis (ICA) technique for degradation diagnostics (which we will encounter in Chapter 7) is based directly on $dQ/dV$ curves measured by PITT or derived from slow C-rate galvanostatic discharge.

### EIS: Electrochemical Impedance Spectroscopy

**Electrochemical Impedance Spectroscopy (EIS)** is the most information-rich single measurement technique available to battery researchers. It measures the frequency-resolved impedance of a cell (or electrode), and because different physical processes have different characteristic frequencies, EIS can in principle deconvolve all the contributions to cell impedance — ohmic resistance, double-layer capacitance, charge-transfer resistance, solid-state diffusion — in a single measurement.

**The principle:** A small sinusoidal voltage perturbation $\Delta V(t) = \Delta V_0 \sin(\omega t)$ is applied to the cell at a given frequency $\omega$ (or equivalently, $f = \omega/2\pi$). The resulting sinusoidal current response $\Delta I(t) = \Delta I_0 \sin(\omega t + \phi)$ has an amplitude $\Delta I_0$ and a phase shift $\phi$. The complex impedance at that frequency is:

$$Z(\omega) = \frac{\Delta V}{\Delta I} = |Z| e^{j\phi} = Z' + jZ'' \tag{3.17}$$

where $Z'$ is the real part (in phase with the voltage, resistive character) and $Z''$ is the imaginary part (out of phase, reactive character). A full EIS measurement sweeps $\omega$ over a range of typically 100 kHz to 10 mHz, measuring $Z(\omega)$ at each frequency.

The results are usually displayed as a **Nyquist plot**: $-Z''$ on the y-axis vs. $Z'$ on the x-axis, with frequency as an implicit parameter (decreasing frequency from left to right for most battery impedance plots — but always check). The reason for plotting $-Z''$ rather than $Z''$ is that capacitive elements have negative imaginary impedance, so $-Z''$ is positive for capacitive features, making the plot more intuitive.

Here is the connection that makes EIS click for an EE. A Nyquist plot is just a Bode plot replotted in polar form: same data, different axes. A pure resistor sits at a single point on the real axis. A pure capacitor traces the negative imaginary axis as frequency varies. A parallel RC block — a resistor $R$ in parallel with a capacitor $C$ — traces a perfect semicircle of diameter $R$ in the Nyquist plane, centred on $(R/2,\,0)$. The frequency at the top of the semicircle is exactly $\omega_\text{peak} = 1/(RC) = 1/\tau$, the corner frequency you already know from first-order filter design. So when you see a semicircle in a battery EIS spectrum, you are seeing one $RC$ block, and you can read off its $R$ from the diameter and its $\tau$ from the apex frequency. Two semicircles means two $RC$ blocks with different time constants; one for the cathode, one for the anode, if you are lucky enough that they are well separated.

This is the same kind of intuition you use to spot the corner frequency of a low-pass filter on a Bode plot — you are just looking at the data in different coordinates.

**Reading a battery EIS Nyquist plot:** A typical Nyquist plot for a fresh lithium-ion cell at 50% SOC and 25°C shows the following features from high to low frequency:

At the **high-frequency intercept with the real axis** (typically 1–100 kHz), the imaginary part of the impedance crosses zero and the real part gives $R_\Omega$ — the pure ohmic resistance (electrolyte + contacts + electronic resistances). This point is the EIS equivalent of the HPPC instantaneous voltage drop.

At **intermediate frequencies** (100 Hz to 1 Hz), there is typically one or two **semicircles** in the Nyquist plane. A semicircle is the signature of a parallel RC circuit: a capacitance in parallel with a resistance. In a battery, this corresponds to the double-layer capacitance $C_\text{dl}$ in parallel with the charge-transfer resistance $R_\text{ct}$. The diameter of the semicircle gives $R_\text{ct}$; the frequency at the top of the arc gives the time constant $\tau = R_\text{ct} C_\text{dl}$. In many real cells, two overlapping semicircles are visible — one for the cathode and one for the anode, distinguishable by their time constants if they are sufficiently separated.

At **low frequencies** (below ~1 Hz), a nearly 45° line extending toward lower frequencies is the **Warburg impedance** — the signature of solid-state diffusion in the electrode particles. The slope departs from 45° as frequency approaches the diffusion time constant (when the diffusion front spans the full particle radius), transitioning to a near-vertical or capacitive feature at very low frequency.

**Equivalent circuit models (ECMs) for EIS:** The standard approach to extracting quantitative parameters from an EIS spectrum is to fit it to an equivalent circuit model. The most common model for a battery is the **Randles circuit**: a series combination of $R_\Omega$, and a parallel combination of $C_\text{dl}$ and ($R_\text{ct}$ in series with the Warburg impedance $Z_W$). In circuit notation: $R_\Omega + (C_\text{dl} \| (R_\text{ct} + Z_W))$.

More complex models add additional RC elements for the SEI impedance (a second semicircle at higher frequency, with a faster time constant than the charge-transfer arc), and a limiting capacitance at very low frequency representing the total cell capacitance.

**Bode-form EIS.** The same EIS data are sometimes plotted in Bode form: $|Z(\omega)|$ and $\angle Z(\omega)$ versus $\log f$, on two stacked axes. This is exactly the Bode plot you know from filter analysis. The Nyquist form is preferred in battery work because the semicircles and Warburg tail are visually distinctive and easy to fit by eye, but the Bode form is sometimes more convenient for spotting frequency-dependent features that overlap in the Nyquist plane (for instance, two RC blocks with very similar time constants that merge into a single squashed semicircle on Nyquist but remain visible as two corners on a Bode magnitude plot). When you read EIS papers you will encounter both — they are the same information in different coordinates.

**Practical worked example:** Here is a representative EIS measurement for a Samsung INR18650-30Q cell (3.0 Ah, NMC chemistry), measured at 50% SOC and 25°C. Approximate values from the literature (Barai et al., *Journal of The Electrochemical Society*, 2019):

High-frequency intercept: $Z' = R_\Omega \approx 25$ mΩ. This is the ohmic resistance.

Intermediate-frequency semicircle peak: diameter $\approx 20$ mΩ, peak frequency $\approx 50$ Hz. At the apex of a Cole–Cole semicircle, $\omega_\text{peak} R_\text{ct} C_\text{dl} = 1$, so

$$C_\text{dl} = \frac{1}{2\pi f_\text{peak} R_\text{ct}} = \frac{1}{2\pi(50)(0.020)} \approx 0.16\ \text{F} = 160\ \text{mF}.$$

Notice the order of magnitude. In Chapter 2 we estimated the *intrinsic* double-layer capacitance as $10\!-\!40\,\mu\text{F/cm}^2$ — that is per unit of *true* electrochemical surface area. A commercial 18650 contains electrodes whose porous, particulate microstructure exposes hundreds to thousands of cm² of real surface area per cm² of geometric footprint, and the total geometric footprint inside an 18650 is itself a few hundred cm². Multiplying these factors out, total $C_\text{dl}$ values in the 10 mF to 1 F range are normal for a full cell. The seemingly enormous capacitance is the first quantitative reminder that a porous battery electrode behaves nothing like a flat electrode in an introductory textbook.

Low-frequency Warburg slope: extends from roughly 0.1 Hz down to 10 mHz, showing the characteristic 45° behaviour of semi-infinite solid-state diffusion.

Total impedance at 10 mHz: $Z' \approx 120$ mΩ — much larger than the ohmic value, dominated at this frequency by diffusion and the accumulated kinetic losses.

**What EIS tells you that HPPC cannot:** The ability to separate $R_\Omega$, $R_\text{ct}$, $C_\text{dl}$, and the Warburg impedance in a single measurement is what makes EIS uniquely powerful. For degradation diagnosis: if $R_\text{ct}$ grows while $R_\Omega$ stays constant, the degradation is at the electrode–electrolyte interface (kinetic degradation — charge-transfer resistance growth, often due to SEI thickening or cathode surface reconstruction). If $R_\Omega$ grows, the degradation is in the bulk electrolyte or current collectors (electrolyte depletion, contact deterioration). If the Warburg region changes character, solid-state diffusion in the particles is affected (particle cracking, lithium ordering). EIS thus gives a diagnostic fingerprint that can point toward specific degradation mechanisms — a topic we will develop fully in Chapter 7.

---

## Worked Interpretation Exercise: Reading a Commercial Cell Datasheet

Let us apply the full vocabulary of this chapter to a real commercial datasheet. We will use the publicly available datasheet for the **Panasonic NCR18650B** cell — a 3.4 Ah, NCA chemistry, 18650 cylindrical cell widely used in electric vehicles (it was the cell used in early Tesla Model S battery packs) and frequently studied in the academic literature.

**Header information:**

- **Nominal voltage: 3.6 V.** This is the average discharge voltage at a standard (low) C-rate. It is not the OCV at any specific SOC — it is a weighted average across the full discharge curve.
- **Minimum voltage: 2.5 V.** This is the lower cutoff voltage $V_\text{cutoff}$. Discharging below this risks deep lithiation of the cathode and potential structural damage.
- **Charge voltage: 4.2 V.** This is $V_\text{max}$ for CC-CV charging. Exceeding this accelerates cathode degradation and electrolyte oxidation.
- **Standard charge: CC-CV at 1.625 A (≈ C/2) to 4.2 V, cutoff at 50 mA.** This defines the standard charging protocol: CC at roughly 0.5C until 4.2 V, then CV at 4.2 V until the current tapers to 50 mA (about C/70 — a very conservative CV termination criterion).

**Capacity specification:**

- **Minimum capacity: 3250 mAh at standard charge, discharged at 0.2C.** Note that this is measured at a slow rate (C/5), not at 1C. The 3.4 Ah nominal rating is the typical (not minimum) value. The minimum guarantee is 3.25 Ah.
- **Typical capacity: 3350 mAh.** At C/5.

**Discharge curves (graphical):**

The datasheet shows a family of discharge curves at different temperatures (−20°C, 0°C, 23°C, 45°C) at 0.5C and a family at different C-rates (0.2C, 0.5C, 1C, 2C) at 23°C.

- The voltage-vs-capacity curves slope smoothly from about 4.15 V at the start of discharge to about 3.3 V at 80% capacity, then drop more steeply to the 2.5 V cutoff. There is no flat plateau — this is the NCA chemistry's single-phase sloped discharge characteristic, very different from LFP's flat plateau. This slope makes NCA cells amenable to voltage-based SOC estimation.
- At −20°C, the cell delivers only about 1.8 Ah at 0.5C — roughly 53% of its room-temperature capacity. The voltage sags early because charge-transfer resistance is much higher at low temperature. This is consistent with the Arrhenius dependence of $i_0$.
- As C-rate increases from 0.2C to 2C, the discharge curves shift downward (more voltage sag from larger ohmic and kinetic overpotentials) and the delivered capacity decreases slightly. At 2C, capacity is about 3.1 Ah — 92% of the 0.2C value. This is a well-designed cell: rate capability is good.

**Cycle life:**

- **Cycle life: ~500 cycles to ~70% capacity retention** (at 1C charge/1C discharge, 23°C, 100% DOD). Note that this retention threshold is more permissive than the conventional 80% EOL criterion. If we reinterpret for the conventional 80% criterion, the cycle life would be considerably shorter — perhaps 250–350 cycles depending on the fade curve shape.

**Temperature range:**

- **Operating: −20°C to +60°C (discharge), 0°C to +45°C (charge).** The asymmetry between discharge and charge temperature ranges is important: charging below 0°C is prohibited because low-temperature charging drives lithium plating on the graphite anode (the lithium cannot intercalate quickly enough, so it deposits as metal). This is a hard safety limit, not a performance guideline.

**What the datasheet does not tell you:**

The Panasonic NCR18650B datasheet does not include: OCV-vs-SOC curve (you must measure it); DCIR vs. SOC curve; differential capacity ($dQ/dV$) curve; EIS parameters; or degradation curves at elevated temperature or partial SOC cycling. For modelling purposes, all of these must either be measured by the researcher or found in the academic literature — there is a substantial body of published characterisation data for this specific cell, which is one reason it is so commonly used in battery modelling studies.

**What the datasheet implies but doesn't say.** Look back at what we have just extracted. Notice how much the datasheet is *not* telling us. We do not know the OCV curve, so we cannot do voltage-based SOC estimation without measuring it. We do not know how DCIR varies with SOC or temperature, so we cannot predict instantaneous power capability away from the single test condition. We do not know the contribution of $R_\Omega$, $R_\text{ct}$, and the Warburg components separately, so we cannot diagnose what changes during ageing. We do not know cycle life under realistic duty cycles (mixed DOD, varying temperature), only under a single benchmark condition. Reading a datasheet well is as much about knowing what isn't there as what is — and the gap between datasheet and what a battery model needs is exactly why the characterisation techniques in Section 3.10 exist.

---

## What Changes for Sodium-Ion?

The metrics and terminology in this chapter are chemistry-agnostic — capacity, C-rate, SOC, SOH, CC-CV charging, OCV, DCIR, all apply equally to sodium-ion cells. What changes are the specific values, and in one case — the OCV curve shape — something qualitatively important changes.

The most practically significant difference is the **OCV curve shape of hard carbon anodes**. As discussed in Section 3.4, the flat plateau region of hard carbon at low potential (below 0.1 V vs. Na/Na⁺) means that the full cell OCV of a SIB has a flatter region than typical lithium-ion cells. The available energy in this plateau region is effectively invisible to a voltage-based SOC estimator. The fraction of total capacity in the plateau varies by material and processing conditions but is typically 20–40% of the total hard carbon capacity. A BMS for a SIB cell must be designed with this fundamental OCV limitation in mind.

The **first-cycle Coulombic efficiency** is lower for SIBs than for graphite-based LIBs, though the gap has been narrowing rapidly. Older hard carbons gave ICE in the 75–85% range; current optimised commercial hard carbons (HiNa, Kuraray, and others) routinely report 88–92%, approaching the 90–95% typical of graphite. ICE remains a key materials-level optimisation target for SIB anodes, since each percentage point of irreversible first-cycle loss translates directly into wasted active sodium inventory at the cathode. This affects not just the cell-level ICE measurement but also the pre-lithiation/pre-sodiation strategy used by manufacturers to compensate: some SIB manufacturers add a sacrificial sodium source (sodium metal, sodium-rich compounds) to the cell during manufacturing to pre-dope the hard carbon and compensate for the SEI formation loss. Interpreting a cycle life measurement for a pre-sodiated hard carbon cell is different from interpreting one for a standard cell — the initial capacity is artificially higher.

The **internal resistance** of commercial SIB cells tends to be higher than comparable lithium-ion cells at the same format, primarily because: (1) Na⁺ is larger and moves more slowly in the electrolyte ($D_\text{Na}^+ < D_\text{Li}^+$ in most electrolytes); (2) the charge-transfer kinetics at hard carbon are somewhat slower; and (3) the hard carbon SEI is thicker and less conductively optimised than graphite's. Current commercial SIB cells (e.g., HiNa BC-1, CATL first-generation) report DCIRs of 80–150 mΩ for 26650-format cells, compared to 20–50 mΩ for a comparable NMC 18650. This higher impedance translates directly to lower power density and higher heat generation, both of which are important design considerations.

---

## Chapter Summary

**Key ideas:**

- Capacity (Ah) measures stored charge; energy (Wh) = average voltage × capacity. Both are specified at a reference rate and temperature. Gravimetric (Wh/kg) and volumetric (Wh/L) energy densities are the normalised, intensive quantities used to compare cells.
- C-rate is a normalised current: 1C discharges a cell in one hour. Higher C-rates deliver less capacity because concentration polarisation drives the terminal voltage to the cutoff before the electrode is fully discharged.
- SOC is fractional charge fill relative to current maximum capacity. DOD = 1 − SOC. SOH tracks degradation: capacity-based SOH$_Q$ and resistance-based SOH$_R$ measure different aspects of ageing and may diverge.
- OCV is the true equilibrium voltage (requires long rest after current); terminal voltage = OCV minus overpotentials under load. OCV curve flatness is the fundamental challenge for voltage-based SOC estimation in LFP and SIB cells.
- Internal resistance has three components: ohmic ($R_\Omega$, instantaneous), charge-transfer ($R_\text{ct}$, RC time constant), and diffusion (Warburg, diffusion time constant). DCIR is a measurement-protocol-dependent lumped number; EIS separates all three components.
- Coulombic efficiency CE = $Q_\text{disch}/Q_\text{chg}$ per cycle. Round-trip energy efficiency $\eta_E$ = CE × voltage efficiency. CE ≈ 99.8–99.95% for mature LIB; cumulative loss over 500 cycles is significant.
- Cycle life (number of cycles to EOL) and calendar life (time to EOL at rest) have different physical origins. High-DOD cycling, high temperature, and high SOC storage all accelerate ageing.
- CC-CV charging: constant-current until $V_\text{max}$, then constant-voltage until current tapers. Protects against electrode overpotential and overcharge; charging below 0°C is prohibited for graphite to avoid lithium plating.
- Characterisation techniques: HPPC (internal resistance vs. SOC, ECM parameters), GITT (OCV curve + solid-state diffusion coefficient), PITT (differential capacity $dQ/dV$), EIS (full impedance spectrum separating $R_\Omega$, $R_\text{ct}$, $C_\text{dl}$, Warburg).

**Key equations:**

$$Q = \int I\,dt, \qquad E = \bar{V} \cdot Q$$

$$\text{SOC} = \frac{Q_\text{remaining}}{Q_\text{max}}, \qquad \text{DOD} = 1 - \text{SOC}$$

$$\text{SOH}_Q = \frac{Q_\text{max}(t)}{Q_\text{max}(0)}$$

$$\text{CE} = \frac{Q_\text{disch}}{Q_\text{chg}}, \qquad \eta_E = \eta_V \cdot \text{CE}$$

$$R_\text{int} = \frac{\Delta V}{I}$$

$$Z(\omega) = Z'(\omega) + j Z''(\omega)$$

$$\Delta E \propto \sqrt{t} \;\Rightarrow\; D_s \text{ from GITT slope (eq.\ 3.16)}$$

**Key vocabulary (in order of appearance):**

Capacity (Ah), energy (Wh), C-rate, cutoff voltage, gravimetric energy density, volumetric energy density, state of charge (SOC), depth of discharge (DOD), state of health (SOH), equivalent full cycle (EFC), open-circuit voltage (OCV), terminal voltage, OCV hysteresis, ohmic resistance, charge-transfer resistance, diffusion resistance, DC internal resistance (DCIR), Coulombic efficiency (CE), initial Coulombic efficiency (ICE), voltage efficiency, round-trip efficiency, calendar life, cycle life, self-discharge, CC-CV protocol, HPPC, GITT, PITT, differential capacity ($dQ/dV$), EIS, Nyquist plot, Randles circuit, Warburg impedance, incremental capacity analysis (ICA).

---

## Deliverable

**Task:** Download a CATL or Samsung cell datasheet and a HiNa SIB datasheet. Write a one-page interpretation of each, explaining every graph and specification in your own words.

**Guidance:** Specific cells to use:

For LIB: The **Samsung INR21700-50E** (5.0 Ah, NMC, 21700 format) datasheet is publicly available and contains a comprehensive set of discharge curves, temperature performance, and cycle life data. The **CATL M3P** datasheet (a lithium manganese iron phosphate chemistry, available through industry contacts or technical presentations) is an alternative.

For SIB: The **HiNa BC-1** cell (1.33 Ah, hard carbon / O3-type layered oxide, 26650 format) has been characterised in several published papers even if a commercial datasheet is not publicly available. Search for "HiNa battery characterisation" or "BC-1 SIB" in Google Scholar. Alternatively, the **Faradion/Reliance 18650 SIB cell** has appeared in published characterisation studies.

When writing your interpretation, address each of the following explicitly for both cells:

The nominal voltage and what chemistry it implies. The rated capacity and at which C-rate it was measured. The shape of the discharge curves at multiple C-rates — is the OCV shape sloped or flat, and what does that imply for SOC estimation? The temperature performance — at what temperature does the cell retain 80% of room-temperature capacity, and is this consistent with Arrhenius-type kinetic limitations? The cycle life specification — is the EOL criterion 80% capacity retention, and over what DOD? The internal resistance (if provided) and how it compares between the two cells.

A **partial worked example for the Samsung INR21700-50E** based on published data (Sturm et al., *Journal of Power Sources*, 2021):

Nominal voltage 3.6 V, rated capacity 4.9 Ah at C/5 (note: rated as "50E" for 5.0 Ah but typical measured capacity is 4.9 Ah). The discharge curve at room temperature has a moderately sloped profile between about 4.15 V and 3.0 V with a gentle knee around 3.3 V — characteristic of NMC chemistry with no flat plateau. At $-20°C$ and 0.5C, capacity drops to approximately 2.8 Ah — about 57% of room-temperature capacity — consistent with kinetic limitation from elevated $R_\text{ct}$ at low temperature. Cycle life: typically rated 500 cycles to 80% at 1C/1C, 25°C, 100% DOD.

---

## Further Reading

1. **Plett, G. L., *Battery Management Systems, Vol. 1: Battery Modeling*, Artech House (2015), Chapters 1–2.** The most EE-friendly introduction to battery metrics, OCV curves, and equivalent circuit models. Plett's notation is clean and his examples are numerical and direct. This is the companion text for Part VI of this book, but Chapters 1–2 are directly relevant here.

2. **Barai, A. et al., "A study of the influence of measurement timescale on internal resistance characterisation methodologies for lithium-ion cells," *Scientific Reports* 8, 21, (2018).** A careful experimental study demonstrating how DCIR measurements depend on pulse duration, temperature, and SOC, and why different measurement protocols give different answers. Shows the gap between HPPC-style measurements and EIS-derived parameters.

3. **Weppner, W. and Huggins, R. A., "Determination of the kinetic parameters of mixed-conducting electrodes and application to the system Li₃Sb," *Journal of the Electrochemical Society* 124 (10), 1569–1578 (1977).** The original GITT paper. Worth reading to see how the technique was conceived — the derivation of the $\sqrt{t}$ relationship is elegant and builds directly on Fick's second law.

4. **Barsoukov, E. and Macdonald, J. R. (eds.), *Impedance Spectroscopy: Theory, Experiment, and Applications*, Wiley (3rd edition, 2018), Chapter 4.** The standard reference for EIS, with a comprehensive treatment of the physical models underlying battery impedance spectra. Chapter 4 covers Randles circuits and Warburg impedance in depth.

5. **Dubarry, M. et al., "Synthesize battery degradation modes via a diagnostic and prognostic model," *Journal of Power Sources* 219, 204–216 (2012).** The paper that established incremental capacity analysis (ICA) as a diagnostic tool for identifying degradation modes from $dQ/dV$ and $dV/dQ$ curves. Directly connects PITT/slow-discharge measurements to the degradation mechanisms we will study in Chapter 7.

---

*Next chapter: **Chapter 4 — Cell Construction.** We descend into the physical world of how a cell is actually built — electrode manufacturing, form factors, formation cycling, and current collector materials. Prompt me with "write Chapter 4" to continue.*

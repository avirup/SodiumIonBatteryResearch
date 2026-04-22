# Chapter 13: What's Different About Sodium

## Chapter Opening

You have now read twelve chapters of battery science, and sodium-ion batteries have appeared in every one of them — in the "What Changes for Sodium-Ion?" sections that have closed each chapter since Chapter 1, in the detailed treatment of hard carbon and layered oxide cathodes in Chapter 6, in the thermal safety comparison in Chapter 8, in the balancing and estimation complications in Chapters 10 and 11, and in the safety concept implications in Chapter 12. The picture has been assembled incrementally, one piece per chapter, in the context of whichever concept was being introduced. Now it is time to hold all the pieces together simultaneously and examine them as a system.

This chapter is the consolidation. Its purpose is to answer a single question with the full depth the book has been building toward: *What does an engineer — specifically a simulation-focused electrical engineer who wants to do research on sodium-ion batteries — need to know that is different from what they know about lithium-ion batteries?* Not different at the level of "sodium is cheaper" or "hard carbon instead of graphite" — those surface-level facts were established in Chapters 4 and 6. Different at the level of which model equations need to change, which parameters need new values, which physical mechanisms have different magnitudes or different signs, and which failure modes are amplified, suppressed, or entirely new.

The answer to that question is the research agenda for SIB simulation. Every section of this chapter identifies a place where your LIB knowledge requires modification or extension when applied to sodium. Some modifications are straightforward substitutions — different standard potential, different ionic radius, different numerical values. Others are qualitative changes — mechanisms that work differently in kind, not just in degree. And a few are genuine open problems where the physics is not yet well-characterised and where careful, rigorous simulation work can make a real contribution.

Read this chapter with a notebook open. By the end, you should have a list of specific, targeted research questions: "What is the solid-state diffusion coefficient of Na⁺ in NVPF as a function of temperature, and how does it compare to Li⁺ in LFP?" "How does the O3→P3 phase transition in NaMnO₂ manifest in a DFN model, and what parameter captures it?" "Is the Bruggeman exponent for hard carbon electrodes the same as for graphite?" These questions — questions that a physicist or chemist would not think to ask but that an engineer building simulation models must answer — are the entry points to your research career.

---

> **Prerequisites Check**
>
> This chapter synthesises the entire book. All chapters are prerequisite reading. Specific sections most directly drawn upon:
>
> - Chapter 1 (Sections 1.4, 1.7, 1.8): standard potentials, Faraday's laws, Gibbs free energy
> - Chapter 2 (Sections 2.1–2.3, 2.5–2.8): intercalation, SEI, Butler-Volmer, diffusion
> - Chapter 3 (Sections 3.4, 3.10): OCV curves, GITT, EIS
> - Chapter 4 (Sections 4.3, 4.4): formation cycling, current collectors
> - Chapter 6 (all sections): the primary SIB reference chapter
> - Chapter 7 (all sections): degradation mechanisms and their signatures
> - Chapter 8 (Sections 8.2, 8.7): Bernardi equation, thermal safety comparison
> - Chapters 10–12: state estimation, balancing, functional safety
>
> Before reading, spend five minutes reviewing the table in Chapter 6 Section 6.9 (the quantitative comparison of SIB vs. LIB cells). That table is the numerical reference frame for most of the discussions in this chapter.

---

## 13.1 Na⁺ vs. Li⁺: The Fundamental Physical Differences and Their Cascading Consequences

We established the basic physical differences between sodium and lithium ions in Chapter 6, Section 6.1. Here we systematise those differences and trace each one through the full chain of consequences — from atomic physics to cell design to BMS algorithm to safety classification.

When you sit down to build your first SIB simulation model — whether in PyBaMM, COMSOL, or your own MATLAB code — the temptation will be to take a working LIB model and replace every lithium-related parameter with its sodium counterpart. The ionic radius difference we are about to examine explains why this "find-and-replace" approach will fail in subtle ways. The 34% size increase does not merely change numerical parameter values; it changes which crystal structures are viable, which transport mechanisms dominate, and in some cases which governing equations are even appropriate. Understanding this cascade from one physical fact to many engineering consequences is the organising theme of this entire chapter.

### Ionic Radius: The Root of Almost Everything

The sodium ion Na⁺ has an ionic radius of **1.02 Å** in octahedral coordination; Li⁺ has **0.76 Å**. The ratio is 1.34 — sodium is 34% larger. This single physical fact propagates through the entire SIB system in ways that affect every level of the engineering hierarchy.

At the **crystal structure level**, the larger Na⁺ requires larger interstitial sites in the host material. This has two consequences that run in opposite directions. First, it disqualifies graphite as an anode: the staging energy for NaC₆ is thermodynamically unfavourable at room temperature because expanding the graphite interlayer spacing to accommodate Na⁺ costs more energy than is recovered from the sodium-graphene interaction. The interplanar spacing of graphite (0.335 nm) is too small; hard carbon's turbostratic interlayer spacing (0.37–0.40 nm) and closed nanopores are more accommodating. Second, in oxide cathode materials, the larger Na⁺ actually fits more comfortably in the prismatic coordination environment of P2-type structures than in the octahedral sites preferred by Li⁺. This is why P2-type layered oxides — which have no stable lithium analogue — are commercially viable and scientifically important SIB cathodes (Chapter 6, Section 6.2).

At the **electrolyte level**, the ionic radius affects solvation shell structure and desolvation kinetics. In carbonate electrolytes, Na⁺ has a primary solvation shell coordination number of approximately 5–6, compared to approximately 4 for Li⁺. Counterintuitively, the *desolvation energy* of Na⁺ is generally *lower* than that of Li⁺, because Na⁺'s lower charge density produces weaker individual ion-solvent bonds. Published computational and experimental studies typically place Na⁺ desolvation energies at 35–50 kJ/mol in carbonates, compared to 50–65 kJ/mol for Li⁺.

Yet the overall charge-transfer activation energy $E_{a,\text{ct}}$ measured from EIS — which lumps desolvation, SEI ion transport, and the electrode-surface charge-transfer step — is often *higher* for SIB cells than for comparable LIB cells. This apparent contradiction reflects the fact that the SEI on hard carbon is generally thicker, less ionically conductive, and less well-optimised than the mature graphite SEI in LIBs. It is the *total interfacial process*, not desolvation alone, that produces the higher $R_\text{ct}$ observed for SIB cells. Reported $E_{a,\text{ct}}$ values for SIB hard carbon half-cells in carbonate electrolytes range from 50–75 kJ/mol, compared to 40–60 kJ/mol for graphite in LIB carbonate electrolytes — a modest but meaningful difference that translates to a factor of 2–4 in $R_\text{ct}$ at 25°C and a larger factor at low temperatures. For example, commercial SIB 26650-format cells show $R_\text{ct} \approx 80$–150 mΩ, while LIB 18650 cells typically show $R_\text{ct} \approx 20$–50 mΩ. (Caution: these are different cell formats with different electrode areas. An area-normalised comparison using $R_\text{ct} \cdot A_\text{electrode}$ [Ω·cm²] would be more rigorous, but the point that SIB interfacial kinetics are slower holds even after area normalisation.)

In ether-based electrolytes (DEGDME, diglyme), the solvation structure of Na⁺ is fundamentally different: Na⁺ coordinates with the ether oxygen atoms in a configuration that is energetically more favourable and kinetically more labile than the carbonate coordination. Desolvation in ether electrolytes is faster, $R_\text{ct}$ is lower, and rate capability is better. This is why ether electrolytes have attracted so much attention for hard carbon SIB anodes and why the comparison between carbonate and ether electrolyte SIB performance data in the literature is not a fair apples-to-apples comparison — they represent different fundamental solvation physics.

At the **simulation model level**, the larger ionic radius affects which parameters of the Doyle-Fuller-Newman (DFN) model require new values when adapting from LIB to SIB. The solid-state diffusion coefficient $D_s$ in all electrode materials takes different numerical values and has different temperature dependence for Na⁺ hosts compared to Li⁺ hosts. In a DFN simulation, $D_s$ controls how quickly concentration gradients relax inside the electrode particles — get it wrong, and the model will under- or over-predict the voltage sag at high C-rates. The charge-transfer rate constant $k_0$ at both electrodes is generally lower for SIB systems due to the slower interfacial kinetics discussed above; this parameter sets the activation overpotential in the Butler-Volmer equation and directly affects the model's prediction of power capability. The electrolyte thermodynamic factor $f_\pm$ and activity coefficient $\gamma_\pm$ are different because SIB electrolytes are different chemical systems (NaPF₆ or NaFSI in different solvent mixtures); these parameters govern the concentration-potential coupling in the electrolyte phase and affect the predicted concentration overpotential at high rates. Finally, the partial molar volume $\Omega$ of the sodium-host intercalation compound controls the predicted diffusion-induced stress in the electrode particles — a parameter critical for mechanical degradation modelling (Chapter 7), where the larger Na⁺ produces larger lattice strain per intercalated ion.

None of these can be assumed equal to their LIB counterparts. All require either direct experimental measurement (GITT for $D_s$, EIS for $k_0$, specific characterisation experiments for $\Omega$) or careful extrapolation from density functional theory (DFT) calculations.

### Standard Electrode Potential: The Voltage Penalty

The Na⁺/Na reduction potential of −2.71 V vs. SHE is 0.33 V higher (less negative) than the Li⁺/Li potential of −3.04 V. This is a thermodynamic fact that cannot be altered by any material engineering choice. It means that a sodium-ion cell built with cathode and anode materials structurally analogous to their lithium counterparts will have a cell voltage 0.33 V lower than the LIB — all else being equal.

In practice, the voltage penalty for commercial SIB cells relative to comparable LIB cells is slightly larger than 0.33 V because the specific cathode and anode materials used in SIBs are not identical in electrochemical character to their LIB counterparts. Commercial O3-type SIB cathodes operate at an average voltage of 3.0–3.3 V vs. Na/Na⁺, while commercial NMC cathodes operate at 3.6–3.8 V vs. Li/Li⁺ — a difference of 0.5–0.6 V that exceeds the fundamental thermodynamic difference, reflecting the currently limited cathode voltage performance of SIB materials.

For simulation modelling: the OCV curves used in DFN models and ECMs for SIBs are referenced to the Na/Na⁺ scale. When converting to the SHE scale (necessary for comparing thermodynamic data across chemistries), the conversion is $E_\text{SHE} = E_\text{Na/Na⁺} - 2.71 \; \text{V}$. Note that electrolyte transport properties — ionic conductivity $\kappa$, diffusion coefficient $D_e$, transference number $t_+$ — are intrinsic material properties measured in SI units and do not change when you switch between reference electrode scales. The reference electrode choice affects only how you report potentials.

### Ionic Mass: The Capacity Penalty

Sodium is 22.99 g/mol; lithium is 6.94 g/mol — a ratio of 3.31. For every equivalent of charge stored (1 mol of ions cycled), a sodium-ion electrode stores 3.31 times more mass in the ion species itself compared to a lithium electrode. This directly reduces the gravimetric specific capacity of any material that stores sodium compared to a structurally analogous lithium storage material.

The theoretical specific capacity formula from Chapter 1 makes this explicit:

$$C_\text{th} = \frac{nF}{3.6 \, M_\text{host+ion}} \tag{13.1}$$

where $M_\text{host+ion}$ includes the mass of the host material and the stored ion. For a given host structure with molar mass $M_\text{host}$, storing Na gives a lower specific capacity than storing Li because $M_\text{Na} > M_\text{Li}$.

For hard carbon vs. graphite: Graphite stores Li in LiC₆ ($M = 79$ g/mol, $C_\text{th} = 372$ mAh/g). Hard carbon stores Na at a maximum loading of approximately $\text{Na}_{0.8}\text{C}_6$ (that is, about 0.13 Na per C atom — far lower than a 1:1 ratio). The molar mass per carbon atom is then $M \approx 12 + (0.8/6) \times 22.99 \approx 15.1$ g/mol, which gives a theoretical specific capacity of $C_\text{th} = (0.8/6) \times 96{,}485 / (3.6 \times 15.1) \approx 237$ mAh/g. Practical values for well-optimised hard carbons range from 250 to 350 mAh/g, with the upper end exceeding this simple stoichiometric estimate because the nanopore-filling mechanism provides additional capacity beyond what interlayer intercalation alone contributes. The ionic mass penalty is real but is not the dominant limiter for hard carbon specific capacity — the mechanism (nanopore filling has limited sites, not limited mass) is more constraining than the mass calculation alone.

### Summary Table: Na⁺ vs. Li⁺ at a Glance

#### Table 13.1: Fundamental Physical Properties of Na⁺ vs. Li⁺

| Property | Li⁺ | Na⁺ | Ratio (Na/Li) | Primary Consequence |
| --- | --- | --- | --- | --- |
| Ionic radius (octahedral, Å) | 0.76 | 1.02 | 1.34 | Different host structures; graphite excluded |
| Atomic mass (g/mol) | 6.94 | 22.99 | 3.31 | Lower gravimetric capacity |
| Standard potential vs. SHE (V) | −3.04 | −2.71 | — | 0.33 V lower cell voltage |
| Solvation coordination no. (carbonate) | ~4 | ~5–6 | — | Different desolvation kinetics |
| Charge-transfer $E_{a,\text{ct}}$ in carbonate (kJ/mol) | 40–60 | 50–75 | — | Higher $R_\text{ct}$, worse rate capability |
| Charge-transfer $E_{a,\text{ct}}$ in ether (kJ/mol) | — | 25–40 | — | Low-temperature advantage |
| Bulk metal density (g/cm³) | 0.534 | 0.971 | 1.82 | Heavier plated deposits |
| Crustal abundance (ppm) | 20 | 23,600 | ~1,180 | Cost advantage |

---

## 13.2 Hard Carbon Anode Behaviour: The Slope and Plateau in Depth

We described hard carbon's slope and plateau OCV mechanism in Chapter 6, Section 6.5. Here we go deeper — examining the quantitative parameters that matter for simulation, the unresolved physical questions about the mechanism, and the practical consequences for model choice.

### The Two-Mechanism Model Revisited

The Stevens-Dahn "house of cards" model (Chapter 6) attributes slope-region capacity to sodium intercalation into the turbostratic interlayer spaces and plateau-region capacity to nanopore filling with quasi-metallic sodium. This model has been the consensus view for over two decades, supported by SAXS (pore volume change at the plateau), ²³Na NMR (distinct sodium environments in slope vs. plateau), and synchrotron PDF analysis (local structural changes).

However, the model is not without controversy. An alternative interpretation — the "adsorption-intercalation" model — reverses the assignment: the slope region reflects surface and defect adsorption of sodium, and the plateau region reflects intercalation into the graphene layer stacks. Recent high-resolution studies using in-operando synchrotron diffraction have shown that the graphene interlayer spacing of hard carbon does expand slightly during the plateau, consistent with intercalation into the turbostratic stacks at that potential. The current scientific consensus (as of 2024–2025) is that both mechanisms contribute to both regions, with nanopore filling dominating the plateau and turbostratic intercalation dominating part of the slope — but the detailed mechanistic assignment is still an active research topic.

**Why this matters for simulation**: If the dominant mechanism switches during cycling (slope = intercalation, plateau = pore filling), then the appropriate physical model for each region is different. Intercalation into a layered host is well described by solid-state diffusion with Fick's second law and the DFN model's treatment of spherical particles with concentration-dependent diffusion. Nanopore filling, however, is better described as an adsorption process — possibly following a Langmuir or Freundlich isotherm for the nanopore sites — with different mathematical structure.

An EE analogy may help clarify the distinction. Solid-state diffusion through a layered lattice is analogous to signal propagation along a distributed RC transmission line: the governing equation is a diffusion PDE, the "signal" (sodium concentration) propagates continuously, and the characteristic time scales with the square of the distance. Nanopore filling, by contrast, is more like charging a finite bank of discrete capacitors, each with its own access resistance: the process is governed by the number of available sites (capacitors) and the kinetics of accessing each one, not by continuous diffusion through a medium. A model that uses only the transmission-line equation to describe both processes will fit the data in one regime and fail in the other.

A DFN model that applies the same single-particle diffusion equation throughout the hard carbon electrode may be adequate for engineering purposes but physically incorrect in detail. This creates a genuine research opportunity: developing a two-mechanism model for hard carbon that correctly represents the slope region with solid-state diffusion physics and the plateau region with a pore-filling (adsorption) model, and validating this model against GITT and EIS data from hard carbon half-cells. Such a model would provide more physically faithful predictions of rate capability, temperature dependence, and ageing behaviour for hard carbon anodes.

### The Diffusion Coefficient in Hard Carbon

Solid-state diffusion of sodium in hard carbon is fundamentally different from solid-state diffusion of lithium in graphite, because hard carbon is amorphous rather than crystalline. The diffusion coefficient $D_s$ cannot be defined in the same way as for a crystal lattice (where diffusion proceeds along specific crystallographic directions). Instead, $D_s$ in hard carbon is an effective apparent diffusivity that represents the combination of tortuous paths through the disordered carbon matrix.

GITT measurements of hard carbon anodes in SIB half-cells consistently show that $D_s$ is strongly state-of-charge dependent:

In the **slope region** (SOC 0–70% approximately, where sodium is occupying turbostratic interlayer sites), $D_s \approx 10^{-12}$–$10^{-11}$ m²/s at 25°C, with strong dependence on sodium content. These values are higher than lithium diffusion in graphite ($D_s \approx 10^{-14}$–$10^{-13}$ m²/s for LiC₆ → C₆), which seems counterintuitive for a larger ion but reflects the more open, disordered structure of hard carbon compared to the tight interlayer spacing of graphite.

In the **plateau region** (SOC 70–100% approximately, where nanopore filling occurs), $D_s$ drops dramatically, often to $10^{-15}$–$10^{-14}$ m²/s. This drop is consistent with the interpretation that sodium in the plateau is entering increasingly confined nanopores with limited diffusion pathways. The abrupt transition in $D_s$ at the slope-plateau boundary is one of the clearest experimental signatures of the mechanism change.

The strong $D_s$ variation with SOC means that any simulation model using a single, fixed $D_s$ value for the hard carbon electrode will be quantitatively inaccurate in at least one SOC region. A concentration-dependent $D_s$ is required, analogous to the concentration-dependent diffusion coefficient used for some LIB electrode materials but with a more dramatic variation for hard carbon.

The temperature dependence of $D_s$ in hard carbon follows the Arrhenius law. Reported activation energies span a range of 25–55 kJ/mol depending on the hard carbon source and processing conditions — comparable to graphite's activation energy for lithium diffusion (20–50 kJ/mol). This means that the solid-state diffusion limitation worsens at low temperatures for hard carbon at approximately the same rate as for graphite — the low-temperature advantage of SIBs over LIBs does not come from better solid-state diffusion, but from the faster interfacial kinetics (lower desolvation energy in ether electrolytes, or the different hard carbon surface chemistry).

### Modelling Hard Carbon in the DFN Framework

The standard DFN model assumes each electrode consists of spherical particles of uniform radius $r_p$, with sodium (or lithium) diffusing through the solid particle according to Fick's second law in spherical coordinates:

$$\frac{\partial c_s}{\partial t} = \frac{1}{r^2}\frac{\partial}{\partial r}\left(r^2 D_s \frac{\partial c_s}{\partial r}\right) \tag{13.2}$$

with boundary conditions at the particle centre (zero flux by symmetry) and at the surface (flux equal to the pore-wall flux $j_n$ from the Butler-Volmer equation).

For hard carbon, applying this equation directly requires addressing three complications:

**Complication 1 — Effective particle geometry**: Hard carbon is not composed of spherical particles in the traditional sense. Hard carbon particles are aggregates of disordered carbon with a complex internal pore structure. The "effective particle radius" used in a DFN model is an empirical parameter fitted to the electrode's rate behaviour, not a directly measurable geometric quantity. Typical values used in the literature range from 1 to 10 µm, depending on the particle size distribution of the specific hard carbon material and its processing.

**Complication 2 — SOC-dependent $D_s$**: As described above, $D_s$ varies by 3–4 orders of magnitude between the slope and plateau regions. In the DFN model, $D_s$ must be expressed as a function of the local sodium concentration $c_s$: $D_s = D_s(c_s/c_{s,\text{max}})$. This function must be parameterised from GITT data, and its implementation in the DFN solver requires careful numerical treatment (concentration-dependent diffusion in spherical coordinates introduces nonlinearity that can cause convergence issues with naive finite difference discretisation).

**Complication 3 — Two-mechanism storage**: If the slope-region intercalation and plateau-region nanopore filling are physically distinct mechanisms, the single-particle DFN model may need extension. One approach is a two-state model: each hard carbon "particle" contains both intercalation sites (accessed first, during slope charging) and nanopore sites (accessed last, during plateau charging), with different diffusion coefficients and different OCV characteristics for each site type. The total charge stored is the sum from both populations. This two-state approach has been implemented by several research groups and gives better agreement with experimental rate capability data than the single-mechanism DFN.

---

## 13.3 Why the Plateau Breaks OCV-Based SOC Estimation: The Estimation Problem in Full

We have examined the flat-OCV SOC estimation problem from multiple angles throughout the book — in Chapter 3 (OCV curve sensitivity), Chapter 6 (hard carbon mechanism), Chapter 10 (EKF Kalman gain drops to zero), and Chapter 12 (diagnostic coverage gap). Here we synthesise all of this into a complete, quantitative statement of the problem and a survey of the proposed solutions.

### The Complete Problem Statement

A sodium-ion cell with a hard carbon anode has the following OCV characteristics at 25°C (representative of a commercial O3 layered oxide / hard carbon cell):

A brief but important note on SOC convention: in a half-cell (hard carbon vs. Na metal), SOC typically refers to the degree of sodiation of the anode — SOC = 100% means fully sodiated hard carbon. In the full cell, SOC = 100% means the cell is fully charged, which corresponds to the anode being fully sodiated and the cathode being fully desodiated. The anode's slope region (high $dV/d(\text{SOC})$, occurring at low sodiation in the half-cell) maps to the *high* full-cell SOC range (60–100%), because the anode is approaching empty (desodiated) as the full cell is "charged." Conversely, the anode's plateau (occurring at high sodiation in the half-cell) maps to the *low-to-mid* full-cell SOC range (15–60%). If the SOC mapping between Sections 13.2 and 13.3 seems backwards, this is why — the anode's state runs in the opposite direction to the full cell's state during charge.

The full-cell OCV curve divides into three regions. From 0 to approximately 15% SOC, the hard carbon anode is in its steep slope region, and the full-cell OCV gradient is approximately 150 mV per unit SOC — steep enough for accurate voltage-based SOC estimation. From approximately 15% to 60% SOC, the hard carbon anode is in its plateau region, and the full-cell OCV gradient falls to approximately 25–50 mV per unit SOC, dominated by the soft OCV variation of the layered oxide cathode against a nearly constant anode potential near 0.05 V vs. Na/Na⁺. From approximately 60% to 100% SOC, the hard carbon returns to its upper slope region and the full-cell gradient recovers to approximately 80 mV per unit SOC, as both electrodes contribute to the voltage change.

The OCV hysteresis between charge and discharge in the plateau region is approximately 50–80 mV — the charge-direction OCV is higher than the discharge-direction OCV at the same true SOC.

With a cell voltage measurement noise of $\sigma_V = 5$ mV (from a 16-bit CMIC over a 4V range), the SOC uncertainty in each region is: In the steep slope region ($dE/d\text{SOC} \approx 150$ mV), $\sigma_\text{SOC} = 5/150 \approx 3.3\%$ — acceptable. In the plateau ($dE/d\text{SOC} \approx 25$–50 mV), $\sigma_\text{SOC}$ ranges from $5/50 = 10\%$ to $5/25 = 20\%$, with a midpoint estimate of $5/37 \approx 13.5\%$ — poor by any BMS standard. In the upper slope region ($dE/d\text{SOC} \approx 80$ mV), $\sigma_\text{SOC} = 5/80 \approx 6.3\%$ — marginal.

The plateau spans 45% of the SOC range. During normal operation (charging from 20% to 90% SOC to protect longevity), approximately 56% of the operational SOC range falls within or near the plateau — the majority of normal operation is in the regime where voltage-based SOC correction is poor. This is not the same as LFP, where the plateau is even flatter (~3 mV/unit SOC) but the non-plateau regions at the extremes are routinely accessed by the BMS for recalibration. For SIBs, the combination of a larger plateau, higher hysteresis, and a more gradual slope-to-plateau transition creates a worse-case estimation environment than LFP.

### Proposed Solutions and Their Status

**Solution 1 — Improved coulomb counting with temperature and ageing compensation**: The simplest approach is to accept the flat-OCV regime and improve coulomb counting accuracy to minimise drift during the plateau. This requires: (a) a high-accuracy current sensor (shunt-based with <10 mA offset and <0.1% gain error); (b) careful temperature compensation of both the current sensor and the $Q_\text{max}$ parameter; (c) frequent rest-state OCV recalibration at the extremes of SOC (when the cell exits the plateau into the steep slope regions). This approach is pragmatic and implementable with existing BMS hardware, but its accuracy is bounded by the coulomb counting drift rate — for a cell operating continuously in the plateau for 10 hours (a common grid storage duty cycle), the uncorrected SOC drift from current sensor errors alone can reach 5–10%.

**Solution 2 — Extended EKF with hysteresis state variable**: The EKF can be augmented with a hysteresis state variable $h$ that tracks the cell's OCV correction due to the history-dependent memory effect in hard carbon. The augmented model uses separate charge-direction and discharge-direction OCV curves, with the hysteresis state providing a continuous transition between them based on recent current direction. Plett's group developed this approach for LFP cells and demonstrated improved SOC accuracy compared to single-curve EKF. The approach requires an additional model for hysteresis dynamics:

$$\dot{h} = \gamma |i| (\text{sgn}(i) \, M(\text{SOC}) - h) \tag{13.3}$$

where $\gamma$ is the hysteresis rate constant, $i$ is the current, and $M(\text{SOC})$ is the maximum hysteresis magnitude at each SOC (a function that peaks in the slope region where hysteresis is largest). The augmented EKF with hysteresis has been implemented in SIB simulation environments and shows improvement in SOC accuracy during mixed charge/discharge operation, but it requires fitting an additional three or four parameters from characterisation data.

**Solution 3 — EIS-based impedance fingerprinting**: The impedance spectrum of a hard carbon electrode changes in detectable ways between the slope and plateau regions, particularly in the mid-frequency range (0.1–10 Hz) where the Warburg behaviour (related to solid-state diffusion) and the charge-transfer arc are both sensitive to the local sodium concentration. If the BMS has the ability to perform abbreviated EIS measurements (a sinusoidal current perturbation at one or two selected frequencies, rather than a full frequency sweep), it can extract impedance-derived SOC indicators that remain sensitive even in the OCV plateau.

Recall from Chapter 3 (Section 3.10) that the Warburg impedance appears as a 45° line on the Nyquist plot at low frequencies — the regime where the cell's response is dominated by solid-state diffusion rather than charge-transfer kinetics. The slope of that 45° line is the Warburg coefficient $\sigma_W$, and it encodes the diffusion rate. Specifically, the Warburg coefficient — the slope of $Z''$ vs. $\omega^{-1/2}$ in the Warburg region — is proportional to $(D_s c_{s,\text{max}})^{-1/2}$, which changes as $D_s$ drops dramatically entering the plateau. An impedance measurement at a single frequency in the Warburg region can therefore detect the slope-to-plateau transition and maintain some SOC sensitivity across the plateau. This approach is not yet in commercial BMS hardware but is an active research topic, and is feasible with existing embedded DSP hardware if the frequency injection capability is added to the CMIC.

**Solution 4 — Physics-based model with full two-mechanism hard carbon**: A full DFN model that explicitly represents both the intercalation and nanopore-filling mechanisms in hard carbon can predict SOC more accurately than an ECM because it tracks the internal state variables (concentration profiles in slope sites vs. nanopore fill fraction) that are the true determinants of the cell's electrochemical state. The model-based estimator (using an extended Luenberger observer or an EKF operating on the full DFN state vector) can maintain SOC accuracy in the plateau by leveraging the model's physics, even when the terminal voltage provides little information. The computational cost of running a full DFN model in real time on a BMS microcontroller is high but not prohibitive with modern embedded processors (32-bit ARM Cortex-M4 or M7) and reduced-order model techniques (Padé approximations, proper orthogonal decomposition). This represents the frontier of SIB BMS research.

### Worked Interpretation: Reading a Hard Carbon GITT Curve

Imagine you have performed a GITT (Galvanic Intermittent Titration Technique) experiment on a hard carbon half-cell (hard carbon vs. Na metal, NaPF₆/EC:DMC electrolyte) during sodiation (discharge of the half-cell). The experiment applies a constant current pulse of $C/20$ for 30 minutes, then rests for 4 hours, repeatedly, from 2.0 V down to 0.01 V vs. Na/Na⁺.

What you would see, reading the voltage-vs.-capacity curve from left to right:

**Region 1 (2.0 V → ~0.10 V, slope region):** Each current pulse produces a voltage drop of approximately 15–30 mV from the OCV, and the relaxation during rest is rapid — the voltage recovers to within 2 mV of steady state within 30–60 minutes. The quasi-equilibrium OCV after each rest step decreases steeply and smoothly. From the GITT formula (Chapter 3, Equation 3.18), you extract $D_s$ values in the range $10^{-12}$–$10^{-11}$ m²/s. The high $D_s$ means sodium redistributes quickly inside the hard carbon particles after each pulse, producing fast voltage relaxation.

**Region 2 (~0.10 V → ~0.05 V, transition zone):** The voltage drop per pulse begins to increase (now 30–60 mV at the same current), and the relaxation slows — full equilibration now requires 2–3 hours. The extracted $D_s$ drops by one to two orders of magnitude within a narrow capacity window. This is the slope-to-plateau transition, and the dramatic slowdown in diffusion is one of the clearest experimental signatures of the mechanism change from interlayer intercalation to nanopore filling.

**Region 3 (~0.05 V → 0.01 V, plateau region):** The quasi-equilibrium OCV is nearly flat (the plateau), but each current pulse now produces a large voltage drop (50–100 mV), and the relaxation is very slow — 3–4 hours is often insufficient for full equilibration. The extracted $D_s$ is $10^{-15}$–$10^{-14}$ m²/s. If you truncate the rest period at 2 hours (as some experimenters do to save time), you will systematically underestimate the equilibrium OCV in this region and overestimate $D_s$ — a common experimental artefact in hard carbon GITT studies that you should watch for when reading the literature.

The takeaway: a single GITT experiment on a hard carbon half-cell gives you the $D_s$ vs. SOC function that a DFN model requires — but only if the rest periods are long enough to reach true equilibrium at every point, which for the plateau region may mean 4–6 hour rests. Literature values extracted with shorter rest periods should be treated with caution.

---

## 13.4 Aluminium Current Collectors on Both Sides: Cost, Implications, and Modelling

We established the thermodynamic basis for aluminium current collectors on both SIB electrodes in Chapter 4, Section 4.4. Here we consolidate the full picture — not just why it works, but what it changes for cell design, pack architecture, and simulation modelling.

### Manufacturing Simplification

Using a single current collector material (aluminium, 12–20 µm foil) for both electrodes eliminates the procurement, inventory management, and process qualification required for two different foil materials (copper and aluminium). In a manufacturing environment that processes millions of cells, simplifying from two material suppliers and two process lines to one is not a trivial advantage. The reduction in bimetallic joint interfaces (places where copper and aluminium busbars must be welded or bolted together, creating galvanic corrosion risks and mechanical joint reliability concerns) also simplifies pack assembly.

The areal cost of aluminium foil is approximately \$0.08–0.12/m², compared to \$0.25–0.40/m² for copper foil of the same thickness. For an 18650-equivalent cell with approximately 0.4 m² of anode current collector area (both sides, one roll), the raw material saving from switching to aluminium is approximately \$0.07–0.12 per cell — modest per cell but significant at gigawatt-hour scale manufacturing volumes.

### Electronic Resistance Increase

Aluminium has a higher bulk resistivity than copper: $\rho_\text{Al} = 2.65 \times 10^{-8}$ Ω·m vs. $\rho_\text{Cu} = 1.72 \times 10^{-8}$ Ω·m — aluminium is approximately 54% more resistive per unit volume. For the same foil thickness (12 µm), the **sheet resistance** of the anode current collector increases from:

$$R_\text{sheet,Cu} = \frac{1.72 \times 10^{-8}}{12 \times 10^{-6}} = 1.43 \; \text{m}\Omega/\square$$

to:

$$R_\text{sheet,Al} = \frac{2.65 \times 10^{-8}}{12 \times 10^{-6}} = 2.21 \; \text{m}\Omega/\square$$

The unit "mΩ/□" (milliohms per square) is the standard unit of sheet resistance: it is the resistance of any square piece of the foil, regardless of the square's size, measured between two opposite edges. If you have worked with thin-film resistors or PCB copper layers, this is the same quantity. For a rectangular current collector of length $L$ and width $W$, the total resistance is $R = R_\text{sheet} \times (L/W)$.

For a jelly-roll electrode with a current path of approximately 50 cm from the active area to the tab, the current collector contribution to cell resistance increases by the ratio 2.21/1.43 = 1.54. If the copper anode current collector contributed 2 mΩ to the cell's total internal resistance in an 18650-format LIB, the aluminium anode current collector in an equivalent SIB would contribute approximately 3 mΩ — an increase of 1 mΩ in total cell resistance, comparable to or smaller than the other differences in $R_0$ between LIB and SIB cells (which arise from SEI resistance and charge-transfer resistance differences). The current collector resistance increase is real but is a minor contribution to the overall higher DCIR of SIB cells.

One advantage of the aluminium-for-copper substitution that is easy to overlook: weight. Aluminium's density is 2.70 g/cm³, compared to copper's 8.96 g/cm³. For the same foil thickness, the aluminium anode current collector is 3.3× lighter than the copper it replaces. In an 18650-format cell where the anode current collector contributes roughly 5–8 g of copper mass, switching to aluminium saves approximately 3.5–5.5 g per cell. This mass saving partially offsets the gravimetric energy density penalty of SIBs at the cell level — a small but non-negligible contribution to closing the Wh/kg gap with LIBs.

### Implications for the Tabless and Large-Format Cell Design

For large-format cells (4680-type cylindrical, large prismatic), current collector resistance becomes a more significant fraction of total cell resistance because the current path length is longer. The **tabless design** used in 4680-type cells (Chapter 4, Section 4.1) that reduces current collector resistance by creating distributed contact points along the electrode length is equally applicable to SIB large-format cells — and becomes more important for SIBs precisely because the base $R_0$ from Al is higher and the benefit of reducing the current path length is proportionally greater.

For SIB simulation models, the current collector resistance is included as part of the total ohmic resistance $R_0$ in the DFN model or ECM. When parameterising from HPPC or EIS data, $R_0$ is measured as a lumped quantity that includes current collector, contact, and SEI contributions — the current collector fraction is not separately identifiable from terminal measurements alone. Post-mortem characterisation (measuring the current collector resistance independently by four-wire measurement on a harvested foil) is required if the current collector contribution is to be separated from the total.

---

## 13.5 The Low-Temperature Advantage: Physical Origin and Quantification

SIB cells are consistently better than LIB cells at low temperatures — not slightly better, but substantially better in some chemistries. The HiNa BC-1 retains approximately 88% of room-temperature capacity at −20°C and 70% at −40°C (Chapter 6, Section 6.8), while a typical NMC/graphite LIB retains 50–60% at −20°C and often cannot discharge at all at −40°C. This section provides the physical explanation and quantifies the mechanism.

### The Activation Energy Story

From Chapter 10, Section 10.3 (Equation 10.23), the charge-transfer resistance at temperature $T$ is:

$$R_\text{ct}(T) = R_\text{ct}(T_0) \cdot \exp\!\left[\frac{E_{a,\text{ct}}}{R}\left(\frac{1}{T} - \frac{1}{T_0}\right)\right] \tag{13.5}$$

This is the Arrhenius resistance scaling first introduced as Equation 10.23; we reproduce it here as Equation 13.5 for convenience and because it is the central equation of this section.

The variable $E_{a,\text{ct}}$ is the activation energy for the rate-limiting interfacial step. The low-temperature performance is almost entirely determined by this activation energy: a lower $E_{a,\text{ct}}$ means $R_\text{ct}$ grows less severely as temperature decreases, and the cell maintains better rate capability at low temperature.

For graphite anodes in LiPF₆/carbonate electrolytes, the rate-limiting step is the desolvation of Li⁺ from its carbonate solvation shell, with $E_{a,\text{ct}} \approx 40$–60 kJ/mol. For hard carbon anodes in SIBs, the situation depends on the electrolyte:

In carbonate electrolytes (NaPF₆ in EC:DMC), the charge-transfer activation energy is $E_{a,\text{ct}} \approx 45$–65 kJ/mol — comparable to graphite in LIB carbonate electrolytes, so no significant low-temperature advantage arises. In ether electrolytes (NaPF₆ or NaFSI in DEGDME), $E_{a,\text{ct}}$ drops to approximately 25–40 kJ/mol — significantly lower than either the SIB-carbonate or LIB-carbonate value.

The lower activation energy in ether electrolytes is the physical origin of the SIB low-temperature advantage. It arises from the different solvation structure of Na⁺ in ether: the linear ether molecules coordinate Na⁺ through sequential chelation (the flexible chain wraps around the ion), and this configuration is more easily disrupted during desolvation than the rigid carbonate cage around Li⁺. The result is a lower energy barrier for the ion transfer step at the electrode-electrolyte interface.

Numerically, at −20°C (253 K) vs. 25°C (298 K), with $E_{a,\text{ct}} = 35$ kJ/mol (ether SIB) vs. 55 kJ/mol (carbonate LIB):

$$\frac{R_\text{ct}(-20°\text{C})}{R_\text{ct}(25°\text{C})}\bigg|_\text{ether SIB} = \exp\!\left[\frac{35000}{8.314}\left(\frac{1}{253} - \frac{1}{298}\right)\right] = \exp(2.51) \approx 12.3 \quad (\text{since } e^{2.5} \approx 12.18)$$

$$\frac{R_\text{ct}(-20°\text{C})}{R_\text{ct}(25°\text{C})}\bigg|_\text{carbonate LIB} = \exp\!\left[\frac{55000}{8.314}\left(\frac{1}{253} - \frac{1}{298}\right)\right] = \exp(3.95) \approx 52.5$$

The carbonate LIB's $R_\text{ct}$ grows 52.5× at −20°C, while the ether SIB's grows only 12.3×. This 4.3-fold difference in resistance growth at low temperature is the quantitative basis of the SIB low-temperature advantage. In a cell where $R_\text{ct}$ is the dominant contributor to internal resistance (which it is at low temperatures), the SIB delivers substantially better power capability.

This also explains why the low-temperature advantage of SIBs is electrolyte-dependent: an SIB using carbonate electrolyte does not have a significant low-temperature advantage over LIBs, because the charge-transfer activation energy for Na⁺ in carbonates is similar to that for Li⁺. The advantage is specific to ether electrolytes.

### Implications for Pack and BMS Design

The low-temperature advantage means that SIB packs may not need cell preheating systems in climates where temperatures drop to −20°C — a system simplification that reduces pack cost and complexity. For LIB packs designed for Nordic, Canadian, or high-altitude deployments, preheating is typically mandatory (adding 500–1500 W of heating power and the associated thermal management hardware). An SIB pack that can start charging and discharging at −20°C without preheating eliminates this cost.

For BMS algorithms, the lower temperature sensitivity of $R_\text{ct}$ means the temperature-derated current limit (the algorithm that restricts charging current at low temperatures to prevent plating) is less aggressive for SIBs. The threshold current below which plating risk is negligible can be higher at a given temperature for SIBs, allowing faster cold-weather charging without safety compromise.

---

## 13.6 The Safety Advantage: Physical Origin at Depth

Chapter 8 (Section 8.7) quantified the SIB thermal safety advantage. Here we examine the physical mechanism more deeply, connecting the cathode crystal chemistry established in Chapter 6 to the calorimetric measurements that validate the safety claim.

### Oxygen Release: The Dominant Heat Source

As established in Chapter 8, the dominant exothermic event in LIB thermal runaway is the reaction between oxygen released from the delithiated cathode and the organic electrolyte. The oxygen release temperature is set by the thermodynamics of the transition metal oxide decomposition:

For LCO (Co³⁺/Co⁴⁺ couple, fully delithiated → CoO₂): CoO₂ → ½Co₂O₃ + ¼O₂ begins at approximately 170–200°C for deeply delithiated states ($x > 0.5$ in $\text{Li}_{1-x}\text{CoO}_2$), with the onset temperature decreasing as the degree of delithiation increases. The Co⁴⁺ state is strongly oxidising and thermodynamically unstable.

For NMC811 (dominated by Ni³⁺/Ni⁴⁺): Fully delithiated NiO₂-like phases are even more unstable, with decomposition beginning around 180–200°C.

For O3-type SIB cathodes ($\text{Na[Ni}_{0.4}\text{Fe}_{0.3}\text{Mn}_{0.3}\text{]O}_2$, fully desodiated): The average oxidation state of the transition metals at full charge is lower than in the equivalent LIB cathode, because sodium-ion cathodes typically operate at lower voltages and the transition metal redox couples are partially different. Iron (Fe³⁺/Fe⁴⁺) and manganese (Mn³⁺/Mn⁴⁺) are involved alongside nickel, and these species are less aggressively oxidising than pure Ni⁴⁺. Oxygen release from fully charged O3-type SIB cathodes begins at approximately 240–280°C.

The 60–100°C increase in oxygen release temperature for SIB layered oxides vs. NMC811 is the physical basis of the higher thermal runaway onset temperature measured by accelerating rate calorimetry (ARC). This difference arises from three factors: the lower average oxidation state of the transition metals in SIB cathodes at full charge, the presence of iron (which forms more stable oxides than nickel), and the different structural response of the O3 sodium oxide framework to decomposition compared to the nickel-rich NMC framework.

For polyanionic SIB cathodes — NVPF, NFPP, and NASICON-type structures (Na Super Ionic CONductor; recall Chapter 6, Section 6.3) — the polyanion framework (PO₄³⁻, (PO₃F)²⁻) physically entraps the oxygen — the phosphate-oxygen bonds are strong covalent bonds that resist cleavage even at temperatures above 400°C. This is the same mechanism as LFP's exceptional thermal safety (Chapter 5, Section 5.3). NVPF shows no measurable oxygen release below 420°C — comparable to or better than LFP.

For PBA cathodes (Prussian white, Na₂Fe[Fe(CN)₆]): Decomposition begins at approximately 300–350°C, but the product is not molecular oxygen — it is HCN (hydrogen cyanide) and CO from cyanide bridge cleavage, plus the metal oxide residue. HCN is toxic but not as rapidly combustion-supporting as O₂. The hazard profile of PBA cathode failure is different from layered oxide failure — less fire risk, but toxic gas generation. This difference must be addressed in the SIB safety concept.

### Implications for ARC Test Interpretation

ARC (accelerating rate calorimetry) tests performed on commercial SIB cells confirm the theoretical prediction. The self-heating onset temperature $T_\text{onset}$ — defined as the temperature at which the cell's self-heating rate exceeds the ARC detection threshold (typically 0.02°C/min) — is approximately 110–140°C for O3-type SIB cells, compared to 80–120°C for NMC811 at high SOC (depending on ARC sensitivity) and above 150°C for LFP. The peak temperature during runaway $T_\text{max}$ reaches approximately 400–500°C for O3 SIB, compared to 750–850°C for NMC811. The total heat released $Q_\text{total}$ is approximately 8–12 kJ for a 1.33 Ah 26650 SIB cell, compared to 28–38 kJ for a 3 Ah 18650 NMC811 cell. Note the capacity difference: on a per-ampere-hour basis, the comparison is approximately 8 kJ/Ah for SIB vs. 10 kJ/Ah for NMC811 — less dramatic than the raw cell-level numbers suggest.

The total heat per ampere-hour is not dramatically different because the stored electrochemical energy per Ah is similar for both chemistries — the SIB advantage comes primarily from the higher initiation temperature (larger margin from ambient to $T_\text{onset}$), which determines whether a thermal event begins at all, rather than from a dramatically lower total energy release.

For ASIL classification in the functional safety framework (Chapter 12), the question is whether the higher $T_\text{onset}$ justifies a Severity downgrade from S3. In typical ambient environments (up to 45°C), the margin from ambient to $T_\text{onset}$ is approximately 55–75°C for NMC811 ($T_\text{onset} - T_\text{amb} \approx 100 - 45$) and approximately 75–95°C for O3 SIB ($T_\text{onset} - T_\text{amb} \approx 120 - 45 = 75°\text{C}$ at the low end). The SIB's larger margin means that to trigger thermal runaway, the cell must undergo a more severe abuse event (longer-duration short circuit, higher overcharge overvoltage, more intense external heating). Whether this quantitatively justifies a Severity downgrade from S3 to S2 depends on the specific pack design and the abuse event scenarios — this is the formal HARA analysis that safety engineers must conduct with ARC test evidence.

In practical safety testing, the difference is visible in the nail penetration test — the standard abuse test (IEC 62660-3, GB/T 31485) in which a steel nail is driven through a fully charged cell to create an internal short circuit. NMC811 LIB cells subjected to nail penetration typically exhibit violent venting, flame, and surface temperatures exceeding 500°C within seconds. O3-type SIB cells under the same test show a less energetic response: venting occurs but is less violent, flame is less likely (and when present, less sustained), and peak surface temperatures typically remain below 300°C. Polyanionic SIB cells (NVPF) often pass nail penetration without any flame or sustained thermal event. These results are direct consequences of the higher $T_\text{onset}$ and lower total energy release discussed above, translated from the controlled ARC environment into the violent, adiabatic conditions of a puncture event.

---

## 13.7 SEI Differences in SIBs

The SEI on hard carbon anodes in sodium-ion electrolytes differs from the graphite SEI in LIBs in composition, thickness, stability, and formation kinetics. These differences propagate into cell performance, calendar aging, and the accuracy of any physics-based degradation model.

### Composition Differences

The SEI on hard carbon in carbonate electrolytes (NaPF₆ or NaClO₄ in EC:DMC) contains different species than the LIB graphite SEI. The inorganic inner layer is dominated by NaF (from NaPF₆ → NaF + PF₅) and Na₂CO₃ (from carbonate solvent reduction), with $\text{Na}_2\text{O}$ (sodium oxide) contributing a smaller fraction than $\text{Li}_2\text{O}$ does in LIB SEIs. The organic outer layer contains sodium alkyl carbonates (analogous to lithium alkyl carbonates in LIBs), but with different chain structures reflecting different radical intermediates in the Na⁺-mediated reduction pathway.

The ionic conductivity of NaF is lower than that of LiF (the dominant inorganic species in LIB SEIs). This is counterintuitive — a larger lattice might seem to give ions more room to move — but the critical factor is the activation energy for each ion hop between lattice sites. In NaF, the hop distance is larger and the saddle-point energy (the energy barrier the Na⁺ must surmount to move from one lattice site to the next) is higher than the corresponding barrier for Li⁺ in LiF. The net effect is lower Na⁺ mobility through the NaF crystal and higher ionic resistance contribution from the inorganic SEI layer. This contributes to higher SEI ionic resistance in SIBs and is one physical reason for the higher overall $R_0$ of SIB cells.

In ether electrolytes (NaPF₆ or NaFSI in DEGDME), the SEI composition is dramatically different: the carbonate-derived organic species are absent, replaced by ether decomposition products (primarily sodium ethylene glycolate and related oligomers) and a higher fraction of inorganic NaF. The ether-derived SEI is generally thinner (5–15 nm vs. 20–50 nm for carbonate-derived SEI), more mechanically stable, and more ionically conductive — explaining the higher ICE (85–92%) and better cycling stability observed with ether electrolytes on hard carbon.

### Formation and Evolution

The formation of the hard carbon SEI during the first cycles shares the same general mechanism as graphite SEI formation: electrolyte reduction at the electrode surface below the electrolyte's reduction stability potential. For hard carbon in NaPF₆/EC:DMC, the SEI formation onset is at approximately 1.0–1.5 V vs. Na/Na⁺ (during the first charge). For comparison, the graphite SEI onset in LiPF₆/EC:DMC is ~0.8 V vs. Li/Li⁺, which on the SHE scale corresponds to −2.24 V — equivalent to about 0.47 V vs. Na/Na⁺. The hard carbon SEI onset is therefore at a substantially more positive potential than the graphite onset, even after accounting for the different reference scales. This difference reflects the catalytic activity of hard carbon's abundant surface functional groups (ether, carboxyl, hydroxyl residues from pyrolysis), which initiate electrolyte reduction reactions at more positive potentials than the relatively inert basal-plane surface of crystalline graphite.

The key difference in formation kinetics is the **hard carbon surface chemistry**. Hard carbon has more surface functional groups than crystalline graphite (ether groups, carboxyl groups, hydroxyl groups from the pyrolysis of oxygen-containing precursors) that react with the sodium electrolyte in addition to the carbonate solvent reduction. These additional reactions are partly responsible for the lower ICE of hard carbon compared to graphite — the functional groups consume sodium irreversibly, and more surface area per unit mass (10–15 m²/g vs. 1–4 m²/g for graphite) means proportionally more surface reaction.

For simulation models of SIB calendar aging, the SEI growth kinetics should follow the same parabolic $\sqrt{t}$ law as for LIBs (Chapter 7, Section 7.2), but with a different rate constant $k_\text{SEI}$ and activation energy $E_a$. The limited long-term calendar aging data published for SIB cells (most studies cover less than two years) makes it challenging to extract these parameters reliably. The $\sqrt{t}$ fits that are available suggest $k_\text{SEI}$ values somewhat higher than for LIB graphite in the same temperature range — consistent with the lower SEI stability and the higher surface area of hard carbon. This means SIB calendar aging at elevated temperature (40–45°C) may be faster than LFP/graphite (which has exceptionally stable calendar aging) but potentially comparable to or slower than NMC811/graphite at the same temperature.

---

## 13.8 Degradation Modes Unique to or Amplified in SIBs

Chapter 7 established the three-mode degradation framework (LLI, LAM, CL) and the specific mechanisms that drive each mode. For SIBs, all three modes are present, but the relative importance of mechanisms differs, and a small number of failure modes are unique to the sodium chemistry.

### O3→P3 Phase Transition Fatigue in Layered Oxide Cathodes

O3-type layered oxide SIB cathodes (the most commercially prevalent cathode type) undergo the O3→P3 phase transition during deep desodiation (Chapter 6, Section 6.2). This transition involves gliding of the MO₂ oxide layers relative to each other — a crystallographic shear deformation that creates structural disorder and, in polycrystalline cathode particles, stress concentrations at grain boundaries.

Unlike the smooth solid-solution cycling of NMC cathodes in LIBs (which involves only continuous lattice parameter changes without layer gliding), the O3→P3 transition is a first-order phase transition with an associated discontinuous volume change. The repeated phase transition causes intergranular cracking at grain boundaries within polycrystalline cathode particles, contributing to loss of active material (LAM). It also drives accumulation of structural defects — stacking faults and anti-site defects — that reduce sodium mobility through the cathode lattice and increase impedance (contributing to conductivity loss, CL). In the first cycles, the transition is partially irreversible, adding a first-cycle capacity loss on top of the SEI-related losses at the anode.

The O3→P3 phase transition can be suppressed or mitigated by several strategies. Limiting the upper voltage cutoff avoids complete desodiation and keeps the cathode below the transition composition — trading capacity for stability, which is a common commercial strategy. Doping the cathode with electrochemically inactive elements (Mg, Ti, Cu) stabilises the O3 stacking through the transition region by pinning the oxide layers and increasing the energy cost of the shear deformation. Using single-crystal cathode particles eliminates the grain boundaries where intergranular cracking initiates, analogous to the single-crystal NMC strategy in LIBs (Chapter 5). Finally, blending O3 and P2 phases in the same cathode creates a composite where the P2 component — which does not undergo the same shear transition — buffers the mechanical stress from the O3 component's transformation.

For simulation models of SIB cathode degradation, the O3→P3 transition must be represented either explicitly (through a phase-transition model that switches between the O3 and P3 free-energy curves at the transition composition) or implicitly (through an empirical strain/stress model that captures the accumulated damage as a function of the depth of desodiation past the transition point). Neither approach has been as thoroughly developed for SIB cathodes as the analogous NMC degradation models for LIBs.

### PBA Cathode-Specific Degradation: Water and Vacancy Evolution

For PBA-based SIB cells (Chapter 6, Section 6.4), degradation mechanisms unique to the open framework structure are present.

**Water release from the PBA structure**: As discussed in Chapter 6, PBA cathodes contain zeolitic water (in the channels) and coordinated water (at vacancy sites). During cycling, this water is released and reacts with the electrolyte salt — the dominant pathway being $\text{NaPF}_6 + \text{H}_2\text{O} \rightarrow \text{NaF} + \text{POF}_3 + 2\text{HF}$ — generating HF that attacks the SEI and promotes additional parasitic reduction reactions at the anode surface. These parasitic reactions consume mobile Na⁺ irreversibly, contributing to LLI. The rate of water release is temperature-dependent and accelerated at elevated temperature, making calendar aging at high SOC and high temperature the dominant degradation pathway for PBA cells.

**Hexacyanometalate vacancy growth**: PBAs are synthesised with a fraction of vacancies (missing [M(CN)₆] units) that is controlled by synthesis conditions. During cycling, the electrochemical stress can cause additional vacancy formation — the crystal framework is locally disrupted as sodium ions enter and leave rapidly. Growing vacancy density reduces the capacity (fewer sites for sodium) and increases impedance (vacancies disrupt the electronic conductivity of the framework). This mechanism has no LIB analogue; it is unique to the open-framework PBA structure.

### Sodium Plating: Less Dendrite-Prone but Still Damaging

As established in Section 7.3 and Section 13.5, sodium metal deposits are less prone to sharp dendrite formation than lithium metal deposits. The difference arises from the different surface energy and diffusion kinetics of sodium metal: sodium's higher surface diffusion coefficient (at room temperature) promotes lateral spreading of deposits rather than needle growth, producing more equiaxed and less penetrating metallic sodium deposits.

However, sodium metal deposits are not completely benign. Dead sodium (electrochemically isolated sodium metal) contributes to LLI — and because hard carbon's plateau region brings the anode potential very close to 0 V vs. Na/Na⁺ during full charging, the driving force for plating is always present near the top of charge. The lower dendrite tendency means catastrophic separator penetration is less likely, but the LLI contribution from dead sodium accumulates with cycling, particularly under fast charging at low temperatures.

For simulation models of SIB cycle aging: the plating contribution to LLI should follow the same framework as for LIBs (conditional on the local anode potential reaching 0 V vs. Na/Na⁺), but with modified parameters for the plating rate constant (lower overpotential required to trigger measurable plating), the dead sodium fraction (likely higher than dead lithium fraction because sodium metal is less reactive with the SEI after plating), and the re-intercalation efficiency (how much plated sodium re-inserts on the subsequent discharge).

### Hard Carbon Structural Evolution Over Cycling

Hard carbon microstructure is not static over thousands of cycles. The repeated expansion and contraction of the turbostratic interlayer spacings during slope-region cycling causes gradual ordering — the hard carbon slowly evolves toward a more graphitic local structure — meaning the turbostratic carbon layers, which start out randomly oriented and irregularly spaced, gradually become more parallel and more uniformly spaced, approaching (though never reaching) the crystalline order of graphite. Think of it as a messy stack of papers that, after being repeatedly pressed and released, settles into a neater pile. This structural ordering is slow (thousands of cycles) but directional and irreversible, and occurs particularly in regions of the electrode that cycle most intensively.

This structural evolution has three measurable consequences. First, it changes the slope of the hard carbon OCV curve: as the turbostratic character diminishes, the slope region becomes steeper and the plateau becomes less well-defined, altering the voltage signature that the BMS uses for SOC estimation. Second, it increases the local diffusion coefficient in slope-region intercalation sites, because the more uniform layer spacing allows faster sodium transport. Third, it reduces the closed-pore fraction available for nanopore filling, as crosslinks between disordered carbon layers break and pores either open to the electrolyte (becoming part of the accessible surface rather than storage sites) or collapse under mechanical stress.

This structural evolution has no precise LIB analogue (graphite's crystal structure is more stable under Li cycling). It means that the SIB hard carbon anode parameters — $D_s$, OCV curve shape, and the ratio of slope to plateau capacity — evolve over the cell's life. A physics-based SIB model that assumes static electrode parameters will gradually diverge from experimental observations over extended cycling, and the divergence will be systematic (not random) because the structural evolution is directional. Capturing this evolution requires either periodic re-parameterisation of the model (practical for post-hoc analysis but not for real-time BMS prediction) or a physics-based model of the hard carbon structural evolution itself (a research-frontier challenge).

---

## What Changes for SIB Simulation Research: A Research Agenda

We have now systematically identified every place in the battery physics framework where sodium differs from lithium. Let us consolidate this into an explicit research agenda — the list of open problems that a simulation-focused EE researcher can meaningfully address.

The problems are arranged roughly in order of tractability (easier first, harder later). For each, I note which experimental or computational approach is needed to address it.

**Problem 1 — DFN model parameterisation for hard carbon**: The solid-state diffusion coefficient $D_s(c_s, T)$ for Na⁺ in hard carbon, the charge-transfer rate constant $k_0(T)$, and the OCV thermodynamic factor have not been systematically characterised as functions of both composition and temperature for commercially relevant hard carbon materials. A complete GITT and EIS characterisation study at multiple temperatures and multiple hard carbon precursor/synthesis conditions would establish the parameter database needed for reliable DFN simulations. This is experimental rather than purely simulation work, but the experimental protocols (GITT, EIS, half-cell fabrication) are well-established and the data analysis follows standard methods.

**Problem 2 — Two-mechanism hard carbon model development**: Implementing a DFN model with separate intercalation (slope) and nanopore-filling (plateau) mechanisms for the hard carbon anode, validating it against rate capability data and GITT, and comparing it to the single-mechanism model in terms of predictive accuracy. This is primarily simulation and model development work, with model validation against published experimental data.

**Problem 3 — EKF-based SOC estimation for flat-OCV SIB cells**: Demonstrating quantitatively the SOC uncertainty growth during the plateau region, implementing the hysteresis-augmented EKF (or an alternative), and evaluating the improvement in SOC accuracy. This is pure algorithm development and can be done entirely in simulation using a parameterised SIB cell model.

**Problem 4 — O3→P3 phase transition model**: Incorporating the O3→P3 transition into a physics-based cathode degradation model for O3-type SIB cathodes, analogous to the mechanical degradation models for NMC811 in LIBs. The transition provides a well-defined structural event that can be modelled using phase-field methods or empirical stress accumulation models.

**Problem 5 — SIB calendar aging characterisation and modelling**: Systematically measuring the calendar aging rate of commercial SIB cells (HiNa BC-1 or equivalent) at multiple temperatures and SOC levels, fitting the parabolic growth model with Arrhenius temperature dependence, and comparing the resulting parameters to the equivalent LIB values. This establishes the calendar aging model needed for SIB lifetime prediction.

**Problem 6 — Physics-based thermal runaway model for SIB chemistries**: Extending the Bernardi-based thermal models from Chapter 8 to include the specific exothermic reactions in SIB thermal abuse (O3 cathode decomposition at higher temperature, different electrolyte decomposition products, sodium plating exothermic reactions). Connecting the model to ARC test data to validate the simulated thermal runaway trajectory.

Each of these problems is tractable for a simulation-focused researcher with access to published experimental data and standard simulation tools (PyBaMM, MATLAB/Simulink, COMSOL). Problems 2, 3, and 4 can be addressed entirely computationally; Problems 1, 5, and 6 require experimental data that may or may not be available from the published literature for the specific chemistry you study. Chapter 14 will return to this agenda in the context of the current research landscape.

---

## Chapter Summary

**Key ideas:**

- Na⁺ is 34% larger (1.02 Å vs. 0.76 Å), 3.3× heavier, and 0.33 V higher in reduction potential than Li⁺. Na⁺ has lower desolvation energy than Li⁺ (due to lower charge density), but the overall charge-transfer activation energy $E_{a,\text{ct}}$ for SIB cells is higher because of contributions from the less mature SEI and electrode-interface processes. These differences propagate into every level of the SIB engineering hierarchy.
- Hard carbon anode behaviour is characterised by two mechanisms: turbostratic intercalation (slope region, $D_s \approx 10^{-12}$–$10^{-11}$ m²/s) and nanopore filling (plateau region, $D_s \approx 10^{-15}$–$10^{-14}$ m²/s). The dramatic drop in $D_s$ at the slope-plateau boundary requires a concentration-dependent diffusion coefficient in DFN models. A two-mechanism hard carbon model is physically more faithful than the standard single-particle DFN approach.
- The flat OCV plateau (25–50 mV/unit SOC, spanning ~45% of the operational SOC range) makes voltage-based SOC estimation unreliable for approximately 56% of normal operation. Solutions include enhanced coulomb counting with OCV recalibration at the extremes, hysteresis-augmented EKF, EIS-based impedance fingerprinting, and physics-based DFN model observers. All are active research topics.
- Aluminium current collectors on both electrodes save approximately \$0.07–0.12 per cell in raw material cost, simplify manufacturing, and reduce cell mass by 3.5–5.5 g (from the Cu→Al substitution), at the cost of ~54% higher current collector sheet resistance. The resistance increase is real but minor compared to other contributors to SIB's higher DCIR.
- The low-temperature advantage of SIBs is electrolyte-specific: ether electrolytes have $E_{a,\text{ct}} \approx 25$–40 kJ/mol for Na⁺ charge transfer vs. 40–60 kJ/mol for Li⁺ in carbonate electrolytes, producing a 4–5× smaller $R_\text{ct}$ growth factor at −20°C and substantially better power capability.
- The thermal safety advantage arises from higher oxygen release temperatures for SIB cathodes (>240°C for O3 oxides vs. ~180–200°C for NMC811; >400°C for polyanionic cathodes). $T_\text{onset}$ for SIB thermal runaway is ~110–140°C (vs. 80–120°C for NMC811), peak temperature ~400–500°C (vs. 750–850°C), and total heat release ~8–12 kJ/cell (vs. 28–38 kJ/cell for NMC).
- SIB-specific degradation modes: O3→P3 phase transition fatigue in layered oxide cathodes (intergranular cracking, stacking disorder); PBA cathode water release and vacancy evolution; hard carbon structural evolution toward graphitisation over extended cycling (altering OCV shape and $D_s$ values). All three require model development beyond what is available for LIBs.

**Key equations referenced from throughout the book:**

All key equations from earlier chapters apply. New or emphasised equations in this chapter:

$$D_s(c_s, T) = D_{s,0}(c_s) \cdot \exp(-E_{a,D}/RT) \quad \text{(concentration- and temperature-dependent } D_s \text{ for hard carbon)} \tag{13.4}$$

$$\frac{R_\text{ct}(T)}{R_\text{ct}(T_0)} = \exp\!\left[\frac{E_{a,\text{ct}}}{R}\left(\frac{1}{T} - \frac{1}{T_0}\right)\right] \quad \text{(Arrhenius resistance ratio)} \tag{13.5}$$

At $T = -20°\text{C}$ (253 K) relative to $T_0 = 25°\text{C}$ (298 K), this gives growth factors of $\approx 12\times$ for ether SIBs ($E_{a,\text{ct}} = 35$ kJ/mol) vs. $\approx 52\times$ for carbonate LIBs ($E_{a,\text{ct}} = 55$ kJ/mol).

$$\sigma_\text{SOC,plateau} = \frac{\sigma_V}{\left|\frac{dE_\text{OCV}}{d(\text{SOC})}\right|_\text{plateau}} \approx \frac{5 \; \text{mV}}{37 \; \text{mV}} \approx 13.5\% \quad \text{(SOC uncertainty in plateau region)} \tag{13.6}$$

**Key open research problems identified:**

DFN parameterisation for hard carbon; two-mechanism hard carbon model; hysteresis-augmented EKF for SIBs; O3→P3 phase transition degradation model; SIB calendar aging characterisation; physics-based SIB thermal runaway model.

---

## Deliverable

The primary deliverable for Chapter 13 in the context of your research preparation is a personal document we will call the **SIB Simulation Parameter Table** — a structured reference that you will maintain and update throughout your research career.

Create a table with the following structure. For each parameter in the DFN model (as defined in Newman's electrochemical systems framework or in PyBaMM's parameter set structure), record: the parameter name, its symbol, its LIB value (from literature, for a graphite/NMC reference), its SIB value (from literature, for a hard carbon/O3 cathode reference), the measurement technique used to extract it, the primary reference, and any notes about SOC or temperature dependence.

Begin with the following parameters, using published literature values (search for "SIB DFN parameters" and "hard carbon electrochemical characterisation" in Google Scholar):

Electrolyte conductivity $\kappa$ (mS/cm at 25°C), electrolyte diffusion coefficient $D_e$ (m²/s), transference number $t_+$, anode solid-state diffusion coefficient $D_{s,a}$ (m²/s at 50% SOC), cathode solid-state diffusion coefficient $D_{s,c}$, anode exchange current density $i_0$ (A/m²), cathode exchange current density $i_0$, anode OCV (curve: provide the qualitative description and reference source), cathode OCV (same), anode particle radius $r_{p,a}$ (µm), cathode particle radius $r_{p,c}$, anode porosity $\varepsilon_a$, cathode porosity $\varepsilon_c$, anode electrode thickness $L_a$ (µm), cathode electrode thickness $L_c$.

For any SIB parameter that you cannot find in the literature, note it explicitly as "not characterised" — this is your research gap map. The gaps in your table are the highest-priority experimental and computational needs for SIB simulation research.

Excellent starting points for SIB DFN parameters: Bhatt et al. (*Journal of Power Sources*, 2020) for hard carbon; Gonzalez-Robles et al. (*Advanced Energy Materials*, 2021) for NVPF cathodes; Kim et al. (*ACS Applied Materials and Interfaces*, 2022) for O3-type layered oxide cathodes. Note: as I cannot verify whether these specific citations are correct without database access, treat these as directional search terms rather than guaranteed sources, and verify each reference independently.

---

## Further Reading

1. **Deng, J. et al., "Interplay between Solid Electrolyte Interface (SEI) and Dendrite Formation on the Anode of Sodium Ion Batteries," *Advanced Energy Materials* 11 (6), 2003987 (2021).** The most comprehensive recent review of SEI formation on hard carbon in sodium electrolytes, covering both carbonate and ether electrolyte systems. Includes quantitative comparison of SEI composition, thickness, and ionic conductivity across electrolyte types.

2. **Bommier, C. and Ji, X., "Recent development on anodes for Na-ion batteries," *Israel Journal of Chemistry* 55 (5), 486–507 (2015).** A systematic review of hard carbon anode behaviour including the slope/plateau mechanism, the two-mechanism debate, GITT-derived diffusion coefficients, and rate capability data across multiple hard carbon types. The most thorough survey of the hard carbon electrochemistry that underlies Sections 13.2 and 13.3.

3. **Nayak, P. K. et al., "From lithium-ion to sodium-ion batteries: advantages, challenges and surprises," *Angewandte Chemie International Edition* 57 (1), 102–120 (2018).** A comprehensive comparison of LIB and SIB across all relevant dimensions — materials, performance, cost, and safety — written specifically to highlight what is different and why. Well-organised around the "what changes" theme of this chapter.

4. **Zhao, L. et al., "A Comprehensive Review on the Thermal Behavior of Lithium-ion Batteries and the Evaluation of Functional Safety," *Energy Storage Materials* 35, 313–333 (2021).** While focused primarily on LIBs, this review's framework for thermal characterisation (ARC methodology, onset temperature determination, heat generation separation) is the methodology directly applied to SIBs in the comparative studies referenced in Section 13.6. Reading this alongside the SIB ARC literature gives the methodological context for interpreting the safety comparison.

5. **Muñoz-Márquez, M. A. et al., "Na-Ion Batteries for Large Scale Stationary Energy Storage," *Advanced Energy Materials* 7 (20), 1700470 (2017).** A review that situates SIB technology in the context of grid-scale stationary storage deployment — the application where the balance of SIB properties (cost, safety, longevity) most clearly outweigh its energy density limitations. Useful for understanding the commercial endpoint toward which the SIB simulation research in Chapter 14 is directed.

*Note: As with all citations in this book, I cannot verify these references against a live database. Please confirm each title, volume, and page range independently before citing them in your own work.*

---

*Next chapter: **Chapter 14 — The SIB Research Landscape.** We survey the major research groups, the Chinese research ecosystem, the commercial landscape as it stands in 2025–2026, and — most importantly — the open problems that are addressable by EE-focused simulation researchers. Your reading of Chapter 13 is the foundation; Chapter 14 is the map of where to go. Prompt me with "write Chapter 14" to continue.*

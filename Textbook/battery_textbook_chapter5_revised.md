# Chapter 5: Lithium-Ion Chemistry Families

## Chapter Opening

If you have spent any time reading battery news — or even just following the electric vehicle industry — you have encountered a cascade of acronyms: LCO, LFP, NMC, NCA, LMO, LTO. Each refers to a different combination of electrode materials. Each represents a different set of trade-offs. Each dominates in a different application, and each is the right answer to a different question. Yet the abbreviations are thrown around casually, often without explanation, as if the reader is expected to already know why NMC won the EV market in 2018 while LFP is winning it back in 2024, or why LTO is used in fast-charging buses in China despite its dramatically lower energy density, or why LCO remains dominant in your phone despite being the oldest chemistry and the most expensive.

This chapter builds the framework for understanding all of those choices. We will examine each major lithium-ion chemistry in enough depth that you understand not just what the material does, but why it does it — what crystal structure governs its behaviour, what the thermodynamic driving forces are, where the performance limits come from, and what failure modes lurk at the edges of its operating window.

This chapter is also preparation for Chapter 6, where we will examine sodium-ion chemistries. Almost every SIB cathode concept is a deliberate echo of or departure from its lithium-ion predecessor: the O3 layered oxides of SIB are the descendants of LCO; the polyanionic NVPF cathode echoes LFP's structural philosophy; the choice of hard carbon over graphite for the SIB anode is a consequence of what we will learn here about why graphite works for lithium but not sodium. Chapter 5 is, in a sense, the reference frame against which Chapter 6 is measured.

By the end of this chapter, you will be able to name any major lithium-ion chemistry, state its cathode and anode materials and their crystal structures, give approximate values for its specific capacity, nominal voltage, energy density, power density, cycle life, safety characteristics, and cost, and explain which application it is optimised for and why. You will also understand the concept of the energy-power-safety-cost-life pentagon — the five-dimensional trade-off space within which every battery chemistry must operate, and within which no chemistry simultaneously occupies all five corners.

---

> **Prerequisites Check**
>
> From Chapters 1–4:
>
> - Half-reactions and standard electrode potentials (Chapter 1, Sections 1.2–1.4)
> - Crystal structure families for intercalation — layered, spinel, olivine, polyanionic (Chapter 2, Section 2.2)
> - The SEI and first-cycle efficiency (Chapter 2, Section 2.3; Chapter 3, Section 3.6)
> - Performance metrics: capacity, energy density, C-rate, cycle life, SOH (Chapter 3)
> - Electrode manufacturing and why porosity and particle size matter (Chapter 4, Section 4.2)
>
> If the layered/spinel/olivine crystal structure discussion from Chapter 2 is not fresh in your mind, review Section 2.2 before proceeding. The structure-property connections in this chapter build directly on it.

---

## 5.1 The Five-Dimensional Trade-Off Space

Before examining individual chemistries, we need a conceptual framework for comparing them. Battery chemistries do not compete on a single axis — the "best" chemistry depends entirely on what the application demands. An attempt to find a single "winner" misses the point. What we need is a multi-dimensional trade-off framework.

This is a situation you already know from EE. When you specify an op-amp, you do not ask "which is the best op-amp?" You look at gain-bandwidth product, slew rate, input noise, offset voltage, supply current, and cost; you pick the one whose shape in that six-dimensional space matches your circuit. When you pick a control loop, you trade bandwidth against stability margin against noise rejection. The underlying reason for the trade-offs in both cases is the same: improving one figure of merit usually requires a physical change that degrades another. In op-amps, a wider bandwidth pushes you toward smaller compensation capacitors, which hurt stability. In batteries, a higher energy density pushes you toward more reactive materials, which hurt safety. The trade-offs are not historical accidents — they are baked into the physics, and every chemistry in this chapter is a different point on the Pareto front.

The five properties that define a chemistry's application suitability are energy density, power density, safety, cycle life, and cost. Each deserves a careful definition before we start comparing chemistries against them.

**Energy density** is how much energy can be stored per kilogram (gravimetric) or per litre (volumetric). This governs driving range in an EV, runtime in a phone, and weight in an aircraft. Higher is better, but the gains come at the cost of other dimensions — the materials that store the most energy per gram are also the most reactive, the most expensive, or the most difficult to cycle.

**Power density**, by contrast, is how quickly energy can be delivered or accepted. This governs acceleration in an EV, the ability to absorb regenerative braking, charge rate, and cold-weather performance. Higher power density demands both fast kinetics (small activation barriers, short diffusion paths) and favourable electrode geometry (thin coatings, more current collector per gram of active material). The power requirement therefore pushes electrode design in the opposite direction from the energy requirement: thin coats with more inert mass give better power but worse energy density, and the two objectives cannot both be maximised in a single cell design — as we saw in Chapter 4.

**Safety** is the resistance of the cell to thermal runaway under abuse conditions: overcharge, short circuit, mechanical penetration, external heating. It is determined primarily by the thermodynamic stability of the charged cathode and the nature of the electrolyte decomposition reactions. Safer chemistries typically have lower energy density, because the materials that store the most energy are also the most oxidising in their delithiated state, and the most likely to release oxygen when heated.

**Cycle life**, the number of charge–discharge cycles to end-of-life (conventionally defined as 80% capacity retention — a historical convention from early EV battery warranties, reinforced by the observation that cells degrade increasingly non-linearly below this threshold and become disproportionately less useful than the capacity number alone suggests), governs total cost of ownership and suitability for applications like grid storage where a cell must cycle five to ten thousand times. Long cycle life requires mechanically stable electrodes (small volume changes during cycling), chemically stable electrolyte interfaces, and a thermodynamically well-matched electrode pair.

Finally, **cost** is the raw material cost of the active materials, dominated by the cathode in most chemistries. This is where the choice of transition metals matters most: cobalt is expensive and geopolitically concentrated; nickel is moderately expensive; manganese and iron are cheap and abundant. The sodium-ion pitch, as we will see in Chapter 6, is largely a cost argument built on exactly this observation.

No chemistry simultaneously maximises all five dimensions. Every chemistry is a compromise, and the interesting engineering question is always: given the requirements of this specific application, which compromise is best?

A useful mental model is a **pentagon diagram** (sometimes called a Ragone-extended performance spider chart) where each of the five properties is a vertex and each chemistry is drawn as a closed polygon whose distance from the centre along each axis encodes how well it scores on that property, normalised so that 1.0 is "excellent" and 0.0 is "poor." You will see versions of this diagram in almost every battery review paper.

Concretely, imagine five axes radiating from a central origin at 72° intervals, labelled (clockwise from the top): Energy density, Power density, Safety, Cycle life, Cost (where "cost" is scored so that *low cost* is toward the outside — i.e., the axis is really "affordability"). Each chemistry is plotted by placing a dot on each axis at the appropriate score and connecting the five dots into a polygon. For LFP/graphite, the polygon is *large* along Safety, Cycle life, and Affordability (all pushed to the outside), and *small* along Energy density and Power density (pulled toward the centre) — a lopsided pentagon leaning toward the "cost-life-safety" half of the diagram. For NMC811/graphite, the polygon is *large* along Energy density and Power density but *small* along Safety and Cycle life, with Affordability in the middle — a nearly mirror-image lopsided pentagon.

```text
                  Energy
                     .
                   .   .
       Affordab. .       . Power
                .         .
                 .       .
                  . . . .
         Cycle Life    Safety
```

Sketch this for yourself after you finish the chapter. The exercise of placing each chemistry on this diagram, from memory, will force you to consolidate the five-dimensional picture in a way that passive reading does not. The reason these diagrams are ubiquitous in review papers is that they compress a table's worth of numbers into a visual gestalt that you can compare at a glance — exactly what you need when you are deciding whether a new chemistry is worth reading about.

---

## 5.2 LCO: Lithium Cobalt Oxide — The Original Chemistry

### History and Structure

**Lithium cobalt oxide (LCO)**, chemical formula LiCoO₂, is where the modern lithium-ion battery story begins. John Goodenough's group at Oxford demonstrated its use as a lithium-ion cathode in 1980; Rachid Yazami and Philippe Touzain showed that graphite could reversibly intercalate lithium in 1980–1983; and Akira Yoshino at Asahi Kasei assembled the first practical lithium-ion cell (petroleum-coke anode / LCO cathode) in 1985. Graphite did not replace coke as the standard anode until the early 1990s, once ethylene carbonate electrolytes were introduced that allowed a stable SEI to form on graphite without exfoliating it — a detail we will revisit when we discuss electrolyte selection. Sony commercialised this chemistry in 1991, and it powered virtually every portable electronic device for the following two decades. Goodenough, Whittingham, and Yoshino shared the Nobel Prize in Chemistry in 2019 for this work.

LCO has the **layered O3 crystal structure** (α-NaFeO₂ structure type) described in Chapter 2: alternating layers of CoO₂ sheets and Li layers stacked in a rhombohedral unit cell (space group $R\bar{3}m$). The cobalt is in octahedral coordination, as is the lithium. The lithium occupies the interstitial space between the CoO₂ layers and diffuses freely *within* those layers but not *across* them — what physicists call two-dimensional (or "quasi-2D") diffusion.

Here is the intuition. Imagine Li ions as charges hopping between sites on a grid. In LCO, the grid is flat: a Li ion can hop north, south, east, or west within its layer with roughly equal ease, but cannot hop "up" or "down" to the next layer because the CoO₂ sheets in between form a kinetic wall. So transport is effectively 2D. In LFP, which we will meet next, the geometry is opposite — transport is effectively 1D, confined to parallel tunnels through the olivine lattice. And in spinel LMO and LTO, transport is 3D, with the ion free to hop in any direction. The dimensionality of the diffusion pathway matters enormously for rate capability: 3D > 2D > 1D in general, because 3D geometries have more parallel paths for current to take and are more tolerant of blockages. Think of it as the difference between a city with a full grid of streets (3D spinel), a city with avenues only (2D layered, limited turns), and a city with a single one-way expressway you cannot exit (1D olivine). An accident on the expressway is catastrophic; the grid routes around it trivially.

### Electrochemistry

The half-reaction at the LCO cathode during discharge is:

$$\text{Li}_{1-x}\text{CoO}_2 + x\,\text{Li}^+ + x\,e^- \longrightarrow \text{LiCoO}_2 \tag{5.1}$$

where the potential ranges from approximately 3.7 V (near full lithiation, $x \to 0$) to 4.2 V (at the practical delithiation cutoff of $x \approx 0.5$), both measured vs. Li/Li⁺.

The theoretical specific capacity follows from Faraday's first law:

$$C_\text{th} = \frac{nF}{3.6\,M}$$

where $n$ is the number of electrons transferred per formula unit, $F = 96485$ C/mol is the Faraday constant, $M$ is the molar mass in g/mol, and the factor of 3.6 converts coulombs to milliamp-hours ($1~\text{mAh} = 3.6~\text{C}$). For LCO with $n = 1$ and $M = 97.87$ g/mol, this gives $C_\text{th} = 96485 / (3.6 \times 97.87) = 274$ mAh/g, as we calculated in Chapter 1.

However — and this is the central limitation of LCO — only about half of this theoretical capacity is practically accessible. Extracting more than approximately $x = 0.5$ from Li$_{1-x}$CoO₂ causes two problems. First, above $x \approx 0.5$, the CoO₂ layers undergo phase transitions involving changes in stacking sequence (from the O3 to the O1 structure and intermediate phases), which are partially irreversible and cause structural degradation over cycling. Second, at high states of delithiation, cobalt is progressively oxidised toward Co⁴⁺ (at $x \approx 0.5$ roughly half the cobalt is Co⁴⁺; full delithiation to $x = 1$ would correspond to a formal CoO₂ composition with all cobalt at +4). Highly delithiated Li$_{1-x}$CoO₂ is structurally unstable: the oxygen sublattice loses its grip on the Co⁴⁺ ions, and above a threshold temperature the lattice releases oxygen, which then oxidises the organic electrolyte in a strongly exothermic reaction. This oxygen-release step is the thermodynamic trigger for thermal runaway in LCO — not a direct cathode-electrolyte reaction, but oxygen liberated from the cathode feeding the combustion of the electrolyte it is in contact with.

The practical specific capacity of LCO is therefore approximately **140–160 mAh/g**, corresponding to $x \leq 0.5$. Cell-level specific energy for LCO/graphite 18650 cells is approximately 200–260 Wh/kg.

### LCO Performance Profile

LCO has a moderately sloped OCV curve (good for SOC estimation), good rate capability (the 2D Li diffusion in the CoO₂ plane is facile), moderate cycle life (500–1000 cycles under careful voltage management), and excellent volumetric energy density (>700 Wh/L for 18650 cells) due to the high density of LCO (5.06 g/cm³) and the reasonably high practical capacity.

Its Achilles heel is **safety**. Fully delithiated (or near-fully delithiated) LCO is thermodynamically unstable: the Co³⁺/Co⁴⁺ redox couple makes the delithiated cathode a strong oxidiser, and if the temperature rises due to any cause, the cathode can begin to decompose exothermically, releasing oxygen that reacts with the organic electrolyte in a cascade. The onset temperature for oxygen release from delithiated LCO is approximately 150–180°C — dangerous territory that can be reached during internal short circuits or overcharge. This is why LCO cells require sophisticated BMS protection circuits.

The second weakness is **cost**: cobalt is expensive (~$30–50/kg as of this writing, with large price fluctuations), geographically concentrated (the Democratic Republic of Congo supplies over 70% of world production), and subject to supply security concerns. LCO uses approximately 0.6 g of cobalt per watt-hour of cell energy — one of the highest cobalt intensities of any cathode chemistry.

### Application Domain

LCO dominates **consumer electronics** (smartphones, laptops, tablets, cameras) where the priorities are maximum volumetric energy density (thin devices) and a cycle life *just* adequate for the product lifetime. Consider a phone over two years: if the user charges roughly every 1.5 days, that is ~490 cycles. Add a safety margin and you need a cell good for 500–800 cycles to 80% retention — which LCO, used conservatively, can provide. A vehicle battery that needs 1500+ cycles would be a terrible fit for LCO, but a pocket device that is expected to be obsolete after two years is a near-ideal match. LCO is poorly suited to EVs (cost, safety at scale, cycle life) and completely unsuited to stationary storage (cost per Wh is too high).

A note on the asymmetry of this chapter: we will spend most of our time on cathode chemistries and much less on anode chemistries. This is not an oversight. In Li-ion, cathode choice is the dominant lever on cell voltage, specific energy, safety, and cost, while the anode side is effectively solved — graphite works, has worked since the early 1990s, and is used in >95% of commercial cells. The exceptions (LTO, silicon additives, and eventual lithium metal) are genuine but niche, and we will cover them in §5.7 and §5.8. For now, read the cathode sections as doing most of the work, and assume graphite on the anode side unless otherwise stated.

---

## 5.3 LFP: Lithium Iron Phosphate — The Safe Workhorse

### Structure and the Inductive Effect

**Lithium iron phosphate (LFP)**, chemical formula LiFePO₄, occupies the diametrically opposite position from LCO in the trade-off space: it sacrifices energy density and volumetric compactness to achieve extraordinary safety, cycle life, and low cost. Goodenough's group at UT Austin reported it as a cathode material in 1997, and while its commercialisation was initially hampered by poor electronic conductivity (requiring carbon coating and nanostructuring), it is now one of the largest-volume battery chemistries in the world.

LFP has the **olivine crystal structure**: iron atoms sit in octahedral FeO₆ sites, phosphate groups $(\text{PO}_4)^{3-}$ occupy tetrahedral sites and form a rigid covalent backbone, and lithium occupies octahedral LiO₆ sites arranged along one-dimensional channels that run parallel to the *b*-axis of the orthorhombic unit cell (space group $Pnma$). Picture the structure as a stack of rigid phosphate-iron sheets with parallel tunnels drilled through them in one direction only — Li ions move along these tunnels like cars on a single-lane one-way road. This is a dramatic contrast to LCO's quasi-2D diffusion (a grid of avenues with no turns) and to spinel's 3D diffusion (a full city grid). The one-way-tunnel geometry has two important consequences we will return to. First, the rate capability at the particle level is intrinsically limited, which is why LFP must be synthesised as small, carbon-coated nanoparticles to compensate. Second, any point defect that blocks a tunnel — most commonly an "anti-site" defect where an Fe ion ends up in a Li site — stops Li transport along that entire tunnel, because there is no way for the Li ions behind the blockage to go around it. LFP is therefore more sensitive to synthetic purity than layered or spinel cathodes, and the literature pays close attention to the anti-site defect concentration as a quality metric.

The voltage of LFP is tuned by the **inductive effect** mentioned in Chapter 2: the phosphate anion $(\text{PO}_4)^{3-}$ is strongly electron-withdrawing, pulling electron density away from the iron ion. This raises the energy of the Fe³⁺/Fe²⁺ redox couple from ~1.0 V vs. SHE in simple iron oxides to ~3.45 V vs. Li/Li⁺ — a useful cathode potential. The stronger the inductive effect of the polyanion, the higher the voltage; fluorinated polyanions (as in LiVPO₄F) raise this further, and more weakly withdrawing anions (silicates, borates) produce lower voltages. The inductive effect is a beautifully general concept that battery materials scientists use to rationally design cathode voltages.

### Electrochemistry: The Two-Phase Reaction

The LFP cathode undergoes a **two-phase reaction** during cycling. Rather than a continuous solid-solution of varying lithium content, LFP exists in two discrete phases: lithium-rich LiFePO₄ (fully lithiated, Fe²⁺) and lithium-poor FePO₄ (fully delithiated, Fe³⁺). As the cell charges, the LiFePO₄ phase is converted to FePO₄; as it discharges, the reverse occurs. The two phases coexist throughout most of the charge or discharge.

$$\text{LiFePO}_4 \rightleftharpoons \text{FePO}_4 + \text{Li}^+ + e^- \tag{5.2}$$

with $E^\circ \approx +3.45$ V vs. Li/Li⁺ for this half-reaction.

As we established in Chapter 1 and reinforced in Chapter 3, a two-phase reaction gives a flat voltage plateau. It is worth revisiting the reason explicitly, because it matters again in a moment.

The electrode potential is set by the Nernst equation:

$$E = E^\circ - \frac{RT}{nF}\ln\frac{a_\text{reduced}}{a_\text{oxidised}},$$

where the activities are of the species at the electrode. For a solid-solution cathode like NMC, the activity of lithium in the host changes continuously as you change the state of charge: pull out a few more Li ions, and the remaining Li has a different chemical environment, a different activity, and therefore a different potential. That is why NMC's OCV curve slopes continuously.

For a two-phase cathode like LFP, something different happens. As long as both LiFePO₄ and FePO₄ phases are present, the *composition* of each phase is fixed — one is stoichiometric LiFePO₄, the other is stoichiometric FePO₄. Removing more Li from the cell just converts more LiFePO₄ to FePO₄ without changing the composition of either phase. So the activity of Li in the LiFePO₄ phase is constant (it is a thermodynamic property of the pure phase), the argument of the logarithm in the Nernst equation is constant, and the potential is constant too. The whole cell voltage sits on a plateau at ~3.45 V throughout the transition — roughly 90–95% of LFP's capacity. Only at the very ends, where one of the two phases disappears, does the voltage curve acquire a slope.

If you find this argument slippery on first reading, here is the EE version: a two-phase reaction is to a solid-solution reaction what a Zener diode is to a resistor. The Zener holds a nearly constant voltage across a wide range of currents because physics pins its voltage; the resistor shows a continuous V(I) relationship. LFP is the Zener of battery cathodes.

The practical consequence of the two-phase mechanism for SOC estimation bears repeating here: **a flat OCV curve is the enemy of voltage-based SOC estimation**. A 10 mV voltage measurement error anywhere in the LFP plateau region corresponds to a SOC uncertainty of 15–25% — essentially useless. BMS algorithms for LFP must rely primarily on coulomb counting, with periodic recalibration at the tails (near 0% or 100% SOC where the curve has some slope). This is not a minor implementation detail; it is a fundamental limitation that shapes the entire BMS architecture for LFP systems.

**A common misconception — the flat plateau is about OCV, not V(t).** Students new to LFP often assume that the flat voltage plateau means an LFP cell under load also holds its terminal voltage constant. It does not. Under any non-zero current, the terminal voltage is displaced from the OCV by ohmic and polarisation overpotentials, both of which are SOC-dependent (especially at the ends of the plateau and at extreme DOD). So the terminal-voltage curve of a loaded LFP cell is *not* flat — it has a clear SOC dependence through the IR drop. The flat part is the open-circuit voltage, measured at rest. What this means in practice is that you can sometimes squeeze a little SOC information out of an LFP cell during dynamic operation by observing how the terminal voltage responds to current pulses, even though the OCV-based lookup is useless. Chapter 10 will make this precise when we discuss model-based SOC estimation.

The theoretical specific capacity of LFP follows from Faraday's first law with $n = 1$ and $M_\text{LFP} = 157.76$ g/mol: $C_\text{th} = 96485/(3.6 \times 157.76) = 169.9$ mAh/g. The practical capacity is close to this theoretical value — approximately **155–170 mAh/g** — because LFP can be nearly fully cycled without structural degradation, unlike LCO which can only use half its theoretical range.

### The Electronic Conductivity Problem and Carbon Coating

Early attempts to use LFP as a cathode failed because its intrinsic electronic conductivity is extremely low — about $10^{-9}$ S/cm, compared to roughly $10^{-4}$ S/cm for LCO and $10^{-3}$ S/cm for NMC. To see what this means physically, imagine an electron trying to reach an iron centre 100 nm deep inside an uncoated LFP particle. Using $R = \rho L / A$ with $\rho = 10^9$ Ω·cm, a path length of $10^{-5}$ cm, and a particle cross-section of $10^{-10}$ cm², the resistance of that single path is on the order of $10^{24}$ Ω — absurdly high. Scaled across all the iron centres in an electrode carrying realistic current, the electronic-transport overpotential alone would dominate everything else in the cell. The electrons needed for the Fe²⁺ ↔ Fe³⁺ redox reaction cannot reach or leave the iron centres fast enough, and the cell cannot deliver useful current at any rate.

The solution, developed by Ravet, Armand and colleagues in the early 2000s, was **carbon coating**: a thin (1–3 nm) layer of conductive carbon is deposited on each LFP nanoparticle surface during synthesis. The coating provides a high-conductivity shell through which electrons can reach the LFP surface, and the final leg of electron transport into the iron centre is short enough that the low intrinsic conductivity no longer dominates. Combined with reducing the particle size to 100–200 nm — which shortens both the solid-state Li diffusion path and the distance electrons must travel through the insulating core — carbon-coated nano-LFP has acceptable rate capability for most applications. This is why LFP in the literature is always "C-LFP" or "carbon-coated LFP," and why the specific capacity reported for LFP electrodes implicitly includes the 2–5% carbon coating mass.

### Safety: Why LFP Is Uniquely Stable

The safety advantage of LFP relative to LCO and NMC is not merely quantitative — it is qualitative. The LFP crystal structure is thermodynamically stable up to very high temperatures even when fully delithiated: the fully delithiated FePO₄ phase does not release oxygen until temperatures above approximately 400–450°C. Compare this to delithiated LCO (oxygen release at ~150–180°C) or delithiated NMC811 (oxygen release at ~180–200°C). The phosphate framework physically locks up the oxygen in strong covalent P-O bonds that are thermodynamically more stable than the oxide framework in layered materials.

This means that even if an LFP cell is short-circuited, overcharged, or subjected to external heating, it is extremely difficult to trigger the exothermic electrolyte-combustion cascade that constitutes thermal runaway. LFP cells can pass nail penetration tests that destroy LCO and NMC cells. This is why LFP is used without thermal runaway propagation concerns in applications like bus fleets, e-bikes, and grid storage systems where large numbers of cells are packed in proximity and where thermal event management is difficult. It is also why BYD, one of the world's largest EV manufacturers, has adopted LFP for the majority of its passenger vehicle battery packs despite the energy density penalty.

The same structural rigidity that makes LFP thermally safe also contributes to its exceptional cycle life: the volume change between LiFePO₄ and FePO₄ is a modest ~6.8%, small enough that the particles do not fracture appreciably under cycling, and the two-phase mechanism means the interior of a particle experiences a sharp phase boundary rather than a continuous concentration gradient — which, counterintuitively, reduces the mechanical stresses that drive crack formation. We will return to particle cracking as a degradation mechanism in Chapter 7.

### LFP Performance Profile

LFP summary: nominal voltage 3.2–3.35 V; practical specific capacity 155–170 mAh/g; cell-level specific energy 150–200 Wh/kg; cycle life >3,000 cycles (often >5,000 at partial DOD); excellent safety; low cost (iron and phosphorus are among the cheapest battery materials); poor volumetric energy density (LFP's density is 3.6 g/cm³, lower than LCO's 5.06 g/cm³, and the lower voltage also contributes); SOC estimation challenge from flat OCV.

Application: **grid energy storage, e-bikes, electric buses, mass-market EVs (particularly in China), power tools, backup power**. Applications where cycle life, safety, and cost matter more than energy density per kilogram or litre.

---

## 5.4 NMC: The Dominant EV Chemistry

### The Nickel-Manganese-Cobalt Family

**NMC** — **lithium nickel manganese cobalt oxide**, general formula Li(Ni$_x$Mn$_y$Co$_z$)O₂ where $x + y + z = 1$ — is not a single material but an entire family of materials sharing the layered O3 structure of LCO but with three transition metals sharing the octahedral sites in the cobalt layers. The three metals serve distinct electrochemical roles: nickel is the primary redox-active species (Ni²⁺/Ni⁴⁺ couple provides most of the capacity); cobalt improves electronic conductivity and helps maintain structural order during cycling; manganese (electrochemically inactive at these potentials, remaining as Mn⁴⁺) acts as a structural stabiliser, improving thermal stability relative to pure nickel or cobalt oxides.

**A common misconception — NMC is a solid solution, not a mixture.** It is tempting to read "NMC = nickel + manganese + cobalt" as meaning an NMC cathode is a physical blend of LiNiO₂, LiMnO₂, and LiCoO₂ particles. It is not. NMC is a single-phase material with a single crystal lattice in which the three transition metals share the octahedral sites of the CoO₂-like layer, distributed essentially randomly (with some short-range ordering in certain compositions). When you pick up a grain of NMC622 and look at it with a microscope, you do not see separate Ni, Mn, and Co domains — you see one material whose individual octahedral sites happen to be occupied by one of three metals. This is why substituting Ni for Co does not just change the average properties like you would get from a blend; it changes the local electronic structure at every site in the lattice. The same distinction applies to NCA, and it will apply to the layered Na(Ni,Fe,Mn,Co)O₂ cathodes of Chapter 6.

The family is labelled by the molar ratios of Ni:Mn:Co, and the variants form a rough historical sequence that tracks the steady push toward higher nickel. The earliest widely commercialised member, **NMC111**, has equal parts of all three metals (Li(Ni₀.₃₃Mn₀.₃₃Co₀.₃₃)O₂) and delivers a moderate specific capacity of around 160 mAh/g with excellent thermal stability, good cycle life, and moderate cost; it remains in use for power tools and early-generation EVs. **NMC532** (Ni:Mn:Co = 5:3:2) pushes the nickel fraction up and reaches 175–180 mAh/g, at the price of slightly reduced thermal stability and somewhat more demanding synthesis. **NMC622** (6:2:2) reaches 190–200 mAh/g and was dominant in premium EVs roughly from 2018 to 2022, a period when European and American automakers were scaling their first high-volume BEV platforms. **NMC811** (8:1:1), the current state-of-the-art at 200–220 mAh/g, continues the trend: more nickel means more capacity and less cobalt (and therefore lower cost and reduced supply-chain risk), but at the price of significantly lower thermal stability, faster cycle-life decay, and synthesis conditions so tight that only a handful of manufacturers can produce it reliably at scale. Beyond NMC811, research-frontier chemistries with nickel content above 90% — collectively called **NMC90+** or sometimes Ni-rich NMC — are approaching pure LiNiO₂ in both composition and behaviour, and running into the same structural limitations that kept pure LiNiO₂ out of commercial cells in the first place.

A useful exercise is to work out where these numbers come from. The theoretical specific capacity of an NMC variant depends on its molar mass and on how many electrons per formula unit it can deliver. For Li(Ni$_{0.8}$Mn$_{0.1}$Co$_{0.1}$)O$_2$ (NMC811), the molar mass is

$$M = 6.94 + 0.8(58.69) + 0.1(54.94) + 0.1(58.93) + 2(16.00) = 96.27 \text{ g/mol}.$$

If we could extract all of the lithium (x = 1, so n = 1 electron per formula unit), the theoretical specific capacity would be

$$C_\text{th} = \frac{nF}{3.6\,M} = \frac{96485}{3.6 \times 96.27} = 278 \text{ mAh/g}.$$

The practical capacity of NMC811, approximately 200–220 mAh/g, corresponds to extracting roughly 72–79% of the lithium inventory before you hit the upper voltage limit beyond which thermal stability collapses. NMC111 is computed the same way (M ≈ 96.5 g/mol, since the three transition metals have similar atomic mass), giving nearly the same theoretical capacity of ~278 mAh/g — but NMC111 can only safely access about 58% of it (~160 mAh/g). So the difference in practical capacity between NMC111 and NMC811 is *not* a theoretical-capacity difference (they are nearly identical); it is a difference in how much of the capacity can be safely used before the cathode becomes thermally unstable. This is a subtle but important point: the nickel dilemma is fundamentally about the *usable fraction of a nearly-constant theoretical capacity*, and it is why the cycle-life–capacity trade-off across the NMC family is so sharp.

### The Nickel Dilemma

The trend toward higher nickel is driven by two simultaneous motivations: higher capacity (each additional Ni replacing Mn or Co adds redox activity) and lower cobalt content (lower cost, lower supply-chain risk). But nickel brings its own problems, and the "nickel dilemma" is one of the central tensions in current LIB cathode research.

At high nickel content, several degradation mechanisms become more severe. The **Ni²⁺/Li⁺ cation mixing** problem: nickel(II) and lithium(I) ions have nearly identical ionic radii (Shannon six-coordinate radii of 0.69 Å for Ni²⁺ and 0.76 Å for Li⁺). When two cations have similar radii, they can occupy each other's sites without distorting the surrounding oxygen framework, which means the energy penalty for swapping them is small — and at the high temperatures of synthesis, thermal fluctuations are enough to make the exchange happen. Once Ni²⁺ lodges in a lithium site between the CoO₂ layers, it blocks the quasi-2D diffusion path for Li⁺ through that region, reducing practical capacity and increasing impedance. High-nickel NMC therefore requires very precise synthesis conditions (controlled atmosphere, precise temperature, rapid cooling) to minimise cation mixing, and characterisation papers universally report a "cation mixing fraction" (typically 1–5%) as a quality metric for Ni-rich cathodes.

The **surface reconstruction** problem: during cycling, the surface of high-nickel NMC particles undergoes a phase transition from the layered structure to a rock-salt structure (NiO-type), a thin layer that has low lithium diffusivity and higher resistance. This reconstruction layer grows with cycling, increasing impedance. It is analogous to the SEI in some ways — a passivation layer that grows progressively.

The **thermal stability** problem: delithiated high-nickel NMC is a powerful oxidiser. The oxygen release temperature for NMC811 is approximately 180–200°C, significantly lower than for NMC111 (~260°C). For this reason, NMC811 cells require more sophisticated thermal management and BMS overvoltage protection than lower-nickel variants. High-profile recalls involving high-nickel NMC cells — the Hyundai Kona EV and Chevrolet Bolt recalls of 2020–2021, both involving LG-manufactured Ni-rich cells (characterised in the literature as NMC622-class, not NMC811 as sometimes reported) — triggered an industry-wide re-examination of high-nickel cathode safety practices, even though the immediate root cause in both cases was traced to manufacturing defects (folded anode tabs and separator damage) rather than the chemistry itself. The episode is still instructive: high-nickel cells are less forgiving of manufacturing imperfections precisely because their thermal runaway onset is closer to achievable in-pack temperatures.

### The Anode Side: Graphite with NMC

NMC cathodes are almost universally paired with **graphite anodes** (or, in premium cells, graphite with a small percentage of silicon added). The graphite anode has the **staged intercalation** chemistry described in Chapter 2 — a sequence of discrete, ordered arrangements of Li between the graphene layers, labelled by the integer "stage number" $n$, where stage-$n$ means one Li-filled gallery between every $n$ adjacent empty galleries. The fully lithiated stage-1 compound (LiC₆) has every gallery filled; stage-2 (LiC₁₂) has every other gallery filled; higher stages have progressively sparser Li layers. Each stage-to-stage transition is a genuine phase transformation that produces a flat plateau in the graphite OCV curve, and these plateaus are what create the sharp peaks in a dQ/dV measurement that we will read later in the chapter. The combined NMC/graphite full cell OCV curve is moderately sloped across the full SOC range — dominated by the NMC cathode shape, which slopes continuously. This makes voltage-based SOC estimation more tractable than for LFP/graphite cells.

Graphite has a theoretical specific capacity of 372 mAh/g, computed as follows. In the fully lithiated stage-1 compound LiC₆, one Li⁺ is stored per six carbon atoms. Because the specific capacity is reported per gram of *carbon* (the active material), the relevant molar mass is $M = 6 \times 12.01 = 72.06$ g/mol, not the formula-unit mass of LiC₆. With $n = 1$ electron per Li inserted,

$$C_\text{th} = \frac{nF}{3.6\,M} = \frac{96485}{3.6 \times 72.06} = 372 \text{ mAh/g}.$$

Graphite achieves a practical capacity of approximately 350–365 mAh/g — remarkably close to theoretical, because graphite can be nearly fully lithiated to LiC₆ without side reactions — and a nominal potential of roughly 0.1–0.2 V vs. Li/Li⁺ on average.

### Silicon Addition

Adding silicon to the graphite anode — typically 5–10% by weight, or up to 50% in advanced cells — increases anode specific capacity significantly. Silicon's theoretical specific capacity for the Li₁₅Si₄ phase is 3579 mAh/g, roughly 10× graphite. Even a 5% silicon addition can increase the anode specific capacity from ~360 to ~450 mAh/g, enabling a meaningful cell-level energy density increase.

The catch, as noted in Chapter 2, is the ~300% volume expansion of silicon during full lithiation. This volume change causes particle fracturing, repeated SEI formation on newly exposed surfaces, progressive capacity fade, and electrical isolation of cracked particles. The engineering challenge is to design silicon-containing composite anodes (silicon nanoparticles, silicon-carbon composites, silicon dispersed in graphite matrix) that accommodate the volume change without fracturing. This is an intensely active research area. Current state-of-the-art silicon-graphite anodes in commercial cells (e.g., Tesla 4680 with ~5% silicon) achieve 400–500+ mAh/g effective capacity at the cost of somewhat higher first-cycle irreversibility and somewhat faster capacity fade relative to pure graphite.

### NMC Performance Profile

NMC/graphite summary: nominal voltage 3.6–3.7 V; practical specific capacity 160–220 mAh/g (cathode-limited); cell-level specific energy 200–280 Wh/kg depending on variant; cycle life 500–2000 cycles depending on nickel content, DOD, and temperature; safety good to moderate (decreasing with increasing Ni content); cost moderate (decreasing as cobalt content drops with higher-Ni variants).

Application: **premium EVs, high-energy consumer electronics, energy storage where volumetric density matters**. NMC622 and NMC811 are the standard chemistries for European and American EV platforms; NMC111 and NMC532 remain in power tools and lower-tier EVs.

---

## 5.5 NCA: The High-Energy Variant

**NCA** — **lithium nickel cobalt aluminium oxide**, formula Li(Ni$_x$Co$_y$Al$_z$)O₂, typically Li(Ni$_{0.8}$Co$_{0.15}$Al$_{0.05}$)O₂ — has its origins in work on Ni-rich layered oxides in Japan in the 1990s (notably Ohzuku and Makimura on related LiNiO₂ derivatives) and was commercialised by SAFT and then by Panasonic/Matsushita. It is most visible today in the Panasonic 18650 and 2170 cells used in Tesla vehicles from 2012 onward.

The crystal structure is identical to LCO and NMC: layered O3, $R\bar{3}m$ space group. The role of aluminium in NCA is analogous to the role of manganese in NMC: it stabilises the structure and improves thermal characteristics without contributing significantly to capacity (Al³⁺ is electrochemically inactive in this voltage window).

The question a non-chemist will want to ask at this point is: if aluminium doesn't participate in the redox reaction, what is it actually *doing*? The answer is structural. Delithiated Ni-rich layered oxides have a tendency to release oxygen because the Ni⁴⁺–O bond becomes weakly destabilised at high delithiation and the oxygen sublattice can collapse into a rock-salt arrangement (the surface reconstruction we discussed above). Embedding electrochemically inactive Al³⁺ into the transition-metal layer pins the lattice: Al–O bonds are stronger and more covalent than Ni–O bonds, so the inactive Al sites act as rebar in the concrete, holding the layered structure together even when the Ni around them is being oxidised and reduced. You pay for this stability with a small capacity reduction (the Al sites cannot store charge) but gain thermal runaway onset temperatures 20–40°C higher than the un-substituted material. Mn⁴⁺ in NMC plays the same structural-rebar role, though through a slightly different mechanism.

NCA has a practical specific capacity of **190–220 mAh/g**, very close to NMC811, and a nominal voltage of ~3.6 V. At the cell level, the Panasonic 21700 NCA cell achieves about 260–300 Wh/kg — among the highest for commercial cells. The synthesis of NCA is demanding: the material is moisture-sensitive (Al is reactive), requires inert-atmosphere handling, and the Ni-rich composition faces all the same cation mixing and surface reconstruction issues as high-nickel NMC. NCA is perhaps even more mature as a commercial chemistry than NMC811 (Panasonic has made NCA cells for Tesla since 2012), and the two are genuine competitors for the high-energy-density automotive application.

A notable difference from NMC: NCA does not contain manganese, which eliminates one degradation mechanism — manganese dissolution and cross-contamination — but also removes one of NMC's structural stabilisers.

Application: **high-energy-density EVs and premium consumer electronics.** NCA is less widespread than NMC811 simply because its synthesis requirements are more demanding and fewer manufacturers have mastered it. Outside of Tesla's supply chain (Panasonic, later CATL), NCA cells are less commonly encountered.

---

## 5.6 LMO: Lithium Manganese Oxide — The Spinel

**LMO** — **lithium manganese oxide**, formula LiMn₂O₄ — was one of the earliest alternative cathode materials explored for lithium-ion batteries. Unlike LCO, NMC, and NCA with their layered structures, LMO has the **spinel** crystal structure: manganese ions occupy octahedral 16d sites in a cubic close-packed oxygen framework, with lithium occupying tetrahedral 8a sites. The 8a tetrahedral sites are connected through vacant 16c octahedral sites to form a three-dimensional network of equivalent diffusion pathways — in effect, a full grid in all three spatial directions, to return to the street-network analogy. Compared to LCO's 2D planes and LFP's 1D tunnels, a 3D network has many more parallel paths for lithium to take, and a blockage anywhere can be routed around. This structural choice is why LMO has intrinsically excellent rate capability (it can deliver and accept very high currents) and why it is immune to the anti-site-defect sensitivity that plagues LFP: no single defect can isolate a region of the crystal.

The theoretical specific capacity follows from Faraday's first law with $n = 1$ and $M_\text{LMO} = 180.81$ g/mol: $C_\text{th} = 96485/(3.6 \times 180.81) = 148.3$ mAh/g. Practical specific capacity is lower at **100–120 mAh/g**, reflecting the difficulty of fully cycling LMO without structural degradation. The nominal voltage is approximately 4.0 V vs. Li/Li⁺ — higher than LCO's 3.7 V, which is thermodynamically attractive.

LMO's safety profile is excellent: manganese oxides are thermally stable to high temperature, there is no cobalt dissolution, and the three-dimensional structure is robust. The cost is very low — manganese is among the cheapest transition metals.

The problem with LMO is **manganese dissolution** into the electrolyte. In pristine LiMn₂O₄ the manganese exists as a 1:1 mixture of Mn³⁺ and Mn⁴⁺ — an average oxidation state of +3.5 — because charge balance with one Li⁺ and four O²⁻ demands it. At elevated temperatures (above ~40°C), and especially when trace HF is present in the electrolyte from LiPF₆ hydrolysis, surface Mn³⁺ ions undergo a disproportionation reaction:

$$2\,\text{Mn}^{3+}_{(\text{solid})} \longrightarrow \text{Mn}^{2+}_{(\text{solution})} + \text{Mn}^{4+}_{(\text{solid})} \tag{5.3}$$

The Mn²⁺ that is produced is soluble in the electrolyte and leaves the cathode; the Mn⁴⁺ stays behind but cannot participate in redox cycling at normal cell voltages. The cathode thus loses both Mn and its associated capacity. The dissolved Mn²⁺ then migrates to the graphite anode, deposits on its surface, and catalyses the decomposition of the SEI — dramatically accelerating capacity fade. This mechanism, called **transition metal crossover** or **Mn crosstalk**, is severe enough at operating temperatures above 40–50°C that LMO cells stored at elevated temperature degrade rapidly. This temperature sensitivity limits LMO's practical application range.

**LNMO** (LiNi₀.₅Mn₁.₅O₄, the high-voltage spinel) is an important variant that operates at approximately 4.7 V vs. Li/Li⁺ — the highest cathode voltage of any commercially relevant material. At this voltage, conventional carbonate electrolytes are near the edge of their oxidative stability window, which has prevented LNMO from commercialising despite its attractive electrochemistry. Finding electrolytes stable at 4.7+ V vs. Li/Li⁺ is one of the open challenges in battery materials research.

Application: **power tools, medical devices, some EV applications as a blend component with NMC** (LMO/NMC blends combine LMO's power capability and low cost with NMC's energy density and better cycle life).

**A consolidating table.** At this point we have met all three structural dimensionality classes for LIB cathodes. It is worth collecting them:

| Structure family   | Example       | Li diffusion dimensionality | Rate capability   | Defect sensitivity         |
| :----------------- | :------------ | :-------------------------: | :---------------: | :------------------------- |
| Olivine            | LFP           | 1D (tunnels)                | Intrinsic poor    | Very high                  |
| Layered O3         | LCO, NMC, NCA | 2D (planes)                 | Moderate–good     | Moderate (cation mixing)   |
| Spinel             | LMO, LTO      | 3D (network)                | Excellent         | Low                        |

The table encodes a rule that battery materials chemists internalise early: *structural dimensionality is one of the strongest predictors of rate capability and defect tolerance*. Chapter 6 will extend this table downward with the SIB cathodes, where we will meet layered O3 and P2 types again and also the three-dimensional Prussian blue analogue framework — and the same structure/rate/defect relationship will hold.

---

## 5.7 LTO: Lithium Titanate — The Safe, Long-Life Anode

**LTO** — **lithium titanium oxide**, formula Li₄Ti₅O₁₂ — is the odd one out in this chapter: it is an **anode material**, not a cathode material. Its inclusion is justified by its distinct performance profile and its importance in specific applications.

LTO has the spinel crystal structure (like LMO), with lithium and titanium sharing octahedral and tetrahedral sites. Its intercalation half-reaction is:

$$\text{Li}_4\text{Ti}_5\text{O}_{12} + 3\,\text{Li}^+ + 3\,e^- \longrightarrow \text{Li}_7\text{Ti}_5\text{O}_{12} \tag{5.4}$$

with $E^\circ \approx +1.55$ V vs. Li/Li⁺.

This is the defining characteristic of LTO: its potential (1.55 V vs. Li/Li⁺) is much higher than graphite (0.05–0.25 V vs. Li/Li⁺). This high anode potential has three important consequences.

**Consequence 1 — No SEI formation.** At 1.55 V, LTO operates above the thermodynamic window where standard carbonate electrolytes are reduced, so the classical SEI that dominates graphite anode aging does not form. In practice LTO surfaces develop a very thin interphase (a few nanometres) from slow side reactions with trace impurities, and at elevated temperatures (~60°C and above) this film thickens and produces gas — the well-known LTO gassing problem that complicates pouch-cell packaging. For our purposes, however, the first-order picture is clean: near-100% first-cycle Coulombic efficiency and essentially zero SEI-driven capacity fade under normal operation. LTO cells can achieve **10,000–20,000 cycles** — extraordinary longevity that no other mainstream chemistry approaches.

**Consequence 2 — No lithium plating.** At 1.55 V vs. Li/Li⁺, the LTO potential sits 1.55 V above the lithium plating potential of 0 V. Even a severely polarised graphite anode at the end of a 3C charge might only drop ~50–100 mV below its equilibrium value — and graphite equilibrium is already only ~80 mV above plating, which is why graphite plates at all. An LTO anode would need to be polarised by a full 1.55 V — more than an order of magnitude larger than any plausible in-cell overpotential — before its surface potential reached 0 V vs. Li/Li⁺. Lithium plating, the dominant fast-charging safety and degradation concern for graphite anodes, is therefore essentially impossible with LTO. This makes LTO cells inherently safe for fast charging, safe at low temperatures (where plating on graphite gets worse because of sluggish solid-state diffusion), and the reason Toshiba advertises its SCiB cells for minus-30°C operation — an environment where graphite-anode cells would plate on almost any charge pulse.

**Consequence 3 — Low cell voltage.** When paired with a 4.0 V cathode (e.g., LMO, which is the most common LTO cathode partner), the cell voltage is $4.0 - 1.55 = 2.45$ V — significantly lower than a graphite/NMC cell at 3.6 V. Lower cell voltage means lower energy density. Combined with LTO's relatively low theoretical specific capacity ($C_\text{th} = 3 \times 96485 / (3.6 \times 459.1) = 175$ mAh/g theoretical, ~160 mAh/g practical), LTO/LMO cells typically achieve only **50–80 Wh/kg** at the cell level — roughly one-third to one-quarter the energy density of a NMC/graphite cell. This is the fundamental trade-off: extraordinary longevity and safety, at the cost of very low energy density.

LTO also exhibits the **zero-strain** property: the volume change of Li₄Ti₅O₁₂ during lithiation to Li₇Ti₅O₁₂ is nearly zero (~0.2%). No mechanical stress from cycling means no particle cracking, no SEI disruption, and no loss of inter-particle contact. Combined with the no-SEI advantage, zero-strain is the mechanistic origin of LTO's exceptional cycle life.

Application: **fast-charging public transit buses (Toshiba SCiB cells, widely deployed in Asia), grid frequency regulation (where fast response and long life are critical), UPS systems, any application requiring extreme cycle life or fast charging where energy density is not the primary constraint**. LTO remains niche because of its low energy density, but within its application window it is uniquely suited.

---

## 5.8 Anode Alternatives: A Brief Survey

We have now covered the major cathode chemistries. The anode side is somewhat simpler: graphite dominates overwhelmingly, with silicon-graphite composites as the primary performance enhancement. LTO has been covered above. Two other anode materials deserve brief mention.

### Hard Carbon for Lithium-Ion

Hard carbon intercalates lithium as well as sodium. In lithium-ion cells, hard carbon offers a specific capacity of approximately 200–300 mAh/g (higher than LTO, lower than graphite) at potentials of 0.1–1.0 V vs. Li/Li⁺. Its disordered structure means it is less prone to graphite's stage-phase-transition-related mechanical stress, potentially giving better rate capability and cycle life.

However, hard carbon's ICE for lithium is typically 80–90% — somewhat lower than graphite — and its lower density compared to graphite means lower volumetric energy density. Hard carbon anodes for LIBs remain a niche application (some sodium-ion researchers argue the distinction between HC-based LIBs and SIBs is primarily a matter of which ion is being intercalated). For the purposes of this book, hard carbon as an anode is primarily a sodium-ion story, which we take up in Chapter 6.

### Lithium Metal

The ultimate anode for lithium-ion batteries is lithium metal itself. Its theoretical specific capacity is $C_\text{th} = F/(3.6 \cdot 6.941) = 3862$ mAh/g, and its potential is, by definition, 0 V vs. Li/Li⁺ — the most negative (most reducing) electrode potential achievable in a lithium cell, and therefore the one that, paired with any given cathode, yields the largest possible cell voltage and the highest energy density. Compared to graphite, lithium metal gives you roughly 10× the specific capacity and eliminates the ~100 mV of graphite overpotential that eats into cell voltage. The energy density ceiling for a lithium metal / NMC811 cell is approximately 500+ Wh/kg — nearly double current state-of-the-art.

The obstacles to lithium metal are the same issues that make LTO's no-plating guarantee so attractive, now in reverse: the SEI on lithium metal is unstable, grows continuously, and never fully passivates. Lithium plating is inhomogeneous, producing **dendrites** — needle-like lithium metal filaments that can pierce the separator and cause internal short circuits, potentially triggering thermal runaway. Coulombic efficiency of lithium metal anodes is typically 95–99.5% per cycle in current solid-state and liquid electrolyte systems — far too low for the 1000+ cycle life automotive applications demand.

Solving the lithium metal anode problem (achieving 99.9%+ CE, suppressing dendrites, maintaining stable SEI over thousands of cycles) is arguably the single most important open problem in battery materials science. Progress is being made via solid electrolytes, artificial SEI coatings, electrolyte additive engineering, and 3D host architectures, but commercial solid-state cells with high-energy lithium metal anodes remain years away from mass deployment as of the mid-2020s.

---

## 5.9 Which Chemistry Wins in Which Application?

We now have enough vocabulary to answer the question explicitly. Before we look at the metric-by-metric comparison, it is useful to see the current distribution of these chemistries in actual manufactured cells. The table below gives rough global EV-market shares as of the mid-2020s (the numbers shift meaningfully year over year and should be taken as approximate):

| Chemistry                | Approx. EV market share (2024) | Direction              |
| :----------------------- | :----------------------------: | :--------------------- |
| LFP                      | ~40%                           | Growing rapidly        |
| NMC (all variants)       | ~50%                           | Slowly declining       |
| NCA                      | ~5%                            | Stable (Tesla-linked)  |
| Other (LMO blends, LTO)  | <5%                            | Niche                  |

The most striking trend in this market over the past five years is the resurgence of LFP. As recently as 2019, LFP was considered a second-tier chemistry relegated to low-end and bus applications; by 2023 it had overtaken NMC in Chinese domestic EV sales, and by 2024 it was the dominant chemistry in mass-market EVs globally. The reason is not a technical breakthrough in LFP itself — it is the same chemistry Goodenough's group reported in 1997. The reason is that applications shifted underneath the chemistry: as battery pack sizes grew and cost per kWh became the dominant commercial metric, LFP's cost advantage began to outweigh its energy density penalty, and cell-to-pack engineering innovations (notably CATL's CTP and BYD's Blade) let manufacturers recover some of the volumetric disadvantage at the pack level. This is a textbook example of how the chemistry–application fit is a moving target: *the right answer depends on the application, and the applications change*.

The following table summarises the key metrics for the major chemistries alongside their primary application domains:

| Chemistry         | Nominal V (V) | Spec. Capacity (mAh/g) | Cell Energy (Wh/kg) | Cycle Life (cycles) | Safety       | Cost           | Primary Application       |
| ----------------- | :-----------: | :--------------------: | :-----------------: | :-----------------: | :----------: | :------------: | ------------------------- |
| LCO/graphite      | 3.8           | 140–160                | 200–260             | 500–1000            | Low–moderate | High           | Consumer electronics      |
| LFP/graphite      | 3.2           | 155–170                | 150–200             | 3000–6000           | Excellent    | Low            | Grid, e-bus, mass EV      |
| NMC111/graphite   | 3.7           | 155–165                | 180–220             | 800–1500            | Good         | Moderate       | Power tools, early EV     |
| NMC622/graphite   | 3.7           | 180–200                | 220–260             | 600–1200            | Good         | Moderate       | Premium EV (2018–2022)    |
| NMC811/graphite   | 3.7           | 200–220                | 240–280             | 500–1000            | Moderate     | Moderate–low   | Current premium EV        |
| NCA/graphite      | 3.6           | 190–220                | 250–290             | 500–1000            | Moderate     | Moderate       | Tesla vehicles            |
| LMO/graphite      | 4.0           | 100–120                | 100–150             | 300–700             | Good         | Low            | Power tools, blends       |
| LTO/LMO           | 2.45          | 120 (cell)             | 50–80               | 10000–20000         | Excellent    | Moderate–high  | Transit, grid FR          |

A few observations that will be useful when we compare SIBs in Chapter 6:

The LFP/graphite chemistry is the closest thing to a "right answer" for cost-sensitive, high-cycle-life applications. Its energy density penalty versus NMC is approximately 25–35%, but its cost advantage (no cobalt, no nickel, abundant iron and phosphorus) is substantial, and its cycle life advantage is enormous. The resurgence of LFP in the 2020s — with BYD, CATL, and others deploying LFP in mass-market EVs and grid storage — is a story about how application requirements (cost per cycle, not energy density per kilogram) determine chemistry selection.

The progression from NMC111 to NMC622 to NMC811 is a systematic trade of thermal stability and cycle life for energy density, with declining cobalt content as a beneficial side effect. Understanding this progression helps you read the current literature intelligently: a paper on NMC811 degradation is directly relevant to the frontier of the commercial chemistry, while a paper on NMC111 is either historical context or addressing a niche application.

The LTO case illustrates a broader principle: sometimes the right answer is to accept a large energy density penalty in exchange for properties (no plating, no SEI, zero strain) that enable an application category that is otherwise inaccessible. In battery engineering, absolute performance on any single metric is less important than the match between performance profile and application requirements.

---

## Worked Interpretation Exercise: Reading a Differential Capacity ($dQ/dV$) Curve

The differential capacity (or **incremental capacity**) curve — $dQ/dV$ plotted against voltage $V$ — is one of the most diagnostic fingerprints of a battery chemistry. We introduced this concept in Chapter 3 (Section 3.10) in the context of PITT measurements; now we can read one meaningfully.

Here is the key intuition. A two-phase reaction produces a flat plateau in $V(Q)$: large changes in $Q$ at essentially zero change in $V$. Take the derivative $dQ/dV$ and that flat plateau becomes a sharp peak — $dQ \to \infty$ as $dV \to 0$. A solid-solution reaction, conversely, produces a smoothly sloped $V(Q)$ region, and its derivative is a broad, low feature. Taking $dQ/dV$ is therefore the electrochemical analogue of taking $\frac{d}{dt}$ of a voltage ramp in an EE circuit: steps become spikes, gradual ramps become plateaus, and features that were hidden in the original signal jump out. If you think of $V(Q)$ as a time-domain signal and $dQ/dV$ as its "edge detector," every peak in $dQ/dV$ is an event in the battery's internal thermodynamics — a phase transition, a staging transition, the onset of a new redox couple — that you could not easily see in the raw voltage curve.

Consider the differential capacity curve for a fresh **NMC622/graphite** cell (based on published data from Dahn's group at Dalhousie University; representative of many commercial NMC/graphite cells). The curve is measured by integrating the current in a very slow C/25 rate galvanostatic discharge, then computing $dQ/dV$ numerically. The following features are observed as the cell discharges from 4.2 V to 3.0 V:

**Peak 1 at approximately 4.1 V (discharge)**: A tall, sharp peak — usually the largest feature in the whole curve. This corresponds to the graphite anode transitioning from stage-1 (LiC₆) to stage-2 (LiC₁₂), a genuine two-phase coexistence on the graphite side that holds the graphite potential flat at roughly 85 mV vs. Li/Li⁺ over a substantial slice of the anode capacity. A flat anode plateau at ~0.085 V combined with a cathode voltage near ~4.19 V produces the sharp cell-voltage feature near 4.1 V. Because this peak reflects a true phase transition, its sharpness is the signature you should expect — the same reason the LFP plateau shows up as a near-delta-function peak, which we will see in a moment. The area under Peak 1 is directly proportional to the number of moles of Li shuttled during the stage-1 ↔ stage-2 transition, and its amplitude decreases characteristically as lithium inventory is lost — making this peak one of the most diagnostic features for tracking graphite capacity loss.

**Broad region 4.1 to 3.7 V**: A continuous rise and fall in $dQ/dV$, reflecting the single-phase (solid-solution) lithiation of the NMC cathode across most of its composition range. NMC has no sharp phase transitions in this range — the gradual change in Li content produces a smooth $dQ/dV$ response. The area under this peak is proportional to the capacity delivered in this voltage range.

**Peak 2 at approximately 3.7 V**: A moderate peak corresponding to the graphite stage-2 → stage-2L transition on discharge (the reverse direction from peak 1), where stage-2L denotes a "liquid-like" or dilute variant of stage-2 in which the Li layers are no longer ordered. The graphite potential climbs from ~90 mV to ~120 mV across this feature. In a full-cell dQ/dV it appears as a smaller but still distinct peak, and its position and amplitude are another classical fingerprint of graphite — absent in LTO or hard-carbon anodes.

**Peak 3 at approximately 3.6 V**: A smaller peak corresponding to another graphite staging transition (stage-2L to stage-3). Again, a graphite fingerprint.

**Broad region 3.5 to 3.2 V and Peak 4 at approximately 3.45 V in LFP** (for contrast — this is not an NMC feature but described here for comparison): If we were looking at an LFP/graphite cell, we would see an enormous, sharp peak at approximately 3.45 V occupying almost the entire $dQ/dV$ curve — the flat LFP plateau appearing as a delta-function-like peak in the differential capacity view. A $dQ/dV$ peak that is very sharp and tall indicates a flat voltage plateau (two-phase reaction); a $dQ/dV$ peak that is broad and low indicates a sloped voltage region (single-phase reaction).

**The diagnostic utility**: As a cell ages, the peaks in its $dQ/dV$ curve change in characteristic ways. The area under each peak decreases as capacity fades. Peaks shift in voltage as electrode compositions become misaligned (the phenomenon of "electrode slippage" where the relative lithiation states of anode and cathode drift due to lithium inventory loss). The ability to diagnose degradation mode from $dQ/dV$ curve evolution — without disassembling the cell — is the basis of the incremental capacity analysis (ICA) technique. We will apply ICA to specific degradation modes in Chapter 7.

For now, the key takeaway is that the $dQ/dV$ curve is a Rosetta Stone: it translates the thermodynamic structure of each electrode material (its phase transitions, solid-solution ranges, staging phenomena) into a measurable electrical signal visible from the cell terminals. Every feature in the curve has a specific physical origin, and learning to read those features is one of the most valuable experimental skills a battery researcher can develop.

---

## What Changes for Sodium-Ion?

Chapter 6 is entirely devoted to sodium-ion chemistry, so this section is briefer than usual and serves mainly to orient the transitions.

The most important message from Chapter 5, for a reader preparing to study sodium-ion batteries, is this: **every sodium-ion cathode concept has a direct lithium-ion analogue, and understanding the LIB version makes the SIB version much easier to grasp**. The O3 layered oxides of SIB (NaxCoO₂, NaxNiO₂, and multi-metal variants) are structural cousins of LCO and NMC. The P2 layered oxides unique to SIB are a variant on the layered theme that has no close LIB parallel, but they are more naturally understood against the LIB layered oxide background. The NVPF polyanionic cathode is the sodium analogue of LFP — same structural philosophy (strong covalent framework, inductive effect tuning of voltage, excellent thermal stability), different metal and anion. Prussian blue analogues are unique to SIBs (and some non-battery applications) but use the same two-phase reaction mechanism as LFP.

For anodes, the contrast is stark: graphite (the LIB standard) does not work for sodium, and this forces the SIB to rely on hard carbon — a material with a fundamentally different OCV shape, lower ICE, and more complex physical mechanism. The consequences of this difference for BMS design (the flat plateau problem) and cell manufacturing (lower ICE requires pre-sodiation compensation) flow directly from the contrast between the graphite vs. hard carbon OCV curves we will examine in Chapter 6.

The energy density comparison is also important context. Current SIB cells achieve 100–160 Wh/kg at the cell level — comparable to LFP, below NMC. The SIB pitch is not energy density leadership; it is cost-plus-sustainability (no lithium, no cobalt, no nickel in some variants, aluminium current collectors, abundant sodium salt). Chapter 6 will make this pitch precise.

---

## Chapter Summary

**Key ideas:**

- Battery chemistries compete across five dimensions: energy density, power density, safety, cycle life, and cost. No chemistry wins on all five simultaneously. Application requirements determine the best trade-off.
- LCO (layered O3, LiCoO₂): highest volumetric energy density, high cost, moderate cycle life, poor safety at high SOC. Dominates consumer electronics. Practical capacity ~150 mAh/g (half of theoretical) due to structural instability above x = 0.5.
- LFP (olivine, LiFePO₄): low cost, excellent safety (oxygen release onset ~400–450°C, far above any achievable in-pack temperature), excellent cycle life (3000–6000 cycles), flat voltage plateau (SOC-estimation challenge), lower energy density. Dominant in grid storage, e-buses, mass-market EVs.
- NMC (layered O3, Li(Ni,Mn,Co)O₂): dominant for premium EVs. Increasing nickel content (111 → 622 → 811) increases capacity and reduces cobalt content but reduces thermal stability and cycle life. NMC811 is the current state-of-the-art at 200–220 mAh/g.
- NCA (layered O3, Li(Ni,Co,Al)O₂): similar to high-Ni NMC, dominant in Tesla supply chain. Aluminium stabilises the lattice against cation mixing.
- LMO (spinel, LiMn₂O₄): excellent rate capability (3D diffusion), low cost, safety-adequate, but manganese dissolution above ~40°C limits cycle life. Often used as a blend component with NMC.
- LTO (spinel anode, Li₄Ti₅O₁₂): 1.55 V vs. Li/Li⁺ anode potential — no SEI, no Li plating, zero strain, 10,000–20,000 cycle life, safe fast charging. Very low energy density (50–80 Wh/kg cell-level). Niche: fast-charging transit, grid frequency regulation.
- Graphite remains the standard anode. Silicon addition (~5–10%) increases capacity but introduces volume expansion and faster fade. Lithium metal anodes offer theoretical 500+ Wh/kg but dendrite and CE challenges remain unsolved commercially.
- Structural dimensionality (1D olivine, 2D layered, 3D spinel) is one of the strongest predictors of rate capability and defect tolerance.
- The $dQ/dV$ curve (differential capacity) is a diagnostic fingerprint: peaks correspond to phase transitions and staging phenomena in each electrode. Their evolution with cycling reveals degradation mode.

**Key equations:**

The theoretical specific capacity of any active material follows from Faraday's first law,

$$C_\text{th}~[\text{mAh/g}] = \frac{nF}{3.6\,M},$$

where $n$ is electrons per formula unit, $F = 96485$ C/mol, $M$ is molar mass in g/mol, and the factor 3.6 converts coulombs to milliamp-hours. The full-cell nominal voltage is the difference of electrode potentials,

$$E_\text{cell} = E_\text{cathode} - E_\text{anode},$$

measured (by convention) against the same reference electrode — for lithium cells, metallic Li at 0 V. And the **inductive effect** provides a qualitative design rule for cathode voltage: a polyanionic host (like the phosphate in LFP) produces a higher redox potential than a simple oxide host of the same transition metal, because the polyanion withdraws electron density from the metal, lowering the energy of its occupied d-orbitals and raising the potential at which the metal is reduced during discharge.

**Key vocabulary (in order of appearance):**

Energy-power-safety-cost-life pentagon, LCO, layered O3 structure, quasi-2D diffusion, cation mixing, LFP, olivine, one-dimensional diffusion, anti-site defect, inductive effect, two-phase reaction, carbon coating, NMC, solid solution vs. mixture, Ni:Mn:Co ratio (111/532/622/811), surface reconstruction, rock-salt layer, NCA, structural rebar (Al³⁺, Mn⁴⁺), LMO, spinel, 3D diffusion network, manganese dissolution, Mn crosstalk, LNMO, LTO, zero-strain anode, no-SEI anode, Li plating prevention, silicon anode, lithium metal anode, dendrite, staged intercalation, differential capacity ($dQ/dV$), incremental capacity analysis (ICA), electrode slippage.

---

## Deliverable

The primary deliverable for this chapter feeds the Chapter 6 table task. Begin building the LIB half of the comparison table now.

For each of the five LIB chemistries you will use in the comparison (suggested: LFP/graphite, NMC622/graphite, NMC811/graphite, NCA/graphite, and LTO/LMO), record the following metrics using published datasheet or literature values for a specific commercial cell: nominal voltage, rated capacity, specific energy (Wh/kg), volumetric energy density (Wh/L), DCIR (mΩ), 1C capacity retention (%), cycle life (cycles to 80%), and any available OCV curve shape descriptor (flat or sloped, and where).

The table will be completed with SIB counterparts in Chapter 6.

As a partial worked example, here is an entry for the **Samsung INR18650-30Q** (3.0 Ah, 18650 format), a widely-used high-nickel cell drawn from published characterisation literature. The precise chemistry of the 30Q is somewhat contested — some characterisation studies report it as NMC622, others as NCA, and Samsung does not publish the cathode composition — so I list its specs here without committing to a chemistry label. For the purposes of building your comparison table, note the chemistry as "high-Ni (NMC622 or NCA, unconfirmed)" and move on.

Nominal voltage: 3.6 V. Rated capacity: 3000 mAh at C/5, 25°C. Specific energy: approximately 243 Wh/kg (measured; from the cell mass of ~44 g and energy of 3.0 Ah × 3.6 V = 10.8 Wh). Volumetric energy density: approximately 650 Wh/L. DCIR at 50% SOC, 25°C: approximately 45 mΩ (from EIS high-frequency intercept). Cycle life: approximately 500 cycles to 80% at 1C/1C, 100% DOD, 25°C. OCV shape: moderately sloped throughout, with graphite staging features visible at low potential.

---

## Further Reading

1. **Goodenough, J. B. and Kim, Y., "Challenges for Rechargeable Li Batteries," *Chemistry of Materials* 22 (3), 587–603 (2010).** Goodenough's own retrospective on the development of LCO, LFP, and the cathode challenge landscape. Authoritative, concise, and a model of clear scientific writing. Read this for historical context and for Goodenough's perspective on what the unsolved problems are.

2. **Noh, H.-J. et al., "Comparison of the structural and electrochemical properties of layered Li[Ni$_x$Co$_y$Mn$_z$]O₂ (x = 1/3, 0.5, 0.6, 0.7, 0.8 and 0.85) cathode material for lithium-ion batteries," *Journal of Power Sources* 233, 121–130 (2013).** The systematic study of the NMC family from Ni = 0.33 to Ni = 0.85 in a single paper, showing how capacity, thermal stability, and structural parameters evolve with nickel content. Essential reading for understanding the NMC trade-off.

3. **Whittingham, M. S., "Lithium Batteries and Cathode Materials," *Chemical Reviews* 104 (10), 4271–4302 (2004).** A comprehensive review of cathode materials history and science, by one of the three 2019 Nobel laureates. Covers the olivine, layered, and spinel families in depth, with excellent discussion of the structural chemistry underlying performance.

4. **Etacheri, V. et al., "Challenges in the development of advanced Li-ion batteries: a review," *Energy & Environmental Science* 4, 3243–3262 (2011).** A systems-level review of the major challenges facing each chemistry family, from electrolyte compatibility to thermal management. Particularly useful for its treatment of the silicon anode challenge and the lithium metal anode problem.

5. **Dahn, J. R. et al., "Suppression of Hydrogen Evolution and Voltaic Efficiency Improvement in Rechargeable Lithium Batteries by Electrolyte Additives," and associated works.** Dahn's group at Dalhousie has published hundreds of systematic studies on LIB electrolyte and electrode performance. The series of papers using the "100-cell testing" methodology for cycle life prediction are the most rigorous long-term cycle life studies in the literature and establish quantitative comparisons between NMC variants under controlled conditions.

---

*Next chapter: **Chapter 6 — Sodium-Ion Chemistry Families.** We map the SIB landscape with the full LIB context now in place: O3 and P2 layered oxides, NVPF and NFPP polyanionic cathodes, Prussian blue analogues, hard carbon anodes, and the commercial cells that have brought SIB to market. Prompt me with "write Chapter 6" to continue.*

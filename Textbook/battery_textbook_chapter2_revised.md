# Chapter 2: How a Battery Works in Operation

## Chapter Opening

Chapter 1 gave you the thermodynamic skeleton of a battery: the half-reactions, the free-energy driving force, the Nernst equation telling you what voltage to expect at equilibrium. That framework is necessary, but it describes a battery that is infinitely slow and perfectly at rest — a Platonic ideal that never quite exists in the laboratory. Real batteries do real things: they charge and discharge at finite rates, they lose some of their energy to heat, their voltage sags under load and then recovers when the load is removed, and they slowly degrade with every cycle. None of that can be explained by thermodynamics alone.

This chapter is where we build the dynamic picture. We are going to follow a lithium ion — or, later, a sodium ion — on its complete journey from the moment it leaves the cathode host material during discharge to the moment it arrives at the anode and settles into its new lattice site. Along the way, it will cross phase boundaries, navigate a turbulent liquid medium, squeeze through a polymer membrane, pass through a thin and chemically complex solid film, and finally be accepted by an electrode surface that only grants entry at a rate governed by an exponential activation law. Every one of those steps is a distinct physical process with its own time constant, its own voltage cost, and its own potential failure mode.

By the end of this chapter, you will be able to explain — in physical terms, not just label names — why a cell's voltage drops when you draw current from it, why performance degrades at low temperature, why fast charging is harder than fast discharging, why the first few charge cycles are irreversible, and how you can distinguish, from external measurements alone, whether a cell is limited by kinetics or by diffusion. You will also have your first encounter with the Butler-Volmer equation: we will not derive it here (that comes in a later chapter), but we will develop enough intuition for it that the full derivation will feel inevitable rather than surprising.

This chapter is the conceptual heart of the book. Everything in Parts IV, V, and VI — degradation, thermal behaviour, state estimation — loops back to the physical processes described here. Read it slowly.

---

> **Prerequisites Check**
>
> From your EE background:
>
> - RC circuit time constants and impedance (essential for Section 2.4 and 2.6)
> - Basic concepts of diffusion as a transport phenomenon (helpful but will be built up from scratch)
> - Exponential I-V characteristics (diodes) — the Butler-Volmer equation in Section 2.8 is structurally analogous
>
> From Chapter 1:
>
> - Half-reactions, oxidation and reduction (Section 1.2)
> - Cell anatomy: anode, cathode, electrolyte, separator (Section 1.3)
> - The Nernst equation and why composition affects voltage (Section 1.5)
> - Activity and its role in thermodynamics (Section 1.6)
>
> If you are uncertain about RC time constants, spend five minutes reviewing them before Section 2.4 — the double-layer capacitance analogy is central and worth following carefully.

---

## 2.1 Intercalation — the Guest-Host Mechanism

Let us begin with the most important single concept in modern battery technology: **intercalation**. Almost every commercial rechargeable battery built in the last three decades relies on it, and understanding it deeply will pay dividends throughout this book.

The word **intercalation** comes from the Latin *intercalare*, meaning to insert between. In the context of batteries, it describes a process in which guest ions (lithium, sodium, or another species) insert into — and can be reversibly removed from — the crystal lattice of a host material, without fundamentally destroying that lattice's structure. The host is the electrode material. The guest is the ion being stored.

Think of it this way. Imagine a multi-storey car park with thousands of spaces arranged in a precise geometric grid. When cars drive in, they occupy the spaces. When they drive out, the structure of the car park is completely unchanged — the same concrete columns, the same ramps, the same spatial layout. The cars have come and gone, but the host is unaltered. Intercalation is the same process at the atomic scale: ions slip into the available voids within a crystalline host, and they can be pulled back out again. The host survives both events with its crystal structure largely intact.

This is what makes lithium-ion batteries rechargeable. If the electrode reactions destroyed the host material irreversibly — as happens in a zinc-manganese dioxide alkaline cell, where the reaction products are different phases from the reactants — you cannot put the material back to its original state by running current in reverse. The reaction is irreversible at the structural level. Intercalation reactions, because they preserve the host framework, are reversible: you can insert the guest, remove it, and insert it again thousands of times.

The guest ions in a lithium-ion battery are Li⁺ ions. In a sodium-ion battery, they are Na⁺ ions. In either case, the ion moves between the two electrodes through the electrolyte, and the corresponding electron moves through the external circuit. The electrons are not stored inside the electrode in some abstract sense — they are transferred to or from the metal current collector at each half-reaction. What the electrode stores is the guest ion in a specific arrangement of lattice sites.

**Students sometimes confuse intercalation with dissolution.** In dissolution, the host material breaks down: the electrode material chemically reacts with the electrolyte, and the products dissolve into the liquid phase. This is a fundamentally different and generally destructive process. Intercalation does not dissolve the host. The lithium or sodium ion enters the solid host intact; the solid remains a solid.

There is a second important distinction: intercalation is not the same as **alloying**, even though alloying also stores guest atoms in a solid host. In alloying, the insertion of the guest changes the crystal structure so dramatically — often creating entirely new intermetallic phases — that the volumetric expansion can be 100–400%. Silicon, for instance, alloys with lithium to form Li₁₅Si₄, expanding by about 300% in volume. This huge volume change causes mechanical fracture of the silicon particles after repeated cycling. Intercalation hosts, by contrast, typically expand by only 1–10% in volume when fully loaded, which is why they survive thousands of cycles without cracking.

### What Happens Microscopically During Intercalation

Let us trace exactly what happens when a lithium-ion cell discharges, at the atomic scale.

At the negative electrode (graphite anode) surface, the following process occurs: a LiC₆ unit in the graphite lattice — lithium sandwiched between graphene layers — donates its lithium atom. The lithium loses its electron (which enters the current collector and flows through the external circuit), becoming Li⁺, and slides out of the graphite interlayer space into the electrolyte. The graphite layer spacing contracts slightly as the lithium leaves. At full discharge, the graphite is nearly devoid of lithium: we write this as $\text{C}_6$, or more carefully as $\text{Li}_x\text{C}_6$ with $x \approx 0$.

The sodium-ion analogue of this paragraph looks broadly similar and differs in one crucial respect. The guest ion is Na⁺ rather than Li⁺; the host is **hard carbon** — disordered, non-graphitic carbon with turbostratic layer fragments and a population of closed nanopores — rather than crystalline graphite; and the insertion mechanism is a hybrid of two distinct processes rather than the clean staged intercalation of Li into graphite. We will unpack the hybrid mechanism in Chapter 6. What matters here is that graphite itself does *not* work as a sodium host at room temperature: Na⁺ and graphene do not form a stable staged intercalation compound analogous to $\text{LiC}_6$, for reasons tied to the balance of solvation energy and insertion energy that we will meet again in Section 2.5. This is the first place in the book where a plausible Li-ion assumption — "of course the same carbon anode works for both" — turns out to be wrong, and it is worth registering the surprise now. The search for a graphite-equivalent Na anode consumed most of a decade of materials research before hard carbon settled into its role as the consensus solution, and the question of whether something better exists is still open.

At the positive electrode (LCO cathode) surface, the reverse process occurs: Li⁺ arrives from the electrolyte, accepts an electron from the current collector (which arrived from the external circuit), and inserts into an available site in the LiCoO₂ lattice. The cobalt ion adjacent to the newly arrived lithium is reduced from Co⁴⁺ to Co³⁺ to balance charge. At full discharge, the cathode is lithium-rich: Li₁CoO₂.

Notice that the lithium in the electrolyte is always Li⁺ — never Li⁰. The electron and the ion travel separately: the electron through the external circuit, the ion through the electrolyte. The ion does not "carry" the electron — they meet again only at the electrode surface where the half-reaction occurs.

**A common misconception, especially for EE readers.** The word "anode" does not mean "negative terminal". The anode is the electrode where *oxidation* occurs, which is the electrode that gives up electrons to the external circuit. During discharge, that is the graphite electrode, which is also the negative terminal — so "anode" and "negative" coincide, and it is tempting to treat them as synonyms. But during *charge*, oxidation now occurs at the cathode-material side (Li⁺ leaves the LiCoO₂ lattice and Co³⁺ is oxidised back to Co⁴⁺), so the LCO electrode is now the anode despite still being the positive terminal. Most textbooks, and most of this one, label electrodes by their discharge roles: we will call the graphite electrode "the anode" and the LCO electrode "the cathode" regardless of whether the cell is charging or discharging, because that is how commercial cell datasheets and battery engineers talk. Just remember that the labels are a *discharge-centric convention*, not a law of physics, and that if you read the older electrochemistry literature you will sometimes find strict electrode-role usage that disagrees with the battery-engineer convention.

The reversibility of this process relies on a crucial property of the host materials: they must have stable crystal structures that can accommodate the strain of expansion and contraction as the guest ion population changes, they must be electronically conductive (so electrons can be delivered to or removed from the reaction site within the solid), and they must have sufficiently large pathways for the guest ions to diffuse through the lattice.

---

## 2.2 Why Intercalation Hosts Matter: Layered, Spinel, Olivine, and Polyanionic Structures

Not all crystal structures make good intercalation hosts. The host material must satisfy several simultaneous requirements: it must have enough structural void space to accommodate the guest ion, it must be rigid enough not to collapse when the guest is removed, it must be electronically conductive within the solid (so half-reactions can proceed at particle surfaces), and the energy of insertion must be in the right range to produce a useful cell voltage. Different crystal structure families satisfy these requirements to different degrees, and understanding the major families will help you read the battery materials literature much more fluently.

### Layered Oxides

The **layered oxide** structure is the workhorse of lithium-ion and sodium-ion cathode materials. The archetype is LiCoO₂ — lithium cobalt oxide — first proposed as a cathode by Goodenough in 1980 and still used in consumer electronics today.

The crystal structure of LiCoO₂ consists of alternating layers: a layer of CoO₂ (edge-sharing CoO₆ octahedra forming a flat sheet), then a layer of lithium ions, then another CoO₂ sheet, and so on, stacked in a repeating pattern. The lithium ions sit in octahedral sites between the CoO₂ layers, and they can diffuse relatively freely within their layer plane — the two-dimensional channels in the lithium layer are the pathways for diffusion.

When lithium is extracted (during charge), the CoO₂ layers remain intact, held together by electrostatic interactions. The lithium layer becomes partially vacant. The cell parameter in the direction perpendicular to the layers changes slightly as lithium is removed. When too much lithium is extracted (beyond about 50% of the theoretical capacity for LCO), the CoO₂ layers begin to slide relative to each other, and the structure can undergo a phase transition to a different stacking sequence, which is one reason LCO is cycled over only part of its theoretical capacity range.

For sodium-ion batteries, layered oxides such as $\text{Na}_x\text{CoO}_2$, $\text{Na}_x\text{NiO}_2$, and multi-component variants like $\text{Na}_x[\text{Ni}_{0.25}\text{Fe}_{0.25}\text{Mn}_{0.5}]\text{O}_2$ are the most studied cathodes. The notation "O3" and "P2" that you will frequently see refers to the stacking sequence of the oxide layers and the coordination environment of the alkali ion: **O3** means the alkali ion sits in an octahedral (O) site with a three-layer (3) repeating unit; **P2** means the alkali ion sits in a prismatic (P) site with a two-layer repeating unit. The P2 structure tends to be more stable during sodium cycling than O3, though the reason is subtler than simple site geometry. The direct argument is that Na⁺, being large, fits comfortably in a prismatic site. The more important argument — and the one that matters for long cycle life — is that O3-type Na cathodes undergo a cascade of phase transitions during desodiation (O3 → P3 → O1 type stackings) that repeatedly slide the oxide layers past each other, generating mechanical stress and inviting crack formation. P2 cathodes cycle within a single phase over a much wider composition range and therefore avoid that fatigue cycle. We will return to this — and to the price P2 pays for its stability, namely a lower sodium content per formula unit and therefore lower theoretical capacity — in Chapter 6.

### Spinel Structures

**Spinel** structures (exemplified by LiMn₂O₄ for lithium-ion) have a three-dimensional framework of interconnected tetrahedral and octahedral sites. The manganese atoms form a continuous three-dimensional lattice, and lithium occupies tetrahedral sites within it. The guest can diffuse through the three-dimensional channel network, which gives spinel materials their excellent rate capability — ions have multiple pathways through the solid rather than being constrained to move within planes. The trade-off is energy density: the three-dimensional structure is less efficient at packing lithium per unit volume than layered structures.

### Olivine Structures

**Olivine** structures, exemplified by LiFePO₄ (lithium iron phosphate, LFP), are the basis of the most commercially important low-cost lithium-ion chemistry. The olivine crystal structure has one-dimensional channels along which lithium can diffuse — the lithium moves in tunnels along the $b$-axis of the crystal. This one-dimensional pathway makes diffusion highly anisotropic: lithium moves quickly in one direction but not at all in the others. Consequently, olivine materials must be made into very small particles (typically 50–200 nm) so the diffusion path length is short.

The characteristic feature of LFP from a battery perspective is its **flat discharge plateau**: over about 95% of its capacity, the cell voltage stays nearly constant at around 3.2–3.4 V vs. Li/Li⁺. This is because LiFePO₄ undergoes a two-phase reaction during lithiation/delithiation: lithium-rich LiFePO₄ and lithium-poor FePO₄ coexist, and as the reaction proceeds, one phase grows at the expense of the other. As we noted in Chapter 1, when two phases coexist, the activity ratio is fixed and the voltage is constant — Nernst equation logic, applied to a solid-state two-phase system. This flat voltage profile makes SOC estimation by voltage lookup very difficult, a problem we will encounter repeatedly in Chapters 10 and 13.

### Polyanionic Structures

**Polyanionic** cathode materials contain complex anions like (PO₄)³⁻, (SO₄)²⁻, or (PO₃F)²⁻ as structural building blocks. Examples include LiFePO₄ (just discussed), Na₃V₂(PO₄)₂F₃ (NVPF, an important SIB cathode), and Na₃V₂(PO₄)₃ (NVP). The polyanionic framework is very rigid and thermally stable — the strong covalent bonding in the polyanion resists structural collapse even when the framework is fully delithiated/desodiated. This rigidity is the source of the exceptional safety and long cycle life of LFP: even at elevated temperatures, the olivine framework does not release oxygen, unlike layered oxides where oxygen evolution under stress is a thermal runaway initiator.

The voltage of a polyanionic cathode is tuned by what is called the **inductive effect**: the electronegative polyanion (e.g., PO₄) withdraws electron density from the transition metal, raising the energy of the d-band and therefore raising the cell voltage. Fluorinated polyanions like (PO₃F)²⁻ are even more electronegative, which is why NVPF has a higher average voltage (~3.9 V vs. Na/Na⁺) than NVP (~3.4 V vs. Na/Na⁺). This is a sophisticated piece of solid-state chemistry, but for our purposes the key point is that the identity of the anion framework controls the voltage as much as the identity of the transition metal.

The reason we have spent time on crystal structures here — even though we will revisit them in Chapters 5 and 6 — is that crystal structure governs the dimensionality of ion diffusion, the magnitude of volumetric strain on cycling, the two-phase versus single-phase reaction mechanism, and the thermal stability of the cathode. All of these show up in the performance and degradation behaviour we will study throughout the book.

---

## 2.3 The Solid-Electrolyte Interphase (SEI): Formation, Function, and Consequences

This section covers one of the most important — and most studied, and still not fully understood — phenomena in battery science. The **solid-electrolyte interphase**, or **SEI**, is a thin film that forms spontaneously on the surface of battery electrodes during the first few charge cycles, as the electrolyte reacts with the electrode surface. Understanding the SEI is essential to understanding capacity fade, impedance growth, first-cycle irreversibility, temperature sensitivity, and several degradation mechanisms. It is also a subject of intense ongoing research: despite decades of study, the exact composition, morphology, and formation mechanism of the SEI remain areas of active debate.

### Why the SEI Forms

Recall from Chapter 1 that the electrolyte must be electronically insulating — it conducts ions, not electrons. This is what forces the electrons to travel through the external circuit rather than short-circuiting through the electrolyte. The electrolyte must also be chemically stable: it should not react with either electrode.

Here is the problem. The electrochemical potential of the graphite anode during lithiation (roughly 0.05–0.25 V vs. Li/Li⁺, i.e., $-3.04 + 0.1 \approx -2.94$ V vs. SHE) is extremely reductive. At this potential, most organic electrolytes are thermodynamically unstable — the electrolyte has a strong thermodynamic tendency to be reduced at the anode surface. Ethylene carbonate, the canonical organic solvent in LIB electrolytes, has a reduction onset around 0.8 V vs. Li/Li⁺. The graphite anode operates *below* this potential.

So why doesn't the electrolyte simply react away indefinitely, destroying the cell? Because the reaction products are mostly solid, they deposit on the electrode surface and form a protective film — the SEI. This film is ionically conductive (Li⁺ can pass through it to reach the electrode surface) but electronically insulating (electrons cannot pass through it). Once the SEI reaches a critical thickness, it passivates the electrode surface: further electrolyte cannot contact the electrode directly, and further reduction stops. The system has self-passivated.

This passivation is not incidental — it is the mechanism that makes graphite anodes viable at all. Without the SEI, the electrolyte would be consumed continuously. It is, in a sense, the thing that protects the thing. The same argument applies verbatim to hard carbon in a sodium-ion cell: the hard-carbon anode also operates at potentials far below the reductive stability window of carbonate electrolytes, and it also survives only because an SEI forms in the first cycle and shuts down further electrolyte reduction. The chemistry of the film is different — different salt, different solvent decomposition products, different inner/outer layer balance — but the *physical role* of the SEI is identical across the two chemistries, and every sentence in this section about why the SEI matters can be read with either Li or Na substituted throughout.

A direct analogy from engineering: the native oxide layer that forms on aluminum metal in air. When aluminum is freshly cut, it reacts with oxygen and forms a thin, dense, adherent Al₂O₃ layer. This layer is impermeable to further oxygen diffusion, so the bulk aluminum is protected. The SEI is the electrochemical equivalent — a self-limiting passivation layer formed not by oxidation in air but by reduction at an electrochemical interface.

### Composition and Structure of the SEI

The SEI is not a single compound — it is a complex, heterogeneous, layered mixture of reaction products. Its composition depends on the electrolyte solvent, the salt, the electrode material, the first-cycle conditions (temperature, current), and the specific contaminants (water, oxygen) present during formation.

For a graphite anode in a LiPF₆/EC:DMC electrolyte (the most studied system), the inner SEI layer — closest to the graphite surface — is enriched in inorganic species, dominated by lithium fluoride (LiF) and lithium carbonate (Li₂CO₃), with smaller amounts of Li₂O and various lithium phosphates. The LiF comes primarily from reductive decomposition of the PF₆⁻ anion and from reaction of trace HF with carbonate species; the Li₂CO₃ comes from solvent reduction pathways involving CO₂ (either residual or generated in situ). The exact balance is sensitive to water content, formation temperature, and cycling protocol, which is part of why SEI composition remains a subject of active measurement decades after the film was first identified. The outer SEI layer — closer to the electrolyte — contains more organic species: lithium alkyl carbonates (e.g., lithium ethylene dicarbonate, LEDC), semicarbonates, and ethers. These form from the reductive decomposition of the solvent molecules.

The inner inorganic layer is denser and more electrically insulating. The outer organic layer is more porous and less stable. The total SEI thickness on graphite after formation is typically 10–100 nm — thin enough to allow good ionic conductivity (the Li⁺ transport resistance across 20 nm of SEI is much smaller than other resistances in the cell), but thick enough to passivate the surface.

### First-Cycle Irreversibility

The formation of the SEI consumes lithium. The lithium that is used to form the SEI — the lithium that reacts with the electrolyte and becomes locked up in LiF, Li₂CO₃, and organic compounds — is permanently lost from the cell inventory. It cannot be returned to the cathode.

This is why the capacity measured in the first discharge of a freshly assembled lithium-ion full cell is always **lower** than the capacity delivered during the first charge: some of the lithium that left the cathode and arrived at the anode was consumed by SEI formation rather than being stored reversibly in the graphite. The ratio of charge extracted in the first discharge to the charge put in during the first charge is called the **first-cycle Coulombic efficiency** (or **initial Coulombic efficiency**, ICE), and it is typically 85–95% for graphite anodes. The 5–15% deficit represents lithium permanently consumed by SEI formation.

For hard carbon anodes in sodium-ion batteries, the initial Coulombic efficiency is often even lower — 75–85% — partly because hard carbon has a much higher surface area than crystalline graphite (more surface for the SEI to form on) and partly because the SEI chemistry in carbonate-ester electrolytes with NaPF₆ is less well-controlled than the analogous lithium system. Improving the ICE of hard carbon is an active area of sodium-ion battery research.

A worked example is worth walking through. Consider a graphite electrode designed to hold 10 mAh of reversible capacity (at a practical 350 mAh/g, that is about 28 mg of graphite). An initial Coulombic efficiency of 92% means that of the lithium delivered during the first charge, 8% — roughly 0.8 mAh-equivalent of lithium — is permanently consumed by SEI formation. In a full cell, that lithium comes from the cathode, so the cell's usable capacity is set not by the cathode's capacity and not by the anode's capacity but by *whichever is smaller after subtracting the first-cycle loss*. This is why commercial cells are routinely built with a small excess of either cathode or anode, and why "cathode prelithiation" and "anode prelithiation" (adding a sacrificial lithium source to compensate) are active areas of industrial development. For hard carbon in a sodium-ion cell with an ICE of 80%, the same accounting gives a 20% first-cycle loss — two-and-a-half times worse — and the motivation for sodium-specific prelithiation strategies becomes sharp.

### The SEI as a Degradation Mechanism

The SEI is not static. With every charge-discharge cycle, the graphite electrode expands and contracts slightly as lithium inserts and de-inserts. This mechanical breathing — roughly 10% volume change for graphite — stresses the SEI. The SEI can crack where the electrode surface expands rapidly. Fresh electrode surface is exposed. Fresh electrolyte contacts that surface. More SEI grows to re-passivate it. More lithium is consumed. The SEI grows thicker.

Over hundreds of cycles, this continuous SEI growth consumes a slowly increasing fraction of the lithium inventory. Capacity fades — not because the electrode materials have degraded, but because the total amount of "free" cyclable lithium in the system decreases. This mechanism — **loss of lithium inventory (LLI)** — is one of the three fundamental degradation modes we will study in Chapter 7, and SEI growth is its primary driver in most commercial cells.

There is also a calendar aging component: even when the cell is sitting idle (especially at high SOC or elevated temperature), the SEI continues to grow slowly because the graphite remains at low potential and there is always thermodynamic drive to reduce the electrolyte. This is why high-SOC storage accelerates calendar aging. In Chapter 7 we will quantify SEI thickness growth with the parabolic law $\delta_\text{SEI}(t) \propto \sqrt{t}$ — a classical diffusion-limited passivation kinetics that shows up in everything from rusting iron to growing silicon oxides on microchips, and that predicts the characteristic $\sqrt{t}$-shaped calendar-fade curves you will see on datasheets. For now, hold onto the idea that SEI growth is the dominant mechanism behind that curve.

---

## 2.4 The Electric Double Layer and Double-Layer Capacitance

When an electrode surface is in contact with an electrolyte, something interesting happens at the interface even when no faradaic (redox) reaction is occurring. Charges redistribute. A structured arrangement of ions and solvent molecules forms at the surface. This structure is called the **electric double layer (EDL)**, and it has a capacitance associated with it that is measurable, important, and very much analogous to a capacitor in a circuit.

### The Physics of the Double Layer

Imagine the surface of a graphite electrode at some potential, say 0.1 V vs. Li/Li⁺. The electrode surface has an excess of negative charge (electrons in the graphene layers). This excess negative charge on the electrode surface attracts positive ions (Li⁺) from the electrolyte and repels negative ions (PF₆⁻). The positive ions accumulate near the electrode surface, forming a dense layer of positive charge. This layer of charge on the electrode surface paired with the layer of positive ions in the electrolyte is the "double layer."

More precisely, the structure has two regions. The **inner Helmholtz plane (IHP)** marks the distance of closest approach of specifically adsorbed ions or solvent molecules to the electrode surface — essentially a monolayer of material directly in contact with the electrode. The **outer Helmholtz plane (OHP)** is the distance of closest approach for solvated (hydration-shell–intact) ions in the solution. Beyond the OHP lies the **diffuse layer** (Gouy-Chapman layer), a region where the ion concentration transitions gradually from the high value near the electrode back to the bulk electrolyte concentration. The full EDL model incorporating all three regions was developed by Stern in the 1920s.

For our purposes, the crucial observation is simpler: charge is separated across a very thin layer (roughly 0.5–5 nm), and this charge separation has a capacitance associated with it. The thin layer acts exactly like the dielectric in a parallel-plate capacitor. The capacitance is:

$$C_\text{dl} = \frac{\varepsilon_r \varepsilon_0 A}{d} \tag{2.1}$$

where $\varepsilon_r$ is the relative permittivity of the medium in the double layer, $\varepsilon_0 = 8.854 \times 10^{-12}$ F/m is the permittivity of free space, $d$ is the effective thickness of the double layer, and $A$ is the electrode area.

Because $d$ is so small — a few nanometres — and the electrode area in a porous battery electrode is enormous (20–100 m²/g of electrode material, summing over all the particle surfaces), the double-layer capacitance per unit area is very high: typically 10–40 µF/cm² of real electrode area, or 5–20 F per gram of electrode material. For a full battery cell with tens of grams of electrode, this amounts to tens of farads of capacitive storage. That is not a small number: it is six orders of magnitude beyond a typical ceramic capacitor and three orders of magnitude beyond a bulk electrolytic capacitor of comparable physical size. It is in fact comparable to a commercial supercapacitor — which is no coincidence, because the same double-layer phenomenon is what makes supercapacitors work. This double-layer capacitance is the physical basis of **electrochemical double-layer capacitors (EDLCs)**, also called supercapacitors or ultracapacitors, which store energy purely in the EDL without any faradaic reaction.

In a battery, the double-layer capacitance is present in parallel with the faradaic (redox) reaction. When current changes suddenly — say, when a load is suddenly applied — the double-layer capacitor charges or discharges first, providing an instantaneous current, while the slower faradaic reaction builds up. This is why the voltage response of a battery to a current step shows an immediate ohmic drop (from the electrolyte and contact resistance) followed by a curved exponential approach to a steady state — the characteristic RC response of a capacitor charging.

This is the first of many places where your EE background maps directly onto battery physics. The double-layer capacitance $C_\text{dl}$ in series with a charge-transfer resistance $R_\text{ct}$ forms an RC circuit with a time constant $\tau = R_\text{ct} C_\text{dl}$ that governs how quickly the electrode responds to perturbations. We will quantify this time constant in Section 2.5 and again in Chapter 3 when we discuss electrochemical impedance spectroscopy.

---

## 2.5 Charge Transfer Kinetics at the Electrode–Electrolyte Interface

So far we have discussed what reactions occur at electrodes (half-reactions), where they occur (electrode–electrolyte interface, after the ion crosses the double layer), and what passivation film sits in the way (the SEI). Now we need to ask: how fast do they proceed? Thermodynamics tells us the direction and equilibrium state; kinetics tells us the rate.

This next idea took me a while to get comfortable with, so let us go slowly.

### The Activation Energy Barrier

Every chemical reaction — including the electrode half-reaction — has to get over an **activation energy barrier**. Think of the reaction coordinate as a landscape of potential energy: the reactants sit at one energy level, the products sit at a lower energy level (for a spontaneous reaction), and between them is a hill — the transition state. The reaction can only proceed if the reactants have enough thermal energy to climb over the hill.

For an electrode reaction like:

$$\text{Li}^+(\text{solv}) + e^- \rightarrow \text{Li}(\text{in graphite})$$

the activation energy is the energy required to strip the solvation shell off the Li⁺ ion (desolvation), transport it across the double layer, and incorporate it into the graphite lattice. Each of these steps has its own energy barrier. The overall rate is dominated by the slowest step.

The Arrhenius law for the rate constant of a chemical reaction is:

$$k = A \exp\left(-\frac{E_a}{RT}\right) \tag{2.2}$$

where $E_a$ is the activation energy, $A$ is a pre-exponential factor, $R$ is the gas constant, and $T$ is absolute temperature. This exponential dependence on temperature explains one of the most practically important observations about batteries: at low temperature, charge transfer kinetics slow down exponentially, and the cell's power capability drops dramatically. A lithium-ion cell at $-20$°C may deliver only 30–50% of its room-temperature capacity at moderate discharge rates, not because there is less lithium in the electrodes but because the kinetics of lithium desolvation and transfer are sluggish.

### The Effect of Electrode Potential on Kinetics

Here is where electrode kinetics becomes richer than simple chemical kinetics: the rate of the electrode reaction is also controlled by the electrode potential, not just temperature. Changing the electrode potential changes the energy of the electrons at the electrode surface, which changes the relative heights of the activation energy barrier in the forward (reduction) and reverse (oxidation) directions.

Specifically: if you make the electrode more negative (more reducing potential, more electrons available), you lower the activation barrier for the reduction reaction and raise it for the oxidation reaction. More positive potential does the opposite. The quantitative question is: *how much* of an applied potential change goes into lowering the forward barrier, and how much goes into raising the reverse one? That fractional split is exactly what the **transfer coefficient** $\alpha$ encodes. If $\alpha = 0.5$, half of any potential change you impose lowers the forward barrier and half raises the reverse one — the reaction is perfectly symmetric with respect to the direction of driving. If $\alpha = 0.7$, 70% of the applied potential goes into lowering the forward barrier, and the reaction is asymmetric: it responds more vigorously to forward driving than to reverse driving. The classical picture of why $\alpha$ ends up near 0.5 for most electrode reactions comes from a parabolic Marcus-theory cartoon of the reactant and product energy wells, which we will draw properly in the later derivation chapter. For now, take $\alpha \approx 0.5$ as the default and treat it as the knob that tilts the two exponentials in opposite directions. This asymmetry is what gives rise to the exponential current-voltage characteristic of an electrode.

The potential applied to an electrode relative to its equilibrium (Nernst) potential is called the **overpotential** $\eta$:

$$\eta = E - E_\text{eq} \tag{2.3}$$

where $E$ is the actual electrode potential and $E_\text{eq}$ is the equilibrium (open-circuit) potential for that electrode at the current composition, from the Nernst equation. When $\eta < 0$ (the electrode is driven more negative than its equilibrium), the reduction reaction is favoured. When $\eta > 0$, the oxidation reaction is favoured.

The overpotential is the "driving force" for the electrode reaction, analogous to the voltage above a diode's threshold that drives current through it. A small overpotential produces a small current. A large overpotential produces an exponentially larger current. This nonlinear relationship is the Butler-Volmer equation, which we will introduce in Section 2.8.

---

## 2.6 Mass Transport: Diffusion, Migration, and Convection

Even if charge transfer at the electrode surface were infinitely fast, the cell's rate capability would still be limited by how quickly ions can be delivered to (or removed from) the electrode surface. This is the domain of **mass transport** — the movement of species through the electrolyte and within the electrode materials.

There are three mechanisms of mass transport, and each dominates in a different regime. Understanding them separately — and then together — is essential to understanding power limitations, impedance spectra, and the shapes of voltage curves under load.

### Diffusion

**Diffusion** is the motion of a species from regions of high concentration to regions of low concentration, driven by the concentration gradient. It is governed by Fick's laws.

**Fick's First Law** states that the molar flux $J$ (mol m⁻² s⁻¹) of a species is proportional to its concentration gradient:

$$J = -D \frac{\partial c}{\partial x} \tag{2.4}$$

where $D$ is the **diffusion coefficient** (m²/s) and $c$ is the concentration (mol/m³). The negative sign captures the physical intuition: flux is from high to low concentration, opposite the gradient.

**Fick's Second Law** gives the time evolution of concentration:

$$\frac{\partial c}{\partial t} = D \frac{\partial^2 c}{\partial x^2} \tag{2.5}$$

This is a parabolic partial differential equation — mathematically identical to the heat equation, which you likely encountered in undergraduate mathematics. The analogy is deep: diffusion of mass is governed by the same mathematical structure as diffusion of heat, with the diffusion coefficient $D$ playing the role of thermal diffusivity $\alpha$. If you have solved heat diffusion problems in a slab or cylinder, you already know how to solve battery diffusion problems.

From a circuits perspective, diffusion in one dimension has an equivalent circuit representation: the **Warburg impedance**, a distributed RC ladder network. In a semi-infinite uniform medium, the Warburg impedance goes as $Z_W \propto (j\omega)^{-1/2}$ — a 45-degree phase angle in the impedance plane, distinct from a pure resistor (0°) or capacitor (90°). This 45-degree signature appears in electrochemical impedance spectra and is a diagnostic fingerprint for diffusion-limited processes.

#### The Diffusion Time Constant

How long does diffusion take? The characteristic time for a diffusing species to travel a distance $L$ is:

$$\tau_\text{diff} = \frac{L^2}{D} \tag{2.6}$$

This is the most useful single formula for estimating whether diffusion is limiting a battery process. Let us plug in some numbers.

Lithium-ion diffusion coefficient in liquid electrolyte: $D_{\text{Li}^+} \approx 10^{-10}$ m²/s. Thickness of a typical battery electrode: $L \approx 100$ µm = $10^{-4}$ m. Diffusion time:

$$\tau = \frac{(10^{-4})^2}{10^{-10}} = \frac{10^{-8}}{10^{-10}} = 100 \text{ s}$$

One hundred seconds. Interpreting this: at a 1C rate the cell discharges in 3600 s, so diffusion is comfortably fast relative to the discharge; at a 36C rate (full discharge in 100 s) diffusion and discharge share the same timescale, and liquid-phase transport starts to limit the cell. That is the naive estimate.

In practice it is wrong by about an order of magnitude, in the direction that matters. A real battery electrode is not a block of free electrolyte — it is a porous matrix of electrode particles with the electrolyte filling the pore space at roughly 30–40% porosity, and the ions must follow a tortuous path around the particles rather than a straight line. The effective diffusion coefficient is $D_\text{eff} = D \cdot \varepsilon / \tau_\text{tort}$, with $\varepsilon \approx 0.35$ and the tortuosity factor $\tau_\text{tort} \approx 3$ for a typical electrode. That drops $D_\text{eff}$ to roughly $10^{-11}$ m²/s and pushes the diffusion time up to about 1000 s. Concentration polarisation accordingly starts biting at ~3–5C in a well-designed electrode, not 36C — a number you will encounter in essentially every datasheet. We will meet this Bruggeman correction again in later chapters when we look at the Doyle-Fuller-Newman model; file the intuition for now.

Diffusion in the solid electrode material is typically much slower. For Li⁺ in LCO: $D_s \approx 10^{-14}$ m²/s. For a 5 µm radius particle ($L = 5 \times 10^{-6}$ m):

$$\tau = \frac{(5 \times 10^{-6})^2}{10^{-14}} = \frac{2.5 \times 10^{-11}}{10^{-14}} = 2{,}500 \text{ s} \approx 42 \text{ min}$$

Solid-state diffusion in the electrode particles takes tens of minutes. This is why high-rate capability requires either small particles (reduce $L$) or materials with high $D_s$. The solid-state diffusion time constant is often the limiting factor in fast charging, not the liquid-phase transport.

It is worth running the same calculation for a sodium-ion analogue to see where the numbers land. Published Na⁺ diffusion coefficients in P2-type $\text{Na}_{2/3}\text{MnO}_2$ and $\text{Na}_{2/3}[\text{Ni}_{1/3}\text{Mn}_{2/3}]\text{O}_2$ cathodes cluster around $D_s \approx 10^{-13}$ to $10^{-14}$ m²/s at room temperature — in the same order-of-magnitude band as Li⁺ in LCO, but typically at the slower end. For a 5 µm particle with $D_s = 10^{-14}$ m²/s we reproduce the 2,500-second estimate from the LCO calculation; for $D_s = 3 \times 10^{-14}$ m²/s (a good P2 cathode) it drops to about 800 seconds. The take-away: solid-state diffusion is the rate limit in SIB cathodes too, and the engineering response is the same — make the particles small. This is why almost every commercial SIB cathode powder you will see quoted in the literature has a D50 particle size in the 1–5 µm range, matched against precisely the same diffusion time-constant argument we just walked through for LCO. When you read your first SIB cathode paper and see a figure showing "rate capability vs. particle size," you will already know what physics is being probed.

Liquid-phase diffusion in SIB electrolytes is broadly comparable to Li-ion: $D_{\text{Na}^+} \approx 10^{-10}$ m²/s in typical carbonate solvents, with somewhat lower absolute values than Li⁺ in the same solvent because the Na⁺ ion drags a larger solvation shell. The Bruggeman-corrected diffusion time across a 100 µm porous electrode is therefore also about 1000 s, and the practical C-rate ceiling before concentration polarisation dominates sits in the same 3–5C neighbourhood. The transport physics of the two chemistries is quantitatively similar; the important differences are in the solid-state kinetics and the interfacial chemistry, not the liquid transport.

### Migration

**Migration** is the directed motion of charged species in an electric field. In the electrolyte, both Li⁺ and PF₆⁻ ions experience the electric field set up by the potential difference across the cell, and they drift in opposite directions: Li⁺ toward the anode (which is negative during discharge), PF₆⁻ toward the cathode.

The migration flux of species $i$ is:

$$J_{\text{mig},i} = -z_i \frac{F}{RT} D_i c_i \frac{\partial \phi}{\partial x} \tag{2.7}$$

where $z_i$ is the charge number of the species, $\phi$ is the electric potential, and the other symbols have their usual meanings. The full expression for the total flux of a charged species combines diffusion and migration:

$$J_i = -D_i \frac{\partial c_i}{\partial x} - z_i \frac{F}{RT} D_i c_i \frac{\partial \phi}{\partial x} \tag{2.8}$$

This is the **Nernst-Planck equation** — one of the foundational equations of electrochemical transport. Notice that it contains both Fick's law (first term) and an electric field driving term (second term). In a battery, both terms are generally active simultaneously.

An important practical point: in the electrolyte, only a fraction of the total ionic current is carried by Li⁺. The rest is carried by the anion (PF₆⁻). The fraction of current carried by Li⁺ is called the **transference number** $t_+$, and for typical LIB electrolytes, $t_+ \approx 0.35$–$0.4$. This means that 60–65% of the ionic current in the electrolyte is carried by the bulky, non-reactive PF₆⁻ anion. Only the Li⁺ current matters for the electrode reaction, so the effective capacity for ion delivery to the electrode is lower than the total ionic conductivity would suggest.

Low transference number is also the origin of **concentration polarisation**. Here is the physical picture. Both Li⁺ and PF₆⁻ carry current in the electrolyte, but only Li⁺ is consumed at the cathode and generated at the anode — PF₆⁻ is electrochemically inert at both electrodes. If $t_+$ were equal to 1, Li⁺ migration alone would deliver exactly the current the reaction demands. Because $t_+ \approx 0.4$, migration under-supplies Li⁺ at the consuming electrode and over-supplies at the generating electrode, and the shortfall must be made up by *diffusion of the whole salt* — Li⁺ and PF₆⁻ moving together to preserve electroneutrality. This is why, under load, the salt concentration builds up near the anode (during discharge) and falls near the cathode. The resulting concentration gradient across the separator and electrodes limits rate capability, causes the voltage to sag more severely at high current, and is one of the reasons electrolytes with higher $t_+$ (a long-standing goal of polymer and single-ion-conductor research) are so eagerly pursued.

### Convection

**Convection** is transport due to bulk fluid motion. In most battery cells, there is no externally driven flow — the electrolyte is not being pumped or stirred. However, small density-driven convection can occur due to concentration gradients, and gas evolution (from side reactions) can drive convective mixing. In most battery models and for most operating conditions, convection in the electrolyte is neglected. It does play a role in flow batteries (redox flow cells) where electrolyte is actively circulated, but that is outside our scope here.

---

## 2.7 Kinetic vs. Transport Limitations — Which Dominates When

We now have two distinct mechanisms that can limit the rate of a battery: **charge transfer kinetics** (the electrode reaction rate, governed by the Butler-Volmer equation and activation energy) and **mass transport** (diffusion and migration of ions to and from the reaction site). Understanding which one dominates under what conditions is crucial for interpreting performance data, choosing appropriate models, and diagnosing degradation.

### The Two Types of Overpotential

The voltage loss (compared to the thermodynamic open-circuit voltage) in a real operating cell can be separated into contributions from different physical processes:

**Ohmic overpotential** ($\eta_\Omega$): The voltage drop across the purely resistive elements of the cell — the electrolyte ionic resistance, the electronic resistances of the electrode matrices and current collectors, and the contact resistances at interfaces. This is instant and current-proportional: $\eta_\Omega = IR_\Omega$. When current stops, this overpotential vanishes immediately.

**Activation overpotential** ($\eta_\text{act}$): The extra potential needed to drive the electrode half-reaction at a finite rate, above and beyond the equilibrium potential. This arises from the kinetic barrier at the electrode surface (Section 2.5). It follows the Butler-Volmer equation (nonlinear in general, logarithmic at high overpotential — the **Tafel region**). When current stops, this overpotential decays on the timescale of the double-layer $RC$ time constant — typically milliseconds to seconds.

**Concentration overpotential** ($\eta_\text{conc}$): The change in the electrode potential caused by concentration gradients that develop when the rate of ion consumption at the electrode surface exceeds the rate of ion supply by diffusion. This can be thought of as a local Nernst shift: the ion concentration at the electrode surface is lower (for the cathode during discharge) than in the bulk electrolyte, so the local Nernst equation gives a lower potential than the bulk would predict. When current stops, this overpotential decays on the diffusion time constant — typically seconds to minutes.

These three contributions add to give the total overpotential:

$$\eta_\text{total} = \eta_\Omega + \eta_\text{act} + \eta_\text{conc} \tag{2.9}$$

And the terminal voltage of a discharging cell is:

$$V_\text{terminal} = E_\text{OCV} - \eta_\text{total} \tag{2.10}$$

(For a charging cell, $V_\text{terminal} = E_\text{OCV} + \eta_\text{total}$, since overpotentials always oppose the reaction.)

### A Note on Charge/Discharge Symmetry

Everything we have said so far has implicitly assumed a discharging cell. The language has reflected this: "voltage sag," "voltage drop under load," "the cathode during discharge," and so on. Before we go further, it is worth pausing to make the symmetry explicit, because a surprising amount of later confusion traces back to not having done so.

The physics in this chapter is symmetric under reversal of current direction. The Butler-Volmer equation has two branches, anodic and cathodic, and neither is privileged — which branch dominates depends only on the sign of the overpotential you impose. Diffusion is symmetric: Fick's laws care nothing about which end of a slab is the source and which is the sink. Ohmic resistance is symmetric by definition. The double-layer capacitance charges and discharges with equal facility. The only thing that changes when you flip from discharge to charge is the *sign* of every flux and every overpotential, and which electrode is playing which role.

Concretely: during discharge, Li⁺ flows from the graphite electrode through the electrolyte to the LCO electrode, electrons flow through the external circuit in the same net direction, and the overpotentials on both electrodes conspire to make the terminal voltage *lower* than the OCV ($V_\text{terminal} = E_\text{OCV} - \eta_\text{total}$). During charge, everything reverses. Li⁺ flows from LCO back to graphite, electrons are pumped through the external circuit in the opposite direction by an external power supply, and the overpotentials now conspire to make the terminal voltage *higher* than the OCV ($V_\text{terminal} = E_\text{OCV} + \eta_\text{total}$). Overpotentials always oppose the reaction you are trying to drive — they are a kinetic tax you pay for going faster than equilibrium, and the tax is levied in whichever direction the traffic is moving.

There are two practical asymmetries worth flagging, even though they do not break the underlying symmetry of the equations. First, fast charging is mechanically harder than fast discharging because of lithium plating: if you push Li⁺ into a graphite electrode faster than it can intercalate, the excess Li⁺ reduces to metallic lithium on the graphite surface rather than inserting into the lattice, and that metallic lithium is largely irreversible (and a safety hazard — we will return to it in Chapter 7). There is no analogous failure mode on the discharge side. Second, the concentration polarisation at high C-rate develops in opposite directions on charge and discharge, which means the rate at which you can safely push current may be asymmetric in the two directions for a given cell design. Otherwise, everything you have learned in this chapter about how voltages and overpotentials and time constants behave under load applies equally to charging and discharging. When Chapter 10 asks you to reason about state estimation during regenerative braking in an EV — a scenario in which charge and discharge alternate on a second-by-second timescale — you will lean on this symmetry heavily.

### Identifying Which Dominates

A useful physical heuristic for deciding which limitation dominates:

At **low current rates** (say, C/10 or less), the cell operates close to equilibrium. Both kinetic and diffusion overpotentials are small compared to the thermodynamic driving force. The voltage is close to OCV, and performance is limited by the OCV curve shape, not by kinetics or transport.

At **moderate rates** (1C–3C), activation overpotential begins to matter. The Butler-Volmer equation predicts that $\eta_\text{act}$ grows logarithmically with current once the high-overpotential (Tafel) regime is reached, so doubling the current does not double the voltage loss — it adds a fixed logarithmic increment. This regime is kinetically limited.

At **high rates** (above ~3C for typical cells), concentration polarisation becomes dominant. As the current rate increases, the surface concentration of the reacting ion approaches zero long before the electrode is electrochemically exhausted. The voltage drops sharply and the accessible capacity falls. This is the transport-limited regime.

At **low temperatures**, kinetic limitation dominates even at moderate rates, because the Arrhenius factor in the charge-transfer rate constant drops exponentially. Even a C/2 rate at $-20$°C can be transport-limited by the sluggish solid-state diffusion of lithium in the electrode particles (which is also thermally activated).

Diagnostically, these three regimes leave fingerprints in several different experiments, and learning to read them is one of the more transferable skills in battery characterisation. The following table collects the signatures we will rely on throughout the book:

| Property | Ohmic ($\eta_\Omega$) | Kinetic ($\eta_\text{act}$) | Transport ($\eta_\text{conc}$) |
| --- | --- | --- | --- |
| Physical origin | Electron & ion resistance of matrices, electrolyte, contacts | Activation barrier at electrode surface | Concentration gradients in electrolyte and solid |
| Current dependence | Linear in $I$ | Logarithmic in $I$ at high $\eta$ (Tafel) | Strongly nonlinear; saturates at a limiting current |
| Temperature dependence | Weak (metallic conductors slightly worse when hot; electrolyte *better* when hot) | Strong (Arrhenius, exponential in $1/T$) | Moderate (diffusivity Arrhenius, smaller exponent) |
| Timescale under a step | Instantaneous (≪ 1 ms) | RC time of double layer: ms to s | Diffusion time $L^2/D$: s to minutes |
| EIS signature | High-frequency intercept on real axis | Semicircle (parallel $R_\text{ct}$, $C_\text{dl}$) | 45° Warburg line at low frequency |
| Dominant regime | Always present | Low T, moderate C-rate | High C-rate, low T (solid-state) |

The bottom row — "when does each dominate" — deserves a separate sentence because it cuts against a common intuition. Transport limitation and kinetic limitation both get worse at low temperature, but *not because the underlying coefficients get worse by the same factor*. Charge-transfer kinetics fall off roughly as $\exp(-E_a^\text{ct}/RT)$ with $E_a^\text{ct} \approx 50$–$60$ kJ/mol; solid-state diffusion falls off as $\exp(-E_a^D/RT)$ with $E_a^D \approx 20$–$30$ kJ/mol. So cooling from 25°C to $-20$°C hits kinetics harder than diffusion, and the regime that limits a cell at room temperature (often diffusion) may not be the regime that limits it in the cold (often kinetics).

We will use these signatures extensively in Chapter 3 when we discuss characterisation techniques.

---

## 2.8 Introduction to the Butler-Volmer Equation (Intuition Only)

We have been circling the Butler-Volmer equation throughout this chapter: we know it relates current to overpotential at an electrode surface, we know it is nonlinear, and we know it is the kinetic companion to the Nernst equation (which governs equilibrium). Let us now develop enough intuition for it that the full derivation, when it comes, will feel like confirmation of what we already believed.

### The Analogy to a Diode

Consider the current-voltage characteristic of a p-n junction diode. The Shockley diode equation is:

$$I = I_s \left[\exp\left(\frac{V}{V_T}\right) - 1\right] \tag{2.11}$$

where $I_s$ is the reverse saturation current, $V$ is the forward voltage, and $V_T = kT/q$ is the thermal voltage (~26 mV at room temperature). The diode characteristic is exponential for forward bias and saturates at $-I_s$ for reverse bias.

The Butler-Volmer equation has exactly this structure, but for an electrode reaction:

$$i = i_0 \left[\exp\left(\frac{\alpha_a F \eta}{RT}\right) - \exp\left(-\frac{\alpha_c F \eta}{RT}\right)\right] \tag{2.12}$$

where $i$ is the current density (A/m²), $i_0$ is the **exchange current density** (A/m²), $\eta = E - E_\text{eq}$ is the overpotential, and $\alpha_a$ and $\alpha_c$ are the **anodic and cathodic transfer coefficients**, with $\alpha_a + \alpha_c = 1$ (and often $\alpha_a = \alpha_c = 0.5$ for symmetric reactions).

Compare equations (2.11) and (2.12):

- Both are exponential in the driving voltage.
- The Shockley equation has one exponential term (for carriers crossing one direction). The Butler-Volmer has two: one for the forward (anodic, oxidation) direction and one for the reverse (cathodic, reduction) direction.
- The thermal voltage $kT/q$ in the diode plays the role of $RT/F$ in Butler-Volmer (these are the same quantity per electron: $kT/q = RT/(N_A q) = RT/F$).
- The saturation current $I_s$ in the diode plays the role of the exchange current $i_0$ in Butler-Volmer.

The **exchange current density $i_0$** deserves special attention. It is the current density flowing in each direction (forward and reverse) when the electrode is exactly at its equilibrium potential ($\eta = 0$). At equilibrium, the forward and reverse reactions are balanced and there is no net current — but they are not static. Lithium ions are continuously being reduced into the graphite and continuously being oxidised back out, at equal rates. The exchange current density is the magnitude of these balanced fluxes. A high $i_0$ means the electrode reaction is facile — small overpotentials drive large currents. A low $i_0$ means the reaction is sluggish — large overpotentials are needed to drive even modest currents.

### The Four Regimes of Butler-Volmer

Let us examine the Butler-Volmer equation qualitatively in each of four regimes:

**Near equilibrium** ($|\eta| \ll RT/F \approx 26$ mV at room temperature): Both exponentials can be linearised using $e^x \approx 1 + x$ for small $x$. Assuming $\alpha_a = \alpha_c$ for a symmetric reaction (and noting $\alpha_a + \alpha_c = 1$, so each coefficient is $\tfrac{1}{2}$):

$$i \approx i_0 \left[\left(1 + \frac{\alpha_a F\eta}{RT}\right) - \left(1 - \frac{\alpha_c F\eta}{RT}\right)\right] = i_0 \cdot \frac{(\alpha_a + \alpha_c) F\eta}{RT} = i_0 \cdot \frac{F\eta}{RT}$$

The constant terms cancel, the two linear terms *add* (note the minus signs on the second exponential and on the second $\alpha$ both flipping), and the transfer coefficients conveniently sum to one. The electrode behaves like a linear resistor:

$$R_\text{ct} = \frac{RT}{i_0 F A} \tag{2.13}$$

where $A$ is the electrode area. This is the **charge-transfer resistance** that appears in the equivalent circuit model and in impedance spectra. Notice that $R_\text{ct}$ is inversely proportional to $i_0$: a facile electrode (high $i_0$) has low charge-transfer resistance.

**Anodic Tafel regime** ($\eta \gg RT/F$, positive overpotential): The cathodic exponential becomes negligible:

$$i \approx i_0 \exp\left(\frac{\alpha_a F \eta}{RT}\right) \tag{2.14}$$

Taking the logarithm: $\ln i = \ln i_0 + \alpha_a F \eta / RT$. A plot of $\ln(i)$ vs. $\eta$ is linear — this is the **Tafel plot**, and its slope $\alpha_a F / RT$ gives the transfer coefficient.

Two practical rules at room temperature, both worth committing to memory. First, with $\alpha = 0.5$, each ~51 mV of additional overpotential multiplies the current by a factor of $e$ (because $RT/(\alpha F) = 0.0257/0.5 \approx 0.0514$ V). Second, the *Tafel slope* — the slope of $\eta$ versus $\log_{10} i$ — is $2.303 RT/(\alpha F) \approx 118$ mV/decade for $\alpha = 0.5$. A Tafel slope of 59 mV/decade, often quoted in electroanalytical textbooks, corresponds to $\alpha = 1$ (full-barrier transfer) and is characteristic of certain outer-sphere redox couples, not of intercalation electrodes. When you see a Tafel slope reported in a paper, the first thing to check is which $\alpha$ it implies.

**Cathodic Tafel regime** ($\eta \ll -RT/F$, negative overpotential): The anodic exponential becomes negligible, and the current saturates (in magnitude) with a similar exponential dependence.

**Concentration-limited regime**: When the current becomes large enough that the surface concentration of the reacting species drops to zero, the concentration term in $i_0$ (which depends on surface concentration) goes to zero, and no further increase in overpotential can increase the current. This is the limiting current, determined by mass transport.

### What $i_0$ Depends On

The exchange current density depends on temperature (Arrhenius), on the surface concentration of the reacting species, and on the electrode material and its surface chemistry (including the SEI). These dependencies are what connect the kinetic picture back to the transport and materials picture:

$$i_0 = F k_0 \, c_{\text{Li}^+}^{\,1-\alpha} \, c_{\text{Li,max}}^{\,\alpha} \, (1-x)^{\alpha} \, x^{1-\alpha} \tag{2.15}$$

where $k_0$ is the rate constant for the electrode reaction, $c_{\text{Li}^+}$ is the Li⁺ concentration in the electrolyte at the electrode surface, $c_{\text{Li,max}}$ is the maximum lithium concentration in the host material, and $x$ is the state of lithiation (fraction of sites occupied). As $x \to 0$ (nearly empty electrode) or $x \to 1$ (nearly full electrode), $i_0 \to 0$ — the electrode reaction slows at the extremes of its composition range, because there are either too few lithium ions in the host to be oxidised or too few vacancies to accept new lithium. This is why cells become harder to charge near full state of charge and harder to discharge near empty state of charge, independent of the Nernst-equation voltage changes.

We will derive the Butler-Volmer equation from first principles in a later chapter, using transition state theory. Before moving on, let us consolidate. Butler-Volmer is the nonlinear current–voltage relationship at an electrode surface — the battery equivalent of the diode equation, with two exponential branches instead of one. The exchange current density $i_0$ sets the overall scale: a facile electrode has high $i_0$, low activation overpotential, and low charge-transfer resistance; a sluggish electrode has the opposite. At small overpotentials the electrode is a linear resistor with $R_\text{ct} = RT/(i_0 F A)$, and at large overpotentials the current grows exponentially in the Tafel regime. Finally, because $i_0$ itself carries an Arrhenius temperature dependence, the electrode kinetics collapse exponentially as the cell cools — and this is the root-cause physical explanation for why batteries lose so much of their power capability in the cold.

---

## Worked Interpretation Exercise: The Voltage Relaxation Experiment

Here is a real experimental observation from a standard battery characterisation test, and we will use the physical concepts from this chapter to interpret it completely.

**The experiment:** A fully charged commercial 18650 layered-oxide/graphite cell (Panasonic NCR18650B, rated 3.0 Ah, nominal voltage 3.6 V) is discharged at a constant 3.0 A (1C) for 600 seconds. Current is then switched off. The following voltage profile is observed:

- Before current starts: $V = 4.16$ V (resting OCV, fully charged)
- Immediately when 3A current starts: voltage drops to 3.97 V (a 190 mV instant drop)
- Voltage continues falling during the 600 s discharge, reaching 3.61 V when current is switched off
- Immediately after current is switched off: voltage jumps from 3.61 V to 3.73 V (a 120 mV instant recovery)
- Over the next 120 seconds, voltage rises slowly from 3.73 V to 3.84 V
- After 600 s of rest, voltage has reached 3.88 V (approximate new OCV)

Let us interpret each feature using the physics from this chapter.

**The 190 mV instant drop at current onset** is the **ohmic overpotential** $\eta_\Omega = IR_\Omega$. With $I = 3$ A and $\eta_\Omega = 0.190$ V, the ohmic resistance is $R_\Omega = 0.190/3 = 63$ mΩ. This ohmic resistance includes the electrolyte ionic resistance, the electronic resistances of the electrodes and current collectors, and the contact resistances — all the truly resistive elements that respond instantaneously.

**The gradual voltage decline during discharge** is the build-up of activation overpotential ($\eta_\text{act}$, which rises as the electrode surfaces become more chemically perturbed) and concentration overpotential ($\eta_\text{conc}$, which grows as concentration gradients develop across the electrodes and separator). The Nernst-equation change (OCV decreasing as SOC decreases) is also included in this gradual decline — distinguishing kinetic and thermodynamic contributions requires a separate OCV measurement, which is why GITT (Section 3.10) is needed for clean characterisation.

**The 120 mV instant recovery at current switch-off** is the immediate disappearance of the ohmic overpotential. The current is zero; $\eta_\Omega = IR_\Omega = 0$ instantly. Notice, though, that the instant recovery (120 mV) is smaller than the instant drop (190 mV) at current onset. The ohmic resistance itself has not changed — a 63 mΩ resistance at $t=0$ is still 63 mΩ at $t=600$ s. What has changed is the OCV. During 600 s of 3 A discharge we extracted $Q = 3.0 \text{ A} \times 600 \text{ s} = 1800 \text{ C}$ of charge, which is $1800/3600 = 0.5$ Ah out of a 3.0 Ah cell — roughly 17% of the cell's capacity, or a ΔSOC of about 0.17. For a layered-oxide/graphite 18650 cell in the high-SOC region, the OCV slope is roughly 400 mV per full SOC swing, so a 0.17 ΔSOC corresponds to an OCV drop of about $0.17 \times 0.4 \approx 70$ mV. That 70 mV is exactly the difference between the 190 mV instant drop at current onset and the 120 mV instant recovery at current switch-off. The arithmetic reconciles to within the rounding of our reading precision, and we have extracted two separate quantities — $R_\Omega$ and $dV_\text{OCV}/d\text{SOC}$ — from what looked like a single voltage trace.

**The slow 110 mV recovery over 600 s** is the relaxation of the activation and concentration overpotentials. The fast component (milliseconds to seconds, barely visible in this data) is the RC discharge of the double-layer capacitance — the activation overpotential decays as the electrode surfaces return to equilibrium. The slow component (seconds to minutes) is the diffusion of lithium ions re-equilibrating their concentration gradients across the electrodes and separator. The fact that this takes several minutes confirms our earlier estimate that diffusion across a 100 µm electrode layer (with the Bruggeman correction) takes on the order of a few hundred to a thousand seconds.

**The new OCV at 3.88 V rather than 4.16 V** simply reflects that the cell has been partially discharged. The OCV is lower because the cathode has been lithiated further (lower potential) and the anode has been delithiated (higher potential, but less — in a layered-oxide/graphite cell, the voltage change in this region is dominated by the positive-electrode OCV slope).

By interpreting a single voltage relaxation trace, we have identified the ohmic resistance (63 mΩ), confirmed the presence of activation and diffusion overpotentials, observed their different time constants, and read off the OCV change due to discharge. This kind of physical interpretation is what battery engineers do every day, and it relies entirely on the framework developed in this chapter.

---

## What Changes for Sodium-Ion?

The physics of this chapter — intercalation, SEI, double-layer capacitance, Butler-Volmer, diffusion — all apply equally to sodium-ion batteries. But several parameters take different values, and a few mechanisms are qualitatively different.

**Intercalation hosts change significantly.** As we saw in Section 2.1, graphite does not work as an anode for sodium. The Na⁺ ion is 34% larger than Li⁺, and the stage-1 graphite intercalation compound (LiC₆) has no stable sodium analogue at room temperature and ambient pressure. Hard carbon — disordered, non-graphitic carbon with nanopore spaces and turbostratic layer spacing — is the SIB anode of choice. Its intercalation mechanism involves two distinct processes (the slope region and the plateau region), and the voltage profile looks fundamentally different from graphite.

**The SEI chemistry differs.** The SEI on hard carbon in sodium-ion electrolytes (NaPF₆ or NaClO₄ in EC:DMC or ether-based solvents) has a different composition from the lithium analogue. NaF and sodium carbonates dominate in some electrolytes; ether-based electrolytes form thinner, more stable SEIs. The initial Coulombic efficiency of hard carbon (typically 75–85%) is notably lower than graphite (85–95%), partly because hard carbon's larger surface area (typically 5–15 m²/g versus 1–5 m²/g for graphite) provides more surface area for SEI formation.

**Solid-state diffusion coefficients are generally lower.** Na⁺ has a lower solid-state diffusion coefficient than Li⁺ in most cathode materials, and the reason is straightforward: Na⁺ is larger, and it must squeeze through the same narrow migration bottlenecks in the host lattice that Li⁺ slips through comfortably. In polyanionic frameworks with tight channels, the penalty can be one to two orders of magnitude. In more open layered oxides — especially P2-type Na cathodes with their prismatic coordination — the Na⁺ diffusivity can be comparable to Li⁺ in layered Li oxides. The effect is not universal but it is the way to bet.

**Exchange current densities differ, but not in the direction you might guess.** Naively, the smaller Li⁺ should desolvate faster at the electrode surface and therefore give a larger $i_0$. The trend is actually the opposite: Li⁺ has a much higher charge density than Na⁺ (ionic radii ≈ 0.76 Å vs. 1.02 Å), binds carbonate solvent molecules more tightly, and so carries a larger desolvation penalty at the interface. This is one reason sodium-ion cells often retain more of their room-temperature power at sub-zero temperatures than lithium-ion cells — the Arrhenius factor still bites, but the activation barrier it multiplies is smaller. Whether the net exchange current density is higher or lower than for a comparable Li system depends strongly on the cathode material, the electrolyte, and the interphase chemistry; the literature is genuinely mixed. The important takeaway is not the sign of the comparison but that any Li-ion intuition you carry about charge-transfer kinetics needs to be re-derived for Na systems, not copied across.

We will return to all of these differences systematically in Chapters 6 and 13. The key point for now is: the framework established in this chapter is universal, but the specific numbers and some qualitative features differ, and those differences matter for modelling, BMS design, and degradation.

---

## Chapter Summary

**Key ideas:**

- Intercalation is the reversible insertion of guest ions into a crystalline host without destroying the host structure. It is what makes lithium-ion (and sodium-ion) batteries rechargeable. The major intercalation host structure families — layered oxide, spinel, olivine/polyanionic — differ in dimensionality of ion diffusion, voltage profile shape (flat plateau vs. sloping), and thermal stability.
- The SEI is a passivation film that forms on electrode surfaces where the electrode potential falls outside the electrochemical stability window of the electrolyte. It is self-limiting once it becomes thick enough to block electron tunnelling. It provides long-term passivation but consumes irreversible lithium (or sodium) inventory during formation and with each cycle, and is the primary cause of capacity fade via loss of lithium inventory.
- The electric double layer acts as a capacitor at the electrode–electrolyte interface, with a capacitance of 10–40 µF/cm² of real electrode area. Combined with the charge-transfer resistance, it forms an RC circuit with a characteristic time constant. The double-layer capacitance is the origin of the instant voltage drop-and-recovery at current transitions.
- Charge transfer kinetics at the electrode surface follow the Butler-Volmer equation — a diode-like exponential I-V relationship. The exchange current density $i_0$ sets the scale; high $i_0$ means low activation overpotential. $i_0$ decreases exponentially with temperature (Arrhenius), explaining cold-weather power loss.
- Mass transport occurs via diffusion (Fick's laws, Warburg impedance, time constant $\tau = L^2/D$), migration (Nernst-Planck), and convection (negligible in most cells). Solid-state diffusion in electrode particles is typically 4–6 orders of magnitude slower than liquid-phase diffusion and is often the rate-limiting transport process. Porous-electrode tortuosity (Bruggeman correction) slows liquid-phase transport by roughly another order of magnitude relative to free-solution values.
- Three types of overpotential cause voltage to deviate from OCV under load: ohmic (instantaneous, IR), activation (logarithmic, exponential decay on RC timescale), and concentration (develops over diffusion timescale, slow to recover). Their signatures in voltage relaxation experiments are distinct, and all three apply symmetrically to charge and discharge — only the signs flip.

**Key equations:**

$$C_\text{dl} = \frac{\varepsilon_r \varepsilon_0 A}{d} \quad \text{(double-layer capacitance)} \tag{2.1}$$

$$J = -D \frac{\partial c}{\partial x} \quad \text{(Fick's First Law)} \tag{2.4}$$

$$\frac{\partial c}{\partial t} = D \frac{\partial^2 c}{\partial x^2} \quad \text{(Fick's Second Law)} \tag{2.5}$$

$$\tau_\text{diff} = \frac{L^2}{D} \quad \text{(diffusion time constant)} \tag{2.6}$$

$$i = i_0 \left[\exp\!\left(\frac{\alpha_a F \eta}{RT}\right) - \exp\!\left(-\frac{\alpha_c F \eta}{RT}\right)\right] \quad \text{(Butler-Volmer)} \tag{2.12}$$

$$R_\text{ct} = \frac{RT}{i_0 F A} \quad \text{(charge-transfer resistance, linear regime)} \tag{2.13}$$

$$V_\text{terminal} = E_\text{OCV} - \eta_\Omega - \eta_\text{act} - \eta_\text{conc} \quad \text{(terminal voltage, discharge)} \tag{2.10}$$

**Key vocabulary (in order of appearance):**

Intercalation, host material, guest ion, hard carbon, layered oxide, spinel, olivine, polyanionic, two-phase reaction, single-phase reaction, solid-electrolyte interphase (SEI), passivation, loss of lithium inventory (LLI), first-cycle Coulombic efficiency, initial Coulombic efficiency (ICE), electric double layer (EDL), Helmholtz plane, diffuse layer, double-layer capacitance, overpotential, activation energy, transfer coefficient, exchange current density, charge-transfer resistance, Fick's laws, diffusion coefficient, Nernst-Planck equation, transference number, Warburg impedance, Bruggeman correction, ohmic overpotential, activation overpotential, concentration overpotential, Butler-Volmer equation, Tafel regime.

---

## Deliverable

**Task:** Draw a labeled diagram of a Li-ion cell during discharge showing ion flow, electron flow, and where each loss mechanism occurs.

**Guidance:** Your diagram should show, at minimum: the copper current collector, the graphite anode (with SEI layer on its surface), the separator (porous polymer), the LCO cathode, the aluminum current collector, the external circuit (with a load), and the electrolyte filling the pores and separator. Arrows should indicate:

1. Direction of electron flow in the external circuit (from graphite to LCO — conventional current flows the opposite way)
2. Direction of Li⁺ flow in the electrolyte (from graphite, through separator, to LCO)
3. Location of ohmic drop (across the electrolyte and electrode matrices)
4. Location of activation overpotential (at the electrode–electrolyte interface, both sides)
5. Location of concentration overpotential (within the electrode pore electrolyte and at electrode surfaces)
6. Location of interphases: SEI on the graphite surface and the cathode-electrolyte interphase (CEI) on the positive-electrode surface

A partial ASCII sketch to get you started — annotate and extend this:

```text
  e⁻ →→→→→→→→→→→→→→→→→→→→→→→→→→→→
  |                                  |
[Cu] ─[Graphite│SEI│Electrolyte│Separator│Electrolyte│LCO]─ [Al]
                                                              |
                Li⁺ →→→→→→→→→→→→→→→→→→→→→→→→→→→→→→→→→→→ 
  
  ηΩ: distributed across electrolyte
  ηact: at graphite/electrolyte interface + at LCO/electrolyte interface
  ηconc: gradient across 100 µm electrode thickness (both electrodes)
```

On your diagram, also annotate which processes are slower (diffusion in solid — minutes) vs. faster (activation overpotential — milliseconds) vs. instantaneous (ohmic).

---

## Further Reading

1. **Huggins, R. A., *Advanced Batteries: Materials Science Aspects*, Springer (2009), Chapters 3–4.** Huggins is exceptional on the physical meaning of intercalation, the thermodynamics of solid-solution reactions versus two-phase reactions, and the connection between crystal structure and voltage profile shape. Chapters 3–4 are the direct complement to Sections 2.1 and 2.2 of this chapter.

2. **Newman, J. and Thomas-Alyea, K. E., *Electrochemical Systems*, Wiley (3rd edition, 2004), Chapters 4–9.** The authoritative treatment of mass transport (Chapter 4), electrode kinetics (Chapter 8), and porous electrode theory (Chapter 22). Dense but precise. Return to this when you want to go beyond intuition into rigorous modelling.

3. **Peled, E. and Menkin, S., "Review — SEI: Past, Present and Future," *Journal of the Electrochemical Society* 164 (7), A1703–A1719 (2017).** One of the most comprehensive reviews of SEI by one of the field's pioneers. Covers formation mechanisms, composition, and the role of SEI in ageing. Essential background for Chapter 7.

4. **Bard, A. J. and Faulkner, L. R., *Electrochemical Methods: Fundamentals and Applications*, Wiley (2nd edition, 2001), Chapter 3.** The canonical derivation and discussion of the Butler-Volmer equation, Tafel behaviour, and exchange current density. The treatment of the electrical double layer in Chapter 13 is also excellent.

5. **Doyle, M., Fuller, T. F., and Newman, J., "Modeling of Galvanostatic Charge and Discharge of the Lithium/Polymer/Insertion Cell," *Journal of the Electrochemical Society* 140 (6), 1526–1533 (1993).** The paper that established the Doyle-Fuller-Newman (DFN) model — the foundational physics-based model that formalises everything in this chapter into a complete set of coupled PDEs. Reading this after Chapter 2 gives you the jump from physical intuition to mathematical model.

---

*Next chapter: **Chapter 3 — Performance Metrics and Terminology.** We ascend from physics back toward engineering: capacity, C-rate, internal resistance, OCV curves, Coulombic efficiency, cycle life, and the full suite of characterisation techniques — HPPC, GITT, PITT, EIS — explained from first principles. Prompt me with "write Chapter 3" to continue.*

# Chapter 4: Cell Construction

## Chapter Opening

So far in this book we have inhabited a somewhat abstract world. We have talked about electrodes, electrolytes, and separators as if they were ideal geometric planes of material sitting in a beaker. The physics and chemistry we have built up — intercalation, Butler-Volmer kinetics, Fick's diffusion, the SEI — is real and accurate, but it has existed, up to this point, largely without context. A real battery is not a beaker. It is a precisely engineered product that must pack as much energy as possible into as little space and mass as possible, survive thousands of charge-discharge cycles without mechanical failure, resist thermal runaway under abuse, and be manufactured at a cost measured in tens of dollars per kilowatt-hour rather than thousands.

This chapter is about the gap between the physics and the product. It is about how the material — the active powder with its beautiful crystal structure and its carefully optimised electrochemistry — becomes the cell sitting on a laboratory bench or inside a car. That journey involves slurries and ovens and precision rollers and hermetic seals and electrolyte fill lines, and every step of it has electrochemical consequences. The way an electrode is calendered affects its porosity and therefore its rate capability. The way a cell is sealed determines whether its electrolyte will last five years or fifteen. The first cycles a cell undergoes after assembly are not accidental — they are a deliberate manufacturing step called formation, and without them the cell would die in weeks.

Understanding cell construction is also practically important for anyone doing simulation research. When you build a physics-based model of a sodium-ion cell, you need geometric parameters: electrode thickness, particle size, porosity, tortuosity, electrolyte volume fraction. All of these are consequences of manufacturing choices — calendering pressure, slurry formulation, coating weight. The better you understand how those choices are made and what they mean physically, the better you can interpret the parameters you feed into your model and assess whether they are physically reasonable.

By the end of this chapter, you will be able to look at any commercial cell — cylindrical, prismatic, or pouch — and understand why it is built the way it is, what geometric and manufacturing trade-offs were made in its design, and how those trade-offs show up in the performance and degradation behaviour you will model and measure.

---

> **Prerequisites Check**
>
> From your EE background:
> - Basic mechanical and thermal intuitions (stress, strain, heat conduction) — helpful for understanding calendering and thermal management
> - Familiarity with manufacturing tolerance concepts — relevant to electrode coating uniformity
>
> From Chapters 1–3:
> - The SEI and its formation during the first cycles (Chapter 2, Section 2.3) — essential for Section 4.3
> - Current collector material choices (Chapter 1, Section 1.3) — this chapter expands on those reasons
> - The three overpotential types (Chapter 2, Section 2.7) — needed to understand why porosity and tortuosity matter
> - Coulombic efficiency and first-cycle irreversibility (Chapter 3, Section 3.6) — directly relevant to Section 4.3

---

## 4.1 Form Factors: Cylindrical, Pouch, and Prismatic

The same electrochemical system — the same active materials, the same electrolyte chemistry, the same separator — can be packaged in radically different physical forms. The three dominant form factors in commercial lithium-ion (and increasingly sodium-ion) cells are **cylindrical**, **prismatic**, and **pouch**. Each has a distinct manufacturing process, a distinct set of mechanical advantages and disadvantages, and a distinct set of applications where it excels. Understanding why each form factor exists requires thinking about the engineering problem from the top down: how do you pack the maximum electrochemically active material into the minimum volume, maintain structural integrity over thousands of cycles, manage heat, and do it at low manufacturing cost?

### Cylindrical Cells

The **cylindrical cell** is the oldest and in many ways the most mature format. The basic construction is a long, thin "jelly roll" — a multilayer sandwich of anode, separator, electrolyte-wetted cathode, and another separator, wound tightly around a central mandrel into a spiral and then inserted into a cylindrical steel can. The steel can is sealed at both ends, with one end forming the negative terminal and the other (with a safety vent) the positive terminal.

The standard naming convention for cylindrical cells uses two numbers encoding the diameter and height in millimetres. The **18650** cell — 18 mm diameter, 65 mm height — became the global standard for laptop batteries in the 1990s and remains the most studied cell format in the academic literature. It was also used in the original Tesla Roadster (6,831 cells per pack) and the early Model S. The **21700** cell — 21 mm diameter, 70 mm height — was introduced commercially by Panasonic and Tesla around 2017 and offers roughly 50% more energy per cell than the 18650 while maintaining similar voltage characteristics. The **4680** cell — 46 mm diameter, 80 mm height — is Tesla's current large-format cylindrical cell, offering a claimed 5× energy per cell versus the 21700 and a novel "tabless" electrode design.

The jelly-roll geometry has several important engineering properties. The steel can provides excellent mechanical rigidity: cylindrical cells are resistant to external mechanical abuse (crushing, penetration) compared to the other formats. The wound structure naturally creates a uniform electrode stack without the need for external compression. The geometry also creates challenges: heat generated in the centre of the jelly roll must conduct radially outward through the wound layers to reach the can wall — a significant thermal resistance that can create temperature gradients across the cell cross-section.

The conventional cylindrical cell has tabs — metal strips welded to the current collector foils at specific points along the electrode coil — that carry current from the electrode jelly roll to the cell terminals. In a conventional design, there is typically one tab on the anode and one on the cathode, located at the ends of the wound structure. The current must travel the full length of the current collector foil (up to 60 cm or more in an 18650) to reach the tab. For high-current applications, this creates significant resistive losses in the current collector foil — an ohmic loss that heats the cell and limits power density.

The **4680 "tabless" design** addresses this by creating many small contacts distributed continuously along the length of the electrode foil, eliminating the long-path current conduction problem. The current path from any point on the electrode to the terminal is shortened from the full unwound foil length down to roughly the cell *height* — a factor of several reduction in current-collector resistance (Tesla has cited around a fivefold drop, depending on how you count) and a corresponding improvement in both power density and thermal uniformity. Critically, the heat generated by ohmic loss in the foil is now distributed along the full electrode rather than concentrated near a single tab, which evens out the cell's internal temperature gradients during high-rate operation. This is a clean example of how cell geometry directly affects the ohmic resistance we discussed in Chapter 3.

If you want an EE analogy, think of a high-current ground plane on a PCB. If you ground that plane at one corner only, every return current has to find its way to that corner — current crowding, voltage drops, and IR heating concentrated at the connection. If instead you stitch the plane to the chassis with vias every few millimetres, the return current spreads out, the resistance drops, and the heating spreads out with it. Tabless electrode design is the same trick at the cell level: replace a single distant contact with a distributed contact, and the IR losses fall and even out simultaneously.

A characteristic of cylindrical cells that matters for pack design is their **isotropic volume expansion**: as the jelly roll swells slightly with lithiation cycling, the cell expands radially inside the rigid steel can. Because the can constrains the expansion, the electrode stack is under compressive stress — this actually helps maintain good inter-particle contact and electrode-separator contact over cycling, one reason cylindrical cells tend to have relatively good cycle life compared to pouch cells without external compression.

### Prismatic Cells

**Prismatic cells** use either a wound jelly roll or a stacked flat-plate construction, inserted into a rigid rectangular aluminium or steel case. The prismatic format is dominant in automotive applications from Asian manufacturers (CATL, BYD, Samsung SDI, and others) and in stationary storage. The rectangular geometry allows prismatic cells to be packed together in modules without wasted space between cells — the volumetric efficiency of rectangular packing is higher than cylindrical packing.

The prismatic aluminium case is much lighter than steel (aluminium density 2.7 g/cm³ vs. steel 7.9 g/cm³), which improves the cell-level gravimetric energy density. However, aluminium is less rigid than steel, so prismatic cells can experience more deformation under mechanical load or internal swelling. Manufacturers typically apply external compression during module assembly to maintain electrode stack pressure throughout the cell's life — an important design consideration that cylindrical cells do not require.

Heat management in prismatic cells is easier than in cylindrical cells in one respect: the flat faces of a prismatic cell provide large surface areas through which cooling can be applied (most automotive prismatic modules cool the cells through the large flat faces using cooling plates). However, the temperature distribution within a thick prismatic cell (cells for automotive applications can be 30–60 mm thick) is still uneven, and the centre of the cell is the hottest point.

The **blade cell** (BYD's LFP cell design) is a particularly thin prismatic format — typically 13.5 mm thick but up to 960 mm long and 90 mm tall — designed to be stacked directly into a battery pack without an intermediate module structure (the "cell-to-pack" concept). The extreme aspect ratio of the blade cell minimises the thermal path to the cooling surface and eliminates module hardware, reducing pack mass and cost.

### Pouch Cells

The **pouch cell** (also called a **soft-pack cell** or **laminate cell**) replaces the rigid metal can with a thin, flexible aluminium-plastic laminate film. The electrodes are cut into flat rectangular sheets and stacked in an alternating anode-separator-cathode-separator arrangement, connected by thin current collector tabs that exit through the heat-sealed edge of the pouch. The laminate film is formed into an envelope around the stack and the edges are heat-sealed under vacuum.

Pouch cells are the most versatile format in terms of shape customisation: the laminate can be formed into any flat rectangular shape. This makes pouch cells attractive for consumer electronics (smartphones, tablets, wearables) where the cell must fit into an irregular space, and for some automotive applications where the flat form factor aids thermal management.

The gravimetric energy density of pouch cells is typically the highest of the three formats because the laminate film packaging is much lighter than a metal can — a pouch film contributes roughly 1–3% of total cell mass, compared to 15–25% for a cylindrical steel can. However, this lightweight packaging provides no structural rigidity. Pouch cells require external mechanical compression throughout their life to maintain good electrode stack contact as the electrodes breathe (expand and contract) during cycling, and they are more vulnerable to physical damage.

The great practical challenge of pouch cells is **gas management**. During the first few cycles (the formation process, discussed in Section 4.3), gas is evolved as electrolyte decomposes and the SEI forms. In a metal-can cell, the gas is absorbed by the liquid electrolyte or vented through a safety valve. In a pouch cell, if this gas is not managed — either by a designed gas pocket at one end of the pouch that is separated and removed after formation, or by a degassing step — the cell swells and the internal pressure pushes the electrode layers apart, increasing ionic resistance and degrading performance. All commercial pouch cells go through a degassing step after formation for this reason.

### Comparative Summary

The choice of form factor is a system-level engineering decision that balances energy density, power density, thermal management, mechanical robustness, manufacturing cost, and application-specific shape constraints. A table helps:

| Property | Cylindrical (18650/21700) | Prismatic | Pouch |
|---|---|---|---|
| Gravimetric energy density | Moderate (can weight) | Moderate | High (light packaging) |
| Volumetric packing efficiency | ~60–74% (round packing) | ~85–95% | ~85–95% |
| Mechanical robustness | High (steel can) | Moderate | Low (no rigid case) |
| Thermal management | Moderate (radial path) | Good (flat faces) | Good (flat faces) |
| Manufacturing maturity | Highest | High | Moderate |
| Gas management | Built-in vent | Built-in vent | Requires degassing step |
| Dominant application | Consumer, some EV | EV, stationary | Consumer, some EV |

For sodium-ion cells, all three form factors are in commercial use. CATL's first-generation SIB cells were released in cylindrical (26700-class) format, with prismatic cells targeted at automotive packs. HiNa has shipped both cylindrical (26700-class) and prismatic cells across its product line. Faradion (now part of Reliance Industries) is best known for pouch-cell demonstrations — including their reference 12 Ah hard-carbon / layered-oxide pouch cell — though they have also produced cylindrical samples. Several Chinese producers are moving toward prismatic and blade formats for automotive-scale production. The takeaway is that the SIB industry has not yet converged on a dominant form factor the way LIB-for-EV has converged on prismatic and large-format cylindrical; a sodium cell can show up in any of the three packages, and you should expect to encounter all three in the literature.

---

## 4.2 Electrode Manufacturing: Slurry, Coating, Calendering, Slitting

Transforming powdered active material into a functional electrode is one of the most technically demanding steps in battery manufacturing, and it is the step with the most direct impact on the electrochemical parameters that appear in simulation models. Understanding the process allows you to interpret manufacturing-related parameters physically.

### The Slurry

The starting point of electrode manufacturing is the **slurry** — a viscous suspension of the active material powder in a solvent, mixed with two additives: a **binder** and a **conductive carbon**.

The **binder** is a polymer that, when the slurry dries, holds the active material particles together and adheres the electrode layer to the current collector foil. The most common binder for cathode electrodes is PVDF (polyvinylidene difluoride), dissolved in NMP (N-methyl-2-pyrrolidone) as the slurry solvent. For anode electrodes, aqueous-based binders — typically CMC (carboxymethyl cellulose) plus SBR (styrene-butadiene rubber) — are increasingly preferred because they avoid the energy-intensive and expensive NMP solvent and are compatible with the water sensitivity requirements of graphite processing.

The binder must fulfil several competing requirements: it must be flexible enough to accommodate the volume changes of the active particles during cycling without cracking, it must be stable against both oxidation at the cathode and reduction at the anode, it must be ionically permeable (electrolyte must wet through it to reach the active particle surfaces), and it must have good adhesion to both the particles and the current collector foil. No single binder excels at all of these simultaneously, which is why binder choice is a persistent area of cell development.

The **conductive carbon** additive (typically carbon black, graphite flakes, or carbon nanotubes, at 1–5 weight percent of the electrode) serves to create an electronically conductive network connecting the active particles to the current collector. Many active materials — particularly the olivine and polyanionic cathodes like LFP, and the hard carbon anodes used in SIBs — have relatively low intrinsic electronic conductivity. The carbon additive creates conduction pathways between particles and between particles and the current collector. Without it, the electrode would have prohibitively high electronic resistance.

The slurry is mixed in a high-shear planetary mixer to ensure uniform distribution of all components. The slurry composition is typically 80–97% active material by weight, 1–5% conductive carbon, and 2–8% binder, depending on the chemistry and the performance targets. The ratio matters: more binder increases adhesion and mechanical robustness but reduces energy density (binder is dead weight) and can block ionic access to particle surfaces. More conductive carbon improves rate capability but similarly reduces energy density. Electrode formulation is an optimisation problem with multiple competing objectives.

For sodium-ion cells, the slurry chemistry is similar. Hard carbon anodes typically use aqueous CMC/SBR binders. Cathode slurry formulations depend on the cathode family: layered oxides use PVDF/NMP; NVPF and Prussian blue analogue (PBA) cathodes sometimes use aqueous binders due to environmental and cost advantages, though water sensitivity of some PBA phases requires careful humidity control.

### Coating

The slurry is **coated** onto the current collector foil using a **slot-die coater** or **comma-bar coater** in a continuous roll-to-roll process. The foil — copper for anodes, aluminium for cathodes — is fed from a supply roll, passes under the coating head where the slurry is deposited as a uniform wet film, travels through a drying oven that evaporates the solvent (NMP or water), and winds onto a take-up roll as a dry electrode tape.

The thickness of the wet coating is controlled by the gap in the coating head and the flow rate of the slurry. After drying, the dry coating thickness is typically 50–200 µm per side (many commercial cells are coated on both sides of the foil simultaneously or in two passes). The dry coating weight per unit area — called the **areal loading** or **coating weight**, measured in mg/cm² — is one of the most important manufacturing parameters and is a direct input to physics-based cell models.

Coating uniformity is critical. Variations in coating weight of even a few percent across the electrode area lead to non-uniform current distribution during operation — regions with less active material receive proportionally higher current density, experiencing more severe kinetic and transport polarisation and degrading faster. In large-format cells, coating uniformity over areas of several hundred square centimetres is a major manufacturing challenge.

The drying step is more complex than it might appear. The solvent (NMP for PVDF-based cathodes) must be removed completely — residual NMP contaminates the electrolyte and degrades performance — but drying too rapidly causes **binder migration**: the polymer binder, carried by the solvent flux toward the surface during evaporation, accumulates at the top surface of the coating rather than being uniformly distributed throughout the electrode thickness. This binder migration can leave the interior of the electrode binder-poor (poor adhesion between particles) and the surface binder-rich (blocked ionic access, surface cracking). Controlled drying profiles that slow the final evaporation stage are used to mitigate this effect.

### Calendering

After drying, the electrode tape passes through a **calendering** step: it is pressed between two precision steel rollers under high pressure (tens to hundreds of MPa). Calendering serves two purposes.

First, it **densifies** the electrode: the porous powder coating is compressed, reducing the thickness by typically 15–40% and increasing the electrode volumetric density. This increases the volumetric energy density of the electrode, which is important for reaching high volumetric energy density in the final cell.

Second, it **improves electronic contact** between particles and between the electrode coating and the current collector. Fresh-dried electrode coatings have large voids between particles that provide poor particle-to-particle contact. Calendering crushes particles slightly into each other and into the current collector foil, dramatically reducing the contact resistance.

The critical parameter controlled by calendering is **electrode porosity** $\varepsilon$ — the fraction of the electrode volume occupied by empty space (which will be filled by electrolyte in the assembled cell). This is perhaps the single most important geometric parameter in a physics-based battery model, because it controls three competing properties simultaneously:

**Higher porosity** (less calendering): more electrolyte volume in the electrode, which lowers the ionic resistance by providing more parallel ion transport pathways; also allows more room for electrode volume expansion during cycling without mechanical stress. But higher porosity reduces volumetric energy density (more dead space) and reduces inter-particle electronic conductivity.

**Lower porosity** (more calendering): higher volumetric energy density and better electronic conductivity, but greater ionic transport resistance (fewer and smaller pathways for ions to move through the pores), greater susceptibility to transport limitation at high C-rates, and less mechanical accommodation of volume changes.

A quick numerical feel for how sharp these trade-offs are. Suppose you start with an electrode at 40% porosity and calender it down to 25%. You have just gained a factor of $0.75/0.60 = 1.25$ in solid volume fraction — about a 25% improvement in volumetric energy density at the electrode level, which is significant. But by Bruggeman (which we are about to meet), your effective electrolyte-phase diffusivity has dropped by a factor of $(0.40/0.25)^{1.5} \approx 2.0$. You have doubled the ionic transport resistance of your electrode in exchange for that 25% energy density gain. Whether the trade is worth it depends entirely on the application: a stationary storage cell that never sees more than C/3 will happily take the energy density and pay no real penalty, because at C/3 ionic transport in the pores is nowhere near limiting. A power-tool cell that needs to deliver 15C in short bursts cannot afford to give up that diffusivity, and will be calendered much less aggressively. This is one of the most direct examples in the chapter of how a single manufacturing parameter sets the application envelope of the resulting cell.

The Bruggeman relation (Equation 4.1) is the workhorse model for electrolyte-phase transport in a porous electrode:

$$D_\text{eff} = D_0 \cdot \varepsilon^{1.5} \tag{4.1}$$

where $D_\text{eff}$ is the effective diffusion coefficient ions experience in the porous electrode, $D_0$ is the diffusion coefficient in the free (bulk) electrolyte, and $\varepsilon$ is the porosity (the void fraction of the electrode). The exponent 1.5 is not pulled out of thin air — it is the result of a self-consistent effective-medium calculation Bruggeman did in 1935 for the conductivity of a random packing of spherical inclusions. The cleanest way to remember where it comes from is to think of two effects multiplying:

First, ions only occupy a fraction $\varepsilon$ of the volume — there is just less liquid for them to be in. This alone would give $D_\text{eff} = \varepsilon D_0$, a factor of $\varepsilon^1$. Second, the path an ion must take to get from one face of the electrode to the other is not a straight line; it has to wind around solid particles, and the geometric path is longer than the straight-line distance by a factor we call the tortuosity. For a random sphere packing, Bruggeman's effective-medium argument gives a tortuosity of $\varepsilon^{-0.5}$, contributing another factor of $\varepsilon^{0.5}$ to the diffusivity reduction. Multiply: $\varepsilon^1 \cdot \varepsilon^{0.5} = \varepsilon^{1.5}$.

The intuition for an EE: porosity does to ionic transport what filling a transmission line with a denser dielectric does to a wave — it does not block the signal, but it slows it down and introduces an extra geometric factor on top of the bulk material property. Higher porosity means more parallel paths *and* shorter effective paths, which is why even a small change in porosity (say, from 0.30 to 0.40) makes a non-trivial difference in rate capability: $0.40^{1.5}/0.30^{1.5} \approx 1.54$, a 54% improvement in $D_\text{eff}$ for a 33% increase in porosity.

Real electrodes deviate from the Bruggeman prediction, especially heavily calendered ones where pores become elongated, partially closed, and non-uniform. The general form used in the Newman / Doyle-Fuller-Newman simulation tradition is

$$D_\text{eff} = D_0 \cdot \frac{\varepsilon}{\tau}$$

where $\tau$ is the **tortuosity factor** — a single number that lumps together all the geometric reasons ions in a porous electrode see less than the free-electrolyte diffusivity. (Annoyingly, this $\tau$ is unrelated to the time constant $\tau$ we used in Chapter 2; the overloaded notation is standard in both fields and you will have to rely on context.) Bruggeman's $\varepsilon^{1.5}$ result is just the special case $\tau = \varepsilon^{-0.5}$, which at $\varepsilon = 0.3$ predicts $\tau \approx 1.8$. Real measurements of well-calendered NMC cathodes give $\tau$ in the range 3–5 — noticeably worse than Bruggeman, which is why the simulation literature treats $\tau$ as something you measure (by FIB-SEM tomography, EIS, or symmetric-cell methods) rather than something you predict. Highly compressed electrodes can reach $\tau$ of 10 or more.

*A common misconception worth flagging.* Porosity and tortuosity are related but they are not the same parameter, and you cannot back one out of the other without measuring something. Two electrodes with identical porosity can have very different tortuosities depending on the *shape* of their pores: long, straight, parallel channels (low tortuosity) versus a tangled mess of dead-ends and bottlenecks (high tortuosity). Calendering tends to crush pores into flatter, more elongated, more anisotropic shapes — which is why heavily calendered electrodes have tortuosities well above the Bruggeman prediction even at the same porosity as a less-calendered electrode. When you read a paper that reports only $\varepsilon$ and assumes Bruggeman, treat the resulting transport coefficients as optimistic. We will see in Chapter 7 that tortuosity also tends to *grow* over a cell's life as particles crack and rearrange, which is one of the silent contributors to power fade — quite separate from the more frequently cited capacity fade.

In simulation work, porosity and tortuosity are the parameters you will most need to estimate carefully. Published values for commercial electrodes from synchrotron X-ray tomography and focused ion beam (FIB) cross-sectional imaging are available in the literature for several commercial cells and are the best reference for establishing physically reasonable model parameters.

### Slitting and Notching

After calendering, the wide electrode tape (typically 300–800 mm wide, produced in rolls of several hundred metres) must be cut to the final dimensions required for the specific cell format. This is done by **slitting** — precision cutting using laser or mechanical blades — and (for pouch and prismatic stacked cells) **notching**, which cuts the electrode sheets to their final rectangular shape and forms the current collector tab extensions.

The quality of the slit edge matters for cell safety. Burrs or metal fragments on the cut edge can pierce the separator in the assembled cell, creating an internal short circuit. Electrode manufacturing facilities invest heavily in slitting blade quality and edge quality inspection.

---

## 4.3 Formation Cycling and Why First Cycles Differ

After a cell is physically assembled — electrodes wound or stacked, case crimped or heat-sealed, electrolyte filled — it is not yet a functional battery. It is an inert electrochemical assembly that must be activated by its first controlled charge-discharge cycles. This activation process, called **formation**, is one of the most critically important steps in cell manufacturing, and it has direct electrochemical consequences that shape the cell's performance for its entire lifetime.

### What Happens During Formation

When a freshly assembled cell is first charged, the electrodes are "dry" in the sense that they have never been in contact with an electrolyte under electrochemical conditions. The active material particles are in their pristine, as-manufactured state: no SEI exists yet.

As the charging current begins, the cell undergoes several processes simultaneously.

**Electrolyte wetting and infiltration**: The electrolyte must permeate the pores of the electrode coatings completely, displacing any air trapped during assembly. In a fresh cell, some pores may not be fully wetted initially. The first few charge cycles, particularly if performed slowly, help drive electrolyte into incompletely wetted pores through electroosmotic and capillary forces. Incomplete wetting at the start of formation leads to non-uniform current distribution and inhomogeneous SEI formation.

**SEI formation on the anode**: As described in Chapter 2, when the anode potential drops below approximately 0.8 V vs. Li/Li⁺ (which happens during the first charge of a graphite anode), the organic electrolyte begins to reduce. The products deposit on the anode surface as the nascent SEI. This process consumes lithium (or sodium, in an SIB) irreversibly — the first-cycle Coulombic efficiency loss we discussed in Chapter 3 (Section 3.6). The SEI grows rapidly during the first charge, passivates the surface, and then grows much more slowly in subsequent cycles.

**CEI formation on the cathode**: A thinner, less well-characterised passivation film — the **cathode-electrolyte interphase (CEI)** — forms on the cathode surface during the first charge when the cathode reaches its upper potential limit. This film forms from oxidative decomposition of the electrolyte solvents and salt at the cathode's high potential. The CEI is generally thinner and more variable than the SEI, and its properties depend strongly on cathode chemistry and electrolyte composition.

**Structural rearrangement of electrode particles**: The first intercalation/de-intercalation cycle is sometimes the most stressful mechanically. Freshly synthesised active material particles have never experienced the strain of hosting guest ions. The first lithiation (or sodiation) drives the composition to a state the particle has never been in before, and some particles crack, restructure their surfaces, or undergo phase transitions that are less reversible than subsequent cycles. This is one reason the first cycle is not representative of steady-state behaviour.

**Gas evolution**: The SEI formation reactions produce gases — predominantly CO₂, CO, and hydrocarbons (ethylene, propylene) from the reduction of carbonate solvents. In a pouch cell, this gas can significantly swell the cell during formation, which is why pouch cells are typically formed while clamped, and are then degassed: the cell is opened under inert atmosphere, the gas pocket (a deliberately formed unsealed region at one end of the pouch) is removed, and the cell is heat-resealed. In cylindrical and prismatic cells, the gas is largely absorbed into the electrolyte or vented through safety valves.

### The Formation Protocol

Formation is not simply "charge the cell once." It is a carefully designed electrochemical conditioning protocol, often proprietary to the cell manufacturer, that may include:

A slow first charge (typically C/10 or C/20) to ensure uniform SEI formation across all electrode surfaces. A fast charge would drive up overpotentials, causing heterogeneous SEI formation.

One or more partial discharge-charge cycles to verify that the SEI has stabilised and to check for internal short circuits.

A longer rest at elevated temperature (sometimes called an "aging step" or "high-temperature soak"), lasting hours to days at 40–60°C. Elevated temperature accelerates the SEI formation chemistry, producing a denser and more stable SEI than formation at room temperature alone would yield.

A final capacity check and impedance measurement to bin the cell — to categorise it by its measured capacity and resistance into production bins, ensuring that cells in the same bin are well-matched. Matching cells that go into the same pack minimises the cell-to-cell variation that drives balancing losses (Chapter 11).

Formation adds cost and time to manufacturing: a formation step that requires 12–24 hours at temperature, followed by 48 hours of resting, followed by testing, before the cell is ready to ship represents a significant fraction of the manufacturing cycle time. Reducing formation time without sacrificing SEI quality is an active area of industrial research. One approach is to use formation electrolytes with different solvent compositions (more reactive, faster SEI formers) that are then flushed and replaced with the final electrolyte — a two-electrolyte process that is complex but can produce excellent SEIs.

### Why First Cycles Differ From Steady State

Even after a proper formation step, the second cycle is not identical to the first. The cell approaches steady-state behaviour gradually over typically 5–20 cycles as the SEI stabilises, residual lithium inventory adjustments settle, and the electrode microstructure accommodates its new cycling state. This is why cells reported in the research literature are generally "pre-cycled" or "broken in" for 3–5 cycles before any characterisation measurements are taken — you want to measure the steady-state cell, not the transient post-assembly cell.

Specifically, the phenomena that transition from non-steady to steady state over the first 5–20 cycles include:

The Coulombic efficiency rising from its first-cycle low (~85–95% for graphite-based LIB, ~75–85% for hard carbon SIB) toward its cycle-averaged steady-state value (~99.8–99.95%). The CE rise is not instantaneous but asymptotes toward steady state as the SEI progressively thickens and passivates the remaining active surface area.

The OCV curve shifting slightly as the **electrode balance** settles. Electrode balance is the ratio of the anode's reversible capacity to the cathode's reversible capacity in the assembled cell — it determines how much of each electrode's voltage curve the full-cell OCV actually sweeps through during a 0–100% SOC traversal. (Note that this has nothing to do with the cell-to-cell balancing we will discuss in Chapter 11; the overloaded vocabulary is unfortunate.) Fresh cells often have a slightly non-optimal balance because the irreversible lithium loss to first-cycle SEI formation shifts the operating window of the full cell relative to the operating windows of the individual half-cells. The first few cycles equilibrate to a steady-state offset, and from then on the cell's OCV curve takes its final shape — the one you will fit your model parameters against.

The internal resistance decreasing slightly as the electrolyte fully permeates all electrode pores and as the electrode particles settle into their mechanically stable configurations (minor cracking and rearrangement of the most stressed particles, improving contact and reducing local current density heterogeneity).

For simulation researchers, this means: when you characterise a cell to extract model parameters (OCV curves, $R_\text{ct}$, diffusion coefficients), always use a cell that has been fully formed and broken in. Parameters extracted from first-cycle data are not representative of the cell's operational behaviour.

*A common misconception.* It is tempting, especially for an engineer used to mechanical systems, to think of formation as "breaking the cell in" the way you break in a new engine — gentle initial cycling that loosens up the moving parts. This is the wrong picture. Nothing in a battery is loosening up. Formation is the irreversible chemical *construction* of a thin solid film (the SEI) that did not exist before the first charge and that will protect the anode for thousands of cycles afterward. A poorly executed formation step does not produce a cell that gets better with use; it produces a cell that has a defective protective film for its entire life, and that defective film will determine how that cell ages, how it tolerates fast charging, and how soon its capacity falls off the cliff. Manufacturers spend a lot of effort getting formation right because there is no second chance.

### Formation for SIBs

Formation in sodium-ion cells follows the same conceptual framework — SEI formation, gas evolution, first-cycle irreversibility — but has some distinctive features.

The formation electrolyte composition matters more for hard carbon SIBs than for graphite LIBs, because the hard carbon surface chemistry is more diverse (large surface area, many different surface functional groups) and produces a more heterogeneous SEI. Ether-based electrolytes (such as DEGDME — diethylene glycol dimethyl ether — with NaClO₄ or NaPF₆) produce thinner, more stable SEIs on hard carbon than carbonate-based electrolytes, with higher initial Coulombic efficiency. This is one of the reasons there is active debate in the SIB community about whether ether or carbonate electrolytes are preferable for long-term cycling.

The gas evolution during SIB formation has a different composition than LIB formation gas, because different electrolyte solvents are being reduced at different potentials. For ether-based electrolytes, significantly less gas is produced during hard carbon formation — another advantage.

The formation step in SIBs often must be extended to achieve adequate SEI stabilisation, partly because of the lower ICE of hard carbon and partly because the SIB electrolyte chemistry is less mature and the SEI less predictable than the well-optimised graphite/LiPF₆/EC:DMC system. Current best-practice formation protocols for SIBs are an active topic in manufacturing development.

---

## 4.4 Current Collectors: Copper, Aluminium, and Why SIB Can Use Aluminium on Both Sides

In Chapter 1 we introduced the current collectors and noted that lithium-ion cells use copper on the anode side and aluminium on the cathode side, while sodium-ion cells can use aluminium on both sides. The electrochemical reason was stated briefly: lithium alloys with aluminium at low potentials, but sodium does not. Here we will explore this in detail — including what "alloys with aluminium" means thermodynamically and structurally, why the potential window matters, and what using aluminium on both sides means for cell manufacturing and economics.

### The Electrochemical Stability Window of Current Collectors

A current collector must be electrochemically inert — it must not react with the electrode material, the electrolyte, or the ions being cycled, over the entire range of potentials the electrode experiences during operation. If the current collector corrodes, dissolves, alloys with the active material, or undergoes any other electrochemical transformation, it ceases to be a current collector and becomes a contaminant that poisons the electrode and the electrolyte.

**Aluminium** forms a stable surface oxide (Al₂O₃) that passivates it against corrosion in many environments. This passivation layer is stable at the positive electrode potentials encountered in lithium-ion cells (3.5–4.5 V vs. Li/Li⁺). However, at the negative-electrode potentials of a lithium-ion cell (0.01–0.3 V vs. Li/Li⁺) the thermodynamics flip. Lithium starts to incorporate itself into the aluminium lattice as a true intermetallic alloy. It is worth pausing on what that means: an *intermetallic alloy* is not a chemical reaction in the sense of "Al + Li → some ionic compound" — it is the formation of a new crystalline solid in which Li and Al sit on a regular lattice in a fixed stoichiometric ratio, with metallic bonding throughout. The system goes through a sequence of these phases as more lithium is added: LiAl (cubic, ~50 atomic % Li), Li₃Al₂, Li₉Al₄. Each phase has its own crystal structure, its own density, and its own equilibrium potential against Li/Li⁺.

The earliest of these, LiAl, forms at roughly 0.30–0.38 V vs. Li/Li⁺ depending on which phase boundary you cite, and this is the threshold that disqualifies aluminium as a foil for any anode that operates below ~0.4 V. The destructive part is not the chemistry — it is the geometry. Forming LiAl from Al involves nearly a 100% volume expansion of the host lattice, because each Al atom now has a Li atom shoehorned in nearby. A thin (8–15 µm) aluminium foil simply cannot survive that strain: it cracks, fragments, and loses electrical contact with the electrode coating it was supposed to be carrying current for. The active material delaminates, the cell loses capacity in a few cycles, and what was a current collector becomes a pile of lithiated debris.

Worse still, the alloying is essentially irreversible at room temperature — once Li has worked its way into the Al lattice, getting it back out requires conditions you do not have in a normal cell. So the "alloy" is permanent, and so is the damage.

For a graphite anode, which spends almost all of its operating life in the 0.05–0.25 V vs. Li/Li⁺ window — well below the LiAl threshold — aluminium is simply not an option. Lithium would destroy the current collector within the first few cycles.

**Copper** does not form intermetallic compounds with lithium at any accessible potential — the Li-Cu phase diagram shows no stable phases at room temperature and ambient pressure in the relevant composition range. Copper is also electrochemically stable against oxidation at the anode potential range (it would only be oxidised if the potential rose above approximately 3.3 V vs. Li/Li⁺, which a graphite anode never approaches). Hence copper is the appropriate current collector for the graphite anode in lithium-ion cells.

At the cathode potential (3.5–4.5 V vs. Li/Li⁺), copper would be oxidised (Cu → Cu²⁺ + 2e⁻ becomes thermodynamically favourable above about 3.3 V vs. Li/Li⁺), introducing copper contamination into the electrolyte. This copper dissolution is a real degradation mechanism in overcharged cells where the cathode potential exceeds this limit. Aluminium, with its stable oxide passivation at these potentials, does not dissolve. Hence aluminium is correct for the cathode.

### Why Sodium Changes the Picture

The key question is: does sodium form stable alloys with aluminium?

The Na-Al phase diagram reveals the answer. Sodium and aluminium do have intermetallic phases — NaAl, NaAl₃, and Na₃Al — but these phases are thermodynamically accessible only at highly anodic conditions (essentially, you need to electrodeposit sodium metal into aluminium, which requires potentials at or very near 0 V vs. Na/Na⁺ under concentrated sodium conditions).

More precisely: the formation potential for Na-Al intermetallics is approximately 0 V vs. Na/Na⁺ or below — essentially at the sodium plating potential. The hard carbon anode in a sodium-ion cell operates at potentials *above* this range: the hard carbon slope region spans roughly 0.1–1.0 V vs. Na/Na⁺ in normal operation, and the plateau region sits at roughly 0.05–0.1 V vs. Na/Na⁺ — close to, but still safely above, sodium plating. While this is close to Na metal plating potential, it is not below the Al-Na alloying potential in practice for the following reason: the Na-Al alloy formation is kinetically slow and requires the formation of metallic sodium at the surface first, which the SEI on the aluminium-supported hard carbon electrode prevents.

Experimental evidence across many published studies confirms this: hard carbon electrodes on aluminium foil current collectors in sodium-ion half-cells cycle stably for hundreds of cycles without aluminium corrosion. The aluminium is stable throughout the operating potential window of hard carbon.

This is a profoundly practically important result. Copper is one of the most expensive commodity materials in a lithium-ion cell. In a standard 18650 cell, the copper foil is around 8 µm thick and has a footprint on the order of 500 cm² (one face of a roughly 60 cm × 5.5 cm wound strip — see the worked exercise later in this chapter for where that geometry comes from). Once you account for density (Cu is 8.96 g/cm³), this works out to roughly 4 g of copper, or about 8% of the total mass of a typical 48 g 18650 cell, and roughly 10–15% of the total raw material cost — second only to the cathode active material. Eliminating copper from a sodium-ion cell and replacing it with aluminium (which is roughly 3–4× less expensive by mass and about 3× less dense) reduces both material cost and cell mass.

The ability to use a single current collector material on both sides also simplifies manufacturing: the same foil inventory, the same processing equipment, the same winding parameters can be used for both electrodes, reducing manufacturing complexity and capital equipment requirements. For a technology like sodium-ion batteries, which must ultimately compete on cost with mature lithium-ion manufacturing, this is a meaningful structural advantage.

### Current Collector Thickness and Its Electrochemical Consequences

Current collector foils are typically 6–20 µm thick — extremely thin, because thicker foils add dead weight without adding energy storage capacity. For an 8 µm copper foil and a 12 µm aluminium foil, the current collectors together account for roughly 15–25% of total electrode mass in a commercial cell.

The foil thickness must be balanced against two competing demands. Thinner foils save mass and volume, improving energy density. But thinner foils have higher sheet resistance ($R_\square = \rho / t$, where $\rho$ is electrical resistivity and $t$ is foil thickness), which increases the ohmic resistance component of the current collector and becomes limiting at high current rates. For the large-format 4680 cylindrical cell at its target performance of 6C fast charging, current collector resistance is a genuine design constraint.

The electrical resistivity of copper is $1.72 \times 10^{-8}$ Ω·m; of aluminium $2.65 \times 10^{-8}$ Ω·m. Copper is about 35% more conductive per unit volume. For current collectors where the primary function is electronic conduction, copper would therefore be slightly preferred on conductivity grounds alone — which is one reason the switch from copper to aluminium in SIBs, while electrochemically justified, does come with a minor electronic-resistance trade-off that cell designers must account for.

Before moving on, it helps to have all of the current-collector trade-offs laid out side by side:

| Property | Copper (Cu) | Aluminium (Al) |
|---|---|---|
| Density (g/cm³) | 8.96 | 2.70 |
| Electrical resistivity (Ω·m) | $1.72 \times 10^{-8}$ | $2.65 \times 10^{-8}$ |
| Approx. commodity cost (USD/kg) | ~9 | ~2.5 |
| Approx. cost per unit volume (USD/L) | ~80 | ~7 |
| Stable against oxidation up to | ~3.3 V vs. Li/Li⁺ | >5 V vs. Li/Li⁺ (passivated) |
| Alloys with Li below | Does not alloy | ~0.37 V vs. Li/Li⁺ |
| Alloys with Na below | Does not alloy | ~0 V vs. Na/Na⁺ (kinetically suppressed in operation) |
| Used as anode collector in LIB? | Yes | No (would alloy) |
| Used as cathode collector in LIB? | No (would oxidise) | Yes |
| Used as anode collector in SIB? | Possible but unnecessary | Yes |
| Used as cathode collector in SIB? | No | Yes |

The two rows that matter most for the SIB cost story are the volume-cost row and the bottom four. Aluminium is roughly an order of magnitude cheaper than copper *per litre of foil* — and a foil's contribution to a cell is naturally measured by volume, not by mass. Combined with the fact that Al works on both electrodes, this is where the cost advantage really lives.

### Current Collector Adhesion and Interfacial Resistance

The adhesion between the active material coating and the current collector is critical for both electrical performance and mechanical durability. Poor adhesion leads to delamination — the electrode coating peeling away from the foil — particularly at the edges and corners where residual stress concentrates. Delaminated regions are electrically disconnected from the current path, appearing as dead capacity.

The surface roughness of commercial current collector foils is carefully controlled to promote adhesion: too smooth and the binder cannot grip well; too rough and the coating is non-uniform and the high points can pierce the separator. Aluminium foils for cathodes and copper foils for anodes used in battery manufacturing have surface roughness $R_a$ typically in the range 0.1–0.5 µm.

For sodium-ion cells, the compatibility of hard carbon slurry formulations with aluminium foil adhesion is a specific manufacturing concern. The aqueous CMC/SBR binder systems used for hard carbon have slightly different adhesion characteristics on aluminium than the PVDF/NMP systems conventionally used on aluminium for cathodes in LIBs, and optimisation of slurry formulation for aluminium adhesion in sodium-ion cells is an ongoing area of development.

---

## Worked Interpretation Exercise: Connecting Manufacturing to Simulation Parameters

Let us make the connection between the manufacturing choices described in this chapter and the numerical parameters that appear in a physics-based cell model — specifically the Doyle-Fuller-Newman (DFN) model, which you will encounter when we reach Chapter 13 and which is the standard framework for SIB simulation research.

A published characterisation study of the commercial **LG MJ1 18650 NMC cell** (3.5 Ah) by Ecker et al. (*Journal of the Electrochemical Society*, 2015) reports the following electrode parameters extracted from a combination of physical measurements (SEM, XRD, mercury porosimetry) and electrochemical characterisation (GITT, EIS):

**Positive electrode (NMC):**
- Thickness: 70 µm (per side)
- Porosity: 0.30
- Particle radius: 5.2 µm
- Active material volume fraction: 0.60

**Negative electrode (graphite):**
- Thickness: 73 µm (per side)
- Porosity: 0.34
- Particle radius: 8.6 µm
- Active material volume fraction: 0.57

Now let us interpret each number in terms of the manufacturing steps we have discussed.

**Electrode thickness of 70–73 µm** is a post-calendering dimension. It is the thickness of the dry electrode coating after the calendering step has compressed it from a thicker wet-coated, dried dimension. For a 70 µm coating on a 12 µm aluminium current collector (cathode side), the total cathode tape thickness is 82 µm per side, or 164 µm for a double-side-coated foil. In an 18650 cell with a jelly roll of roughly 60 cm length and 4.5 cm width, the total active area is approximately $0.60 \times 0.045 \times 2 \approx 0.054$ m² per electrode side, or about 540 cm² — consistent with published values.

**Porosity of 0.30–0.34** is a direct outcome of the calendering pressure. A porosity of 0.30 means 30% of the electrode volume is open pore space filled by electrolyte in the assembled cell, and 70% is occupied by solid (active material, binder, conductive carbon). This is a moderately compressed electrode. For context: as-coated (before calendering), NMC electrodes typically have porosities of 0.50–0.60; heavy calendering can reduce this to 0.20–0.25. The 0.30 value represents a compromise between rate capability (higher porosity preferred) and energy density (lower porosity preferred).

Using the Bruggeman relation (Equation 4.1): $D_\text{eff} = D_0 \times 0.30^{1.5} = D_0 \times 0.164$. This means the effective ionic diffusivity in the cathode pores is about 16% of the free-electrolyte value — a factor of 6 reduction. This reduction in effective diffusivity relative to free electrolyte is a direct consequence of the tortuosity of the pore network in a calendered electrode, and it is a major driver of rate capability limitations.

**Particle radius of 5.2 µm** (NMC) comes from the synthesis and milling of the active material before slurry preparation. Using the order-of-magnitude diffusion-time estimate (Equation 4.2), $\tau_\text{diff} \sim r_p^2 / D_s$, with $r_p = 5.2 \times 10^{-6}$ m and $D_s \approx 10^{-14}$ m²/s for NMC at mid-SOC:

$$\tau_\text{diff} \sim \frac{(5.2 \times 10^{-6})^2}{10^{-14}} = \frac{2.7 \times 10^{-11}}{10^{-14}} \approx 2{,}700 \text{ s} \approx 45 \text{ min}$$

(A note on conventions: the rigorous first-mode time constant for diffusion into a sphere is $r_p^2/(\pi^2 D_s)$, smaller than our estimate by about a factor of ten, and some papers report $r_p^2/(15 D_s)$ following Crank. These are all the same physics with different prefactors, and they all lead to the same scaling conclusions. We use the bare $r_p^2/D_s$ here for arithmetic clarity. Also note that $D_s$ for NMC is strongly SOC-dependent — we will revisit this in Chapter 7.)

So the characteristic timescale for a Li⁺ to diffuse from the surface of an NMC particle to its centre is on the order of $2700$ seconds, or about 45 minutes. Compare this to the time available at various C-rates. At 1C, a full discharge takes 3600 s, so the operating timescale is only about $1.3 \times$ the diffusion timescale. That ratio is not large: even at 1C, solid-state diffusion is already starting to influence the cell's voltage response — which is exactly why a GITT pulse at 1C produces a measurable post-pulse relaxation as the concentration profile inside the particles re-homogenises. At 10C the operating timescale (360 s) is roughly an order of magnitude *shorter* than the diffusion timescale, so the centre of each particle never equilibrates with its surface during a discharge, and the cell delivers substantially less than its 1C capacity. By 20C, solid-state diffusion is the dominant rate-limiting process.

This is the rational basis for the particle-size optimisation that materials engineers pursue. Halving the particle radius cuts $\tau_\text{diff}$ by a factor of four (the $r_p^2$ scaling), buying back almost two C-rate doublings of usable rate capability — at the cost of a much larger surface area, which in turn means more SEI, more first-cycle loss, and more side-reaction sites for calendar aging. Particle size is one of the cleanest examples in this book of a trade-off where every direction you push hurts something else.

This exercise demonstrates why the manufacturing choices — calendering pressure setting the porosity, particle size setting the solid-state diffusion time — translate directly into the kinetic performance limits visible in rate capability curves, and why simulation models must incorporate these parameters accurately to reproduce observed cell behaviour.

---

## What Changes for Sodium-Ion?

The form factor landscape, electrode manufacturing processes, and formation protocols for sodium-ion cells are largely derived from lithium-ion technology — most SIB manufacturers are either spin-offs of the LIB industry or have licensed LIB manufacturing know-how. The main differences are:

**Current collectors**: As covered in detail in Section 4.4, aluminium foil replaces copper for both electrodes in SIBs. This simplifies the supply chain and reduces cost, but requires careful validation of hard carbon/aluminium adhesion in aqueous binder systems.

**Electrolyte**: SIB electrolytes based on NaPF₆ or NaClO₄ in carbonate or ether solvents have different wetting characteristics than LIB electrolytes. In particular, some SIB electrolytes have higher viscosity and lower wetting speed, requiring longer wetting times or lower filling speeds during cell assembly. The electrolyte fill step may also be complicated by the hygroscopicity of some sodium salts (NaClO₄ is particularly moisture-sensitive), requiring tighter humidity control in the dry room.

**Formation**: As discussed in Section 4.3, the formation protocol for hard carbon SIBs typically requires more careful control and sometimes elevated temperature aging to produce a stable SEI. The lower ICE of hard carbon (~75–85%) means more formation charge is consumed irreversibly, which some manufacturers compensate by pre-doping the hard carbon with a sodium source (e.g., sodium metal thin film on the anode, or sodium-rich sacrificial additive in the cathode).

**Hard carbon porosity and particle size**: Hard carbon for SIBs is an amorphous material with a complex pore structure that includes both open pores (accessible to electrolyte, the source of slope-region capacity) and closed nanopores (inaccessible to electrolyte, the source of plateau-region capacity). The balance between open and closed porosity — a function of carbonisation temperature and precursor — affects both capacity and rate capability in ways that differ fundamentally from crystalline graphite. The porosity parameter in a simulation model for hard carbon is therefore more complex than for graphite: there is a macroporosity (electrode-level pores between particles) and a microporosity (within particles). Current hard carbon models use simplified representations of this two-scale structure.

---

## Chapter Summary

**Key ideas:**

- The three commercial cell form factors — cylindrical (jelly roll in metal can), prismatic (wound or stacked in rectangular case), and pouch (stacked in laminate film) — each represent different trade-offs among energy density, power density, mechanical robustness, thermal management, gas management, and manufacturing cost. Cylindrical cells are most mechanically robust; pouch cells have the highest gravimetric energy density; prismatic cells dominate automotive applications due to volumetric packing efficiency.
- Electrode manufacturing involves four sequential steps: slurry preparation (active material + binder + conductive carbon + solvent), coating onto current collector foil, drying, and calendering. Calendering is the step that directly sets electrode porosity, which controls the trade-off between ionic transport (favours higher porosity) and volumetric energy density (favours lower porosity). The Bruggeman relation $D_\text{eff} = D_0 \varepsilon^{1.5}$ quantifies the porosity effect on effective ionic diffusivity.
- Formation cycling is the mandatory first-charge-discharge sequence performed on every cell after assembly. It forms the SEI (and CEI), drives electrolyte into unfilled pores, evolves and removes gas, and establishes the steady-state Coulombic efficiency. The first 5–20 cycles are transitional; simulation and characterisation measurements should be performed on broken-in cells.
- Current collector choice is thermodynamically constrained: copper oxidises above ~3.3 V vs. Li/Li⁺ (disqualifying it for cathodes) and lithium alloys with aluminium below ~0.37 V vs. Li/Li⁺ (disqualifying aluminium for graphite anodes, with volume expansion mechanically destroying the foil). Copper avoids both problems on the anode but is expensive. Sodium does not alloy with aluminium in the hard carbon operating window, enabling aluminium-on-both-sides in SIBs — a meaningful cost and manufacturing simplification.

**Key equations:**

$$D_\text{eff} = D_0 \cdot \varepsilon^{1.5} \quad \text{(Bruggeman relation for porous-electrode transport)} \tag{4.1}$$

$$\tau_\text{diff} \sim \frac{r_p^2}{D_s} \quad \text{(order-of-magnitude solid-state diffusion time for a spherical particle of radius } r_p\text{)} \tag{4.2}$$

$$R_\square = \frac{\rho}{t} \quad \text{(current-collector sheet resistance, in ohms per square)} \tag{4.3}$$

**Key vocabulary (in order of appearance):**

Jelly roll, 18650 / 21700 / 4680, tab, tabless electrode, prismatic cell, blade cell, pouch cell (soft-pack / laminate cell), degassing, cell-to-pack, slurry, binder (PVDF, CMC, SBR), NMP, conductive carbon, slot-die coating, areal loading (coating weight), binder migration, calendering, electrode porosity, tortuosity factor, Bruggeman exponent, slitting, formation cycling, cathode-electrolyte interphase (CEI), gas evolution, electrode balance, formation electrolyte, cell binning, current collector, Li-Al alloying, intermetallic alloy, electrochemical stability window, sheet resistance.

---

## Deliverable

The original chapter plan does not specify a dedicated deliverable for Chapter 4. Instead, the knowledge from this chapter feeds into the deliverable for Chapter 6, where you will construct a comparison table of SIB vs. LIB cells across all Chapter 3 metrics. To prepare, do the following now:

For each of the three form factors (18650 cylindrical, prismatic, pouch), find one specific commercial cell (search manufacturer websites, the BatteryBits database, or Cell Analysis Modelling and Prototyping, CAMP, facility data at Argonne National Laboratory). Record the following for each: form factor dimensions, nominal voltage, rated capacity and at what C-rate, gravimetric energy density (Wh/kg), volumetric energy density (Wh/L), and internal resistance if available.

Then answer the following questions using the concepts from this chapter. For the cell with the highest gravimetric energy density: is this consistent with the form factor trade-off discussion in Section 4.1? For the cell with the lowest internal resistance: is this consistent with the current collector material and electrode thickness? For any cell that reports initial Coulombic efficiency: is it in the expected range for its anode chemistry?

---

## Further Reading

1. **Schmuch, R. et al., "Performance and cost of materials for lithium-based rechargeable automotive batteries," *Nature Energy* 3, 267–278 (2018).** An authoritative review of the full electrode manufacturing chain from materials cost to cell-level performance, with quantitative data on how manufacturing choices (calendering, areal loading, electrolyte volume) affect energy density and cost. Directly relevant to the manufacturing-to-simulation connection.

2. **Wood, D. L. et al., "Technical and economic analysis of solvent-based lithium-ion electrode drying with water and NMP," *Drying Technology* 36 (2), 234–244 (2018).** The technical and economic case for aqueous electrode processing (eliminating NMP), with implications for SIB hard carbon electrodes where aqueous processing is already preferred.

3. **Heubner, C. et al., "From Active Materials to Battery Cells: A Straightforward Tool for Determining the Impact of Electrode-Level Properties on the Performance of Lithium-Ion Batteries," *Advanced Energy Materials* 10 (47), 2001936 (2020).** A practical guide to connecting electrode-level parameters (porosity, thickness, loading) to cell-level energy and power density — exactly the translation this chapter is aimed at.

4. **An, S. J. et al., "The state of understanding of the lithium-ion-battery graphite solid electrolyte interphase (SEI) and its relationship to formation cycling," *Carbon* 105, 52–76 (2016).** A comprehensive review of what formation cycling actually does to the SEI, with detailed chemistry and protocols. Read this to understand Section 4.3 in greater depth.

5. **Komaba, S. et al., "Na-ion batteries using hard carbon and conventional electrolyte," *ECS Transactions* 28 (8), 43–55 (2010).** One of the early papers establishing that hard carbon / aluminium current collector assemblies are stable for sodium-ion cycling, providing the experimental basis for the SIB aluminium current collector advantage discussed in Section 4.4.

---

*Next chapter: **Chapter 5 — Lithium-Ion Chemistry Families.** We survey the major Li-ion cathode and anode chemistries — LCO, LFP, NMC, NCA, LMO, LTO — and build the trade-off framework you will use to understand why SIB was developed as an alternative. Prompt me with "write Chapter 5" to continue.*

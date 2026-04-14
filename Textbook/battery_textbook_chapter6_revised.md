# Chapter 6: Sodium-Ion Chemistry Families

## Chapter Opening

There is a question that serious researchers ask when they encounter sodium-ion batteries for the first time, and it is worth stating plainly: if we already have lithium-ion batteries that work extraordinarily well, why would we deliberately choose to build batteries around a heavier, bulkier ion that sits higher on the reduction potential scale, cannot use graphite as an anode, and cannot use copper as a current collector? What problem is sodium-ion actually solving?

The answer is not primarily technical. It is economic, geographic, and temporal.

Lithium is not rare in the Earth's crust — it sits at about 20 parts per million, comparable to cobalt — but it is unevenly distributed. The majority of accessible lithium reserves sit in the "lithium triangle" of Chile, Argentina, and Bolivia, with significant additional deposits in Australia. As global demand for lithium-ion batteries has grown exponentially through the 2010s and 2020s, the lithium supply chain has tightened, prices have moved through a range of more than an order of magnitude between 2020 and 2024, and the geopolitical risk of concentrated supply has become a genuine concern for battery manufacturers and the governments that want to build domestic battery industries.

Sodium has none of these problems. Sodium is the sixth most abundant element in the Earth's crust and is essentially uniformly distributed across every continent in the form of sodium carbonate (soda ash), sodium chloride (table salt), and dozens of other minerals. The raw material for sodium-ion electrolytes — sodium hexafluorophosphate or sodium perchlorate — can be synthesised from commodity chemicals anywhere in the world. The cathode materials that work best for SIBs — layered oxides of iron, manganese, and nickel; Prussian blue analogues based on iron; vanadium fluorophosphates — are largely free of cobalt and low in nickel. The bill of materials for a sodium-ion cell is, in principle, dramatically less geopolitically sensitive than a lithium-ion cell.

This is the SIB argument: not "better than lithium-ion" but "good enough, from materials that are cheap and available everywhere." The target application is not the premium performance market — that remains lithium-ion's domain, at least for now — but the enormous and growing markets for stationary grid storage, affordable urban electric vehicles, and two- and three-wheeled electric transport in emerging economies. In those markets, cost per kilowatt-hour and supply chain resilience matter more than energy density per kilogram.

With that context established, we can read this chapter as an engineering survey: what materials are available for SIB cathodes and anodes, what do they do well and poorly, and how does the overall system compare to the lithium-ion analogues we surveyed in Chapter 5? By the end, you will be able to read a SIB research paper and identify which chemistry family the authors are working with, what performance range to expect from it, and what the open problems are that motivated the work. This chapter is also the foundation for Chapter 14, where we'll revisit the SIB research landscape from a research-strategy angle — who is publishing what, where the open questions are, and which of them are tractable with EE-style simulation tools.

---

> **Prerequisites Check**
>
> From Chapter 1:
>
> - Standard electrode potentials of Li⁺/Li and Na⁺/Na (Section 1.4) — directly needed here
> - Faraday's law for theoretical capacity calculation (Section 1.7)
>
> From Chapter 2:
>
> - Intercalation host structure families: layered, spinel, olivine, polyanionic (Section 2.2)
> - The SEI and first-cycle irreversibility (Section 2.3)
>
> From Chapter 3:
>
> - All cell metrics: capacity, energy density, C-rate, cycle life, ICE, OCV shape (full chapter)
>
> From Chapter 5:
>
> - LCO, LFP, NMC chemistry details (Sections 5.2–5.4) — SIB chemistries are best understood by comparison
> - The five-dimensional trade-off framework (Section 5.1)
> - The flat OCV / SOC estimation problem introduced for LFP (Section 5.3) — critically important for SIB hard carbon
>
> This chapter is the most chemistry-dense in the book so far. If any of the crystal structure vocabulary from Chapter 2 is fuzzy, spend ten minutes reviewing Section 2.2 before proceeding to Section 6.1.

---

## 6.1 Why Na⁺ Is Harder to Work With Than Li⁺

Before we discuss specific SIB materials, we need to establish the fundamental physical and chemical differences between sodium and lithium ions as battery charge carriers. These differences explain why SIBs cannot simply use the same electrode materials as LIBs with sodium substituted for lithium — every material choice must be reconsidered from the ground up.

### Ionic Radius and Its Consequences

The sodium ion Na⁺ has an ionic radius of **1.02 Å** in octahedral coordination; the lithium ion Li⁺ has a radius of **0.76 Å** in the same coordination. This 34% difference in radius is the most important single physical fact about SIBs. It has consequences at every level of the cell, from crystal structure to electrolyte to SEI.

At the crystal structure level, the larger Na⁺ ion requires larger interstitial sites in its host material. The sites in graphite's interlayer space — which are perfectly sized for Li⁺ — are simply too small and the interlayer interaction too strong for Na⁺ to intercalate at room temperature with useful reversibility. This is not a thermodynamic accident: the calculated staging energy for $\text{NaC}_6$ is positive (unfavourable) while for $\text{LiC}_6$ it is negative (favourable), reflecting the fact that the expanded interlayer spacing needed to accommodate Na⁺ costs more energy than is recovered from the Na-graphene interaction. Graphite is therefore not a viable anode for sodium-ion batteries under normal conditions, which is the single most important practical consequence of Na⁺'s larger size.

For cathode materials, the larger Na⁺ preference for larger coordination environments means that some crystal structures work better as sodium hosts than as lithium hosts, and vice versa. In particular, prismatic coordination (where the ion sits at the centre of a trigonal prism of six oxygen atoms) accommodates Na⁺ more comfortably than the octahedral coordination favoured by Li⁺ — this is the physical origin of the P2-type layered structure that is uniquely important in SIBs and has no significant lithium-ion analogue.

### Ionic Mass

Sodium is 23.0 g/mol; lithium is 6.941 g/mol — a factor of 3.3× heavier. For a fixed molar capacity (moles of ions cycled), the sodium-based electrode will contain 3.3× more mass from the charge carrier alone. This contributes directly to lower gravimetric specific capacity compared to lithium-based analogues, all else being equal. The magnitude of the penalty depends on what fraction of the electrode mass is the ion versus the host material, but it is always unfavourable.

### Standard Electrode Potential

As established in Chapter 1, the Na⁺/Na standard reduction potential is −2.71 V vs. SHE, compared to −3.04 V for Li⁺/Li — a difference of 0.33 V, with Na⁺/Na sitting higher on the reduction scale. The practical consequence: if you built the same cathode material twice, once as a lithium host and once as a sodium host, and paired each with its own alkali-metal anode, the sodium cell's open-circuit voltage would come out 0.33 V lower than the lithium cell's. That 0.33 V is a fixed contribution from the anode reference and cannot be undone by tuning the cathode side of the same material.

A careful reader will immediately object that real SIBs don't use sodium metal anodes and their cathodes aren't simple translations of lithium cathodes. That's right. In a commercial SIB, the anode is hard carbon (which sits ~0.05–0.2 V above the Na/Na⁺ reference), and the cathode is chosen for chemistry that works well with Na⁺, not for faithfulness to a lithium precedent. The net result is that the real cell-level voltage penalty relative to an equivalent LIB lands in the 0.3–0.5 V range rather than being exactly 0.33 V. The underlying 0.33 V anode-reference shift is the dominant piece, though, and it is the right number to keep in your head as the thermodynamic "cost of switching to sodium."

### Diffusion Coefficient in Solids

**Common misconception:** "The bigger, heavier ion must always diffuse more slowly." It sounds obvious — and for liquids and plasmas it's usually right — but in solid intercalation hosts it is not a theorem. In a solid, diffusion of an alkali ion is a sequence of thermally activated hops between discrete sites, and the rate depends on the *local* energy landscape: the size of the bottleneck the ion has to squeeze through, the depth of the site it is currently sitting in, and how those two compare to the ion's own size. If a host is tight around Li⁺ (small bottleneck, deep site) but loose around Na⁺ (wider bottleneck, shallower site), Na⁺ can actually hop *faster*. This is observed in several polyanionic and PBA frameworks where the channels are sized for the bigger ion. It is also part of why some solid electrolytes are excellent Na⁺ conductors despite being mediocre Li⁺ conductors.

For most of the well-studied *layered oxide* cathode families, however, the solid-state diffusion coefficient of Na⁺ turns out to be comparable to or somewhat lower than Li⁺ in the corresponding Li host — because the layered oxide structure evolved to be "optimal for Li⁺" and Na⁺ is being accommodated in a slightly too-small environment. The generalisation you should keep in your head is: *for a given host, Na⁺ may be faster or slower than Li⁺ depending on whether the host is oversized or undersized for the ion it's trying to move*. Do not carry over a generic "Na is slower" intuition from fluid chemistry.

The more interesting kinetic story is at the electrode-electrolyte interface. Before an ion can intercalate into a host, it has to shed the sheath of solvent molecules that surrounds it in the electrolyte — its solvation shell. The energy cost of stripping that shell is the **desolvation energy**, and it shows up as part of the activation barrier for charge transfer at the surface. First-principles calculations (Okoshi et al. and others) find, consistent with the simple picture, that Li⁺ binds ethylene carbonate more strongly than Na⁺ does — roughly 210 kJ/mol versus 160 kJ/mol per ion-solvent pair — because Li⁺ has higher charge density. On the desolvation axis alone, then, Na⁺ is actually *favoured*: it walks up to the interface with a less tightly held solvent shell.

Why, then, do SIBs typically show higher charge-transfer resistance and higher cell-level DCIR than comparable LIBs? The answer is not desolvation. It is a combination of other factors: (i) the bulk electrolyte conductivity is lower (we'll quantify this in the next subsection), (ii) the SEI on hard carbon is typically thicker and more resistive than the SEI on graphite, so the ion must traverse a longer and more tortuous solid-phase path before it can even reach the host, (iii) solid-state Na⁺ diffusion coefficients in many of the best-studied cathode lattices are modestly lower than the Li⁺ values in the corresponding Li host, and (iv) the same amount of charge has to be carried by heavier ions, so for equal current density more mass has to move. Taken together these effects more than offset the desolvation-energy advantage. The useful lesson here is one you'll encounter often in this field: every kinetic process has a multi-step pathway, and the rate-limiting step is not always where intuition puts it first. An EE parallel is the RC time constant of a signal path dominated by wire capacitance rather than transistor capacitance — you can't locate the bottleneck without walking the full loop.

One place where desolvation *does* visibly matter is in ether-based electrolytes. In diglyme (DEGDME) and related glymes, Na⁺ forms strongly coordinated, geometrically rigid solvation complexes with 2–3 glyme molecules, and under certain conditions it can intercalate into graphite *together with its solvent shell* (co-intercalation). On hard carbon, the result is a distinctively thinner, more inorganic-rich SEI and faster interfacial kinetics than in carbonate electrolytes — at the cost of a narrower electrochemical stability window. We'll return to this when we discuss ether electrolytes in Section 6.7.

### Electrolyte Considerations

SIB electrolytes are structurally similar to LIB electrolytes: a sodium salt dissolved in organic solvent(s), or in ethers. The dominant sodium salts are **NaPF₆** (sodium hexafluorophosphate, analogous to LiPF₆) and **NaClO₄** (sodium perchlorate, with no direct LIB analogue at high commercial use since LiClO₄ is less commonly used in LIBs due to explosion risk, though NaClO₄ is widely used in SIB research). NaFSI (sodium bis(fluorosulfonyl)imide) and NaTFSI are also studied for their improved conductivity and stability.

The same carbonate solvent blends used in LIBs (EC:DMC, EC:DEC, EC:DMC:EMC) are used in SIBs, though the optimum blend ratios differ because of the different solvation chemistry of Na⁺. One practical challenge: NaPF₆ has lower solubility in some carbonate mixtures than LiPF₆ at the same molarity, which limits achievable salt concentrations and ionic conductivity. The 1 M NaPF₆ in EC:DMC electrolyte commonly used in SIB research has an ionic conductivity of approximately 5–7 mS/cm at 25 °C, somewhat lower than the 10–12 mS/cm of 1 M LiPF₆ in EC:DMC.

### Why SIBs Survive Cold Better Than LIBs

The chapter opening mentioned the low-temperature advantage of SIBs as one of the properties that makes them attractive for grid and EV applications in cold climates. It is worth explaining briefly where this advantage comes from, because it will come up again in Section 6.5 and in Chapter 8.

Three physical effects stack in SIB's favour at low temperature. First, the lower desolvation energy of Na⁺ in carbonate electrolytes (discussed above) means that the charge-transfer activation barrier at the electrode-electrolyte interface is less temperature-sensitive than it is for Li⁺: at −20 °C, the ratio of $R_\text{ct}(-20°\text{C})/R_\text{ct}(+25°\text{C})$ is smaller for Na⁺ than for Li⁺. Second, the optimal SIB electrolyte formulations (including PC-containing blends that would exfoliate graphite but don't affect hard carbon) have lower liquidus temperatures than typical LIB electrolytes, so the electrolyte itself remains liquid and conductive to lower temperatures. Third, the hard carbon anode, with its broader distribution of sodium storage sites, appears to be less sensitive to low-temperature kinetic bottlenecks than graphite, which has a narrow set of staging transitions that become kinetically sluggish below −10 °C.

The net result is that commercial SIB cells like the HiNa BC-1 retain roughly 88% of room-temperature capacity at −20 °C and 70% at −40 °C, compared to 40–60% at −20 °C for typical commercial LIBs. This is not a marginal difference — it is the kind of gap that changes which chemistry you pick for winter-climate grid storage or for EV applications in northern latitudes. The mechanism discussion here will be picked up in Chapter 8 (thermal behaviour) and quantified more carefully there.

With this physical background established, we can now examine each SIB material family.

---

## 6.2 Cathodes: Layered Oxides — O3 and P2 Types

Layered transition metal oxides are the most studied and most commercially relevant SIB cathode family. They share the structural philosophy of LCO and NMC — a layered arrangement of transition metal oxide sheets separated by alkali-ion layers — but the larger Na⁺ ion and the different ionic radii of sodium relative to the host cations create a richer variety of stacking sequences and coordination geometries.

### The Structural Notation: O3, P2, P3, O2

The classification system for layered sodium transition metal oxides was established by Claude Delmas in the 1980s and is based on two descriptors. The first letter indicates the coordination environment of the sodium ion: **O** for octahedral, **P** for prismatic, **T** for tetrahedral (rare in battery materials). The number indicates how many oxide layers are in the repeating unit cell.

A brief historical aside: Claude Delmas and collaborators at Bordeaux developed this notation in 1980 precisely because the sodium layered oxides $\text{Na}_x\text{CoO}_2$ and $\text{Na}_x\text{MnO}_2$ turned out to have *more* stacking variants than anyone had found in the analogous lithium compounds, and there was no vocabulary to describe them cleanly. The notation was created to handle sodium's embarrassment of structural riches. It is telling that a system invented for sodium chemistry is now also used to describe analogous (if rarer) lithium layered oxide phases — the sodium world came first, historically, for layered oxide crystallography. This is a small example of the more general fact that SIB research is not a latecomer to battery chemistry — sodium intercalation chemistry was studied in parallel with lithium intercalation in the 1970s and 1980s, and was only abandoned commercially because lithium won the energy-density race. We are, in a sense, picking back up on a thread that was dropped forty years ago for reasons that no longer fully apply.

**O3 structure**: Sodium sits in octahedral sites; the unit cell contains three MO₂ layers per repeating unit (ABCABC stacking of the oxygen sublattice). This is the same structure as LCO — the $\alpha\text{-NaFeO}_2$ structure type. The O3 structure exists for many sodium compositions $\text{Na}_x\text{MO}_2$ near $x = 1$ (sodium-rich compositions).

**P2 structure**: Sodium sits in prismatic sites (six oxygen neighbours forming a trigonal prism rather than an octahedron); the unit cell contains two MO₂ layers per repeating unit (ABBA stacking). The P2 structure is found for sodium-deficient compositions, typically $x \approx 0.6\text{–}0.7$ in $\text{Na}_x\text{MO}_2$. There is no stable lithium analogue of the P2 structure because Li⁺ strongly prefers octahedral coordination and does not naturally form prismatic coordination with oxide layers.

**P3 structure**: Sodium in prismatic sites, three-layer repeating unit. Intermediate between O3 and P2.

**O2 structure**: Octahedral coordination, two-layer unit. Rare and metastable; studied mainly as a synthesis curiosity.

A schematic should help. Imagine looking sideways through a stack of transition-metal oxide slabs, with sodium layers sandwiched between them. The letters A, B, C refer to the in-plane position of the oxygen atoms in each slab — three distinguishable registration positions relative to a reference hexagonal lattice. "O" means the sodium sits in an octahedron of six oxygens; "P" means it sits in a trigonal prism of six oxygens. The prism and the octahedron both have six neighbours, but they differ in how those neighbours are arranged: in the octahedron, the two triangular faces of three oxygens are twisted 60° relative to each other; in the trigonal prism, they are eclipsed.

```text
     O3 (octahedral Na, ABCABC stacking)          P2 (prismatic Na, ABBA stacking)

 A  O─O─O─O─O─O─   [oxide slab]              A  O─O─O─O─O─O─   [oxide slab]
       •  •  •     Na in octahedra                 ▫  ▫  ▫     Na in trigonal prisms
 B  O─O─O─O─O─O─   [oxide slab]              B  O─O─O─O─O─O─   [oxide slab]
       •  •  •     Na
 C  O─O─O─O─O─O─   [oxide slab]              B  O─O─O─O─O─O─   [oxide slab]
       •  •  •     Na                              ▫  ▫  ▫     Na in trigonal prisms
 A  O─O─O─O─O─O─   [repeat]                  A  O─O─O─O─O─O─   [oxide slab]

 Oxygen faces twisted 60° between             Oxygen faces eclipsed across
 adjacent slabs: each Na sees a               adjacent slabs: each Na sees a
 twisted oxygen cage = octahedron.            straight oxygen cage = prism.
```

The practical consequence is what to look for in a research paper. When someone writes "$\text{Na}_{0.67}\text{MO}_2$, P2 type," they are telling you two things: (i) the sodium layers have *prismatic* coordination (which is more open and more tolerant of the big Na⁺ ion), and (ii) the oxide slabs stack in a two-layer A-B-B-A repeat (which means there is no twist between slabs, and the slabs can glide past each other more easily during sodium extraction). Both of these matter for the behaviour we'll see in a moment.

The notation also encodes the stacking sequence: ABCABC (O3), ABBA (P2), ABBCCA (P3). During electrochemical cycling, as sodium is extracted, the electrostatic repulsion between adjacent oxide layers changes, and transitions between these stacking sequences can occur — for instance, O3 materials often transition to P3 upon partial desodiation. These phase transitions are partially reversible and contribute to irreversible capacity loss and impedance growth during early cycles. Managing or suppressing these phase transitions is one of the central design goals for SIB layered oxide cathodes.

### O3-Type Layered Oxides

The O3 family starts with compositions close to $\text{NaMO}_2$ — sodium-rich, analogous to $\text{LiMO}_2$. The prototypical examples are $\text{NaCoO}_2$ (the sodium analogue of LCO), $\text{NaNiO}_2$, $\text{NaMnO}_2$, $\text{NaFeO}_2$, and multi-component variants.

$\text{NaCoO}_2$ has been studied since the 1970s (the famous Goodenough paper on LCO actually surveyed several alkali metal cobaltates). Its practical specific capacity as a SIB cathode is approximately 120–140 mAh/g, with an average voltage around 2.7–3.0 V vs. Na/Na⁺. The multiple phase transitions during cycling (O3 → O′3 → P3 → P′3 as sodium is extracted) produce a stepped, complex OCV curve and significant first-cycle irreversibility. Cobalt content makes $\text{NaCoO}_2$ expensive and reduces its commercial appeal for a cost-driven chemistry.

$\text{NaMnO}_2$ is attractive on cost grounds (manganese is cheap) but suffers from the same Mn³⁺ Jahn-Teller instability that plagues LMO: Mn³⁺ (d⁴ electronic configuration) undergoes a cooperative structural distortion that causes the lattice to distort asymmetrically (orthorhombic distortion from the ideal rhombohedral O3), and this distortion changes character during cycling, causing mechanical stress and capacity fade. Practical capacity is 140–185 mAh/g but cycle life is poor without modification.

**Multi-component O3 oxides** — where multiple transition metals are combined to average out the problematic behaviours of single-metal systems — are the most commercially relevant. The most prominent examples are O3-type $\text{NaNi}_{0.5}\text{Mn}_{0.5}\text{O}_2$, $\text{NaNi}_{0.33}\text{Mn}_{0.33}\text{Co}_{0.33}\text{O}_2$ (a direct structural analogue of NMC111 but for sodium), and more recent high-nickel variants. By carefully tuning the Ni:Mn:Co or Ni:Mn:Fe ratios, researchers can balance the contributions of each metal.

Each of these metals plays a different role in the composite electrode and is worth understanding on its own terms. Nickel is the workhorse — it carries most of the useful redox capacity through the Ni²⁺/Ni³⁺/Ni⁴⁺ couples and contributes the highest voltage of the common choices. Manganese is the structural scaffold: in its Mn⁴⁺ state it is electrochemically inert during normal cycling but holds the oxide layers together during sodium extraction and reinsertion, and its presence substantially improves cycle life. Iron is the cost-reduction move — cheap, abundant, and non-toxic — and it also contributes useful capacity through the Fe³⁺/Fe⁴⁺ couple near 3.3 V vs. Na/Na⁺, which lands conveniently in the operating voltage range. Cobalt, when present, improves electronic conductivity within the cathode particle (helping with rate capability) but comes with the familiar cost and supply-chain drawbacks and is therefore kept as low as possible in modern designs, often to zero. Copper, titanium, and a handful of other dopants are added in small quantities (a few mol%) to suppress specific phase transitions during deep desodiation — they don't carry useful capacity themselves, but they stabilise the host lattice enough to enable deeper cycling than the undoped material would tolerate.

A representative high-performing O3 composition from the research literature is **$\text{Na}[\text{Ni}_{0.4}\text{Fe}_{0.2}\text{Mn}_{0.4}]\text{O}_2$** — no cobalt, approximately 160–180 mAh/g practical capacity, 3.2 V average voltage, respectable cycle life (>200 cycles to 80% at room temperature). This kind of cobalt-free, iron-containing multi-metal O3 oxide is the direction in which SIB commercial development is heading, and several companies (HiNa, CATL) have commercialised cells based on closely related compositions.

The cycle life challenge for O3 oxides is the **O3-P3 phase transition** that occurs during deep desodiation. When sodium content drops below about $x = 0.75$ in $\text{Na}_x\text{MO}_2$, the stacking of MO₂ layers rearranges from the O3 sequence to a P3 sequence — the transition metal oxide layers glide relative to each other. This gliding is partially irreversible and introduces structural defects. Limiting the upper charge voltage (and thus the depth of desodiation) suppresses this transition but reduces accessible capacity. Finding O3 compositions that suppress the O3→P3 transition while maintaining high capacity is a major ongoing research challenge.

### P2-Type Layered Oxides

P2-type layered oxides are arguably the most distinctive and scientifically interesting cathode material unique to sodium-ion batteries. Their prismatic sodium coordination — for which there is no good lithium analogue — produces a set of properties that make them complementary to O3 oxides.

The prototypical P2 compositions are $\text{Na}_x\text{MnO}_2$, $\text{Na}_x\text{CoO}_2$, and multi-metal $\text{Na}_x[\text{Ni}_y\text{Mn}_{1-y}]\text{O}_2$ systems, all with sodium content $x \approx 0.6\text{–}0.7$ in the fully sodiated state. The most studied and commercially relevant P2 cathode is **P2-$\text{Na}_{0.67}[\text{Mn}_{0.5}\text{Ni}_{0.5}]\text{O}_2$**, first systematically characterised by Dahn's group and subsequently by many others.

The P2 structure has several intrinsic advantages relative to O3. Because sodium already starts at a non-stoichiometric, sodium-deficient composition ($x \approx 0.67$), there is no O3→P3 phase transition during desodiation — P2 material can be desodiated from $x = 0.67$ down to $x \approx 0.2$ without a destructive stacking rearrangement (though other phase transitions do occur). The prismatic sites are larger and accommodate Na⁺ more comfortably than octahedral sites, which correlates with better ionic mobility within the layers.

The disadvantage of P2 is that it starts at $x \approx 0.67$ — there is already a sodium vacancy in every three sodium sites. That matters for full-cell design. Think of the full cell as a shared sodium budget: every sodium ion that ends up cycling between electrodes has to be paid for at manufacture time, either by the cathode (which starts out sodiated and gives up sodium during the first charge) or by the anode (which could in principle start out sodiated too, as in a prelithiated or presodiated anode). In a conventional full cell, the cathode is the sodium reservoir and the anode starts empty. For an O3 cathode sitting near $x = 1$, that reservoir is nearly full and the anode can be fully loaded on the first discharge without any drama. For a P2 cathode starting at $x \approx 0.67$, the reservoir is already one-third empty from the outset: there are simply fewer sodium ions available to move into the hard carbon on the first discharge than there are sites in the hard carbon to receive them. The practical consequence is that **P2/hard carbon full cells must be balanced differently from O3/hard carbon cells**. Either the cell is oversized on the cathode side to compensate, or the anode is presodiated at manufacture time (an expensive extra step), or the cell operates with a hard carbon that is deliberately less than fully loaded — accepting a lower effective anode capacity in exchange for the P2 cathode's structural advantages. This is one of the places where SIB cell engineering starts to diverge meaningfully from LIB cell engineering.

The most commercially important P2 composition for SIBs is the $\text{Na}_{0.67}[\text{Mn}_{0.5}\text{Ni}_{0.5}]\text{O}_2$ family and its copper- and titanium-substituted variants. Copper substitution ($\text{Na}_{0.67}[\text{Cu}_{0.11}\text{Mn}_{0.78}\text{Ni}_{0.11}]\text{O}_2$ and similar) suppresses specific phase transitions and improves cycle life; titanium substitution improves structural stability during deep cycling. Practical specific capacity for optimised P2 oxides is approximately 120–160 mAh/g, average voltage approximately 3.2–3.5 V vs. Na/Na⁺.

**Students sometimes ask why both O3 and P2 cathodes are being developed in parallel rather than one being obviously superior.** The answer is that they are complementary in their charge/discharge profiles. O3 materials have a higher average voltage and can deliver more of their capacity at high voltage, which is desirable for energy density. P2 materials have better structural stability during deep cycling and better rate capability in some compositions. Blended cathode electrodes containing both O3 and P2 phases — or graded particles with a P2 core and O3 shell — are being explored to combine the advantages of both.

---

## 6.3 Cathodes: Polyanionic Frameworks — NVPF, NFPP, and Related

Polyanionic cathodes for sodium-ion batteries are the sodium-world equivalent of LFP. They use the **inductive effect** of a complex anion framework to tune the transition metal redox potential upward, and they gain structural stability and safety from the strongly covalent polyanion bonds that lock oxygen into the lattice even under extreme conditions.

It's worth pausing on the inductive effect, because it is one of the handful of chemistry concepts that really does most of the work in cathode design and will come back repeatedly. The idea is this. In a simple oxide like $\text{NaCoO}_2$, the redox couple that matters is Co³⁺/Co⁴⁺, and the voltage of the cell depends on how tightly the cobalt holds onto its outermost electron. "Tightly" here means: how much energy does it cost to extract that electron? If we surround cobalt with six oxygens in a layered oxide, the cobalt-oxygen bond has a certain degree of covalency, and electrons delocalise a bit onto the oxygen. That lowers the effective electron affinity of cobalt, pinning the Co³⁺/Co⁴⁺ redox couple at some particular absolute energy (about 2.7–3.0 V vs. Na/Na⁺ for $\text{NaCoO}_2$).

Now replace one of those oxygens with an oxygen that is *also* strongly bonded to a highly electronegative neighbour — a phosphorus in a phosphate group, or a fluorine in a fluorophosphate. That oxygen is now being pulled on from two sides: the cobalt on one side, the phosphorus (or fluorine) on the other. Phosphorus is more electronegative than cobalt, so it wins — the oxygen's electron density shifts away from the metal and toward the phosphate. The metal-oxygen bond becomes more ionic, less covalent. The electrons on the metal are less screened, more tightly localised, and harder to extract. The M²⁺/M³⁺ redox couple gets pushed up in voltage.

That's the inductive effect: the electron-withdrawing phosphate or fluorophosphate group "inductively" pulls charge density away from the metal-oxygen bond, and the voltage of the cathode rises as a consequence. It's why LFP (Fe²⁺/Fe³⁺ in a phosphate framework) sits at 3.4 V vs. Li/Li⁺ while the same Fe²⁺/Fe³⁺ couple in an iron oxide sits at ~2.0 V. It's why NVPF sits at 3.7 V and 4.2 V vs. Na/Na⁺ while the V³⁺/V⁴⁺ couple in a simple vanadium oxide sits much lower. And it's why, for polyanionic cathodes, adding more electron-withdrawing groups (replacing a $\text{PO}_4$ with a $\text{P}_2\text{O}_7$ or adding F⁻) is a knob for raising the voltage at the cost of mass.

An EE analogy that is imperfect but useful: the inductive effect acts a bit like a DC level shift on an op-amp output. You pick the redox couple for your capacity (the "signal"), and you pick the polyanion for your voltage offset (the "bias"). Every battery chemist is at some level tuning this offset.

### NVPF: Sodium Vanadium Fluorophosphate

**NVPF** — **Na₃V₂(PO₄)₂F₃**, sodium vanadium fluorophosphate — is widely considered the highest-performing SIB polyanionic cathode currently in research use, and is the basis of Tiamat's commercial SIB cells in France.

NVPF has a three-dimensional open framework structure with large channels for Na⁺ ion transport (better than the one-dimensional channels of LFP). The compound contains vanadium in the V³⁺ oxidation state in the fully sodiated form. During charging, two sodium ions per formula unit are extracted, and vanadium is oxidised from V³⁺ to V⁴⁺ (and partially to V⁵⁺ at higher voltages):

$$\text{Na}_3\text{V}_2(\text{PO}_4)_2\text{F}_3 \rightarrow \text{NaV}_2(\text{PO}_4)_2\text{F}_3 + 2\text{Na}^+ + 2e^- \tag{6.1}$$

To pin down the theoretical specific capacity, we use the same Faraday's-law recipe from Chapter 1. Two sodium ions are extracted per formula unit (so $n = 2$), and the molar mass of $\text{Na}_3\text{V}_2(\text{PO}_4)_2\text{F}_3$ works out to $3(22.99) + 2(50.94) + 2(30.97) + 8(16.00) + 3(19.00) = 417.8$ g/mol. The theoretical gravimetric capacity is therefore

$$C_\text{th} = \frac{nF}{3.6\,M} = \frac{2 \times 96485\,\text{C/mol}}{3.6 \times 417.8\,\text{g/mol}} \approx 128.3\,\text{mAh/g} \tag{6.2}$$

where the factor of 3.6 converts coulombs to milliamp-hours (1 mAh = 3.6 C). This is already lower than the layered oxides on a per-gram basis, but the key advantage of NVPF is its **high voltage**: the two-sodium extraction occurs at two distinct plateaux, at approximately 3.7 V and 4.2 V vs. Na/Na⁺ respectively. The average voltage of approximately 3.95 V vs. Na/Na⁺ is the highest of any widely studied SIB cathode — significantly above the layered oxide average of 3.2–3.5 V.

The combination of high voltage and good structural stability gives NVPF an excellent specific energy (approximately 480 Wh/kg at the material level, or roughly 110–130 Wh/kg at the cell level) and exceptional rate capability: the three-dimensional channels allow rapid Na⁺ diffusion, and NVPF cells have been demonstrated at rates up to 10C with good capacity retention. The Tiamat 18650 SIB cell using NVPF achieves approximately 90% capacity retention at 10C versus C/5 — power density comparable to LTO with significantly higher energy density.

The drawbacks of NVPF are **vanadium toxicity** (V compounds are environmentally regulated in many jurisdictions, adding manufacturing and disposal costs), and the somewhat lower gravimetric capacity compared to layered oxides. The vanadium issue is a genuine commercial obstacle and has motivated search for vanadium-free polyanionic alternatives.

### NVP: Na₃V₂(PO₄)₃

**NVP** — sodium vanadium phosphate, Na₃V₂(PO₄)₃ — is the fluorine-free analogue of NVPF. It has the NASICON crystal structure — a three-dimensional framework of corner-sharing VO₆ octahedra and PO₄ tetrahedra named after the fast sodium ion conductor Na₁₊ₓZr₂SiₓP₃₋ₓO₁₂ (NASICON = Sodium Super Ionic CONductor). The NASICON framework has particularly wide and open channels for Na⁺ transport, giving excellent ionic conductivity even in the solid state.

NVP delivers approximately 117 mAh/g theoretical specific capacity at a single flat plateau of approximately 3.4 V vs. Na/Na⁺, based on the V³⁺/V⁴⁺ redox couple. The flat plateau is thermodynamically analogous to LFP — NVP undergoes a two-phase reaction between $\text{Na}_1\text{V}_2(\text{PO}_4)_3$ and $\text{Na}_3\text{V}_2(\text{PO}_4)_3$ — and carries the same OCV estimation challenge. Like NVPF, NVP faces the vanadium toxicity issue.

### NFPP: Na₄Fe₃(PO₄)₂(P₂O₇) and Related

**NFPP** (Na₄Fe₃(PO₄)₂(P₂O₇)) and related iron-based polyanionic cathodes represent the most promising avenue for cobalt-free, nickel-free, vanadium-free SIB cathodes. NFPP is based entirely on iron (abundant, cheap, non-toxic) and has a mixed phosphate/pyrophosphate structure.

The electrochemistry of NFPP involves two sets of Fe²⁺/Fe³⁺ redox reactions at approximately 2.9 V and 3.2 V vs. Na/Na⁺, giving an average voltage of about 3.1 V. The theoretical specific capacity is approximately 129 mAh/g. NFPP was first reported as a sodium-ion cathode by Kim et al. (*Energy & Environmental Science*, 2013), and it has been under sustained academic development ever since. Commercial cells based on it or on closely related mixed phosphate/pyrophosphate compositions have only recently begun to appear — the scale-up gap between lab report and commercial cell is typical of polyanionic cathodes, where the challenge is less "does it work" than "can you coat, calendar, and cycle it consistently at GWh scale." Its advantages: no toxicity concerns, no critical materials, low raw material cost, reasonable capacity, good structural stability. Its disadvantage: relatively low voltage compared to NVPF or the layered oxides, which limits energy density.

**NASICON-structured Na₃MnTi(PO₄)₃** and similar manganese-titanium NASICON compounds are also attracting attention as vanadium-free, cobalt-free alternatives with voltage profiles intermediate between NFPP and NVPF. This is an active research frontier as of the mid-2020s.

### General Advantages of Polyanionic SIB Cathodes

Relative to layered oxides, all polyanionic SIB cathodes share several advantages: thermal stability is superior (the strong covalent polyanion framework resists oxygen release at high temperature), cycle life is generally better (the rigid framework accommodates the small volume changes during sodiation/desodiation without structural fatigue), and voltage profiles are often flat or step-wise (clean two-phase reactions, thermodynamically well-defined). The flat voltage profile is scientifically clean but practically challenging for SOC estimation — the same issue as LFP in the lithium world.

The disadvantages are also shared: lower gravimetric specific capacity than layered oxides (the heavy polyanion occupies mass without contributing to capacity) and lower electronic conductivity (requiring carbon coating and nanostructuring, exactly as for LFP).

---

## 6.4 Cathodes: Prussian Blue Analogues (PBAs)

**Prussian blue analogues (PBAs)** are an unusual but commercially important SIB cathode family with no significant equivalent in the lithium-ion world (they can intercalate lithium, but the cell voltage and capacity are not competitive).

### Structure

Prussian blue itself is the compound Fe₄[Fe(CN)₆]₃ — the intensely blue pigment first synthesised around 1704 and still used in artists' paints today. Its crystal structure is an open three-dimensional framework built from two kinds of iron site linked by cyanide. Imagine a simple cubic lattice whose corners alternate between "high-spin" Fe (call it the M′ site) and "low-spin" Fe (the M site, sitting inside the carbon-coordinated [Fe(CN)₆] group). Along every edge of that cube lies a straight M′–N≡C–M bridge: the nitrogen end of cyanide binds M′, the carbon end binds M, and the bond is essentially linear. The result is a rigid scaffolding in which each metal sits at a cube corner and is octahedrally coordinated by six cyanide ligands, with the cyanide groups forming the twelve edges of each cubic subcell.

The alkali ions live inside the empty cubic cavities — one cavity per M/M′ cube, sitting at the body-centre position. Because the Fe–N≡C–Fe bridge is long (roughly 5 Å between neighbouring metal centres, compared with ~2.9 Å M–O–M in a layered oxide), these cavities are *large* — considerably larger than the interstitial sites in any layered oxide or olivine. They accommodate Na⁺ comfortably, can also host K⁺ (which is larger still) and even Cs⁺ in some analogues, and the three open faces of each cavity connect to the neighbouring cavities to form three-dimensional diffusion channels that are wide and unobstructed. This is why PBAs are rate-capability outliers among battery cathodes: the ions are moving through what is essentially a molecular sieve rather than squeezing between close-packed oxide layers.

The general formula for battery-relevant PBAs is $\text{Na}_x\text{M}'[\text{M}(\text{CN})_6]_{1-y} \cdot \square_y \cdot n\text{H}_2\text{O}$, where M′ and M are transition metals (typically combinations of Fe, Mn, Co, Ni, Cu), $\square$ represents hexacyanometalate vacancies (sites where [M(CN)₆] groups are missing), and $n\text{H}_2\text{O}$ represents coordinated and zeolitic water molecules.

### Electrochemistry

The redox activity in PBAs comes from the transition metal ions in both the M′ and M positions. For iron-based PBAs (the most studied), both Fe²⁺/Fe³⁺ at the M site and Fe²⁺/Fe³⁺ at the M′ site are electrochemically active, though at different voltages (due to different crystal field splitting in the two environments). This can give two distinct plateaux — one at approximately 3.0 V and one at 3.4 V vs. Na/Na⁺ for iron-based PBAs — and a combined theoretical specific capacity of approximately 170 mAh/g. In practice, the presence of vacancies ($\square$) and water reduces the accessible capacity to approximately 100–150 mAh/g for state-of-the-art PBA cathodes.

**Natron Energy** (formerly Alveo Energy) has commercialised PBA-based SIB cells using Na₂MnFe(CN)₆ (manganese iron PBA) in aqueous electrolyte for ultra-high-rate, ultra-long-life applications (grid frequency regulation, data centre backup power). Their cells achieve cycle lives of tens of thousands of cycles at very high C-rates (10C–40C) — exceeding even LTO in lifetime and rate capability — though with lower energy density.

### The Water Problem

The practical challenge with PBAs is water. The open PBA framework strongly adsorbs water: both coordinated water (directly bound to transition metal sites that lack a cyanide ligand, due to vacancies) and zeolitic water (residing in the open channels). Water in the electrode reacts with the sodium electrolyte, consumes sodium (forming NaOH), and accelerates capacity fade. Controlling the water content of PBA cathodes — through careful synthesis conditions (dry room, controlled humidity synthesis), thermal treatment, and electrolyte additives — is the central manufacturing challenge for PBA-based SIBs. We'll return to water-induced PBA degradation in Chapter 7, where it serves as one of the examples of a degradation mode that is genuinely unique to sodium-ion — there is no meaningful LIB analogue of PBA water uptake because PBAs are not competitive LIB cathodes.

Solving the water problem is the key to unlocking PBA's natural advantages: the very low cost of iron hexacyanide precursors, the high theoretical capacity, and the excellent rate capability from the wide three-dimensional channels. Commercial PBA cells from Natron and from Altris AB (a Swedish company using the iron-only PBA Prussian white Na₂Fe[Fe(CN)₆] as a cathode) represent the current state of the art in PBA commercialisation.

**Prussian white** (Na₂Fe[Fe(CN)₆], fully sodiated iron-only PBA) is particularly interesting because it contains only iron, is completely cobalt-free and nickel-free, can be synthesised at room temperature in aqueous conditions (extremely low manufacturing energy and cost), and has a theoretical specific capacity of approximately 170 mAh/g. Altris AB is developing Prussian white-based SIBs specifically for the Nordic grid storage market. The primary remaining challenges are water content control and the relatively modest operating voltage (average ~3.1 V vs. Na/Na⁺).

### Cathode Family Summary

Before we move on to anodes, it is worth collecting the three SIB cathode families into a single reference table. The numbers below are representative of state-of-the-art research-grade and early-commercial materials as of 2024–2025; specific cells will deviate, sometimes significantly.

| Family | Representative | Avg. voltage (V vs. Na/Na⁺) | Practical capacity (mAh/g) | Specific energy, material level (Wh/kg) | Rate | Cycle life | Cost drivers | Main open problem |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| O3 layered oxide | Na[Ni,Fe,Mn]O₂ | 3.2–3.4 | 140–180 | 450–600 | Moderate | Moderate | Ni, sometimes Co | O3→P3 phase transition |
| P2 layered oxide | Na₀.₆₇[Mn,Ni]O₂ | 3.3–3.5 | 120–160 | 400–560 | Moderate–good | Moderate–good | Ni, Mn | Starts Na-deficient; balance/presodiation |
| Polyanionic (NVPF) | Na₃V₂(PO₄)₂F₃ | ~3.95 | ~120 | ~480 | Excellent | Excellent | V (toxic, regulated) | V dependence |
| Polyanionic (NFPP) | Na₄Fe₃(PO₄)₂P₂O₇ | ~3.1 | ~120 | ~370 | Good | Good | Fe only (cheap) | Modest voltage; low conductivity |
| PBA (Fe-only, Prussian white) | Na₂Fe[Fe(CN)₆] | ~3.1 | 100–170 | 310–530 | Excellent | Excellent | Fe, cyanide | Water uptake, vacancies |
| PBA (Mn-Fe, aqueous) | Na₂MnFe(CN)₆ | ~1.4 (vs. anode) | ~60 | ~80 (full cell) | Exceptional (60C) | Exceptional (>50,000 cycles) | Fe, Mn, cyanide | Low voltage, low energy density |

Two patterns stand out. First, the three families occupy clearly different positions on the rate–energy–cost trade-off surface: layered oxides are the default high-capacity choice, polyanionics (NVPF in particular) trade some capacity for very high voltage and rate capability, and PBAs trade some voltage and capacity for exceptional rate and cycle life. Second, the cost-driver column is the one most likely to change commercial decisions: a cathode that requires vanadium or cobalt has a harder path to grid-scale manufacturing than a cathode that runs on iron. This is the reason you see so much effort on Fe-only variants of every family.

---

## 6.5 Anodes: Hard Carbon — The Dominant Choice

The anode side of a sodium-ion cell is simpler than the cathode side in terms of material options, because most of the alternatives that work for lithium (silicon, LTO) do not translate cleanly to sodium. **Hard carbon** is the overwhelmingly dominant SIB anode material, used in essentially all commercial SIB cells today.

### What Hard Carbon Is

**Hard carbon** is a disordered, non-graphitic carbon material produced by pyrolysis of organic precursors at intermediate temperatures, typically 1000–1500 °C. It is also sometimes called **turbostratic carbon** — "turbostratic" meaning that adjacent graphene-like sheets are stacked without a fixed rotational alignment. Unlike graphite, where each sheet is registered to the one above and below in the familiar ABAB (or ABCABC for rhombohedral graphite) pattern, the sheets in a turbostratic carbon are twisted randomly relative to each other, so the stacking has no long-range order perpendicular to the basal plane. This looks minor but it has large consequences: the interlayer spacing is wider and more variable than in graphite (~0.37–0.40 nm rather than 0.335 nm), and the electronic and ionic behaviour inside those spaces is fundamentally different from perfectly stacked graphite. The material is called "hard" because (unlike "soft carbon" or graphitisable carbon) it cannot be converted to graphite by further heat treatment — the cross-linking between the disordered sheets prevents the graphitisation ordering process.

The disordered structure creates two types of microstructural feature that are directly relevant to sodium storage:

**Turbostratic micropores** between the randomly stacked graphene-like layers: these are open pores (accessible to the electrolyte) with a width of approximately 0.37–0.42 nm — slightly larger than the interlayer spacing of graphite (0.335 nm) and accessible to Na⁺. Sodium can intercalate into these layers, following kinetics and thermodynamics similar to graphite intercalation but at lower capacity because the disordered stacking provides fewer well-defined staging sites.

**Closed nanopores** between microcrystallite domains: these are nano-scale voids (typically 1–5 nm diameter) that are completely enclosed by the carbon structure and inaccessible to the liquid electrolyte. Sodium can accumulate in these pores, but only as quasi-metallic sodium clusters (the environment is similar to sodium in a very confined space — the activity of sodium in the nanopores is close to 1, the activity of sodium metal). This is the "nanopore filling" mechanism.

### The Slope and Plateau Regions

The electrochemical storage of sodium in hard carbon produces a distinctive OCV profile that we introduced briefly in Chapters 1 and 3 but now deserves a full physical explanation. During sodiation (charging the anode), the voltage profile has two distinct regions:

**The slope region** (from approximately 1.5 V to 0.1 V vs. Na/Na⁺, accounting for approximately 150–200 mAh/g of capacity): Voltage decreases continuously with increasing sodium content, following a single-phase (solid-solution-like) behaviour. Sodium is being adsorbed onto defect sites and surface functional groups at high potential and is progressively intercalating into the turbostratic interlayer spaces at lower potential. Because the sodium activity changes continuously with site occupancy in these disordered environments, the Nernst equation predicts a continuous potential variation — a slope. This is directly analogous to the slope region in NMC cathodes (single-phase behaviour, varying Na/vacancy ratio).

**The plateau region** (from approximately 0.1 V to ~0.01 V vs. Na/Na⁺, accounting for approximately 50–100 mAh/g): Voltage is nearly constant, reminiscent of LFP's flat plateau. The physical origin, in the Stevens-Dahn picture, is pore-filling: sodium accumulates inside the closed nanopores as quasi-metallic clusters. Here's why that produces a flat voltage.

Recall the Nernst equation for the half-reaction Na⁺ + e⁻ → Na (in some host environment):

$$E = E^\circ - \frac{RT}{F}\ln \frac{a_\text{Na(host)}}{a_{\text{Na}^+}} \tag{6.4}$$

where $a_\text{Na(host)}$ is the activity of stored sodium inside the host — a dimensionless measure of how "free" the sodium behaves, equal to 1 for sodium metal and less than 1 for sodium bound in an intercalation site. $a_{\text{Na}^+}$ is the activity of sodium ion in the electrolyte, effectively constant during a slow measurement.

Now, when we're measuring a half-cell OCV curve against a sodium metal reference electrode, we're asking "what is the potential of the working electrode relative to metallic sodium?" If the sodium stored in the working electrode happens to behave *exactly* like metallic sodium — same activity, same chemical environment — then $a_\text{Na(host)} = a_\text{Na(metal)} = 1$, and the Nernst equation gives $E = E^\circ = 0$ V vs. Na/Na⁺. The potential of the working electrode equals the potential of the reference electrode, because they are chemically indistinguishable.

Pore-filled quasi-metallic sodium clusters aren't quite metallic sodium — they are finite, confined, and surface-dominated — but they are close enough that their activity stays very near 1 throughout the filling process. As more sodium pours into the pores, the activity doesn't change appreciably, and therefore $E$ doesn't change appreciably. That is the flat plateau: a process during which one of the state variables in the Nernst equation is pinned at its limiting value.

Contrast this with the slope region, where the stored sodium is in a range of crystallographic sites at varying occupancies and its activity changes continuously as more sodium is added. Continuously varying activity inside the logarithm gives continuously varying potential — a slope. The two regions are thermodynamically distinct: the slope is single-phase solid-solution behaviour, and the plateau is pore-filling into a second phase whose activity is pinned by confinement.

This physical picture — intercalation between turbostratic layers for the slope, and pore filling by quasi-metallic sodium clusters for the plateau — is the original "falling card" / "house of cards" model proposed by Stevens and Dahn around 2000–2001. It is the model you'll encounter first in almost every SIB review and it captures the essential qualitative shape of the voltage curve, which is why we use it here.

It is worth flagging that the modern view is more nuanced. Work from 2018 onward — combining operando ²³Na NMR, SAXS, dilatometry, and DFT from groups including Tarascon, Palacín, Adelhelm, and Ji — indicates that the plateau capacity is almost certainly a *mixture* of several storage motifs: sodium adsorbed on pore walls and surface defects, quasi-metallic clusters in the closed pores, and, in some hard carbons, intercalation into unusually narrow interlayer galleries that are thermodynamically distinct from the slope region. The exact balance of these contributions depends on the precursor and the carbonisation temperature, and is still being debated in the literature as of 2025. For your purposes in this book, the Stevens-Dahn two-region picture is good enough to predict the shape of the voltage curve and to reason about BMS consequences. If you end up doing simulation research on hard carbon specifically, expect to spend time on the more detailed mechanistic literature.

**Common misconception:** the fact that the plateau sits near 0 V vs. Na/Na⁺ does *not* mean that sodium metal plates on the hard carbon surface during normal operation. Pore-filled quasi-metallic clusters inside closed nanopores are thermodynamically and kinetically quite different from macroscopic sodium metal on an exposed surface. Plating is a separate failure mode, and we'll discuss it in Chapter 7.

The mechanistic distinction matters practically in another way too: the slope region sodium is more readily de-sodiated than the plateau region sodium (the plateau-region sodium is more tightly confined in the pores and requires a larger driving force to remove). This contributes to the rate-capability asymmetry of hard carbon: it charges the slope region more easily than the plateau at high rates.

### The Flat Plateau: Implications for BMS

The plateau region of hard carbon — occupying anywhere from 20% to 50% of total capacity depending on material and processing — sits very close to 0 V vs. Na/Na⁺. In a full SIB cell (hard carbon anode paired with a layered oxide or polyanionic cathode), the full cell OCV is:

$$E_\text{OCV,cell} = E_\text{cathode}(\text{SOC}) - E_\text{anode}(\text{SOC}) \tag{6.3}$$

The cathode voltage typically slopes from about 3.5 V to about 2.5 V vs. Na/Na⁺ during discharge. The anode voltage during the plateau region is nearly constant at ~0.05 V vs. Na/Na⁺. Therefore, during the fraction of discharge that corresponds to the anode plateau, the cell OCV is nearly flat at whatever the cathode voltage is at that point in discharge. For a layered oxide cathode that is itself relatively flat at intermediate SOC, both curves conspire to create a nearly flat full-cell OCV region that can span 30–50% of total capacity.

This is the "flat OCV" problem for SIB state-of-charge estimation that we have referenced repeatedly since Chapter 3. It is a more severe version of a problem you already know about from LFP.

For LFP/graphite, the flat LFP plateau is paired with a graphite anode whose own OCV curve consists of a sequence of short plateaus at roughly 85, 125, and 220 mV vs. Li/Li⁺ (the graphite staging transitions), linked by narrow sloped regions. The full-cell LFP/graphite OCV curve inherits this structure: it is dominantly flat with a handful of small ripples contributed by the graphite steps. This is already infamous among LIB BMS designers as the archetypal "flat OCV" problem, and a sizeable industry of online capacity estimators and incremental capacity analysis techniques has grown up around it.

For SIB, the situation is worse in two small but consequential ways. First, the hard carbon plateau sits much closer to 0 V vs. Na/Na⁺ (roughly 50 mV) than any of graphite's steps, so the anode contributes effectively zero useful voltage variation over a very wide SOC range. Second, hard carbon's plateau is a single continuous near-isothermal transition rather than a sequence of staging steps — the small ripples that give LFP/graphite a foothold for incremental capacity analysis are missing in hard carbon. Paired with a cathode that is itself relatively flat in mid-SOC (both O3 layered oxides and polyanionic cathodes are flatter than NMC in the middle of the curve), the combined full-cell OCV can span 30–50% of capacity with single-digit millivolts of range. This is the regime in which voltage-based SOC estimation simply ceases to work, and in which coulomb-counting accuracy becomes the dominant error source.

The consequence for BMS design is severe. In the language of state estimation, which we'll develop properly in Chapter 10, the flat-OCV region is an **observability failure**: the output of the system (the terminal voltage) contains almost no information about the state (SOC). You can integrate current to track SOC by coulomb counting — that part is a pure open-loop integrator — but you have no way to correct the integrator's drift from voltage measurements alone while the cell is inside the flat region. It is exactly analogous to trying to estimate the position of a mechanical system when your only sensor is a velocity meter, or trying to estimate the charge on a capacitor that has been momentarily disconnected from the rest of the circuit: you know how much charge has flowed in and out since the last observation, but there is no direct readout of the absolute state.

Practical SIB BMS designs work around this by combining three things: (i) current integration through the flat region, (ii) whatever small voltage variation remains — even sub-millivolt trends can be exploited with careful calibration and temperature compensation, and (iii) anchor points at the edges of the flat region where the OCV starts to slope again, which provide the "observations" that the estimator's correction step needs. The accuracy of coulomb counting across the unobservable interval depends critically on current-sensor accuracy and on the stability of the cell's Coulombic efficiency, because any small bias in either one integrates into an ever-growing SOC error. We'll see in Chapter 10 that this is the single most important algorithmic difference between LFP/SIB BMS design and NMC/NCA BMS design.

### Hard Carbon Performance Metrics

Representative performance metrics for state-of-the-art commercial-grade hard carbon anodes (as of 2024–2025) are summarised in the table below. All values are for hard carbons optimised for sodium storage, typically biomass- or sucrose-derived and carbonised at 1100–1400 °C.

| Metric | Typical range | Notes |
| --- | --- | --- |
| Practical specific capacity (mAh/g) | 250–350 | Slope + plateau combined; higher values for carbons with larger closed-pore fraction |
| Initial Coulombic efficiency (%) | 75–90 | Lower than graphite (85–95%) due to higher BET surface area (5–15 m²/g vs. 1–4 m²/g for synthetic graphite) and correspondingly more SEI formation |
| Average anode potential (V vs. Na/Na⁺) | ~0.2 | Weighted average across slope and plateau; the plateau itself sits at ~0.05 V |
| Rate capability, 1C vs. C/10 (%) | 80–90 | Commercial-quality hard carbons |
| Rate capability, 5C vs. C/10 (%) | 60–70 | Drops off faster than graphite |
| Cycle life (cycles to 80% retention) | 500–2000+ | Strongly dependent on electrolyte formulation, voltage window, and temperature |

The ICE gap between hard carbon (75–90%) and graphite (85–95%) is one of the most actively worked-on problems in SIB materials science, because every percentage point of ICE translates directly to pack-level energy density — a 5% ICE loss on the anode is a 5% energy penalty at the cell level that no amount of cathode optimisation can recover.

### Pre-sodiation: A Fix for the ICE Problem

One approach to the low-ICE problem of hard carbon deserves explicit mention. **Pre-sodiation** is the practice of loading extra sodium into the cell at manufacture time so that the irreversible loss to SEI formation during the first cycle does not come out of the reversible sodium inventory. In practice, pre-sodiation can be done in several ways: by adding a sacrificial sodium-rich additive to the cathode (for example, an organic sodium salt that releases Na⁺ on the first charge and is then inert), by using a slightly sodium-rich cathode composition to begin with, by making direct chemical contact with sodium metal during electrode assembly (expensive and process-hostile), or by pre-cycling the anode against a sodium reference before assembly (also process-hostile). The sacrificial-additive approach is the most commercially viable today and is used in some research SIB cells to push ICE from the baseline 78–85% into the 90–95% range.

Pre-sodiation is the SIB analogue of prelithiation in LIBs, which is itself an active research area for silicon anodes. The core accounting is the same: the first-cycle sodium (or lithium) loss to SEI is a permanent tax on the cell's energy density, and pre-loading extra alkali metal at manufacture time buys that energy density back at the cost of some manufacturing complexity. Whether this trade is worth it depends on how much ICE gap remains after electrolyte optimisation — as hard carbon ICE keeps improving, the economic case for pre-sodiation gets weaker.

### Hard Carbon Precursors and Synthesis

The properties of hard carbon — especially the ratio of closed to open pore volume, the interlayer spacing, and the surface chemistry — are controlled by the choice of precursor material and the carbonisation temperature. Common precursors include cellulose and biomass-derived carbons (glucose, sucrose, phenolic resins, waste agricultural products), which are inexpensive and environmentally attractive, and whose relatively high oxygen content in the precursor creates defects and functional groups in the final carbon that can enhance sodium storage capacity — the specific capacity of biomass-derived hard carbon can reach 300–350 mAh/g. Polyacrylonitrile (PAN), similar to the precursor used for structural carbon fibre, gives hard carbon with moderate surface area and a well-controlled pore structure and is often used in research because the synthesis conditions are reproducible. Petroleum-derived resins are used in some commercial processes for cost and scale reasons.

The carbonisation temperature profoundly affects the closed/open pore ratio: temperatures below approximately 1000 °C produce carbons with many open pores but small interlayer spacing; temperatures above approximately 1400–1600 °C produce carbons with larger interlayer spacing and higher closed pore fraction but also with some graphitisation at crystallite edges that reduces surface area and thus SEI formation. Most commercial hard carbons are carbonised at 1100–1400 °C as a balance.

---

## 6.6 Anodes: Alternatives to Hard Carbon

Hard carbon dominates SIB anodes today but is not perfect. Several alternative anode materials are under active development, each addressing a specific limitation of hard carbon.

### Soft Carbon

**Soft carbon** (graphitisable carbon, graphitisable at temperatures above 2000 °C) has lower practical capacity for sodium (~150–200 mAh/g) and a more heavily slope-dominated profile (less plateau), but offers higher initial Coulombic efficiency (often 85–90%) and better rate capability at very high C-rates due to its more ordered structure and better electronic conductivity. It is used in some commercial SIB cells as a blend or partial replacement for hard carbon.

### Alloy-Type Anodes: Tin, Antimony, Bismuth

Sodium alloys with tin (Na₁₅Sn₄, theoretical capacity 847 mAh/g), antimony (Na₃Sb, 660 mAh/g), and bismuth (Na₃Bi, 385 mAh/g), following the same principle as silicon alloying with lithium. The high theoretical capacities are attractive, but the same volume expansion problem applies: tin expands by approximately 420% during full sodiation, antimony by approximately 300%, bismuth by approximately 250%.

In SIBs the alloy anode challenge is if anything more severe than silicon in LIBs, because the larger sodium ion causes even larger volume changes. However, nanostructured composites (tin nanoparticles in carbon matrix, antimony dispersed in carbon) have shown promising cycle lives of >300–500 cycles with practical capacities of 400–600 mAh/g. These materials are primarily in the research-to-early-commercialisation stage.

### Titanate Anodes

Several sodium titanium oxides exhibit reversible sodium storage at potentials of approximately 0.3–0.8 V vs. Na/Na⁺, analogous to LTO in the lithium world. **Na₂Ti₃O₇** has a layered structure with a very low average sodiation potential (~0.3 V vs. Na/Na⁺ — the lowest of any SIB anode material, approaching the Na plating limit) and a theoretical capacity of approximately 177 mAh/g. **Na₂Ti₆O₁₃** has a tunnel structure and better cycling stability.

Titanate anodes for SIBs combine the safety advantage (no sodium plating) with reasonable capacity, but their practical development has been slower than for LTO in LIBs, partly because hard carbon already fills the anode role adequately for most SIB applications and there is less urgency for an ultra-safe alternative.

---

## 6.7 Electrolytes for SIBs: Differences from LIBs

We discussed SIB electrolyte basics in Section 6.1. Here we add the specific details needed for understanding cell performance and degradation.

### Carbonate Electrolytes

The standard SIB electrolyte for research is **1 M NaPF₆ in EC:DMC (1:1 by volume)** or **1 M NaPF₆ in EC:PC (ethylene carbonate:propylene carbonate)**. The inclusion of propylene carbonate (PC) — which causes exfoliation of graphite in LIBs (a known incompatibility) — is not a problem for hard carbon anodes, which do not exfoliate. PC improves low-temperature performance because it has a lower melting point than EC alone. This is one of the practical manufacturing advantages of SIB: the electrolyte formulation has fewer constraints than LIB electrolytes.

NaPF₆ at 1 M gives an ionic conductivity of approximately 6–7 mS/cm at 25 °C. NaClO₄ in EC:DMC gives comparable or slightly higher conductivity (~7–8 mS/cm) and is more common in academic research because NaClO₄ is cheaper and more soluble than NaPF₆. NaPF₆ is preferred for commercial cells because ClO₄⁻ is a strong oxidiser: under the combination of heat, mechanical shock, and organic fuel present in a failing cell, perchlorate salts mixed with carbonate solvents can react violently. This is the same reason LiClO₄ fell out of favour for commercial LIBs decades ago.

### Ether-Based Electrolytes

Ether-based electrolytes — particularly **1 M NaPF₆ or NaFSI in DEGDME** (diethylene glycol dimethyl ether, also called diglyme) — have attracted significant attention for SIBs because they produce a distinctly different and often superior SEI on hard carbon compared to carbonate electrolytes.

The SEI formed on hard carbon in ether electrolytes is thinner and more inorganic-rich than its carbonate-electrolyte counterpart — dominated by NaF (from NaPF₆ reduction) and Na₂O (from ether reduction), rather than by the mixed organic-carbonate oligomers that form in EC:DMC systems. Four consequences flow from this. First, the initial Coulombic efficiency of hard carbon in ether electrolytes is typically 85–92%, compared to 78–88% for the same carbon in carbonate electrolyte — a direct reduction in the sodium inventory lost to SEI formation during formation cycling. Second, the inorganic SEI has better Na⁺ ionic conductivity at the nanoscale grain sizes found in practice, because NaF and Na₂O grain boundaries can conduct Na⁺ efficiently even though bulk NaF is a poor conductor. Third, the SEI is more mechanically stable, flexing less with the volume changes of the underlying hard carbon during cycling and therefore re-forming less frequently. And fourth, the combination of these three effects gives better capacity retention over long-term cycling, with differences of 5–15% at 500+ cycles being typical.

The disadvantage of ether electrolytes is their narrower electrochemical stability window: DEGDME is oxidised at approximately 4.0 V vs. Na/Na⁺, which limits the use of high-voltage cathodes like NVPF (average 3.95 V vs. Na/Na⁺) with ether electrolytes. For layered oxide cathodes operating below 4.0 V, ether electrolytes are highly attractive. For NVPF, carbonate electrolytes or specialised fluorinated ether electrolytes are required.

### Electrolyte Additives

Additives used in LIB electrolytes — fluoroethylene carbonate (FEC), vinylene carbonate (VC), propane sultone — have SIB analogues. **FEC** (even at 5–10% volume fraction) significantly improves the ICE and cycle life of hard carbon anodes in carbonate electrolytes by modifying the SEI composition, forming a more NaF-rich, more inorganic inner SEI layer. FEC addition is the most reliably effective single additive for improving SIB hard carbon performance and is expected to be standard in commercial SIB cells.

---

## 6.8 Commercial SIB Cells: Who Has Shipped What

As of early-to-mid 2025, sodium-ion batteries have moved from a purely academic subject to an emerging commercial technology. The commercialisation landscape is moving rapidly, and the following describes the state at the time of writing — a snapshot that will certainly have evolved by the time you read it. Cross-reference with recent reviews and company announcements for current status.

### CATL (Contemporary Amperex Technology)

CATL announced its first-generation SIB in 2021 and delivered its first commercial cells in 2023. The first-generation cell uses a **Prussian white-type cathode** (iron-sodium PBA) paired with **hard carbon** anode, with a cell-level specific energy of approximately **160 Wh/kg** — comparable to the top end of what SIBs have achieved at the cell level. CATL announced a second-generation AB-battery design (a pack where SIB and LFP cells are mixed in the same pack to leverage SIB's low-temperature advantage while LFP provides higher energy density), targeting applications where the best of both chemistries is needed.

### HiNa (High Na-ion Battery Technology Company, China)

HiNa is a spin-off from the Institute of Physics at the Chinese Academy of Sciences (CAS), founded by Hu Yong-Sheng's group — one of the world's leading SIB research teams. Their commercial cell, the **BC-1**, uses an **O3-type layered oxide** cathode ($\text{Na}[\text{Cu}_{0.22}\text{Fe}_{0.3}\text{Mn}_{0.48}]\text{O}_2$ — cobalt-free, nickel-free, based on copper-iron-manganese) paired with an **anthracite-derived hard carbon** anode.

Published specifications for the BC-1 (26650 cylindrical format): nominal voltage 3.2 V; rated capacity 1.33 Ah at 0.1C; specific energy approximately 146 Wh/kg; cycle life >4,000 cycles at 1C to 80% retention; operating temperature −40 °C to +80 °C. The low-temperature performance is particularly noteworthy: the BC-1 retains approximately 88% of room-temperature capacity at −20 °C and approximately 70% at −40 °C — significantly better than most LIB chemistries.

### Faradion / Reliance Industries

Faradion (UK, acquired by Reliance Industries India in 2022) was among the first companies to commercialise SIB cells at the 18650 scale, using **O3-type $\text{NaNi}_{0.25}\text{Mn}_{0.25}\text{Fe}_{0.25}\text{Mg}_{0.1}\text{Ti}_{0.15}\text{O}_2$** cathode (or similar multi-metal O3 compositions) paired with hard carbon. Their cells achieve approximately 150 Wh/kg and are designed for grid storage and industrial applications. The Reliance acquisition has been oriented toward deploying SIBs in the Indian market for stationary storage and two/three-wheeled EVs.

### Natron Energy (USA)

Natron uses **Na₂MnFe(CN)₆ Prussian blue analogue** cathode with a **NaTi₂(PO₄)₃ NASICON anode** in aqueous sodium electrolyte — a fully aqueous cell chemistry. The aqueous chemistry eliminates flammability concerns (water-based electrolyte) but limits cell voltage to approximately 1.4 V (the electrochemical stability window of water). Natron targets data centre UPS, fast-charging bus depots, and grid frequency regulation with extremely high cycle counts (>50,000 cycles claimed) and ultra-high rate capability (60C charge/discharge). This is a niche but real commercial market.

### Altris AB (Sweden)

Altris uses **Prussian white Na₂Fe[Fe(CN)₆]** cathode paired with hard carbon in organic electrolyte. Their cell is designed specifically for grid storage in Northern Europe, leveraging the extremely low cost of iron hexacyanide precursors and the potential for local manufacture anywhere in the world. First commercial cells were delivered in 2024.

### Tiamat (France)

Tiamat's commercial SIB uses the **NVPF** cathode (Na₃V₂(PO₄)₂F₃) as described in Section 6.3, paired with hard carbon or soft carbon anode. Target application is high-rate, moderate-energy systems: power tools, industrial equipment, fast-charging infrastructure. Their 18650-format cell demonstrates ~10C rate capability with good retention — the highest published rate performance of any commercial-format SIB cell. The vanadium content remains a commercial challenge but Tiamat is working on scale-up in France as part of the European SIB ecosystem.

---

## 6.9 A Quantitative Comparison: SIB vs. LIB

The chapter deliverable (in the Deliverable section at the end of this chapter) asks for a detailed comparison table; here we establish the key quantitative comparisons at the cell level, which will anchor your table-building exercise.

The following table provides representative cell-level values for five major SIB cells and five major LIB cells, covering all the Chapter 3 metrics. Values are from published literature or public specification sheets as of 2024–2025 and should be treated as representative rather than definitive:

| Cell | Chemistry | Format | Nom V (V) | Cap (Ah) | Sp. Energy (Wh/kg) | Vol. Energy (Wh/L) | Cycle Life (cycles) | DCIR (mΩ) | OCV shape |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| HiNa BC-1 | O3 LO / HC | 26650 | 3.2 | 1.33 | 146 | ~280 | >4000 | ~100 | Mixed slope/flat |
| CATL 1st Gen SIB | PBA / HC | 26650 | ~3.1 | ~3.0 | ~160 | ~290 | >3000 | ~80 | Flat-heavy |
| Faradion 18650 | O3 LO / HC | 18650 | 3.2 | ~2.0 | ~150 | ~350 | >1000 | ~90 | Mixed |
| Tiamat 18650 | NVPF / HC | 18650 | ~3.7 | ~1.0 | ~130 | ~300 | >4000 | ~60 | Stepped plateau |
| Natron (aqueous) | PBA / NTP | Cylindrical | 1.4 | Varies | ~40–50 | ~80 | >50000 | Low | Flat |
| Samsung 30Q | NMC622/Gr | 18650 | 3.6 | 3.0 | 243 | 650 | ~500 | 45 | Moderate slope |
| Panasonic NCR18650B | NCA/Gr | 18650 | 3.6 | 3.4 | 248 | 700 | ~400 | 40 | Moderate slope |
| LG INR21700-M50 | NMC811/Gr | 21700 | 3.6 | 5.0 | 260 | 730 | ~500 | 35 | Moderate slope |
| BYD Blade (LFP) | LFP/Gr | Prismatic | 3.2 | ~135 | ~150–160 | ~330–350 | >3000 | ~80 | Flat |
| Toshiba SCiB | LTO/LMO | 20700 | 2.4 | 10 | 67 | 177 | >20000 | ~20 | Flat |

Several patterns emerge immediately from this table. Current SIB cells cluster at 130–160 Wh/kg — below the 230–260 Wh/kg range of premium NMC cells but competitive with LFP (~150–180 Wh/kg) and well above LTO (~50–90 Wh/kg). The cycle life of SIB cells is already competitive with LFP for the cells designed for long-life applications (HiNa BC-1 at >4,000 cycles is comparable to commercial LFP). The DCIR of SIB cells is notably higher than equivalent-format LIB cells — reflecting the higher charge-transfer resistance and thicker SEI discussed in earlier sections. The OCV shape of SIB cells is flat-heavy, consistently more challenging for SOC estimation than NMC/NCA cells.

The performance gap between SIBs and LFP — roughly 10–20% lower specific energy, comparable cycle life, potentially lower cost once scaled — is the key comparison for understanding where SIBs will compete commercially in the next 5–10 years.

---

## 6.10 Worked Interpretation Exercise: Reading a Hard Carbon Half-Cell OCV Curve

Let us apply the physical understanding of Section 6.5 to an actual published hard carbon OCV measurement. The following describes data from a sucrose-derived hard carbon carbonised at 1300 °C, measured against a sodium metal reference electrode in 1 M NaClO₄/PC electrolyte. The measurement uses GITT with very small increments (C/50 current pulses, 1-hour rest).

The OCV curve during sodiation (from the empty state at ~2.0 V vs. Na/Na⁺ down to ~0.01 V) shows:

**From 2.0 V to ~0.1 V (slope region)**: The OCV decreases quasi-linearly (slightly curved) from 2.0 V to approximately 0.12 V. The total charge in this region integrates to approximately 190 mAh/g. Reading the curve physically: sodium is being adsorbed on surface functional groups (high voltage, small capacity, >1.0 V), then intercalating into the turbostratic interlayer spaces (0.5–0.1 V, main slope region). The slope confirms single-phase behaviour — a continuously varying sodium chemical potential in the host. Applying the Nernst equation perspective developed in Section 6.5: the activity of Na in the host changes continuously with filling fraction, producing a continuously varying equilibrium potential.

**At approximately 0.1 V**: The OCV curve reaches a kink — the potential levels off and the slope suddenly decreases. This marks the onset of nanopore filling.

**From ~0.1 V to ~0.01 V (plateau region)**: The OCV is nearly constant at approximately 0.05–0.08 V vs. Na/Na⁺ for the remainder of the capacity, approximately 80 mAh/g of additional charge. The plateau confirms quasi-metallic sodium storage in the nanopores — the activity of sodium in the pores has become nearly constant (≈1), so the equilibrium potential is nearly constant at close to 0 V vs. Na/Na⁺, exactly as equation 6.4 predicts.

**Total capacity**: 190 + 80 = 270 mAh/g. **ICE**: The measurement reports 81%, meaning that 270/0.81 ≈ 333 mAh/g was charged during the first sodiation, and only 270 mAh/g was recovered on the first desodiation — about 63 mAh/g was consumed irreversibly by SEI formation. This is consistent with the ~15–25 m²/g surface area typical of this precursor and carbonisation temperature.

**What the kink at 0.1 V tells us**: The sharpness of the kink is a measure of the cooperativity of the nanopore filling transition. A sharper kink indicates a more uniform nanopore size distribution (all pores fill at nearly the same potential). A gradual bend indicates a distribution of pore sizes and environments (broader range of filling potentials). Comparing kink sharpness across different hard carbons is a rapid way to qualitatively assess their nanopore uniformity.

**Extracting the nanopore fraction from the curve.** One of the most useful numbers you can pull out of a hard carbon half-cell OCV is the ratio of plateau capacity to total capacity, because it quantifies how much of the storage is happening in closed nanopores (plateau) versus turbostratic intercalation (slope). For this sample: plateau capacity is 80 mAh/g, total reversible capacity is 270 mAh/g, so the plateau fraction is $80/270 \approx 30\%$. In the Stevens-Dahn framework, this tells us that about 30% of the stored sodium is sitting in quasi-metallic clusters in closed pores, and about 70% is intercalated between turbostratic layers. Carbons carbonised at higher temperature typically have larger plateau fractions (up to ~50% for 1400–1500 °C pyrolysis); carbons carbonised at lower temperature tend toward the slope-dominated end. Knowing the plateau fraction lets you predict, to first order, how bad the BMS SOC estimation problem will be for a given hard carbon: higher plateau fraction means more flat region in the full-cell OCV and more reliance on coulomb counting.

**Extracting an effective plateau potential.** The second useful extraction is the plateau potential itself. For this sample it is ~0.05–0.08 V vs. Na/Na⁺. The distance of this plateau from 0 V vs. Na/Na⁺ is a margin against sodium plating — the closer to 0 V the plateau sits, the smaller the voltage window before overpotential pushes the electrode potential below the Na/Na⁺ line and triggers plating on the carbon surface. Carbons with plateaus at ~0.1 V are safer against plating than those at ~0.02 V, but the difference is only tens of millivolts, which is why rate capability and low-temperature operation both matter so much for SIB design.

**The practical implication for full-cell OCV**: In a complete cell paired with an O3 layered oxide cathode at average 3.2 V vs. Na/Na⁺, the slope region of the full-cell OCV descends from about 3.1 V to about 3.05 V over 190 mAh/g (reflecting the cathode descending from 3.2 to 3.15 V while the anode ascends from 0.0 to 0.05 V). The plateau region produces a nearly flat full-cell OCV of about 3.1 V over the remaining 80 mAh/g. The combined OCV has only a ~50 mV total range over roughly 30% of the total capacity — consistent with the severe SOC estimation problem described in Section 6.5.

---

## 6.11 What Changes for Sodium-Ion? (Consolidated Summary)

In every chapter up to this point, this section has appeared to preview SIB-specific considerations as a small addendum. Chapter 6 is the first chapter in which SIB has been the main subject rather than the forward-reference, so the usual "what changes for sodium-ion" section doesn't quite fit here — everything in the chapter has been about sodium. Instead, this section plays a different role: it consolidates the SIB differences we've accumulated across Chapters 1–6, organised by the chapter that first introduced the underlying concept, and sets up a clean handoff to the later parts of the book. If you want a single-page crib sheet for "what is actually different about sodium-ion," this is it. The items below will re-appear, each with more detail, when we reach the relevant chapter.

**Thermodynamics** (Chapter 1 basis): 0.33 V lower open-circuit voltage than equivalent LIB chemistry; lower gravimetric specific capacity for the same electron count per formula unit; the Na⁺/Na scale vs. Li⁺/Li scale requires explicit conversion when comparing potentials.

**Intercalation and host materials** (Chapter 2 basis): Graphite is not viable — hard carbon is the anode. Cathode crystal structures include O3 and P2 layered oxides, NVPF and NFPP polyanionics, and PBAs — all sodium-specific or sodium-preferred. Larger ion size means more phase transitions in layered oxides (O3→P3) and different preferred coordination geometry (P2 prismatic sites).

**SEI chemistry** (Chapter 2/4 basis): SEI on hard carbon is thicker and less stable than on graphite; ICE is 75–90% vs. 85–95% for graphite; ether electrolytes improve ICE; pre-sodiation may be needed for commercial cells.

**Cell performance** (Chapter 3/4 basis): 130–160 Wh/kg cell-level energy; higher DCIR (80–150 mΩ for 26650 format vs. 20–50 mΩ for 18650 LIB); better low-temperature performance than most LIBs; flat/complex OCV requiring coulomb-counting-dominant BMS; aluminium on both current collectors (Chapter 4 basis).

**Degradation differences** (to be detailed in Chapter 7): SEI-driven capacity fade is present but may be slower if ether electrolyte is used; phase transition fatigue in O3 layered oxide cathodes is a specific SIB degradation mode; manganese dissolution (from LMO/LMO analogues) is less severe in SIB PBAs; new degradation modes related to PBA cathode (water absorption, vacancy evolution) are unique to SIB.

**BMS challenges** (to be detailed in Chapters 10, 13): Flat OCV in plateau region severely limits voltage-based SOC; higher internal resistance requires different power limit calculations; lower thermal runaway risk (covered in Chapter 8) simplifies some safety algorithm design.

The following table makes the mapping from cell-level performance metric to underlying physical cause explicit — it is the "why" behind the numbers in Section 6.9.

| SIB vs. LIB metric difference | Direction | Dominant physical cause | Chapter introduced |
| --- | --- | --- | --- |
| Cell voltage | ~0.3–0.5 V lower | Na⁺/Na reference 0.33 V above Li⁺/Li; minor cathode-side offsets | 1, 6.1 |
| Gravimetric capacity | Lower | Heavier ion per charge carried (3.3×); sometimes lower utilisation of host sites | 1, 6.1 |
| DCIR | 1.5–2× higher | Lower electrolyte conductivity; thicker/more resistive SEI on hard carbon; heavier ion transport | 2, 6.1, 6.5 |
| Low-temperature capacity | Higher (better) | Weaker Na⁺ solvation in carbonate; lower desolvation barrier; lower liquidus of optimal electrolyte blends | 6.1, 6.7 |
| OCV flatness | More severe | Hard-carbon plateau near 0 V vs. Na/Na⁺ paired with often-flat SIB cathodes | 6.5 |
| Thermal runaway risk | Lower | Lower cathode-side oxygen release at elevated temperature; less energetic SEI decomposition | 8 (forward) |
| Raw material cost | Lower | Na abundance and distribution; no Co, minimal Ni in best chemistries; Al both sides | 6 opening, 4 (forward) |
| Cycle life | Comparable | Trade-offs are chemistry-specific; no intrinsic advantage or disadvantage | 6.4, 7 (forward) |

---

## Chapter Summary

**Key ideas:**

- Na⁺ is 34% larger than Li⁺ (1.02 Å vs. 0.76 Å), 3.3× heavier, and 0.33 V higher on the reduction potential scale. These differences mean: graphite is not viable as a SIB anode; SIB cell voltage is inherently 0.3–0.5 V lower than equivalent LIB; larger ion requires larger interstitial sites in host materials.
- The desolvation energy of Na⁺ in carbonate electrolytes is *lower* than that of Li⁺ — so desolvation is actually a kinetic *advantage* for Na⁺, and is part of why SIBs perform better at low temperature. The higher DCIR of SIBs compared to LIBs comes from other causes: lower electrolyte conductivity, thicker hard-carbon SEI, and somewhat slower solid-state Na⁺ diffusion in the best-studied cathode lattices.
- SIB cathode families: O3 layered oxides (NaMO₂, direct analogue of LCO/NMC, phase transitions during cycling are the main challenge); P2 layered oxides (prismatic Na coordination, unique to SIB, better structural stability during cycling, starts Na-deficient); polyanionic NVPF (highest voltage SIB cathode at ~3.95 V average, excellent rate capability, vanadium toxicity concern) and NFPP (iron-based, no critical materials); Prussian blue analogues (open framework, excellent rate capability and cycle life, water contamination challenge).
- Hard carbon dominates SIB anodes: turbostratic disordered carbon with slope region (intercalation, 0.1–2 V vs. Na/Na⁺) and plateau region (nanopore filling, ~0.01–0.1 V vs. Na/Na⁺). The plateau produces a near-flat OCV close to 0 V vs. Na/Na⁺ — the most practically important performance challenge for SIB BMS. The flat-OCV region is best thought of as an observability failure: terminal voltage carries almost no information about SOC, and coulomb counting becomes the dominant estimator.
- ICE of hard carbon is 75–90%, lower than graphite (85–95%), due to higher surface area and less mature SEI chemistry. Ether electrolytes improve ICE vs. carbonate electrolytes. Pre-sodiation is the additional manufacturing-stage fix that buys back some of the ICE loss.
- Commercial SIB landscape (2024–2025): CATL (PBA/HC, ~160 Wh/kg), HiNa (O3/HC, ~146 Wh/kg, >4000 cycles), Faradion/Reliance (O3/HC), Tiamat (NVPF/HC, ultra-high rate), Natron (aqueous PBA, >50,000 cycles), Altris (Prussian white/HC).
- SIB cell-level specific energy (130–160 Wh/kg) is competitive with LFP, well below NMC. SIB advantages: lower raw material cost and supply chain risk; no cobalt/nickel required; aluminium current collectors on both sides; better low-temperature performance than most LIBs; lower thermal runaway risk; competitive cycle life.

**Key equations:**

Full-cell open-circuit voltage decomposed into electrode half-cell potentials (equation 6.3):
$$E_\text{OCV,cell} = E_\text{cathode}(\text{SOC}) - E_\text{anode}(\text{SOC})$$

Theoretical gravimetric capacity of an intercalation material, with $n$ electrons per formula unit, Faraday constant $F$, and molar mass $M$ in g/mol (equation 6.2):
$$C_\text{th} = \frac{nF}{3.6\,M}$$

For NVPF ($n = 2$, $M = 417.8$ g/mol): $C_\text{th} \approx 128$ mAh/g. For Prussian white $\text{Na}_2\text{Fe}[\text{Fe}(\text{CN})_6]$ ($n = 2$, $M = 314$ g/mol): $C_\text{th} \approx 171$ mAh/g.

Nernst equation applied to a sodium-storage half-cell (equation 6.4):
$$E = E^\circ - \frac{RT}{F}\ln \frac{a_\text{Na(host)}}{a_{\text{Na}^+}}$$

Reference potentials:
$$E^\circ(\text{Na}^+/\text{Na}) = -2.71\ \text{V vs. SHE}, \qquad E^\circ(\text{Li}^+/\text{Li}) = -3.04\ \text{V vs. SHE}$$
giving a 0.33 V anode-reference shift from Li to Na cells.

**Key vocabulary (in order of appearance):**

desolvation energy, O3 layered oxide, P2 layered oxide, Delmas notation (O/P, layer count), O3→P3 phase transition, prismatic coordination, inductive effect (polyanionic), NVPF (Na₃V₂(PO₄)₂F₃), NASICON structure, NVP (Na₃V₂(PO₄)₃), NFPP, Prussian blue analogue (PBA), Prussian white, cyanide framework, hard carbon, turbostratic carbon, closed nanopore, open micropore, slope region, plateau region, house-of-cards model, initial Coulombic efficiency (ICE) for SIB, observability failure, pre-sodiation, ether electrolyte (DEGDME), NaPF₆, NaClO₄, fluoroethylene carbonate (FEC) additive, cell-to-pack.

---

## Deliverable

**Task:** Build a comparison table of five commercial SIB cells vs. five commercial LIB cells across all Chapter 3 metrics.

**Guidance:** Use the quantitative comparison in Section 6.9 as a starting point, but go deeper. For each cell, find a specific published paper or reliable public datasheet and extract: nominal voltage, rated capacity (and at what C-rate), specific energy (Wh/kg), volumetric energy density (Wh/L), DCIR (mΩ at 50% SOC, 25 °C), cycle life (cycles to 80% capacity retention), rate capability (capacity at 1C and 5C as percentage of C/10 capacity), low-temperature performance (capacity at −20 °C as percentage of 25 °C capacity), and OCV shape descriptor (flat, sloped, mixed, describe where the flat regions are).

For the SIB cells, look specifically for: HiNa BC-1 (many publications from Hu Yong-Sheng's group and from the Beijing National Laboratory for Condensed Matter Physics); Faradion/Reliance cells (characterisation by Armstrong et al. and Barker et al., and recently Reliance's own publications); CATL first-generation SIB (search for "CATL SIB characterisation 2023–2024"). For Tiamat: Ponrouch et al. and collaborators published extensively on NVPF-based 18650 cells.

Alongside the table, write a one-page narrative answering: Where does SIB currently beat LIB on any metric? Where is the gap largest? What would need to improve in SIB technology for it to displace LFP in grid storage? Is the SOC estimation challenge a hard physical limit or an engineering problem that better BMS design can solve?

A partial worked entry for the HiNa BC-1 vs. Samsung INR18650-30Q comparison:

HiNa BC-1 (26650, O3-$\text{NaCuFeMnO}_2$/HC): Nominal 3.2 V, 1.33 Ah at C/10, ~146 Wh/kg, ~280 Wh/L, DCIR ~100 mΩ at 50% SOC, >4000 cycles to 80%, rate capability ~90% at 1C and ~70% at 5C vs. C/10, low-temperature ~88% at −20 °C, OCV: sloped above 0.1 V anode (slope-dominated cathode region) merging into flat near-zero region from hard carbon plateau — approximately 30% of capacity in a nearly flat region near 3.1–3.15 V cell OCV.

Samsung 30Q (18650, NMC622/Gr): Nominal 3.6 V, 3.0 Ah at C/5, ~243 Wh/kg, ~650 Wh/L, DCIR ~45 mΩ at 50% SOC, ~500 cycles to 80%, rate capability ~97% at 1C and ~88% at 5C vs. C/5, low-temperature ~62% at −20 °C, OCV: moderately sloped throughout, no truly flat region exceeding 10% of capacity.

---

## Further Reading

1. **Yabuuchi, N. et al., "Research Development on Sodium-Ion Batteries," *Chemical Reviews* 114 (23), 11636–11682 (2014).** The most comprehensive early review of SIB cathode and anode materials, written by Shinichi Komaba's group — one of the foundational SIB research teams. Covers layered oxides, polyanionics, hard carbon, and electrolytes in systematic depth. Still the best single reference for understanding the breadth of the material landscape.

2. **Hu, Y.-S. et al., "Sodium-Ion Batteries: Present and Future," *Nature Energy* 6, 513–524 (2021).** A forward-looking review by the leader of the HiNa group. Focuses on commercialisation readiness, cost analysis, and the specific technical challenges (ICE, energy density, electrolyte) that must be solved for SIBs to compete at scale. Essential reading for understanding where the field is going.

3. **Stevens, D. A. and Dahn, J. R., "The Mechanisms of Lithium and Sodium Insertion in Carbon Materials," *Journal of the Electrochemical Society* 148 (8), A803–A811 (2001).** The paper that established the slope/plateau model for sodium storage in hard carbon and introduced the "house of cards" microstructural model. Methodologically rigorous, uses both electrochemical and structural (SAXS, WAXS) evidence. Read this to understand hard carbon at a mechanistic level — and then read a recent (post-2020) review to see how the model has been refined.

4. **Vaalma, C. et al., "A cost and resource analysis of sodium-ion batteries," *Nature Reviews Materials* 3, 18013 (2018).** The authoritative techno-economic analysis showing why sodium-ion batteries could offer cost advantages over lithium-ion, with careful accounting of raw material costs, manufacturing costs, and economies of scale. The paper that put the cost argument for SIBs on a quantitative footing.

5. **Tarascon, J.-M., "Na-ion versus Li-ion Batteries: Complementarity Rather Than Competitiveness," *Joule* 4 (8), 1616–1620 (2020).** A short commentary from one of the founders of modern electrochemistry research, arguing that the right framing for SIBs is not "will they replace Li-ion" but "which market segments do they fill that Li-ion never will." Useful for recalibrating expectations after reading the cost-optimistic literature. Pair with Vaalma et al. (entry 4) to get both the quantitative and the strategic argument.

---

*Next chapter: **Chapter 7 — Degradation Mechanisms.** We descend into the physics of why batteries die: loss of lithium/sodium inventory, loss of active material, impedance growth, SEI evolution, lithium/sodium plating, particle cracking, and the interplay of calendar and cycle aging. Prompt me with "write Chapter 7" to continue.*

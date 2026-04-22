# Battery Technology for Electrical Engineers: A Self-Study Text

---

## Chapter 1: Electrochemistry for Engineers

## Chapter Opening

There is a moment that happens to almost every electrical engineer who ventures into battery research for the first time. You pick up a paper — something from *Nature Energy* or the *Journal of the Electrochemical Society* — and within the first two paragraphs you encounter phrases like "Li⁺ intercalation into a layered oxide host," "reductive decomposition of the electrolyte at the graphite surface," or "the SEI-limited rate capability of hard carbon." You know you are reading about a battery. You vaguely understand that lithium ions are moving. But the precise physical meaning of each phrase, the chain of logic that connects the chemistry to the measured voltage, and the reason the author chose those words rather than some other words — all of that is opaque.

This chapter is the key to that door.

By the time you finish it, you will be able to read a half-reaction — say, $\text{C}_6 + \text{Li}^+ + e^- \rightarrow \text{LiC}_6$ — and know exactly what it is claiming about the physical world: which species gains electrons, which loses them, where that process happens, and what potential difference it implies. You will understand why cell voltage is not an arbitrary number stamped on a datasheet but a thermodynamic consequence of the chemical free-energy difference between the two electrodes. You will know what Faraday's laws say, why they are not approximations, and how to use them to turn a charge measurement into a mass measurement and back again.

None of this requires you to abandon your engineering background. Quite the opposite: thermodynamics and electrochemistry are, at their core, the study of energy — exactly what you have been doing all along, just in a different language. We will build that translation layer carefully, and we will do it in the direction you are coming from: physical intuition first, formalism second, numbers third.

One important framing point before we begin. Electrochemistry is sometimes taught as a branch of chemistry, which leads to an emphasis on memorising tables of half-reactions and electrode potentials. That is not how we will approach it. We will treat it as a branch of thermodynamics and transport theory, which puts us on familiar engineering ground. The vocabulary is new. The physics is something you already understand.

---

> **Prerequisites Check**
>
> From your EE background:
>
> - Thermodynamics at the level of energy, work, entropy, and free energy (undergraduate engineering thermodynamics is sufficient; a rigorous statistical-mechanics treatment is not needed yet)
> - Basic differential equations (needed in Section 1.5 for the Nernst derivation)
> - Comfort with dimensional analysis and unit conversion
>
> From earlier in this book:
>
> - None — this is the first chapter. Everything will be defined here.
>
> If your thermodynamics is rusty, spend thirty minutes reviewing the definitions of enthalpy, entropy, and Gibbs free energy before reading Section 1.8. The derivation there will be hard to follow without them.

---

## 1.1 What Is a Battery? Galvanic vs. Electrolytic Cells

Let us begin with a picture that, once fixed clearly in your mind, will underpin everything in this book.

Imagine two metal bars sitting in a solution of dissolved salt, connected by a wire. One bar is copper; the other is zinc. You have just built one of the oldest electrochemical devices in history — the Daniell cell, invented in 1836. Now here is the remarkable thing: if you simply connect the wire and wait, a current flows through it *spontaneously*, without any external voltage source. The zinc bar slowly dissolves. The copper bar slowly grows. Chemical energy stored in the difference between the chemical properties of zinc and copper is being converted, continuously, into electrical energy in the wire.

That, in its most distilled form, is what a battery is: a device that converts stored chemical potential energy into electrical energy through a controlled chemical reaction. The key word is *controlled* — the reaction does not happen in a violent burst like combustion; it happens at two physically separated surfaces called **electrodes**, and the electrons released at one electrode are forced to travel through an external circuit to reach the other, doing useful work along the way.

The process I just described — spontaneous conversion of chemical energy to electrical energy — is called a **galvanic process** (after Luigi Galvani) or sometimes a **voltaic process** (after Alessandro Volta). A device that harnesses it is a **galvanic cell**. Every battery you have ever used — from the AA alkaline cell in a television remote to the 100 kWh lithium-ion pack underneath a Tesla — is, at its core, a galvanic cell or a collection of galvanic cells.

Now run the process in reverse. Suppose instead of harvesting the current from the Daniell cell, you connect it to an external power supply and force current through it in the opposite direction. The copper dissolves back into solution. Zinc plates out of solution back onto the zinc bar. You are now consuming electrical energy to drive a chemical reaction that would not proceed spontaneously on its own. This is called an **electrolytic process**, and the device is an **electrolytic cell**. Industrial electroplating, the Hall–Héroult process for smelting aluminum, the chlor-alkali process for producing chlorine — all of these are electrolytic.

**Students often confuse galvanic and electrolytic cells** because both involve electrodes, both involve ions in solution, and both involve the flow of current. The distinction is thermodynamic, not structural. In a galvanic cell, the chemical reaction drives the current: the system does work on the external circuit, $\Delta G < 0$, and you extract energy. In an electrolytic cell, the current drives the chemical reaction: the external circuit does work on the system, $\Delta G > 0$ (for the reaction as driven), and you consume energy. The same physical device can often operate in either mode depending on what you connect to it — this is exactly what happens when you *charge* a rechargeable battery. During discharge, it is a galvanic cell. During charge, it is an electrolytic cell. You drive the same electrode reactions in reverse.

This duality — the same device, the same ions, the same electrodes, but radically different direction of energy flow depending on whether you are sourcing or sinking current — is one of the conceptually beautiful things about electrochemistry. It is also practically important: understanding what happens during charge versus discharge at the electrode surfaces is the key to understanding degradation, which we will spend all of Chapter 7 on.

One more vocabulary point before we move on. The word **cell** in electrochemistry refers to a single electrochemical unit — one positive electrode, one negative electrode, one electrolyte. A **battery**, strictly speaking, is a collection of cells wired together, though in casual usage "battery" is used for single cells as well (a "9-volt battery" is actually six 1.5-volt cells in series inside the same case). In this book we will be precise: "cell" means a single electrochemical unit, and "battery" or "pack" means a collection of cells.

---

## 1.2 Oxidation, Reduction, and Half-Reactions

Chemistry happens when electrons are transferred. Everything else — the ionic motion, the phase changes, the gas evolution — is a consequence. Understanding batteries therefore requires a clear mental model of electron transfer, and the most powerful tool for building that model is the concept of **half-reactions**.

Let us define our terms carefully.

**Oxidation** is the loss of electrons by a chemical species. A species that is oxidised gives electrons up. The mnemonic that most chemists use is *OIL*: Oxidation Is Loss (of electrons). When zinc metal dissolves in our Daniell cell, it does so by the process:

$$\text{Zn} \rightarrow \text{Zn}^{2+} + 2e^-$$

Zinc metal loses two electrons and becomes a doubly-charged positive ion that enters the solution. Zinc has been oxidised.

**Reduction** is the gain of electrons by a chemical species. A species that is reduced accepts electrons. The complementary mnemonic is *RIG*: Reduction Is Gain. In the Daniell cell, copper ions in solution accept the electrons that zinc released:

$$\text{Cu}^{2+} + 2e^- \rightarrow \text{Cu}$$

Copper ions are reduced to copper metal, which plates out on the copper electrode.

Crucially, these two processes are inseparable. Electrons cannot simply "float" in space — if one species releases them, another must absorb them simultaneously. Oxidation and reduction always occur in tandem. The combined process is therefore called an **oxidation-reduction reaction**, or **redox reaction** for short. Every galvanic and electrolytic cell is, at its heart, a device for spatially separating a redox reaction so that the electron transfer happens not directly between chemical species in contact but through an external wire.

Each of the two half-reactions above — the oxidation of zinc and the reduction of copper — is called a **half-reaction** (or sometimes a **half-cell reaction**). The name is apt: each represents one half of the overall redox process. To get the full reaction, you simply add the two half-reactions together, cancelling the electrons:

$$\text{Zn} + \text{Cu}^{2+} \rightarrow \text{Zn}^{2+} + \text{Cu}$$

This is the net reaction of the Daniell cell. Zinc dissolves; copper plates out. Energy is released. Electrons flow through the wire.

Now a subtlety that trips up many engineers first encountering electrochemistry: the sign convention for writing half-reactions. There is a universal convention that all **standard half-reactions are written as reductions** — that is, with electrons on the left-hand side, being consumed:

$$\text{Cu}^{2+} + 2e^- \rightarrow \text{Cu} \quad E^\circ = +0.34 \text{ V}$$
$$\text{Zn}^{2+} + 2e^- \rightarrow \text{Zn} \quad E^\circ = -0.76 \text{ V}$$

When zinc is actually oxidised at the electrode, we reverse the half-reaction and reverse the sign of its potential. The electrode doing the oxidation — the one at which the current enters the electrolyte from the external circuit during discharge — is the **anode**, and the electrode doing the reduction — the one at which current leaves the electrolyte into the external circuit — is the **cathode**. (We will define these more carefully and discuss how their roles flip on charge in Section 1.3.)

The **oxidising agent** in a redox reaction is the species that gets reduced (it accepts electrons, thereby oxidising something else). The **reducing agent** is the species that gets oxidised (it donates electrons, thereby reducing something else). In the Daniell cell, Cu²⁺ is the oxidising agent; Zn metal is the reducing agent.

**Students often mix up "the oxidising agent is the species that gets oxidised."** This is exactly backwards. The oxidising agent causes oxidation in the other species by accepting electrons itself — therefore the oxidising agent is the species that gets *reduced*. If you catch yourself confused, trace the electrons: whoever gains electrons is being reduced, and that species is the oxidising agent.

For our purposes going forward, the key skill is reading a half-reaction fluently — and by "fluently" I mean that four pieces of information should jump out at you within a second or two of seeing it. First, which direction the electrons are flowing: electrons on the left-hand side means a reduction as written, electrons on the right-hand side means an oxidation. Second, which chemical species is being transformed, and from what to what. Third, the stoichiometry of the ion and electron transfer — how many ions, how many electrons, per formula unit of reaction. And fourth, the potential of this half-reaction relative to the standard hydrogen electrode, which we will define properly in Section 1.4. Getting to the point where you can extract all four at a glance takes practice, but it is a skill that rewards the investment: once you have it, battery literature becomes dramatically more readable.

Let us practice with the half-reactions for a lithium cobalt oxide (LCO) / graphite cell, which is the canonical lithium-ion chemistry:

**At the positive electrode (LCO cathode), during discharge:**

$$\text{Li}_{1-x}\text{CoO}_2 + x\text{Li}^+ + xe^- \rightarrow \text{LiCoO}_2$$

Read this as: lithium-poor cobalt oxide accepts $x$ lithium ions from the electrolyte and $x$ electrons from the external circuit, and is thereby reduced. Charge balance tells us where the reduction lands: lithium and oxygen have fixed oxidation states (+1 and −2), so the arriving electrons must reduce cobalt. In LiCoO₂, cobalt is formally Co³⁺; in Li₀.₅CoO₂, the average cobalt oxidation state is +3.5. During discharge, cobalt's average oxidation state therefore drops from about +3.5 back toward +3. (In practice LCO is not cycled past $x \approx 0.5$, because further delithiation destabilises the layered structure — a point we will return to in Section 1.7.) The positive electrode is reduced during discharge, making it the cathode.

**At the negative electrode (graphite anode), during discharge:**

$$\text{LiC}_6 \rightarrow \text{C}_6 + \text{Li}^+ + e^-$$

Read this as: lithium-rich graphite releases a lithium ion into the electrolyte and an electron into the external circuit. The negative electrode is oxidised during discharge, making it the anode.

We will return to these specific half-reactions in the deliverable at the end of this chapter. For now, the point is that the language of half-reactions is the precise, compact notation for describing what is physically happening at each electrode surface in a battery.

---

## 1.3 Anode, Cathode, Electrolyte, Separator, Current Collector — Anatomy of a Cell

Before we go further into thermodynamics and electrochemistry, let us establish the physical vocabulary for talking about what is inside a battery cell. This section is partly a glossary and partly a physical description, and it is worth reading carefully because ambiguous use of terms like "anode" and "cathode" is one of the most consistent sources of confusion in battery literature.

### The Electrolyte

The **electrolyte** is the medium through which ions move inside the cell. It is ionically conductive but electronically insulating — that is, ions can move through it freely, but electrons cannot. This is the critical property: by forcing electrons to travel through the external circuit while ions travel through the electrolyte, the cell does electrical work.

Electrolytes in commercial lithium-ion cells are typically liquid solutions of a lithium salt — most commonly lithium hexafluorophosphate, LiPF₆ — dissolved in a mixture of organic solvents such as ethylene carbonate and dimethyl carbonate. In sodium-ion cells, the analogous salt is NaPF₆ or NaClO₄ in similar solvents. The electrolyte occupies the pores within the electrodes and the space between them.

The electrolyte is the component you know least about from your EE background, and it will require the most new vocabulary. For now, here is the mental model to hold onto. The electrolyte is a **selective conductor**: it conducts ions readily (ionic conductivities on the order of 10 mS/cm are typical for Li-ion electrolytes) but is essentially an insulator for electrons (electronic conductivities many orders of magnitude lower). This selectivity is the whole trick of a battery. If the electrolyte conducted electrons too, the cell would short-circuit through its own interior — the electrons would simply flow from anode to cathode through the electrolyte itself, dissipating all the free energy as heat and producing no current in the external circuit. By making the internal conductor *ionic-only*, we force the electrons to take the long way around — through the copper foil, out of the cell, through your load, and back — and it is along that long way around that they do useful electrical work. This asymmetry between ionic and electronic conductivity is the single most important property of any electrolyte, and most electrolyte development is ultimately about pushing ionic conductivity up and electronic conductivity down.

### The Electrodes

**Electrodes** are the solid materials at which the electrode reactions take place. In a battery, the electrodes are porous structures — think of a highly compressed sponge made of fine particles — coated onto metal foil current collectors. Lithium ions and electrons must both reach the same electrode surface for the half-reaction to proceed, so the electrode must be both ionically accessible (the electrolyte fills the pores) and electronically conductive (electrons move through the solid matrix).

The terminology for which electrode is the anode and which is the cathode is, unfortunately, a source of genuine confusion in the field, and it is important to address this directly.

**The canonical definition** (which is also the consistent one): the **anode** is the electrode at which oxidation occurs; the **cathode** is the electrode at which reduction occurs. This definition has nothing to do with which electrode is "positive" or "negative" — it refers purely to the direction of the electrode reaction.

During discharge of a lithium-ion cell, the graphite electrode is oxidised (LiC₆ → C₆ + Li⁺ + e⁻), so it is the **anode** during discharge. The LCO electrode is reduced (Li₁₋ₓCoO₂ + Li⁺ + e⁻ → LiCoO₂), so it is the **cathode** during discharge.

During charge, the reactions reverse: LiC₆ is being reformed (reduction), so graphite becomes the cathode; LiCoO₂ is being delithiated (oxidation), so it becomes the anode. The roles swap every time you reverse current.

Battery engineers — particularly those working on cell design and degradation — often deal with this by using "negative electrode" for graphite and "positive electrode" for LCO, avoiding the anode/cathode ambiguity entirely. The negative electrode is always the graphite one, regardless of whether the cell is charging or discharging, because "negative" and "positive" refer to the *terminal polarity* of a cell at rest — and the terminal polarity never flips (if it did, your phone would spontaneously reverse itself). You will see both conventions in the literature, sometimes within the same paper. In this book we will use the thermodynamically consistent convention (anode = oxidation during the given half-cycle) but will always specify "during discharge" or "during charge" to remove ambiguity.

**Students often say, in exasperation, "just tell me which one is the anode."** The honest answer is: it depends on which direction current is flowing. If you have to pick one usage to default to, default to "negative electrode" for graphite and "positive electrode" for LCO — those labels never move. Save "anode" and "cathode" for moments when you are specifically talking about what is being oxidised or reduced in a given half-cycle, and always attach "during discharge" or "during charge" when you use them. This single habit will prevent more confusion than any other in your first year of reading the literature.

**Students often encounter the statement "the anode is always negative."** This is only true for a galvanic cell (battery discharging). During charging, the electrode that was the negative electrode becomes the cathode (it is being reduced — lithium is being inserted back into graphite), while the positive electrode becomes the anode (it is being oxidised — lithium is being forced out of LCO back into solution). The voltage conventions can be confusing, but the redox definitions never are: anode = oxidation, cathode = reduction, always.

### The Separator

The **separator** is a thin porous membrane placed physically between the two electrodes. Its job is mechanical: it prevents the electrodes from touching (which would cause a short circuit) while still allowing ions to pass through its pores in the electrolyte. In lithium-ion cells, separators are typically microporous polyolefin sheets (polyethylene or polypropylene) 10–25 micrometers thick. The pore structure allows electrolyte to permeate through, maintaining ionic continuity, while the polymer matrix is insulating. One safety feature of polyethylene separators is "shutdown" — at elevated temperature, the pores melt closed, blocking ionic conduction and shutting down the cell before thermal runaway proceeds further.

### The Current Collectors

**Current collectors** are the metal foils onto which the electrode material is coated. They serve two functions: mechanical support for the porous electrode coating, and electronic conduction to carry the electron current from the electrode particles to the external terminal.

In commercial lithium-ion cells, the positive electrode is coated on aluminum foil and the negative electrode on copper foil. The choice is not arbitrary. Copper is used on the negative side because the potential of a graphite anode during normal operation (roughly 0.1–0.3 V vs. Li/Li⁺) would cause aluminum to alloy with lithium at those potentials, destroying the current collector. Copper does not form lithium alloys at these potentials, so it is safe. Aluminum is used on the positive side because copper would oxidise (corrode) at the higher potentials of the positive electrode (3.0–4.2 V vs. Li/Li⁺), while aluminum forms a stable passivation layer that does not corrode.

One of the cost and manufacturing advantages of sodium-ion cells, which we will explore in Chapter 6, is that **sodium does not alloy with aluminum at any relevant potential**, allowing aluminum foil to be used for both current collectors. Copper is the second-most expensive commodity in a lithium-ion cell after the active materials; eliminating it cuts material cost meaningfully.

### The Full Anatomy

Here is a schematic description of a cell cross-section during discharge — the kind of diagram that appears in almost every battery textbook. Picture a layered sandwich:

```text
       ┌────────── External circuit ──────────┐
       │    e⁻  →  →  →  →  (load)  →  →  →   │
       │                                      │
       ▼                                      ▼
  ┌─────────┐  ┌──────────┐  ┌─────┐  ┌──────────┐  ┌─────────┐
  │   Cu    │  │ Graphite │  │ Sep │  │   LCO    │  │   Al    │
  │  foil   │▐▐│  (porous,│▐▐│(por.│▐▐│ (porous, │▐▐│  foil   │
  │(negative│  │  e⁻+Li⁺) │  │ ion │  │  e⁻+Li⁺) │  │(positive│
  │terminal)│  │          │  │only)│  │          │  │terminal)│
  └─────────┘  └──────────┘  └─────┘  └──────────┘  └─────────┘
                     ←  ←  ←  Li⁺  ←  ←  ←
                   (through electrolyte in pores)

  During discharge:
    - Electrons leave graphite via Cu foil, traverse external load,
      re-enter cell via Al foil, and are consumed at LCO.
    - Li⁺ ions leave graphite, migrate through the porous separator,
      and are intercalated into LCO.
  The separator's pores are filled with electrolyte; the separator
  itself is electronically insulating. Current cannot flow through
  the cell interior except as ions.
```

Electrons leave the graphite anode through the copper current collector, travel through the external circuit (doing work), and arrive at the aluminum current collector. Simultaneously, Li⁺ ions leave the graphite (released by the oxidation reaction at the anode surface), travel through the electrolyte — each ion surrounded by a shell of three to five coordinated solvent molecules (typically ethylene carbonate and dimethyl carbonate), with the whole solvated complex drifting and diffusing through the pore space and threading through the separator — and are intercalated into the LCO cathode, where they combine with the arriving electrons to complete the reduction reaction.

Both currents — electronic and ionic — must flow simultaneously for the cell to operate. If the external circuit is open, the ionic current stops too: there is no sink for the Li⁺ ions, so no more Li⁺ can leave the anode, so no more electrons can be released. The cell just sits there at its open-circuit voltage (to be derived in Section 1.8), waiting.

This interdependence of electronic and ionic current is a deep constraint that drives most of the physics we will study for the rest of the book. It means, for instance, that whatever limits ionic transport in the electrolyte will limit the cell's power capability just as surely as a resistance in the external circuit would.

---

## 1.4 Standard Electrode Potentials and the Electrochemical Series

Now we have the physical picture. It is time to ask: where does the voltage come from? Why does a Daniell cell produce 1.10 V and not 0.75 V or 2.50 V? The answer is rooted in thermodynamics and is captured in the concept of **standard electrode potentials**.

### The Reference Electrode Problem

To assign a voltage to an electrode, you need a reference. This is a familiar situation in electrical engineering: voltages are always relative, and you choose a convenient zero point — chassis ground, earth ground, a signal reference — whichever is most useful for the measurement at hand. You can freely switch between references by adding or subtracting a constant offset, and nothing physical depends on which one you use. Electrochemistry works exactly the same way. Its universal "ground" is the **standard hydrogen electrode (SHE)**, against which all other electrode potentials are reported in reference tables. But just as an EE routinely uses non-ground references for convenience (differential measurements, floating supplies, etc.), electrochemists routinely use non-SHE references for convenience — most importantly the Li/Li⁺ and Na/Na⁺ references in non-aqueous battery work, which we will meet at the end of this section. Switching between references is always a simple offset, and you should feel as comfortable doing it in electrochemistry as you do in EE.

The SHE is defined as follows: a platinised platinum electrode (platinum coated with finely divided "platinum black" to catalyse the hydrogen reaction) in contact with a solution of H⁺ ions at unit activity (approximately 1 mol/L under ideal conditions), with hydrogen gas bubbled over it at 1 bar pressure, at 25°C (298.15 K). The half-reaction at the SHE is:

$$2\text{H}^+(aq) + 2e^- \rightarrow \text{H}_2(g) \quad E^\circ = 0.000 \text{ V (by definition)}$$

By international convention, this reaction is assigned a potential of exactly zero. Every other electrode potential is measured relative to this reference.

The SHE is more of a theoretical construct than a practical device — it is finicky to set up and maintain. In real experiments, secondary reference electrodes (silver/silver chloride, saturated calomel, Li/Li⁺ in non-aqueous solutions, etc.) are used. But all electrode potentials in tables are ultimately reported on the SHE scale.

### The Standard Electrode Potential

The **standard electrode potential** $E^\circ$ for a half-reaction is the potential of that half-reaction, written as a reduction, measured against the SHE under standard conditions: all dissolved species at unit activity, all gases at 1 bar, temperature at 298.15 K.

A few values to build intuition:

$$\text{F}_2 + 2e^- \rightarrow 2\text{F}^- \quad E^\circ = +2.87 \text{ V}$$
$$\text{O}_2 + 4\text{H}^+ + 4e^- \rightarrow 2\text{H}_2\text{O} \quad E^\circ = +1.23 \text{ V}$$
$$\text{Cu}^{2+} + 2e^- \rightarrow \text{Cu} \quad E^\circ = +0.34 \text{ V}$$
$$2\text{H}^+ + 2e^- \rightarrow \text{H}_2 \quad E^\circ = 0.00 \text{ V (reference)}$$
$$\text{Zn}^{2+} + 2e^- \rightarrow \text{Zn} \quad E^\circ = -0.76 \text{ V}$$
$$\text{Li}^+ + e^- \rightarrow \text{Li} \quad E^\circ = -3.04 \text{ V}$$
$$\text{Na}^+ + e^- \rightarrow \text{Na} \quad E^\circ = -2.71 \text{ V}$$

A quick note on the sign convention. A negative standard reduction potential, like $E^\circ = -3.04$ V for Li⁺/Li, does *not* mean "lithium ions don't like to be reduced" in an absolute sense; it means "lithium ions are less eager to grab an electron than a hydrogen ion is." Since we zeroed the scale at the hydrogen electrode by fiat, anything that is a weaker oxidiser than H⁺ ends up with a negative number. Equivalently — and this is the perspective that matters for battery anodes — a very negative $E^\circ$ for the reduction direction means a very *positive* $E^\circ$ for the reverse (oxidation) direction. Lithium metal very much wants to give up its electron, and that eagerness is exactly what makes it a superb anode material.

### Interpreting the Electrochemical Series

These potentials, arranged in order from most positive to most negative, constitute the **electrochemical series** (sometimes called the **activity series** in general chemistry texts; note that the "galvanic series" you will encounter in corrosion engineering is a related but distinct empirical ranking of metals in seawater, and is not identical to this thermodynamic table).

Here is how to read it physically. A large positive $E^\circ$ for the reduction half-reaction means the reaction has a strong thermodynamic tendency to proceed in the reduction direction — the species on the left strongly wants to accept electrons. Fluorine, with $E^\circ = +2.87$ V, is an extraordinarily powerful oxidising agent: it will forcibly grab electrons from almost anything. Conversely, a very negative $E^\circ$ means the reduction half-reaction has a strong tendency to proceed in reverse — the species on the right strongly wants to give electrons away. Lithium metal, with $E^\circ = -3.04$ V, is an extraordinarily powerful reducing agent: it barely wants to hold onto its electron at all.

### Predicting Cell Voltage

The **standard cell voltage** for a galvanic cell is:

$$E^\circ_\text{cell} = E^\circ_\text{cathode} - E^\circ_\text{anode}$$

where both values are reduction potentials from the table. The cathode is the electrode where reduction occurs (the more positive electrode potential), and the anode is where oxidation occurs (the more negative electrode potential).

For the Daniell cell:

$$E^\circ_\text{cell} = E^\circ_{\text{Cu}^{2+}/\text{Cu}} - E^\circ_{\text{Zn}^{2+}/\text{Zn}} = (+0.34) - (-0.76) = +1.10 \text{ V}$$

A point worth internalising: the 1.10 V we just calculated is a real, measurable, highly reproducible number. If you build a Daniell cell on your kitchen counter — zinc and copper strips in a jar of copper sulfate solution — and touch a multimeter to the two electrodes, you will read between 1.05 and 1.10 V, with the residual gap coming from non-unit activities and measurement conditions. Alessandro Volta measured closely related numbers in 1800 with nothing but wet cardboard and a gold-leaf electroscope. The tables of standard electrode potentials are not theoretical constructs; they are the distilled result of two centuries of such measurements, and the Nernst equation together with those tables lets you predict the voltage of any galvanic cell you can write the half-reactions for, to within a few tens of millivolts, before you build it. This predictive power is what makes electrochemistry a quantitative discipline, and it is the reason we can talk seriously about designing new battery chemistries on paper before ever touching a glovebox.

For a standard lithium-ion LCO/graphite cell, using $E \approx +3.9$ V for the LCO cathode and $E \approx +0.1$ V for the graphite anode, both on the Li/Li⁺ scale (we will see this non-SHE reference shortly):

$$E_\text{cell} \approx 3.9 - 0.1 \approx 3.8 \text{ V (nominal, vs. Li/Li}^+\text{)}$$

Note that we have written $E$ rather than $E^\circ$ here. Strictly speaking, neither electrode is at standard conditions — they are partially lithiated insertion hosts, not pure elements at unit activity — so what we are quoting are representative mid-discharge open-circuit potentials, not true standard potentials. The literature is loose about this distinction and often uses $E^\circ$ to mean "the typical value you will see on a voltage curve," which is how we will use it going forward, while noting that the rigorous thermodynamic $E^\circ$ for an insertion couple requires a reference state to be specified. We will pin this down more carefully in Chapter 3 when we discuss open-circuit voltage curves.

A critical practical note: battery electrode potentials are almost always reported against the **Li/Li⁺ reference** (in lithium chemistry) or the **Na/Na⁺ reference** (in sodium chemistry), not the SHE. The Li/Li⁺ reference is at $-3.04$ V vs. SHE, so to convert: $E(\text{vs. SHE}) = E(\text{vs. Li/Li}^+) - 3.04$ V. You will often see cathode potentials stated as "3.9 V vs. Li/Li⁺" — this means $3.9 - 3.04 = 0.86$ V vs. SHE. The non-aqueous world of lithium and sodium batteries always uses the metal-ion reference because the SHE is not experimentally accessible in organic electrolytes.

The key insight from the electrochemical series is this: **cell voltage is a measure of the thermodynamic driving force for electron transfer between the two electrode materials.** Materials with a large difference in their electrode potentials produce high cell voltage. This is why lithium, with the most negative reduction potential of any element, is such a desirable battery anode material — it produces the highest possible voltage when paired with an oxidising cathode, and voltage multiplied by capacity gives energy density.

There is one more observation worth pausing on. Among the alkali metals — Li, Na, K, Rb, Cs — lithium has both the smallest atomic mass (6.94 g/mol) and the most negative standard reduction potential (−3.04 V vs SHE). These two facts are the reason lithium-ion batteries dominate the portable energy storage landscape. High voltage times high specific capacity (small molar mass means many moles of electrons per gram, via Faraday's first law) equals high gravimetric energy density. No other element in the periodic table combines light mass and strongly negative reduction potential as favourably as lithium does. Sodium is the closest contender — 23 g/mol, −2.71 V vs SHE — and even that modest shift costs about 10–15% on both voltage and specific capacity compared to lithium. The value proposition of sodium-ion batteries is therefore not "better energy density" (it never will be); it is abundance, cost, low-temperature behaviour, safety, and strategic supply-chain considerations, all of which we will unpack in Chapters 6 and 13. When someone asks you "why not just use sodium instead of lithium in a laptop?", the answer is right here in the electrochemical series and in the periodic table: at the cell level, you are giving up roughly 15% of the energy density in exchange for abundance and safety, and that tradeoff is great for grid storage and entry-level EVs but not for laptops. Holding this tradeoff clearly in mind is one of the most useful mental anchors a battery person can have.

### A Note on the Word "Potential"

Electrochemistry uses the word *potential* in several related but distinct ways, and it is worth laying them out explicitly before we continue, because a reader who conflates them will get stuck. Here is a compact comparison.

| Quantity | Symbol | Units | What it measures | Where it appears |
| --- | --- | --- | --- | --- |
| Electrode potential | $E$ | V | Voltage of an electrode vs a reference electrode, under the current conditions | Nernst equation output; what a voltmeter reads |
| Standard electrode potential | $E^\circ$ | V | The same thing, evaluated at standard conditions (unit activities, 1 bar, 298 K) | Reference tables; Nernst equation starting point |
| Chemical potential | $\mu_i$ | J/mol | Free energy per mole of species $i$; the "voltage for particles" governing chemical equilibrium | Thermodynamic derivations; driving force for diffusion |
| Electrochemical potential | $\tilde{\mu}_i$ | J/mol | Chemical potential plus the electrostatic energy of ion $i$ in the local potential: $\tilde{\mu}_i = \mu_i + z_i F \phi$ | Transport equations (Nernst–Planck); what really drives ion flow in a cell |

Electrode potential and standard electrode potential both have units of volts and both describe the voltage of an electrode relative to a reference — they differ only in the conditions at which they are evaluated. Chemical potential is a completely different kind of quantity: it has units of energy per mole, and it governs chemical equilibrium in the way that voltage governs electrical equilibrium. Electrochemical potential, which we will meet properly in Chapter 2 (ion transport) and Chapter 8 (concentrated solution theory), is the quantity that actually drives ion flow inside a cell — it combines the chemical driving force (gradient in $\mu$) with the electrical driving force (gradient in $\phi$) into a single expression.

For this chapter, you only need to keep the first three straight. When we say "electrode potential" we mean volts; when we say "chemical potential" we mean joules per mole; when we say "standard electrode potential" we mean volts under a specific reference condition. If a sentence ever leaves you confused about which one is meant, check the units — they will tell you immediately.

---

## 1.5 The Nernst Equation and What It Predicts

The standard electrode potentials in Section 1.4 are defined at standard conditions: unit activity, 298 K, 1 bar. But real batteries do not operate at standard conditions. The lithium ion concentration in a cell's electrolyte changes as the cell charges and discharges. The lithium content in the electrode host materials changes continuously. Temperature varies. The question we need to answer is: how does electrode potential change when conditions deviate from standard?

The answer is the **Nernst equation**, and it is one of the most important equations in all of electrochemistry. Let us derive it from thermodynamics, carefully.

### Derivation

Consider a general half-reaction written as a reduction:

$$a A + b B + ne^- \rightarrow c C + d D$$

where $A$ and $B$ are the oxidised species, $C$ and $D$ are the reduced species, $n$ is the number of electrons transferred, and $a$, $b$, $c$, $d$ are stoichiometric coefficients.

The **Gibbs free energy change** for this reaction, at non-standard conditions, is related to the standard Gibbs free energy change $\Delta G^\circ$ by:

$$\Delta G = \Delta G^\circ + RT \ln Q \tag{1.1}$$

where $R = 8.314$ J mol⁻¹ K⁻¹ is the gas constant, $T$ is temperature in Kelvin, and $Q$ is the **reaction quotient** — the ratio of the activities of products to reactants, each raised to their stoichiometric power:

$$Q = \frac{a_C^c \cdot a_D^d}{a_A^a \cdot a_B^b} \tag{1.2}$$

(We will define **activity** precisely in Section 1.6. For now, treat it as a normalised concentration.)

Now, the Gibbs free energy change is related to the cell potential by:

$$\Delta G = -nFE \tag{1.3}$$

where $F = 96{,}485$ C/mol is **Faraday's constant** — the total charge of one mole of electrons — and $E$ is the electrode potential. You can take this equation on faith for now — we will derive it rigorously in Section 1.8 — but the intuition behind it is worth stating here, because it is almost trivial. The left-hand side is the Gibbs free energy released per mole of reaction. The right-hand side is the electrical work done per mole of reaction, which is (charge transferred per mole of reaction) × (potential through which that charge moves). The charge transferred per mole is $nF$: $n$ electrons per formula unit, $F$ coulombs per mole of electrons. The potential is $E$. So the product is $nFE$ joules per mole. The minus sign enforces the convention that a spontaneous reaction ($\Delta G < 0$) drives a positive cell voltage ($E > 0$), which is what "spontaneous" means operationally — you can stick a voltmeter on the cell and read a positive number. Equation (1.3) is literally "free energy released equals electrical work done," which is just the first law of thermodynamics specialised to a reversible electrochemical cell.

Similarly, at standard conditions:

$$\Delta G^\circ = -nFE^\circ \tag{1.4}$$

Substituting equations (1.3) and (1.4) into (1.1):

$$-nFE = -nFE^\circ + RT \ln Q$$

Dividing through by $-nF$:

$$E = E^\circ - \frac{RT}{nF} \ln Q \tag{1.5}$$

This is the **Nernst equation**. It tells us how the electrode potential changes from its standard value as the composition of the system departs from standard conditions. At 298 K, the prefactor $RT/F = (8.314 \times 298.15)/96485 = 0.02569$ V, and converting the natural log to log base 10:

$$E = E^\circ - \frac{0.05916}{n} \log_{10} Q \tag{1.6}$$

The factor 0.05916 V ≈ 59.16 mV is called the **Nernst slope** (sometimes "the 59 mV rule"), and it appears constantly in electrochemistry. At room temperature, a tenfold change in the activity ratio shifts the potential by about 59 mV per electron transferred. For a two-electron reaction, a tenfold change shifts the potential by about 30 mV. This is a small but measurable shift — it matters for precision OCV (open-circuit voltage) modelling.

### Physical Interpretation

The Nernst equation is telling us something physically sensible: the tendency of a species to be reduced depends on how much of it is available. If you have a very high concentration of oxidised species (Q is small), the reduction reaction can proceed more easily — the potential is higher than $E^\circ$. If the oxidised species is nearly exhausted (Q is large), the potential is lower. This is, in a sense, a free-energy argument dressed up in electrical language.

In a battery context, the Nernst equation is the thermodynamic backbone of the **open-circuit voltage (OCV) curve** — the voltage you measure when no current is flowing, as a function of state of charge. The "state of charge" of a battery is essentially a measure of the lithium (or sodium) content of the electrodes, and as that content changes, the activity of Li in the host changes, and the cell voltage changes accordingly. But here is the subtlety: for a real electrode material, the relationship between Li content and Li activity is not a simple logarithm. It reflects the statistical mechanics of site occupancy, the interactions between Li ions in neighbouring sites, phase transitions as the host restructures, and in some materials (LiFePO₄ being the canonical example) two-phase coexistence over large composition ranges. So while the Nernst equation *form* is right — potential is always $E^\circ - (RT/nF)\ln Q$ in equilibrium — the $Q$ for an intercalation host is a much richer object than the dilute-solution version we used for the Cu²⁺ half-cell. We will address these host-specific effects in Chapter 2 and Chapter 3.

### A Worked Example

Consider the reduction reaction for a copper half-cell:

$$\text{Cu}^{2+}(aq) + 2e^- \rightarrow \text{Cu}(s) \quad E^\circ = +0.34 \text{ V}$$

What is the electrode potential if the Cu²⁺ concentration is reduced to 0.001 mol/L instead of the standard 1 mol/L?

Here $n = 2$, and the reaction quotient is:

$$Q = \frac{a_{\text{Cu}}}{a_{\text{Cu}^{2+}}} = \frac{1}{0.001} = 1000$$

(where we take the activity of solid copper to be 1, by convention — pure solids have unit activity.)

$$E = 0.34 - \frac{0.05916}{2} \log_{10}(1000) = 0.34 - (0.02958)(3) = 0.34 - 0.089 = +0.251 \text{ V}$$

So diluting the Cu²⁺ by a factor of 1000 drops the electrode potential by about 89 mV. This is a real, measurable effect. If you connected this dilute copper half-cell to a Daniell cell zinc electrode (at standard conditions), the cell voltage would be $0.251 - (-0.76) = 1.011$ V rather than the standard 1.10 V.

### The Nernst Equation in Battery Research

For a battery researcher, the Nernst equation's most important application is in understanding the shape of OCV curves. When you plot the open-circuit voltage of a cell versus its state of charge, the shape of that curve carries thermodynamic information about the electrode materials.

A region where voltage changes smoothly and monotonically with SOC corresponds to a **single-phase reaction** — one homogeneous phase whose composition (and therefore whose Li activity) is sliding continuously through some range as lithium is added or removed. The Nernst equation turns that continuously varying activity into a continuously varying voltage, and you see a sloped OCV curve.

A **flat voltage plateau**, on the other hand, is the signature of a **two-phase reaction** — a regime in which the host material contains two coexisting phases (say, a lithium-rich phase and a lithium-poor phase), and adding more lithium to the cell simply converts some of the lithium-poor phase into the lithium-rich phase without changing the composition of either one. The canonical example is LiFePO₄: across most of its usable composition range, the material is a mixture of nearly-stoichiometric LiFePO₄ and nearly-stoichiometric FePO₄, in varying proportions. Here is the key thermodynamic point: as long as the two phases coexist, their individual compositions — and therefore the activities of lithium in each — are fixed by the equilibrium between them. There is no composition variable left to change. The Nernst equation then gives a fixed voltage, independent of how much total lithium is in the cell. The result is a plateau.

The practical payoff is large: looking at an OCV curve, you can tell at a glance where the electrode is in a single-phase regime (sloped) and where it is in a two-phase regime (flat), and you can read off the two-phase equilibrium voltage directly from the plateau height. This connection between OCV curve shape and electrode thermodynamics is the basis of a powerful characterisation technique (GITT, the Galvanostatic Intermittent Titration Technique) that we will study in Chapter 3.

---

## 1.6 Activity vs. Concentration — and Why the Distinction Matters Later

In writing the Nernst equation we used the symbol $a$ for activity and quietly noted it was "like a normalised concentration." It is time to be more precise, because the distinction between activity and concentration will matter when we get to real electrolyte solutions and to the activity of lithium (or sodium) within electrode host materials.

### Why Concentration Is Not Enough

The thermodynamic quantity that governs chemical equilibria and electrode potentials is the **chemical potential** $\mu$ of a species. You can think of $\mu$ as the "voltage for particles": just as voltage tells you how much electrical work it takes to move a unit of charge into a region, the chemical potential of species $i$ tells you how much Gibbs free energy it takes to add one mole of species $i$ to a system (holding temperature, pressure, and the amounts of all other species fixed). Formally,

$$\mu_i = \left(\frac{\partial G}{\partial n_i}\right)_{T, P, n_{j \neq i}}$$

and $\mu_i$ has units of joules per mole. A species spontaneously flows from regions of high chemical potential to regions of low chemical potential, in exactly the same sense that current flows from high voltage to low voltage — and at equilibrium, the chemical potential of each species is uniform everywhere it is free to go. If you are comfortable with the fact that an electrical network reaches steady state when voltages equilibrate across every unconstrained node, you already have the right mental model for chemical equilibrium; just replace "voltage" with "chemical potential" and "charge" with "moles of species $i$."

For an ideal gas or an ideally dilute solution, the chemical potential depends logarithmically on concentration:

$$\mu = \mu^\circ + RT \ln\left(\frac{c}{c^\circ}\right) \tag{1.7}$$

where $c$ is molar concentration, $c^\circ$ is a reference concentration (conventionally 1 mol/L), and $\mu^\circ$ is the standard chemical potential referenced to that state. The logarithmic form is not a choice — it falls out of statistical mechanics when you count the number of microstates accessible to non-interacting particles at concentration $c$, and the entropy contribution becomes logarithmic in the dimensionless ratio $c/c^\circ$. This is where the $\ln Q$ term in the Nernst equation ultimately comes from: the Nernst log is a chemical-potential log in disguise.

But real solutions at finite concentration are not ideal. Ions interact with each other electrostatically. The solvent molecules around an ion are disturbed, and those disturbances extend to the neighbours of that ion and their neighbours. The result is that the effective "thermodynamic concentration" — the concentration that correctly predicts equilibria and electrode potentials — is not the actual molar concentration, but a corrected quantity.

### Defining Activity

The **activity** $a_i$ of species $i$ is defined such that the chemical potential always takes the clean form:

$$\mu_i = \mu_i^\circ + RT \ln a_i \tag{1.8}$$

For an ideal solution, $a_i = c_i / c^\circ$ where $c^\circ = 1$ mol/L is the standard concentration. The activity and concentration are equal (in the normalised sense) when the solution behaves ideally.

For a non-ideal solution, the activity is related to concentration through the **activity coefficient** $\gamma_i$:

$$a_i = \gamma_i \cdot \frac{c_i}{c^\circ} \tag{1.9}$$

In dilute aqueous solutions, $\gamma \approx 1$ and activity ≈ normalised concentration. In concentrated solutions, or in the organic electrolytes of lithium-ion batteries (where concentrations of 1 mol/L are typical and interactions are significant), $\gamma$ can deviate substantially from 1 — sometimes by factors of two or more.

For solid species and pure liquids, the activity is defined as 1. This is why the activity of solid copper, solid lithium, or crystalline electrode materials appears as 1 in reaction quotients.

### Activity of Lithium in an Electrode Host

This is where activity becomes subtle and important for battery applications. The "concentration" of lithium in a graphite electrode, for instance, is not a simple ionic concentration in solution — it is the fraction of available sites that are occupied by lithium atoms in the graphite lattice. This quantity, called the **stoichiometric coefficient** or **insertion fraction** $x$ (so the electrode composition is written as Li$_x$C$_6$, $0 \le x \le 1$), enters the Nernst equation through the activity of lithium in the host material. The relationship between $a_\text{Li}$ in the host and $x$ depends on the statistical mechanics of site occupancy and the interaction energies between lithium atoms in neighbouring sites.

In an ideal insertion material with no interactions — a lattice of $N$ identical sites, each of which can be either occupied or empty, with no energetic preference for any particular arrangement — the activity takes a simple form that is worth deriving, because it is our first glimpse of how statistical mechanics enters battery thermodynamics. Let $x$ be the fraction of occupied sites, so $Nx$ sites hold a Li atom and $N(1-x)$ are empty. The entropy of mixing for such a lattice is

$$S_\text{mix} = -k_B N \left[ x \ln x + (1-x) \ln(1-x) \right]$$

and the chemical potential of Li in the host, taken as the derivative $\partial G / \partial N_\text{Li}$ at fixed temperature, picks up only the configurational entropy contribution (since we assumed no interactions):

$$\mu_\text{Li} = \mu_\text{Li}^\circ + RT \ln\left(\frac{x}{1-x}\right)$$

(where we have used $N_A k_B = R$ to convert from per-site to per-mole quantities.) Comparing with equation (1.8), we read off the activity:

$$a_\text{Li} = \frac{x}{1-x} \tag{1.10}$$

This is a **Langmuir-type isotherm**, and it captures an intuition you should carry with you: when the host is nearly empty ($x \to 0$), adding more lithium is easy (low chemical potential, high activity ratio of empty-to-full sites); when the host is nearly full ($x \to 1$), adding more lithium is hard (high chemical potential, because the few remaining sites are "hard to find"). Feed this activity into the Nernst equation and you get an OCV that drops monotonically from +∞ to −∞ as $x$ sweeps from 0 to 1 — a smooth, featureless logarithmic curve.

Real electrode materials almost never produce curves this simple. Interactions between neighbouring Li atoms (repulsive in some materials, attractive in others), ordering transitions (where Li atoms arrange into specific superlattices at particular compositions), staging phenomena (where Li preferentially fills every $k$-th layer in graphite), and outright two-phase coexistence (like the LiFePO₄ ↔ FePO₄ conversion) all cause deviations — plateaus, steps, wiggles, hysteresis. The OCV curve of a real cell is a fingerprint of all these effects superimposed on the basic Langmuir backbone. Reading that fingerprint is a large part of what OCV-based characterisation is about, and we will return to it in Chapter 3.

The practical takeaway is this: when you see $Q$ in the Nernst equation in a battery context, do not assume you can replace activity with molar concentration. For electrode materials, the relevant quantity is the chemical activity of the ion in the host lattice, which is related to (but not equal to) the fractional site occupancy. For electrolyte species in dilute solutions, activity ≈ concentration is often a good approximation, but for concentrated electrolytes or systems where precise thermodynamics matters, the activity coefficient must be accounted for.

We will not need to work through the full statistical-mechanical derivation of activity coefficients in this book — that belongs to a statistical thermodynamics course. What you need is the conceptual understanding: activity is the thermodynamically correct measure of "how much of this species is available to do work," and it coincides with (normalised) concentration only for ideal systems.

---

## 1.7 Faraday's Laws of Electrolysis — Linking Charge to Mass

Michael Faraday, working in the 1830s before any atomic theory of matter was established, made a series of experimental observations about electrolysis that are, with our modern understanding, completely unsurprising — and yet remain among the most practically useful quantitative relationships in all of electrochemistry.

### First Law

**Faraday's First Law of Electrolysis:** The mass of a substance deposited or dissolved at an electrode is directly proportional to the total charge that has passed through the electrode.

In modern notation:

$$m = \frac{M}{nF} Q_\text{total} \tag{1.11}$$

where $m$ is mass in grams, $M$ is the molar mass of the substance in g/mol, $n$ is the number of electrons transferred per formula unit in the half-reaction, $F = 96{,}485$ C/mol is Faraday's constant, and $Q_\text{total}$ is the total charge in coulombs.

This law is exact — it is a consequence of charge conservation and the quantised nature of electron transfer. There are no approximations here.

### Second Law

**Faraday's Second Law of Electrolysis:** The same quantity of electricity always deposits or dissolves the same number of equivalents of any substance.

In practice this means: if you pass the same total charge through two different electrolytic cells in series, the ratio of masses deposited in the two cells is the ratio $M/n$ for each substance. The quantity $M/n$ is called the **equivalent weight** of the substance.

### Faraday's Constant

Faraday's constant $F$ is the charge of one mole of electrons:

$$F = N_A \cdot e = (6.022 \times 10^{23} \text{ mol}^{-1}) \times (1.602 \times 10^{-19} \text{ C}) = 96{,}485 \text{ C/mol}$$

where $N_A$ is Avogadro's number and $e$ is the elementary charge. Operationally, you can think of $F$ as a unit-conversion factor between the chemist's world (moles of stuff) and the engineer's world (coulombs of charge): 96 485 coulombs buys you exactly one mole of single-electron-per-ion reaction. Whenever you need to convert between "how much current flowed" and "how many ions moved," $F$ is the conversion. This is exactly why it appears in both the Nernst equation and in $\Delta G = -nFE$: both equations are relating a molar thermodynamic quantity to a per-charge electrical quantity, and $F$ is the bridge.

Historically, this relationship is also a lovely piece of science: Faraday derived his constant empirically in the 1830s, with no knowledge of electrons, atoms, or Avogadro's number, simply by carefully weighing how much metal a given amount of charge deposited in electrolysis. The fact that his empirical number agrees precisely with $N_A \cdot e$ — a product of two quantities he had no access to — was one of the early confirmations of atomic theory.

### Using Faraday's Laws: Two Worked Examples

**Example 1: Theoretical capacity of a lithium cobalt oxide cathode.**

Lithium cobalt oxide, LiCoO₂ (molar mass $M = 97.87$ g/mol), can deliver one lithium ion per formula unit during discharge, corresponding to $n = 1$ electron transferred. The theoretical gravimetric capacity is the amount of charge that can be stored per gram of material:

$$Q_\text{specific} = \frac{nF}{M} = \frac{1 \times 96{,}485 \text{ C/mol}}{97.87 \text{ g/mol}} = 985.9 \text{ C/g} = 273.9 \text{ mAh/g}$$

(using the conversion $1 \text{ Ah} = 3600 \text{ C}$, so $985.9 / 3600 = 273.9 \text{ mAh/g}$).

In practice, only about half of the lithium can be extracted from LiCoO₂ before the structure becomes unstable (extracting more than $x \approx 0.5$ from Li$_{1-x}$CoO₂ risks cobalt dissolution and structural collapse), so the practical specific capacity of LCO is approximately 140–160 mAh/g.

**Example 2: How much lithium is deposited during a charge cycle?**

A lithium-ion cell has a capacity of 3.0 Ah. During charging, how many grams of lithium are inserted into the graphite anode?

Using Faraday's first law with $n = 1$ (one electron per Li⁺), $M_\text{Li} = 6.941$ g/mol:

$$m = \frac{M}{nF} \cdot Q = \frac{6.941 \text{ g/mol}}{1 \times 96{,}485 \text{ C/mol}} \times (3.0 \text{ Ah} \times 3600 \text{ C/Ah})$$

Let us track the units carefully. $M/(nF)$ has units of (g/mol) ÷ (C/mol) = g/C, so it is telling us how many grams of lithium are delivered per coulomb of charge passed. Numerically,

$$\frac{M}{nF} = \frac{6.941}{96{,}485} = 7.19 \times 10^{-5} \text{ g/C}$$

The total charge passed is

$$Q = 3.0 \text{ Ah} \times 3600 \text{ C/Ah} = 10{,}800 \text{ C}$$

and so

$$m = (7.19 \times 10^{-5} \text{ g/C}) \times (10{,}800 \text{ C}) = 0.777 \text{ g}$$

A 3 Ah lithium-ion cell cycles roughly 0.78 grams of lithium back and forth between electrodes during each charge-discharge cycle. For context, a typical 18650 cell (the cylindrical form factor you might find in a laptop battery) has a capacity of about 3.0–3.5 Ah, so this calculation is directly applicable.

### The Connection to Capacity Measurements

This is where Faraday's laws become indispensable for battery engineers. **Capacity** — the amount of charge a cell can store — is measured in ampere-hours (Ah) or milliampere-hours (mAh). Faraday's first law is the bridge between the electrical measurement (charge in Ah) and the chemical reality (moles of lithium or sodium cycled). This bridge is used constantly: to calculate theoretical capacities from crystal chemistry, to determine how much cyclable lithium inventory has been lost to side reactions (the mechanism we will meet in Chapter 7 as "loss of lithium inventory," one of the three canonical degradation modes), and to interpret results from techniques like ICP-OES (Inductively Coupled Plasma Optical Emission Spectrometry) that measure elemental composition of harvested electrodes. Every time a paper reports capacity fade in mAh per cycle, there is an implicit Faraday's-law conversion behind it from coulombs of lost capacity to moles of trapped lithium.

A key quantity derived from Faraday's laws is the **theoretical specific capacity** $C_\text{th}$ of an electrode material (in mAh/g):

$$C_\text{th} = \frac{nF}{3.6 \cdot M} \tag{1.12}$$

where the factor 3.6 converts C/g to mAh/g ($3600 \text{ C/Ah} = 3.6 \text{ C/mAh}$). This equation is worth memorising — you will use it every time you encounter a new electrode material.

---

## 1.8 Gibbs Free Energy and Cell Voltage

We have been using the relationship $\Delta G = -nFE$ without deriving it. This section provides that derivation, because understanding the thermodynamic origin of cell voltage is essential to understanding why voltage changes with temperature, state of charge, and current — effects that will matter throughout the book.

### The Work Done by a Galvanic Cell

Consider a galvanic cell operating reversibly — meaning it operates infinitely slowly, in thermodynamic quasi-static equilibrium, with no kinetic losses. (We will relax this assumption in Chapter 2 when we introduce Butler-Volmer kinetics.) Under these ideal conditions, all of the Gibbs free energy released by the cell reaction is converted to electrical work.

The **maximum electrical work** that a system can do at constant temperature and pressure equals the decrease in Gibbs free energy:

$$W_\text{elec,max} = -\Delta G \tag{1.13}$$

Now, what is the electrical work done when a charge $Q$ moves through a potential difference $E$? It is simply $W = QE$ (in joules). For one mole of reaction proceeding, the charge transferred is $nF$ coulombs (from Faraday's laws). Therefore:

$$W_\text{elec,max} = nFE$$

Setting this equal to $-\Delta G$:

$$-\Delta G = nFE$$

$$\boxed{\Delta G = -nFE} \tag{1.14}$$

This relationship is exact under the assumption of reversible operation. It connects the thermodynamics (the Gibbs free energy of the cell reaction) to the electrochemistry (the cell voltage and the moles of charge transferred). It is, in a sense, the fundamental equation of electrochemistry.

### Interpreting the Signs

The sign convention in equation (1.14) is worth dwelling on. A spontaneous reaction has $\Delta G < 0$. With $n > 0$ and $F > 0$, this means $E > 0$ for a spontaneous (galvanic) cell. Conversely, a non-spontaneous reaction has $\Delta G > 0$ and would require $E < 0$ — meaning you would need to apply a voltage larger than $|E|$ from the outside to drive the reaction (the electrolytic case). The formula is consistent with our earlier physical description.

At standard conditions, $\Delta G^\circ = -nFE^\circ$. Substituting into $\Delta G = \Delta G^\circ + RT \ln Q$ immediately gives us back the Nernst equation (equation 1.5). So the Nernst equation is simply $\Delta G = -nFE$ combined with the thermodynamic relation for non-standard states. There is nothing mysterious about it: it is just thermodynamics in electrical language.

### The Temperature Coefficient of Cell Voltage

One immediate consequence of equation (1.14) is a relationship between cell voltage and temperature. From thermodynamics, the Gibbs free energy is related to enthalpy and entropy:

$$\Delta G = \Delta H - T\Delta S \tag{1.15}$$

Combining with (1.14):

$$E = -\frac{\Delta G}{nF} = -\frac{\Delta H - T\Delta S}{nF} = -\frac{\Delta H}{nF} + \frac{T\Delta S}{nF} \tag{1.16}$$

To differentiate this with respect to temperature, we need to recognise that $\Delta H$ and $\Delta S$ are themselves functions of temperature — but only weakly. Over the modest temperature ranges relevant to battery operation (say, −20 °C to +60 °C), both can be treated as approximately constant, and the $-\Delta H/(nF)$ term contributes essentially nothing to the derivative. (The rigorous statement is that $(\partial \Delta H / \partial T)_P = \Delta C_P$ and $(\partial \Delta S / \partial T)_P = \Delta C_P / T$, and these two contributions cancel in the derivative of $\Delta G$ because of the Gibbs–Helmholtz relation — so the result below is actually exact, not approximate.) Differentiating (1.16) at constant pressure and treating $\Delta H$ and $\Delta S$ as constants gives:

$$\left(\frac{\partial E}{\partial T}\right)_P = \frac{\Delta S}{nF} \tag{1.17}$$

This is the **temperature coefficient of the cell voltage**, sometimes called the **entropic coefficient**. It is not a nuisance — it carries real information. The entropy change of the cell reaction $\Delta S$ can be measured by measuring how the open-circuit voltage changes with temperature, a technique called **electrochemical calorimetry**. More practically, this temperature coefficient contributes to heat generation in the cell (the "entropic heat" or reversible heat), which is a component of the full heat generation equation we will derive in Chapter 8 (the Bernardi equation).

Typical values of $(\partial E/\partial T)_P$ for lithium-ion cells are on the order of $\pm 0.1$ to $\pm 1$ mV/K, and the sign can change with state of charge. This means that at some states of charge, an LFP cell actually absorbs heat during discharge (endothermic, $\Delta S > 0$) and releases heat during charging — counterintuitive but thermodynamically consistent.

### The Gibbs Free Energy of the Full Cell Reaction

To complete the picture, let us compute $\Delta G^\circ$ for the LCO/graphite cell using tabulated data.

The overall cell reaction for the **discharge** of an LCO/graphite cell is approximately:

$$\text{Li}_{1-x}\text{CoO}_2 + \text{Li}_x\text{C}_6 \rightarrow \text{LiCoO}_2 + \text{C}_6$$

Let us compute for the standard discharge of the full cell. Using $E_\text{cell} \approx 3.8$ V and $n = 1$ (per Li):

$$\Delta G = -nFE = -(1)(96{,}485 \text{ C/mol})(3.8 \text{ V}) = -366{,}643 \text{ J/mol} \approx -367 \text{ kJ/mol}$$

This is the maximum electrical energy available per mole of lithium transferred. To express this per kilogram of LiCoO₂:

$$\text{Energy density} = \frac{367{,}000 \text{ J/mol}}{97.87 \text{ g/mol}} = 3{,}749 \text{ J/g} = 3{,}749{,}000 \text{ J/kg}$$

Converting to Wh/kg: $3{,}749{,}000 / 3600 \approx 1{,}041$ Wh/kg.

This is the **theoretical gravimetric energy density based on the cathode mass alone**. In a real cell, the full cell mass includes the anode, electrolyte, separator, current collectors, and packaging, which together reduce the practical energy density to 150–250 Wh/kg for a complete 18650 cell. The gap between theoretical and practical energy density is one of the central engineering challenges in battery cell design, and understanding it requires everything in Parts III through VI of this book.

---

## Worked Interpretation Exercise: Reading a Half-Reaction Table

Let us now apply everything in this chapter to a real example from the battery literature. Consider the following entry from a published paper on hard carbon anodes for sodium-ion batteries (a slight simplification of data from Komaba et al., Advanced Functional Materials, 2011):

> "The half-cell was assembled with hard carbon as the working electrode and metallic sodium as the counter/reference electrode. Reversible capacity of 265 mAh/g was measured in the potential range 0.01–2.0 V vs. Na/Na⁺ at 25 mA/g. A sloping region from 2.0 to 0.1 V vs. Na/Na⁺ accounts for approximately 200 mAh/g, while a low-voltage plateau below 0.1 V contributes the remaining 65 mAh/g."

Walk through this with me.

**"Half-cell with metallic sodium as counter/reference electrode"** — this tells us the voltage scale. All potentials reported are on the Na/Na⁺ scale (analogous to the Li/Li⁺ scale). Metallic sodium has $E^\circ = -2.71$ V vs. SHE, so to convert: $E(\text{vs. SHE}) = E(\text{vs. Na/Na}^+) - 2.71$ V. But for our purposes within the sodium world, we just work in V vs. Na/Na⁺.

**"Reversible capacity of 265 mAh/g"** — using Faraday's first law, we can calculate the mass of sodium cycled per gram of hard carbon. With $n = 1$ (one electron per Na⁺), $M_\text{Na} = 22.99$ g/mol:

$$m_\text{Na} = \frac{M_\text{Na}}{nF} \cdot (0.265 \text{ Ah/g} \times 3600 \text{ C/Ah}) = \frac{22.99}{96{,}485} \times 954 = 0.2274 \text{ g Na per g carbon}$$

So every gram of hard carbon cycles about 0.23 grams of sodium in each charge-discharge cycle.

**"0.01–2.0 V vs. Na/Na⁺"** — this is the operating window. The lower cutoff at 0.01 V is set to avoid sodium metal plating (the potential must stay above 0 V vs. Na/Na⁺ to avoid plating). The upper cutoff at 2.0 V is set to avoid electrolyte oxidation.

**"Sloping region from 2.0 to 0.1 V"** — in this region, the sodium activity in the hard carbon changes continuously with insertion fraction, producing a varying potential per the Nernst equation. This is a single-phase insertion process. The 200 mAh/g here corresponds to sodium filling defect sites, edge sites, and interlayer positions in the turbostratically stacked graphene-like domains of the hard carbon structure.

**"Low-voltage plateau below 0.1 V"** — a flat plateau signals a process in which the sodium activity in the host stays roughly constant as more sodium is added, which thermodynamically corresponds to a two-phase (or quasi-two-phase) regime (remember, when two phases coexist, the activity ratio is fixed and the voltage is constant). The microscopic origin of this plateau in hard carbon is still actively debated. The currently dominant picture — and the one you should hold in your head as a first approximation — is that sodium fills the closed nanopores inside hard carbon particles as "quasi-metallic" sodium clusters, in a state thermodynamically close to bulk metallic sodium. This would explain why the plateau sits just a few tens of millivolts above the Na/Na⁺ potential: the sodium activity in those pores is very close to 1. Earlier models (Stevens and Dahn, 2000) assigned the plateau to intercalation between graphene-like sheets and the sloping region to adsorption on defect sites, essentially the opposite assignment. You will see both pictures in the literature. For the purposes of this chapter, the important point is that *a flat OCV plateau is a thermodynamic signature of fixed activity*, regardless of which microscopic mechanism is responsible.

This is the kind of reading you should be able to do fluently by the end of this book. We have just combined Faraday's laws, the Nernst equation, the concept of activity, and the standard electrode potential framework to extract physical meaning from four lines of a paper abstract.

---

## What Changes for Sodium-Ion?

Most of what we covered in this chapter applies to sodium-ion batteries without modification. The Nernst equation, Faraday's laws, Gibbs free energy, and half-reaction notation are universal — they were derived from thermodynamics, not from any specific chemistry. What changes between Li-ion and SIB is the *numerical content*: specific potentials, specific ionic sizes, specific host materials. Those numerical differences will turn out to have consequences that reach all the way up into BMS algorithms, but at this stage of the book the preview is deliberately brief. Here are the two most important differences to plant in your head now.

The most important difference is the **standard electrode potential of sodium versus lithium**. The Na/Na⁺ couple sits at $-2.71$ V vs. SHE, compared to $-3.04$ V for Li/Li⁺. This 0.33 V difference in anode potential means that, all else being equal, a sodium-ion cell will have about 0.33 V less thermodynamic voltage than a comparable lithium-ion cell — and since energy density scales with voltage, this is a fundamental (though not fatal) energy density disadvantage.

The second difference is the ionic radius: Na⁺ is 1.02 Å, compared to 0.76 Å for Li⁺. For reasons that are partly size-related and partly thermodynamic (the formation energy of Na-graphite intercalation compounds is unfavourable in carbonate electrolytes), bare Na⁺ does not intercalate into graphite to useful capacity at room temperature in conventional electrolytes. This is why hard carbon, with its disordered, defect-rich, and pore-containing microstructure, is the dominant SIB anode material. (There is a small research literature on *solvent co-intercalation* into graphite using ether electrolytes, which does give usable capacity, but this is not the commercial route.) The Na⁺/Li⁺ size difference also affects which cathode crystal structures can host the ion and how the Nernst-equation activity varies with insertion fraction — layered oxides, for instance, adopt different stackings (O3, P2) depending on the Na content, because the larger ion prefers different coordination environments than Li⁺ does.

We will revisit these consequences in detail in Chapter 6 and Chapter 13.

---

## Chapter Summary

**Key ideas:**

- A galvanic cell converts chemical energy to electrical energy spontaneously ($\Delta G < 0$). An electrolytic cell consumes electrical energy to drive a non-spontaneous chemical reaction ($\Delta G > 0$). A rechargeable battery is a galvanic cell on discharge and an electrolytic cell on charge.
- Oxidation is loss of electrons; reduction is gain of electrons. Half-reactions always come in pairs. The anode is the site of oxidation; the cathode is the site of reduction.
- A cell's anatomy: two electrodes (porous active material coated on current collectors), a liquid electrolyte (ionically conducting, electronically insulating), and a separator (prevents electrical short while allowing ionic transport).
- Standard electrode potentials quantify the thermodynamic tendency of a half-reaction, measured against the SHE. Cell voltage is the difference in reduction potentials: $E^\circ_\text{cell} = E^\circ_\text{cathode} - E^\circ_\text{anode}$.
- The Nernst equation, $E = E^\circ - \frac{RT}{nF}\ln Q$, corrects the standard potential for non-standard activities. It is derived from $\Delta G = \Delta G^\circ + RT\ln Q$ combined with $\Delta G = -nFE$.
- Activity is the thermodynamically correct measure of species availability. For ideal dilute solutions, activity equals normalised concentration. For solid electrode materials, activity depends on site occupancy and interaction energies in the host lattice; the ideal non-interacting limit gives a Langmuir isotherm $a_\text{Li} = x/(1-x)$.
- Faraday's laws link charge to mass: $m = \frac{M}{nF} Q_\text{total}$. Theoretical specific capacity is $C_\text{th} = nF / (3.6M)$ in mAh/g.
- Cell voltage is thermodynamically grounded: $\Delta G = -nFE$. The temperature coefficient of voltage, $(\partial E / \partial T)_P = \Delta S / nF$, connects cell thermodynamics to heat generation.

**Key equations:**

$$E^\circ_\text{cell} = E^\circ_\text{cathode} - E^\circ_\text{anode} \quad \text{(standard cell voltage)}$$

$$E = E^\circ - \frac{RT}{nF}\ln Q \quad \text{(Nernst equation)}$$

$$m = \frac{M}{nF} Q_\text{total} \quad \text{(Faraday's first law)}$$

$$C_\text{th} \, [\text{mAh/g}] = \frac{nF}{3.6 M} \quad \text{(theoretical specific capacity)}$$

$$\Delta G = -nFE \quad \text{(Gibbs–voltage relationship)}$$

$$\left(\frac{\partial E}{\partial T}\right)_P = \frac{\Delta S}{nF} \quad \text{(temperature coefficient)}$$

**Key vocabulary (in order of appearance):**

Galvanic cell, electrolytic cell, redox reaction, oxidation, reduction, half-reaction, oxidising agent, reducing agent, anode, cathode, electrolyte, separator, current collector, standard hydrogen electrode (SHE), standard electrode potential, electrochemical series, reaction quotient, Nernst equation, Nernst slope, chemical potential, activity, activity coefficient, Langmuir isotherm, Faraday's constant, theoretical specific capacity, Gibbs free energy, entropic coefficient, electrochemical potential.

---

## Deliverable

**Task:** Write out the half-reactions for a Li-ion cell (graphite/LCO) and a Na-ion cell (hard carbon/layered oxide). Calculate theoretical cell voltage from standard potentials.

**Guidance:** Start by writing the reduction half-reaction for each electrode, on the Li/Li⁺ scale for LIB and the Na/Na⁺ scale for SIB. Typical values from the literature:

- LCO cathode: $E \approx +3.9$ V vs. Li/Li⁺ at $x \approx 0.5$ (half-discharged). The LCO potential is state-of-charge dependent and spans roughly 3.7–4.2 V vs. Li/Li⁺ over the usable window.
- Graphite anode: $E \approx +0.1$ V vs. Li/Li⁺ averaged over the discharge range, with staging plateaus distributed between about 0.05 V and 0.25 V.

**Partial solution for the Li-ion cell:**

Cathode half-reaction (reduction, during discharge):

$$\text{Li}_{0.5}\text{CoO}_2 + 0.5\text{Li}^+ + 0.5e^- \rightarrow \text{LiCoO}_2 \quad E \approx +3.9 \text{ V vs. Li/Li}^+$$

Anode half-reaction (oxidation, during discharge — written here as reduction for the table, then reversed):

$$\text{LiC}_6 \rightarrow \text{C}_6 + \text{Li}^+ + e^- \quad (E_\text{reduction} \approx +0.1 \text{ V vs. Li/Li}^+)$$

Cell voltage:

$$E_\text{cell} = E_\text{cathode} - E_\text{anode} = 3.9 - 0.1 = 3.8 \text{ V (nominal)}$$

**For the Na-ion cell**, do the analogous calculation using:

- Layered oxide cathode (e.g., NaCoO₂, P2-type structure): $E \approx +3.2$ to $3.7$ V vs. Na/Na⁺
- Hard carbon anode: average potential $\approx +0.2$ V vs. Na/Na⁺ (weighted average of slope and plateau regions)

Write the half-reactions explicitly, noting which species are being oxidised and reduced, and calculate $E_\text{cell}$. Then use the standard electrode potentials vs. SHE (Li/Li⁺ at $-3.04$ V vs. SHE; Na/Na⁺ at $-2.71$ V vs. SHE) to convert your answers to the SHE scale and verify they are internally consistent.

---

## Further Reading

1. **Atkins, P. W. and de Paula, J., *Physical Chemistry*, Oxford University Press (any recent edition), Chapter on Electrochemistry.** The foundational treatment of activity, chemical potential, and the Nernst equation for physical chemists. Mathematically rigorous without being inaccessible. Read this to solidify the thermodynamic underpinning of everything in this chapter.

2. **Huggins, R. A., *Advanced Batteries: Materials Science Aspects*, Springer (2009), Chapters 1–3.** Written by one of the field's great experimentalists, this book covers electrode thermodynamics and the Gibbs free energy–voltage relationship from a material scientist's perspective. The discussion of activity in electrode hosts (Chapter 3) is the best concise treatment available for the level we need.

3. **Newman, J. and Thomas-Alyea, K. E., *Electrochemical Systems*, Wiley (3rd edition, 2004), Chapters 1–3.** The canonical rigorous graduate text for electrochemical engineering. Demanding — the notation is dense — but sections 2.1–2.4 on the electrochemical potential and the Nernst equation are the authoritative engineering treatment. Pick this up when you want to go deeper into thermodynamic foundations.

4. **Bard, A. J. and Faulkner, L. R., *Electrochemical Methods: Fundamentals and Applications*, Wiley (2nd edition, 2001), Chapter 2.** The definitive reference for electrochemical methods and kinetics. Chapter 2 covers thermodynamics and potential, and is essential background for the Butler-Volmer material we will reach in Chapter 2 of this book.

5. **Reddy, T. B. (ed.), *Linden's Handbook of Batteries*, McGraw-Hill (4th edition, 2011), Chapter 1.** A broad engineering reference with excellent summaries of electrochemical fundamentals from a practical standpoint. Useful for seeing how the chemistry in this chapter connects to real cell specifications.

---

*Next chapter: **Chapter 2 — How a Battery Works in Operation.** We descend from thermodynamics into kinetics and transport: intercalation, the SEI, the electric double layer, Butler-Volmer kinetics, and diffusion. Prompt me with "write Chapter 2" to continue.*

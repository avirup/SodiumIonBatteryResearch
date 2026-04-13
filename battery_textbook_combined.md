# Chapter 1: Electrochemistry for Engineers

## Chapter 1 Opening

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

$$\mu = \mu^\circ + RT \ln c \tag{1.7}$$

where $c$ is molar concentration and $\mu^\circ$ is a standard chemical potential (the value $\mu$ takes when $c$ equals a reference concentration, conventionally 1 mol/L). The logarithmic form is not a choice — it falls out of statistical mechanics when you count the number of microstates accessible to non-interacting particles at concentration $c$, and the entropy contribution $-TS$ becomes $-RT\ln c$ per mole. This is where the $\ln Q$ term in the Nernst equation ultimately comes from: the Nernst log is a chemical-potential log in disguise.

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

The overall cell reaction for LiCoO₂/graphite is approximately:

$$\text{LiCoO}_2 + \text{C}_6 \rightarrow \text{Li}_{1-x}\text{CoO}_2 + \text{Li}_x\text{C}_6$$

Let us compute for the standard discharge of the full cell. Using $E_\text{cell} \approx 3.8$ V and $n = 1$ (per Li):

$$\Delta G = -nFE = -(1)(96{,}485 \text{ C/mol})(3.8 \text{ V}) = -366{,}643 \text{ J/mol} \approx -367 \text{ kJ/mol}$$

This is the maximum electrical energy available per mole of lithium transferred. To express this per kilogram of LiCoO₂:

$$\text{Energy density} = \frac{367{,}000 \text{ J/mol}}{97.87 \text{ g/mol}} = 3{,}749 \text{ J/g} = 3{,}749{,}000 \text{ J/kg}$$

Converting to Wh/kg: $3{,}749{,}000 / 3600 \approx 1{,}041$ Wh/kg.

This is the **theoretical gravimetric energy density based on the cathode mass alone**. In a real cell, the full cell mass includes the anode, electrolyte, separator, current collectors, and packaging, which together reduce the practical energy density to 150–250 Wh/kg for a complete 18650 cell. The gap between theoretical and practical energy density is one of the central engineering challenges in battery cell design, and understanding it requires everything in Parts III through VI of this book.

---

## Chapter 1 Worked Interpretation Exercise: Reading a Half-Reaction Table

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

## Chapter 1: What Changes for Sodium-Ion?

Most of what we covered in this chapter applies to sodium-ion batteries without modification. The Nernst equation, Faraday's laws, Gibbs free energy, and half-reaction notation are universal — they were derived from thermodynamics, not from any specific chemistry. What changes between Li-ion and SIB is the *numerical content*: specific potentials, specific ionic sizes, specific host materials. Those numerical differences will turn out to have consequences that reach all the way up into BMS algorithms, but at this stage of the book the preview is deliberately brief. Here are the two most important differences to plant in your head now.

The most important difference is the **standard electrode potential of sodium versus lithium**. The Na/Na⁺ couple sits at $-2.71$ V vs. SHE, compared to $-3.04$ V for Li/Li⁺. This 0.33 V difference in anode potential means that, all else being equal, a sodium-ion cell will have about 0.33 V less thermodynamic voltage than a comparable lithium-ion cell — and since energy density scales with voltage, this is a fundamental (though not fatal) energy density disadvantage.

The second difference is the ionic radius: Na⁺ is 1.02 Å, compared to 0.76 Å for Li⁺. For reasons that are partly size-related and partly thermodynamic (the formation energy of Na-graphite intercalation compounds is unfavourable in carbonate electrolytes), bare Na⁺ does not intercalate into graphite to useful capacity at room temperature in conventional electrolytes. This is why hard carbon, with its disordered, defect-rich, and pore-containing microstructure, is the dominant SIB anode material. (There is a small research literature on *solvent co-intercalation* into graphite using ether electrolytes, which does give usable capacity, but this is not the commercial route.) The Na⁺/Li⁺ size difference also affects which cathode crystal structures can host the ion and how the Nernst-equation activity varies with insertion fraction — layered oxides, for instance, adopt different stackings (O3, P2) depending on the Na content, because the larger ion prefers different coordination environments than Li⁺ does.

We will revisit these consequences in detail in Chapter 6 and Chapter 13.

---

## Chapter 1 Summary

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

## Chapter 1 Deliverable

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

## Chapter 1 Further Reading

1. **Atkins, P. W. and de Paula, J., *Physical Chemistry*, Oxford University Press (any recent edition), Chapter on Electrochemistry.** The foundational treatment of activity, chemical potential, and the Nernst equation for physical chemists. Mathematically rigorous without being inaccessible. Read this to solidify the thermodynamic underpinning of everything in this chapter.

2. **Huggins, R. A., *Advanced Batteries: Materials Science Aspects*, Springer (2009), Chapters 1–3.** Written by one of the field's great experimentalists, this book covers electrode thermodynamics and the Gibbs free energy–voltage relationship from a material scientist's perspective. The discussion of activity in electrode hosts (Chapter 3) is the best concise treatment available for the level we need.

3. **Newman, J. and Thomas-Alyea, K. E., *Electrochemical Systems*, Wiley (3rd edition, 2004), Chapters 1–3.** The canonical rigorous graduate text for electrochemical engineering. Demanding — the notation is dense — but sections 2.1–2.4 on the electrochemical potential and the Nernst equation are the authoritative engineering treatment. Pick this up when you want to go deeper into thermodynamic foundations.

4. **Bard, A. J. and Faulkner, L. R., *Electrochemical Methods: Fundamentals and Applications*, Wiley (2nd edition, 2001), Chapter 2.** The definitive reference for electrochemical methods and kinetics. Chapter 2 covers thermodynamics and potential, and is essential background for the Butler-Volmer material we will reach in Chapter 2 of this book.

5. **Reddy, T. B. (ed.), *Linden's Handbook of Batteries*, McGraw-Hill (4th edition, 2011), Chapter 1.** A broad engineering reference with excellent summaries of electrochemical fundamentals from a practical standpoint. Useful for seeing how the chemistry in this chapter connects to real cell specifications.

---

*Next chapter: **Chapter 2 — How a Battery Works in Operation.** We descend from thermodynamics into kinetics and transport: intercalation, the SEI, the electric double layer, Butler-Volmer kinetics, and diffusion.*
```{=latex}
\clearpage
```

<!-- markdownlint-disable-next-line MD025 -->
# Chapter 2: How a Battery Works in Operation

## Chapter 2 Opening

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

This is why the capacity measured in the first discharge of a freshly assembled lithium-ion cell is always higher than the capacity measured in the first charge: some of the lithium that left the cathode and arrived at the anode was consumed by SEI formation rather than being stored reversibly in the graphite. The ratio of charge extracted in the first discharge to the charge put in during the first charge is called the **first-cycle Coulombic efficiency** (or **initial Coulombic efficiency**, ICE), and it is typically 85–95% for graphite anodes. The 5–15% deficit represents lithium permanently consumed by SEI formation.

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

## Chapter 2 Worked Interpretation Exercise: The Voltage Relaxation Experiment

Here is a real experimental observation from a standard battery characterisation test, and we will use the physical concepts from this chapter to interpret it completely.

**The experiment:** A fully charged 18650 NMC/graphite cell (rated 3.0 Ah, nominal voltage 3.6 V, Panasonic NCR18650B) is discharged at a constant 3.0 A (1C) for 600 seconds. Current is then switched off. The following voltage profile is observed:

- Before current starts: $V = 4.16$ V (resting OCV, fully charged)
- Immediately when 3A current starts: voltage drops to 3.97 V (a 190 mV instant drop)
- Voltage continues falling during the 600 s discharge, reaching 3.61 V when current is switched off
- Immediately after current is switched off: voltage jumps from 3.61 V to 3.73 V (a 120 mV instant recovery)
- Over the next 120 seconds, voltage rises slowly from 3.73 V to 3.84 V
- After 600 s of rest, voltage has reached 3.88 V (approximate new OCV)

Let us interpret each feature using the physics from this chapter.

**The 190 mV instant drop at current onset** is the **ohmic overpotential** $\eta_\Omega = IR_\Omega$. With $I = 3$ A and $\eta_\Omega = 0.190$ V, the ohmic resistance is $R_\Omega = 0.190/3 = 63$ mΩ. This ohmic resistance includes the electrolyte ionic resistance, the electronic resistances of the electrodes and current collectors, and the contact resistances — all the truly resistive elements that respond instantaneously.

**The gradual voltage decline during discharge** is the build-up of activation overpotential ($\eta_\text{act}$, which rises as the electrode surfaces become more chemically perturbed) and concentration overpotential ($\eta_\text{conc}$, which grows as concentration gradients develop across the electrodes and separator). The Nernst-equation change (OCV decreasing as SOC decreases) is also included in this gradual decline — distinguishing kinetic and thermodynamic contributions requires a separate OCV measurement, which is why GITT (Section 3.10) is needed for clean characterisation.

**The 120 mV instant recovery at current switch-off** is the immediate disappearance of the ohmic overpotential. The current is zero; $\eta_\Omega = IR_\Omega = 0$ instantly. Notice, though, that the instant recovery (120 mV) is smaller than the instant drop (190 mV) at current onset. The ohmic resistance itself has not changed — a 63 mΩ resistance at $t=0$ is still 63 mΩ at $t=600$ s. What has changed is the OCV. During 600 s of 3 A discharge we extracted $Q = 3.0 \text{ A} \times 600 \text{ s} = 1800 \text{ C}$ of charge, which is $1800/3600 = 0.5$ Ah out of a 3.0 Ah cell — roughly 17% of the cell's capacity, or a ΔSOC of about 0.17. For an NMC cell in the high-SOC region, the OCV slope is roughly 400 mV per full SOC swing, so a 0.17 ΔSOC corresponds to an OCV drop of about $0.17 \times 0.4 \approx 70$ mV. That 70 mV is exactly the difference between the 190 mV instant drop at current onset and the 120 mV instant recovery at current switch-off. The arithmetic reconciles to within the rounding of our reading precision, and we have extracted two separate quantities — $R_\Omega$ and $dV_\text{OCV}/d\text{SOC}$ — from what looked like a single voltage trace.

**The slow 110 mV recovery over 600 s** is the relaxation of the activation and concentration overpotentials. The fast component (milliseconds to seconds, barely visible in this data) is the RC discharge of the double-layer capacitance — the activation overpotential decays as the electrode surfaces return to equilibrium. The slow component (seconds to minutes) is the diffusion of lithium ions re-equilibrating their concentration gradients across the electrodes and separator. The fact that this takes several minutes confirms our earlier estimate that diffusion across a 100 µm electrode layer (with the Bruggeman correction) takes on the order of a few hundred to a thousand seconds.

**The new OCV at 3.88 V rather than 4.16 V** simply reflects that the cell has been partially discharged. The OCV is lower because the cathode has been lithiated further (lower potential) and the anode has been delithiated (higher potential, but less — the voltage is dominated by the cathode in an NMC cell at high SOC).

By interpreting a single voltage relaxation trace, we have identified the ohmic resistance (63 mΩ), confirmed the presence of activation and diffusion overpotentials, observed their different time constants, and read off the OCV change due to discharge. This kind of physical interpretation is what battery engineers do every day, and it relies entirely on the framework developed in this chapter.

---

## Chapter 2: What Changes for Sodium-Ion?

The physics of this chapter — intercalation, SEI, double-layer capacitance, Butler-Volmer, diffusion — all apply equally to sodium-ion batteries. But several parameters take different values, and a few mechanisms are qualitatively different.

**Intercalation hosts change significantly.** As we saw in Section 2.1, graphite does not work as an anode for sodium. The Na⁺ ion is 34% larger than Li⁺, and the stage-1 graphite intercalation compound (LiC₆) has no stable sodium analogue at room temperature and ambient pressure. Hard carbon — disordered, non-graphitic carbon with nanopore spaces and turbostratic layer spacing — is the SIB anode of choice. Its intercalation mechanism involves two distinct processes (the slope region and the plateau region), and the voltage profile looks fundamentally different from graphite.

**The SEI chemistry differs.** The SEI on hard carbon in sodium-ion electrolytes (NaPF₆ or NaClO₄ in EC:DMC or ether-based solvents) has a different composition from the lithium analogue. NaF and sodium carbonates dominate in some electrolytes; ether-based electrolytes form thinner, more stable SEIs. The initial Coulombic efficiency of hard carbon (typically 75–85%) is notably lower than graphite (85–95%), partly because hard carbon's larger surface area (typically 5–15 m²/g versus 1–5 m²/g for graphite) provides more surface area for SEI formation.

**Solid-state diffusion coefficients are generally lower.** Na⁺ has a lower solid-state diffusion coefficient than Li⁺ in most cathode materials, and the reason is straightforward: Na⁺ is larger, and it must squeeze through the same narrow migration bottlenecks in the host lattice that Li⁺ slips through comfortably. In polyanionic frameworks with tight channels, the penalty can be one to two orders of magnitude. In more open layered oxides — especially P2-type Na cathodes with their prismatic coordination — the Na⁺ diffusivity can be comparable to Li⁺ in layered Li oxides. The effect is not universal but it is the way to bet.

**Exchange current densities differ, but not in the direction you might guess.** Naively, the smaller Li⁺ should desolvate faster at the electrode surface and therefore give a larger $i_0$. The trend is actually the opposite: Li⁺ has a much higher charge density than Na⁺ (ionic radii ≈ 0.76 Å vs. 1.02 Å), binds carbonate solvent molecules more tightly, and so carries a larger desolvation penalty at the interface. This is one reason sodium-ion cells often retain more of their room-temperature power at sub-zero temperatures than lithium-ion cells — the Arrhenius factor still bites, but the activation barrier it multiplies is smaller. Whether the net exchange current density is higher or lower than for a comparable Li system depends strongly on the cathode material, the electrolyte, and the interphase chemistry; the literature is genuinely mixed. The important takeaway is not the sign of the comparison but that any Li-ion intuition you carry about charge-transfer kinetics needs to be re-derived for Na systems, not copied across.

We will return to all of these differences systematically in Chapters 6 and 13. The key point for now is: the framework established in this chapter is universal, but the specific numbers and some qualitative features differ, and those differences matter for modelling, BMS design, and degradation.

---

## Chapter 2 Summary

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

## Chapter 2 Deliverable

**Task:** Draw a labeled diagram of a Li-ion cell during discharge showing ion flow, electron flow, and where each loss mechanism occurs.

**Guidance:** Your diagram should show, at minimum: the copper current collector, the graphite anode (with SEI layer on its surface), the separator (porous polymer), the LCO cathode, the aluminum current collector, the external circuit (with a load), and the electrolyte filling the pores and separator. Arrows should indicate:

1. Direction of electron flow in the external circuit (from graphite to LCO — conventional current flows the opposite way)
2. Direction of Li⁺ flow in the electrolyte (from graphite, through separator, to LCO)
3. Location of ohmic drop (across the electrolyte and electrode matrices)
4. Location of activation overpotential (at the electrode–electrolyte interface, both sides)
5. Location of concentration overpotential (within the electrode pore electrolyte and at electrode surfaces)
6. Location of SEI (thin film on graphite surface and, to a lesser extent, on LCO surface)

---

## Chapter 2 Further Reading

1. **Huggins, R. A., *Advanced Batteries: Materials Science Aspects*, Springer (2009), Chapters 3–4.** Huggins is exceptional on the physical meaning of intercalation, the thermodynamics of solid-solution reactions versus two-phase reactions, and the connection between crystal structure and voltage profile shape. Chapters 3–4 are the direct complement to Sections 2.1 and 2.2 of this chapter.

2. **Newman, J. and Thomas-Alyea, K. E., *Electrochemical Systems*, Wiley (3rd edition, 2004), Chapters 4–9.** The authoritative treatment of mass transport (Chapter 4), electrode kinetics (Chapter 8), and porous electrode theory (Chapter 22). Dense but precise. Return to this when you want to go beyond intuition into rigorous modelling.

3. **Peled, E. and Menkin, S., "Review — SEI: Past, Present and Future," *Journal of the Electrochemical Society* 164 (7), A1703–A1719 (2017).** One of the most comprehensive reviews of SEI by one of the field's pioneers. Covers formation mechanisms, composition, and the role of SEI in ageing. Essential background for Chapter 7.

4. **Bard, A. J. and Faulkner, L. R., *Electrochemical Methods: Fundamentals and Applications*, Wiley (2nd edition, 2001), Chapter 3.** The canonical derivation and discussion of the Butler-Volmer equation, Tafel behaviour, and exchange current density. The treatment of the electrical double layer in Chapter 13 is also excellent.

5. **Doyle, M., Fuller, T. F., and Newman, J., "Modeling of Galvanostatic Charge and Discharge of the Lithium/Polymer/Insertion Cell," *Journal of the Electrochemical Society* 140 (6), 1526–1533 (1993).** The paper that established the Doyle-Fuller-Newman (DFN) model — the foundational physics-based model that formalises everything in this chapter into a complete set of coupled PDEs. Reading this after Chapter 2 gives you the jump from physical intuition to mathematical model.

---

*Next chapter: **Chapter 3 — Performance Metrics and Terminology.** We ascend from physics back toward engineering: capacity, C-rate, internal resistance, OCV curves, Coulombic efficiency, cycle life, and the full suite of characterisation techniques — HPPC, GITT, PITT, EIS — explained from first principles.*

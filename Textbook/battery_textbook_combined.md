---
title: "Battery Technology for Electrical Engineers: A Self-Study Text"
documentclass: book
---

\pagenumbering{gobble}
\newgeometry{margin=0pt}
\thispagestyle{empty}
\noindent
\includegraphics[width=\paperwidth,height=\paperheight]{/home/avirup/SodiumIonBatteryResearch/Textbook/Book_Cover.png}
\clearpage
\restoregeometry

\pagestyle{empty}
\thispagestyle{empty}
\vspace*{\fill}
\noindent\textbf{Copyright \textcopyright{} 2026 Avirup}\
This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0).\
You are free to share and adapt this material for noncommercial purposes, provided you give appropriate attribution and indicate if changes were made.\
License text: \url{https://creativecommons.org/licenses/by-nc/4.0/}\

\vspace{1.5em}
\noindent\textbf{ISBN:} TBD\
\textbf{Library of Congress Control Number:} TBD\

\vspace{1.5em}
\noindent\textbf{Publisher:} Independent publication\
Publisher details to be confirmed.
\vspace*{\fill}
\clearpage

\pagestyle{empty}
\tableofcontents
\clearpage
\pagenumbering{arabic}
\setcounter{page}{1}
\pagestyle{fancy}

# Electrochemistry for Engineers

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

## What Is a Battery? Galvanic vs. Electrolytic Cells

Let us begin with a picture that, once fixed clearly in your mind, will underpin everything in this book.

Imagine two metal bars sitting in a solution of dissolved salt, connected by a wire. One bar is copper; the other is zinc. You have just built one of the oldest electrochemical devices in history — the Daniell cell, invented in 1836. Now here is the remarkable thing: if you simply connect the wire and wait, a current flows through it *spontaneously*, without any external voltage source. The zinc bar slowly dissolves. The copper bar slowly grows. Chemical energy stored in the difference between the chemical properties of zinc and copper is being converted, continuously, into electrical energy in the wire.

That, in its most distilled form, is what a battery is: a device that converts stored chemical potential energy into electrical energy through a controlled chemical reaction. The key word is *controlled* — the reaction does not happen in a violent burst like combustion; it happens at two physically separated surfaces called **electrodes**, and the electrons released at one electrode are forced to travel through an external circuit to reach the other, doing useful work along the way.

The process I just described — spontaneous conversion of chemical energy to electrical energy — is called a **galvanic process** (after Luigi Galvani) or sometimes a **voltaic process** (after Alessandro Volta). A device that harnesses it is a **galvanic cell**. Every battery you have ever used — from the AA alkaline cell in a television remote to the 100 kWh lithium-ion pack underneath a Tesla — is, at its core, a galvanic cell or a collection of galvanic cells.

Now run the process in reverse. Suppose instead of harvesting the current from the Daniell cell, you connect it to an external power supply and force current through it in the opposite direction. The copper dissolves back into solution. Zinc plates out of solution back onto the zinc bar. You are now consuming electrical energy to drive a chemical reaction that would not proceed spontaneously on its own. This is called an **electrolytic process**, and the device is an **electrolytic cell**. Industrial electroplating, the Hall–Héroult process for smelting aluminum, the chlor-alkali process for producing chlorine — all of these are electrolytic.

**Students often confuse galvanic and electrolytic cells** because both involve electrodes, both involve ions in solution, and both involve the flow of current. The distinction is thermodynamic, not structural. In a galvanic cell, the chemical reaction drives the current: the system does work on the external circuit, $\Delta G < 0$, and you extract energy. In an electrolytic cell, the current drives the chemical reaction: the external circuit does work on the system, $\Delta G > 0$ (for the reaction as driven), and you consume energy. The same physical device can often operate in either mode depending on what you connect to it — this is exactly what happens when you *charge* a rechargeable battery. During discharge, it is a galvanic cell. During charge, it is an electrolytic cell. You drive the same electrode reactions in reverse.

This duality — the same device, the same ions, the same electrodes, but radically different direction of energy flow depending on whether you are sourcing or sinking current — is one of the conceptually beautiful things about electrochemistry. It is also practically important: understanding what happens during charge versus discharge at the electrode surfaces is the key to understanding degradation, which we will spend all of Chapter 7 on.

One more vocabulary point before we move on. The word **cell** in electrochemistry refers to a single electrochemical unit — one positive electrode, one negative electrode, one electrolyte. A **battery**, strictly speaking, is a collection of cells wired together, though in casual usage "battery" is used for single cells as well (a "9-volt battery" is actually six 1.5-volt cells in series inside the same case). In this book we will be precise: "cell" means a single electrochemical unit, and "battery" or "pack" means a collection of cells.

---

## Oxidation, Reduction, and Half-Reactions

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

## Anode, Cathode, Electrolyte, Separator, Current Collector — Anatomy of a Cell

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

## Standard Electrode Potentials and the Electrochemical Series

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

## The Nernst Equation and What It Predicts

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

## Activity vs. Concentration — and Why the Distinction Matters Later

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

## Faraday's Laws of Electrolysis — Linking Charge to Mass

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

## Gibbs Free Energy and Cell Voltage

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


\newpage

# How a Battery Works in Operation

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

## Intercalation — the Guest-Host Mechanism

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

## Why Intercalation Hosts Matter: Layered, Spinel, Olivine, and Polyanionic Structures

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

## The Solid-Electrolyte Interphase (SEI): Formation, Function, and Consequences

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

## The Electric Double Layer and Double-Layer Capacitance

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

## Charge Transfer Kinetics at the Electrode–Electrolyte Interface

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

## Mass Transport: Diffusion, Migration, and Convection

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

## Kinetic vs. Transport Limitations — Which Dominates When

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

## Introduction to the Butler-Volmer Equation (Intuition Only)

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
6. Location of SEI (thin film on graphite surface and, to a lesser extent, on LCO surface)

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


\newpage

# Performance Metrics and Terminology

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
>
> - RC circuits and impedance in the complex plane (essential for Section 3.10, EIS)
> - Basic concepts of efficiency and power (Section 3.6)
> - Familiarity with Bode plots and frequency-domain thinking (helpful for Section 3.10)
>
> From Chapter 1:
>
> - Faraday's laws connecting charge to mass (Section 1.7) — needed for Section 3.1
> - The Nernst equation and its connection to OCV (Section 1.5) — needed for Section 3.4
>
> From Chapter 2:
>
> - The three overpotentials (ohmic, activation, concentration) and their time constants (Section 2.7) — needed for Sections 3.5 and 3.10
> - Butler-Volmer equation and exchange current density (Section 2.8) — needed for Section 3.10
> - The SEI and first-cycle irreversibility (Section 2.3) — needed for Section 3.6
>
> If anything from Chapter 2 is unclear, especially the three-overpotential framework, review Section 2.7 before proceeding to Section 3.5.

---

## Capacity (Ah) vs. Energy (Wh): Specific vs. Volumetric

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
| --- | --- | --- | --- |
| LCO (consumer) | 3.7 | 200–260 | 550–700 |
| NMC811 (EV) | 3.7 | 230–280 | 600–750 |
| NCA (EV) | 3.6 | 220–270 | 600–700 |
| LFP (EV/grid) | 3.2 | 150–200 | 350–450 |
| LMO (low-cost) | 3.8 | 100–130 | 250–330 |
| SIB (hard carbon / layered oxide) | 3.1–3.2 | 100–160 | 250–400 |

The SIB numbers are lower than the best lithium-ion chemistries — reflecting the lower cell voltage and lower specific capacity of current SIB electrode materials — but competitive with LFP, particularly in cost. We will revisit these comparisons in detail in Chapters 5 and 6.

A useful calibration for an EE: the best electrolytic capacitors store about 0.05–0.1 Wh/kg, the best supercapacitors about 5–10 Wh/kg, lead-acid batteries about 30–40 Wh/kg, current commercial lithium-ion cells about 200–280 Wh/kg, and gasoline (for context) about 12,000 Wh/kg before accounting for engine efficiency. Lithium-ion sits roughly three orders of magnitude denser than capacitors and one order of magnitude less dense than hydrocarbon fuel — close enough to fuel to displace it in mobility applications, far enough above capacitors to make stationary energy storage practical at grid scale.

---

## C-Rate and What "1C" Actually Means

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

## State of Charge, Depth of Discharge, State of Health

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

## Open-Circuit Voltage vs. Terminal Voltage; Why OCV Curve Shape Matters for BMS

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

## Internal Resistance and the Three Polarizations

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

## Coulombic, Voltage, and Energy Efficiency

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

## Cycle Life vs. Calendar Life; What Counts as "A Cycle"

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
| --- | --- | --- |
| Driver | Charge throughput (cycles, DOD, C-rate) | Time spent at a given (T, SOC) |
| Dominant mechanism (LIB) | SEI growth at exposed anode surfaces, particle cracking, lithium plating | SEI growth at the equilibrium anode potential, cathode electrolyte oxidation |
| Strongest stressor | High DOD, high C-rate, voltage extremes | High temperature, high SOC |
| Temperature dependence | Mixed (high T accelerates side reactions, low T accelerates plating) | Arrhenius — roughly doubles per +10°C |
| Mitigation | Limit DOD, moderate C-rate, narrow voltage window | Store cool and at moderate SOC (~30–50%) |
| Modelling approach | Cycle-based or throughput-based fade laws; rainflow counting | Time × Arrhenius × SOC-dependent rate law |

Real cells experience both simultaneously, and a complete fade model superposes the two contributions. We will build such a model in Chapter 7.

---

## Self-Discharge

**Self-discharge** is the spontaneous loss of stored charge over time when a cell is open-circuit (not connected to any load or charger). It is distinct from calendar aging: self-discharge refers to the loss of charge (SOC decreases over days or weeks), while calendar aging refers to capacity fade and resistance rise over months or years. A cell can self-discharge significantly over a month without meaningfully degrading in calendar aging terms, and vice versa.

Self-discharge has several distinct physical origins, and a real cell typically exhibits all of them simultaneously to varying degrees. The dominant mechanism for a healthy lithium-ion cell at room temperature is slow electrochemical side reaction at the anode, but in degraded cells, in cells with manufacturing defects, or in chemistries with shuttle-active impurities, other mechanisms can take over.

**Electrochemical side reactions at low rate**: The same reactions that form the SEI during cycling continue very slowly at rest. This consumes a tiny current continuously, slowly depleting the stored charge. For a well-formed SEI, this rate is very small.

**Electronic leakage through the separator**: If the separator is imperfect — has a micro-short or contamination — electrons can cross from anode to cathode directly, mimicking a small load and discharging the cell. Even a 1 MΩ "leakage resistance" across a 3.7 V cell corresponds to a continuous discharge current of 3.7 µA, which over a month (2.6 × 10⁶ s) amounts to 9.6 C or about 2.7 mAh — negligible for a 3 Ah cell, but an important specification for long-life applications.

**Electrolyte redox shuttle**: In some chemistries, a dissolved species (often an impurity or a deliberately added molecule) can be electrochemically oxidised at the positive electrode and reduced at the negative electrode in a continuous cycle, shuttling charge from cathode to anode and discharging the cell. This is a problem in overcharged cells and is intentionally exploited in some chemistries as an overcharge protection mechanism.

Self-discharge rates for lithium-ion cells are typically 1–5% per month at room temperature, increasing with temperature. This is much lower than for older technologies (NiMH: 20–30% per month; lead-acid: 5–15% per month) and is one of the reasons lithium-ion has won the portable electronics market.

---

## CC-CV Charging Protocol

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

## Characterisation Tests: HPPC, GITT, PITT, EIS

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


\newpage

# Cell Construction

## Chapter Opening

So far in this book we have inhabited a somewhat abstract world. We have talked about electrodes, electrolytes, and separators as if they were ideal geometric planes of material sitting in a beaker. The physics and chemistry we have built up — intercalation, Butler-Volmer kinetics, Fick's diffusion, the SEI — is real and accurate, but it has existed, up to this point, largely without context. A real battery is not a beaker. It is a precisely engineered product that must pack as much energy as possible into as little space and mass as possible, survive thousands of charge-discharge cycles without mechanical failure, resist thermal runaway under abuse, and be manufactured at a cost measured in tens of dollars per kilowatt-hour rather than thousands.

This chapter is about the gap between the physics and the product. It is about how the material — the active powder with its beautiful crystal structure and its carefully optimised electrochemistry — becomes the cell sitting on a laboratory bench or inside a car. That journey involves slurries and ovens and precision rollers and hermetic seals and electrolyte fill lines, and every step of it has electrochemical consequences. The way an electrode is calendered affects its porosity and therefore its rate capability. The way a cell is sealed determines whether its electrolyte will last five years or fifteen. The first cycles a cell undergoes after assembly are not accidental — they are a deliberate manufacturing step called formation, and without them the cell would die in weeks.

Understanding cell construction is also practically important for anyone doing simulation research. When you build a physics-based model of a sodium-ion cell, you need geometric parameters: electrode thickness, particle size, porosity, tortuosity, electrolyte volume fraction. All of these are consequences of manufacturing choices — calendering pressure, slurry formulation, coating weight. The better you understand how those choices are made and what they mean physically, the better you can interpret the parameters you feed into your model and assess whether they are physically reasonable.

By the end of this chapter, you will be able to look at any commercial cell — cylindrical, prismatic, or pouch — and understand why it is built the way it is, what geometric and manufacturing trade-offs were made in its design, and how those trade-offs show up in the performance and degradation behaviour you will model and measure.

---

> **Prerequisites Check**
>
> From your EE background:
>
> - Basic mechanical and thermal intuitions (stress, strain, heat conduction) — helpful for understanding calendering and thermal management
> - Familiarity with manufacturing tolerance concepts — relevant to electrode coating uniformity
>
> From Chapters 1–3:
>
> - The SEI and its formation during the first cycles (Chapter 2, Section 2.3) — essential for Section 4.3
> - Current collector material choices (Chapter 1, Section 1.3) — this chapter expands on those reasons
> - The three overpotential types (Chapter 2, Section 2.7) — needed to understand why porosity and tortuosity matter
> - Coulombic efficiency and first-cycle irreversibility (Chapter 3, Section 3.6) — directly relevant to Section 4.3

---

## Form Factors: Cylindrical, Pouch, and Prismatic

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
| --- | --- | --- | --- |
| Gravimetric energy density | Moderate (can weight) | Moderate | High (light packaging) |
| Volumetric packing efficiency | ~60–74% (round packing) | ~85–95% | ~85–95% |
| Mechanical robustness | High (steel can) | Moderate | Low (no rigid case) |
| Thermal management | Moderate (radial path) | Good (flat faces) | Good (flat faces) |
| Manufacturing maturity | Highest | High | Moderate |
| Gas management | Built-in vent | Built-in vent | Requires degassing step |
| Dominant application | Consumer, some EV | EV, stationary | Consumer, some EV |

For sodium-ion cells, all three form factors are in commercial use. CATL's first-generation SIB cells were released in cylindrical (26700-class) format, with prismatic cells targeted at automotive packs. HiNa has shipped both cylindrical (26700-class) and prismatic cells across its product line. Faradion (now part of Reliance Industries) is best known for pouch-cell demonstrations — including their reference 12 Ah hard-carbon / layered-oxide pouch cell — though they have also produced cylindrical samples. Several Chinese producers are moving toward prismatic and blade formats for automotive-scale production. The takeaway is that the SIB industry has not yet converged on a dominant form factor the way LIB-for-EV has converged on prismatic and large-format cylindrical; a sodium cell can show up in any of the three packages, and you should expect to encounter all three in the literature.

---

## Electrode Manufacturing: Slurry, Coating, Calendering, Slitting

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

## Formation Cycling and Why First Cycles Differ

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

## Current Collectors: Copper, Aluminium, and Why SIB Can Use Aluminium on Both Sides

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
| --- | --- | --- |
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


\newpage

# Lithium-Ion Chemistry Families

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

## The Five-Dimensional Trade-Off Space

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

## LCO: Lithium Cobalt Oxide — The Original Chemistry

### History and Structure

**Lithium cobalt oxide (LCO)**, chemical formula LiCoO₂, is where the modern lithium-ion battery story begins. John Goodenough's group at Oxford demonstrated its use as a lithium-ion cathode in 1980; Rachid Yazami and Philippe Touzain showed that graphite could reversibly intercalate lithium in 1980–1983; and Akira Yoshino at Asahi Kasei assembled the first practical lithium-ion cell (petroleum-coke anode / LCO cathode) in 1985. Graphite did not replace coke as the standard anode until the early 1990s, once ethylene carbonate electrolytes were introduced that allowed a stable SEI to form on graphite without exfoliating it — a detail we will revisit when we discuss electrolyte selection. Sony commercialised this chemistry in 1991, and it powered virtually every portable electronic device for the following two decades. Goodenough, Whittingham, and Yoshino shared the Nobel Prize in Chemistry in 2019 for this work.

LCO has the **layered O3 crystal structure** (α-NaFeO₂ structure type) described in Chapter 2: alternating layers of CoO₂ sheets and Li layers stacked in a rhombohedral unit cell (space group $R\bar{3}m$). The cobalt is in octahedral coordination, as is the lithium. The lithium occupies the interstitial space between the CoO₂ layers and diffuses freely *within* those layers but not *across* them — what physicists call two-dimensional (or "quasi-2D") diffusion.

Here is the intuition. Imagine Li ions as charges hopping between sites on a grid. In LCO, the grid is flat: a Li ion can hop north, south, east, or west within its layer with roughly equal ease, but cannot hop "up" or "down" to the next layer because the CoO₂ sheets in between form a kinetic wall. So transport is effectively 2D. In LFP, which we will meet next, the geometry is opposite — transport is effectively 1D, confined to parallel tunnels through the olivine lattice. And in spinel LMO and LTO, transport is 3D, with the ion free to hop in any direction. The dimensionality of the diffusion pathway matters enormously for rate capability: 3D > 2D > 1D in general, because 3D geometries have more parallel paths for current to take and are more tolerant of blockages. Think of it as the difference between a city with a full grid of streets (3D spinel), a city with avenues only (2D layered, limited turns), and a city with a single one-way expressway you cannot exit (1D olivine). An accident on the expressway is catastrophic; the grid routes around it trivially.

### Electrochemistry

The half-reaction at the LCO cathode during discharge is:

$$\text{Li}_{1-x}\text{CoO}_2 + x\,\text{Li}^+ + x\,e^- \longrightarrow \text{LiCoO}_2 \tag{5.1}$$

where the potential ranges from approximately 3.7 V (near full lithiation, $x \to 0$) to 4.2 V (at the practical delithiation cutoff of $x \approx 0.5$), both measured vs. Li/Li⁺.

The theoretical specific capacity follows from Faraday's first law:

$$C_\text{th} = \frac{nF}{3.6\,M}, \tag{5.A}$$

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

## LFP: Lithium Iron Phosphate — The Safe Workhorse

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

The theoretical specific capacity of LFP follows from equation (5.A) with $n = 1$ and $M_\text{LFP} = 157.76$ g/mol: $C_\text{th} = 96485/(3.6 \times 157.76) = 169.9$ mAh/g. The practical capacity is close to this theoretical value — approximately **155–170 mAh/g** — because LFP can be nearly fully cycled without structural degradation, unlike LCO which can only use half its theoretical range.

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

## NMC: The Dominant EV Chemistry

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

## NCA: The High-Energy Variant

**NCA** — **lithium nickel cobalt aluminium oxide**, formula Li(Ni$_x$Co$_y$Al$_z$)O₂, typically Li(Ni$_{0.8}$Co$_{0.15}$Al$_{0.05}$)O₂ — has its origins in work on Ni-rich layered oxides in Japan in the 1990s (notably Ohzuku and Makimura on related LiNiO₂ derivatives) and was commercialised by SAFT and then by Panasonic/Matsushita. It is most visible today in the Panasonic 18650 and 2170 cells used in Tesla vehicles from 2012 onward.

The crystal structure is identical to LCO and NMC: layered O3, $R\bar{3}m$ space group. The role of aluminium in NCA is analogous to the role of manganese in NMC: it stabilises the structure and improves thermal characteristics without contributing significantly to capacity (Al³⁺ is electrochemically inactive in this voltage window).

The question a non-chemist will want to ask at this point is: if aluminium doesn't participate in the redox reaction, what is it actually *doing*? The answer is structural. Delithiated Ni-rich layered oxides have a tendency to release oxygen because the Ni⁴⁺–O bond becomes weakly destabilised at high delithiation and the oxygen sublattice can collapse into a rock-salt arrangement (the surface reconstruction we discussed above). Embedding electrochemically inactive Al³⁺ into the transition-metal layer pins the lattice: Al–O bonds are stronger and more covalent than Ni–O bonds, so the inactive Al sites act as rebar in the concrete, holding the layered structure together even when the Ni around them is being oxidised and reduced. You pay for this stability with a small capacity reduction (the Al sites cannot store charge) but gain thermal runaway onset temperatures 20–40°C higher than the un-substituted material. Mn⁴⁺ in NMC plays the same structural-rebar role, though through a slightly different mechanism.

NCA has a practical specific capacity of **190–220 mAh/g**, very close to NMC811, and a nominal voltage of ~3.6 V. At the cell level, the Panasonic 21700 NCA cell achieves about 260–300 Wh/kg — among the highest for commercial cells. The synthesis of NCA is demanding: the material is moisture-sensitive (Al is reactive), requires inert-atmosphere handling, and the Ni-rich composition faces all the same cation mixing and surface reconstruction issues as high-nickel NMC. NCA is perhaps even more mature as a commercial chemistry than NMC811 (Panasonic has made NCA cells for Tesla since 2012), and the two are genuine competitors for the high-energy-density automotive application.

A notable difference from NMC: NCA does not contain manganese, which eliminates one degradation mechanism — manganese dissolution and cross-contamination — but also removes one of NMC's structural stabilisers.

Application: **high-energy-density EVs and premium consumer electronics.** NCA is less widespread than NMC811 simply because its synthesis requirements are more demanding and fewer manufacturers have mastered it. Outside of Tesla's supply chain (Panasonic, later CATL), NCA cells are less commonly encountered.

---

## LMO: Lithium Manganese Oxide — The Spinel

**LMO** — **lithium manganese oxide**, formula LiMn₂O₄ — was one of the earliest alternative cathode materials explored for lithium-ion batteries. Unlike LCO, NMC, and NCA with their layered structures, LMO has the **spinel** crystal structure: manganese ions occupy octahedral 16d sites in a cubic close-packed oxygen framework, with lithium occupying tetrahedral 8a sites. The 8a tetrahedral sites are connected through vacant 16c octahedral sites to form a three-dimensional network of equivalent diffusion pathways — in effect, a full grid in all three spatial directions, to return to the street-network analogy. Compared to LCO's 2D planes and LFP's 1D tunnels, a 3D network has many more parallel paths for lithium to take, and a blockage anywhere can be routed around. This structural choice is why LMO has intrinsically excellent rate capability (it can deliver and accept very high currents) and why it is immune to the anti-site-defect sensitivity that plagues LFP: no single defect can isolate a region of the crystal.

The theoretical specific capacity follows from equation (5.A) with $n = 1$ and $M_\text{LMO} = 180.81$ g/mol: $C_\text{th} = 96485/(3.6 \times 180.81) = 148.3$ mAh/g. Practical specific capacity is lower at **100–120 mAh/g**, reflecting the difficulty of fully cycling LMO without structural degradation. The nominal voltage is approximately 4.0 V vs. Li/Li⁺ — higher than LCO's 3.7 V, which is thermodynamically attractive.

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

## LTO: Lithium Titanate — The Safe, Long-Life Anode

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

## Anode Alternatives: A Brief Survey

We have now covered the major cathode chemistries. The anode side is somewhat simpler: graphite dominates overwhelmingly, with silicon-graphite composites as the primary performance enhancement. LTO has been covered above. Two other anode materials deserve brief mention.

### Hard Carbon for Lithium-Ion

Hard carbon intercalates lithium as well as sodium. In lithium-ion cells, hard carbon offers a specific capacity of approximately 200–300 mAh/g (higher than LTO, lower than graphite) at potentials of 0.1–1.0 V vs. Li/Li⁺. Its disordered structure means it is less prone to graphite's stage-phase-transition-related mechanical stress, potentially giving better rate capability and cycle life.

However, hard carbon's ICE for lithium is typically 80–90% — somewhat lower than graphite — and its lower density compared to graphite means lower volumetric energy density. Hard carbon anodes for LIBs remain a niche application (some sodium-ion researchers argue the distinction between HC-based LIBs and SIBs is primarily a matter of which ion is being intercalated). For the purposes of this book, hard carbon as an anode is primarily a sodium-ion story, which we take up in Chapter 6.

### Lithium Metal

The ultimate anode for lithium-ion batteries is lithium metal itself. Its theoretical specific capacity is $C_\text{th} = F/(3.6 \cdot 6.941) = 3862$ mAh/g, and its potential is, by definition, 0 V vs. Li/Li⁺ — the most negative (most reducing) electrode potential achievable in a lithium cell, and therefore the one that, paired with any given cathode, yields the largest possible cell voltage and the highest energy density. Compared to graphite, lithium metal gives you roughly 10× the specific capacity and eliminates the ~100 mV of graphite overpotential that eats into cell voltage. The energy density ceiling for a lithium metal / NMC811 cell is approximately 500+ Wh/kg — nearly double current state-of-the-art.

The obstacles to lithium metal are the same issues that make LTO's no-plating guarantee so attractive, now in reverse: the SEI on lithium metal is unstable, grows continuously, and never fully passivates. Lithium plating is inhomogeneous, producing **dendrites** — needle-like lithium metal filaments that can pierce the separator and cause internal short circuits, potentially triggering thermal runaway. Coulombic efficiency of lithium metal anodes is typically 95–99.5% per cycle in current solid-state and liquid electrolyte systems — far too low for the 1000+ cycle life automotive applications demand.

Solving the lithium metal anode problem (achieving 99.9%+ CE, suppressing dendrites, maintaining stable SEI over thousands of cycles) is arguably the single most important open problem in battery materials science. Progress is being made via solid electrolytes, artificial SEI coatings, electrolyte additive engineering, and 3D host architectures, but commercial solid-state cells with high-energy lithium metal anodes remain years away from mass deployment as of the mid-2020s.

---

## Which Chemistry Wins in Which Application?

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


\newpage

# Sodium-Ion Chemistry Families

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

## Why Na⁺ Is Harder to Work With Than Li⁺

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

## Cathodes: Layered Oxides — O3 and P2 Types

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

## Cathodes: Polyanionic Frameworks — NVPF, NFPP, and Related

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

## Cathodes: Prussian Blue Analogues (PBAs)

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

## Anodes: Hard Carbon — The Dominant Choice

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

## Anodes: Alternatives to Hard Carbon

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

## Electrolytes for SIBs: Differences from LIBs

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

## Commercial SIB Cells: Who Has Shipped What

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

## A Quantitative Comparison: SIB vs. LIB

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

## Worked Interpretation Exercise: Reading a Hard Carbon Half-Cell OCV Curve

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

## What Changes for Sodium-Ion? (Consolidated Summary)

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


\newpage

# Degradation Mechanisms

## Chapter Opening

Every battery in the world is dying. Slowly, irreversibly, at a rate that depends on temperature, current, voltage, and the choices made by the engineer who designed the system around it — but dying nonetheless. Understanding why is not just an academic exercise. It is the difference between a battery pack that lasts twelve years in an electric vehicle and one that needs replacement after six. It is the difference between a grid storage system that earns a positive return on investment and one that does not. And for a simulation researcher, it is the difference between a model that can predict end-of-life behaviour and one that can only reproduce fresh-cell data.

Degradation is also one of the most scientifically subtle areas in battery research, because the mechanisms that cause a cell to fail are numerous, interrelated, and often self-reinforcing. SEI growth consumes lithium, which reduces capacity; it also adds ionic resistance, which increases heat generation; the heat accelerates further SEI growth. Particle cracking exposes fresh electrode surface, which triggers more SEI formation, which consumes more lithium. Electrolyte decomposition at the cathode produces metal dissolution; the dissolved metal deposits on the anode and destroys the SEI there. These feedback loops mean that degradation in a real cell is rarely the work of a single mechanism operating in isolation — it is a cascade of coupled processes, and untangling them requires both physical understanding and careful experimental technique.

This chapter builds the degradation taxonomy you need to work fluently in the battery research literature. We begin with the three fundamental degradation modes — a high-level classification that organises the diverse phenomena into a coherent framework. We then examine each specific mechanism in physical detail, derive or motivate the quantitative models that describe its rate, and identify the external signatures by which it can be diagnosed from terminal measurements. Throughout, we will lean on the materials vocabulary from Chapters 5 and 6 — the distinction between polycrystalline and single-crystal NMC, the layered-oxide vs polyanionic vs PBA cathode families in SIB, the difference between graphite and hard carbon as intercalation hosts — because degradation mechanisms are not generic. A specific mechanism operates on a specific material, and the materials we met in the chemistry-family chapters are the ones whose degradation we are now explaining. Along the way we will pay particular attention to which mechanisms are unique to or amplified in sodium-ion batteries versus lithium-ion batteries, since that distinction will matter when you build SIB degradation models.

By the end of this chapter, you will be able to read a set of capacity-fade and resistance-rise data from a cycling experiment, form a hypothesis about which mechanisms are operating, and design a diagnostic measurement strategy to test that hypothesis. You will also have the vocabulary to read Birkl et al. (2017) — the primary source for this chapter's deliverable — with full comprehension.

---

> **Prerequisites Check**
>
> From Chapter 2:
>
> - The SEI: formation, composition, and role (Section 2.3) — central to Sections 7.2 and 7.7
> - Butler-Volmer kinetics and overpotential (Sections 2.5, 2.8) — needed for Section 7.3
> - Mass transport and diffusion (Section 2.6) — needed for Section 7.4
>
> From Chapter 3:
>
> - Coulombic efficiency, cycle life, calendar life (Sections 3.6, 3.7) — the measurable signatures of degradation
> - EIS and differential capacity ($dQ/dV$) as diagnostic tools (Section 3.10) — used throughout this chapter
>
> From Chapters 5 and 6:
>
> - Crystal structures of LCO, NMC, LFP, layered oxides, hard carbon (Chapters 5, 6) — needed to understand material-specific failure modes
> - Hard carbon slope/plateau mechanism (Chapter 6, Section 6.5) — needed for SIB-specific degradation
>
> If any of the SEI material from Chapter 2 is fuzzy, review Section 2.3 before reading Section 7.2 — SEI growth is the single most important degradation mechanism in lithium-ion batteries, and you will not make sense of the rest of the chapter without it.

---

## The Three Degradation Modes: A Unifying Framework

The degradation literature contains dozens of named mechanisms. This abundance can be overwhelming. The key to navigating it is a hierarchical classification that separates *how a cell fails* (the mode) from *why it fails* (the mechanism). This framework was systematised by Birkl, Roberts, McTurk, Bruce, and Howey in their landmark 2017 review paper, and it has become the standard language for discussing battery degradation.

At the top level, there are exactly three degradation modes. Every mechanism we will discuss — SEI growth, lithium plating, particle cracking, transition metal dissolution, electrolyte decomposition — feeds into one or more of these three modes.

### Mode 1: Loss of Lithium (or Sodium) Inventory (LLI)

**Loss of lithium inventory (LLI)** refers to a decrease in the total amount of cyclable lithium (or sodium, in SIBs) in the cell. Lithium that has been consumed irreversibly — locked up in the SEI, deposited as metallic lithium that cannot be re-intercalated, converted to an inactive chemical compound — is no longer available to carry charge between the electrodes. Capacity decreases because there is less mobile ion available to fill the electrode's sites.

LLI does not mean the electrode materials have degraded. The active materials may be perfectly intact, with all their lattice sites available. But there are fewer lithium ions to fill them. This is analogous to a bus with 50 seats (the electrode) and a fleet that used to have 50 passengers (lithium inventory) but now has only 40. The bus is fine; there are just fewer passengers.

In a fresh cell, the lithium inventory is set by design. The cathode is the lithium source — on the very first charge, all the cyclable lithium in the cell arrives from the cathode — and the anode is sized slightly larger than the cathode so that even at full charge, the anode is not fully lithiated. This excess is quantified by the **N/P ratio** (negative-to-positive capacity ratio), typically 1.05–1.15 for commercial graphite/NMC cells. The margin exists for a reason we will see in Section 7.3: a fully lithiated graphite particle sits right at 0 V vs. Li/Li⁺, which is also where lithium plating begins. Keeping the anode below full lithiation by design pushes the plating threshold out of reach under normal charging.

In this balanced state, the cathode's delithiated composition at top of charge, the anode's lithiated composition at top of charge, and the cell's nameplate capacity are mutually consistent. As LLI accumulates, the balance is disrupted. Some of the cyclable lithium is now locked up in the SEI or as dead lithium, so on every subsequent charge the cathode gives up less lithium than it originally did. The electrode OCV curves — which are properties of the materials and do not themselves change — now slide past each other on the shared capacity axis because one electrode reaches its endpoint before the other does. The cell cannot reach its original full charge, not because the electrodes are damaged, but because there is not enough mobile lithium left to move both electrodes simultaneously into their endpoint compositions.

LLI is primarily detected through changes in the full cell OCV curve and in the differential capacity ($dQ/dV$) curve. As LLI accumulates, the electrode OCV curves slide relative to each other on the SOC axis — a phenomenon called **electrode slippage** or **lithium inventory drift**. The features in the $dQ/dV$ curve (phase transition peaks, staging peaks) shift in voltage and decrease in area as the electrode pair loses its original alignment.

### Mode 2: Loss of Active Material (LAM)

**Loss of active material (LAM)** refers to a decrease in the electrochemically accessible quantity of electrode material — the amount of electrode that is connected to both the electronic pathway and the ionic pathway. Material that has become electronically isolated (particle cracking that severs the electronic network) or ionically isolated (pore clogging that prevents electrolyte access) is no longer available to store or release charge. Capacity decreases because there are fewer sites available, even if the lithium inventory were sufficient to fill them all.

LAM can affect the positive electrode (LAMpe), the negative electrode (LAMne), or both. The distinction matters for diagnosis: LAMpe and LAMne produce different signatures in the $dQ/dV$ curve because the features from each electrode shift differently.

LAM is distinct from LLI: in LAM, the problem is the host, not the guest. If you imagine the bus again: LAM is equivalent to some of the seats being broken and unusable. The passengers (lithium) are still there, but they cannot sit in those seats.

### Mode 3: Conductivity Loss (CL) / Impedance Growth

**Conductivity loss (CL)** — also called impedance growth or resistance rise — refers to an increase in any of the resistive elements of the cell: the electrolyte ionic resistance, the SEI ionic resistance, the charge-transfer resistance at electrode surfaces, or the electronic resistance of the electrode matrices. Resistance rise directly reduces the available power (the cell cannot deliver high current without excessive voltage sag), increases heat generation, and (by increasing polarisation) can indirectly accelerate further degradation by pushing the local electrode potential outside safe limits.

Impedance growth is primarily detected by DCIR measurements or EIS, and by the increased separation between charge and discharge voltage curves at a given current (the larger the gap, the more resistive the cell).

### Using the Framework

The value of this three-mode classification is that it separates degradation signatures in measurable data. A capacity check at low C-rate (C/20 or lower) measures the combined effect of LLI and LAM but is relatively insensitive to conductivity loss (at very low rate, overpotentials are small and resistance barely affects deliverable capacity). A capacity check at moderate C-rate (1C) reflects all three modes. A resistance measurement (HPPC or EIS) directly quantifies conductivity loss. An OCV or $dQ/dV$ curve reveals the relative shifts of the two electrode OCV curves, enabling separation of LLI from LAM and identification of which electrode is more degraded.

Before we dive in, it is worth fixing the landscape in your head. The three modes are orthogonal axes of failure, and every mechanism we will discuss projects onto one or more of them. Here is the rough map:

```text
                LLI          LAM        CL
                (guest)      (host)     (transport)
                ---------    ---------  ---------
SEI growth      ■ strong     □          ■ weak
Li plating      ■ strong     □          □
Particle crack  ■ secondary  ■ strong   ■ weak
TM dissolution  ■ strong     ■ weak     ■ strong
CEI growth      □            □          ■ strong
Electrolyte dry □            ■ weak     ■ strong
```

The filled boxes mark the *primary* mode each mechanism drives; the weak-shaded ones mark the secondary consequences. Notice how several mechanisms show up under multiple modes — that is the coupling the chapter opening warned you about, and it is why the mechanisms cannot be discussed in complete isolation. Keep this table in your peripheral vision as we go through the sections. By §7.6 you should be able to reconstruct it from memory.

With this framework in hand, we can now examine each specific mechanism, understand which mode it drives, and identify its diagnostic signature.

---

## SEI Growth — The Dominant Calendar Aging Mechanism

We introduced the SEI in Chapter 2 and encountered it again in Chapter 4's formation discussion. Now we need to understand its long-term evolution quantitatively, because continuous SEI growth is the single most important degradation mechanism in lithium-ion cells under normal operating conditions.

### The Thermodynamic Instability That Never Fully Goes Away

Recall from Chapter 2 that the graphite anode operates at 0.05–0.25 V vs. Li/Li⁺ — a strongly reducing potential at which the organic electrolyte is thermodynamically unstable. The SEI forms during the first cycles and passivates the surface, creating a kinetic barrier that slows further electrolyte reduction to a very low rate. But it never fully stops.

Even through a thick, well-formed SEI, there is a non-zero probability that solvent molecules or salt anions diffuse through the film, reach the graphite surface, and are reduced. This happens continuously — during cycling, when the SEI is mechanically stressed and partially disrupted, and during rest (calendar aging), when there is no current but the thermodynamic driving force persists as long as the anode is at low potential (i.e., at high SOC).

The rate of ongoing SEI growth is governed by solid-state diffusion of reactive species (primarily ethylene carbonate or its fragments, and water trace contaminants) through the existing SEI layer. As the SEI thickens, the diffusion path length increases, and the rate of further growth decreases. This self-limiting kinetics produces the characteristic **parabolic growth law**, and the derivation is worth walking through because it is the same piece of math you have already seen several times in disguise.

Imagine the SEI as a thin film of thickness $L$ separating the graphite surface (where reactive species are consumed, so the concentration at $x = L$ is effectively zero) from the bulk electrolyte (where the concentration is held roughly constant at $c_0$). Let $D$ be the diffusivity of the reactive species through the SEI. In steady state — which is a good approximation because diffusion through a nanometre-scale film is much faster than SEI growth itself — the flux through the film is
$$J = \frac{D c_0}{L}.$$
Now, every molecule that makes it through gets consumed and forms new SEI on the graphite side. If each molecule adds a fixed volume $v$ of SEI material, the thickness grows as
$$\frac{dL}{dt} = v J = \frac{v D c_0}{L}.$$
This is a separable ODE. Rearranging gives $L\,dL = v D c_0\,dt$, and integrating from $L_0$ at $t = 0$ to $L$ at time $t$ yields
$$L^2 - L_0^2 = 2 v D c_0\, t.$$
For $L \gg L_0$ (well past the formation cycles), the constant drops out and we recover
$$L(t) \approx \sqrt{2 v D c_0}\,\sqrt{t},$$
which is the parabolic growth law in its cleanest form. The expression under the outer square root is the rate constant $k_\text{SEI}$. Writing this with the initial offset restored gives equation (7.1):

$$L_\text{SEI}(t) = L_0 + k_\text{SEI} \sqrt{t} \tag{7.1}$$

If this structure looks familiar, it should: it is the same math that governs the growth of an oxide layer on silicon during thermal oxidation (the Deal–Grove model), the depletion of a diffusing species into a semi-infinite medium, and — the EE version — the spreading of a voltage disturbance down a diffusive RC transmission line, whose penetration depth grows as $\sqrt{t}$. Whenever the rate of a process is throttled by diffusion through its own product, $\sqrt{t}$ is the signature.

It is worth stopping to put a number on the SEI's physical dimensions, because most readers imagine it as either invisibly thin or much thicker than it really is. A freshly-formed SEI on a graphite particle is typically 5–20 nanometres thick — a few tens of atomic layers, on the same scale as a thermal gate oxide in a modern MOSFET. Over years of calendar aging and thousands of cycles, the SEI on an aged cell might grow to 50–100 nanometres: still thin on any macroscopic scale, but now thick enough to meaningfully impede ion transport and to contribute measurably to the impedance rise of the cell. The fact that a difference of a few tens of nanometres of film thickness — invisible at any normal microscopy resolution — is the difference between a fresh cell and an end-of-life cell is one of the counterintuitive things about battery aging, and it is why "more SEI" is synonymous with "older cell."

The lithium consumed by SEI growth is directly proportional to the SEI thickness: each nanometre of new SEI consumes a calculable amount of lithium per unit area. Since LLI scales with SEI thickness, and SEI thickness grows as $\sqrt{t}$, we expect capacity fade from SEI-driven LLI to also follow a $\sqrt{t}$ law:

$$\Delta Q_\text{LLI}(t) \propto \sqrt{t} \tag{7.2}$$

This square-root time dependence is a quantitative prediction of the diffusion-limited SEI growth model, and it can be tested experimentally by measuring capacity at intervals during long-term calendar aging. Empirical calendar aging data for lithium-ion cells at fixed temperature and SOC typically show excellent $\sqrt{t}$ fits over periods of months to years. When a dataset deviates from $\sqrt{t}$ behaviour — for example, showing a faster-than-$\sqrt{t}$ rate later in life — it is a signal that a secondary degradation mechanism has become active (perhaps particle cracking has exposed fresh surface area, giving the SEI a new growth front).

### Temperature Dependence: The Arrhenius Law for SEI Growth

The rate constant $k_\text{SEI}$ depends on temperature through the **Arrhenius equation**, which is the workhorse expression for any thermally activated process. In physical terms: the reaction (here, the diffusion step that rate-limits SEI growth) requires a molecule to climb an energy barrier of height $E_a$, called the **activation energy**. The probability of a molecule having enough thermal energy to clear that barrier follows a Boltzmann distribution, and integrating over the distribution gives an $\exp(-E_a/k_B T)$ factor per molecule, or equivalently $\exp(-E_a/RT)$ if $E_a$ is expressed per mole and $R = N_A k_B$ is the gas constant. The prefactor $A$ lumps together everything else — collision frequency, geometric factors, attempt rate.

If you have ever looked at reverse-bias current in a Schottky diode, or the thermal generation current in a BJT, you have seen the same exponential. In semiconductor physics we write it $\exp(-\phi_B/k_B T)$, where $\phi_B$ is the barrier height; in chemistry we write it $\exp(-E_a/RT)$. It is the same physics and the same math — a thermally excited population clearing a barrier — and it pays to recognise the pattern wherever it appears.

$$k_{\mathrm{SEI}}(T) = A \exp\left(-\frac{E_a}{RT}\right) \tag{7.3}$$

where $E_a$ is the activation energy for the diffusion of reactive species through the SEI, typically 40–80 kJ/mol for commercial cells. At this activation energy, an Arrhenius calculation gives:

$$
\frac{k_{\mathrm{SEI}}(35^\circ\mathrm{C})}{k_{\mathrm{SEI}}(25^\circ\mathrm{C})}
= \exp\left(\frac{E_a}{R}\left(\frac{1}{298\mathrm{K}} - \frac{1}{308\mathrm{K}}\right)\right)
$$

With $E_a = 60\,\mathrm{kJ\,mol^{-1}}$ and $R = 8.314\,\mathrm{J\,mol^{-1}\,K^{-1}}$:

$$
\frac{k_{\mathrm{SEI}}(35^\circ\mathrm{C})}{k_{\mathrm{SEI}}(25^\circ\mathrm{C})}
= \exp\left(
\frac{60000\,\mathrm{J\,mol^{-1}}}{8.314\,\mathrm{J\,mol^{-1}\,K^{-1}}}
\cdot
\frac{10\mathrm{K}}{298 \cdot 308\mathrm{K}^2}
\right)
= \exp(0.786) \approx 2.19
$$

A 10°C temperature increase roughly doubles the calendar aging rate. This factor-of-two is the quantitative basis for the industry rule of thumb you will hear often: storing lithium-ion cells at elevated temperature dramatically accelerates calendar aging. Carrying the same calculation forward, a cell stored at 45 °C ages approximately 4–5× faster than the same cell at 25 °C, and roughly 20× faster than a cell stored at 5 °C. These numbers depend sensitively on the assumed activation energy — a cell chemistry with $E_a = 40$ kJ/mol would show factors closer to 3× and 10×, while a cell with $E_a = 80$ kJ/mol would show factors closer to 6× and 40× for the same temperature range. When you see a calendar-aging acceleration table in a datasheet or paper, recognise that the underlying $E_a$ is doing most of the work and is worth extracting.

### SOC Dependence

The rate of SEI growth also depends on the state of charge of the cell during storage. At higher SOC, the anode is more lithiated and therefore sits at a lower potential (closer to 0 V vs. Li/Li⁺), where the thermodynamic driving force for electrolyte reduction is stronger. The overvoltage for SEI-forming reactions is larger, driving more rapid electrolyte decomposition.

Quantitatively, the SOC dependence is often modelled as an exponential in the anode potential $U_\text{anode}$:

$$k_\text{SEI}(\text{SOC}) \propto \exp\!\left(-\frac{\beta F U_\text{anode}}{RT}\right) \tag{7.4}$$

where $\beta$ is an empirical coefficient. Since $U_\text{anode}$ decreases as SOC increases (lower potential = more reducing = higher SEI growth rate), $k_\text{SEI}$ increases with SOC. The practical implication: a cell stored at 100% SOC ages faster than a cell stored at 50% SOC, which ages faster than a cell stored at 20% SOC.

The combined temperature-SOC dependence of calendar aging is what drives the engineering recommendation to store lithium-ion batteries at 30–50% SOC in a cool location — not arbitrary caution, but a quantitative optimisation of the Arrhenius kinetics.

### What the Cycle-by-Cycle SEI Evolution Looks Like

During cycling, the SEI is not simply growing — it is simultaneously growing on fresh surfaces and being disrupted. Graphite is not an isotropic swelling material: between empty graphite and fully lithiated LiC₆, the $c$-axis (the stacking direction, perpendicular to the graphene planes) expands by roughly 10%, while the $a$-axis barely moves at all. The overall volumetric change over a full charge-discharge excursion is on the order of 10–13%, and because the expansion is anisotropic, particles experience shear strains at grain boundaries and at contact points with neighbouring particles. The SEI cracks preferentially at these locations — at particle contacts, at sharp surface features, and along high-curvature edges. The cracked regions expose fresh graphite. The electrolyte re-contacts those surfaces and new SEI nucleates.

This means the steady-state Coulombic efficiency is set by a balance between SEI growth (consuming lithium continuously) and the stability of the passivation layer (slowing the growth). A well-formed, stable SEI — produced by careful formation cycling and maintained by appropriate cycling conditions — keeps the per-cycle lithium loss to approximately 0.01–0.2% of capacity per cycle. A poorly formed or frequently disrupted SEI can consume 0.5–2% or more per cycle.

It is worth putting a number on this to make the calendar-vs-cycle distinction tangible. Take a commercial NMC/graphite cell with a steady-state Coulombic efficiency of 99.95% per cycle — a realistic figure for a well-formed cell after the first 50 cycles. A Coulombic efficiency of 99.95% means that each charge-discharge cycle permanently consumes 0.05% of the cycled capacity as new LLI (new SEI, mostly). If the cell is cycled once per day between 0% and 100% SOC, that is 0.05% per day from cycling alone, or roughly 18% per year from the cycling contribution if the rate stayed constant (it won't — it will slow down as the $\sqrt{t}$ behaviour asserts itself, but the leading term is useful for intuition). Meanwhile, the same cell, sitting on the shelf at 50% SOC and 25 °C, will lose perhaps 2–3% of capacity to calendar aging over the same year. Under these conditions the cycle-aging contribution dominates the calendar contribution by roughly an order of magnitude. Now run the same comparison for a grid-storage cell cycling once every three days and resting at high SOC between cycles in a hot climate — the calendar term grows, the cycle term shrinks, and the dominant aging pathway can flip. The lesson is that "which mechanism dominates" is not a property of the cell alone; it is a property of the cell *and* the duty cycle together, and it is why the same chemistry can have wildly different field lifetimes in different applications.

The gradual rise of per-cycle lithium loss over the cell's life — from near-zero when the cell is fresh to increasingly significant as mechanical degradation (Section 7.4) disrupts the SEI more aggressively — is one of the hallmarks of late-life accelerated degradation.

We will see this $\sqrt{t}$ law again in Chapter 10, where it shows up as the structural prior in model-based state-of-health estimators: a Kalman filter that expects capacity to decline as $\sqrt{t}$ will track a well-behaved calendar-aging trajectory much better than one that assumes linear decline, and its estimates of remaining useful life will be correspondingly less biased.

---

## Lithium and Sodium Plating — When and Why

Lithium plating — the deposition of metallic lithium on the graphite anode surface rather than intercalation into the graphite — is one of the most dangerous and irreversible degradation mechanisms in lithium-ion batteries. It is also one of the most practically relevant, because it is directly triggered by fast charging and by low-temperature operation — precisely the operating conditions that battery users most want to improve.

### The Physical Mechanism

During charging, a lithium ion arriving at the graphite anode surface from the electrolyte has two competing reactions available to it. One is the intended reaction — intercalation into the graphite host:
$$\text{Li}^+ + e^- + \text{C}_6 \rightarrow \text{LiC}_6 \quad \text{(intercalation; good)}$$
The other is plating — reduction to solid metallic lithium on the graphite surface:
$$\text{Li}^+ + e^- \rightarrow \text{Li}(\text{s}) \quad \text{(plating; bad)}$$
These reactions have different equilibrium potentials. The intercalation reaction happens at the graphite equilibrium potential, which ranges from about 0.25 V vs. Li/Li⁺ when the graphite is nearly empty down to about 0.05 V when it is nearly full. The plating reaction happens at, by definition, 0 V vs. Li/Li⁺ — that is literally the reference. So whichever electrochemical process has the *higher* equilibrium potential during reduction wins: while the graphite surface is sitting at, say, 0.15 V, intercalation is energetically favoured over plating, and the ion slides into the graphite lattice. But if the local electrode potential gets pulled down to 0 V or below — either because the graphite is nearly full (so its own equilibrium potential is already close to 0 V) or because the overpotential driving current through the cell is large enough to push the surface potential below the graphite's equilibrium value — then plating becomes competitive, and then dominant.

For intercalation to win cleanly, then, two conditions must be met simultaneously. First, the local electrode potential must be comfortably above 0 V vs. Li/Li⁺. Second, the lithium ions must be able to diffuse into the graphite lattice *at the rate they are arriving at the surface*, so that they don't pile up at the surface and build up a concentration gradient that drags the local potential down further.

The local electrode potential at any point on the graphite surface during charging is:

$$E_\text{local} = E_\text{OCV,anode}(\text{local SOC}) - |\eta_\text{local}| \tag{7.5}$$

where $E_\text{OCV,anode}$ is the anode equilibrium potential at the local state of lithiation, and $|\eta_\text{local}|$ is the magnitude of the local overpotential (sum of activation and concentration contributions). During charging, the anode is being driven cathodically — reduction is happening, current flows into the anode — so in the standard sign convention $\eta_\text{local} = E_\text{local} - E_\text{OCV,anode}$ is negative, and $E_\text{local}$ sits *below* $E_\text{OCV,anode}$. We have written the equation with an absolute value so that the geometric picture ("the local potential is pulled down from equilibrium by the overpotential") is unambiguous. If $|\eta_\text{local}|$ becomes large enough that $E_\text{local}$ drops to or below 0 V vs. Li/Li⁺, lithium cannot preferentially intercalate — it plates as metal instead.

There are five things that push $|\eta_\text{local}|$ up, and they mostly act together rather than in isolation. The first is **charging current**: a higher current demands more driving force from the Butler-Volmer equation, which directly enlarges the activation overpotential $\eta_\text{act}$. The second is **temperature**: the charge-transfer resistance at the SEI–graphite interface follows an Arrhenius law, so at low temperatures the kinetics slow down exponentially and a much larger overpotential is required to drive the same current. The third is **local lithiation** — note that the operative word here is *local*, not *global*. Plating is not fundamentally a global-SOC phenomenon; it is a local-composition phenomenon. Under fast charging the separator-facing side of the anode sees the highest current density and fills up first, so its local lithiation can be significantly higher than the anode's average lithiation, and its local equilibrium potential correspondingly closer to 0 V vs. Li/Li⁺. This is why plating can initiate at a globally modest SOC — 60–80% — under aggressive charging, and it is why a proper plating model requires a pseudo-2D description that resolves the through-thickness lithiation profile rather than collapsing the anode to a single state-of-charge tank. The fourth is **electrode thickness and tortuosity**: diffusion limitation in the electrolyte-filled pores adds concentration overpotential $\eta_\text{conc}$ on top of the activation contribution, and this term grows with electrode thickness. The fifth is **SEI thickness**: as the SEI thickens with age, the ion transfer resistance through the film grows, and the extra $\eta_\text{act}$ it demands can by itself push an old cell into plating under charging conditions that a fresh cell would tolerate comfortably.

This is why the combination of fast charging (high current) at low temperature (slow kinetics) at high SOC (low equilibrium margin), on an aged cell with a thickened SEI, is the worst possible condition for lithium plating — and why manufacturers specify charging below 0 °C as prohibited for graphite-anode lithium-ion cells.

### What Happens to Plated Lithium

Once lithium metal deposits on the graphite surface, there are three possible fates, in roughly ascending order of severity. The most benign is **re-intercalation during discharge**. If the plated lithium remains in good electronic contact with the graphite surface, the subsequent discharge will strip it back: the metallic lithium dissolves anodically and re-enters the electrolyte as Li⁺, and from there it can intercalate into the cathode just as if nothing had happened. This is the least harmful outcome, but it is not free: the stripped lithium leaves behind a porous, surface-area-rich graphite surface that presents a larger footprint for SEI formation on the next charge, so even "reversible" plating still accelerates LLI indirectly.

A worse outcome is **isolation as dead lithium**. Metallic lithium that is stripped from the electrode surface can become electronically disconnected — either as a fragment mechanically detached during the strip, or as lithium that has reacted around its edges with the electrolyte and become encased in its own SEI. Once surrounded by an ionically-permeable but electronically-insulating SEI shell, a lithium deposit is electrochemically orphaned: no electron can reach it, so it cannot participate in any further reaction. This **dead lithium** contributes directly to LLI, and unlike reversibly-plated lithium, it never comes back.

The most catastrophic outcome is **dendrite growth and internal short circuit**. Under conditions of repeated or severe plating, lithium deposits preferentially at high-electric-field points on the electrode surface — sharp edges, SEI defects, dead-lithium stubs — and grows there as needle-like metallic filaments called **dendrites**. If a dendrite grows long enough to pierce the separator and contact the cathode, it creates an internal short circuit: a sudden, uncontrolled energy release that can ignite the electrolyte and trigger thermal runaway. This is the dominant failure mode for lithium-metal anodes and, under severe abuse, for graphite anodes too. It is also the reason lithium plating is treated as a safety issue and not merely an aging issue, and it is why BMS algorithms that suppress plating during fast charging are considered safety functions, not just longevity functions.

### Diagnosing Lithium Plating from External Measurements

Lithium plating leaves several diagnostic signatures.

A **sub-1C Coulombic efficiency drop** — a sudden decrease in CE by 0.1–0.5% per cycle — indicates that less charge is being recovered on discharge than invested on charge, consistent with some fraction of the charge going to form dead lithium that cannot be recovered.

A **voltage plateau on discharge** provides the cleanest electrochemical fingerprint. When plated lithium strips from the anode surface during discharge, it does so at an anode potential slightly above 0 V vs. Li/Li⁺ — before the main graphite destaging reactions, which happen around 0.1–0.2 V. This produces a short, flat plateau at the very beginning of discharge, visible as a subtle shoulder in the full-cell voltage curve whose absolute voltage depends on the cathode's state at the start of discharge: roughly 4.0–4.2 V for an NMC or LCO cell near top of charge, roughly 3.3–3.4 V for an LFP cell. In practice the stripping plateau is easier to see in the *differential* voltage curve ($dV/dQ$ vs. $Q$) than in the raw voltage curve, because the plateau shows up as a local dip in $dV/dQ$ that stands out sharply from the surrounding staging features. This "stripping plateau" is a diagnostic fingerprint of prior plating, and it is the measurement of choice for distinguishing plating-driven LLI from SEI-driven LLI in cycling studies.

An **EIS low-temperature shift** is another signature: at low temperatures, the EIS spectrum shows an enlarged charge-transfer semicircle (consistent with higher $R_\text{ct}$) and, after plating, an additional feature in the mid-frequency range corresponding to the lithium metal/SEI interface.

Finally, **post-mortem cell opening** is the gold standard when it can be done. In research settings, cells suspected of plating are disassembled in an argon-atmosphere glove box, and metallic lithium deposits appear as grey, reflective patches on the graphite anode surface — unmistakable under examination.

**A common misconception worth flagging.** Students often treat "lithium plating" and "dendrite formation" as synonyms. They are not. Plating is the *event* — the reduction of Li⁺ to Li(s) on the anode surface instead of into the graphite host. Dendrites are a *morphological outcome* of plating under specific conditions: high local current density, localised SEI defects, and sustained plating over many cycles. Most plating events in commercial cells, especially early in life, produce soft, mossy, relatively uniform deposits rather than sharp dendrites. These mossy deposits contribute to LLI (they are lithium that cannot come back) but they do not puncture the separator, and the cell does not short. The transition from mossy plating to dendritic plating happens when plating concentrates at a few points — typically after many plating cycles have reshaped the SEI and after dead lithium has accumulated to the point where the electric field is no longer uniform across the anode surface. When you read that a cell "showed plating" in a cycling study, the default assumption should be mossy, not dendritic, unless the authors specifically report a separator short or a safety event.

### Sodium Plating in SIBs

The analogous concern in sodium-ion batteries is **sodium plating** on the hard carbon anode surface. The physics is identical: if the local anode potential drops to or below 0 V vs. Na/Na⁺, sodium plates as metal rather than inserting into the carbon.

Sodium metal is not as prone to dendrite growth as lithium metal — the surface energy of sodium metal and its different SEI chemistry result in more equiaxed deposits rather than sharp dendrites — which is one physical reason why SIBs are generally considered somewhat safer than LIBs with respect to plating-induced short circuit risk. However, sodium plating still contributes to LLI through dead sodium formation, and the low-potential plateau of hard carbon (Section 6.5) means that the anode potential is close to 0 V vs. Na/Na⁺ during the plateau region of charging, leaving a small margin against plating.

This small margin means that fast charging of SIBs at low temperatures can trigger sodium plating even at moderate C-rates, and it is one reason that SIB fast-charging protocols require careful BMS management. The threshold for sodium plating is, however, less sharply temperature-dependent than for lithium plating (because the hard carbon plateau kinetics differ from graphite staging kinetics), and empirical evidence suggests SIBs can tolerate fast charging at temperatures around 0 °C better than equivalent LIBs — one of the low-temperature advantages we noted in Chapter 6.

To summarise the plating comparison in a single view:

|Property|Lithium plating on graphite|Sodium plating on hard carbon|
|---|---|---|
|Threshold anode potential|0 V vs. Li/Li⁺|0 V vs. Na/Na⁺|
|Plating margin at top of charge|~0.05 V (stage-1 graphite)|~0.01–0.02 V (hard-carbon plateau)|
|Dominant deposit morphology|Mossy → dendritic under severe conditions|Mossy, more equiaxed; dendrites rare|
|Short-circuit risk from dendrites|High under severe plating|Substantially lower|
|Contribution to LLI / LSI|High (dead lithium)|High (dead sodium)|
|Temperature sensitivity of onset|Very steep (Arrhenius $R_\text{ct}$)|Less steep; hard-carbon kinetics differ|
|Fast-charging tolerance at 0 °C|Poor (prohibited for graphite)|Moderate (better than graphite)|
|BMS management required|Plating-aware charging (delta-V, dV/dT)|Plating-aware charging, tighter margin in plateau|

Read this table as the "short form" of the SIB plating story. When you encounter a SIB fast-charging paper, the claims about low-temperature tolerance and thin plateau margin will track the relevant rows.

---

## Particle Cracking and Mechanical Fatigue

Electrode active material particles are not inert solids — they breathe. Every time a lithium or sodium ion intercalates, the host lattice expands. Every time an ion de-intercalates, the lattice contracts. Over thousands of cycles, these repeated expansion-contraction cycles impose mechanical fatigue on the electrode particles, eventually causing them to crack.

### The Mechanism: Diffusion-Induced Stress

When an electrode particle is charged (or discharged) at finite rate, the lithium (or sodium) concentration inside the particle is not uniform. The ion arrives at the particle surface first — that is where the electrolyte is — and diffuses inward from there. Equilibration takes time, and that time is set by the particle's diffusion time constant $\tau_\text{diff} \sim r^2/D_\text{s}$, where $r$ is the particle radius and $D_\text{s}$ is the solid-state diffusivity of lithium in the host material. If you drive the surface with a current that changes faster than $\tau_\text{diff}$, the interior of the particle cannot keep up. The surface fills or empties while the core is still near its starting composition.

If you are looking for an EE analogy, picture a distributed RC transmission line terminated in a short. If you apply a step voltage at the input (the surface), the near-input portion of the line charges up quickly, while the far end (the core) lags behind. For a brief interval, the voltage (read: lithium concentration) along the line is non-uniform. The electrochemical version of this is exactly the same PDE — Fick's second law is mathematically identical to the telegrapher's equation in the diffusive (lossy, non-inductive) limit.

Now, here is the mechanical twist that makes it matter. In most intercalation hosts, the lattice parameter depends on lithium content: the unit cell swells as lithium is inserted, so the local strain is proportional to the local concentration. During the non-equilibrium transient, the outer shell of the particle is already swollen (more lithium) while the core is still at its starting (less swollen) size. But the shell is mechanically bonded to the core — they are part of the same crystal. The shell wants to occupy a larger volume than the core will allow, so the shell ends up in compression in the radial direction and in *tension* in the tangential (hoop) direction, while the core pushes back in compression. This mismatch-induced internal stress is called **diffusion-induced stress (DIS)**, and it is the mechanical shadow of the concentration gradient.

The magnitude of DIS scales with the rate of charging (higher rate = steeper concentration gradient = larger mismatch), the partial molar volume of the ion in the host material $\Omega$ (larger volume change = larger strain per unit composition change), the elastic modulus of the material, and the particle size. The maximum tensile stress at the particle surface (the location where cracks typically initiate) scales as:

$$\sigma_\text{max} \sim \frac{E\,\Omega\,\Delta c_\text{max}}{1-\nu} \tag{7.6}$$

where $E$ is the Young's modulus of the host material, $\Omega$ is the partial molar volume of the inserted species, $\Delta c_\text{max}$ is the maximum concentration difference between surface and centre, and $\nu$ is Poisson's ratio. The dimensionless prefactor, which we have absorbed into the $\sim$, is on the order of $1/3$ to $2/9$ for a spherical particle and depends on whether one evaluates the radial or tangential stress at the surface or the centre (this is the Cheng–Verbrugge analysis, which is the canonical derivation and worth looking up when you need a precise value). For our purposes, the important thing is the *scaling*: stress grows linearly with modulus, with partial molar volume (a proxy for how much the lattice swells), and with the concentration gradient, and it is amplified for stiffer (larger $E$) and more constrained (larger $\nu$) materials. This stress is tensile at the surface for the case where the surface is more expanded than the core (insertion into a shell first), and tensile at the core for the reverse case. Both can cause cracking; the location of crack initiation depends on the sign of $\Delta c$ and the relative toughness of the material.

### Fracture Mechanics of Electrode Particles

A crack initiates when the stress intensity factor $K$ at the crack tip exceeds the fracture toughness $K_{1C}$ of the material:

$$K = Y \sigma_\text{max} \sqrt{\pi a} \geq K_{1C} \tag{7.7}$$

where $Y$ is a geometry-dependent dimensionless factor and $a$ is the crack length. For a small flaw of size $a_0$ already present in the particle (all real particles have manufacturing defects), the critical stress to propagate the crack decreases with increasing particle size (because $K \propto \sigma\sqrt{a}$ and larger particles have longer initial flaws and experience higher total strain). This explains why **particle size optimisation** is a central strategy for improving the cycle life of high-expansion electrode materials: smaller particles (below a critical size $r_c$) are more resistant to fracture because their total strain is smaller and their initial flaw size is proportionally smaller.

For NMC and NCA cathode particles (secondary particles composed of many smaller primary grains), cracking occurs preferentially **along grain boundaries** within the secondary particle — the interface between neighbouring primary grains is a stress concentration point and the grain boundary toughness is lower than the intragranular toughness. This mode of failure is called **intergranular cracking**, and it is the dominant fracture mechanism in high-nickel NMC (NMC622, NMC811) under aggressive cycling. Single-crystal NMC particles — where the secondary particle is a single grain — eliminate intergranular cracking and significantly improve cycle life, at the cost of more difficult synthesis and somewhat lower rate capability.

For hard carbon (SIB anode), the amorphous, cross-linked structure is more crack-resistant than crystalline LCO or NMC because there are no grain boundaries and the isotropic structure distributes stress more evenly. However, repeated expansion of the interlayer spacing during sodium intercalation can cause delamination of disordered graphene sheets, which is a softer form of mechanical degradation.

### Consequences of Cracking

Particle cracking has three downstream consequences that matter, and they all amplify the initial mechanical damage. The first is **active material isolation**, which is LAM in its purest form: when a crack propagates through a particle, it can sever the electronic percolation network that connects that particle's interior to the current collector, and the severed fragment becomes electronically orphaned. The lattice is intact, the lithium sites are still there, but there is no wire to reach them — they are dark, as far as the external circuit is concerned.

The second consequence is the creation of **new surface area for SEI formation**, which is LLI. Every freshly-exposed internal surface is an unpassivated patch of graphite or oxide, and the electrolyte begins forming SEI on it immediately. The lithium consumed is proportional to the new area exposed, so every crack event is also an LLI event — which is why §7.2's calendar-aging $\sqrt{t}$ law starts to break down in late life: cracking keeps opening new surfaces, giving the SEI new growth fronts, and resetting the diffusion clock on each one.

The third consequence is **corrosion fatigue**. Once a crack opens, electrolyte penetrates into the crack interior, where it is trapped and experiences concentration changes during cycling that generate additional osmotic stress at the crack tip. This stress can propagate the crack further under conditions that the particle's outer surface alone would have survived. Cracking is thus autocatalytic: a single initial flaw can, over enough cycles, grow into a network of cracks that shatters the particle and transfers most of its volume into the LAM bucket.

### Detecting Particle Cracking

Cracking is harder to diagnose non-invasively than the other mechanisms we've met in this chapter, and the most definitive methods are all destructive. The gold standard is **post-mortem microscopy**: a cycled cell is disassembled in a glove box, electrodes are rinsed and dried, and cross-sections of individual particles are imaged directly. Scanning electron microscopy (SEM) on focused-ion-beam-prepared cross-sections — what the literature calls FIB-SEM — is the reference technique for nanoscale crack imaging, though preparing the cross-sections without introducing preparation artifacts is technically demanding and the authors of a good FIB-SEM study have typically spent substantial time on sample preparation alone.

There are also several in-operando proxies. **Gas chromatography of the cell headspace** tracks the rate of fresh surface exposure through the characteristic gas products — CO₂, CO, hydrocarbons — that form when new, unpassivated electrode surface reacts with the electrolyte. **Impedance evolution** gives a less direct but non-invasive signal: cracking initially increases the active surface area (more particle surface per volume of electrode) which briefly lowers the charge-transfer resistance $R_\text{ct}$, but as isolated fragments accumulate and pore clogging from SEI debris sets in, both $R_\text{ct}$ and $R_\Omega$ rise. This non-monotonic impedance evolution — a brief dip followed by a sustained rise — has been observed in NMC811 cycling studies and is reasonably diagnostic of a cracking-driven degradation trajectory when the cycling protocol is aggressive enough to produce cracking. Finally, in pouch cells and in prismatic cells with deformable cases, the cumulative effect of cracking-driven SEI regeneration manifests as an irreversible increase in cell thickness. Measuring pouch-cell thickness as a function of cycle count — easy to do, doesn't touch the cell electrically — turns out to be a remarkably sensitive non-invasive proxy for cumulative mechanical degradation.

---

## Transition Metal Dissolution and Crosstalk

When the cathode operates at high potential, transition metal ions at the cathode surface can be chemically or electrochemically extracted from the host structure and dissolved into the electrolyte. These dissolved metal ions then migrate toward the anode and deposit on or into the graphite surface, catalysing destructive reactions there. This chain of events — dissolution at the cathode, migration through the electrolyte, deposition at the anode — is called **transition metal crosstalk** (or simply **metal contamination**).

### The Dissolution Mechanism

The dissolution of transition metals from cathode materials is driven by two coupled processes: chemical attack by hydrofluoric acid, and electrochemical oxidation at high cathode potential.

The chemical pathway starts with **HF attack**. The LiPF₆ salt in LIB electrolytes is thermodynamically unstable in the presence of trace water — which is inevitably present from electrode drying imperfections, from moisture ingress during assembly, and from downstream reactions. The hydrolysis proceeds as:

$$\text{LiPF}_6 + \text{H}_2\text{O} \rightarrow \text{LiF} + \text{POF}_3 + 2\,\text{HF} \tag{7.8}$$

and POF₃ continues to react with further water to generate more HF. The upshot is that *any* Li-ion cell with a PF₆⁻-based salt and non-zero water content will contain some HF, and the HF concentration grows over time — especially at elevated temperature, where the hydrolysis is faster.

"HF attack" on a cathode surface needs a moment of unpacking, because the word "attack" makes it sound more mysterious than it is. At a metal oxide cathode surface — say, the (104) facet of an NMC particle — the terminal metal atoms are coordinated to oxygen. When HF molecules reach this surface, the fluoride is a strong ligand for transition metals, and the reaction
$$\text{MO}_x(\text{surface}) + 2\,\text{HF} \rightarrow \text{MF}_2(\text{dissolved}) + \text{H}_2\text{O}$$
is thermodynamically favoured. The metal fluoride is soluble in carbonate electrolyte; the oxygen leaves as water. The net effect is that a thin layer of cathode is slowly etched off, molecule by molecule. If you have ever seen a wet etch step in a semiconductor process — HF stripping native oxide off a silicon wafer in the lab, or BOE etching silicon dioxide — it is exactly that picture, at exactly the same kind of rates (slow at room temperature, accelerating by factors of 2–10 per 20 °C).

For the Mn³⁺/Mn⁴⁺-containing spinel LiMn₂O₄, the reaction proceeds through the **Hunter mechanism**, a disproportionation driven by protons (or, equivalently, by HF):

$$2\,\text{LiMn}_2\text{O}_4 + 4\,\text{H}^+ \rightarrow 3\,\text{MnO}_2\,(\text{s}) + \text{Mn}^{2+}\,(\text{aq}) + 2\,\text{Li}^+ + 2\,\text{H}_2\text{O} \tag{7.9}$$

Parse this one carefully, because the oxidation-state bookkeeping is the whole point. In LiMn₂O₄, Mn is in a mixed +3/+4 state, averaging +3.5. When protons attack the spinel surface, three of every four Mn atoms are left behind as solid MnO₂ (Mn⁴⁺), while the fourth is released as soluble Mn²⁺ — i.e., three Mn atoms are oxidised and one is reduced, all within the same reaction. This is exactly the Mn³⁺ disproportionation we first wrote in Chapter 5 (Equation 5.3), now happening at the cathode surface in the presence of acid:

$$2\,\text{Mn}^{3+} \rightarrow \text{Mn}^{2+}\,(\text{dissolved}) + \text{Mn}^{4+}\,(\text{stable solid}) \tag{7.10}$$

Equation (7.9) is just the fully-written-out version of (7.10) on the LMO surface, with the protons and water molecules explicitly accounted for. The soluble Mn²⁺ is the species that leaves the cathode and goes on to cause crosstalk at the anode. For NMC, the analogous mechanism runs over any Mn³⁺ fraction present in the cathode — which is why higher-Mn compositions (NMC111, NMC442) are more susceptible than lower-Mn compositions (NMC811) to HF-driven Mn loss, even though the latter have worse *overall* TM dissolution because of Ni dissolution at high voltage. Temperature accelerates both HF generation and dissolution: above approximately 40–50 °C, Mn dissolution from LMO becomes rapid enough to cause severe cycle-life degradation within hundreds of cycles.

The second pathway is **electrochemical dissolution at high voltage**. Independent of HF, highly delithiated cathode surfaces (at high positive electrode potential) can spontaneously dissolve transition metals through an oxidative mechanism. Cobalt dissolution from LCO at potentials above approximately 4.2 V vs. Li/Li⁺, and nickel dissolution from high-Ni NMC at potentials above approximately 4.3 V, are well-documented. This is one reason that overcharging — even slightly above the rated upper voltage — accelerates degradation dramatically.

### The Crosstalk Mechanism

Once transition metal ions (most commonly Mn²⁺, Co²⁺, Ni²⁺) are dissolved in the electrolyte, they migrate toward the graphite anode under the combined influence of diffusion and the electric field in the electrolyte. At the anode, they are electrochemically reduced at the much lower anode potential:

$$\text{M}^{2+} + 2e^- \rightarrow \text{M}\,(\text{metal deposit}) \tag{7.11}$$

These metal deposits (manganese, cobalt, or nickel metal particles) on the graphite surface catalyse the continued decomposition of the electrolyte. The metal particles act as heterogeneous catalysts for SEI-decomposing reactions, dramatically accelerating the rate of LLI at the anode. This catalytic effect means that even very small concentrations of dissolved transition metal can cause disproportionate acceleration of capacity fade — parts-per-million levels of dissolved manganese in the electrolyte measurably increase capacity fade rates.

Additionally, metal deposition on the SEI changes its mechanical and transport properties, causing it to become less effective as a passivation layer and more variable in thickness. In severe cases, the modified SEI cracks more easily, further exposing fresh graphite and compounding the problem.

### Crosstalk in SIBs

Transition metal dissolution in SIBs follows the same chemical logic. Iron-containing cathodes (NFPP, Prussian white) and manganese-containing cathodes (P2-NaMnO₂, PBA with Mn) are subject to dissolution. The hydrolysis pathway that generates HF in a LiPF₆ electrolyte applies essentially unchanged to a NaPF₆ electrolyte — the unstable species is the PF₆⁻ anion, whose decomposition in the presence of trace water produces POF₃ and HF largely independent of the counter-cation. In practice, NaPF₆ is often described as having similar or slightly worse thermal stability than LiPF₆, and the HF problem is not mitigated by the switch from lithium to sodium. Vanadium dissolution from NVPF is a specific concern — dissolved vanadium species are toxic and also interfere with the hard carbon SEI — and is one of the reasons NVPF cells tend to show accelerated fade at elevated temperature compared to their lithium analogues.

Prussian blue analogues have their own dominant degradation pathway, and it is not HF-driven. PBAs are synthesised with significant amounts of **zeolitic water** trapped in the framework cavities, and removing this water before cell assembly is notoriously difficult. During cycling, residual water desorbs slowly, and the framework loses the structural support the water molecules provided — vacancies collapse, the lattice distorts, and active material is lost. This is a LAM mechanism, distinct from the HF-and-dissolution pathway we have been discussing. On top of that, Mn-containing PBAs suffer from Jahn–Teller distortion around Mn³⁺ just like their Li-ion counterparts, which adds a mechanical-fatigue contribution during the Mn²⁺/Mn³⁺ redox couple. The water-sensitivity issue discussed in Chapter 6 is the root cause of the LAM pathway, and thorough dewatering during electrode preparation is one of the open engineering challenges for commercial PBA-based SIB cells.

---

## Electrolyte Decomposition and Gas Generation

The electrolyte is not a passive bystander in degradation — it is consumed. The SEI formation reactions (Chapter 2) are a form of electrolyte decomposition, but ongoing electrolyte decomposition occurs throughout the cell's life at both electrodes and is one of the major contributors to capacity fade in long-life applications.

### Reductive Decomposition at the Anode

Ongoing reductive decomposition at the anode is primarily the SEI growth mechanism we discussed in Section 7.2. The products include organic lithium salts (lithium alkyl carbonates), inorganic species (LiF, Li₂CO₃, Li₂O), and gases (CO₂, CO, C₂H₄). In a sealed cell, the gases dissolve back into the electrolyte to some extent; what cannot dissolve contributes to internal gas pressure. In a pouch cell, this manifests as cell swelling. In a cylindrical cell, as rising internal pressure that can eventually actuate the safety vent.

### Oxidative Decomposition at the Cathode

At the high potentials of the positive electrode (3.5–4.5 V vs. Li/Li⁺), the electrolyte undergoes oxidative decomposition — the solvent molecules are electrochemically oxidised at the cathode surface, forming the **cathode–electrolyte interphase (CEI)** mentioned in Chapter 4. The CEI is generally thinner and less well-studied than the SEI, but its growth contributes to impedance rise and to a gradual loss of electrolyte (which, if sufficient, can dry out the cell and cause sudden death).

The oxidation onset potential for EC:DMC electrolyte is approximately 4.5–5.0 V vs. Li/Li⁺ in the absence of a catalyst. However, in the presence of surface impurities (water, HF, dissolved metals) or at elevated temperature, oxidative decomposition begins at much lower potentials — as low as 4.0–4.2 V vs. Li/Li⁺. This is why operating voltage limits are carefully managed in high-nickel NMC cells, and why electrolyte additives that preferentially oxidise to form a stable CEI (analogous to how VC and FEC form a stable SEI) are an active area of electrolyte development.

### Gas Generation and Its Consequences

The gases produced by electrolyte decomposition — CO₂, CO, C₂H₄, C₃H₆ (propylene, from PC decomposition), H₂ — affect cell performance in three distinct ways.

The first is **direct pressure increase**. As discussed, this can cause pouch cell swelling and prismatic cell case deformation. For cylindrical cells, sufficient internal pressure actuates the **current interrupt device (CID)** — a safety mechanism that permanently disconnects the cell internally when pressure exceeds a threshold, causing irreversible capacity loss.

The second is **gas bubble formation at electrode surfaces**. Gas nucleating at the electrode surface creates a gas film that blocks ionic access to the electrode surface beneath it, locally increasing ionic resistance and redistributing current density — the remaining open surface must carry more current, increasing local overpotential and accelerating further decomposition. This is another positive feedback loop.

The third is **electrolyte depletion**. Each mole of electrolyte consumed to generate gas (or to form SEI/CEI) is a mole of electrolyte no longer available for ionic conduction. Long-lived cells (10+ years, 5,000+ cycles) can lose enough electrolyte to cause a transition from electrolyte-saturated operation to a partially dry electrode state, where some electrode volume is no longer electrolyte-wetted. The transition to partial drying causes sudden, accelerated impedance rise — the cell reaches a **knee point** beyond which degradation accelerates rapidly.

---

## Calendar Aging vs. Cycle Aging — Different Physics, Different Models

With the individual mechanisms established, we can now address the distinction between calendar aging and cycle aging at the model level. This distinction matters practically because real applications combine both: a cell in an EV is cycling during the day and resting at night, and the total degradation is the combined result of both contributions.

### Calendar Aging: The Diffusion-Limited Regime

**Calendar aging** is dominated by SEI growth during storage and by electrolyte decomposition at the cathode under static conditions. Both are diffusion-limited processes. As established in Section 7.2, the capacity fade from calendar aging follows the parabolic (square-root-time) law:

$$Q_\text{loss,cal}(t, T, \text{SOC}) = B(T, \text{SOC}) \cdot \sqrt{t}, \qquad B(T, \text{SOC}) = B_0(\text{SOC})\,\exp\!\left(-\frac{E_a}{RT}\right) \tag{7.12}$$

where $B_0$ is a pre-exponential factor that depends on SOC (encoding the SEI growth rate's SOC dependence through the exponential-in-$U_\text{anode}$ form of equation 7.4), $E_a$ is the effective activation energy, $T$ is temperature, and $t$ is time. This is the **Wang model** or **Arrhenius square-root model** for calendar aging, and it fits empirical data for graphite/LFP and graphite/NMC cells over 1–5 years with reasonable accuracy.

The model breaks down at very long times and high temperatures for two reasons. First, above ~60 °C, additional mechanisms (CEI growth, electrolyte oxidation) that are not diffusion-limited begin to contribute. Second, the $\sqrt{t}$ law assumes the SEI grows on the same surface throughout — but particle cracking creates new surface area, adding a new kinetic regime after significant mechanical degradation has occurred.

### Cycle Aging: A Superposition of Mechanisms

**Cycle aging** is mechanistically more complex because it involves contributions from LLI (per-cycle SEI formation), LAM (per-cycle cracking and isolation), and conductivity loss (per-cycle SEI restructuring and thickening), all of which scale with cycle count $N$, DOD, C-rate, and temperature in different ways.

The empirical models used in industry are typically **power-law** or **exponential** in cycle count:

$$Q_\text{loss,cyc}(N, \text{DOD}, I, T) = C \cdot N^z \cdot f(\text{DOD}) \cdot g(I) \cdot h(T) \tag{7.13}$$

where $C$ is a chemistry-dependent constant and $z$ is an empirical power-law exponent, typically in the range 0.5–1.0. A value near 1.0 corresponds to the simplest scenario, in which each cycle costs roughly the same fraction of capacity (so cumulative loss is linear in cycle count) — this is what you observe when the dominant mechanism is cycle-driven SEI regeneration on freshly-cracked surfaces, which presents a roughly constant fraction of new area per cycle. A sub-linear exponent $z < 1$ (commonly $z \approx 0.5$–0.8) is observed when the per-cycle damage slows down over time, typically because the cell is in the early-life regime where the calendar-aging $\sqrt{t}$ contribution is dominant and the "cycle" clock and the "time" clock are running at proportional rates. The exponent is best treated as an empirical fit parameter and not overinterpreted — $z$ absorbs several physical mechanisms at once and its value depends on how $N$ itself is defined (full cycles, equivalent cycles, throughput). The functions $f$, $g$, $h$ are empirical multipliers capturing DOD, C-rate, and temperature dependence respectively, and we treat each in turn in §7.8.

The DOD function $f(\text{DOD})$ typically increases strongly with DOD: cycling over 100% DOD is much more damaging per cycle than cycling over 20% DOD. A common empirical form is:

$$f(\text{DOD}) = (\text{DOD})^\kappa \tag{7.14}$$

with $\kappa \approx 1.0$–2.0 depending on chemistry. This is the basis of the **rainflow-counting** approach to SOH estimation: each cycle is weighted by $\text{DOD}^\kappa$, and the weighted sum of cycle damage is tracked as a degradation accumulator.

### Combining Calendar and Cycle Aging

The total capacity fade over a cell's life is the combination of calendar and cycle degradation. The two contributions are not simply additive — there can be interactions (cycling accelerates calendar-type mechanisms by disrupting the SEI; calendar aging thickens the SEI and changes the charge-transfer kinetics that govern cycle aging). The simplest model that captures the interaction is a weighted sum:

$$Q_\text{loss,total}(t, N) = Q_\text{loss,cal}(t) + Q_\text{loss,cyc}(N) \tag{7.15}$$

where $t$ is the *total* elapsed time since the cell was built — resting or cycling, it does not matter — and $N$ is the number of equivalent full cycles accumulated over that time. The thing to notice is that the two terms run on different clocks but in the same frame: calendar aging is happening continuously, including during the hours the cell is cycling, because SEI growth is a chemical process that does not pause when current is flowing. The cycle-aging term captures the *additional* damage that cycling contributes on top of the baseline calendar contribution. This is why equation (7.15) is only an approximation — the two mechanisms are not perfectly separable because cycling disrupts the SEI passivation and thereby changes the calendar-aging rate itself, and at aggressive cycling conditions the two terms become coupled in ways that a simple sum cannot capture. For a rough engineering estimate it is nevertheless useful, and it is the starting point for most industry life-prediction models.

For the physics-based DFN model (Doyle–Fuller–Newman), calendar and cycle aging are not empirically parameterised but emerge from the mechanistic equations for SEI growth, particle cracking, and mechanical degradation — a more rigorous but computationally expensive approach that we will revisit in Chapter 13.

### A Worked Numerical Example: Estimating Calendar Life

Let us put numbers on a calendar-aging prediction for a commercial NMC/graphite cell. Rather than quoting parameter values from a specific paper and risking a unit mismatch, we will work with a clean phenomenological form calibrated to typical commercial-cell behaviour, and then compare the result to published field data.

Take the parabolic Arrhenius form from equation (7.12) and suppose we know, for this cell chemistry, that storage at a reference condition of 25 °C and 50% SOC produces 2.5% capacity loss after one year. This is a typical mid-range figure for well-designed NMC622/graphite cells and is consistent with datasheet calendar-life specifications. Take $E_a = 50\,\mathrm{kJ\,mol^{-1}}$, near the middle of the 40–80 kJ/mol range we quoted in §7.2.

From the reference point, we can back out $B(25^\circ\mathrm{C}, 50\%)$ directly: with $t = 365\,\mathrm{days}$ and $Q_{\mathrm{loss}} = 0.025$,
$$
B(25^\circ\mathrm{C}) = \frac{0.025}{\sqrt{365}} = \frac{0.025}{19.10} \approx 1.31 \times 10^{-3}\,\mathrm{day}^{-1/2}.
$$
We do not need to separately compute $B_0$; for predicting the cell's behaviour at other temperatures, we only need the ratio $B(T)/B(25^\circ\mathrm{C})$, which the Arrhenius form gives us cleanly:
$$
\frac{B(T)}{B(25^\circ\mathrm{C})} = \exp\left(\frac{E_a}{R}\left(\frac{1}{298\mathrm{K}} - \frac{1}{T}\right)\right).
$$

Now let us use this to answer three practical questions.

*How much capacity does the cell lose in one year at 35 °C?* The Arrhenius ratio is
$$
\exp\left(\frac{50000}{8.314}\left(\frac{1}{298} - \frac{1}{308}\right)\right) = \exp(0.655) \approx 1.93,
$$
so $B(35^\circ\mathrm{C}) \approx 2.53 \times 10^{-3}\,\mathrm{day}^{-1/2}$, and
$$
Q_{\mathrm{loss,cal}}(1\,\mathrm{year}, 35^\circ\mathrm{C}) \approx 2.53 \times 10^{-3} \cdot 19.10 \approx 4.8\%.
$$
Roughly double the 25 °C value, as expected from the rule of thumb.

*How long does it take this cell to reach end-of-life (80% of initial capacity, or 20% loss) from calendar aging alone at 25 °C?*
$$
\sqrt{t_{\mathrm{EOL}}} = \frac{0.20}{B(25^\circ\mathrm{C})} = \frac{0.20}{1.31 \times 10^{-3}} \approx 152.7\,\mathrm{day}^{1/2},
$$
$$
t_{\mathrm{EOL}} \approx 152.7^2 \approx 23{,}300\,\mathrm{days} \approx 64\,\mathrm{years}.
$$
This is a striking number, and it is worth pausing on. A well-designed NMC cell sitting in a cool climate at half-charge, never used, would last more than six decades before calendar aging alone took it to 80% capacity. This is consistent with laboratory calendar-aging studies, which routinely report fresh-cell behaviour extrapolating to decade-plus shelf lives at low temperature and moderate SOC. The *reason* we do not see 60-year field lifetimes is that real cells are not sitting quietly at 25 °C and 50% SOC — they are cycling, they are hot, they are at high or low SOC, and cycle-aging mechanisms are operating in parallel.

*And what if the same cell is stored at 45 °C instead of 25 °C?* The Arrhenius ratio becomes
$$
\exp\left(\frac{50000}{8.314}\left(\frac{1}{298} - \frac{1}{318}\right)\right) = \exp(1.268) \approx 3.55,
$$
so $B(45^\circ\mathrm{C}) \approx 4.66 \times 10^{-3}\,\mathrm{day}^{-1/2}$ and the time to 20% capacity loss collapses to
$$
t_{\mathrm{EOL}} \approx \left(\frac{0.20}{4.66 \times 10^{-3}}\right)^2 \approx 1{,}840\,\mathrm{days} \approx 5.0\,\mathrm{years}.
$$
Raising the storage temperature by 20 °C has cut the calendar life from 64 years to 5 years — a factor of about 13. This is the same Arrhenius factor we estimated in §7.2 (about $3.55^2 \approx 12.6$, since the rate constant enters twice through the $B(T)$ that sits inside $\sqrt{t}$), and it is the quantitative reason calendar aging is the concern it is for hot-climate deployments.

---

## Stressors: Temperature, SOC, DOD, C-Rate, Voltage Limits

Having identified the mechanisms and their models, we can now systematically examine the **stressors** — the operational and environmental variables that accelerate or decelerate each mechanism. This is the practical engineering summary of the chapter.

### Temperature

Temperature is the single most powerful lever in battery degradation, but its effects run in different directions for different mechanisms. The thermally-activated *chemical* mechanisms — SEI growth (Arrhenius, $E_a \approx 40$–80 kJ/mol), transition metal dissolution (Arrhenius, strong temperature dependence), and electrolyte oxidation — all accelerate with temperature. The *mechanical* mechanism of particle cracking goes the other way: higher temperature increases the solid-state diffusivity of lithium within the particle, so at a fixed C-rate the internal concentration gradients are shallower and the diffusion-induced stresses are smaller, which actually *reduces* per-cycle mechanical fatigue. So high temperature speeds up the chemistry and slows down the cracking, and low temperature does the reverse. This is one of the reasons why the combined temperature dependence of total cell aging can be non-monotonic in the sense that different failure modes dominate in different temperature regimes.

**High temperature** ($>35^\circ\mathrm{C}$) accelerates calendar aging (SEI growth, electrolyte decomposition) through Arrhenius kinetics, accelerates transition metal dissolution because HF generation increases with temperature, and increases the rate of electrolyte oxidation at the cathode. It does *not*, however, increase particle cracking — as just discussed, it tends to reduce it.

**Low temperature** ($<10^\circ\mathrm{C}$) does not accelerate thermally-activated mechanisms — calendar aging slows down significantly. However, low temperature dramatically reduces charge-transfer kinetics ($i_0$ decreases exponentially), increasing charge overpotential during fast charging and precipitating lithium or sodium plating even at moderate C-rates. Low-temperature cycle aging is dominated by plating-driven LLI rather than SEI-driven LLI.

**Temperature cycling** — non-uniform temperature distribution within a cell or pack (centre hotter than edges, for example) — creates regions of accelerated and decelerated aging within a single cell, leading to SOC and SOH heterogeneity over time. This pack-level non-uniformity is one of the motivations for thermal management system design in BMS (Chapter 9).

The **optimal storage temperature** for minimising calendar aging is as low as practical — 5–10 °C storage cuts calendar aging rate by 4–8× compared to room temperature while introducing no additional degradation mechanisms.

### State of Charge (SOC)

**High SOC** (>80%) accelerates calendar aging because the anode sits at a lower potential, producing a stronger driving force for SEI formation. It also increases cathode oxidative stress (cathode at higher potential, more susceptible to electrolyte oxidation and metal dissolution). In some chemistries (LCO, NMC at high Ni content), the cathode structure is less stable at high SOC — extended high-SOC storage can cause irreversible structural changes.

**Low SOC** (~10–20%, within the BMS voltage window) is generally *less* harmful for calendar aging than high SOC storage. The anode sits at a higher potential, which weakens the SEI-forming driving force (the exponential-in-$U_\text{anode}$ dependence of equation 7.4), and the cathode sits in a more lithiated and structurally relaxed state, reducing oxidative stress. Storing a cell at 10–20% SOC is slightly *better* for shelf life than storing it at 50% SOC, though the improvement is modest compared to the benefit of lowering storage temperature.

**Over-discharge** (*below* the BMS lower cutoff) is a completely different regime and should not be confused with low-SOC storage. If a cell is pushed past its rated lower voltage — for example, by a parasitic load left connected for weeks after the BMS has shut down, or by a fault that disables the BMS — the fully-delithiated graphite anode's potential rises toward the Cu/Cu²⁺ equilibrium potential around 3.4–3.5 V vs. Li/Li⁺. Copper dissolves from the anode current collector, enters the electrolyte, and can re-deposit at the positive electrode or grow into the separator, causing an internal short circuit during the next charge. Over-discharge damage is irreversible and is one of the principal reasons why every commercial LIB pack has a hard under-voltage lockout. The reader should treat "low SOC" and "over-discharge" as genuinely different stressors: the first is benign-to-beneficial, the second is catastrophic.

**Mid SOC** (30–60%) is optimal for calendar life storage. The anode is at a relatively high potential (modest SEI driving force) and the cathode is not severely stressed.

### Depth of Discharge

**DOD** directly controls the volume change of the electrode materials per cycle, and thus the mechanical fatigue load. A DOD of 100% puts the electrode particles through their full expansion-contraction cycle every time — maximum mechanical stress per cycle, maximum SEI disruption. A DOD of 20% (say, cycling between 40% and 60% SOC) uses only a fraction of the volume change and imposes much less mechanical fatigue.

The relationship between DOD and cycle life is often expressed empirically as:

$$N_\text{f}(\text{DOD}) = N_\text{f,100\%} \times \left(\frac{1}{\text{DOD}}\right)^\kappa \tag{7.16}$$

where $N_\text{f,100\%}$ is the cycle life at 100% DOD and $\kappa \approx 1.0$–2.0. For $\kappa = 1.5$ and a cell with 500 cycle life at 100% DOD:

$N_\text{f}(50\%\,\text{DOD}) = 500 \times (1/0.5)^{1.5} = 500 \times 2^{1.5} \approx 500 \times 2.83 \approx 1{,}410$ cycles.
$N_\text{f}(20\%\,\text{DOD}) = 500 \times (1/0.2)^{1.5} = 500 \times 5^{1.5} \approx 500 \times 11.18 \approx 5{,}590$ cycles.

The payoff for shallow cycling is dramatic. This is the quantitative basis for BMS strategies that intentionally limit the SOC operating window — not fully charging to 100% and not fully discharging to 0% — to extend pack life significantly.

### C-Rate

**High C-rate charging** is the primary trigger for lithium and sodium plating (Section 7.3). It also increases the magnitude of diffusion-induced stress in electrode particles (larger concentration gradients → larger stress → faster crack propagation). High C-rate discharging is somewhat less harmful: during discharge, the direction of lithium flux in the graphite is from the particle interior toward the surface, which generates compressive rather than tensile stress at the surface (cracks initiate under tension, so compressive surface stress is less damaging).

**Asymmetric C-rate management** — charging more slowly than discharging — is one of the strategies used in long-life BMS design. Allowing fast discharge (which EV drivers want for acceleration) while limiting charge rate (which is already limited by charging infrastructure speed in most cases) makes good electrochemical sense.

**Low C-rate cycling** (C/20, C/50) minimises all kinetically-driven degradation and is the closest approach to equilibrium cycling. Very slow cycling can be slightly more damaging for calendar-type mechanisms (the cell spends more time at each SOC), but the tradeoff is almost always favourable for long-life cycle testing.

### Voltage Limits

The upper and lower voltage cutoffs of the cell directly determine which degradation mechanisms are active.

**Upper voltage limit**: Raising the upper cutoff voltage (charging more deeply) extracts more capacity from the cathode but pushes the cathode into a more delithiated (more oxidised, less stable) state. For NMC811, each 100 mV increase in the upper cutoff voltage above 4.2 V approximately doubles the rate of capacity fade. The trade-off is clear: more energy per cycle vs. shorter cycle life. Some BMS algorithms adaptively lower the upper voltage limit as the cell ages (to preserve remaining life), while others maintain it to maximise energy delivery (accepting shorter remaining life). The "right" choice depends on the application.

**Lower voltage limit**: Lowering the cutoff extracts more capacity from the cell at the end of discharge. For graphite-anode LIBs, the lower limit is set to keep the anode potential below the threshold at which the copper current collector begins to dissolve. The Cu/Cu²⁺ equilibrium potential is approximately 3.4–3.5 V vs. Li/Li⁺, and when a graphite cell is deeply discharged the fully-delithiated anode potential rises toward this value; if the cell is pushed further (over-discharge, below about 2.5 V full cell for a typical NMC/graphite pairing), copper dissolves from the anode current collector, migrates through the electrolyte, and re-deposits at the positive electrode. Redeposited copper can eventually grow through the separator and cause an internal short. Over-discharge damage is an irreversible and severe failure pathway for any cell with a copper negative-electrode current collector, and all graphite-anode LIB BMS designs include a hard over-discharge lockout for exactly this reason.

For hard-carbon SIBs the copper dissolution concern does not apply, because SIBs use aluminium current collectors on both sides. Aluminium is stable across the full anodic window the hard-carbon anode can reach — this is, incidentally, one of the structural cost advantages of SIB construction we noted in Chapter 4, and it makes SIB cells inherently tolerant of deeper discharge than graphite/Cu LIBs. The lower voltage limit in an SIB is instead set by a combination of (1) maintaining hard-carbon SEI stability (very low cell voltage pushes the anode to potentials where the SEI can destabilise), (2) avoiding irreversible phase transitions in some cathode chemistries at low SOC (particularly relevant for certain P2-type layered oxides that undergo slab gliding when fully sodiated), and (3) preventing over-oxidation of the hard carbon surface at very positive anode potentials.

### Stressor Summary

|Stressor|Primary mechanisms driven|Relative impact|
|---|---|---|
|**High temperature** ($T > 35^\circ\mathrm{C}$)|SEI growth (Arrhenius), TM dissolution, electrolyte oxidation|Accelerates everything chemical; single most influential stressor|
|**High SOC during storage**|SEI growth (exponential in $U_\text{anode}$), cathode oxidation at top of charge|Dominant calendar-aging driver; controlled by storage SOC|
|**High DOD (deep cycling)**|Particle cracking, DIS, LAM|Dominant mechanical-fatigue driver; matters for full-swing cycling|
|**High C-rate (charge)**|Lithium plating, DIS, concentration gradients|Triggers plating at thresholds; damages aged cells disproportionately|
|**High C-rate (discharge)**|DIS (opposite sign), ohmic heating, concentration polarisation|Less damaging than high charge rate but still accelerates cracking|
|**High upper voltage limit**|Cathode TM dissolution, CEI growth, electrolyte oxidation|Small voltage increases produce large life reductions|
|**Low temperature operation**|Plating (via $R_\text{ct}$ rise), concentration polarisation|Dangerous only during charging; discharge is tolerated|

This table is the reference card for the rest of this chapter: if someone shows you a cycling protocol and asks what will kill the cell, run down the stressors in the left column, tick the ones present in the protocol, and the right two columns tell you what to expect.

---

## Worked Interpretation Exercise: Reading Birkl et al. (2017)

This section provides a guided reading of the key diagnostic framework from **Birkl, Roberts, McTurk, Bruce, and Howey, "Degradation diagnostics for lithium ion cells," *Journal of Power Sources* 341, 373–386 (2017)** — the primary source for this chapter's deliverable.

The paper's central contribution is a systematic framework connecting each degradation mechanism to specific signatures observable in non-invasive external measurements — exactly what you need to diagnose degradation without opening the cell. Here is a guided reading of the paper's key sections.

**Section 2 of Birkl et al. — the three degradation modes**: The paper defines the same three modes we have established in Section 7.1 (LLI, LAMpe, LAMne, CL). They call conductivity loss "conductivity loss" and distinguish positive electrode (PE) from negative electrode (NE) sources of LAM. Notice that they are explicit about what "loss of active material" means: it is not loss of the physical material from the cell but loss of its electrochemical participation — isolation from the electronic or ionic pathway.

**Section 3 — Half-cell model and simulated signatures**: This is the most valuable methodological section for your research. Birkl et al. use a half-cell model: they represent the full cell OCV as the superposition of the cathode OCV curve and the anode OCV curve, parameterised by the electrode stoichiometric windows. By mathematically shifting these windows to simulate LLI, LAMpe, and LAMne, they show how each mode distorts the full-cell OCV curve and $dQ/dV$ curve in a distinct and identifiable way.

The signatures are:

*LLI*: The capacity window of the full cell narrows symmetrically from both ends. The features (peaks) in the $dQ/dV$ curve shift but maintain their relative spacing. The total area under the $dQ/dV$ curve decreases proportionally to the LLI fraction. In the incremental capacity curve $dQ/dV$: peaks shift toward lower voltage on discharge and higher voltage on charge.

*LAMpe* (cathode active material loss): Certain peaks in the $dQ/dV$ curve decrease in height and area — specifically the peaks associated with cathode phase transitions. The peaks associated with anode transitions are relatively preserved. The cell's capacity is limited by the cathode. The shape of the upper portion of the OCV curve changes.

*LAMne* (anode active material loss): The peaks associated with anode staging transitions (the graphite staging peaks at ~3.6–3.7 V in an NMC/graphite cell) decrease in height and shift. The cell's capacity becomes limited by the anode. The lower portion of the discharge curve changes shape.

*CL*: Conductivity loss (impedance growth) does not affect the OCV curve or $dQ/dV$ curve measured under quasi-equilibrium conditions (very slow rate). However, it shows up as: increased voltage gap between charge and discharge curves at any non-zero current; increased DCIR in HPPC tests; enlarged semicircle(s) in EIS; reduced power capability and increased heat generation under load.

**The key diagnostic insight from Birkl et al.**: LLI and LAM are distinguishable from $dQ/dV$ analysis at low rate; CL is distinguishable from impedance measurements. All three can coexist and must be disentangled systematically. A cell with 20% capacity fade might have 15% LLI, 3% LAMne, 2% LAMpe, and significant CL — and the appropriate corrective strategy (electrolyte formulation change to reduce SEI, particle size reduction to reduce cracking, upper voltage limit reduction to reduce metal dissolution) depends on correctly identifying which component dominates.

**Which mechanisms are diagnosable from external measurements alone (answering the deliverable question)**:

*Diagnosable non-invasively*: LLI (from $dQ/dV$ peak shift and area reduction), LAMpe and LAMne separately (from $dQ/dV$ peak-specific changes), CL (from impedance measurements), lithium plating events (from the stripping plateau visible in the post-plating discharge curve), SEI growth (from Coulombic efficiency evolution and impedance growth).

*Not fully diagnosable non-invasively*: The physical origin of LAM (whether it is particle cracking, binder delamination, or loss of electronic contact) cannot be distinguished from electrochemical measurements alone — post-mortem microscopy is required. The spatial distribution of degradation within an electrode (whether degradation is uniform or concentrated near the separator or near the current collector) cannot be inferred from terminal measurements without a reference electrode. Electrolyte depletion vs. increased ionic resistance due to SEI thickening can be ambiguous in EIS without full spectrum fitting.

---

## What Changes for Sodium-Ion?

The three-mode framework (LLI, LAM, CL) applies equally to SIBs. The mechanisms within each mode are largely the same as for LIBs, but their relative importance and some specific features differ.

**SEI and LLI**: SEI growth on hard carbon drives LLI in SIBs just as on graphite in LIBs. The parabolic growth law and Arrhenius temperature dependence apply. However, the initial SEI on hard carbon is less stable (in carbonate electrolytes) and more heterogeneous than on graphite — early-life LLI may accumulate faster per cycle for SIBs. The transition to ether electrolytes or FEC-containing carbonate electrolytes significantly improves the stability of the hard carbon SEI and reduces per-cycle LLI.

**Sodium plating**: As noted in Section 7.3, sodium plating is less prone to dendrite formation than lithium plating, reducing the catastrophic short-circuit risk. However, dead sodium formation (from isolated plated metal) still contributes to LLI and is a degradation concern under fast charging at low temperature.

**Particle cracking**: Hard carbon is generally more crack-resistant than polycrystalline NMC secondary particles, because the amorphous structure has no grain boundaries. But the SIB *cathodes* can have the opposite problem. Sodium layered oxides come in two structural families — O3 and P2 — distinguished by the stacking of the oxygen layers around the sodium sites. During cycling, both families can undergo abrupt structural phase transitions: O3-type cathodes pass through intermediate O3 ↔ P3 transitions during desodiation, and P2-type cathodes undergo a **P2 ↔ O2 transition** at deep desodiation (high state of charge) in which the oxygen slabs glide past each other to accommodate the change in sodium content. The P2→O2 transition in particular involves a large unit-cell volume change and a shear-driven slab glide, and it is the single most disruptive mechanical process in the P2 cathode family. Repeated cycling through this transition causes intergranular fracture in polycrystalline P2 particles and is the dominant capacity-fade driver for P2-based SIBs cycled to high voltage. This is one of the reasons commercial P2 cells restrict their upper voltage cutoff more aggressively than their LIB analogues would suggest — the protection is not against electrolyte oxidation, as in LIB, but against triggering the P2→O2 phase transition.

**Transition metal dissolution**: The specific metals at risk differ by cathode chemistry. For iron-containing cathodes (NFPP, Prussian white), iron dissolution and crosstalk to the hard carbon anode is possible though iron deposits at the anode are less catalytically active than manganese or cobalt for SEI decomposition. Manganese dissolution from P2-NaMnO₂-based cathodes is a concern. For PBA cathodes, the zeolitic-water-driven framework collapse described in Section 7.5 is uniquely important.

**Flat OCV and diagnostic challenges**: The flat OCV plateau of hard carbon in the full cell complicates the $dQ/dV$ diagnostic approach. The graphite staging peaks that serve as sensitive diagnostic markers for LLI and LAMne in LIBs do not exist for hard carbon anodes — the hard carbon plateau produces a smooth, feature-poor $dQ/dV$ contribution. This means that $dQ/dV$-based degradation diagnosis for SIBs is less information-rich than for graphite-based LIBs. Alternative diagnostic signatures must be identified; Coulombic efficiency evolution and EIS may be relatively more important for SIB degradation diagnosis. This is an active research area.

---

## Chapter Summary

**Key ideas:**

- Three degradation modes organise all specific mechanisms: **Loss of Lithium/Sodium Inventory (LLI)** — reduced cyclable ion count; **Loss of Active Material (LAM)** — reduced accessible host capacity; **Conductivity Loss (CL)** — increased cell resistance. Every mechanism feeds one or more of these modes.
- **SEI growth** is the dominant calendar-aging mechanism in lithium-ion cells. The SEI layer thickness grows as $L_\text{SEI} \propto \sqrt{t}$ from diffusion-limited kinetics, and the resulting lithium inventory loss inherits the same time dependence: $Q_\text{loss,cal} \propto \sqrt{t}$ at fixed temperature. Temperature dependence is Arrhenius ($\sim 2\times$ per 10 °C); SOC dependence is exponential in anode potential. Calendar aging is minimised by cool storage at mid-SOC (30–50%).
- **Lithium/sodium plating** occurs when the local anode potential reaches 0 V vs. Li⁺/Li (Na⁺/Na). Triggered by high C-rate charging, low temperature, high SOC, or thickened SEI. Plated lithium forms dead lithium (LLI) and, in extreme cases, dendrites (safety hazard). Sodium plating is less dendrite-prone but still contributes to LLI.
- **Particle cracking** from diffusion-induced stress causes both LAM (electronic isolation of fragments) and LLI (new surface for SEI). Scales with C-rate, partial molar volume change, and particle size. Smaller particles below a critical radius are crack-resistant. Hard carbon is inherently more crack-resistant than polycrystalline oxide cathodes.
- **Transition metal dissolution** (Mn from LMO/NMC, Co from LCO, Fe from PBAs) is driven by HF attack and high-potential electrochemical oxidation. Dissolved metals migrate to the anode and catalytically decompose the SEI — the **crosstalk** mechanism. Temperature and high upper voltage limit accelerate dissolution.
- **Calendar aging** follows $Q_\text{loss,cal} \propto B(T,\text{SOC})\sqrt{t}$. **Cycle aging** follows empirical power-law models in cycle count, DOD, C-rate, and temperature. The two contributions are not fully separable because cycling disrupts the SEI passivation.
- **Stressors**: High temperature accelerates all thermally activated chemical mechanisms. High SOC (storage) accelerates calendar aging. High DOD accelerates mechanical fatigue. High C-rate charging triggers plating. High upper voltage limit triggers metal dissolution and cathode structural instability.
- External diagnostic signatures: LLI and LAM are revealed by $dQ/dV$ curve analysis; CL by impedance; plating by stripping plateau; SEI growth by Coulombic efficiency evolution. The physical origin of LAM requires post-mortem microscopy.

**Key equations:**

$$L_\text{SEI}(t) = L_0 + k_\text{SEI}\sqrt{t} \quad \text{(parabolic SEI growth law)} \tag{7.1}$$

$$k_\text{SEI}(T) = A\exp\!\left(-\frac{E_a}{RT}\right) \quad \text{(Arrhenius temperature dependence)} \tag{7.3}$$

$$\sigma_\text{max} \sim \frac{E\,\Omega\,\Delta c_\text{max}}{1-\nu} \quad \text{(diffusion-induced stress, scaling)} \tag{7.6}$$

$$Q_\text{loss,cal}(t,T) = B(T,\text{SOC})\sqrt{t}, \quad B(T) = B_0\exp\!\left(-\frac{E_a}{RT}\right) \quad \text{(calendar aging model)} \tag{7.12}$$

$$N_\text{f}(\text{DOD}) = N_\text{f,100\%} \left(\frac{1}{\text{DOD}}\right)^{\!\kappa} \quad \text{(cycle life vs.\ DOD)} \tag{7.16}$$

**Key vocabulary (in order of appearance):**

Loss of lithium/sodium inventory (LLI), loss of active material (LAM), conductivity loss (CL), N/P ratio, electrode slippage, lithium inventory drift, incremental capacity analysis (ICA), parabolic SEI growth law, Arrhenius activation energy for SEI, dead lithium/dead sodium, dendrite, diffusion-induced stress (DIS), intergranular cracking, single-crystal NMC, cathode–electrolyte interphase (CEI), transition metal dissolution, HF attack, Hunter mechanism, Mn³⁺ disproportionation, crosstalk, zeolitic water, gas generation, current interrupt device (CID), knee point, Wang model, rainflow counting, stressor, DOD–cycle life relationship, P2 ↔ O2 phase transition.

---

## Deliverable

**Task:** Read Birkl et al. (2017) "Degradation diagnostics for lithium ion cells" (*Journal of Power Sources* 341, 373–386) twice. Write a one-page summary in your own words identifying which mechanisms are diagnosable from external measurements alone.

**Guidance:** The paper is freely available via DOI: 10.1016/j.jpowsour.2016.09.105. On your first reading, focus on the overall framework (Sections 1–3) and absorb the three-mode classification and the concept of the half-cell model. On your second reading, go through Section 4 carefully: this is where specific diagnostic signatures are described for each mechanism.

Your one-page summary should be structured around the diagnostic question: for each mechanism listed in the paper, answer:

1. Which degradation mode does it primarily drive (LLI, LAMpe, LAMne, CL)?
2. What external measurement reveals it (OCV curve shape, $dQ/dV$, EIS, DCIR, Coulombic efficiency, visual inspection)?
3. What is the specific signature (e.g., "LLI shifts $dQ/dV$ peaks toward lower voltage on discharge and reduces peak area proportionally")?
4. Is the mechanism distinguishable from other mechanisms using only non-invasive measurements, or does disambiguation require post-mortem analysis?

**Partial worked answer for LLI to get you started:**

LLI drives capacity fade by reducing the amount of cyclable lithium. In the $dQ/dV$ curve, LLI causes all features to shift coherently toward lower voltage on discharge (and higher voltage on charge), while maintaining their relative positions with respect to each other. The total capacity (integral of $dQ/dV$) decreases. In the OCV curve, the accessible SOC window shrinks from both ends. LLI is diagnosable from external measurements alone. It cannot be confused with LAM (which causes specific peaks to shrink, not all peaks to shift) or CL (which does not affect the quasi-equilibrium $dQ/dV$ curve). However, the physical mechanism causing LLI (SEI growth vs. lithium plating vs. active dissolution) cannot be determined from $dQ/dV$ alone — additional experiments (Coulombic efficiency tracking to distinguish gradual vs. abrupt LLI, temperature dependence of capacity fade rate, or EIS to check for plating-related morphology changes) are needed to identify the cause.

**Structural hint:** The most useful form for this summary is a four-column table — one row per mechanism, columns for (1) primary mode, (2) external measurement, (3) specific signature, (4) diagnosable without post-mortem, yes/no. Write the prose version if you prefer, but also fill out the table. You will refer back to it when you start building your own degradation model in Chapter 13, and a table is much easier to consult than a page of prose.

---

## Further Reading

1. **Birkl, C. R. et al., "Degradation diagnostics for lithium ion cells," *Journal of Power Sources* 341, 373–386 (2017).** The primary source for this chapter's framework. The systematic connection of mechanisms to diagnostic signatures is the most practically useful degradation reference for researchers and engineers. Read this paper carefully as part of the chapter deliverable; it will reward re-reading several times.

2. **Vetter, J. et al., "Ageing mechanisms in lithium-ion batteries," *Journal of Power Sources* 147 (1–2), 269–281 (2005).** The older foundational review that Birkl et al. builds on. Covers the electrochemical and chemical processes underlying degradation from a materials perspective. Particularly strong on cathode degradation mechanisms (metal dissolution, structural changes) that Birkl et al. treats more briefly. Worth reading alongside Birkl for a complete picture.

3. **Reniers, J. M. et al., "Review and Performance Comparison of Mechanical-Chemical Degradation Models for Lithium-Ion Batteries," *Journal of the Electrochemical Society* 166 (14), A3189–A3200 (2019).** If you've ever wondered which of the half-dozen published SEI growth laws and particle-cracking laws actually fit real NMC data — and how much the coupling between them matters — this is the paper that puts them side by side. Essential if you're choosing between forms for your own physics-based degradation model.

4. **Dubarry, M. and Liaw, B. Y., "Identify capacity fading mechanism in a commercial LiFePO₄ cell," *Journal of Power Sources* 194 (1), 541–549 (2009).** The paper that took $dQ/dV$ analysis out of the academic lab and demonstrated it on a real commercial LFP/graphite cell, cleanly separating LLI, LAMpe, and LAMne as the cell aged. Read it immediately after Birkl — it will show you what applying the Birkl framework looks like in practice.

5. **Hein, S. et al., "Influence of Conductive Additives and Binder on the Impedance of Lithium-Ion Battery Cathodes: Theory and Experiment," *Journal of the Electrochemical Society* 167 (1), 013546 (2020).** A rigorous treatment of how electrode microstructure changes — specifically, the formation and evolution of the conductive carbon network during cycling — contribute to the CL degradation mode. Relevant for understanding impedance growth mechanisms that go beyond simple SEI resistance modelling.


\newpage

# Heat in Batteries

## Chapter Opening

Of all the ways a battery can fail, thermal failure is the most spectacular and the most feared. A lithium-ion cell in thermal runaway is not simply a dead battery — it is a self-sustaining exothermic reaction that can reach temperatures above 700°C, eject flaming electrolyte, and, in a pack environment, propagate from cell to cell in a cascade that is extremely difficult to arrest. The Boeing 787 grounding in 2013, the Samsung Galaxy Note 7 recall in 2016, the recurring fires in electric vehicle battery packs — all of these trace, at some level, to the thermal physics we are going to study in this chapter.

But thermal management in batteries is not only about preventing catastrophic events. Even under normal operating conditions, heat generation affects every performance metric we care about. Heat accelerates all the degradation mechanisms from Chapter 7. Temperature gradients within a cell cause non-uniform aging. Excess heat at high C-rate discharge reduces the available power (the terminal voltage sags further). Insufficient heat at low temperatures reduces rate capability and can trigger lithium plating. The thermal behaviour of a cell under its expected duty cycle is as important an engineering specification as its energy density or cycle life.

This chapter builds the quantitative framework for battery thermal analysis. We begin with the physics of heat generation — deriving the Bernardi equation from first principles, separating the irreversible and reversible contributions, and calculating real numbers for a commercial cell. We then examine how heat leaves a cell, introducing the thermal resistance network that governs temperature rise. We discuss the safe operating temperature window and the mechanisms that define its boundaries. We derive the conditions for thermal runaway from a stability analysis perspective, using an approach that will feel familiar from control theory. And we close with a quantitative comparison of SIB and LIB thermal safety — not the qualitative "SIB is safer" claim you will hear repeatedly, but a physical accounting of why it is safer and by how much.

By the end of this chapter, you will be able to take a cell datasheet, a duty cycle specification, and a cooling system design, and determine whether the cell will overheat, by how much, and where in the duty cycle the thermal limit is first reached. That is an engineering capability, not just physical understanding. In Chapter 9, we will scale this analysis from a single cell to a battery pack, where cell-to-cell variation and module-level thermal coupling introduce new challenges — but the single-cell thermal model you build here is the foundation for everything that follows.

---

> **Prerequisites Check**
>
> From your EE background:
> - Thermal resistance networks (analogous to electrical resistance networks — if you can calculate voltage across a resistor divider, you can calculate temperature rise in a thermal network)
> - Basic control system stability concepts (Section 8.5 uses a stability argument; familiarity with positive/negative feedback will help)
> - Power dissipation calculations ($P = I^2 R$, $P = IV$)
>
> From Chapter 1:
> - The Gibbs free energy–voltage relationship $\Delta G = -nFE$ (Section 1.8)
> - The temperature coefficient of cell voltage $(\partial E_\text{OCV}/\partial T)_P = \Delta S/(nF)$ (Section 1.8) — central to Section 8.2
>
> From Chapters 2 and 3:
> - The three overpotentials: ohmic, activation, concentration (Chapter 2, Section 2.7)
> - Internal resistance: ohmic and charge-transfer components (Chapter 3, Section 3.5)
>
> From Chapter 7:
> - The Arrhenius temperature dependence of degradation rates (Section 7.2) — directly relevant to Section 8.6
> - Thermal runaway as an endpoint of degradation (Section 7.3)

---

## Sources of Heat Generation: Ohmic, Polarisation, and Entropic

A battery generates heat during both charge and discharge. If your instinct from circuit design says "charging puts energy *in*, so the cell should cool down," you are thinking of the battery as a lossless energy store — a perfect capacitor. But a real battery is a lossy device: every current path has resistance, every electrode reaction has kinetic barriers, and every concentration gradient dissipates energy. These irreversible losses generate heat regardless of the direction of current, just as a resistor heats up whether current flows left-to-right or right-to-left. On top of these irreversible losses, there is a reversible entropic contribution that *can* make one direction (charge or discharge) slightly endothermic at certain states of charge — but the irreversible losses are always present. Understanding the three distinct sources of heat generation is the prerequisite for deriving the Bernardi equation in Section 8.2.

### Source 1: Irreversible Ohmic Heating

Every real current path has resistance. When current flows through a resistance, electrical energy is dissipated as heat at a rate $\dot{Q}_\text{ohm} = I^2 R_\Omega$, where $I$ is the current and $R_\Omega$ is the ohmic resistance. In a battery, the ohmic resistance includes the electrolyte ionic resistance, the electronic resistances of the electrode matrices and current collectors, and contact resistances at interfaces.

Ohmic heating has two important properties. First, it is always positive — $I^2 R_\Omega \geq 0$ regardless of the direction of current. Both charging and discharging produce ohmic heat. Second, it scales with the square of current, which means doubling the C-rate quadruples the ohmic heat generation rate. At high C-rates, ohmic heating dominates the total heat budget.

This is directly analogous to resistive heating in any electrical circuit — the same $I^2 R$ physics you use to calculate power dissipation in a power transistor applies inside a battery cell, just with the unusual feature that the "resistor" is distributed throughout the volume of the cell rather than being a discrete component.

### Source 2: Irreversible Polarisation Heating

Beyond the purely resistive ohmic component, there is additional irreversible heat generated by the overpotentials at the electrode surfaces — the activation and concentration polarisations we established in Chapter 2. These arise from the kinetic resistance of the electrode reactions (Butler-Volmer activation overpotential $\eta_\text{act}$) and from the concentration gradients that develop in the electrolyte and within electrode particles ($\eta_\text{conc}$).

The heat generated by polarisation is:

$$\dot{Q}_\text{pol} = I \cdot (\eta_\text{act} + \eta_\text{conc}) = I \cdot (V_\text{OCV} - V_\text{terminal} - IR_\Omega) \tag{8.1}$$

where we have subtracted the ohmic drop $IR_\Omega$ from the total voltage deviation $(V_\text{OCV} - V_\text{terminal})$ to isolate the non-ohmic contributions. Like ohmic heating, polarisation heating is always positive for both charge and discharge. The reason is the same as for a diode's forward voltage drop: the overpotential always opposes the current that drives it. During discharge, the current flows in the spontaneous direction, and the overpotential acts as a "voltage tax" that reduces the terminal voltage below OCV. During charge, the current is forced in the non-spontaneous direction, and the overpotential acts as an additional voltage burden that raises the required charging voltage above OCV. In both cases, the overpotential and the current have the same sign (both are defined relative to the direction that opposes equilibrium), so their product — the power dissipated as heat — is always positive. If you have seen the Butler-Volmer equation from Chapter 2, you can verify this: $\eta_\text{act}$ is positive when $I > 0$ (anodic) and negative when $I < 0$ (cathodic), so $I \cdot \eta_\text{act} > 0$ always.

At low-to-moderate C-rates, polarisation heating is comparable to or larger than ohmic heating, because the charge-transfer resistance $R_\text{ct}$ (which governs $\eta_\text{act}$) is typically comparable to or larger than $R_\Omega$ in a fresh cell, as we noted in Chapter 3. At very high C-rates, ohmic heating dominates because it scales as $I^2$ while polarisation heating grows more slowly (logarithmically in the Tafel regime of Butler-Volmer). At low temperatures, polarisation heating dominates because $R_\text{ct}$ increases exponentially with decreasing temperature while $R_\Omega$ increases much more modestly.

In practice, many engineering models combine ohmic and polarisation heating into a single irreversible term:

$$\dot{Q}_\text{irrev} = I \cdot (V_\text{OCV} - V_\text{terminal}) = I^2 R_\text{total} \tag{8.2}$$

where $R_\text{total} = (V_\text{OCV} - V_\text{terminal})/I$ is the apparent total internal resistance *at the operating current, SOC, and temperature*. A critical caveat for the EE reader: $R_\text{total}$ is not a fixed value like a resistor in your circuit schematic. It changes with current (because the activation overpotential is nonlinear — recall the Butler-Volmer equation), with SOC (because both OCV and kinetic parameters vary along the discharge curve), and with temperature (because $R_\text{ct}$ is strongly Arrhenius-dependent). Think of $R_\text{total}$ as a small-signal operating-point parameter, analogous to the dynamic resistance $r_d = dV/dI$ you would extract from the I-V curve of a diode at a specific bias point. This lumped approach is accurate for heat generation calculations at a given operating point, even though it loses the mechanistic separation between ohmic and polarisation components.

### Source 3: Reversible Entropic Heating

This is the heat source that surprises most engineers encountering battery thermal analysis for the first time. In Chapter 1 (Section 1.8), we derived the temperature coefficient of cell voltage:

$$\left(\frac{\partial E_\text{OCV}}{\partial T}\right)_P = \frac{\Delta S}{nF} \tag{8.3}$$

where $\Delta S$ is the entropy change of the cell reaction. This coefficient is not zero for most battery chemistries — the cell reaction involves entropy changes (ions moving from one crystal lattice environment to another, with different local order), and these entropy changes couple the cell's electrochemistry to heat exchange with the environment.

The reversible heat generation rate — the **entropic heat** — is:

$$\dot{Q}_\text{rev} = -I \cdot T \cdot \frac{\partial E_\text{OCV}}{\partial T} = -I \cdot T \cdot \frac{\Delta S}{nF} \tag{8.4}$$

where $T$ is the absolute temperature in Kelvin and $I$ is the current (positive for discharge by convention in many battery engineering texts). A positive $\dot{Q}_\text{rev}$ means the reversible component generates heat (releases it to the surroundings), and a negative $\dot{Q}_\text{rev}$ means the reversible component absorbs heat from the surroundings. The critical feature of this term is its sign: unlike the irreversible ohmic and polarisation terms (which are always positive heat sources), the entropic term can be positive or negative depending on the sign of $\partial E_\text{OCV}/\partial T$.

If $\partial E_\text{OCV}/\partial T > 0$ (the OCV increases with temperature), then $\Delta S > 0$ and $\dot{Q}_\text{rev} < 0$ — during discharge the cell absorbs heat from the environment. The reaction is endothermic with respect to the surroundings. For LFP/graphite full cells, the full-cell entropic coefficient $\partial E_\text{OCV}/\partial T$ — which is the difference between the cathode and anode half-cell coefficients — is positive over significant SOC ranges (roughly $+0.1$ to $+0.5$ mV/K, depending on SOC). In these ranges, the entropic term in the Bernardi equation is negative (the reaction absorbs heat), and at low C-rates the entropic cooling can be large enough to make the net heat generation during discharge nearly zero or even negative — the cell genuinely cools itself. This counterintuitive effect has been confirmed by calorimetric measurements and is one reason that LFP cells run cooler than their internal resistance alone would predict.

If $\partial E_\text{OCV}/\partial T < 0$, then $\Delta S < 0$ and $\dot{Q}_\text{rev} > 0$ — the entropic term adds to the irreversible heating during discharge. The sign and magnitude of $\partial E_\text{OCV}/\partial T$ depend strongly on SOC and vary by chemistry. For NMC cells, the entropic coefficient is negative over most of the high-SOC range, meaning the entropic heat adds to (rather than subtracts from) the irreversible heat during discharge in that range.

**Students sometimes assume the reversible term is negligible and ignore it.** In many engineering applications, the irreversible terms dominate and this approximation is reasonable. But for precision thermal modelling, low-rate cycling at extreme temperatures, or calorimetric measurements of cell thermodynamics, the reversible term matters. The GITT technique can be adapted to measure $\partial E_\text{OCV}/\partial T$ directly by performing OCV measurements at multiple temperatures — this is called **electrochemical entropy measurements** and is used to generate the full $\Delta S$-vs-SOC profile needed for Bernardi equation implementations.

**Relative magnitudes: a quick preview.** Before we formalise these three sources into the Bernardi equation, it helps to have a rough sense of their sizes. For a typical NMC/graphite 18650 cell (3 Ah, $R_\Omega \approx 20$ mΩ, $R_\text{ct} \approx 25$ mΩ) discharged at 1C (3 A) at 25°C and mid-SOC:

Ohmic: $I^2 R_\Omega = 9 \times 0.020 = 0.18$ W

Polarisation: $I^2 R_\text{ct} \approx 9 \times 0.025 = 0.23$ W (rough estimate treating activation overpotential as approximately linear at low current)

Entropic: $|IT(\partial E_\text{OCV}/\partial T)| \approx 3 \times 298 \times 0.0002 = 0.18$ W (can be positive or negative)

At 1C, all three contributions are comparable in magnitude — none is negligible. At higher C-rates, the ohmic term ($\propto I^2$) grows fastest. At lower temperatures, the polarisation term dominates as $R_\text{ct}$ grows exponentially. This is why the Bernardi equation retains all three terms: depending on the operating conditions, any one of them can dominate.

---

## The Bernardi Equation for Heat Generation

With the three heat sources established, we can now derive the **Bernardi equation** — the foundational quantitative model for total heat generation in a battery cell. This equation was published by Doris Bernardi, Erasmo Pawlikowski, and John Newman in 1985 in the *Journal of the Electrochemical Society* and remains the standard framework for battery thermal analysis.

### Derivation

We begin from the first law of thermodynamics applied to the battery as a thermodynamic system. For a system exchanging heat with the environment and doing electrical work:

$$\frac{dU}{dt} = \dot{Q}_\text{in} - \dot{W}_\text{elec} \tag{8.5}$$

where $U$ is the internal energy of the system, $\dot{Q}_\text{in}$ is the rate of heat flow into the system from the surroundings (positive = heat enters cell from environment), and $\dot{W}_\text{elec}$ is the rate of electrical work done by the system on the external circuit.

For a battery at constant pressure, the relevant thermodynamic potential is the **enthalpy** $H = U + PV$. Why switch from internal energy to enthalpy? Because at constant pressure, any volume change in the cell (from gas generation, electrode expansion, etc.) does $PdV$ work against the atmosphere, and the enthalpy automatically accounts for this. Taking the time derivative of $H = U + PV$ at constant $P$ gives $dH/dt = dU/dt + P\,dV/dt$. Substituting $dU/dt$ from Equation 8.5 and recognising that $P\,dV/dt$ is a small mechanical work term that we absorb into $\dot{W}_\text{elec}$, we get:

$$\frac{dH}{dt} = \dot{Q}_\text{in} - \dot{W}_\text{elec} \tag{8.6}$$

In practice, the $PdV$ contribution is negligible for rigid cylindrical and prismatic cells, so this is effectively the same as Equation 8.5 — but the enthalpy form is the thermodynamically clean starting point and will connect directly to the enthalpy of reaction in the next step.

The enthalpy change of the cell reaction is related to the standard cell enthalpy $\Delta H_\text{rxn}$ by the reaction rate. For a galvanic cell operating at current $I$ discharging at voltage $E$ (positive by convention), the system enthalpy changes as reactants convert to products:

$$\frac{dH}{dt} = \frac{I}{nF} \cdot \Delta H_\text{rxn} \tag{8.7}$$

where $I/nF$ gives the molar rate of reaction (mol/s) from Faraday's law, and $\Delta H_\text{rxn} = H_\text{products} - H_\text{reactants}$ for the cell reaction as written. Since the discharge reaction is exothermic for most batteries ($\Delta H_\text{rxn} < 0$), $dH/dt < 0$ — the system loses enthalpy during discharge, as expected.

The electrical work done per unit time is:

$$\dot{W}_\text{elec} = I \cdot E \tag{8.8}$$

where $E$ is the actual terminal voltage of the cell.

From thermodynamics, the enthalpy of reaction is related to Gibbs free energy and entropy by:

$$\Delta H_\text{rxn} = \Delta G_\text{rxn} + T \Delta S_\text{rxn} \tag{8.9}$$

Think of this as an energy accounting identity. The enthalpy change $\Delta H_\text{rxn}$ is the *total* energy released (or absorbed) by the reaction. Of this total, $\Delta G_\text{rxn}$ is the portion available to do useful work — in a battery, this is the electrical energy delivered to the external circuit. The remaining portion $T\Delta S_\text{rxn}$ is the energy exchanged with the thermal environment due to the entropy change of the reaction. If $\Delta S > 0$ (the products are more disordered than the reactants), the reaction absorbs heat from the surroundings to "pay" for the increased disorder. If $\Delta S < 0$, the reaction releases extra heat. This is exactly the entropic heat term we identified in Section 8.1 — we are now seeing where it comes from in the derivation.

And the Gibbs free energy is related to the open-circuit voltage:

$$\Delta G_\text{rxn} = -nF E_\text{OCV} \tag{8.10}$$

Substituting Equations (8.9) and (8.10) into Equation (8.7):

$$\frac{dH}{dt} = \frac{I}{nF}(-nF E_\text{OCV} + T\Delta S_\text{rxn}) = -I \cdot E_\text{OCV} + \frac{I \cdot T \cdot \Delta S_\text{rxn}}{nF} \tag{8.11}$$

Substituting into equation (8.6) and rearranging for $\dot{Q}_\text{in}$ (the heat flowing from environment into the cell, with sign convention that $\dot{Q}_\text{gen} = -\dot{Q}_\text{in}$ is the heat generated by the cell and released to the environment):

$$\dot{Q}_\text{gen} = I(E_\text{OCV} - E) - I \cdot T \cdot \frac{\partial E_\text{OCV}}{\partial T} \tag{8.12}$$

This is the **Bernardi equation**, in its most compact form. Let us parse each term:

The first term $I(E_\text{OCV} - E)$ is the **irreversible heat generation** — the product of current and the total voltage deviation from equilibrium. Since $E_\text{OCV} > E$ during discharge (the terminal voltage is below OCV) and $I > 0$ during discharge, this term is always positive. It encompasses both the ohmic ($I^2 R_\Omega$) and polarisation ($I\eta_\text{pol}$) contributions.

The second term $-IT(\partial E_\text{OCV}/\partial T)$ is the **reversible entropic heat** — it can be positive or negative depending on the sign of $\partial E_\text{OCV}/\partial T$, which varies with SOC and chemistry. When $\partial E_\text{OCV}/\partial T > 0$ ($\Delta S > 0$), this term is negative — the reaction absorbs heat, partially offsetting the irreversible losses. When $\partial E_\text{OCV}/\partial T < 0$ ($\Delta S < 0$), this term is positive — the reaction releases additional heat on top of the irreversible losses.

We can expand the irreversible term explicitly:

$$I(E_\text{OCV} - E) = I^2 R_\Omega + I\eta_\text{act} + I\eta_\text{conc} \tag{8.13}$$

giving the fully expanded Bernardi equation:

$$\boxed{\dot{Q}_\text{gen} = I^2 R_\Omega + I\eta_\text{act} + I\eta_\text{conc} - IT\frac{\partial E_\text{OCV}}{\partial T}} \tag{8.14}$$

### Physical Interpretation of Each Term

**$I^2 R_\Omega$**: Joule heating from ohmic resistance. Always positive. Scales quadratically with current. Dominant at high C-rates. Instantaneous — heat appears as soon as current flows, dissipated uniformly throughout the resistive elements.

**$I\eta_\text{act}$**: Activation (polarisation) heat. Always positive (product of current and overpotential of the same sign). Strongest at low temperatures where $R_\text{ct}$ is large. Concentrated at electrode-electrolyte interfaces.

**$I\eta_\text{conc}$**: Concentration polarisation heat. Always positive. Builds up during sustained high-current discharge as concentration gradients develop. Partially recoverable on rest (as gradients relax), so this contribution drops if current is interrupted.

**$-IT(\partial E_\text{OCV}/\partial T)$**: Entropic heat. Can be positive or negative depending on the sign of $\partial E_\text{OCV}/\partial T$. Spatially distributed throughout the electrode materials (it is a bulk thermodynamic property of the intercalation reactions, not an interface phenomenon). When $\partial E_\text{OCV}/\partial T > 0$ ($\Delta S > 0$), the entropic term is negative — the reaction absorbs heat from the environment, acting as a genuine heat sink that partially offsets the irreversible terms. This is the case for LFP/graphite cells over significant SOC ranges during discharge. When $\partial E_\text{OCV}/\partial T < 0$ ($\Delta S < 0$), the entropic term is positive — the reaction releases additional heat beyond the irreversible losses. For NMC/graphite cells, $\partial E_\text{OCV}/\partial T$ changes sign with SOC, and the entropic contribution can either add to or subtract from the total depending on the operating point.

### A Simplified Engineering Form

For most engineering calculations, the activation and concentration overpotentials are lumped into an effective resistance $R_\text{pol} = (E_\text{OCV} - E - IR_\Omega)/I$, and the Bernardi equation is written as:

$$\dot{Q}_\text{gen} = I^2 R_\text{int} - IT\frac{\partial E_\text{OCV}}{\partial T} \tag{8.15}$$

where $R_\text{int}$ is the total apparent internal resistance at the operating current. This form is directly usable with HPPC test data (which gives $R_\text{int}$ as a function of SOC and temperature) and is the standard form used in BMS thermal models and in the thermal management literature.

---

## Heat Transfer Out of a Cell: Thermal Resistance and Time Constants

Generating heat is one side of the thermal problem. The other side is removing it. A cell's temperature rise is determined not just by how fast heat is generated but by how fast heat can escape to the environment through the thermal resistance of the cell and its surroundings.

### The Thermal Resistance Network

The analogy between thermal and electrical circuits is exact for linear steady-state problems, and you can exploit everything you know about resistor networks. The mapping is: temperature $T$ plays the role of voltage $V$; heat flow rate $\dot{Q}$ (watts) plays the role of current $I$ (amps); thermal resistance $R_\text{th}$ (K/W) plays the role of electrical resistance $R$ (Ω); and thermal capacitance $C_\text{th} = mc_p$ (J/K) plays the role of electrical capacitance $C$ (farads). Ohm's law becomes:

$$\Delta T_\text{ss} = \dot{Q}_\text{gen} \cdot R_\text{th} \tag{8.16}$$

where $\dot{Q}_\text{gen}$ is the heat generation rate (watts) and $R_\text{th}$ is the thermal resistance (K/W or °C/W) between the heat source and the heat sink (ambient temperature). Series and parallel combinations work identically: two thermal resistances in series (e.g., conduction through the jelly roll *then* convection from the surface) add directly, just as series resistors do. Two thermal resistances in parallel (e.g., convection from the cylindrical surface *and* conduction through the tabs) combine as $1/R_\text{parallel} = 1/R_1 + 1/R_2$, just as parallel resistors do. And when we add the thermal capacitance below, we will get an RC time constant that governs transient response — exactly as you would expect.

For a cylindrical cell, the thermal resistance from cell centre to cell surface is dominated by conduction through the jelly roll. The thermal conductivity of the wound electrode stack is anisotropic: in the radial direction (perpendicular to the wound layers), heat must cross many layer interfaces, and the effective radial thermal conductivity $k_r$ is approximately 0.2–0.5 W/m·K — dominated by the separator and electrolyte, which are poor thermal conductors. In the axial direction (along the winding axis), heat can conduct along the current collector foils, giving an effective axial conductivity $k_z$ of approximately 20–40 W/m·K.

For a hollow cylinder conducting heat from the inner surface to the outer surface (no internal heat generation), the radial thermal resistance is:

$$R_\text{th,radial,hollow} = \frac{\ln(r/r_0)}{2\pi k_r h} \tag{8.17}$$

where $r_0$ is the inner radius and $r$ is the outer radius. But Equation 8.17 is *not* what we need here. A jelly roll does not have a hot inner surface and a cold outer surface with no heat sources in between — it generates heat *throughout its volume* (every layer of electrode and electrolyte contributes ohmic and polarisation heat). The correct model is a solid cylinder with uniform volumetric heat generation, for which the thermal resistance from the peak temperature (at the centre) to the outer surface is:

$$R_\text{th,radial} \approx \frac{1}{4\pi k_r h} \tag{8.18}$$

This can be derived by solving the radial heat equation $k_r \nabla^2 T + q''' = 0$ in cylindrical coordinates with uniform volumetric source $q'''$ and a fixed surface temperature — the result is $\Delta T_\text{max} = q''' r^2/(4k_r)$, which, after dividing by the total heat generation $\dot{Q} = q''' \pi r^2 h$, gives Equation 8.18. Notice that this result is independent of $r$ — the thermal resistance depends only on the thermal conductivity and the cylinder height. We mentioned Equation 8.17 so you can recognise it in the literature (it appears in some thermal models that treat the jelly roll as a hollow annulus), but Equation 8.18 is the correct starting point for uniform-heat-generation problems.

For an 18650 cell ($r = 9$ mm, $h = 65$ mm, $k_r = 0.3$ W/m·K):

$$R_\text{th,radial} \approx \frac{1}{4\pi \times 0.3 \times 0.065} = \frac{1}{0.245} \approx 4.1 \text{ K/W}$$

From the cell surface to the ambient, there is a convective thermal resistance:

$$R_\text{th,conv} = \frac{1}{h_c A_\text{surface}} \tag{8.19}$$

where $h_c$ is the convective heat transfer coefficient (W/m²·K) and $A_\text{surface}$ is the external surface area. For natural convection in air, $h_c \approx 5$–20 W/m²·K; for forced air cooling, $h_c \approx 20$–100 W/m²·K; for liquid cooling (direct contact or via a cooling plate), $h_c \approx 200$–2000 W/m²·K.

For the 18650 cell with natural convection ($h_c = 10$ W/m²·K, $A = 2\pi r h + 2\pi r^2 = 2\pi(0.9)(6.5) + 2\pi(0.9)^2 \approx 36.8 + 5.1 = 41.9 \text{ cm}^2 = 4.19 \times 10^{-3} \text{ m}^2$):

$$R_\text{th,conv} = \frac{1}{10 \times 4.19 \times 10^{-3}} = \frac{1}{0.0419} \approx 23.9 \text{ K/W}$$

The total thermal resistance from cell centre to ambient is:

$$R_\text{th,total} = R_\text{th,radial} + R_\text{th,conv} \approx 4.1 + 23.9 = 28.0 \text{ K/W}$$

In this case, the convective resistance dominates — the cell surface temperature is a poor indicator of the cell's internal core temperature, and improving the convective cooling (increasing $h_c$ with forced air or liquid cooling) has a larger impact than trying to improve the jelly roll's internal thermal conductivity.

### Thermal Time Constants

Just as an RC circuit has a time constant $\tau = RC$ that governs how quickly it responds to perturbations, a battery cell has a **thermal time constant**:

$$\tau_\text{th} = m c_p R_\text{th} \tag{8.20}$$

where $m$ is the cell mass (kg), $c_p$ is the specific heat capacity of the cell (J/kg·K, typically 800–1100 J/kg·K for lithium-ion cells), and $R_\text{th}$ is the thermal resistance. For our 18650 cell ($m \approx 46$ g $= 0.046$ kg, $c_p = 900$ J/kg·K, $R_\text{th} = 28.0$ K/W):

$$\tau_\text{th} = 0.046 \times 900 \times 28.0 \approx 1{,}159 \text{ s} \approx 19 \text{ min}$$

This thermal time constant tells us that after a change in heat generation rate (say, the cell begins discharging at 1C), the cell temperature will rise toward its new steady-state value with a characteristic time of about 19 minutes. If the discharge lasts only a few minutes (as in an electric vehicle acceleration event), the cell never reaches steady state — the transient temperature rise is much smaller than $\dot{Q}_\text{gen} \times R_\text{th}$. If the discharge lasts much longer than $\tau_\text{th}$ (grid storage cycling), the cell reaches thermal equilibrium with its cooling environment.

The thermal time constant is also critical for safety analysis: a cell with a long $\tau_\text{th}$ accumulates heat slowly during a short high-power event, while a cell with a short $\tau_\text{th}$ (low thermal mass relative to its cooling capacity) responds quickly and stays closer to ambient temperature. Designing the cooling system to achieve $\tau_\text{th}$ appropriate for the duty cycle is a central task of thermal management system (TMS) engineering.

**The transient temperature response.** The RC analogy gives us the full transient solution directly. For a cell initially at ambient temperature $T_\text{amb}$ that begins generating heat at a constant rate $\dot{Q}_\text{gen}$ at $t = 0$:

$$T(t) = T_\text{amb} + \dot{Q}_\text{gen} \cdot R_\text{th} \left(1 - e^{-t/\tau_\text{th}}\right) \tag{8.20b}$$

This is exactly the voltage across a capacitor being charged through a resistor by a constant current source — you have seen this waveform hundreds of times. At $t = \tau_\text{th}$, the cell has reached 63% of its steady-state temperature rise. At $t = 3\tau_\text{th}$ (~57 minutes for our 18650 example), the cell is within 5% of steady state.

This transient matters for real duty cycles. Consider an EV acceleration event lasting 30 seconds at 5C (well below $\tau_\text{th} \approx 19$ min): the temperature rise is only $\Delta T \approx \dot{Q}_\text{gen} \cdot R_\text{th} \cdot (30/1159) \approx 2.6\%$ of the steady-state value — negligible. But a 1-hour grid storage discharge at 1C ($t \gg \tau_\text{th}$) reaches full steady-state temperature. The thermal time constant is what separates "power events" (short, thermally benign) from "energy events" (long, thermally significant).

---

## Safe Operating Windows and Why They Exist

Every commercial cell has a specified safe operating temperature range: typically −20°C to +60°C for discharge and 0°C to +45°C for charge (with variations by chemistry). These are not arbitrary marketing specifications — they are boundary conditions enforced by specific physical processes that become dangerous or irreversible outside the specified limits.

### Upper Temperature Limit: Onset of Dangerous Reactions

As cell temperature rises above the normal operating range, a sequence of thermally activated side reactions begins. These reactions are exothermic — they generate heat — creating the possibility of positive feedback: heat generates more heat, temperatures rise, and the cell enters thermal runaway. The upper safe operating limit is set to maintain a sufficient margin below the onset temperatures of these reactions.

The key reactions, in order of onset temperature for a typical lithium-ion cell, are:

**SEI decomposition (~80–120°C)**: The metastable organic components of the SEI (lithium alkyl carbonates, polymeric species) begin to decompose at temperatures above approximately 80–100°C. This decomposition releases heat and, importantly, exposes fresh graphite surface that can react directly with the electrolyte. The heat of SEI decomposition is typically 200–500 J/g of anode material, enough to raise the anode temperature by several degrees — a small but non-zero contribution that initiates the cascade.

**Separator melting (~130–160°C for polyethylene, ~165°C for polypropylene)**: The microporous polyolefin separator begins to soften and melt at its melting point. Melting can close the pores ("shutdown"), which stops ionic conduction and terminates the electrochemical reactions — this is actually a safety feature of PE separators. However, if the temperature continues to rise after shutdown (e.g., due to external heating or internal exothermic reactions already in progress), the separator can shrink and rupture, bringing the electrodes into direct contact.

**Electrolyte decomposition (~150–200°C)**: The organic electrolyte decomposes exothermically and can vaporise, generating pressure.

**Cathode decomposition and oxygen release (~170–250°C, depending on chemistry)**: Delithiated layered oxide cathodes release oxygen when thermally destabilised. The oxygen reacts with the flammable electrolyte in a highly exothermic combustion reaction — this is the dominant heat source in advanced thermal runaway. The onset temperature for oxygen release varies strongly by chemistry: ~170–200°C for LCO (lower at extreme delithiation states), ~180°C for NMC811, ~200°C for NMC622, ~260°C for NMC111, and >400°C for LFP. This hierarchy is why LFP cells are dramatically safer than NMC and NCA cells at the thermal abuse level.

**Anode-electrolyte reaction (~250–300°C)**: Metallic lithium (from the SEI and from any plated lithium) reacts exothermically with the electrolyte. In cells that have undergone lithium plating, this reaction initiates at lower temperatures.

The upper temperature limit of 60°C in discharge is set to provide a margin below the SEI decomposition onset (~80–100°C), accounting for the temperature rise from the cell's internal heat generation at maximum C-rate. The lower the cell's internal resistance and the better the cooling, the smaller this margin needs to be — well-cooled automotive cells with liquid cooling can safely sustain operation up to ambient temperatures of 45–50°C.

### Lower Temperature Limit: Plating and Kinetic Failure

As temperature decreases, the primary risk (during charging) is **lithium plating**, as established in Chapter 7. The lower charging temperature limit of 0°C is set because, below this temperature, the charge-transfer kinetics are sufficiently sluggish that even at moderate C-rates, the overpotential during charging is large enough to drive the graphite anode potential to 0 V vs. Li/Li⁺. Why does 0 V matter? Because 0 V vs. Li/Li⁺ is, by definition, the potential at which metallic lithium is thermodynamically stable. If the graphite anode potential drops *below* this threshold during charging (which is possible when large overpotentials are present), it becomes energetically favourable for lithium ions to deposit as metallic lithium on the graphite surface rather than intercalating into the graphite lattice. This metallic lithium deposition is **lithium plating** — the process we discussed in Chapter 7 (Section 7.3) as a major safety and degradation hazard.

This limit is chemistry and rate-dependent: at very low C-rates (C/20 or lower), charging at sub-zero temperatures is sometimes permissible because the overpotentials are small. At higher C-rates, the limit is more stringent. Some manufacturers specify different lower charging limits for different C-rates in their datasheet.

For sodium-ion cells with hard carbon anodes, the lower charging temperature limit is generally more relaxed — approximately −10°C to −20°C is sometimes specified — because hard carbon's charge-transfer kinetics are less severely affected by temperature than graphite's (different activation energy for the desolvation process), and because the plateau region of hard carbon is less prone to plating than graphite's tight staging transitions.

The lower discharge temperature limit (typically −20°C for most LIBs) is set by kinetic performance rather than by a safety reaction: below this temperature, the charge-transfer resistance is so high that the cell cannot deliver useful power without the terminal voltage dropping below the cutoff. It is a performance limit, not a safety limit, for discharge.

---

## Thermal Runaway: Triggers, Stages, and Propagation

**Thermal runaway** is the most consequential failure mode in battery systems and the one that drives the strictest safety design requirements. It is defined as a self-sustaining, accelerating exothermic process in which heat generation exceeds heat dissipation, causing temperature to rise without bound until the cell is destroyed.

### The Thermal Stability Analysis

The condition for thermal runaway can be stated precisely using a stability argument analogous to the analysis of unstable operating points in control theory. Consider the energy balance for a cell at temperature $T$ in an environment at temperature $T_\text{amb}$:

$$mc_p \frac{dT}{dt} = \dot{Q}_\text{gen}(T) - \dot{Q}_\text{cool}(T) \tag{8.21}$$

where $\dot{Q}_\text{gen}(T)$ is the total heat generation rate at temperature $T$ (including all electrochemical and chemical reactions) and $\dot{Q}_\text{cool}(T) = (T - T_\text{amb})/R_\text{th}$ is the rate of heat removal by the cooling system.

A stable thermal equilibrium exists when $\dot{Q}_\text{gen} = \dot{Q}_\text{cool}$ and the slope condition $d\dot{Q}_\text{gen}/dT < d\dot{Q}_\text{cool}/dT$ is satisfied. In other words: the cooling curve must be steeper than the heat generation curve at the equilibrium point. If the heat generation rate increases faster with temperature than the cooling can compensate, the equilibrium is unstable — the operating point is on the wrong side of the stability threshold.

The critical insight is the exponential temperature dependence of the exothermic chemical reactions (Arrhenius). The electrochemical heat generation ($\dot{Q}_\text{irrev} = I^2 R_\text{int}$) grows only linearly with temperature (through the mild temperature dependence of $R_\text{int}$). But the chemical heat generation from SEI decomposition, electrolyte combustion, and cathode oxygen release grows exponentially:

$$\dot{Q}_\text{chem}(T) \sim A_k \exp\!\left(-\frac{E_{a,k}}{RT}\right) \tag{8.22}$$

At temperatures below the onset of dangerous reactions, $\dot{Q}_\text{chem}$ is negligible, the total heat generation is dominated by the electrochemical component, and the cell operates in the stable regime. As temperature rises toward the onset of SEI decomposition, $\dot{Q}_\text{chem}$ begins to grow exponentially. If $\dot{Q}_\text{chem}$ grows faster than the cooling can remove heat, the equilibrium becomes unstable — thermal runaway has been triggered.

Graphically, this is the classic **Semenov diagram** from combustion theory, and it is worth sketching:

**[Figure 8.1 — Semenov Diagram for Battery Thermal Stability]**

*Axes:* Horizontal axis is cell temperature $T$ (K), ranging from ambient ($T_\text{amb}$) to well above the thermal runaway region. Vertical axis is heat rate (W).

*Curve 1 — Heat generation $\dot{Q}_\text{gen}(T)$:* At low temperatures (near $T_\text{amb}$), this curve is nearly flat — only electrochemical irreversible heat, which varies mildly with temperature. As temperature approaches ~80–100°C, the curve begins to rise as SEI decomposition adds an exponential Arrhenius component. Above ~150°C, cathode decomposition and electrolyte combustion cause the curve to shoot upward steeply. The overall shape is a lazy S that becomes exponential.

*Curve 2 — Heat removal $\dot{Q}_\text{cool}(T) = (T - T_\text{amb})/R_\text{th}$:* A straight line starting at the origin (zero heat removal at $T = T_\text{amb}$) and rising with slope $1/R_\text{th}$.

*Intersections:* The two curves cross at two points. The lower intersection ($T_\text{eq}$, typically 30–50°C for a cell at moderate C-rate) is a *stable* equilibrium: if the cell is perturbed slightly hotter, cooling exceeds generation and the cell returns to $T_\text{eq}$. The upper intersection ($T_c$, the *critical temperature*) is *unstable*: above this point, generation exceeds cooling and temperature accelerates upward — thermal runaway. Between the two intersections, cooling still exceeds generation, so the cell would recover if perturbed.

*Key insight for the EE reader:* This is precisely the same stability analysis you would apply to a BJT with thermal feedback. A power transistor's dissipation increases with temperature (positive thermal coefficient of $I_C$), while its heatsink removes heat linearly. If the dissipation curve crosses the cooling line twice, the lower crossing is the safe operating point and the upper crossing is the thermal runaway point — identical physics, different device.

**The loop-gain formulation.** If you prefer control-theory language, thermal runaway is simply the condition where the thermal feedback loop gain exceeds unity. Define the incremental thermal gain as:

$$G_\text{th} = R_\text{th} \cdot \frac{d\dot{Q}_\text{gen}}{dT} \tag{8.22b}$$

The cooling system provides a "restoring force" with slope $d\dot{Q}_\text{cool}/dT = 1/R_\text{th}$. At the stable operating point, $d\dot{Q}_\text{gen}/dT < 1/R_\text{th}$, which means $G_\text{th} < 1$ — the loop is stable, and perturbations are damped. At the critical temperature $T_c$, $d\dot{Q}_\text{gen}/dT = 1/R_\text{th}$, giving $G_\text{th} = 1$ — the system is marginally stable. Above $T_c$, $G_\text{th} > 1$, and the positive feedback drives temperature upward without bound.

This formulation makes the design levers obvious: you can prevent thermal runaway by reducing $R_\text{th}$ (better cooling, which raises the threshold for $G_\text{th} = 1$) or by reducing $d\dot{Q}_\text{gen}/dT$ (choosing a chemistry with higher-temperature onset of exothermic reactions, which pushes the exponential upturn to higher $T$). LFP and NVPF cathodes achieve the latter; liquid cooling achieves the former. The safest designs do both.

The thermal runaway onset temperature (also called the **self-heating onset temperature** $T_\text{onset}$) depends strongly on chemistry and SOC. For a fully charged NMC811/graphite cell, $T_\text{onset}$ can be as low as 55–65°C (in an adiabatic calorimeter measuring only the self-heating component at a 0.02°C/min detection threshold). For LFP/graphite, $T_\text{onset}$ is typically >150–170°C. This 90–110°C difference in self-heating onset temperature is why LFP cells can sometimes survive conditions (external fires, crush) that destroy NMC cells.

### The Three Stages of Thermal Runaway

Thermal runaway in a lithium-ion cell proceeds through a recognisable sequence of stages, well documented through accelerating rate calorimetry (ARC) studies. The three stages are not independent events that happen to occur in sequence — they form a causal cascade in which each stage creates the conditions that trigger the next. Understanding this cascade is essential for designing intervention strategies: if you can interrupt the chain at Stage 1, Stage 3 never occurs. Here is the sequence:

**Stage 1 — Self-heating (~80–120°C)**: SEI decomposition begins. The cell self-heats at a rate of approximately 0.02–0.1°C/min. Gas is generated (CO₂, CO) from the organic SEI components. At this stage, the process is still potentially recoverable if external cooling is applied or the cell is removed from the environment. But if it is not arrested, the heat from SEI decomposition raises the cell temperature into the range where the next set of reactions begins — Stage 2.

**Stage 2 — Thermal acceleration (~120–180°C)**: The separator begins to soften. Separator shutdown (pore melting) may temporarily slow the reaction. Electrolyte begins to decompose. The anode reacts with the electrolyte. Heat generation accelerates to 1–10°C/min. The process is generally no longer reversible at this point. Critically, the loss of separator integrity (either through shutdown-and-rupture or through direct melting) removes the last physical barrier between the reactive anode and cathode, and the heat generated has raised the temperature to the onset of cathode decomposition — triggering Stage 3.

**Stage 3 — Thermal runaway (~180–700°C)**: Cathode decomposition begins releasing oxygen. The released oxygen reacts combustively with the electrolyte vapour in the oxygen-enriched environment inside the cell. The reaction can initiate at temperatures as low as 150–200°C in this oxygen-rich environment — far below the standard autoignition temperature of organic electrolyte solvents in air (~440–465°C for EC and linear carbonates) — because the locally high oxygen concentration dramatically lowers the ignition threshold. Heat generation rate reaches hundreds to thousands of degrees per minute. The cell vents — electrolyte vapour, hot gases, and molten material are ejected through the safety vent. Internal pressure spikes. In the worst case, the cell ruptures explosively. Temperature at the cell surface can reach 600–800°C for NMC/NCA cells.

The total heat released during thermal runaway for an NMC811/graphite 18650 cell is approximately 25–40 kJ — comparable to the stored electrical energy in the cell (~11–14 Wh = 40–50 kJ for a 3 Ah cell at 3.7 V). This is why a battery fire is so energetic: the total heat release comes not only from electrolyte combustion (which contributes perhaps 10–15 kJ for an 18650 cell) but also from cathode decomposition releasing oxygen (which then reacts with electrolyte and solvents), anode-electrolyte reactions, and SEI decomposition. The total chemical enthalpy available from these decomposition pathways happens to be comparable to the stored electrochemical energy of the cell, but the two are not the same — the heat released during thermal runaway comes from *decomposition chemistry*, not from the normal cell reaction running uncontrolled.

### Thermal Runaway Propagation

In a battery pack, thermal runaway in one cell can spread to neighbouring cells through three pathways:

**Heat conduction**: Direct thermal contact between cells conducts heat from the hot cell to its neighbours. If the heat flow rate exceeds the neighbours' thermal runaway onset threshold, they too enter runaway. This is the dominant propagation mechanism in tightly packed cylindrical cell modules.

**Radiation**: Hot cells radiate infrared energy to neighbouring cells. At the surface temperatures reached during thermal runaway (~600–800°C), radiation is very significant (blackbody radiation scales as $T^4$).

**Gas venting**: The hot gases and electrolyte vapour ejected during cell venting can ignite neighbouring cells or their electrolyte vapour if the gas temperature exceeds the autoignition temperature. This is often the fastest propagation pathway in pouch cell modules.

Preventing thermal propagation — ensuring that runaway in one cell does not cascade to the entire pack — is a primary design objective for battery module and pack engineers. Strategies include: thermal barriers (ceramic tiles, intumescent foam) between cells; gas venting pathways designed to direct ejecta away from neighbouring cells; fire-suppression systems integrated into the pack; and thermal runaway detection algorithms in the BMS that trigger cooling and isolation before propagation occurs.

---

## Why Low Temperature Hurts Performance and High Temperature Accelerates Aging

We have now covered the extremes — thermal runaway at high temperature and plating at low temperature. But the thermal effects on normal battery performance and aging are equally important for everyday engineering, and they connect directly to the physical models established in Chapters 2, 3, and 7.

### Low Temperature: The Kinetic Trap

At low temperatures, the primary effect is the exponential increase in charge-transfer resistance $R_\text{ct}$. Recall from Chapter 2 that $R_\text{ct}$ is inversely proportional to the exchange current density $i_0$, which governs the rate of the electrode reaction at equilibrium. Like any chemical reaction rate, $i_0$ follows Arrhenius behaviour: it depends exponentially on temperature because the ions must overcome an energy barrier (the **activation energy** $E_{a,\text{ct}}$) to transfer between the electrolyte and the electrode lattice. The rate-limiting step is typically the desolvation of the ion — stripping the solvent molecules that surround the Li⁺ or Na⁺ ion before it can enter the electrode. Since $R_\text{ct} \propto 1/i_0$, a decrease in $i_0$ at low temperature translates directly to an increase in $R_\text{ct}$:

$$R_\text{ct}(T) = R_\text{ct}(T_0) \cdot \exp\!\left[\frac{E_{a,\text{ct}}}{R}\left(\frac{1}{T} - \frac{1}{T_0}\right)\right] \tag{8.23}$$

where $R = 8.314$ J/(mol·K) is the universal gas constant (not to be confused with resistance — an unfortunate notational collision), $T_0$ is a reference temperature (typically 298 K), and $E_{a,\text{ct}}$ is the activation energy for the charge-transfer process.

For typical graphite/LiPF₆ cells, the activation energy for charge transfer $E_{a,\text{ct}} \approx 30$–60 kJ/mol. Let us walk through the arithmetic step by step at $T = 253$ K (−20°C) versus $T_0 = 298$ K (25°C), since this type of Arrhenius calculation will recur throughout your battery career:

$$\frac{1}{T} - \frac{1}{T_0} = \frac{1}{253} - \frac{1}{298} = 0.003953 - 0.003356 = 5.97 \times 10^{-4} \text{ K}^{-1}$$

$$\frac{E_a}{R} = \frac{50{,}000 \text{ J/mol}}{8.314 \text{ J/(mol·K)}} = 6{,}014 \text{ K}$$

$$\frac{E_a}{R}\left(\frac{1}{T} - \frac{1}{T_0}\right) = 6{,}014 \times 5.97 \times 10^{-4} = 3.59$$

$$\frac{R_\text{ct}(-20°\text{C})}{R_\text{ct}(25°\text{C})} = e^{3.59} \approx 36$$

A 36-fold increase in charge-transfer resistance at −20°C compared to 25°C — consistent with the empirical observation that an 18650 NMC cell delivers only 50–60% of its room-temperature capacity at −20°C and 0.5C, because the large $R_\text{ct}$ drives the terminal voltage to the cutoff before the electrode is fully discharged.

The electrolyte conductivity also decreases at low temperature, but less severely: 1 M LiPF₆ in EC:DMC drops from ~10 mS/cm at 25°C to ~3–4 mS/cm at −20°C — a factor of 2.5–3, much less than the 36-fold increase in $R_\text{ct}$. Below about −30°C to −40°C, electrolyte viscosity increases sharply and ionic conductivity drops further. Although EC has a high melting point (+36°C as a pure substance), standard electrolyte mixtures containing EC with linear carbonates (DMC, EMC, DEC) form eutectics with much lower freezing points. However, in EC-rich formulations, partial crystallisation of EC can occur at very low temperatures (below −30°C), which dramatically reduces ionic conductivity. Adding PC or EMC lowers the eutectic point and mitigates this effect — one reason SIB electrolytes, which often incorporate PC, perform better at low temperature.

The solid-state diffusion coefficient $D_s$ also decreases with temperature. For Li⁺ in NMC, $D_s$ at −20°C is approximately 1–3 orders of magnitude lower than at 25°C (depending on the activation energy for solid-state diffusion, which varies by material and by the crystallographic direction of diffusion). This means the diffusion time constant $\tau = L^2/D_s$ increases dramatically at low temperatures: a particle that equilibrates in 45 minutes at 25°C may take days to equilibrate at −20°C. At any realistic discharge rate, solid-state diffusion becomes severely limiting at low temperatures, contributing to concentration overpotential even at moderate currents.

The engineering consequence is that the **effective internal resistance** of a cell at low temperature is dominated by $R_\text{ct}$ (which is temperature-sensitive) rather than $R_\Omega$ (which is only mildly temperature-sensitive). Preheating a cell from −20°C to 10°C before charging can reduce $R_\text{ct}$ by a factor of 5–10 and dramatically improve charging safety (by allowing higher C-rates without triggering plating) and performance. Modern EV BMS systems include cell preheating functions specifically for this reason.

For SIBs, the low-temperature situation is more favourable than for most LIBs. Hard carbon anodes in sodium-ion cells have lower desolvation energy barriers in ether electrolytes compared to graphite in carbonate electrolytes, giving a lower activation energy for the rate-limiting interfacial step. HiNa BC-1 cells (Chapter 6) retain approximately 88% of room-temperature capacity at −20°C and approximately 70% at −40°C — dramatically better than most NMC/graphite LIBs at the same conditions. The physical origin is the combination of a lower activation energy for Na⁺ desolvation at the hard carbon surface and the PC-containing electrolytes commonly used in SIBs (which maintain low viscosity at low temperature better than EC-only electrolytes).

### High Temperature: The Degradation Multiplier

At high temperatures (above ~35–40°C), the primary effect is the Arrhenius acceleration of all degradation mechanisms. As established in Chapter 7, every 10°C increase in temperature approximately doubles the calendar aging rate. In addition:

**Electrolyte decomposition** at the cathode (CEI growth) accelerates exponentially. For cells cycled at 45°C versus 25°C, the resistance growth rate increases by approximately 3–5× after 500 cycles.

**Transition metal dissolution** from the cathode increases exponentially. For LMO and high-Mn NMC chemistries, this effect is severe above 40°C and is the dominant degradation mechanism at elevated temperature.

**Gassing** from electrolyte decomposition produces swelling in pouch cells and increasing internal pressure in cylindrical and prismatic cells. At temperatures above 60°C, gassing rates in NMC cells can become significant within weeks.

**SEI stability** decreases at elevated temperature: the organic components of the SEI are thermodynamically metastable and decompose faster at higher temperature, leading to a dynamic equilibrium where the SEI is continuously dissolving and reforming (rather than simply growing thicker as at room temperature). This gives a different aging kinetics than the $\sqrt{t}$ calendar law at elevated temperature — often a more linear capacity fade rather than the parabolic shape seen at 25°C.

The optimal operating temperature for longevity is typically 20–30°C — warm enough that kinetics are adequate for good performance, cool enough that Arrhenius-accelerated degradation is not severe. The BMW i3's battery thermal management system, for example, actively heats the cells in cold weather and actively cools them in hot weather, maintaining the pack within a narrow temperature window of approximately 15–35°C to optimise longevity.

---

## Why SIB Is Safer Than LIB — A Quantitative Accounting

The statement "sodium-ion batteries are safer than lithium-ion batteries" appears in almost every SIB review paper and press release, but it is rarely made quantitative. Let us do the quantitative accounting here.

### Cathode Oxygen Release: The Primary Difference

The dominant heat source in a lithium-ion thermal runaway event is the exothermic reaction between oxygen released from the delithiated cathode and the flammable organic electrolyte. As noted in Section 8.4, the onset temperature for oxygen release varies dramatically by cathode chemistry. The following table summarises oxygen release onset temperatures for the major cathode families:

| Chemistry Family | Type | Oxygen Release Onset (°C) | Notes |
|---|---|---|---|
| LCO | LIB | ~170–200 | Lower at extreme delithiation |
| NMC811 | LIB | ~180–200 | Dominant EV cathode; lowest margin |
| NMC622 | LIB | ~200–220 | Intermediate stability |
| NMC111 | LIB | ~260 | Most stable layered NMC |
| LFP | LIB | >400 | Phosphate framework retains O₂ |
| O3 layered oxide (Fe/Mn) | SIB | ~250–300 | Fe³⁺/Fe⁴⁺ vs. Ni³⁺/Ni⁴⁺ couples |
| P2 layered oxide | SIB | ~220–280 | Similar to O3 |
| NVPF | SIB | >400 | Phosphate/fluoride framework; LFP-like |
| PBA (Prussian white) | SIB | ~300–350 | Decomposes releasing HCN/CO, not O₂ |

The higher oxygen release temperature for SIB layered oxide cathodes compared to NMC811/NCA gives an additional margin of 70–120°C before catastrophic thermal runaway. This does not mean SIB cells cannot undergo thermal runaway — they can — but the onset is at a higher temperature, giving more time for detection and intervention, and the runaway is less severe if it does occur.

A note on PBAs: the cyanide framework decomposes rather than releasing molecular oxygen, generating HCN (hydrogen cyanide) and CO. This is a critically different hazard profile: while the absence of free oxygen makes PBA thermal events less likely to produce sustained fire, the release of HCN — an acutely toxic gas with an immediately dangerous concentration of only 50 ppm — creates a serious inhalation hazard in enclosed spaces (buildings, submarines, aircraft cargo holds). PBA-based SIB packs intended for indoor stationary storage will require gas venting and detection systems designed for HCN, not just the smoke and heat detectors used for conventional LIB packs.

### Lower Energy Content: Less Fuel

SIB cells currently store approximately 130–160 Wh/kg at the cell level, compared to 240–300 Wh/kg for high-energy NMC cells. A lower-energy-density cell generally has a lower total inventory of thermally reactive material — less highly-oxidized cathode (and therefore less releasable oxygen), less electrolyte, and lower anode energy content. These material inventories, rather than the stored electrochemical energy directly, determine the total heat release during thermal runaway. However, the correlation is strong: cells designed for high energy density pack more reactive material per unit mass, and so a 160 Wh/kg SIB cell will typically release substantially less heat during runaway than a 260 Wh/kg NMC cell of the same format. This directly reduces the severity and propagation potential of a runaway event.

### Anode Potential and Sodium Metal Hazard

The standard potential of sodium metal ($-2.71$ V vs. SHE) is higher than lithium metal ($-3.04$ V vs. SHE). While this is a disadvantage for energy density (as discussed throughout the book), it has a thermal safety advantage: sodium metal is a slightly less reactive reducing agent than lithium metal. The reaction of sodium metal with water or with electrolyte solvent, while exothermic, releases somewhat less energy per mole than the analogous lithium reaction.

More importantly, as noted in Section 7.3, sodium does not form sharp dendrites as readily as lithium under typical cell operating conditions. The reduced dendrite formation tendency means that the risk of a hard internal short circuit (separator piercing by a metallic dendrite) is lower for SIBs than for LIBs under fast-charging abuse conditions.

### Hard Carbon vs. Graphite: Less Stored Energy in the Anode

Graphite in a lithium-ion cell, when fully lithiated (LiC₆), stores approximately 372 mAh/g at 0.05–0.1 V vs. Li/Li⁺. At this low potential, the lithiated graphite is a powerful reducing agent that reacts vigorously with electrolyte when the SEI is compromised.

Hard carbon in a sodium-ion cell, when fully sodiated, stores approximately 250–350 mAh/g at 0.05–0.2 V vs. Na/Na⁺. The slightly higher average anode potential (hard carbon vs. graphite) and the somewhat lower specific capacity mean that the fully charged SIB anode has a modestly lower driving force for exothermic reaction with the electrolyte than the fully charged LIB graphite anode.

### Electrolyte Differences: A Mixed Picture

The electrolyte contributes to thermal runaway both as a fuel (organic solvents are flammable) and through decomposition reactions that generate gas and heat. SIB electrolytes are typically based on NaPF₆ salt in PC-rich or glyme-based solvents, whereas LIB electrolytes use LiPF₆ in EC/DMC or EC/EMC mixtures. The thermal stability comparison is mixed. NaPF₆ is somewhat less thermally stable than LiPF₆ (decomposition onset ~200°C vs. ~230°C for the pure salts), which could slightly worsen the gas generation profile during the early stages of a thermal event. However, PC-based solvents have a higher boiling point (242°C) and flash point (132°C) than DMC (90°C boiling, 18°C flash) or EMC (110°C boiling, 24°C flash), which can reduce the flammability risk during venting. The net effect on overall safety is modest compared to the cathode oxygen release advantage, but it is worth noting that SIB electrolyte safety is not uniformly better — it is a tradeoff between salt stability and solvent flammability.

### Quantifying the Safety Advantage: Accelerating Rate Calorimetry Data

Accelerating rate calorimetry (ARC) studies — measurements of self-heating rate versus temperature for cells in adiabatic conditions — provide quantitative data on thermal runaway severity. The following table compares representative cells:

| ARC Parameter | NMC811/graphite 18650 (3 Ah) | SIB O3/hard carbon 26650 (1.33 Ah) | SIB Advantage |
|---|---|---|---|
| Self-heating onset $T_\text{onset}$ | 55–65°C | 110–130°C | +55–65°C margin |
| Peak temperature $T_\text{max}$ | 750–850°C | 400–500°C | ~300°C lower |
| Total heat released | 28–38 kJ | 8–12 kJ | 3–4× lower |

The comparison is striking: SIB self-heating onset is approximately 60–70°C higher; peak temperature is approximately 300°C lower; total heat released is approximately 3–4× lower. All three metrics indicate substantially lower thermal runaway severity for the SIB cell.

For PBA-based SIBs and NVPF-based SIBs, the safety advantage is even larger: NVPF cathodes have no oxygen release below ~400°C (analogous to LFP), and PBA cathodes decompose at ~300–350°C without releasing molecular oxygen (though they do generate toxic gases, as noted above). The safety profile of these SIB chemistries is, for practical purposes, comparable to or better than LFP/graphite in terms of thermal runaway risk.

This safety advantage is one of the genuine, material-level strengths of sodium-ion technology, and it will be an important design parameter for the battery packs you will eventually model in simulation research.

---

## Worked Interpretation Exercise: Hand-Calculating Cell Heat Generation and Temperature Rise

Let us work through the deliverable calculation for this chapter: steady-state heat generation for a commercial cell at 1C discharge, compared to a rough convective cooling estimate.

We will use the **Samsung INR18650-30Q** (NMC/graphite, 3.0 Ah, DCIR ≈ 45 mΩ at 50% SOC, 25°C) as our reference cell, consistent with earlier worked examples.

### Step 1: Calculate the 1C Current

$$I_{1C} = 3.0 \text{ Ah} / 1 \text{ h} = 3.0 \text{ A}$$

### Step 2: Calculate Irreversible Heat Generation

Using the simplified Bernardi equation (Equation 8.15) with $R_\text{int}$ in place of separate ohmic and polarisation terms:

$$\dot{Q}_\text{irrev} = I^2 R_\text{int} = (3.0)^2 \times 0.045 = 9 \times 0.045 = 0.405 \text{ W}$$

This is 0.405 watts of irreversible heat at 1C discharge.

### Step 3: Estimate the Entropic Contribution

For NMC/graphite cells, the entropic coefficient $\partial E_\text{OCV}/\partial T$ is approximately $-0.1$ to $-0.3$ mV/K at mid-SOC. At this SOC, $\Delta S < 0$, so the entropic term *adds* to the irreversible heat (per the Bernardi equation, Equation 8.15). At 298 K:

$$\dot{Q}_\text{rev} = -I \times T \times \frac{\partial E_\text{OCV}}{\partial T} \approx -3.0 \times 298 \times (-0.0002 \text{ V/K}) = +0.179 \text{ W}$$

(using $\partial E_\text{OCV}/\partial T = -0.2$ mV/K as a mid-range estimate)

Total heat generation:
$$\dot{Q}_\text{total} = \dot{Q}_\text{irrev} + \dot{Q}_\text{rev} = 0.405 + 0.179 = 0.584 \text{ W}$$

The entropic contribution increases the net heat generation by about 44% at this SOC — a significant effect in the opposite direction from what you might naively expect. At other SOC values where $\partial E_\text{OCV}/\partial T > 0$ (as occurs for NMC/graphite near the bottom of discharge), the entropic term would instead subtract from the total, partially cooling the cell. The SOC-dependence of the entropic coefficient means the cell's heat generation profile is not constant during discharge — it changes as the SOC traverses regions where the sign of $\partial E_\text{OCV}/\partial T$ flips.

### Step 4: Calculate Steady-State Temperature Rise

For natural convection cooling of an 18650 cell in still air at 25°C ambient:

Cell surface area: $A = 2\pi r h + 2\pi r^2 = 2\pi(0.009)(0.065) + 2\pi(0.009)^2 = 3.68 \times 10^{-3} + 5.09 \times 10^{-4} = 4.19 \times 10^{-3}$ m²

Convective heat transfer coefficient (natural convection, vertical cylinder): $h_c \approx 8$ W/m²·K (a reasonable estimate for a 65 mm tall cylinder in still air)

Convective thermal resistance:
$$R_\text{th,conv} = \frac{1}{h_c A} = \frac{1}{8 \times 4.19 \times 10^{-3}} = \frac{1}{0.0335} = 29.8 \text{ K/W}$$

Internal (radial conduction) thermal resistance — using simplified form for a solid cylinder with $k_r = 0.3$ W/m·K:
$$R_\text{th,radial} \approx \frac{1}{4\pi k_r h} = \frac{1}{4\pi \times 0.3 \times 0.065} = \frac{1}{0.245} = 4.08 \text{ K/W}$$

Total thermal resistance (series combination):
$$R_\text{th,total} = 4.08 + 29.8 = 33.9 \text{ K/W}$$

Steady-state temperature rise (core above ambient):
$$\Delta T_\text{core,ss} = \dot{Q}_\text{total} \times R_\text{th,total} = 0.584 \times 33.9 = 19.8 \text{ K}$$

Surface temperature rise (above ambient):
$$\Delta T_\text{surface,ss} = \dot{Q}_\text{total} \times R_\text{th,conv} = 0.584 \times 29.8 = 17.4 \text{ K}$$

Temperature gradient (core to surface):
$$\Delta T_\text{core-surface} = \dot{Q}_\text{total} \times R_\text{th,radial} = 0.584 \times 4.08 = 2.4 \text{ K}$$

### Step 5: Interpret the Results

At 1C discharge in natural convection air cooling at 25°C ambient, the Samsung 30Q cell reaches a steady-state core temperature of approximately **44.8°C** (25 + 19.8). This is within the safe operating range but above the optimal longevity window (20–30°C) — a reminder that even 1C in still air produces meaningful heating. The core-to-surface gradient is about 2.4°C — small enough that the cell is nearly isothermal internally, which is typical for small cylindrical cells at moderate C-rates.

Let us verify what happens at 3C (9 A):

$$\dot{Q}_\text{irrev} = (9)^2 \times 0.045 = 81 \times 0.045 = 3.65 \text{ W}$$

(Note: at 3C, the DCIR may have increased due to concentration polarisation; we use 45 mΩ as an approximation.)

$$\dot{Q}_\text{rev} = -9 \times 298 \times (-0.0002) = +0.536 \text{ W}$$

$$\dot{Q}_\text{total} \approx 3.65 + 0.54 = 4.19 \text{ W}$$

$$\Delta T_\text{core,ss} = 4.19 \times 33.9 = 142 \text{ K}$$

A core temperature of 25 + 142 = **167°C** at 3C in natural convection! This is well above separator softening (~130°C) and deep into the electrolyte decomposition range — clearly unsafe for sustained operation without active cooling. This calculation illustrates why high-rate cylindrical cells must be either actively cooled (liquid cooling can reduce $R_\text{th,conv}$ by 10–50×, bringing $\Delta T$ down to manageable levels) or thermally limited by the BMS to lower C-rates in high-ambient-temperature environments.

This also explains why the datasheet for the Samsung 30Q specifies a maximum continuous discharge of 15A (5C) only under "adequate thermal management conditions" — the caveat is not boilerplate, it is a specific reference to the requirement for forced cooling that the above calculation reveals.

---

## What Changes for Sodium-Ion?

The thermal physics of Sections 8.1–8.3 — the Bernardi equation, thermal resistance networks, time constants — apply identically to SIBs. The numbers change, but the framework is the same.

For the heat generation calculation:

**$R_\text{int}$ is higher for SIBs** (80–150 mΩ for commercial 26650 cells vs. 20–50 mΩ for comparable NMC LIBs), which means higher irreversible heat generation at the same absolute current. However, SIB cells are also rated at lower capacity (1–3 Ah for 26650, vs. 3–5 Ah for 21700 NMC), so at the same C-rate, the absolute current is lower. The net result: heat generation per unit volume is comparable between SIB and LIB at the same C-rate.

**The entropic coefficient** for SIB hard carbon anodes in the plateau region is close to zero (the plateau is nearly temperature-independent, as it corresponds to quasi-metallic sodium in nanopores at an activity close to unity). For the slope region and for most SIB cathodes, the entropic coefficient is non-zero but has not been as thoroughly characterised as for LIB chemistries. This is an open area for calorimetric characterisation research.

For the thermal safety analysis:

As quantified in Section 8.7, SIB cells have: higher thermal runaway onset temperatures (110–130°C for O3-based SIBs vs. 55–65°C for NMC811 LIBs); lower peak temperatures during runaway (400–500°C vs. 750–850°C); and lower total heat release (8–12 kJ vs. 28–38 kJ for comparable format cells).

For NVPF-based SIBs, the safety profile is even more favourable — comparable to LFP in terms of oxygen release resistance. This may become a significant commercial differentiator for SIBs in applications where fire safety is paramount (urban stationary storage, aircraft, submarines).

The lower temperature coefficient of safety onset means that SIB cells designed for operation in tropical environments (ambient temperatures up to 45–50°C) have a larger safety margin than equivalent NMC cells — the margin between ambient and $T_\text{onset}$ is 65–85°C for SIBs vs. only 10–20°C for NMC811 cells in these environments. This is a genuine engineering advantage for deployment in hot climates.

---

## Chapter Summary

**Key ideas:**

- Heat in a battery cell has three sources: irreversible ohmic heating ($I^2 R_\Omega$, always positive, quadratic in current), irreversible polarisation heating ($I\eta_\text{pol}$, always positive), and reversible entropic heating ($-IT\partial E_\text{OCV}/\partial T$, can be positive or negative). All three are captured in the Bernardi equation.
- The Bernardi equation: $\dot{Q}_\text{gen} = I(E_\text{OCV} - E) - IT(\partial E_\text{OCV}/\partial T)$, or equivalently $\dot{Q}_\text{gen} = I^2 R_\text{int} - IT(\partial E_\text{OCV}/\partial T)$. The first term is always a heat source; the second can absorb or release heat depending on the sign of the entropic coefficient $\partial E_\text{OCV}/\partial T$.
- Thermal resistance networks govern temperature rise: $\Delta T = \dot{Q}_\text{gen} \times R_\text{th,total}$. For cylindrical cells, radial conduction through the jelly roll (low $k_r \approx 0.3$ W/m·K) and convective transfer from the surface to ambient are the two series resistances. Natural convection is typically the dominant resistance.
- The thermal time constant $\tau_\text{th} = mc_p R_\text{th}$ governs the transient temperature response. For 18650 cells in natural convection, $\tau_\text{th} \approx 15$–20 minutes — short enough that sustained high-rate discharge reaches steady state during a drive cycle.
- Safe operating windows: upper temperature limit (~60°C) is set by the margin to SEI decomposition onset (~80–100°C). Lower charging limit (0°C for most LIBs) is set by the plating risk from elevated charge-transfer resistance. SIBs have a more relaxed lower charging limit (−10°C to −20°C).
- Thermal runaway is a positive-feedback instability: when the exponential Arrhenius heat generation from chemical reactions exceeds the linear cooling capacity, temperature rises without bound. The critical temperature is set by the intersection of the exponential heat generation curve and the linear cooling curve (Semenov diagram). Self-heating onset (detectable at 0.02°C/min in ARC) occurs at approximately 55–65°C for fully charged NMC811, >150°C for LFP, and 110–130°C for O3-type SIBs. Violent thermal runaway (Stage 3, with oxygen release and electrolyte combustion) requires significantly higher temperatures (~180°C+ for NMC).
- SIBs are quantifiably safer than NMC LIBs: higher oxygen release temperature (>250°C vs. ~180°C for NMC811), lower peak runaway temperature (~450°C vs. ~800°C), lower total heat release (~10 kJ vs. ~35 kJ for comparable format cells), and less severe sodium metal vs. lithium metal reactivity.

**Key equations:**

$$\dot{Q}_\text{gen} = I(E_\text{OCV} - E) - IT\frac{\partial E_\text{OCV}}{\partial T} \quad \text{(Bernardi equation)} \tag{8.12}$$

$$\dot{Q}_\text{gen} = I^2 R_\text{int} - IT\frac{\partial E_\text{OCV}}{\partial T} \quad \text{(engineering form)} \tag{8.15}$$

$$\Delta T_\text{ss} = \dot{Q}_\text{gen} \cdot R_\text{th} \quad \text{(steady-state temperature rise)} \tag{8.16}$$

$$R_\text{th,conv} = \frac{1}{h_c A} \quad \text{(convective thermal resistance)} \tag{8.19}$$

$$\tau_\text{th} = mc_p R_\text{th} \quad \text{(thermal time constant)} \tag{8.20}$$

$$\left(\frac{\partial E_\text{OCV}}{\partial T}\right)_P = \frac{\Delta S}{nF} \quad \text{(entropic coefficient, from Chapter 1)} \tag{8.3}$$

**Key vocabulary (in order of appearance):**

Bernardi equation, irreversible heat, reversible heat, entropic heat, ohmic heating, polarisation heating, entropic coefficient ($\partial E/\partial T$), thermal resistance, radial thermal conductivity ($k_r$), axial thermal conductivity ($k_z$), convective heat transfer coefficient ($h_c$), thermal time constant, safe operating temperature window, SEI decomposition onset, separator shutdown, thermal runaway, critical temperature ($T_c$), self-heating onset temperature ($T_\text{onset}$), Semenov diagram, accelerating rate calorimetry (ARC), thermal propagation, entropic heat measurement.

---

## Deliverable

**Task:** Hand-calculate steady-state heat generation for a commercial cell at 1C discharge using datasheet internal resistance. Compare to a rough convective cooling estimate.

**Guidance:** We worked through this calculation for the Samsung 30Q (NMC, 18650) in Section 8.7. Your task is to repeat the calculation for a different cell — specifically, for a SIB cell — and compare the results.

Use the **HiNa BC-1** (SIB, 26650 format, 1.33 Ah, DCIR ≈ 100 mΩ, nominal voltage 3.2 V) for the SIB calculation.

The 26650 cell dimensions are: diameter 26 mm (radius 13 mm), height 65 mm.

Step through the following:

**1. Calculate 1C current**: $I_{1C} = Q/1\text{h} = 1.33\text{ Ah}/1\text{ h} = 1.33$ A. Notice this is less than half the 1C current of the Samsung 30Q (3.0 A). This matters because heat generation scales as $I^2$: even though the BC-1's DCIR is more than twice the 30Q's, the $I^2$ factor for the BC-1 at 1C is $(1.33)^2 = 1.77$ A² versus $(3.0)^2 = 9.0$ A² for the 30Q. The $I^2 R$ products — which you will calculate in Step 2 — may surprise you.

**2. Calculate irreversible heat generation**: Use $\dot{Q}_\text{irrev} = I^2 R_\text{int}$ with the datasheet DCIR value. Note whether the higher DCIR of the SIB cell compared to the 30Q results in higher or lower absolute heat generation at 1C (hint: compare $I^2 R$ — the lower capacity of the BC-1 means the 1C current is lower, but the DCIR is higher; the net effect is instructive).

**3. Estimate entropic contribution**: Use $\dot{Q}_\text{rev} = -I \times T \times (\partial E_\text{OCV}/\partial T)$, with $\partial E_\text{OCV}/\partial T \approx -0.15 \times 10^{-3}$ V/K as an approximate mid-range entropic coefficient for a hard carbon/layered oxide SIB cell (a rough estimate; precise values are not yet widely published for this chemistry).

**4. Calculate total heat generation**.

**5. Calculate cell surface area** for the 26650 format and estimate the convective thermal resistance assuming natural convection ($h_c = 8$ W/m²·K).

**6. Calculate the radial conduction resistance** using $k_r = 0.3$ W/m·K (assume similar to an 18650 jelly roll).

**7. Calculate steady-state core temperature rise and surface temperature rise**.

**8. Repeat at 3C**: Does the BC-1 cell overheat in natural convection at 3C?

Compare your SIB results to the LIB results from the worked example in Section 8.7. Which cell runs hotter at 1C? At 3C? Which is safer in a natural-convection environment at high ambient temperature (say, 40°C)?

---

## Further Reading

1. **Bernardi, D., Pawlikowski, E., and Newman, J., "A General Energy Balance for Battery Systems," *Journal of the Electrochemical Society* 132 (1), 5–12 (1985).** The original Bernardi equation paper. Readable and rigorous — the derivation is elegant and uses only classical thermodynamics. Worth reading in full both for the result and as a model of clean electrochemical engineering analysis.

2. **Forgez, C. et al., "Thermal modeling of a cylindrical LiFePO₄/graphite lithium-ion battery," *Journal of Power Sources* 195 (9), 2961–2968 (2010).** A practical thermal model for a cylindrical cell that demonstrates how to set up and parameterise the thermal resistance network described in Section 8.3. The paper includes measured radial and axial thermal conductivities for an LFP/graphite 26650 cell — directly relevant to your deliverable.

3. **Feng, X. et al., "Thermal runaway mechanism of lithium ion battery for electric vehicles: A review," *Energy Storage Materials* 10, 246–267 (2018).** The most comprehensive review of thermal runaway mechanisms, triggers, and propagation in EV-scale battery systems. Covers ARC methodology, the three-stage model of Section 8.5, and mitigation strategies. Read this for depth on thermal runaway beyond what this chapter covers.

4. **Bandhauer, T. M., Garimella, S., and Fuller, T. F., "A Critical Review of Thermal Issues in Lithium-Ion Batteries," *Journal of the Electrochemical Society* 158 (3), R1–R25 (2011).** A systematic review of thermal generation, transport, and management in lithium-ion cells. Excellent tables of thermal property values ($k_r$, $k_z$, $c_p$) for various cell formats and chemistries, which are directly usable in simulation models.

5. **Hu, X. et al., "Battery warm-up methodologies at subzero temperatures for automotive applications: Recent advances and perspectives," *Progress in Energy* 2 (2), 022001 (2020).** The most thorough review of low-temperature battery performance and preheating strategies. Particularly relevant to the low-temperature section (8.6) and to understanding how SIBs' low-temperature advantage can be exploited in practice.


\newpage

# Pack Architecture

## Chapter Opening

A single lithium-ion 18650 cell contains about 11 watt-hours of energy and delivers current at 3.6 volts. A Tesla Model Y Long Range battery pack contains about 82 kilowatt-hours of energy and operates at 400 volts. The path from one to the other is not simply "add more cells" — it is a carefully engineered system in which hundreds or thousands of cells are interconnected in precise geometric and electrical arrangements, monitored by distributed electronics, protected by safety devices, managed by a sophisticated software system, and housed in a structural enclosure designed to survive vehicle crashes. Understanding how a pack is put together, and why it is put together that way, is the bridge between the single-cell physics we have developed in Chapters 1 through 8 and the system-level engineering that Chapters 10 through 12 will address.

This chapter is fundamentally an electrical engineering chapter. You already know everything you need to understand pack architecture — series and parallel circuits, voltage and current dividers, fault current protection, communication buses — you just need to see these familiar tools applied in the battery context, with attention to the ways that batteries are not ideal voltage or current sources and to the specific failure modes that arise when many imperfect cells are connected together.

By the end of this chapter, you will be able to look at a pack specification — "96s2p, 350V nominal, 150 Ah" — and immediately reconstruct its cell count, topology, voltage, current capability, and approximate energy content. You will understand why cell-to-cell variation is not just an imperfection to be tolerated but a source of genuine performance and safety risk that must be actively managed. You will know the purpose and proper sequencing of every major electrical component in a pack — contactors, precharge resistors, fuses, current sensors, isolation monitors — and why each one exists. And you will have a working understanding of the communication architecture that allows the BMS to coordinate all of this in real time.

Pack architecture is the layer of engineering that converts electrochemistry into a usable energy storage system. It is where physics and electrical engineering meet, and for an EE with a growing understanding of battery science, it is the most natural home ground in this entire book.

---

> **Prerequisites Check**
>
> From your EE background:
> - Series and parallel circuit analysis — essential for Section 9.1; if you can calculate the equivalent resistance of a network, you can calculate the equivalent capacity of a cell configuration
> - Fuse and relay/contactor circuit operation — needed for Section 9.3
> - Basic CAN bus or other serial communication protocol awareness — helpful for Section 9.4
> - Inrush current and capacitor precharge — directly relevant to Section 9.3
>
> From Chapters 3 and 7:
> - Internal resistance, SOC, SOH definitions (Chapter 3, Sections 3.3, 3.5)
> - Degradation mechanisms and why individual cells age differently (Chapter 7) — motivation for Section 9.2
>
> From Chapter 8:
> - Thermal runaway and propagation (Section 8.5) — motivates the safety design choices in Section 9.3

---

## Series and Parallel Configurations: Nomenclature and Analysis

A battery pack is built by connecting individual cells in series, in parallel, or in series-parallel combinations. The choice of configuration determines the pack's terminal voltage, current capability, capacity, energy content, and internal resistance — and it does so in ways that are direct electrical engineering consequences of how series and parallel circuits behave.

### Series Connections: Voltage Addition

When cells are connected in **series** — positive terminal of one cell to the negative terminal of the next — the voltages add while the capacity (in Ah) remains equal to the capacity of a single cell:

$$V_\text{pack} = \sum_{i=1}^{n_s} V_i \approx n_s \cdot V_\text{cell} \tag{9.1}$$

$$Q_\text{pack} = Q_\text{cell} \tag{9.2}$$

$$R_\text{pack,int} = \sum_{i=1}^{n_s} R_{\text{int},i} \approx n_s \cdot R_\text{cell} \tag{9.3}$$

where $n_s$ is the number of cells in series. The approximate equalities assume all cells are identical — which they are not, as we will examine in Section 9.2.

The energy stored in a series string is $E_\text{string} = V_\text{pack} \times Q_\text{pack} = n_s V_\text{cell} \times Q_\text{cell}$, which equals $n_s$ times the energy of a single cell. This is consistent with the expectation that adding cells in series adds energy proportionally.

The critical property of a series string is that **the same current flows through every cell**. All cells charge and discharge at the same current magnitude. This means the weakest cell in the string — the cell with the lowest capacity, highest internal resistance, or most degraded state — limits the performance of the entire string. You cannot charge the series string beyond the point at which the weakest cell reaches its upper voltage cutoff, even if all other cells have room for more charge. You cannot discharge beyond the point at which the weakest cell reaches its lower voltage cutoff.

This constraint is the fundamental motivation for cell balancing (Chapter 11) and for the careful cell-matching requirements in pack manufacturing. The weakest cell determines pack performance, which is why matching cells by capacity, internal resistance, and OCV before assembly is so important.

### Parallel Connections: Capacity Addition

When cells are connected in **parallel** — all positive terminals joined, all negative terminals joined — the capacities add while the voltage remains equal to the voltage of a single cell:

$$V_\text{pack} = V_\text{cell} \tag{9.4}$$

$$Q_\text{pack} = \sum_{i=1}^{n_p} Q_i \approx n_p \cdot Q_\text{cell} \tag{9.5}$$

$$R_\text{pack,int} = \frac{R_\text{cell}}{n_p} \tag{9.6}$$

where $n_p$ is the number of cells in parallel. Parallel connection reduces the internal resistance (more current paths) and increases the capacity, but keeps the voltage constant.

In a parallel group, the current distributes among the cells inversely proportional to their internal resistance. If cells are matched (equal $R_\text{int}$), current distributes equally. If they are mismatched, the cell with the lowest $R_\text{int}$ carries more current and the cell with the highest $R_\text{int}$ carries less. This current sharing imbalance means that in a mismatched parallel group, some cells are more heavily stressed than others — the low-resistance cell works harder, heats more, and ages faster, which progressively increases the imbalance.

There is also a subtle interaction in parallel groups involving the open-circuit voltage (OCV) of the cells. At the moment of connecting cells in parallel, if their OCVs differ, a circulating current flows to equalise them — limited only by the sum of their internal resistances. For large OCV mismatches, this inrush current can be substantial. Consider connecting a 50% SOC NMC cell ($V_\text{OCV} \approx 3.65$ V) in parallel with a 90% SOC cell ($V_\text{OCV} \approx 4.10$ V), each with $R_\text{int} = 35$ mΩ. The voltage difference is 0.45 V, and the total resistance in the equalisation loop is $35 + 35 = 70$ mΩ, giving an initial current of $0.45/0.070 = 6.4$ A. For a 5 Ah cell, that is a 1.3C equalisation current — not catastrophic, but sustained for minutes as the SOCs converge, generating significant heat in both cells and potentially stressing the SEI. The equalisation current decays as the OCVs converge, following a time course set by the cells' differential capacitance and internal resistance — conceptually identical to charging a capacitor through a resistance, which is a familiar EE picture. This is why cells connected in parallel must be matched in SOC (and ideally in capacity and OCV) before connection.

### Series-Parallel Combinations

Most real battery packs use a combination of series and parallel connections to achieve both the desired voltage and the desired capacity. The two basic topologies are:

**Series-first (series strings in parallel, denoted $n_s\text{s}n_p\text{p}$)**: Cells are first grouped into series strings of $n_s$ cells each, and $n_p$ such strings are connected in parallel. The pack voltage is $n_s V_\text{cell}$, the pack capacity is $n_p Q_\text{cell}$, and the pack internal resistance is $n_s R_\text{cell} / n_p$.

**Parallel-first (parallel groups in series, same notation)**: Cells are first grouped into parallel groups of $n_p$ cells each (all at the same position in the series stack), and $n_s$ such groups are stacked in series. The pack voltage is $n_s V_\text{cell}$, the pack capacity is $n_p Q_\text{cell}$ — identical electrically to series-first for a pack of $n_s \times n_p$ cells.

The distinction between series-first and parallel-first matters for fault management and thermal performance, even though the terminal characteristics are identical in the ideal case. In **parallel-first** architectures (which dominate modern EV packs), cells are first grouped into parallel groups of $n_p$ cells, and these groups are then stacked in series. If one cell in a parallel group develops an internal short, the other $n_p - 1$ cells in that group discharge into it — the group self-equalises at a lower voltage, and the BMS sees a single group with anomalous voltage. The pack can often continue to operate (with reduced performance) because the other 95 series groups are unaffected.

In **series-first** architectures, cells are first wired into full series strings and the strings are paralleled. If a single cell in one string develops a short, the entire string's voltage drops, and the paralleled healthy strings drive current into the faulted string — potentially a much larger current than in the parallel-first case, because the full pack voltage drives the equalisation. The faulted string may need to be disconnected entirely (requiring per-string fusing), which reduces the pack's parallel capacity by $1/n_p$.

This difference in fault isolation behaviour is the primary reason parallel-first topologies are preferred in safety-critical applications: faults are contained locally within a parallel group rather than propagating across the full voltage stack.

### The Pack Nomenclature

The industry standard notation for pack configuration is $n_s\text{s}n_p\text{p}$, where $n_s$ is the series count and $n_p$ is the parallel count. Reading this notation immediately gives you the pack's key parameters. The pack voltage is $V_\text{pack} = n_s \times V_\text{cell,nominal}$, the pack capacity is $Q_\text{pack} = n_p \times Q_\text{cell}$, the total energy is $E_\text{pack} = V_\text{pack} \times Q_\text{pack} = n_s n_p \, V_\text{cell} \, Q_\text{cell}$, and the total cell count is simply $N_\text{total} = n_s \times n_p$. Once you internalise these four relationships, you can reconstruct any pack's electrical characteristics from its $n_s\text{s}n_p\text{p}$ label and a single-cell datasheet.

Let us work through a concrete example. A $96\text{s}2\text{p}$ pack using **Samsung INR21700-50E** cells (3.6 V nominal, 4.9 Ah):

$$V_\text{pack} = 96 \times 3.6 = 345.6 \text{ V nominal} \approx 350 \text{ V}$$
$$Q_\text{pack} = 2 \times 4.9 = 9.8 \text{ Ah}$$
$$E_\text{pack} = 345.6 \times 9.8 = 3{,}387 \text{ Wh} = 3.39 \text{ kWh}$$
$$N_\text{total} = 96 \times 2 = 192 \text{ cells}$$

A different pack topology for the same cells with more parallel: $16\text{s}24\text{p}$:

$$V_\text{pack} = 16 \times 3.6 = 57.6 \text{ V}$$
$$Q_\text{pack} = 24 \times 4.9 = 117.6 \text{ Ah}$$
$$E_\text{pack} = 57.6 \times 117.6 = 6{,}773 \text{ Wh} = 6.77 \text{ kWh}$$
$$N_\text{total} = 16 \times 24 = 384 \text{ cells}$$

The second configuration stores twice the energy but operates at a much lower voltage. Both configurations use the same cells — the topology choices depend entirely on the application requirements for voltage, current, and system architecture.

The choice between these topologies is driven by the target application's power requirements and system voltage constraints. For the same power delivery, a high-voltage/low-current pack ($96\text{s}2\text{p}$) produces lower $I^2R$ losses in the wiring and power electronics, allowing thinner cables and smaller MOSFETs or IGBTs — but requires more series cells and more BMS monitoring channels ($n_s$ voltage measurements). A low-voltage/high-current pack ($16\text{s}24\text{p}$) needs fewer monitoring channels and has better fault tolerance in series (fewer series elements to fail), but the higher currents demand heavier cabling, larger contactors, and more expensive power semiconductors rated for hundreds of amperes. In EV applications, the trend toward 400V and 800V architectures reflects the industry's preference for the high-voltage side of this tradeoff — at the power levels required to drive a vehicle (50–300 kW), keeping currents below 400–500 A is essential for practical cable sizing and connector design. In stationary storage, where weight and connector size matter less, lower-voltage/higher-parallel architectures (48V or 96V systems) are common because they simplify safety requirements and reduce the need for HV-qualified personnel during installation.

### Practical Worked Example: Reconstructing a Real Pack

The **Tesla Model 3 Long Range** (as of 2019–2022) uses **2170-format NCA/graphite cells** (Panasonic, ~4.8 Ah per cell, 3.6 V nominal) in a $96\text{s}46\text{p}$ configuration. Let us verify this:

$$V_\text{pack} = 96 \times 3.6 = 345.6 \text{ V nominal}$$
$$Q_\text{pack} = 46 \times 4.8 = 220.8 \text{ Ah}$$
$$E_\text{pack} = 345.6 \times 220.8 = 76{,}293 \text{ Wh} \approx 76 \text{ kWh}$$
$$N_\text{total} = 96 \times 46 = 4{,}416 \text{ cells}$$

The rated pack energy of approximately 76 kWh (gross) with about 70–72 kWh usable is consistent with published specifications. The difference between gross and usable energy reflects the SOC buffers maintained by the BMS at the top and bottom of the charge range to protect against overcharge and overdischarge — typically 5–10% of total capacity. These buffers trade usable energy for longevity and safety. The 350V nominal bus voltage is characteristic of most modern BEV platforms (which use 400V-class power electronics) — the 96-cell series count at 3.6 V nominal per cell targets this voltage. These values are derived from published teardown analyses and are representative; specific numbers vary slightly by production year and configuration.

---

## Cell-to-Cell Variation and Its Consequences

No two cells are identical, even from the same production lot of the same manufacturer. Manufacturing tolerances in electrode coating weight, calendering pressure, electrolyte fill volume, separator thickness, and formation cycling all create cell-to-cell differences in capacity, internal resistance, and OCV at a given SOC. Cells also age differently depending on their position in the pack (temperature gradients, current distribution), and the aging differences compound over time. Understanding the sources and consequences of cell-to-cell variation is essential to understanding why pack performance degrades over life in ways that cannot be predicted from single-cell testing alone.

### Sources of Cell-to-Cell Variation

At beginning-of-life (BOL), the primary sources of cell-to-cell variation in a commercial pack are:

**Capacity spread**: The capacity of freshly manufactured cells from the same production batch typically shows a Gaussian distribution with a standard deviation of approximately 0.5–2% of the nominal capacity. For a 3.0 Ah cell, this means the capacity spread is roughly ±30–60 mAh (1σ). After cell binning (sorting by measured capacity before pack assembly), the spread within a bin is typically reduced to ±0.5–1%.

**Internal resistance spread**: DCIR spread at BOL is typically ±5–15% within a production batch. Internal resistance is more sensitive to manufacturing variation than capacity because it depends on the quality of electrical contacts, electrode coating uniformity, and electrolyte wetting completeness — all of which are harder to control tightly than the overall amount of active material.

**OCV spread at a given SOC**: Small differences in electrode active material loading, the lithium balance between anode and cathode (set during formation), and any residual capacity differences cause cells at nominally the same SOC to have slightly different OCV values. At mid-SOC on a sloped OCV curve (NMC), a 10 mAh capacity difference between cells might correspond to a 2–5 mV OCV difference. On a flat OCV curve (LFP), the same capacity difference would produce essentially zero OCV difference — which, as we noted in Chapters 3 and 6, makes balancing much harder because there is no voltage signal to indicate imbalance.

**Self-discharge rate spread**: Cells do not all self-discharge at identical rates. Even small differences in leakage current through the separator or in SEI stability accumulate over days to weeks to produce SOC divergence during storage. In a pack that sits idle for months, self-discharge spread can build up to 2–5% SOC divergence, enough to affect performance significantly.

### How Variation Propagates During Operation

In a series string, the capacity imbalance between cells leads to **state-of-charge divergence** during cycling. Consider a string of $n_s$ cells where one cell ("the weak cell") has capacity $Q_\text{weak} < Q_\text{cell}$. During discharge, the string current is the same for all cells. Each cell discharges at the same rate in amperes — but since the weak cell has less capacity, it completes a larger fraction of its available discharge per unit of charge drawn. The weak cell reaches its lower voltage cutoff first, at which point the entire string must stop discharging, even though all other cells still have charge to give.

The lost capacity from this early cutoff is:

$$\Delta Q_\text{lost} \approx (Q_\text{cell} - Q_\text{weak}) \tag{9.7}$$

This is direct pack capacity loss caused by the weakest cell — the "weak link" effect in a series chain. And it compounds over time. Consider a concrete scenario: a series string of 96 cells at 5.0 Ah nominal, where one cell starts at 4.85 Ah (3% below nominal). After 500 full-pack cycles, the normal cells have degraded to 4.75 Ah (5% fade), but the weak cell — having cycled at a 3% higher effective DOD each cycle — has degraded to 4.55 Ah (6.2% fade from its already lower starting point). The capacity gap has widened from 0.15 Ah to 0.20 Ah. After another 500 cycles, the gap widens further. This is the self-reinforcing mechanism of capacity fade in a series string: the weak cell's disadvantage grows with every cycle, and the pack's accessible capacity falls at a rate determined not by the average cell but by the weakest one. In control engineering terms, this is a positive feedback loop with no inherent saturation — it runs until the BMS declares the pack end-of-life.

In a parallel group, the analogous problem is **current imbalance**. The cell with the lowest internal resistance carries a disproportionately large share of the current. Over thousands of cycles, this cell ages faster (higher heat generation, higher effective C-rate, more severe mechanical stress), its resistance increases, and the current imbalance slowly shifts — a gradual equalisation driven by differential aging rather than by deliberate balancing. In well-matched parallel groups this imbalance is small, but in aged packs where cell-to-cell resistance divergence has grown, it can be significant.

### Temperature Non-uniformity as a Variation Amplifier

Cells in different locations within a pack module experience different temperatures. Cells near the centre of a module (farther from the cooling channels) run hotter than cells at the edges. As established in Chapter 7, higher temperature accelerates all thermally activated degradation mechanisms. Cells that run 5°C hotter than their neighbours age approximately 1.5× faster (from the Arrhenius analysis of Section 7.2 — the rule of thumb is roughly a doubling of degradation rate per 10°C increase). Over the lifetime of the pack, thermally hotter cells develop lower capacity and higher resistance than their cooler neighbours — even if they started identical.

This temperature-driven aging heterogeneity compounds the initial manufacturing variation. A pack that starts with ±1% capacity spread may develop ±10% capacity spread after 500 cycles if the thermal management system allows a 5–10°C temperature gradient across the module. The resulting BMS challenges — balancing a pack with large, varying, and spatially structured imbalance — are substantially more demanding than managing the initial manufacturing variation.

The engineering lesson is that thermal management system design and state estimation accuracy are not independent problems — they are coupled. A pack with poor thermal uniformity requires more sophisticated balancing and state estimation, and the balancing losses (energy dissipated in passive balancing, Section 11.2) are higher. This coupling motivates the thermal management system (TMS) targets in modern BEV design: cell-to-cell temperature gradients of less than 3–5°C across the module, over the full range of operating conditions.

### Degradation-Induced Variation

Even in a pack with perfect initial matching and perfect thermal uniformity, cells at different positions in a series string can develop different amounts of degradation due to variation in **local electrochemical conditions**. The current distribution in a parallel-connected electrode stack is not perfectly uniform — edges and corners of large-format prismatic or pouch cells experience different local current densities than the centre, leading to faster local SEI growth and different local capacity fade rates. This within-cell non-uniformity is distinct from cell-to-cell variation but has similar consequences for pack management.

Over the life of a pack, the combined effect of initial manufacturing spread, thermal non-uniformity, and degradation heterogeneity produces a distribution of cell capacities and resistances that widens continuously. End-of-life pack behavior is often dominated by the tail of this distribution — the handful of most-degraded cells whose early cutoff triggers pack-level protective actions.

The manufacturing response to initial cell-to-cell variation is **cell grading** (also called **cell binning**): after formation cycling, every cell is characterised for capacity, DCIR, self-discharge rate, and OCV profile, and sorted into bins of tightly matched cells. Only cells from the same bin are assembled into a single pack. Grading reduces the initial capacity spread within a pack from the full production distribution (±1–2%) to the within-bin tolerance (typically ±0.3–0.5%). Tighter binning improves pack performance and longevity but reduces manufacturing yield — cells that fall outside all bins are sold to less demanding applications or recycled. This is why premium EV manufacturers (who can afford to discard or redirect more cells) achieve better pack longevity than budget manufacturers using the same cell chemistry with looser grading. It is also why second-life battery applications — assembling new packs from cells recovered from retired EV packs — face a particularly severe variation challenge: the cells have aged differently in their first life, and the spread in capacity and resistance at second-life entry can be 10–20%, far wider than any BOL manufacturing spread.

---

## Contactors, Precharge, Fuses, and Current Sensing

The electrical architecture of a battery pack contains several components that have no equivalent in a simple electrochemical cell analysis. These components exist to manage the large energies and currents involved in pack-level systems, to protect against fault conditions, and to allow the pack to be safely connected and disconnected from the load. As an electrical engineer, you will recognise all of these concepts — the battery-specific aspects are primarily about scale and the unusual behaviour of batteries as non-ideal voltage sources.

### The High-Voltage Bus and Its Hazards

A modern EV battery pack operates at 300–800V. At these voltages, arc flash energy during a fault is enormous — a short circuit across a 400V, 200 Ah pack can deliver hundreds of kilojoules in milliseconds, enough to vaporise copper busbars, cause severe arc burns, and destroy the pack electronics. The high-voltage (HV) bus must be treated with the same caution as industrial power distribution equipment, not as a larger version of a 12V automotive battery.

The additional hazard unique to battery systems is that the pack is a **stiff voltage source with low impedance** — unlike a generator or transformer that can be de-energised by disconnecting the prime mover, the electrochemical energy in a battery pack is always present at the terminals as long as the cells are intact. There is no "off switch" that eliminates the voltage without physically disconnecting the cells. This is why the contactor system described below is so important: it provides the controlled connection and disconnection pathway between the stored energy and the external system.

### Contactors: The High-Voltage Switches

**Contactors** are electromechanical switches — essentially large relays — that connect and disconnect the HV bus. They are the primary means of electrically isolating the battery pack from the vehicle's drivetrain and auxiliary systems. A typical pack has at minimum two contactors: a **positive contactor** in series with the positive terminal of the pack, and a **negative contactor** in series with the negative terminal. Opening both contactors isolates the pack from the rest of the system.

Contactors for automotive applications are rated for the full pack voltage (typically 450–900 V DC, depending on architecture) and the maximum continuous current (100–500 A for most passenger vehicles). They are energised by the 12V auxiliary battery (the low-voltage battery in an EV, separate from the main HV pack) and controlled by the BMS. When the BMS commands the contactors closed, the HV bus is energised; when it commands them open, the bus is de-energised.

The contactor closing sequence is not simply "close positive, close negative." A critical intermediate step — precharge — must occur first, and its purpose is one of the most EE-relevant concepts in this chapter.

### Precharge: Managing Inrush Current

When a charged battery pack is connected to an inverter or motor controller that has input capacitors (all modern power electronics do, to filter the DC bus voltage), the connection of the HV bus to the discharged input capacitor creates a momentary short circuit through the battery's internal resistance. The inrush current at the instant of connection is:

$$I_\text{inrush} = \frac{V_\text{pack}}{R_\text{pack,int}} \tag{9.8}$$

For a 400V pack built from large-format prismatic NMC cells with $R_\text{pack,int} = 100$ mΩ (representative of a $96\text{s}1\text{p}$ pack using ~100 Ah prismatic cells with individual DCIR of ~1 mΩ each), the initial inrush current without precharge would be $400/0.1 = 4{,}000$ A — far exceeding the contactor's rated current and sufficient to weld the contactor contacts together (contact welding is the dominant failure mode for improperly precharging contactors).

The solution is a **precharge circuit**: a small **precharge contactor** in series with a **precharge resistor** (typically 10–100 Ω), with this series combination connected in parallel across the main positive contactor. Before the main positive contactor closes, the precharge contactor closes, allowing current to flow through the precharge resistor and charge the input capacitors slowly. Once the capacitor voltage has risen to within a few percent of the pack voltage (monitored by the BMS through the pack and capacitor voltage measurements), the main positive contactor closes, and the precharge contactor opens.

The precharge circuit topology is simple enough to sketch. Imagine the following schematic (draw this in your notebook):

```
       ┌──── Main Positive Contactor (K1) ────┐
       │          (normally open)               │
 PACK  │                                        │  LOAD
 (+) ──┤                                        ├── (+)
       │   ┌─ Precharge Contactor (K2) ─┐      │
       │   │     (normally open)         │      │
       └───┤                             ├──────┘
           └──── R_precharge (50 Ω) ─────┘

 PACK  ─────── Negative Contactor (K3) ─────────── LOAD
 (-)            (normally open)                     (-)
                                             ┌───┐
                                        C_bus │   │ (load input
                                             └───┘  capacitor)
```

The closing sequence is: close K3 → close K2 → wait for $C_\text{bus}$ to charge through $R_\text{precharge}$ → close K1 → open K2. At the moment K1 closes, the voltage across K1 is only a few volts (the residual $V_\text{pack} - V_\text{cap}$), so the inrush is negligible.

The precharge time constant is:

$$\tau_\text{precharge} = R_\text{precharge} \times C_\text{bus} \tag{9.9}$$

where $C_\text{bus}$ is the total input capacitance of the inverter. For a typical 1 mF inverter input capacitance and a 50 Ω precharge resistor:

$$\tau_\text{precharge} = 50 \times 10^{-3} = 0.05 \text{ s} = 50 \text{ ms}$$

Allowing 5τ for the capacitor to charge to >99% of pack voltage: 250 ms — fast enough not to inconvenience the driver, but slow enough that the inrush current through the precharge resistor is limited to $V_\text{pack}/R_\text{precharge} = 400/50 = 8$ A rather than 4,000 A.

The precharge resistor dissipates energy during each precharge event:

$$E_\text{precharge} = \frac{1}{2} C_\text{bus} V_\text{pack}^2 = \frac{1}{2} \times 10^{-3} \times 400^2 = 80 \text{ J} \tag{9.10}$$

This 80 J must be dissipated in the precharge resistor — it must be rated for this energy per event, and if precharge events happen frequently (vehicle cycling on/off multiple times per day), the average power dissipation must also be acceptable. The precharge resistor is therefore not trivially sized; it requires proper thermal engineering.

The full contactor closing sequence is: (1) confirm pack isolation via insulation resistance check — this verifies no ground fault exists before energising anything; (2) close negative main contactor — this connects one side of the pack to the load but no current flows yet because the positive path is still open; (3) close precharge contactor — current now flows from the pack's positive terminal, through the precharge resistor, through the load's input capacitors, and returns through the already-closed negative contactor, charging the capacitors slowly; (4) wait for capacitor to charge, monitoring $|V_\text{pack} - V_\text{bus}| < V_\text{threshold}$ (typically 5–10 V); (5) close positive main contactor — the capacitors are now nearly fully charged, so the voltage across the main contactor at the instant of closing is only a few volts, and the inrush current is negligible; (6) open precharge contactor — all current now flows through the low-resistance main path; (7) confirm current balance (both main contactors carrying equal current, precharge path open). The ordering matters: if you close the positive main contactor before precharge is complete, you get the full 4,000 A inrush. If you close the positive contactor before the negative, you energise the bus through the precharge path but with no return path through the main contactor — the precharge resistor sees the full load current indefinitely. This sequence is governed by the BMS state machine and typically completes in 200–500 ms.

The opening sequence deserves equal attention. When the BMS commands the contactors to open — whether for a normal shutdown or an emergency disconnect — the contactors must interrupt whatever current is flowing at that instant. In AC power systems, the current naturally passes through zero twice per cycle, providing a natural arc-extinction point. DC systems have no such luxury: a DC arc, once struck between the separating contacts, can sustain itself indefinitely if the voltage and current are sufficient. For a 400 V pack delivering 200 A, the arc energy during a 5 ms contact separation can reach hundreds of joules — enough to erode the contacts and eventually weld them shut (the same failure mode as uncontrolled inrush, but during opening rather than closing).

The countermeasures are familiar from power electronics: **magnetic blowout coils** that deflect the arc into an arc chute where it is cooled and extinguished, **snubber capacitors** across the contacts that absorb the inductive energy spike at current interruption, and — most importantly — BMS coordination with the motor controller to reduce the load current to near-zero before commanding the contactors open during normal shutdown. Emergency disconnects, where the contactors must open under full load, are the most stressful events for the contactor hardware and are tested to a defined number of operations (typically 1,000–5,000 emergency breaks over the contactor's lifetime). This is why BMS fault response strategies try to reduce current before opening contactors whenever the fault allows even a few hundred milliseconds of reaction time.

### Fuses and Overcurrent Protection

Each series string in the pack — and the pack as a whole — is protected by fuses or circuit breakers. The primary fuse, typically a **high-voltage pyrotechnic fuse** (a chemically actuated fuse that can interrupt fault currents of tens of kiloamperes in milliseconds), is located in series with the main HV bus. It provides the last line of protection against catastrophic fault currents that exceed the contactors' interruption capability.

In addition to the main HV fuse, individual cell strings or modules may be fused separately, providing protection against internal faults within the module without disconnecting the entire pack. The selection of fuse ratings involves a trade-off: the fuse must not blow during normal high-current operation (maximum motor current, regenerative braking peak), but must blow quickly enough during a fault to prevent catastrophic damage. This selectivity requirement means that the fuse's time-current characteristic must be carefully matched to the rest of the system's protection coordination — standard power systems engineering, applied to EV-scale voltages and currents.

**Current interruption devices (CIDs)** on individual cylindrical cells (discussed in Chapter 8) provide another layer of protection at the cell level, disconnecting cells that have developed excessive internal pressure from gas generation.

### Current Sensing: Hall Effect and Shunt Methods

Accurate current measurement is the foundation of coulomb counting (SOC estimation), power calculation, and fault detection in a BMS. Two measurement approaches dominate:

**Hall-effect current sensors**: A current-carrying conductor passes through a magnetic core. The magnetic field induced by the current is measured by a Hall-effect transducer. Hall sensors are electrically isolated from the HV bus (the Hall element is in the low-voltage measurement circuit), which is important for safety. They respond quickly (bandwidth up to several kHz), allowing them to capture transients. The accuracy is typically ±0.5–1% of full scale for automotive-grade sensors, with an offset (zero-current reading) that can drift over time and temperature — a source of coulomb counting error.

**Shunt resistors**: A precision low-resistance shunt (typically 0.1–2 mΩ) is inserted in series with the HV bus. The voltage drop across the shunt is proportional to the current. Shunt measurements have no magnetic saturation, excellent linearity, and high accuracy (±0.1–0.5% of full scale for precision shunts) — but they require the measurement electronics to be referenced to the HV bus potential, which requires careful isolation of the analog measurement circuitry. Shunt resistors also dissipate power ($P = I^2 R_\text{shunt}$): at 200 A continuous with a 1 mΩ shunt, $P = 200^2 \times 10^{-3} = 40$ W — a significant power loss that must be thermally managed.

Modern BMS designs often use both: a Hall sensor for primary current measurement (isolated, fast) and a shunt for secondary measurement and calibration (accurate, but HV-referenced). The two measurements provide redundancy and mutual error-checking.

A third sensing technology is gaining traction in automotive BMS: **magnetoresistive (xMR) sensors** (including AMR, GMR, and TMR variants), which measure the magnetic field from the bus current using thin-film resistance elements rather than the Hall effect. xMR sensors offer better zero-current offset stability and lower temperature drift than Hall sensors, while maintaining galvanic isolation. As of 2025, TMR-based current sensors from manufacturers such as TDK and Allegro are appearing in production BMS designs, and you may encounter them in recent datasheets alongside or replacing traditional Hall sensors.

The accuracy of current measurement directly limits the accuracy of SOC estimation by coulomb counting. A 0.5% current measurement error means that over a 1C discharge (3600 seconds), the integrated charge error grows to approximately 0.5% of capacity — seemingly small, but equivalent to 15 mAh error in a 3 Ah cell. Over multiple cycles, if the error is systematic (biased high or low rather than random), the accumulated error can drift significantly. This is why battery management algorithms incorporate periodic SOC recalibration events (rest periods where OCV is measured and used to reset the coulomb count) — the coulomb counting integral is accurate for short-term dynamics but needs anchor points from voltage measurements.

### Isolation Monitoring

At high voltage, the insulation between the HV bus and the vehicle chassis (which is at chassis ground, typically connected to the 12V system negative) must be maintained to prevent electric shock hazard. **Isolation resistance** between the HV bus and chassis ground must remain above a minimum value — typically 100–500 Ω/V of bus voltage, or 40–200 kΩ for a 400V system — to comply with automotive safety standards (ISO 6469, FMVSS 305). The Ω/V unit reflects the underlying safety requirement: the leakage current through the insulation (equal to $V_\text{bus}/R_\text{insulation}$) must stay below a safe threshold regardless of bus voltage. Specifying isolation resistance in Ω/V ensures that a 400V system requires proportionally higher insulation resistance than a 48V system to achieve the same maximum leakage current. Think of it as a minimum impedance normalised to voltage — analogous to how per-unit impedance in power systems normalises to base voltage.

An **isolation monitoring device (IMD)** continuously measures the insulation resistance by injecting a small, safe-level AC or DC test signal between the HV bus and chassis and measuring the resulting current. If the insulation resistance falls below the threshold (due to water ingress, damaged wire insulation, or a cell can short to the chassis), the IMD triggers a fault and the BMS opens the contactors. This function is required for all road vehicles with HV systems and is a critical safety feature — a loss of isolation in a wet environment can cause electric shock to occupants or first responders.

---

## CAN Bus and BMS Communication Basics

A battery management system is not a monolithic device — it is a distributed system of sensors, processors, and actuators that must exchange information in real time. The communication architecture that connects these components is as important as the hardware itself, and the dominant standard in automotive applications is the **Controller Area Network (CAN) bus** — a protocol you may know from automotive electronics that we will now see applied specifically to battery management.

### Why a Dedicated Communication Network?

A battery pack in an EV contains, at minimum, the following subsystems that must communicate: a **master BMS** (the central controller that makes system-level decisions), multiple **cell monitoring ICs (CMICs)** measuring individual cell voltages and temperatures across the pack, a **current sensor module** measuring pack current, **contactor drivers and feedback circuits** controlling and monitoring the HV contactors, **balancing circuits** (active or passive, covered in Chapter 11), an **isolation monitoring device (IMD)**, and **thermal management actuators** (coolant pump, cooling fans, heaters). These components may be physically distributed across a large pack (up to 2 metres long in an EV floor-mounted pack) and must exchange data reliably in real time, in the presence of electrical noise from the inverter and motor. A robust communication protocol is essential.

### CAN Bus Fundamentals

The **CAN bus** (ISO 11898) is a two-wire, differential serial protocol originally developed by Bosch in the 1980s for automotive control systems. Its key properties make it well-suited to battery management:

**Differential signaling**: The two wires (CANH and CANL) carry complementary signals. The receiver measures the voltage difference between them. Common-mode noise (which appears equally on both wires) is rejected by the differential receiver. This makes CAN robust against electromagnetic interference from high-current switching transients in the inverter and motor — interference that would corrupt a single-ended communication signal.

**Multi-master, collision detection**: Any node on the CAN bus can transmit at any time. If two nodes transmit simultaneously, the collision is resolved through a deterministic, non-destructive arbitration process. Each transmitting node sends its message ID bit-by-bit onto the bus. The bus uses a wired-AND electrical topology: a dominant bit (logic 0) overwrites a recessive bit (logic 1). As each node transmits its ID, it simultaneously reads the bus. If a node transmits a recessive bit but reads a dominant bit, it knows another node with a lower (higher-priority) ID is also transmitting, and it backs off. The winning node's transmission continues uninterrupted — no data is lost and no retransmission is needed. This is elegant because it provides deterministic, priority-based access without a central arbiter, and the highest-priority message always wins with zero latency penalty. In BMS design, fault alerts are assigned the lowest message IDs so they always win bus arbitration.

**Message-based, broadcast**: CAN messages are broadcast to all nodes on the bus. Every node receives every message and decides whether it is relevant based on the message ID. There is no addressing — the message ID itself encodes both the source of the message and its content type. The master BMS broadcasts control commands and receives telemetry from all cell monitoring nodes.

**Error detection and fault confinement**: CAN includes multiple error-detection mechanisms (CRC check, bit stuffing, ACK field). A node that generates persistent errors is automatically isolated (moved to error passive state, then bus-off state), preventing a single failed node from corrupting the entire bus.

For automotive battery systems, two CAN variants are common: **CAN 2.0B** (classical CAN, 1 Mbit/s maximum) for most BMS communication; and **CAN FD** (CAN with Flexible Data rate, up to 8 Mbit/s) for higher-bandwidth applications like physics-based model data transfer or high-frequency thermal monitoring in advanced BMS designs.

### BMS Communication Architecture

A typical EV BMS has two communication layers:

**Internal BMS network**: Cell monitoring ICs (CMICs), current sensors, and thermal sensors communicate with the master BMS controller over an internal protocol. For large packs with many CMICs, **daisy-chained** communication architectures are common. In a daisy chain, each CMIC is connected only to its immediate neighbours: it receives data from the CMIC below it in the series stack, appends its own cell voltage and temperature readings, and passes the combined data up to the next CMIC. The last node in the chain transmits the entire pack's measurement data to the master BMS. This topology minimises wiring (only nearest-neighbour connections, not star wiring back to a central node) and naturally accommodates the galvanic isolation required between CMICs that reference different points on the HV series stack. Some manufacturers use isolated SPI (Serial Peripheral Interface) or I²C for the CMIC-to-master link rather than CAN, because the cell voltage measurement nodes must reference different parts of the HV stack and require galvanic isolation between them.

**External vehicle network**: The master BMS communicates with the vehicle's other control modules — the main vehicle controller, the thermal management ECU, the charging ECU, the instrument cluster — via the vehicle CAN bus. On this bus, the BMS broadcasts pack-level state information (SOC, SOH, pack voltage and current, temperature, fault codes, power limits) and receives commands (requested current, desired SOC setpoint for charging, thermal preconditioning request).

The specific messages broadcast by a BMS on the vehicle CAN bus are standardised to varying degrees. The **Open Vehicle Monitoring System (OVMS)** and **CANDB++ DBC** file formats are widely used to document and decode BMS CAN messages. For EV fleet management and research, the ability to parse BMS CAN data is an essential skill — it provides real-time access to all the metrics we defined in Chapter 3 (SOC, SOH, temperature, current, voltage) directly from the running vehicle.

### BMS Message Content and Timing

A master BMS typically broadcasts the following data on the vehicle CAN bus, at various update rates:

**Fast messages (10–100 ms cycle)**: Pack current (needed for drivetrain torque control), pack voltage, maximum cell temperature (for thermal protection), contactor state. These are transmitted frequently because the motor controller and thermal management system need near-real-time data to regulate torque and cooling.

**Medium messages (100 ms–1 s cycle)**: SOC (state of charge, updated by coulomb counting every cycle), individual cell voltages (for the cluster display and BMS diagnostics), minimum and maximum cell temperature.

**Slow messages (1–10 s cycle)**: SOH, estimated remaining range, fault codes, balancing status, accumulated energy throughput (for warranty tracking).

**Event-triggered messages**: Fault alerts, contactor state changes, emergency shutdown commands. These are transmitted immediately when the triggering condition is detected, regardless of scheduled cycle timing.

The volume of data from a large pack is substantial. A $96\text{s}2\text{p}$ pack in the parallel-first topology requires 96 cell-group voltage readings per update cycle (each parallel group shares a common terminal voltage that is monitored as a single channel). At 10 ms cycle time and 16-bit resolution per voltage, the raw data rate is $96 \times 2 / 0.01 = 19.2$ kByte/s — well within CAN's 1 Mbit/s bandwidth, but requiring careful message scheduling to avoid bus congestion during peak measurement periods. For larger packs (e.g., $96\text{s}48\text{p}$ with 4,608 cells), the number of monitored channels is still 96; it is the series count $n_s$, not the total cell count, that determines the CMIC channel count in a parallel-first architecture.

### The BMS State Machine

The BMS's core logic is a state machine that governs pack operation. The states and transitions are defined by IEC 62619 (for stationary storage) and by OEM-specific specifications for vehicles. A minimal BMS state machine includes:

**IDLE/STANDBY**: Both contactors open. Pack is isolated from load/charger. Periodic cell monitoring continues (voltage, temperature, SOC update via minimal self-discharge correction). Pack waits for a connect command.

**PRECHARGING**: Negative contactor closed, precharge contactor closed. Pack voltage is being applied to load through precharge resistor. BMS monitors load voltage rise toward pack voltage.

**ACTIVE**: All main contactors closed. Pack is connected to load or charger. Full BMS monitoring active (cell voltages, temperatures, current, fault detection). Power limits enforced in real time.

**FAULT**: One or more fault conditions detected (overcurrent, overvoltage, undervoltage, overtemperature, undertemperature, cell imbalance threshold exceeded, contactor weld detected, isolation loss). BMS opens contactors and logs fault codes. Recovery from fault may be automatic (after fault condition clears and a reset command is received) or may require manual intervention (for safety-critical faults).

**CHARGING**: Similar to ACTIVE but with charge-specific monitoring (upper voltage cutoff enforcement, charge current taper logic, temperature limits for charging).

**BALANCING**: Sub-state of IDLE or ACTIVE. Balancing circuits enabled. BMS monitors cell voltage convergence and disables balancing when balanced.

The state machine is implemented in the master BMS controller's firmware and is the heart of the BMS software architecture. Chapter 12 will address functional safety requirements for this firmware (ISO 26262 compliance), but the state machine structure itself is the operational framework that all the algorithms in Chapters 10 and 11 run within.

---

## Worked Interpretation Exercise: Reconstructing Pack Parameters from CAN Bus Data

Let us apply the chapter's content to a practical scenario that you will encounter in real research: extracting and interpreting CAN bus data from a commercial EV battery system.

Suppose you are working with a **second-generation Nissan Leaf (2018–present)** with a 40 kWh battery pack. The Nissan Leaf BMS broadcasts pack data on a 500 kbit/s CAN bus. The following data frames have been observed in the CAN log (representative values drawn from published Leaf CAN documentation and open-source decoders):

**Frame 0x55B (broadcast at 100 ms)**: Decoded fields include PackVoltage = 371.2 V, PackCurrent = −42.5 A (negative = charging, positive = discharging; the Leaf uses a sign convention where charging current is negative), AverageCellTemperature = 24.3°C.

**Frame 0x5BC (broadcast at 100 ms)**: Fields include SOC_display = 73.0% (the value shown to the driver on the instrument cluster), SOC_internal = 75.2% (the BMS's actual working SOC estimate, not directly shown to the driver), Available_Power_kW = 95.4 kW.

**Frame 0x1DB (broadcast at 10 ms)**: BatteryCurrentSensor = −42.5 A (confirming the charging current), HV_ContactorState = 0x03 (both contactors closed).

Now let us interpret these values against the pack architecture we know.

**Pack configuration**: The second-generation 40 kWh Leaf pack uses $96\text{s}2\text{p}$ with Leaf-specific NMC/graphite pouch cells (nominal ~56 Ah per cell, 3.75 V nominal). Check: $E_\text{pack} = 96 \times 3.75 \times 2 \times 56 = 40{,}320$ Wh $\approx 40$ kWh — consistent with the rated capacity. The nominal pack voltage is $V_\text{pack} = 96 \times 3.75 = 360$ V. The 371.2 V reading is consistent with a nominal 360V pack at approximately 75% SOC (above the 360V nominal, indicating the OCV at 75% SOC is above nominal voltage — consistent with a sloped NMC OCV curve above mid-SOC). Verified.

**Current interpretation**: $-42.5$ A with both contactors closed means the pack is accepting 42.5 A of charge current. At 371.2 V, the charging power is $371.2 \times 42.5 = 15{,}776$ W $\approx 15.8$ kW. This is well above the Leaf's standard 6.6 kW Level 2 onboard charger but below its 50 kW CHAdeMO DC fast charging peak. The 15.8 kW DC-side power is most likely a CHAdeMO session at a reduced rate (the charger or BMS may have limited power due to SOC, temperature, or grid constraints), or it could correspond to AC charging through the optional 22 kW three-phase onboard charger available in European markets. Notice how the CAN data alone does not tell you the charging source — it tells you the DC-side power being delivered to the pack, and you must infer the source from the power level and context.

**SOC discrepancy**: The display SOC (73%) and internal SOC (75.2%) differ by 2.2 percentage points. This is deliberate — the Leaf (like most BEVs) displays a protected SOC that has safety margins applied at both ends: the display reads 0% before the pack is actually empty (protecting against deep discharge), and reads 100% before the pack is actually full (protecting against overcharge). The 2.2% gap at 75% display SOC suggests the protection buffer is larger at the bottom of the range (0% display = ~2% actual SOC) and smaller or zero at top of range for this particular state.

**Available power**: 95.4 kW is the BMS's estimated maximum discharge power available at this SOC and temperature. This is computed from the HPPC-derived $R_\text{int}(\text{SOC}, T)$ map and the minimum allowed cell voltage, using the power-limiting equations:

$$I_\text{max,discharge} = \frac{V_\text{OCV,pack} - n_s \cdot V_\text{min,cell}}{R_\text{int,pack}} \tag{9.11a}$$

$$P_\text{max,discharge} = I_\text{max,discharge} \times n_s \cdot V_\text{min,cell} \tag{9.11b}$$

Here $V_\text{OCV,pack}$ is the present open-circuit voltage of the pack (a function of SOC and temperature) and $n_s \cdot V_\text{min,cell}$ is the pack terminal voltage at which discharge must stop. The BMS uses the HPPC-derived $R_\text{int}(\text{SOC}, T)$ map to evaluate this limit in real time. Notice that the deliverable power at maximum current is $I_\text{max} \times V_\text{min}$, not $I_\text{max} \times V_\text{OCV}$, because at the maximum current the terminal voltage has dropped to its lower limit.

At 75% SOC and 24°C, the internal resistance is moderate and the OCV is comfortably above the minimum cell voltage, allowing full power delivery. This value would decrease as the pack cools, as SOC decreases, or as the pack ages.

This kind of CAN bus analysis — taking raw decoded frames and reconstructing the pack state, verifying against known architecture, and extracting derived quantities — is a standard workflow in EV battery research and in BMS development validation testing.

---

## What Changes for Sodium-Ion?

Pack architecture for sodium-ion batteries follows the same series-parallel topology, contactor/precharge/fuse design, and CAN communication framework as lithium-ion packs. The engineering changes are in the specific parameters, not the structural approach.

**Voltage per cell**: SIB cells have a lower nominal voltage than NMC LIB cells (3.1–3.2 V vs. 3.6–3.7 V). To achieve the same pack voltage (say, 350 V for a 400V-class system), a SIB pack needs more cells in series: approximately $350/3.15 \approx 111$ series cells vs. $350/3.65 \approx 96$ for NMC. This additional series cell count increases the number of cell monitoring channels required and slightly increases pack complexity per unit energy stored.

**Higher DCIR**: SIB cells generally exhibit higher internal resistance than LIB cells of similar capacity and format, owing to the lower ionic conductivity of Na$^+$ electrolytes and less mature electrode optimization. Typical values for commercial SIB cylindrical cells are 80–150 mΩ (in formats like 18650 or 26650), compared to 20–50 mΩ for comparable LIB cells in the same format. The exact ratio depends on chemistry, electrode design, and cell format — but expect SIB pack DCIR to be 2–4× higher than an equivalent LIB pack. Higher DCIR means higher ohmic losses at the same current, higher heat generation (Bernardi equation), and tighter BMS power limits. The precharge resistor sizing also changes slightly (higher $R_\text{int,pack}$ means the inrush current is somewhat lower for the same voltage, but the fundamental precharge requirement is unchanged).

**Flat OCV and BMS implications**: As discussed in detail in Chapters 3 and 6, the flat OCV plateau of hard carbon anodes creates a fundamental challenge for SOC estimation. In the series string context, this means that during the plateau region, individual cell voltage measurements provide almost no information about individual cell SOC — they are nearly identical regardless of the actual SOC distribution within the string. Standard voltage-based balancing algorithms (which drive cells toward the same terminal voltage) are particularly ineffective in this region. BMS algorithms for SIB packs must rely on coulomb counting during the plateau and use voltage only at the extremes of the SOC range where the OCV curve has slope. We will address this problem in detail in Chapter 10 and Chapter 13.

**Zero-volt discharge for transport and storage**: Unlike LIB cells, which suffer irreversible copper current collector dissolution if discharged below approximately 1.0–1.5 V (and are therefore shipped at 30–50% SOC with protective circuitry), most SIB cells can be safely discharged to 0 V without damage — a consequence of using aluminium (rather than copper) current collectors on both electrodes, since aluminium does not dissolve at low potentials the way copper does. This allows SIB packs to be shipped in a fully discharged, zero-energy state, which dramatically simplifies hazardous-goods transport regulations and reduces shipping costs. At the pack level, the BMS can also use 0 V discharge as a safe storage mode for packs awaiting installation or decommissioning, eliminating the self-discharge management and periodic recharging required for stored LIB packs.

**Aluminium current collectors on both sides**: As established in Chapter 4, SIB cells use aluminium current collectors for both anode and cathode. This has a small but non-zero implication for pack-level design: the busbar connections and cell interconnect designs must accommodate aluminium terminal tabs rather than the copper/aluminium combination of LIB cells. Aluminium-to-aluminium interconnects are actually easier to weld consistently (no bimetallic galvanic couple), which simplifies pack assembly.

**Safety design**: The higher thermal runaway onset temperature for SIB cells (Section 8.7) allows somewhat more relaxed thermal runaway propagation prevention requirements. The gap between the maximum ambient temperature and the self-heating onset temperature is larger for SIBs, providing a greater safety margin. This may allow smaller thermal barriers between cells and less stringent thermal management requirements in hot-climate deployments — a commercial advantage that is beginning to be quantified in pack-level safety testing.

---

## Chapter Summary

**Key ideas:**

- Series connection adds voltages and internal resistances; capacity remains that of a single cell. All cells in a series string carry the same current; the weakest cell (lowest capacity) limits the string's accessible capacity. Internal resistance also sums in series.
- Parallel connection adds capacities; voltage remains that of a single cell. Internal resistance divides as a parallel combination. Current distributes inversely proportional to individual cell resistance — mismatched cells experience unequal stress.
- Pack notation is $n_s\text{s}n_p\text{p}$: $V_\text{pack} = n_s V_\text{cell}$; $Q_\text{pack} = n_p Q_\text{cell}$; $N_\text{total} = n_s \times n_p$. Energy = $V_\text{pack} \times Q_\text{pack}$.
- Cell-to-cell variation (±0.5–2% capacity spread, ±5–15% resistance spread at BOL) propagates through the series string as SOC divergence over cycling. The weakest cell limits pack capacity. Temperature non-uniformity compounds initial variation by accelerating degradation in hotter cells. Cell grading at manufacturing reduces but cannot eliminate initial variation.
- Precharge is mandatory before closing main contactors to prevent inrush current damage. The precharge resistor limits inrush by charging the load's input capacitors through a time constant $\tau = R_\text{pc} C_\text{bus}$ before the main contactor closes. Precharge energy $\frac{1}{2}CV^2$ must be dissipated in the precharge resistor. DC arc suppression during contactor opening requires magnetic blowout, snubbers, and BMS-coordinated current reduction.
- Current sensing uses Hall-effect sensors (isolated, fast, moderate accuracy), shunt resistors (non-isolated, accurate, generates heat), or emerging magnetoresistive (xMR) sensors (isolated, low drift). Redundant sensing is standard in critical applications. Current measurement accuracy directly determines coulomb counting accuracy and SOC estimation quality.
- CAN bus is the dominant communication protocol for automotive BMS applications. Differential signaling, non-destructive priority-based arbitration, and built-in error detection make it robust in electrically noisy environments. The BMS broadcasts fast (10–100 ms) and slow (1–10 s) messages covering pack state, fault status, and power limits.
- BMS state machine governs transitions between IDLE, PRECHARGING, ACTIVE, CHARGING, FAULT, and BALANCING states. All estimation and protection algorithms (Chapters 10–12) execute within this state machine framework.

**Key equations:**

$$V_\text{pack} = n_s V_\text{cell} \tag{9.1}$$

$$Q_\text{pack} = n_p Q_\text{cell} \tag{9.5}$$

$$E_\text{pack} = n_s n_p \, V_\text{cell} \, Q_\text{cell}$$

$$R_\text{pack,series} = n_s R_\text{cell};\quad R_\text{pack,parallel} = R_\text{cell}/n_p \tag{9.3, 9.6}$$

$$I_\text{inrush} = V_\text{pack}/R_\text{pack,int} \quad \text{(without precharge)} \tag{9.8}$$

$$\tau_\text{precharge} = R_\text{precharge} \times C_\text{bus} \tag{9.9}$$

$$E_\text{precharge} = \tfrac{1}{2}C_\text{bus}V_\text{pack}^2 \tag{9.10}$$

$$I_\text{max,discharge} = \frac{V_\text{OCV,pack} - n_s \, V_\text{min,cell}}{R_\text{int,pack}};\quad P_\text{max,discharge} = I_\text{max,discharge} \times n_s \, V_\text{min,cell} \tag{9.11}$$

**Key vocabulary (in order of appearance):**

Series string, parallel group, $n_s\text{s}n_p\text{p}$ notation, pack voltage, pack capacity, pack energy, cell count, series-first topology, parallel-first topology, cell-to-cell variation, capacity spread, resistance spread, OCV spread, self-discharge spread, weak link effect, SOC divergence, current imbalance, temperature non-uniformity, aging heterogeneity, cell grading, cell binning, contactor, precharge circuit, precharge resistor, precharge time constant, main positive contactor, negative contactor, inrush current, contact welding, magnetic blowout coil, snubber capacitor, pyrotechnic fuse, current interrupt device (CID), Hall-effect current sensor, shunt resistor, magnetoresistive (xMR) sensor, isolation monitoring device (IMD), insulation resistance, CAN bus (ISO 11898), CANH/CANL, differential signaling, multi-master arbitration, wired-AND arbitration, cell monitoring IC (CMIC), daisy-chain topology, BMS state machine, IDLE, PRECHARGING, ACTIVE, FAULT, BALANCING.

---

## Deliverable

The deliverable for Chapters 9–12 is the same unified exercise from the chapter plan: completing Plett's Coursera specialisation "Algorithms for Battery Management Systems," Courses 1 and 2, and working through the MATLAB assignments. This chapter is the architectural foundation for that work.

Before starting Course 1, ensure you can answer the following from this chapter:

Given a pack specification of $144\text{s}3\text{p}$ using Samsung INR21700-50E cells (4.9 Ah, 3.6 V nominal, 35 mΩ DCIR), compute: nominal pack voltage; pack capacity (Ah); pack energy (Wh); total cell count; pack DCIR (mΩ). Then: compute the maximum continuous discharge current for a power limit of 150 kW; verify the precharge time constant for a 2 mF input capacitance and 33 Ω precharge resistor; calculate the energy dissipated in the precharge resistor per connect event.

**Worked answers**: $V = 144 \times 3.6 = 518.4$ V; $Q = 3 \times 4.9 = 14.7$ Ah; $E = 518.4 \times 14.7 = 7{,}620$ Wh $= 7.62$ kWh; $N = 144 \times 3 = 432$ cells; $R_\text{pack} = 144 \times 35/3 = 1{,}680$ mΩ $= 1.68$ Ω.

Maximum discharge current: $I = P/V = 150{,}000/518.4 = 289$ A.

**A critical sanity check**: the 289 A pack current divides among 3 parallel strings, so each cell carries $289/3 \approx 96$ A. For a 4.9 Ah cell, this is a C-rate of $96/4.9 \approx 19.6$C — far beyond the Samsung 50E's continuous discharge rating of approximately 9.8 A (2C). This tells you that a $144\text{s}3\text{p}$ configuration of high-energy 50E cells cannot deliver 150 kW continuously; the cell's current rating, not the pack's voltage and resistance, is the binding constraint. To deliver 150 kW from this voltage rail, you would need either more parallel strings (increasing $n_p$ until per-cell current falls within the rated limit: $n_p \geq 150{,}000 / (518.4 \times 9.8) \approx 30$ strings) or a switch to high-power cells with a higher continuous current rating. This is the central tension in pack design: high-energy cells (optimised for Wh/kg) have low C-rate limits, and high-power cells (optimised for W/kg) have lower capacity. The pack topology must satisfy both the system-level power requirement and the cell-level current constraint simultaneously.

Precharge time constant: $\tau = 33 \times 2 \times 10^{-3} = 66$ ms. Charging to 99% takes $5\tau = 330$ ms.

Precharge energy: $E = \frac{1}{2} \times 2 \times 10^{-3} \times 518.4^2 = 268.6$ J. This must be dissipated in the precharge resistor — roughly a quarter of a kilojoule per connect event. While modest in isolation, if the vehicle cycles on and off dozens of times per day (fleet vehicles, delivery vans), the cumulative thermal load on the precharge resistor requires attention to its pulse energy rating and thermal derating.

---

## Further Reading

1. **Plett, G. L., *Battery Management Systems, Vol. 1: Battery Modeling*, Artech House (2015), Chapter 1.** Plett's first chapter covers cell and pack electrical models including the series/parallel topology analysis in a form directly compatible with the MATLAB/Simulink modelling work in his Coursera course. Chapters 1–2 are the direct preparatory reading for Part VI of this book.

2. **Plett, G. L., *Battery Management Systems, Vol. 2: Equivalent-Circuit Methods*, Artech House (2015), Chapter 1.** Volume 2's opening chapter addresses how cell-to-cell variation propagates through a pack model — the material of Section 9.2 in quantitative form. Essential reading before tackling the pack-level estimation algorithms.

3. **Hoque, M. M. et al., "Battery charge equalization controller in electric vehicle applications: A review," *Renewable and Sustainable Energy Reviews* 75, 1363–1385 (2017).** A comprehensive review of cell balancing architectures and topologies — the electrical engineering foundation for Chapter 11. Covers passive and active balancing circuits, control algorithms, and comparative analysis of energy efficiency.

4. **Xiong, R. et al., *Battery Management Algorithm for Electric Vehicles*, Springer (2020), Chapter 2.** A detailed treatment of BMS hardware architecture including contactor circuits, precharge design, current sensing selection, and isolation monitoring — with automotive-specific design examples. Chapter 2 is the most directly relevant to Section 9.3.

5. **Bosch, *CAN Specification Version 2.0*, Robert Bosch GmbH (1991), available at www.bosch-semiconductors.com.** The original CAN specification, still the authoritative reference. Remarkably readable for a hardware protocol spec. Section 3 (bit timing, arbitration, error handling) is directly relevant to understanding the robustness properties described in Section 9.4.


# Chapter 11: Cell Balancing

## Chapter Opening

In Chapter 9 we established the uncomfortable truth about series strings: the weakest cell wins. The cell with the least capacity, or the highest internal resistance, or the most degraded state, dictates when the entire string must stop charging and when it must stop discharging — even if every other cell still has capacity to give or headroom to receive. The efficiency penalty from this mismatch is real, the degradation consequence is compounding, and the problem grows worse every cycle as the cells diverge further. Left uncorrected, a pack that starts with a ±1% capacity spread can develop ±10% divergence after a few hundred cycles, and the effective pack capacity shrinks to the capacity of the worst cell multiplied by the number of series cells — a fraction of the original rating.

Cell balancing is the engineering response to this problem. It is the set of techniques by which the BMS actively counteracts the divergence between cells in a series string, keeping them aligned so that all cells can be charged and discharged to the same extent without any cell hitting its voltage limits ahead of the others. Done well, balancing extends pack life, increases usable energy, and reduces the burden on the SOC estimation algorithms from Chapter 10. Done poorly — or not done at all — it accelerates exactly the degradation cascade described in Chapter 7.

This chapter builds the complete picture of cell balancing: the physical origins of imbalance, its quantitative consequences, the two main hardware architectures for correction (passive and active), and the control strategies that govern when and how much to balance. We will pay particular attention to a subtlety that is often glossed over in treatments of balancing: there is not one kind of imbalance, but two — **SOC imbalance** (cells at different states of charge despite being in the same string) and **capacity imbalance** (cells with different maximum capacities) — and these two types require different strategies. We will also examine the interaction between balancing and the flat-OCV problem of SIB cells, which creates specific complications that have no direct analogue in lithium-ion systems.

By the end of this chapter, you will be able to evaluate a balancing circuit schematic, compute its energy dissipation and balancing time, assess whether a given imbalance profile calls for top-balancing or bottom-balancing, and identify the architectural limitations that make passive balancing an approximation rather than a perfect solution. You will also understand why the choice of balancing strategy interacts non-trivially with the OCV curve shape — a connection that will matter deeply for SIB system design.

---

> **Prerequisites Check**
>
> From your EE background:
>
> - Basic circuit analysis: resistive voltage dividers, switched circuits, inductor/capacitor energy storage
> - DC-DC converter topologies (buck, boost, flyback) at a conceptual level — helpful for active balancing topologies
> - Power dissipation calculations — needed throughout
>
> From Chapter 3:
>
> - SOC, DOD, OCV definitions (Section 3.3, 3.4) — the quantities being balanced
> - Cycle life vs. DOD relationship (Section 3.7) — motivates shallow cycling via balancing
>
> From Chapter 9:
>
> - Cell-to-cell variation and the weak-link effect in series strings (Section 9.2) — the problem being solved
> - Series/parallel pack topology (Section 9.1) — the system context
>
> From Chapter 10:
>
> - OCV-SOC curve shape and its effect on voltage-based SOC estimation (Section 10.2) — interacts with voltage-based balancing triggers
> - The flat-OCV problem for SIBs (Section 10.2) — creates specific complications for balancing control

---

## 11.1 Why Cells Drift: The Physical Origins of Imbalance

Before designing a balancing system, we need a precise understanding of what is being balanced. The word "imbalance" in a battery pack can refer to at least three distinct conditions, each with a different physical origin and a different appropriate response. Conflating them leads to balancing strategies that address the symptom rather than the cause.

### Type 1: SOC Imbalance

**SOC imbalance** means that cells in the same series string are at different states of charge — some have more energy stored than others. This is the most directly actionable type of imbalance: it can be corrected by balancing circuits without permanently removing capacity from the system. The energy moved from a high-SOC cell to a low-SOC cell (or dissipated from the high-SOC cell in passive balancing) brings them closer to alignment. Once balanced, all cells can participate equally in the next charge or discharge.

SOC imbalance accumulates from several sources. **Self-discharge rate differences** between cells cause SOC to drift during rest. If cell A discharges itself at 0.1%/day and cell B at 0.3%/day, after 30 days of storage the two cells differ by 6% SOC — with no cycling having occurred at all. For automotive packs that may sit idle for weeks, self-discharge imbalance can be the dominant source of misalignment requiring correction.

**Thermal gradients** within the pack cause position-dependent self-discharge and degradation rates. Cells near a warm section of the pack age faster, lose more capacity per cycle, and develop higher internal resistance — all of which contribute to differential SOC trajectories during cycling, even if the cells started perfectly matched.

**Manufacturing variation** in initial Coulombic efficiency means that after formation cycling, cells that consumed more active ion inventory (lithium or sodium) to build their SEI have less remaining cyclable inventory and thus a slightly different SOC trajectory than more efficient cells, even under identical current profiles. This effect is small (a fraction of a percent of SOC per cycle) but accumulates over hundreds of cycles.

**Parasitic reaction rate heterogeneity**: self-discharge in lithium-ion and sodium-ion cells is dominated not by electron leakage through the separator (which would indicate a defect) but by parasitic electrochemical reactions — ongoing SEI growth that consumes cyclable lithium or sodium inventory, low-level electrolyte oxidation at the cathode surface, and, in some chemistries, redox shuttle mechanisms that transfer charge internally. These reactions proceed at rates that depend on temperature, electrode surface area, and electrolyte composition — all of which vary slightly from cell to cell. Over time, small differences in parasitic reaction rates accumulate into measurable SOC divergence. In aged cells, where increased surface area from particle cracking accelerates side reactions, this effect can become significant even between cells from the same manufacturing batch.

### Type 2: Capacity Imbalance

**Capacity imbalance** means that cells have different maximum capacities $Q_{\text{max},i}$ — one cell can store more charge than another. This is a more fundamental type of imbalance because it cannot be fixed by moving charge between cells. No matter how perfectly the SOC is balanced, a string containing one 2.4 Ah cell and eleven 3.0 Ah cells will always be limited by that 2.4 Ah cell — the pack capacity is determined by the lowest-capacity cell in the string.

Capacity imbalance accumulates primarily from differential degradation. Cells that run hotter, cycle at higher effective DOD, or experience more severe lithium plating lose capacity faster than their neighbours. The self-reinforcing mechanism from Chapter 9 applies: the lower-capacity cell cycles over a larger DOD fraction (because it must provide the same charge as the others from a smaller reservoir), which accelerates its degradation, which further reduces its capacity, which forces an even larger DOD fraction. Left unchecked, this feedback leads to one cell reaching its end-of-life criterion (80% capacity retention) long before the majority of the pack, triggering early pack retirement.

Capacity imbalance cannot be corrected by balancing — balancing can only equalise the current SOC, not the maximum capacity. The long-term strategy for managing capacity imbalance is to slow the divergence (through good thermal management and preventing individual cells from cycling at extreme DOD) and to account for it in SOH estimation and RUL prediction. When the pack is retired, the imbalance is why: one cell has reached EOL while the majority still have usable life remaining.

### Type 3: Internal Resistance Imbalance

**Resistance imbalance** means that cells have different internal resistances, causing them to produce different terminal voltages under the same current load. The highest-resistance cell in the string has the largest voltage excursion for a given current: it hits its upper voltage cutoff soonest during charging, and its lower voltage cutoff soonest during discharging. The pack is limited by this worst-case cell.

Resistance imbalance also causes unequal heat generation among cells (since $\dot{Q} = I^2 R$, the highest-resistance cell runs hottest), which compounds the thermal non-uniformity problem and accelerates differential degradation. A positive feedback loop develops analogous to the capacity imbalance case: high-resistance cells run hot, degrade faster, develop even higher resistance, run even hotter.

Unlike SOC imbalance, resistance imbalance cannot be corrected by charge redistribution. The BMS can only manage its consequences: by computing cell-specific power limits (the most resistive cell has the tightest power limit), by using resistance-based SOH tracking to identify cells that are degrading fastest, and by setting pack-level current limits that protect the most resistant cell.

The table below summarizes the three imbalance types and their key characteristics. Keep it in mind as we discuss balancing strategies — it clarifies which problems balancing can solve and which it cannot.

| Imbalance type | Physical quantity | Primary causes | Correctable by balancing? | Management strategy |
| --- | --- | --- | --- | --- |
| SOC imbalance | Different states of charge ($\text{SOC}_i \neq \text{SOC}_j$) | Self-discharge variation, thermal gradients, Coulombic efficiency differences | Yes — redistribute or dissipate charge | Passive or active balancing |
| Capacity imbalance | Different maximum capacities ($Q_{\text{max},i} \neq Q_{\text{max},j}$) | Differential degradation (temperature, cycling depth, plating) | No — the capacity is physically lost | Thermal management, SOC window limits, cell replacement |
| Resistance imbalance | Different internal resistances ($R_i \neq R_j$) | Differential degradation (SEI growth, contact degradation) | No — the resistance is a physical property | Cell-specific power limits, SOH tracking |

### Why Both SOC and Capacity Imbalance Matter Simultaneously

In a real pack, all three types of imbalance coexist and interact. The practical consequence is that balancing addresses only Type 1 (SOC imbalance) while Types 2 and 3 accumulate over life. A pack with good balancing but poor thermal management will develop capacity and resistance imbalance that no balancing algorithm can fix — the balancing buys time and efficiency, but it does not halt the underlying divergence.

This is why battery engineers sometimes distinguish between **active state management** (redistributing charge to equalise SOC, which balancing circuits do) and **degradation management** (slowing the divergence through thermal management, SOC window optimisation, and charge rate limits, which is the responsibility of the overall BMS strategy). If you think of this in control-system terms: balancing is a feedback controller that can reject a disturbance (SOC drift from differential self-discharge) and keep the state variable (SOC) aligned across cells. But it cannot change the plant parameters — the cells' maximum capacities and internal resistances are physical properties that evolve with degradation and are beyond the reach of any charge-redistribution circuit. The controller compensates; it does not heal. Balancing is one tool in the larger degradation management toolkit, not a substitute for it.

---

## 11.2 Passive Balancing: Resistive Bleed

**Passive balancing** is the simplest and most widely deployed balancing architecture. It works by dissipating excess energy from the higher-SOC cells as heat, using a switchable resistor connected across each cell in the series string. The basic principle: if cell $i$ has a higher voltage than the pack average (indicating it is at higher SOC), close the switch to connect the bleed resistor across it; the resistor discharges the cell until its voltage falls to the target level.

### Circuit Architecture

The passive balancing circuit for each cell consists of three components: a **bypass resistor** $R_b$ (typically 10–100 Ω, chosen to limit dissipation), a **bypass switch** $S_b$ (typically a MOSFET or relay, controlled by the CMIC), and a **temperature sensor** monitoring the resistor temperature to prevent overheating. The resistor and switch are in series, forming a switchable discharge path across the cell terminals. The temperature sensor provides a safety interlock — if the resistor temperature exceeds a threshold, the CMIC opens the switch.

The **CMIC** (cell monitoring IC — the dedicated chip that monitors individual cell voltages and temperatures in a series string) measures each cell's voltage, compares it to the target voltage, and closes the bypass switch for cells that are above target. In the simplest implementation, the CMIC fires the bypass for any cell whose voltage exceeds the pack minimum by more than a threshold $\Delta V_\text{trig}$ (typically 10–30 mV). More sophisticated implementations close the bypass for a duty cycle proportional to the excess voltage, providing finer control over the balancing current.

The balancing current through the bypass resistor is simply Ohm's law applied to the cell-resistor loop:

$$I_b = \frac{V_\text{cell}}{R_b} \tag{11.1}$$

This looks trivial, but notice what it implies: the balancing current depends on the cell voltage, not on the SOC difference. For a chemistry like NMC, where the cell voltage varies significantly with SOC (from ~3.0 V at empty to ~4.2 V at full), the balancing current at the top of charge is about 40% higher than at the bottom — a natural acceleration of balancing when the cell is fullest and the voltage is highest. For flat-OCV chemistries like LFP or SIB hard carbon, where the cell voltage varies by only 50–100 mV across most of the SOC range, the balancing current is essentially constant regardless of SOC. We will revisit this observation in Section 11.7, where it creates a specific complication for SIB balancing strategy.

For a cell at 4.15 V with $R_b = 33$ Ω:
$$I_b = \frac{4.15}{33} = 125.8 \, \text{mA}$$

The heat dissipated in the bypass resistor is:

$$\dot{Q}_b = I_b^2 R_b = \frac{V_\text{cell}^2}{R_b} = \frac{4.15^2}{33} = 522 \, \text{mW}$$

And the time required to balance a SOC difference of $\Delta\text{SOC}$ for a cell of capacity $Q_\text{max}$ follows directly from Equation (11.1):

$$t_\text{bal} = \frac{\Delta\text{SOC} \times Q_\text{max}}{I_b} \tag{11.2}$$

For $\Delta\text{SOC} = 5\%$ and $Q_\text{max} = 3.0$ Ah:
$$t_\text{bal} = \frac{0.05 \times 3.0 \, \text{Ah}}{0.1258 \, \text{A}} = \frac{0.15 \, \text{Ah}}{0.1258 \, \text{A}} = 1.19 \, \text{h} \approx 72 \, \text{minutes}$$

Passive balancing is slow. At typical balancing currents of 50–200 mA, correcting a 5% SOC imbalance in a 3 Ah cell takes 45–180 minutes. This is why balancing is most effective when performed continuously (especially during charging, as we will see in Section 11.4) rather than only at the end of a cycle.

### Energy Efficiency of Passive Balancing

All the energy removed from the high-SOC cells in passive balancing is dissipated as heat in the bypass resistors. The round-trip energy efficiency of passive balancing is therefore always less than 100% — the excess charge is not transferred to the low-SOC cells; it is simply discarded.

The energy wasted per balancing event on one cell follows from Equations (11.1) and (11.2):

$$E_\text{wasted} = \Delta\text{SOC} \times Q_\text{max} \times V_\text{cell} \tag{11.3}$$

For the 5% imbalance example above:
$$E_\text{wasted} = 0.05 \times 3.0 \times 4.15 = 0.623 \, \text{Wh}$$

In a 96-cell string, if ten cells each require 5% SOC reduction at each charge cycle, the energy lost to passive balancing per cycle is approximately $10 \times 0.623 = 6.2$ Wh. For a 75 kWh pack that charges daily, this represents roughly 0.008% of pack energy per cycle — small per cycle, but over 1000 cycles it amounts to 6.2 kWh of wasted energy just from balancing. More significantly, the heat generated within the pack by balancing resistors must be managed by the thermal management system, adding to the cooling load.

Despite its energy inefficiency, passive balancing dominates commercial applications because of its simplicity and low cost. The bypass resistor and MOSFET required per cell add perhaps \$0.50–\$2.00 to the bill of materials and a few square millimetres to the PCB. The control logic is simple: compare cell voltage to threshold, set a bit. The reliability is excellent: a passive balancing circuit fails only if the resistor burns open or the MOSFET fails — rare events with well-designed circuits. For most consumer and automotive applications where the energy waste is small relative to pack energy, these advantages outweigh the thermodynamic inefficiency.

### Thermal Management of Bypass Resistors

The 522 mW dissipated per active bypass resistor in the example above is concentrated in a small component on the CMIC PCB. With many cells balancing simultaneously (as during top-of-charge equalisation), the total heat generated on the CMIC PCB can be 5–10 W per module — enough to require thermal management of the electronics, not just the cells. CMIC datasheets specify a maximum duty cycle for bypass operation, typically 50–70%, to prevent thermal overload of the resistor and the IC package. The BMS firmware must respect these limits and schedule bypass cycles accordingly, distributing the heat generation over time.

In very large packs (automotive, grid) where the bypass resistors are physically separate from the CMIC electronics — a configuration called the **remote bypass topology** — the thermal management is simpler. The heat-generating resistors are mounted on the busbar structure or on the cell holders, where the pack cooling system can remove the heat directly. Remote bypass topology also allows higher balancing currents (since the resistors can be larger and better cooled), reducing balancing time.

### When Is Passive Balancing Enough?

Before we survey the more complex active balancing architectures, it is worth asking: when does passive balancing fail to meet the system requirement? The answer depends on three factors — cell capacity, imbalance magnitude, and available balancing time — and their interplay determines whether the simplicity and cost advantage of passive balancing is worth its energy and time penalty.

Consider three representative applications:

| Application | Cell capacity | Typical imbalance | Balancing window | Passive $I_b$ at 33 Ω | Time to correct | Verdict |
| --- | --- | --- | --- | --- | --- | --- |
| Consumer electronics (laptop, phone) | 3–5 Ah | 1–3% SOC | 2–4 h charge session | 110 mA | 5–25 min | Passive is more than adequate |
| EV automotive (NMC pouch) | 50–80 Ah | 2–5% SOC | 6–10 h overnight charge | 110 mA | 15–60 h | Passive struggles; multiple sessions needed |
| Grid storage (LFP prismatic) | 100–280 Ah | 1–5% SOC | Continuous availability | 110 mA | 15–200+ h | Passive alone is impractical for large imbalances |

The pattern is clear: passive balancing is well-suited to small cells where the balancing current is a meaningful fraction of cell capacity (C/30 to C/50 for a 3 Ah cell), but becomes impractically slow for large cells where the same 100 mA balancing current represents C/500 or less. For large-format cells, the options are to increase the passive balancing current (requiring larger resistors and more thermal management), to accept very long balancing windows (running continuous balancing over many cycles), or to move to active balancing. Most automotive BMS designs choose the first option — using higher-current passive balancing in the 200–500 mA range with remote bypass resistors — because the added cost is modest compared to the full active balancing alternative. Grid storage systems increasingly adopt active or semi-active balancing, where the energy savings over a 20-year deployment life can justify the higher upfront hardware cost.

---

## 11.3 Active Balancing Topologies

**Active balancing** transfers charge between cells rather than dissipating it — the excess energy in the high-SOC cell is delivered to the low-SOC cell through a power-conversion stage, rather than being burned in a resistor. If you have worked with DC-DC converters (buck, boost, flyback), you already have the right mental model: active balancing circuits are miniature, bidirectional DC-DC converters whose input and output happen to be individual cells in a series string. The conversion efficiency is never truly 100% (every real converter has switching losses, conduction losses, and magnetics losses), but practical active balancing circuits achieve 80–95% round-trip efficiency — meaning most of the redistributed energy ends up in the target cell rather than as heat. Active balancing is more complex, more expensive, and larger than passive balancing, but it becomes attractive in applications where balancing energy is large relative to the conversion circuit costs, or where the heat from passive balancing is a problem.

The design space for active balancing is rich — many topologies have been proposed — and we will survey the main families here. When evaluating any active balancing topology, five questions discriminate between the options: what is the energy transfer pathway (cell-to-cell, cell-to-pack, pack-to-cell, or bidirectional); what conversion efficiency does the topology achieve; how complex is the control algorithm required to operate it; what is the worst-case balancing time for a given imbalance magnitude; and what happens when one cell fails open-circuit or short-circuit? We will address each of these for the three main topology families below.

### Switched Capacitor (Flying Capacitor) Topology

The simplest active balancing topology uses a capacitor that is switched alternately between adjacent cells in the string, transferring charge from the higher-voltage cell to the lower-voltage cell.

**Operation**: A capacitor $C_f$ is connected across cell $i$ (the higher-voltage cell) via switches S1 and S2. The capacitor charges to $V_i$. The switches then reconfigure to connect the same capacitor across cell $i+1$ (the lower-voltage cell). The capacitor, now at $V_i > V_{i+1}$, discharges into cell $i+1$, transferring charge. The switches cycle at a frequency of 1–100 kHz.

**Energy transferred per switching cycle**: The charge transferred per cycle is approximately $\Delta Q = C_f (V_i - V_{i+1})$, and the effective balancing current is therefore $I_{\text{bal}} \approx f \cdot C_f \cdot (V_i - V_{i+1})$, where $f$ is the switching frequency. The power delivered to the receiving cell is $P \approx I_{\text{bal}} \cdot V_{i+1}$. As the cells approach the same voltage, the driving force decreases and the transfer rate slows — an inherent self-limiting behaviour.

**Limitations**: The switched capacitor topology can only transfer charge between adjacent cells. Balancing cell 1 against cell 96 in a 96-cell string requires 95 intermediate steps, each losing some efficiency, making long-range balancing slow. The balancing current is also limited by the capacitor size and switching frequency — achieving more than a few hundred milliamps of effective balancing current requires large capacitors or very high switching frequencies, both of which have cost and EMI implications.

**Efficiency**: The energy dissipated per switching cycle is $\frac{1}{2}C_f(\Delta V)^2$, regardless of the switch resistance (you may recall from circuits class that charging a capacitor through any resistance dissipates exactly half the energy — the same physics applies here). However, the useful energy transferred per cycle is approximately $C_f \cdot \Delta V \cdot V_{\text{avg}}$, where $V_{\text{avg}}$ is the mean cell voltage. The ratio of loss to useful transfer is therefore $\Delta V / (2V_{\text{avg}})$, which is small when the cells are closely matched — for example, $\Delta V = 20 \, \text{mV}$ at $V_{\text{avg}} = 3.7 \, \text{V}$ gives a theoretical loss fraction of 0.27%. In practice, resistive losses in the switches and capacitor ESR dominate, reducing real-world efficiency to 70–90%.

### Inductor-Based (Buck-Boost) Topology

A more versatile active balancing approach uses an inductor to transfer energy between any two cells in the string, not just adjacent ones. The inductor temporarily stores energy from the source cell and releases it to the target cell, functioning as a two-way DC-DC converter.

**Cell-to-cell inductor topology**: Two cells are selected by a multiplexer (one source, one destination). A buck-boost converter transfers energy from the source cell to the inductor and from the inductor to the destination cell. Any pair of cells in the string can be connected, regardless of their physical position — enabling direct cell-to-cell balancing across the full string.

**Advantages**: Maximum flexibility in balancing strategy; can balance any pair in one step; typically achieves 80–92% efficiency; allows large balancing currents (1–5 A) with appropriately sized inductors.

**Disadvantages**: Requires a multiplexer or switch matrix to select the cell pair, adding circuit complexity. The control algorithm must decide which pairs to balance and in what order — a combinatorial optimisation problem when many cells are simultaneously imbalanced. The inductor and its associated switches add significant cost (perhaps \$5–\$20 per cell-pair worth of inductor hardware, versus \$0.50 per cell for passive balancing).

To put the cost in perspective: consider a 96s1p EV pack. Passive balancing adds roughly \$0.50–\$2.00 per cell × 96 cells = \$48–\$192 to the BMS bill of materials. Inductor-based active balancing at \$10–\$20 per cell adds \$960–\$1,920 — an order of magnitude more. The energy savings from active balancing (avoiding the ~0.6 Wh per cell per cycle wasted by passive balancing) amount to roughly $96 \times 0.6 = 58 \, \text{Wh}$ per cycle. At a residential electricity cost of \$0.15/kWh, this saves \$0.0087 per cycle, requiring over 100,000 cycles to break even on hardware cost alone — far beyond the pack's cycle life. The economic case for active balancing in automotive applications therefore rests not on energy savings but on lifetime extension: by keeping cells more tightly balanced, active balancing can delay the point at which capacity imbalance forces early pack retirement, potentially recovering thousands of dollars in avoided pack replacement. In grid storage with 10,000+ cycle expectations, the calculus can shift further toward active balancing.

### Transformer-Based (Flyback) Topology

For packs where the individual cell voltages are small (3.6 V) but the pack voltage is large (350 V), a flyback transformer can transfer energy from any individual cell to the full pack bus, or from the pack bus to any individual cell. This "cell-to-pack" or "pack-to-cell" topology has a significant architectural advantage: it does not need to identify a matching pair of cells to balance between. Energy is simply taken from high-SOC cells and injected into the pack bus (where it supplements the total energy available), or drawn from the pack bus to charge low-SOC cells.

**Operation**: In the conceptual form, a flyback converter with one primary winding (connected to the pack bus) and one secondary winding per cell allows any cell to deliver energy to the pack bus or receive energy from it. In practice, building a single transformer with 96 secondary windings is impractical — the leakage inductance and coupling complexity would be unmanageable. Real implementations use either a shared multi-tap transformer covering a group of cells (e.g., one transformer per 8–16 cell module), or individual small transformers per cell with the primaries tied to a common bus. The control principle remains the same: energy flows from a high-SOC cell through its winding to the bus, and from the bus through another winding to the low-SOC cell. The converter's turns ratio determines the voltage step-up from cell-level (≈3.6 V) to pack-level (≈350 V).

**Advantages**: No need to select a balancing pair; balancing one cell does not affect others; can balance at full-string voltage difference; suitable for very large packs.

**Disadvantages**: The transformer structure (even in its modular form) is physically complex and expensive. Electromagnetic coupling between windings must be carefully managed to prevent cross-cell interference. Efficiency is typically 85–92%.

### Modular Multilevel Converter (MMC) Architecture

In the most sophisticated active balancing architectures — increasingly used in high-performance automotive and grid-scale applications — each cell in the string is equipped with its own small bidirectional DC-DC converter, allowing fully individual control of each cell's charge and discharge rate. The pack operates as a modular multilevel converter where the individual cell converters can vary their effective voltage contribution to the string in real time.

This architecture blurs the distinction between "balancing" and "pack operation" — balancing is not a separate process but an inherent consequence of individually controlling each cell's power. The pack can continuously compensate for cell-to-cell differences without dedicated balancing hardware, by slightly adjusting each cell's duty cycle. The energy efficiency is excellent, but the hardware cost (a DC-DC converter per cell) is very high.

MMC architectures are beginning to appear in high-end EV platforms and in grid storage systems where the converter infrastructure is already present. Some grid-scale systems from companies like Powin and Fluence already use modular power conversion stages that inherently provide per-module balancing capability. In automotive, research prototypes have demonstrated full per-cell MMC control, but cost remains a barrier to mass adoption. For cost-sensitive applications, passive balancing remains the standard.

---

## 11.4 When to Balance: Top, Bottom, and Throughout

The decision of *when* to run the balancing algorithm is as important as the choice of *how* to implement it. There are three primary strategies, each suited to different OCV curve shapes and pack designs.

### Top Balancing

**Top balancing** aligns cells at the top of charge — the balancing algorithm runs during or at the end of a charging session, driving all cells to the same upper voltage limit simultaneously. The BMS continues charging until the first cell reaches $V_\text{max}$, then holds $V_\text{max}$ on that cell (CV phase for a CC-CV charger) while continuing to charge the other cells. Simultaneously, if passive balancing is active, bypass resistors pull down the first cell's voltage, preventing it from being overcharged while the others catch up.

Top balancing is effective for chemistries with a **steep OCV curve near the top of charge** — where small differences in SOC produce measurable voltage differences that the BMS can detect and correct. NMC/graphite cells are good candidates: the OCV curve near 90–100% SOC is steep enough that even a 2% SOC difference between cells produces a voltage difference of roughly 10–20 mV, easily within the resolution of a well-calibrated CMIC.

Top balancing is also operationally natural because of how CC-CV charging works (recall Section 3.9). During the CC phase, the charger pushes the same current through all series cells, so they all gain charge at the same rate — no balancing is possible. The first cell to hit $V_\text{max}$ triggers the transition to the CV phase, during which the pack voltage is held constant and the current tapers. During this taper, the BMS can activate the bypass resistors on the highest-SOC cells, preventing them from overcharging while the lower-SOC cells continue to absorb current. The CV phase thus provides a natural window — often 30–90 minutes long — during which balancing and charging proceed simultaneously. This is why passive balancing and top balancing pair so well in practice: the hardware is simple, and the CV phase provides the time.

The limitation of top balancing alone appears on discharge: cells that were balanced at the top of charge will experience SOC divergence during the discharge (due to capacity differences), and by the end of discharge, the lowest-capacity cell will hit its lower cutoff first, cutting off the pack before the higher-capacity cells are depleted. The cumulative energy left stranded in the higher-capacity cells (because the lowest-capacity cell triggered the cutoff) is the **discharge energy loss due to capacity imbalance** — and top balancing cannot prevent this, because it only addresses the SOC alignment at the start of discharge, not the differential discharge rate during it.

### Bottom Balancing

**Bottom balancing** aligns cells at the bottom of discharge — the balancing algorithm runs during or at the end of a discharge, ensuring all cells reach their lower voltage cutoff simultaneously. This ensures the maximum possible capacity is extracted from every cell on every discharge. The cost is that at the top of charge, cells will be at different SOCs (the higher-capacity cells will be fuller than the lower-capacity cells after the same total charge is applied).

Bottom balancing requires the BMS to discharge high-capacity cells at the end of a discharge cycle to bring them to the same endpoint as the weakest cell. In a passive balancing architecture, this is done by applying bypass resistors to the higher-capacity cells after the string has reached its lower cutoff — draining their residual charge to align them with the weakest cell.

Bottom balancing is effective when the priority is maximum discharge energy extraction (for applications like grid storage where the full capacity must be utilised). However, the engineering complexity is higher for two reasons. First, the BMS must track which cells need to be drained at the end of discharge and selectively activate their bypass resistors — adding bookkeeping that is unnecessary in top balancing. Second, and more subtly, the battery system must remain powered after the pack has nominally reached its lower voltage limit: the contactors must stay closed, the CMIC must remain active, and the bypass resistors must continue operating, all while the pack is at its lowest energy state. The BMS must manage this "empty but not dead" condition carefully — if it draws too much standby power from the nearly depleted pack, it risks driving the weakest cell into deep discharge and damaging it. In practice, bottom balancing is often performed not during normal use but during a dedicated maintenance session where an external power supply can keep the BMS electronics alive while the cells are drained to alignment.

### Continuous Balancing (Throughout Operation)

**Continuous balancing** runs the balancing algorithm at all times — during charge, during discharge, and during rest. It does not wait for a defined top or bottom reference point but continuously compares cell voltages and applies corrections whenever the spread exceeds the trigger threshold.

Continuous balancing is the most robust strategy because it corrects imbalance as it develops rather than accumulating it. The energy dissipated by continuous balancing is proportional to the ongoing imbalance development rate — for a well-matched pack with slow divergence, continuous balancing dissipates very little. For a poorly matched or degraded pack with fast divergence, it dissipates proportionally more but also provides the most effective correction.

The challenge with continuous balancing is detecting imbalance during operation. During discharge, the terminal voltage of a cell is below its OCV by the overpotential — and because the overpotential is different for each cell (due to different internal resistance), the terminal voltage difference between two cells may reflect resistance difference rather than SOC difference. Using terminal voltage as the balancing trigger during operation without correcting for the IR drop can lead to balancing in the wrong direction: draining a cell that appears to have high voltage because its resistance is low, rather than because its SOC is high.

The correct approach for continuous balancing is to use **SOC-based balancing triggers** rather than **voltage-based triggers**. The BMS's EKF state estimator (Chapter 10) continuously estimates the SOC of each cell; the balancing algorithm compares these SOC estimates and applies corrections based on the SOC spread rather than the voltage spread. This requires accurate SOC estimates — and accurately estimated SOC requires the OCV curve to be informative, which brings us back to the flat-OCV challenge for LFP and SIB cells.

For cells with flat OCV curves, the BMS cannot reliably distinguish between SOC differences and resistance differences from voltage measurements during operation. The balancing system must choose between two approaches. The first is to balance only during rest periods, when the terminal voltage closely approximates the true equilibrium OCV and the IR drop is zero — giving the most reliable voltage-based SOC comparison. The second is a hybrid strategy: apply conservative balancing based on estimated SOC (with acknowledged uncertainty) during operation, then apply corrective balancing during rest periods when OCV measurements are more reliable and the corrections can be validated.

This hybrid strategy is the current best practice for LFP and SIB BMS implementations.

A note on parallel groups: everything in this section applies to cells connected in *series*. Cells connected in *parallel* (as in a 96s2p pack, where each series position contains two cells in parallel) do not require explicit balancing — they self-balance automatically through direct current redistribution. Because parallel cells share the same terminal voltage, any SOC difference between them drives a circulating current through the connecting busbars that equalises their charge. The time constant for this self-balancing is typically seconds to minutes, governed by the busbar resistance and the cells' internal impedance. The BMS therefore treats each parallel group as a single equivalent cell and applies balancing only across the series string. This is why balancing hardware scales with the number of series cells, not the total number of cells in the pack.

---

## 11.5 Quantitative Analysis: Balancing Time, Energy, and Optimal Strategy

Let us put numbers on the competing choices through a worked analysis that draws together the hardware characteristics and the pack behaviour.

### Problem Setup

Consider a 16s1p LFP pack (16 cells in series, 1 cell in parallel — a small pack for a residential storage system) using **CATL LFP prismatic cells** (100 Ah capacity per cell, $R_\text{int} \approx 0.5$ mΩ per cell, nominal 3.2 V). The pack has been operating for 18 months, and cell-to-cell capacity spread has developed to a distribution with the following characteristics (based on post-aging measurements): cells 1–13 retain 97–99 Ah; cells 14–15 retain 92–94 Ah; cell 16 retains 87 Ah. The mean capacity is 96.3 Ah; cell 16 is 9.3 Ah below the mean.

After a full charge session with top balancing (to the upper voltage limit), every cell is at 100% SOC — each has been charged to its own individual maximum capacity and held at $V_\text{max} \approx 3.65 \, \text{V}$. The pack appears perfectly balanced, because all cell voltages are equal. But recall that "100% SOC" means something different for each cell: 100% of 98 Ah for a healthy cell, versus 100% of 87 Ah for cell 16. The voltage alignment at the top masks the capacity disparity underneath.

### The Discharge Trajectory Without Mid-Discharge Balancing

Now the pack begins a demand-response discharge at $I = 50$ A (0.5C for cell 16, 0.52C for the mean cell). Since all cells carry the same current, after $t$ seconds of discharge, each cell has discharged the same charge $q = It$. The SOC of each cell at time $t$ is given by Equation (11.4):

$$\text{SOC}_i(t) = 1 - \frac{q(t)}{Q_{\text{max},i}} = 1 - \frac{It}{Q_{\text{max},i}} \tag{11.4}$$

Cell 16 (87 Ah) depletes faster because it has less capacity:

$$\text{SOC}_{16}(t) = 1 - \frac{50t}{87 \times 3600}$$

It reaches SOC = 0% (approximately — the BMS will cut off somewhat before this) when:

$$t_{16} = \frac{87 \times 3600}{50} = 6{,}264 \, \text{s} = 1.74 \, \text{h}$$

Meanwhile, a typical cell with 98 Ah depletes at:

$$t_{98} = \frac{98 \times 3600}{50} = 7{,}056 \, \text{s} = 1.96 \, \text{h}$$

The pack cutoff is triggered by cell 16 at $t = 1.74$ h, at which point the typical cell is at:

$$\text{SOC}_\text{typical}(1.74\text{h}) = 1 - \frac{50 \times 6264}{98 \times 3600} = 1 - \frac{313{,}200}{352{,}800} = 1 - 0.888 = 11.2\%$$

The typical cell still has **11.2% SOC remaining** when the pack is cut off by cell 16. For 13 cells at ~98 Ah, the **stranded energy** — the energy physically present in the cells but inaccessible because the pack cutoff has been triggered by the weakest cell — is:

$$E_\text{stranded} = 13 \times 0.112 \times 98 \times 3.2 = 13 \times 35.2 \, \text{Wh} = 457 \, \text{Wh}$$

Plus cells 14 and 15 each have approximately 8–9% remaining, contributing another ~80 Wh. Total stranded energy: approximately **537 Wh** on a nominal pack energy of $16 \times 100 \times 3.2 = 5{,}120$ Wh — a **10.5% reduction in usable discharge energy** due to one degraded cell.

This is the quantitative cost of capacity imbalance. No amount of balancing can recover this energy — the cell simply does not have it. The only solution is to replace cell 16.

### The SOC Imbalance Scenario: Where Balancing Helps

Now consider a different scenario: the pack is new (all cells at 100 Ah), but due to different self-discharge rates over a two-week idle period, the cells enter a charge cycle at the following initial SOCs: cells 1–13 at 48% SOC, cell 14 at 44%, cell 15 at 46%, and cell 16 at 41%.

This is pure SOC imbalance — all cells have the same capacity (100 Ah), but they are at different SOCs due to differential self-discharge during the idle period.

Without balancing, the charge would terminate when cells 1–13 (the highest-SOC cells) reach $V_\text{max}$. At that point, the other cells would be at lower SOC: cell 14 started at 44% SOC and received the same 52 percentage points of charge as cells 1–13 (since all cells carry the same current and have the same capacity), ending at $44 + 52 = 96\%$ SOC — 4% below full, exactly matching its initial 4% deficit relative to cells 1–13. Cell 16 ends at $41 + 52 = 93\%$ SOC — 7% below full.

The cells that started lower finish lower — the charge session does not equalise them (in the absence of balancing). On the subsequent discharge, cells 1–13 will reach their lower cutoff at SOC = 0% at time $t = 100 \times 3600/50 = 7200$ s, while cell 16 reaches 0% SOC at $t = 93/100 \times 7200 = 6696$ s — it triggers the cutoff 504 seconds early, wasting $50 \times 504 / 3600 = 7.0$ Ah, or about 7% of the cell's capacity.

With passive balancing running during the charge session (bypass resistors on cells 1–13 during the CV phase, draining them slightly to allow cells 14–16 to catch up), all cells can be brought to 100% SOC by the end of the charge. The balancing current during the CV phase for cells 1–13 follows from Equation (11.1) with $R_b = 47$ Ω and $V_\text{cell} \approx 3.65$ V:

$$I_b = 3.65/47 = 77.7 \, \text{mA}$$

To drain cells 1–13 from 100% to 96% (to match cell 14): $\Delta Q = 0.04 \times 100 = 4$ Ah.

$$t_\text{bal} = 4 / 0.0777 = 51.5 \, \text{h}$$

That is far too slow for a single charge session. This illustrates a key limitation of passive balancing: it can correct small, continuous imbalances (the kind that develop over a few cycles), but large SOC divergences (from two weeks of differential self-discharge) require either much higher balancing currents, a dedicated equalisation charge, or switching to active balancing. In practice, residential storage systems avoid this problem by performing a **maintenance charge** — a slow, low-current charge to full SOC — periodically, with passive balancing running throughout.

---

## 11.6 Worked Interpretation Exercise: Evaluating a Commercial BMS Balancing Specification

Let us apply the chapter's framework to a real commercial BMS. The **Texas Instruments BQ76952** is a 3–16 series cell monitor IC commonly used in automotive and industrial battery packs. It includes integrated passive balancing functionality. Here is an abbreviated version of its balancing-related specifications:

| Parameter | BQ76952 Specification | Notes |
| --- | --- | --- |
| Voltage measurement resolution | ~0.19 mV | See ADC architecture discussion below |
| Balancing switch type | Internal N-channel MOSFET | Cells 1–15 only; cell 16 requires external component |
| Max balancing current | 200 mA | Limited by internal MOSFET path resistance (~18 Ω) |
| Balancing trigger threshold | Configurable, default 10 mV | Above minimum cell voltage in the string |
| Thermal protection | Auto-inhibit above 60°C | Applies to cell temperature, not resistor temperature |

Now let us interpret each of these specifications and understand what they mean for balancing performance.

**0.19 mV voltage resolution**: The usefulness of this resolution depends entirely on the OCV curve slope at the operating SOC. For an NMC/graphite cell near the top of charge (90–100% SOC), the OCV curve is steep — a typical local slope is $dV_{\text{OC}}/d\text{SOC} \approx 1000 \, \text{mV per unit SOC}$ (meaning the OCV changes by roughly 100 mV over the last 10% of SOC). At this slope, the minimum detectable SOC difference is:

$$\Delta\text{SOC}_\text{min} = \frac{0.19 \, \text{mV}}{1000 \, \text{mV/unit}} = 1.9 \times 10^{-4} = 0.019\%$$

Excellent resolution — the ADC is not the bottleneck; noise and thermal drift dominate at this level.

Now consider an LFP cell in the flattest part of its plateau (approximately 30–70% SOC). Here the OCV curve slope can drop to $dV_{\text{OC}}/d\text{SOC} \approx 30\text{–}80 \, \text{mV per unit SOC}$. Taking the worst case of 30 mV/unit:

$$\Delta\text{SOC}_\text{min} = \frac{0.19 \, \text{mV}}{30 \, \text{mV/unit}} = 0.0063 = 0.63\%$$

The ADC can still resolve sub-1% SOC differences — but the 10 mV default balancing trigger threshold now corresponds to a SOC difference of:

$$\Delta\text{SOC}_\text{trigger} = \frac{10 \, \text{mV}}{30 \, \text{mV/unit}} = 0.33 = 33\%$$

This is the key problem: the trigger threshold, not the ADC resolution, is the practical limit for flat-OCV chemistries. With a 10 mV trigger, the CMIC will not initiate balancing until cells differ by 33% SOC in the flattest part of the LFP plateau — effectively blind in this region. In practice, balancing of LFP (and SIB) cells must rely on the steeper OCV regions at the extremes of the SOC range, or switch to SOC-based triggers from the state estimator. For SIB cells with hard carbon anodes, where the plateau can be even flatter than LFP, the situation is worse still.

**200 mA maximum balancing current**: For a 100 Ah cell (residential storage scale), a 1% SOC imbalance requires correcting:

$$\Delta Q = 0.01 \times 100 \, \text{Ah} = 1 \, \text{Ah}$$

At 200 mA, this takes $1/0.2 = 5$ hours. Passive balancing at the BQ76952's maximum current is very slow for large cells. This is why BQ76952-based systems are more appropriate for smaller cells (3–10 Ah consumer or light automotive cells) where 200 mA represents a more reasonable fraction of the cell capacity (C/15–C/50).

**Cell 16 external requirement**: The asymmetry in CMIC design (cell 16 requires an external component) is a genuine engineering nuisance in 16s packs. It arises because the highest cell in a bottom-referenced stack requires its balancing switch to be driven from a gate voltage that is higher than the pack voltage — requiring either an isolated gate driver or an external high-side MOSFET with a bootstrap circuit. Most CMIC designs handle up to 15 cells internally and leave the top cell as an external requirement. Engineers designing 16s packs with BQ76952 must add this external circuit, and its omission is a common rookie mistake that leaves the highest cell unbalanced.

**Thermal inhibit at 60°C**: The BMS automatically stops balancing if any cell temperature exceeds 60°C. This is a safety feature to prevent balancing from adding heat to an already overtemperature situation — but it also means that in a hot pack (summer storage in an uncooled space), balancing may be frequently inhibited, allowing imbalance to accumulate without correction. Thermal management and balancing are not independent system concerns.

---

## 11.7 What Changes for Sodium-Ion?

The balancing architectures (passive resistive, switched capacitor, inductor-based, transformer-based) and the balancing control strategies (top, bottom, continuous) all apply directly to SIB packs. The hardware is identical in concept. The complications arise specifically from the flat OCV curve of hard carbon anodes, and they manifest at three levels.

### Detection: The Flat OCV Makes Voltage-Triggered Balancing Unreliable

In the plateau region of the hard carbon OCV (approximately 20–55% SOC for a typical SIB cell, as established in Chapter 6), voltage-based balancing triggers — the standard approach for NMC and most commercial BMS ICs — become unreliable. A 5% SOC imbalance between two cells in the plateau produces a voltage difference of perhaps 7–15 mV, depending on the precise slope. With typical CMIC measurement noise of 0.5–2 mV, the signal-to-noise ratio for detecting 5% imbalance in the plateau is poor. Many commercially available CMIC ICs designed for LIB use will simply not trigger balancing in this region because the voltage differences are below their balancing thresholds.

The engineering response requires one of three approaches. First, increase the trigger threshold sensitivity (reduce the minimum balancing voltage trigger), which requires more accurate voltage measurement and may trigger spurious balancing from noise. Second, use SOC-based balancing triggers from the EKF estimator (Chapter 10) rather than raw voltage triggers — but this requires accurate SOC estimation in the plateau, which is itself difficult (Section 10.2). Third, perform balancing primarily outside the plateau region (at the extremes of SOC where the OCV curve is steeper), accepting that the plateau region is not actively balanced and relying on good initial cell matching to keep divergence small in this range.

### Correction: Passive Balancing Still Works, But Slowly

Once the decision to balance is made, passive balancing operates identically for SIBs as for LIBs. The bypass resistor does not know what chemistry the cell is. The complication is that the small voltage differences in the plateau mean the balancing current (from Equation (11.1), $I_b = V_\text{cell}/R_b$) is essentially the same regardless of the SOC difference — the cell voltage varies by only ~50 mV across the whole plateau, so the balancing current is nearly constant throughout. This means passive balancing in the SIB plateau is blind to the magnitude of the imbalance — it drains at a fixed rate regardless of whether the true SOC difference is 1% or 15%.

One additional quantitative difference is worth noting: SIB cells typically operate at lower nominal voltages than NMC cells — approximately 3.0–3.3 V versus 3.6–3.7 V for NMC. From Equation (11.1), this means the passive balancing current is roughly 15–20% lower for the same bypass resistance, and the balancing time from Equation (11.2) is correspondingly longer. For a bypass resistor of 33 Ω, an SIB cell at 3.1 V produces $I_b = 94 \, \text{mA}$ versus 126 mA for an NMC cell at 4.15 V. This modest difference compounds with the already-slow balancing characteristic of flat-OCV chemistries, further motivating higher balancing currents or active balancing for SIB packs.

### Strategy: The Bottom-Balancing Advantage for SIBs

Given the unreliability of top balancing in the plateau region (where the cells all look the same voltage), **bottom balancing** has a specific advantage for SIBs. At the bottom of discharge (low SOC end of the hard carbon slope region, approximately 5–15% full-cell SOC), the OCV curve steepens considerably as the cathode contribution increases and the hard carbon exits its slope region. Voltage differences between cells become more detectable in this region. Bottom-balancing algorithms that align cells at the end of discharge — where the OCV curve has more slope — can detect and correct imbalance more reliably than top-balancing algorithms that operate at the top of charge where the hard carbon may still be in its relatively flat region.

This is an active area of research in SIB BMS design: designing bottom-balancing algorithms that leverage the OCV curve features at the extremes of the SIB SOC range, combined with accurate coulomb counting throughout the plateau, to provide effective balancing despite the flat OCV challenge.

### Impact of OCV Hysteresis on Balancing

Hard carbon's OCV hysteresis (discussed in Chapters 6 and 10) adds another complication for balancing. If cells A and B are at the same true SOC but cell A recently charged while cell B recently discharged, they will have different OCV values — perhaps by 30–60 mV — due to hysteresis. A balancing algorithm that triggers based on voltage difference will incorrectly identify this as a SOC imbalance and attempt to balance cells that are actually at the same SOC, wasting energy.

Correcting for hysteresis in the balancing trigger requires the BMS to track the recent cycling direction of each cell and use the appropriate OCV curve (charge vs. discharge) for the trigger comparison — a complication not present for most LIB chemistries (NMC has some hysteresis, but much smaller than hard carbon). For current SIB BMS designs, the practical approach is to trigger balancing only during extended rest periods (when OCV has relaxed and hysteresis has partially dissipated) and to use conservative voltage thresholds that avoid spurious triggers from hysteresis effects during active cycling.

---

## Chapter Summary

**Key ideas:**

- Cell imbalance has three types: SOC imbalance (correctable by balancing), capacity imbalance (not correctable by balancing — requires cell replacement), and resistance imbalance (managed by cell-specific power limits). Most commercial balancing systems address only SOC imbalance; the other two accumulate over the pack's life.
- SOC imbalance accumulates from differential self-discharge, thermal gradients in the pack, manufacturing variation in initial Coulombic efficiency, and parasitic reaction rate heterogeneity. Differential degradation drives capacity and resistance imbalance over hundreds of cycles.
- Passive (resistive bleed) balancing: all excess charge from high-SOC cells is dissipated as heat. Simple, cheap, reliable. Balancing current $I_b = V_\text{cell}/R_b$; balancing time $t_\text{bal} = \Delta\text{SOC} \times Q_\text{max}/I_b$. Typical balancing currents of 50–200 mA make it slow — correcting a 5% imbalance in a 3 Ah cell takes 45–90 minutes.
- Active balancing transfers charge from high-SOC to low-SOC cells rather than dissipating it. Topologies include switched capacitor (adjacent-cell transfer, simple), inductor-based (any-pair transfer, flexible), and transformer-based (cell-to-pack, scalable). Efficiencies of 80–95%, higher cost and complexity than passive.
- Top balancing aligns cells at full charge (good for steep-OCV chemistries with detectable voltage differences near 100% SOC). Bottom balancing aligns cells at the end of discharge (maximises discharge energy extraction). Continuous balancing corrects imbalance in real time using SOC estimates from the state estimator. SOC-based triggers are more reliable than voltage-based triggers during operation because they correct for IR drop.
- For SIBs, the flat OCV plateau of hard carbon makes voltage-based balancing triggers unreliable in the 20–55% SOC range — voltage differences from imbalance are too small to distinguish from noise. Bottom-balancing strategies that leverage the steeper OCV at low SOC have a specific advantage. OCV hysteresis in hard carbon can cause spurious balancing triggers; rest-period-only balancing mitigates this. These challenges are active research areas in SIB BMS design.

**Key equations:**

$$I_b = V_\text{cell} / R_b \quad \text{(passive balancing current)} \tag{11.1}$$

$$t_\text{bal} = \frac{\Delta\text{SOC} \times Q_\text{max}}{I_b} \quad \text{(passive balancing time for one cell)} \tag{11.2}$$

$$E_\text{wasted} = \Delta\text{SOC} \times Q_\text{max} \times V_\text{cell} \quad \text{(energy dissipated per passive balancing event)} \tag{11.3}$$

$$\text{SOC}_i(t) = 1 - \frac{I \cdot t}{Q_{\text{max},i}} \quad \text{(SOC trajectory of cell } i \text{ under constant current } I\text{)} \tag{11.4}$$

**Key vocabulary (in order of appearance):**

SOC imbalance, capacity imbalance, resistance imbalance, self-discharge rate spread, thermal gradient aging, Coulombic efficiency heterogeneity, parasitic reaction rate heterogeneity, weak-link effect, passive balancing, bypass resistor, bypass switch, CMIC (cell monitoring IC), balancing current, balancing time, remote bypass topology, active balancing, switched capacitor (flying capacitor), inductor-based (buck-boost) balancing, transformer-based (flyback) balancing, cell-to-cell balancing, cell-to-pack balancing, modular multilevel converter (MMC), top balancing, bottom balancing, continuous balancing, voltage-based balancing trigger, SOC-based balancing trigger, IR-corrected balancing, maintenance charge, stranded energy, bottom-balancing advantage for SIBs, OCV hysteresis and balancing.

---

## Deliverable

The deliverable for Chapters 9–12 remains the Plett Coursera specialisation (Courses 1 and 2) with MATLAB assignments. Chapter 11 provides the physical context for the balancing material that appears in Plett's Volume 1 and in the advanced topics of Course 2.

As a targeted exercise for this chapter, implement the following calculation in MATLAB or Python:

**Setup**: A 12s1p NMC/graphite pack (12 cells in series) using cells with 5 Ah capacity and 50 mΩ internal resistance. After 200 cycles of operation, the cell capacities have drifted to: cells 1–10 at 4.85 Ah; cell 11 at 4.60 Ah; cell 12 at 4.30 Ah. All cells are at 100% SOC after a charge session with top balancing.

**Part 1 — No balancing**: Simulate a constant-current discharge at $I = 5$ A (approximately 1C for the mean cell). For each time step, compute the SOC of each cell. Identify when the first cell reaches 0% SOC and compute the SOC remaining in every other cell at that moment. Calculate the total stranded energy.

**Part 2 — With continuous passive balancing**: Add a 100 Ω bypass resistor to each cell. During discharge, if any cell's SOC falls more than 2% below the mean SOC, activate its bypass to slow its discharge rate. Recompute the discharge trajectory and compare the stranded energy to Part 1.

**Worked partial solution for Part 1**: Cell 12 (4.30 Ah) reaches 0% SOC at time $t = 4.30 \times 3600 / 5 = 3096$ s = 51.6 min. At this moment, cell 11 (4.60 Ah) is at SOC = $1 - 5 \times 3096 / (4.60 \times 3600) = 1 - 0.935 = 6.5\%$. Cells 1–10 (4.85 Ah) are at SOC = $1 - 5 \times 3096 / (4.85 \times 3600) = 1 - 0.887 = 11.3\%$. Stranded energy: $(10 \times 0.113 \times 4.85 + 1 \times 0.065 \times 4.60) \times 3.7 \approx (5.48 + 0.299) \times 3.7 \approx 21.4$ Wh, or about 9.6% of the 12-cell pack's nominal energy of $12 \times 5 \times 3.7 = 222$ Wh.

Notice that with a 12.8% spread between the lowest and highest cell capacities, about 9.6% of nominal pack energy is stranded — a meaningful performance penalty even at this moderate spread. The stranded fraction grows faster than linearly as the spread increases (because the cutoff is always triggered by the worst cell, and the distance between worst and average grows with spread). At 25% spread, the stranded energy can exceed 15% — motivating either cell replacement or active balancing strategies that can redistribute current during discharge.

---

## Further Reading

1. **Hoque, M. M., Hannan, M. A., and Mohamed, A., "Charging and discharging model of lithium-ion battery for charge equalization control using particle swarm optimisation algorithm," *PLOS ONE* 11 (9), e0161630 (2016).** A balanced treatment of passive and active balancing algorithms with simulation results showing the time-to-balance and energy efficiency for each approach. Particularly useful for the quantitative comparisons of topology performance.

2. **Daowd, M. et al., "Passive and active battery balancing comparison based on MATLAB simulation," *Proceedings of the 2011 IEEE Vehicle Power and Propulsion Conference*, 1–7 (2011).** A straightforward comparative simulation study of passive vs. active balancing for EV packs, showing how the balancing time and energy waste compare under realistic cell spread conditions. Good entry point for understanding the trade-offs in practice.

3. **Stuart, T. A. and Zhu, W., "Fast equalization for large lithium ion batteries," *IEEE Aerospace and Electronic Systems Magazine* 24 (7), 27–31 (2009).** One of the clearer engineering expositions of inductor-based active balancing, with practical circuit design guidelines. The treatment of the current-steering and timing requirements is directly applicable to hardware design.

4. **Plett, G. L., *Battery Management Systems, Vol. 1: Battery Modeling*, Artech House (2015), Chapter 5.** Plett's treatment of cell balancing focuses on the interaction between balancing control and state estimation — specifically, how the balancing current affects the coulomb counting accuracy and how to compensate. This is the connection between Chapter 10 and Chapter 11 of this book, and it is treated with the rigour appropriate to a BMS implementation.

5. **Zhong, L. et al., "A method for the estimation of the battery pack state of charge based on in-pack cells uniformity analysis," *Applied Energy* 113, 558–564 (2014).** An analysis of how cell-to-cell variation statistics (mean, variance, and their evolution with cycle number) can be used to diagnose imbalance and predict future pack performance. Directly relevant to the SOH fusion and prognostics discussion in Chapter 10, and to understanding the long-term trajectory of balancing requirements as a pack ages.

---

*Next chapter: **Chapter 12 — Functional Safety (Brief).** We survey the ISO 26262 functional safety standard, ASIL ratings, and their application to BMS design — the regulatory and engineering framework within which all the algorithms and architectures of the preceding chapters must operate. Prompt me with "write Chapter 12" to continue.*

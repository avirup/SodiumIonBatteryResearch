# Chapter 9: Pack Architecture

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

## 9.1 Series and Parallel Configurations: Nomenclature and Analysis

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

## 9.2 Cell-to-Cell Variation and Its Consequences

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

## 9.3 Contactors, Precharge, Fuses, and Current Sensing

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

## 9.4 CAN Bus and BMS Communication Basics

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

---

*Next chapter: **Chapter 10 — State Estimation.** We address the core algorithmic challenge of battery management: why SOC estimation is non-trivial, how coulomb counting accumulates error, why flat OCV curves (particularly SIB hard carbon) break voltage-based lookup, and how the equivalent circuit model combined with a Kalman filter provides the state-of-the-art solution. Prompt me with "write Chapter 10" to continue.*

# Chapter 12: Functional Safety

## Chapter Opening

Every algorithm we have developed in the preceding three chapters — the state estimator of Chapter 10, the balancing controller of Chapter 11, the pack architecture of Chapter 9 — must ultimately run on firmware in a microcontroller that is expected to function correctly in the same vehicle that carries human passengers, operates in rain and extreme temperature, and must not cause injury even when its own hardware or software fails. Batteries are not simply an energy source to be optimised for performance; they are a hazard-containing system that must be managed safely. And "safely" in the automotive context has a precise, legally enforceable meaning defined by the ISO 26262 standard for functional safety.

This chapter is intentionally brief — the chapter plan designates it as an awareness-level treatment, not a deep implementation guide. Implementing a full ISO 26262-compliant BMS development process is the work of a team of safety engineers over months or years, and the details of that process are outside the scope of a battery technology textbook. What you need, as a researcher and engineer working with battery systems, is fluency in the vocabulary, an understanding of the classification system (ASIL ratings), and a clear picture of how functional safety requirements shape the architecture of the protective functions that the BMS must implement.

By the end of this chapter, you will be able to read a BMS functional safety concept document and understand what it is asserting, evaluate a BMS protective function description and identify which hazard it addresses, and engage intelligently with safety engineers who specify the requirements that algorithm developers must satisfy. You will also understand why certain BMS design choices — redundant current sensors, hardware-independent voltage cutoffs, watchdog timers — that might seem like engineering over-engineering are in fact mandatory consequences of the safety standard.

---

> **Prerequisites Check**
>
> From your EE background:
>
> - Basic concept of system failure modes and fault analysis — helpful
> - Familiarity with hardware reliability concepts (redundancy, fail-safe design) — helpful
>
> From Chapters 8–11:
>
> - Thermal runaway and its hazard profile (Chapter 8, Section 8.5) — the primary hazard being protected against
> - BMS state machine and contactor control (Chapter 9, Section 9.4) — the protective functions that implement safety requirements
> - SOC estimation and its uncertainty (Chapter 10) — relevant to safety-critical SOC limits
> - The interaction between balancing and state estimation (Chapter 11) — safety implications of balancing failures

---

## 12.1 The Need for a Safety Standard: What Can Go Wrong

Before ISO 26262 and its requirements make sense, it helps to concretise the failure scenarios that motivate them. A battery system can cause harm through several distinct pathways, each with different likelihood and severity.

### The Hazard Catalogue

**Thermal runaway from overcharge**: If the BMS fails to stop charging when cells reach their upper voltage limit — whether because the voltage measurement circuitry fails, the contactor fails to open, or the software logic has an undetected bug — cells can be overcharged beyond their safe voltage. Overcharge drives the cathode into deep delithiation and the electrolyte into oxidative decomposition, eventually triggering the thermal runaway cascade described in Chapter 8. For NMC/graphite cells, the margin between the rated upper cutoff (4.2 V) and the onset of dangerous cathode reactions is only 100–200 mV. A measurement error of that magnitude, sustained through a full charging session, can initiate the hazard.

**Thermal runaway from overdischarge followed by recharge**: If a cell is discharged below its lower voltage cutoff, the anode potential can rise high enough to oxidise the copper current collector — recall from Chapter 4 that LIB anodes use a copper foil. The dissolved Cu²⁺ ions migrate through the electrolyte during overdischarge. On subsequent charging, when the anode potential drops back to reducing conditions, these ions are electrodeposited as metallic copper on the anode surface and within the separator. These copper deposits can bridge the separator and create an internal short circuit. The hazard is not in the overdischarge itself (which causes capacity loss and impedance growth) but in the subsequent charge cycle that drives copper electrodeposition across the separator.

**Electric shock from high-voltage exposure**: If the isolation between the HV bus and the vehicle chassis is lost — due to a cable insulation failure, water ingress, or a cell can short-circuiting to the chassis — vehicle occupants and first responders can be exposed to the full pack voltage (350–800 V). At these voltages, contact with the chassis constitutes a life-threatening electric shock hazard. The BMS must detect this loss of isolation and open the contactors before the vehicle is touched by anyone.

**Fire from external short circuit**: If the HV bus terminals are short-circuited externally — through a crash that pinches a cable against a conductive body panel, or through improper handling — the fault current can reach thousands of amperes. Without rapid fuse interruption, the energy dissipated in the fault can ignite the vehicle structure. The protection must be both fast enough to prevent ignition and robust enough to interrupt the full prospective fault current.

**Runaway from software fault in the BMS**: The BMS itself can fail. Firmware bugs, bit-flips from cosmic rays in embedded SRAM, stuck-at faults in hardware registers, and timing violations in interrupt-driven code are all real failure mechanisms. A BMS that calculates an incorrect SOC and permits charging beyond the true voltage limit — because its software model has accumulated error and believes the cell is at 85% when it is actually fully charged and the voltage is already at 4.20 V — can initiate the overcharge hazard without any hardware failure. The safety standard's requirement for software quality processes is a direct response to this category of failure.

**Loss of propulsion from erroneous contactor opening**: The protective functions described above all terminate in the same action — opening the contactors to isolate the pack. But opening the contactors while the vehicle is in motion causes an immediate loss of drive torque, and with it the loss of electrically assisted power steering and vacuum-independent brake boost. At highway speed, a sudden loss of propulsion and steering assist is itself a safety hazard, potentially rated S3/E4/C2 or C3 depending on the traffic situation. This means the BMS faces a fundamental tension: it must open the contactors fast enough to prevent thermal runaway, but it must not open them spuriously due to a false alarm. Every protective function must therefore be designed with attention to both its *sensitivity* (probability of detecting a real fault) and its *specificity* (probability of not triggering on a non-fault). A BMS that is too aggressive in opening contactors trades one hazard for another.

These hazards have different probabilities and different severities. Some (overcharge to thermal runaway) can result in fire, severe burns, or death. Others (copper dissolution) cause property damage and loss of the battery system but not immediate harm to persons. The ISO 26262 framework provides a structured methodology for classifying hazards by their risk level and for specifying the safety measures required to reduce that risk to an acceptable level.

---

## 12.2 ISO 26262: Structure and Scope

**ISO 26262** is the international standard for functional safety of electrical and electronic systems in road vehicles. It was first published in 2011 and significantly revised in 2018. It is titled "Road Vehicles — Functional Safety" and its full scope is broad — covering all E/E (electrical and electronic) systems in passenger cars and some categories of trucks. Battery management systems fall squarely within its scope for any vehicle application.

The standard is structured as twelve parts. Parts 1 and 2 cover vocabulary and management of the functional safety process. Parts 3 through 6 trace the product development lifecycle from concept through implementation: Part 3 addresses the concept phase (hazard analysis, safety goals, and the functional safety concept), Part 4 covers system-level product development, Part 5 covers hardware-level product development, and Part 6 covers software-level product development and testing. Part 7 addresses production and operation. Part 8 covers supporting processes such as tool qualification and configuration management. Part 9 defines the ASIL-oriented analyses (FMEA, FTA, and related methods) that feed into every development stage. Parts 10 through 12 are supplementary: guidelines (informative, not normative), semiconductor-specific guidance, and adaptation for motorcycles, respectively.

For a BMS developer, Parts 3, 4, 5, 6, and 9 are the most directly relevant. Part 3 is where the safety classification of each hazard is established; Parts 4–6 are where the specific technical and process requirements that result from that classification are defined.

If you have encountered the V-model of systems development in your EE coursework — requirements on the left descending arm, verification on the right ascending arm — ISO 26262 maps directly onto that shape. Part 3 sits at the top of the V: it defines the safety requirements through hazard analysis. Parts 4 through 6 descend the left arm, progressively translating those requirements into system-level, hardware-level, and software-level designs. Each level on the left arm has a corresponding verification level on the right arm (system integration testing, hardware testing, software unit testing). Part 9 provides the analysis methods — FMEA, FTA, and others — that feed into every level. You do not need to memorise the part numbers, but understanding the V-shaped flow from hazard analysis down to detailed design and back up through verification will help you read any BMS safety document with orientation.

### Functional Safety vs. Other Safety Concerns

ISO 26262 addresses **functional safety** — the absence of unreasonable risk due to hazards caused by malfunctioning behaviour of E/E systems. It does not cover all safety aspects of a battery system. **Chemical safety** — such as hydrogen fluoride release from electrolyte decomposition and CO generation during thermal runaway — is covered by UNECE Global Technical Regulation No. 20 and related standards. **Electrical safety** (shock protection, wiring protection) is covered by ISO 6469 and FMVSS 305. **Abuse resistance** — performance under crash, fire, and water immersion — is covered by cell-level standards such as IEC 62660 and UL 2580.

A fully safety-compliant BMS must satisfy all of these standards, not just ISO 26262. In practice, a BMS development programme runs parallel workstreams addressing all applicable standards simultaneously.

---

## 12.3 ASIL: The Risk Classification System

The centrepiece of ISO 26262 for a practitioner is the **Automotive Safety Integrity Level (ASIL)** classification system. ASIL is a risk classification assigned to each safety goal (a high-level requirement that must be satisfied to prevent a specific hazard from causing harm). The ASIL determines the rigour of the development process — the required analysis methods, the code review practices, the testing coverage, the documentation — needed to give confidence that the safety goal will be met in the final product.

### The Three Risk Parameters

ASIL is determined by three parameters that together describe the risk associated with a hazard:

**Severity (S)** measures the worst-case consequence of the hazard manifesting, on a scale from S0 to S3. S0 means no injuries. S1 covers light to moderate injuries. S2 covers severe to life-threatening injuries where survival is likely. S3 covers life-threatening to fatal injuries — this is the rating assigned to any hazard that can result in vehicle fire or high-voltage electrocution.

Thermal runaway leading to vehicle fire is typically assessed as S3. Loss of isolation leading to electric shock is also typically S3. Incorrect SOC display leading to range anxiety is S1 at most.

**Exposure (E)** captures how frequently the vehicle is in the operating situation where the hazard could occur, rated E0 through E4. E0 means the situation is incredibly unlikely. E1 is very low probability. E2 is low probability — a few driving situations per year. E3 is medium probability, occurring in some drives. E4 is high probability, meaning the situation occurs in most drives or continuously during operation.

A BMS overcharge hazard has high exposure (E4) because charging occurs in nearly every operational cycle. An isolation fault exposure depends on assumptions about fault occurrence rates — typically E2–E3 for a well-designed system.

**Controllability (C)** rates the ability of the driver or other persons to avoid harm once the hazard has manifested, from C0 through C3. C0 means the situation is controllable in general. C1 is simply controllable. C2 is normally controllable. C3 means the situation is difficult to control or uncontrollable — once thermal runaway has initiated, for instance, there is nothing the driver can do to stop it.

An incorrect range estimate that leads to a stranded vehicle is controllable (C1 — the driver can stop the vehicle safely).

### The ASIL Matrix

The full ASIL determination table has three dimensions (S × E × C). The slice at C3 — the most relevant for BMS hazards, since thermal runaway is uncontrollable — is shown below:

**ASIL determination at C3 (difficult to control or uncontrollable):**

| Severity | E1 | E2 | E3 | E4 |
| --- | --- | --- | --- | --- |
| **S1** | QM | QM | QM | ASIL A |
| **S2** | QM | QM | ASIL A | ASIL B |
| **S3** | QM | ASIL A | ASIL B | ASIL C |

For the most critical battery hazards — S3 severity with C3 controllability and E4 exposure (such as overcharge during routine charging) — the ASIL matrix yields **ASIL D**, the most stringent level. At lower exposure (E3), the same S3/C3 combination gives ASIL C; at E2, ASIL B.

Note that the standard also defines separate table slices for C1 and C2, which yield lower ASIL levels for the same S and E values. The full table is reproduced in ISO 26262 Part 3, Annex B. The reader should consult the standard directly when performing a formal HARA.

**QM** (Quality Management): No specific ISO 26262 requirements beyond good engineering practice. The system's standard quality management process is sufficient.

**ASIL A** through **ASIL D**: Increasing levels of rigor, with ASIL D being the most stringent and corresponding to the most severe, likely, and uncontrollable hazards.

### Applying ASIL to BMS Hazards

Let us work through the ASIL classification for the overcharge hazard. The severity is S3, because thermal runaway can lead to vehicle fire and potentially fatal injuries. The exposure is E4, because charging occurs in nearly every operational cycle. The controllability is C3, because thermal runaway is difficult to control once initiated. From the ASIL matrix: S3, E4, C3 → **ASIL D**.

ASIL D is the highest ASIL level. It requires the most stringent development processes: formal verification methods for software, extensive hardware redundancy analysis (using techniques like FMEA — Failure Mode and Effects Analysis — and FTA — Fault Tree Analysis), 100% MC/DC code coverage in testing, strict configuration management, and independent safety assessments at multiple development stages. An ASIL D safety requirement applied to a BMS function means that the engineering team must demonstrate, with quantitative evidence, that the probability of the function failing to prevent overcharge is below a specified threshold — typically less than $10^{-8}$ failures per hour of operation.

For comparison, let us classify the isolation fault hazard. The severity is S3 — electric shock to occupants or first responders can be fatal. The exposure is E2, since isolation faults are relatively rare in a well-designed system but possible. The controllability is C3, because once in contact with an energised chassis, the victim may be unable to release. From the ASIL matrix: S3, E2, C3 → **ASIL B**.

ASIL B still requires significant rigour, but less than ASIL D. The BMS isolation monitoring function (Section 9.3) must be designed and verified to ASIL B standards — which means, among other things, that the IMD circuit must be shown to have a sufficiently low probability of both failing to detect a genuine isolation fault and of generating false alarms that would unnecessarily open the contactors.

### What ASIL Levels Mean in Practice

The difference between ASIL levels is not merely a label — it translates directly into development cost, time, and engineering constraints. At QM (quality management), the standard imposes no requirements beyond the organisation's normal development process. At ASIL A, the standard requires structured documentation, basic safety analysis (FMEA at the system level), and defined testing processes — roughly what a well-run engineering team would do anyway. At ASIL B, the requirements tighten: more rigorous analysis methods, higher test coverage targets, and independent review of safety-critical design decisions. At ASIL C, formal methods begin to appear: code coverage must include branch coverage, safety analyses must include quantitative fault tree analysis (FTA), and hardware random failure rates must be demonstrated through calculation. At ASIL D, the most stringent level, the standard requires MC/DC (modified condition/decision coverage) for software testing — a coverage criterion that ensures every Boolean sub-expression in every safety-critical decision has been independently exercised — along with formal verification techniques, quantitative PMHF (probabilistic metric for random hardware failure) demonstration, and independent safety assessment by an external assessor.

The practical consequence: an ASIL D function might require 3–5× the development effort of the same function at ASIL A, and the verification artefacts alone can exceed the volume of the design documentation. This is why ASIL decomposition (splitting a high-ASIL requirement across two independent paths at lower ASIL levels) is not just a theoretical trick but a significant cost-saving strategy — one that directly shapes BMS hardware architecture.

### ASIL Decomposition

An ASIL D requirement does not mean every individual hardware component and every line of code must be developed to ASIL D rigor. ISO 26262 permits **ASIL decomposition**: splitting a safety requirement between two independent channels such that each channel only needs to meet a lower ASIL level, provided the two channels are truly independent and the failure of both simultaneously is extremely unlikely.

For example, an ASIL D overcharge protection requirement can be decomposed as ASIL C + ASIL A if two independent protection mechanisms are implemented: a primary software-based overvoltage protection (ASIL C) and a secondary hardware-based voltage comparator that directly opens the contactor if the cell voltage exceeds a hardwired threshold (ASIL A). Because the two channels are independent — a software bug that disables the primary protection does not affect the hardware comparator — the combined system meets the ASIL D requirement. The logic is identical to redundancy in fault-tolerant circuit design: if two independent paths each have a failure probability $p_1$ and $p_2$, the probability that *both* fail simultaneously is $p_1 \times p_2$ (assuming independence). An ASIL C path with failure probability on the order of $10^{-7}$/hr and an ASIL A path with failure probability on the order of $10^{-6}$/hr combine to give $10^{-13}$/hr — far below the ASIL D target of $10^{-8}$/hr. The arithmetic works only because the two paths share no common failure modes. If both paths used the same voltage measurement IC, a single IC failure could disable both protections, and the decomposition would be invalid.

This decomposition principle explains why BMS designs always include both software-based protection (the BMS algorithm) and hardware-based protection (dedicated safety ICs with hardwired thresholds), even when the software protection is more sophisticated and more flexible.

---

## 12.4 BMS Failure Modes and Protective Functions

With the ASIL framework established, we can systematically survey the protective functions that a BMS must implement and the failure modes they guard against. This section does not derive algorithms — those belong to the chapters covering each function in detail — but maps the safety requirements to the specific hardware and software mechanisms that implement them.

### Cell Overvoltage Protection

**Hazard**: Cell voltage exceeds upper cutoff ($V_\text{max}$), leading to cathode degradation and eventual thermal runaway.

**Failure modes that could allow overvoltage**: The BMS can fail to detect or prevent overvoltage through several paths: cell voltage measurement circuit failure (CMIC input damaged, ADC offset, broken trace), software logic error in the CC-CV charge termination algorithm, contactor stuck closed (welded contact preventing pack isolation), or charger hardware fault delivering higher voltage than commanded.

**Protective functions**:

*Primary (ASIL C or D software)*: Cell voltage monitoring by the master BMS. Each cell's voltage is measured by the CMIC at a rate of at least 10 Hz during charging. If any cell voltage exceeds $V_\text{max}$ (e.g., 4.2 V for NMC), the BMS commands the contactors open. The software must be developed to the ASIL level corresponding to the hazard decomposition.

*Secondary (ASIL A hardware)*: A dedicated analog voltage comparator on each cell — or on groups of cells — compares the cell voltage to a hardwired reference. If the voltage exceeds the reference, the comparator output directly drives the contactor open, bypassing the software entirely. This hardware path must be independent of the primary software path — it must not share power supply, signal ground, or logic gates with the software protection.

*Cell-level safety device (ASIL A)*: The current interrupt device (CID) on individual cylindrical cells provides a last-resort mechanical protection — it permanently disconnects the cell if internal pressure (from gas generation during overcharge) exceeds a threshold. This is not resettable; a cell that has activated its CID must be replaced.

**Detection and diagnostic coverage**: ISO 26262 requires quantification of **diagnostic coverage** — the fraction of all possible failure modes in a safety-relevant component that are detected by the protective function. For the cell voltage measurement path, this means: what fraction of all possible CMIC faults (stuck-at-zero output, stuck-at-full-scale output, intermittent open circuit, gain error, offset drift) result in the cell voltage being measured as lower than actual (allowing overcharge to continue)? Each fault mode must be identified and its probability of occurrence and detectability quantified through FMEA.

### Cell Undervoltage Protection

**Hazard**: Cell voltage falls below lower cutoff ($V_\text{min}$), leading to copper dissolution (LIB) or deep structural damage to the cathode, followed by internal short circuit on subsequent charging.

**Protective functions**:

*Primary*: Cell voltage monitoring with lower cutoff enforcement. If any cell falls below $V_\text{min}$ (typically 2.5–3.0 V for NMC), the BMS opens the contactors to terminate discharge.

*Secondary*: Same hardware-independent comparator approach as for overvoltage, now monitoring for undervoltage. The comparator directly opens the contactor if the voltage falls below the hardwired reference.

*Note on SIBs*: For sodium-ion cells, the lower cutoff voltage is typically 1.5–2.0 V (depending on cathode chemistry), and the hazard of going below this limit is somewhat less severe than for LIBs (no copper current collector to dissolve — recall from Chapter 4 that SIBs use aluminium on both sides). However, deep discharge of SIB cathodes can still cause irreversible structural damage, so undervoltage protection remains important, though potentially at a lower ASIL level.

### Overcurrent Protection

**Hazard**: Current exceeds the cell's or pack's maximum rated current, causing excessive heat generation, lithium/sodium plating, or mechanical damage to the cell.

**Protective functions**:

*Primary*: Pack current monitoring (Hall sensor or shunt, Section 9.3) with software-enforced current limits. The BMS sets maximum current limits based on SOC, temperature, and SOH, and commands the motor controller to reduce torque (in discharge) or the charger to reduce current (in charge) if the limit is approached. Soft limits are enforced by communication commands; hard limits trigger contactor opening.

*Secondary*: The main HV fuse (Section 9.3) provides hardware-independent overcurrent protection. The fuse must be rated to interrupt the prospective short-circuit current of the pack without failing, and its time-current characteristic must be coordinated with the software limits so the fuse only blows in genuine fault conditions (not during legitimate high-current operation).

*Cell-level overcurrent*: Individual cell string fuses protect against internal pack faults (one string shorting to another, or a cell developing an internal short). These are passive devices that require no software.

**Plating protection**: As a sub-case of overcurrent protection, the BMS must enforce charging current limits that prevent lithium or sodium plating (Chapter 7, Section 7.3). The limit is a function of temperature and SOC, derived from the charge-transfer kinetics described by the Butler-Volmer equation (Chapter 2, Section 2.8). The critical constraint is this: if the charging current drives the anode's electrochemical potential below 0 V versus the Li/Li⁺ reference (the equilibrium potential of metallic lithium, introduced in Chapter 1), lithium metal will plate out on the anode surface instead of intercalating. At low temperatures, the charge-transfer resistance rises and the anode potential drops more sharply for a given current, so the safe charging current limit must be severely derated. At high SOC, the anode is nearly full and its equilibrium potential is already close to 0 V vs. Li/Li⁺, providing less margin. The combination of low temperature and high SOC is the most restrictive operating point for the plating prevention function.

### Overtemperature Protection

**Hazard**: Cell temperature exceeds safe operating limits, accelerating degradation (at moderate overtemperature) or initiating thermal runaway (at severe overtemperature).

**Protective functions**:

*Primary*: Cell and module temperature monitoring (thermistors or resistance temperature detectors distributed through the pack, measured by the BMS at 1–10 Hz). Software enforces temperature-dependent power limits and triggers contactor opening if temperature exceeds the emergency limit (typically 60°C for charging, 70°C for discharging for most LIB chemistries; higher for SIBs as noted in Chapter 8).

*Cooling system activation*: The BMS commands the thermal management system (coolant pump, fans, heater) to maintain cells within the optimal temperature window. This is a performance function as well as a safety function — it prevents the temperature from approaching the emergency limit in the first place.

*Thermal runaway detection*: A more demanding safety function distinct from overtemperature protection. Thermal runaway can initiate faster than the normal temperature monitoring loop can detect, particularly if it starts in a cell interior that is thermally insulated from the temperature sensors. Some BMS designs supplement temperature monitoring with **gas detection** (a sensor that detects the characteristic gas products of SEI decomposition and electrolyte combustion — CO, hydrogen, hydrocarbons) and with **voltage collapse detection** (a cell undergoing thermal runaway will show a sudden voltage drop as the cell is effectively shorted internally, even before the temperature rises to detectable levels). These secondary detection methods can provide earlier warning of runaway initiation than temperature alone.

### Isolation Loss Detection

**Hazard**: Loss of HV-to-chassis isolation exposes occupants or first responders to shock hazard.

**Protective functions**:

*Primary*: Continuous isolation monitoring by the IMD (Section 9.3). The IMD injects a test signal and measures the isolation resistance on both the positive and negative HV rails to chassis ground. The BMS opens the contactors if isolation resistance falls below the minimum threshold ($R_\text{iso} \geq 100 \; \Omega/\text{V}$ of pack voltage, or typically 40–200 kΩ for a 400 V system).

The IMD itself must be monitored for failure — a failed IMD that always reports "isolation good" would disable this protective function. Self-diagnostic features (the IMD periodically tests its own measurement path by applying a known test impedance) are required by ISO 26262 for this reason.

### Contactor Welding Detection

**Hazard**: A contactor whose contacts have welded shut — this occurs when the contacts are opened or closed while carrying high current, causing an electrical arc that locally melts and fuses the contact surfaces — cannot be opened by the BMS, leaving the HV bus permanently energised even when the BMS commands isolation.

**Protective functions**:

The BMS must perform a **contactor weld detection test** during each power cycle. The standard test procedure: command the negative contactor closed; measure the voltage across the positive contactor (which should be approximately equal to the full pack voltage if the positive contactor is open). If the voltage is approximately zero, the positive contactor is welded shut. Similarly, command all contactors open; measure the bus voltage (which should collapse to zero if all contactors are truly open). If bus voltage remains at pack voltage, a contactor is welded.

This detection must happen before the vehicle is considered safe to work on (e.g., during the end-of-session shutdown sequence) and must be reported to the driver and service technicians as a fault code. A vehicle with a welded contactor must not be operated until the contactor is replaced.

### Software Integrity: Watchdog Timers and Execution Monitoring

Beyond the individual protective functions, the software itself must be protected against its own failure modes. An embedded microcontroller running BMS firmware can fail in several ways. The main execution loop may stall due to an infinite loop or a deadlock in a semaphore. A stack overflow can corrupt the execution state, or a pointer error can cause the firmware to execute arbitrary memory contents. A bit-flip in SRAM — caused by high-energy neutrons from cosmic ray showers striking the silicon substrate — can corrupt a safety-critical variable. For automotive-grade SRAM, the soft error rate (SER) is on the order of 100–1000 FIT per megabit (where 1 FIT = 1 failure in $10^9$ device-hours), corresponding to roughly one upset per 1–10 million hours per megabit. At first glance this seems negligibly rare, but a modern BMS microcontroller with several megabits of SRAM running for millions of cumulative fleet-hours makes this a realistic — not hypothetical — failure mode.

The primary hardware protection against software failure is the **watchdog timer**: a hardware timer that the firmware must periodically reset ("pet") during normal execution. If the firmware stalls and fails to pet the watchdog, the timer expires and the watchdog resets the microcontroller — triggering a transition to the **safe state**, which is defined for each safety function as the system condition that eliminates or minimises the hazard. For most BMS functions, the safe state is "contactors open, pack isolated" — a condition that prevents both overcharge and overcurrent but also renders the vehicle inoperable. The safe state is not necessarily a desirable operating condition; it is the condition the system defaults to when it cannot guarantee safe continued operation. This ensures that a software failure does not leave the pack in an unsafe state indefinitely.

Additional software integrity measures required by ISO 26262 for ASIL C and D systems include:

**Stack monitoring**: The BMS software must monitor its own stack usage and trigger a safe state if stack usage approaches the stack size limit — indicating that a recursive call or stack corruption event is occurring.

**Memory protection**: A hardware memory protection unit (MPU) prevents one software task from writing to memory regions belonging to another task, preventing corruption of safety-critical variables by non-safety-critical code.

**CRC checks on safety-critical data**: Safety-critical tables stored in non-volatile memory (the OCV-SOC lookup table, the ASIL-rated software constants) must be verified by CRC checksum at power-up and periodically during operation. A corrupted OCV table could cause the BMS to miscalculate SOC and fail to enforce voltage limits correctly.

**Redundant SOC calculation paths**: For ASIL C/D SOC-dependent protective functions, the SOC estimate must be computed by two independent software paths or two independent hardware paths, and the results compared. Disagreement beyond a threshold triggers a fault. This is the software manifestation of the ASIL decomposition principle.

---

## 12.5 The Relationship Between Functional Safety and Battery Research

A researcher who develops a new BMS algorithm — a better SOC estimator, a novel degradation model, an improved balancing strategy — must understand where their work sits in the functional safety framework. Not because the researcher is responsible for writing the FMEA and developing the ASIL decomposition (that is the safety engineer's job), but because the research will eventually need to be translated into a product, and the translation requirements shape what the research must prove.

Specifically: an algorithm that will be used in a safety function at ASIL C or D must be developed under a disciplined software development process, with full documentation of its requirements, design, and verification. The verification must demonstrate not just that the algorithm works correctly under nominal conditions but that it fails gracefully under all relevant fault conditions — sensor failure, model parameter error, computational overflow, communication loss. An SOC estimator that diverges badly when the current sensor develops a 100 mA offset is a safety concern, not just a performance concern, if that divergence could cause the BMS to permit overcharge.

For sodium-ion batteries specifically, the interaction between functional safety requirements and the flat-OCV estimation challenge is a genuine open research problem. An ASIL D overcharge protection function that relies on accurate SOC estimation to enforce the upper voltage limit faces a specific challenge: if the SOC estimate is highly uncertain — recall from Chapter 10 that in the hard carbon plateau region, the OCV changes by less than 20 mV over a SOC range of 30–40%, so the EKF's correction gain from voltage measurements is near zero and the state uncertainty can grow to ±15–20% SOC within a few hours of steady-state operation — the safety function cannot confidently enforce the voltage limit based on SOC alone. The hardware-based voltage comparator (the secondary protection path described in Section 12.4) provides the safety backstop, but the software primary path has reduced diagnostic coverage in this region. Quantifying this reduced coverage, proposing algorithmic solutions (better SOC estimators for flat-OCV cells), and demonstrating their robustness to sensor faults and model errors — all of this constitutes valuable, publishable research that sits directly at the intersection of battery chemistry, estimation theory, and functional safety engineering.

The functional safety framework is not an obstacle to innovation; it is a specification of what a good BMS algorithm must prove about itself. Understanding that specification makes you a better researcher.

---

## Worked Interpretation Exercise: Reading a BMS Safety Concept Document

A **functional safety concept** document is one of the required deliverables in the ISO 26262 concept phase (Part 3). It describes, for each identified hazard and its associated safety goal, the top-level functional safety requirements that the system must implement. Let us work through a representative excerpt from a fictional but realistic BMS safety concept document.

---

*Document excerpt (fictional, representative of real BMS safety concept structure)*:

**Hazard ID**: H-BMS-003
**Hazard Description**: Cell overvoltage during fast charging
**Operational Situation**: EV connected to DC fast charger, charging in CC-CV mode
**Hazard Analysis Result**: S3 (potential thermal runaway → fire → fatalities), E4 (DC fast charging occurs on most long trips), C3 (thermal runaway is uncontrollable once initiated)
**ASIL**: ASIL D
**Safety Goal SG-003**: The BMS shall prevent any cell from exceeding 4.25 V during charging with a probability of failure less than $10^{-8}$ per hour.
**Note**: The safety goal is set at 4.25 V rather than the nominal 4.20 V upper limit to provide a 50 mV margin above the operational limit. The operational limit of 4.20 V is enforced by the primary software protection; the safety goal of 4.25 V is enforced by the independent hardware protection. The 50 mV gap ensures that activation of the hardware protection always indicates a genuine failure of the primary protection, preventing nuisance trips.

**Functional Safety Requirements (FSR)**:

FSR-003-A (ASIL D after decomposition: ASIL C from this path + ASIL A from FSR-003-B): The BMS shall monitor all cell voltages at a minimum rate of 20 Hz during charging. If any cell voltage exceeds 4.20 V for more than 100 ms, the BMS shall command the main positive contactor open within 50 ms.

FSR-003-B (ASIL A): A hardware voltage monitoring circuit, independent of the BMS microcontroller, shall compare each cell voltage to a hardwired reference of 4.25 V and directly open the main positive contactor if any cell voltage exceeds this reference, independent of BMS software state.

FSR-003-C (ASIL B): The BMS shall perform a cell voltage measurement chain diagnostic at each power-up, verifying that each CMIC channel responds correctly to a known test stimulus. If any CMIC channel fails the diagnostic, the BMS shall inhibit charging and report the fault.

---

Let us interpret this excerpt using the chapter's framework.

**The ASIL D classification**: Consistent with the S3/E4/C3 combination we worked through in Section 12.3. The safety goal is stated as a quantitative failure rate — $10^{-8}$/hour — which aligns with the ASIL D quantitative target for the probabilistic metric for random hardware failure (PMHF), defined in ISO 26262 Part 5. ISO 26262 descended from the process-industry standard IEC 61508 and shares its general approach to quantitative safety targets, though the specific values and their application to automotive systems are defined independently in ISO 26262.

**The 50 mV margin design**: This is a classic safety engineering pattern called **protection layer separation**. The operational protection (4.20 V, software) and the safety protection (4.25 V, hardware) are intentionally offset so they never compete. The safety layer only activates when the operational layer has failed — ensuring that the safety layer's activation is always a reliable fault indicator rather than an ambiguous event.

**FSR-003-A (ASIL C)**: The 20 Hz measurement rate and 100 ms response time define the worst-case overcharge duration before protection acts. Consider a DC fast charger supplying 3C charge current to a 5 Ah NMC cell near the end of charge. The voltage rise rate at this point is dominated by the steep tail of the OCV curve. We can estimate it as:

$$\frac{dV}{dt} \approx \frac{dOCV}{dSOC} \times \frac{I}{Q_\text{nom}} \tag{12.1}$$

Near full charge ($\text{SOC} > 0.95$), $dOCV/dSOC$ for NMC is steep — on the order of 2–5 V per unit SOC. For a 5 Ah cell at 3C (15 A), $dSOC/dt = 15/5 = 3 \; \text{hr}^{-1} \approx 8.3 \times 10^{-4} \; \text{s}^{-1}$. Taking $dOCV/dSOC \approx 3 \; \text{V}$, the voltage rise rate is roughly $3 \times 8.3 \times 10^{-4} \approx 2.5$ mV/s. At this rate, the cell would traverse the 50 mV gap from 4.20 V to 4.25 V in approximately 20 seconds — far slower than the 100 ms detection and the 50 ms contactor response time, confirming that the software protection has ample margin to prevent overshoot into the hardware protection threshold.

Note: this estimate ignores the additional IR overpotential that is present during charging (which would shift the measured terminal voltage above OCV by $I \times R_\text{int} \approx 15 \times 0.045 = 0.675 \; \text{V}$), but that overpotential is approximately constant during the final moments of CC charging and does not affect the *rate* of voltage rise. When the charger transitions to CV mode and begins reducing current, the terminal voltage is held constant by definition — so the hazardous overshoot scenario applies specifically to a fault where the CC-to-CV transition fails and the charger continues at full current past the voltage limit.

Notice that the response time requirement (50 ms to command contactor open after detecting overvoltage) is a real-time performance specification for the BMS firmware, not just a logical correctness requirement.

**FSR-003-B (ASIL A)**: The hardware path. Because it is the ASIL A half of an ASIL D decomposition, it "only" needs to meet ASIL A requirements — but it must be genuinely independent of the software path. The requirement that the hardware comparator "directly opens the main positive contactor" means there is a hardwired signal path from the comparator output to the contactor coil drive circuit that bypasses the BMS microcontroller entirely. A software deadlock cannot prevent this protection from activating.

**A common pitfall in ASIL decomposition**: Suppose a cost-conscious design routes both the BMS software voltage measurement and the "independent" hardware comparator through the same cell monitoring IC (CMIC), reasoning that the CMIC has separate digital and analog outputs. This violates the independence requirement — a single CMIC failure (power supply dropout, die crack, solder joint fracture) would disable both paths simultaneously. The ASIL decomposition would be invalid, and the system would not meet the ASIL D safety goal. In practice, achieving genuine independence often requires physically separate measurement ICs with separate power supplies and separate signal routing — an architectural constraint that adds cost and board area, but is non-negotiable for ASIL D decomposition. When you see a BMS design with what appears to be "redundant" measurement hardware, this independence requirement is almost always the reason.

**FSR-003-C (ASIL B)**: The diagnostic coverage requirement. Every time the vehicle powers on, the CMIC measurement chain must be verified. This is how the system confirms that the primary protection path (FSR-003-A) is actually functional. Without this diagnostic, a stuck-at-zero fault in the CMIC (which would make every cell appear to be at 0 V) would disable the primary protection indefinitely — and the only remaining protection would be the hardware comparator, which by itself only meets ASIL A. The diagnostic keeps the system within its ASIL D decomposition validity.

This kind of document analysis — tracing from hazard to ASIL to functional requirements to implementation details — is a skill you will need when working in a team developing commercially deployable BMS systems.

---

## What Changes for Sodium-Ion?

The functional safety framework (ISO 26262) applies identically to SIB packs as to LIB packs. The ASIL classification process is the same; the protective functions are structurally the same. The differences are in the specific numbers and in some hazard severity assessments.

**Lower thermal runaway severity may reduce some ASIL levels**: As established in Chapter 8, SIB cells have higher thermal runaway onset temperatures and lower total heat release than NMC LIB cells. If this difference is sufficient to change the severity classification of the overcharge hazard — from S3 to S2, for example, in a well-engineered pack design that contains the runaway within the pack without causing vehicle fire — then the resulting ASIL classification could drop from ASIL D to ASIL B for the overvoltage protection function. This potential ASIL reduction is commercially significant: ASIL B development requires substantially less engineering overhead than ASIL D. Whether the thermal characteristics of a specific SIB chemistry actually justify a severity downgrade requires a formal hazard analysis and evidence from abuse testing (nail penetration, overcharge, external fire tests) — it is not assumed.

**The flat OCV problem creates new diagnostic coverage challenges**: As discussed in Section 12.4, the BMS overcharge protection function relying on SOC estimation faces reduced diagnostic coverage when the cell is in the OCV plateau region (where SOC estimation uncertainty is high). A full FMEA of a SIB BMS must quantify this reduced coverage and demonstrate that the hardware protection path (which is voltage-based and unaffected by the SOC estimation uncertainty) provides sufficient independent protection. The specific failure mode — "SOC estimator reports 50% when true SOC is 95% because the cell has been in the plateau region and coulomb counting has drifted" — must appear in the FMEA and must be shown to be caught by the hardware comparator. This is a concrete safety engineering consequence of the estimation challenge first identified in Chapter 10.

**Voltage limits are different but the protection architecture is the same**: SIB upper voltage limits (3.9–4.2 V for layered oxide cathodes) and lower voltage limits (1.5–2.0 V) differ from LIB values, but the protection architecture — primary software monitoring, secondary hardware comparator, with independent paths — is identical in structure.

**Sodium metal hazard differs from lithium metal hazard**: Sodium plating (Chapter 7, Section 7.3) is less prone to dendrite formation and catastrophic short circuits than lithium plating. This may affect the severity classification of the plating-related hazard — and therefore the ASIL requirement for the charge current derating function (the algorithm that prevents plating by limiting charge current at low temperatures). A lower S-rating for the plating hazard in SIBs could reduce the ASIL requirement for the current derating function, with corresponding reductions in development cost and rigour. Whether this reduction is justified requires formal analysis with specific severity and controllability evidence.

---

## Chapter Summary

**Key ideas:**

- ISO 26262 is the international functional safety standard for automotive E/E systems, applicable to all BMS functions in road vehicles. It provides a structured methodology for classifying hazard risk and specifying the development rigor required to reduce that risk to an acceptable level.
- ASIL (Automotive Safety Integrity Level) is determined by three factors: Severity (S0–S3, consequences to persons if the hazard occurs), Exposure (E0–E4, frequency of the hazardous operating situation), and Controllability (C0–C3, ability to avoid harm once the hazard occurs). The combination yields QM (no specific requirements) through ASIL A–D (increasing rigor).
- BMS overcharge protection (potential to cause thermal runaway → fire → fatalities) is typically classified ASIL D under standard operating conditions (S3, E4, C3). This is the highest level and requires the most rigorous development processes, quantitative demonstration of failure probability below $10^{-8}$/hour, and full FMEA with diagnostic coverage quantification.
- ASIL decomposition allows an ASIL D requirement to be split into two independent paths (e.g., ASIL C software + ASIL A hardware), each meeting a lower level, provided the two paths are genuinely independent. This is why every safety-critical BMS function has both a software layer and a hardware-independent backup layer.
- Core BMS protective functions include: cell overvoltage protection (primary software cutoff + hardware comparator + cell CID), undervoltage protection, overcurrent protection (current limits + main fuse + cell fuses), overtemperature protection (temperature monitoring + active cooling), isolation loss detection (IMD with self-diagnostic), and contactor weld detection.
- Software integrity is addressed through watchdog timers, memory protection units, stack monitoring, CRC verification of safety-critical tables, and redundant calculation paths for ASIL C/D functions.
- For SIBs, the same framework applies. Potential differences include: lower thermal runaway severity may reduce some ASIL levels (if formally demonstrated through abuse testing); the flat-OCV estimation uncertainty creates specific diagnostic coverage gaps that must be addressed in the FMEA; sodium plating is less dendrite-prone, potentially reducing the ASIL requirement for the plating-prevention current derating function.

**Key vocabulary (in order of appearance):**

ISO 26262, functional safety, E/E system, ASIL (Automotive Safety Integrity Level), severity (S), exposure (E), controllability (C), QM (quality management), safety goal, functional safety concept, ASIL decomposition, FMEA (Failure Mode and Effects Analysis), FTA (Fault Tree Analysis), diagnostic coverage, cell overvoltage protection, hardware comparator, protection layer separation, current interrupt device (CID), cell undervoltage protection, overcurrent protection, charge current derating, overtemperature protection, thermal runaway detection, isolation monitoring device (IMD), contactor weld detection, watchdog timer, memory protection unit (MPU), stack monitoring, CRC checksum, redundant calculation path, safe state.

---

## Deliverable

The deliverable for Chapters 9–12 remains the Plett Coursera specialisation (Courses 1 and 2) with MATLAB assignments. Chapter 12 provides the safety context within which all the algorithms in Plett's courses must eventually operate in a commercial system.

As a focused exercise for this chapter, identify one BMS protective function from Section 12.4 (your choice — for example, the overtemperature protection or the contactor weld detection) and write a short functional safety analysis covering the following:

**Hazard identification**: State the hazard in the form "Hazard X can cause harm Y in operational situation Z." Be specific about the operational situation (driving, charging, storage, crash aftermath).

**ASIL classification**: Assign S, E, and C ratings to the hazard, justify each rating with a brief argument (one or two sentences), and determine the resulting ASIL from the table in Section 12.3.

**Functional safety requirements**: Write two functional safety requirements for this hazard — one for a software-based primary protection path and one for a hardware-based secondary protection path. Specify the ASIL level of each requirement after decomposition.

**Failure mode analysis (one failure mode)**: Identify one specific hardware failure mode in the primary protection path (e.g., "CMIC temperature sensor open circuit causing measured temperature to read 0°C") and describe: (a) how this failure would affect the protective function; (b) how the failure would be detected (diagnostic coverage); (c) what the BMS should do upon detecting this failure.

This exercise simulates a fragment of the hazard analysis and risk assessment (HARA) process defined in ISO 26262 Part 3, and is the kind of thinking you would need to do as part of a BMS development team.

**Partial worked example — overtemperature protection, sensor open-circuit failure**:

Hazard: Cell temperature exceeds upper safe limit during high-rate discharge, initiating thermal runaway. Operational situation: high-speed motorway driving at sustained high C-rate in ambient temperature of 40°C.

ASIL: S3 (thermal runaway risk), E3 (sustained high-rate motorway driving is a common but not constant situation), C3 (thermal runaway is uncontrollable). From the table: S3, C3, E3 → ASIL C.

Failure mode — NTC thermistor open circuit: If a temperature sensor develops an open circuit (broken wire, corroded connector, failed bead thermistor), the CMIC will read the maximum voltage on the measurement pin — which, for a typical voltage divider circuit, corresponds to approximately −40°C (the cold end of the calibration range). The BMS interprets this as "cell is very cold" and removes any temperature-based derating. At the true cell temperature of 50°C, the BMS would normally apply significant power derating — removing that derating at 50°C allows continued high-rate operation, potentially driving the cell toward thermal runaway.

Detection: The BMS must detect open-circuit sensor faults. For an NTC thermistor in a voltage divider, an open circuit produces a reading at the extreme cold limit of the calibration range — a reading of −40°C in a pack that cannot possibly be −40°C during driving is a detectable anomaly. The BMS firmware should implement a plausibility check: if the temperature reading is more than 25°C colder than ambient temperature (measured by an external sensor or inferred from the pack's other sensors), flag the measurement as failed.

Response: On detection of a failed temperature sensor, the BMS should apply a conservative fallback temperature (e.g., assume the cell is at 60°C, triggering the maximum derating), log the fault code for service attention, and illuminate a warning to the driver. The vehicle should complete its current trip safely under the conservative derating but should be serviced before the next trip.

---

## Further Reading

1. **ISO 26262:2018, *Road Vehicles — Functional Safety* (all parts).** The standard itself is the authoritative source. Parts 3, 4, and 9 are the most directly relevant to BMS design. The standard is available for purchase through ISO and national standards bodies. For educational access, many universities subscribe to standards databases (e.g., IEC Webstore, BSI) that provide access without individual purchase.

2. **Haberfellner, R. et al., *Systems Engineering: Fundamentals and Applications*, Birkhäuser (2019), Chapters on safety and dependability.** A comprehensive systems engineering text with strong coverage of safety analysis methods (FMEA, FTA, HAZOP) at the level of practical application. Provides the systems engineering context within which ISO 26262 functions.

3. **Ebert, C. and Parro, R., "Automotive Software," *IEEE Software* 31 (2), 10–13 (2014).** A concise overview of ISO 26262 as it applies to automotive software development, written for a software engineering audience. Explains ASIL, the V-model development process, and the software-specific requirements (MC/DC coverage, tool qualification) in accessible terms.

4. **Thaler, D. et al., "Safety Concept for BMS in Electric Vehicles Using ISO 26262," *Proceedings of IEEE Transportation Electrification Conference and Expo (ITEC)*, 2014.** One of the more accessible published worked examples of applying ISO 26262 to a BMS development programme, showing how hazard analysis, ASIL classification, and functional safety requirements are derived for real BMS functions. Directly applicable to the deliverable exercise.

5. **Xiong, R. et al., *Battery Management Algorithm for Electric Vehicles*, Springer (2020), Chapter 7.** Covers the integration of functional safety requirements with BMS algorithm design — specifically, how to design SOC and SOH estimators that meet ASIL requirements through redundancy and plausibility monitoring. The most direct connection between the estimation algorithms of Chapter 10 and the safety requirements of Chapter 12.

---

*Next chapter: **Chapter 13 — What's Different About Sodium.** We consolidate and deepen the sodium-ion specific material distributed throughout the book, examining every place where LIB modelling and BMS methods need systematic adaptation for SIB: ionic size and diffusion, hard carbon OCV and the plateau problem, the O3→P3 phase transition in cathodes, Al current collectors, low-temperature advantage, safety advantage, SEI differences, and the degradation modes unique to or amplified in SIB. Prompt me with "write Chapter 13" to continue.*

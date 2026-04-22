# Chapter 10: State Estimation

## Chapter Opening

Imagine you are driving an electric vehicle. The instrument cluster shows 47% battery remaining. You are 80 kilometres from home, and the navigation system estimates 75 kilometres of range. You decide to take a detour. How much can you trust that 47%?

The answer depends entirely on the quality of the state estimation algorithm running in your BMS. That algorithm is, in a precise engineering sense, solving a problem that has no perfect solution: it is trying to determine the internal electrochemical state of a battery — a quantity that cannot be measured directly from the outside — from a stream of terminal measurements that are noisy, drift over time, and are related to the hidden state through a nonlinear function that itself changes as the battery ages. The 47% on your dashboard is not a reading from a gauge. It is the output of a recursive estimator, continuously reconciling accumulated charge counts against voltage observations, and it is only as good as the model, the sensors, and the algorithm behind it.

State estimation is where battery science meets control theory, and it is one of the most intellectually satisfying problems in the field precisely because it requires fluency in both. The physics from Chapters 1 through 8 defines what the cell is. Chapter 9 showed how cells are assembled into packs — series and parallel strings, contactors, current sensors, the CAN bus data stream that a BMS reads every few milliseconds. This chapter defines how the BMS uses that data stream to answer the question every system ultimately cares about: how much energy is left, and how long will the pack last?

We will build the treatment from the ground up. We start with the simplest possible estimator — integrating the measured current — and examine exactly how and why it fails. We then add voltage measurements through the OCV-SOC lookup approach, and examine the fundamental limitation imposed by the OCV curve's shape — the flat-curve problem that has appeared repeatedly in this book and that will occupy us at length for the SIB case. We then develop the modern solution: a parameterised equivalent circuit model (ECM) combined with a Kalman filter that fuses current and voltage information optimally. Finally, we extend the framework from state-of-charge estimation to state-of-health estimation and remaining useful life prediction.

By the end of this chapter, you will be able to describe the ECM + Kalman filter BMS architecture at the level of a practicing engineer: you will know the model structure, the estimator equations, the tuning procedure, and the failure modes. You will also understand precisely where and why this architecture struggles for sodium-ion batteries — and what algorithmic modifications have been proposed to address it.

---

> **Prerequisites Check**
>
> From your EE/math background:
>
> - Linear algebra: matrix multiplication, matrix inverse, covariance matrices — essential for Sections 10.3 and beyond
> - Probability and statistics: Gaussian distributions, variance, conditional probability — needed for the Kalman filter derivation
> - State-space representations of dynamic systems ($\dot{x} = Ax + Bu$, $y = Cx + Du$) — the ECM is described in this form
> - Recursive least squares or Wiener filter intuition — helpful but not required
>
> From Chapters 3–5:
>
> - OCV-SOC curves and their shapes (Chapter 3, Section 3.4; Chapter 5) — central to Section 10.2
> - DCIR and the three resistance components (Chapter 3, Section 3.5) — needed for ECM parameterisation
> - Coulombic efficiency and SOH definitions (Chapter 3, Sections 3.6, 3.7) — needed for Section 10.4
>
> From Chapter 6:
>
> - Hard carbon OCV flat plateau (Section 6.5) — the central motivation for Section 10.2's flat-curve analysis
>
> From Chapter 9:
>
> - Current sensing accuracy and its limits (Section 9.3) — motivates the drift analysis in Section 10.1
> - CAN bus data availability (Section 9.4) — the measurement stream that feeds the estimator
>
> If your linear algebra is rusty — particularly matrix inverses and the concept of a covariance matrix — spend thirty minutes reviewing before Section 10.3. The Kalman filter derivation is the most mathematically demanding section in this book, and it will not make sense without that foundation.

---

## 10.1 Coulomb Counting and Its Drift Problem

The most direct approach to estimating state of charge is also the oldest: integrate the current. If you know how much charge has entered or left the battery since it was last at a known reference state, you know the current charge level.

### The Basic Algorithm

Coulomb counting (also called **current integration** or **ampere-hour integration**) implements the following discrete-time recursion:

$$\text{SOC}(k) = \text{SOC}(k-1) - \frac{\eta_i \cdot i(k) \cdot \Delta t}{Q_\text{max}} \tag{10.1}$$

where $\text{SOC}(k)$ is the estimated SOC at time step $k$, $i(k)$ is the measured current at time step $k$ (positive for discharge, negative for charge by the convention used here), $\Delta t$ is the sampling interval, $\eta_i$ is the **Coulombic efficiency**, and $Q_\text{max}$ is the current maximum capacity of the battery in amp-hours.

The Coulombic efficiency $\eta_i$ deserves a moment of attention. During discharge, essentially all the charge that leaves the battery corresponds to lithium (or sodium) ions actually de-intercalating from the anode — $\eta_i \approx 1$. During charge, however, a small fraction of the applied current drives parasitic side reactions (primarily SEI growth on the anode, as we established in Chapters 2 and 7) rather than intercalating ions. This fraction is "lost" in the sense that it consumes charge without increasing SOC. For a well-aged lithium-ion cell, $\eta_i$ during charge is typically 0.998–0.999; for a fresh cell still forming its SEI, it can be 0.99 or lower. For sodium-ion hard carbon anodes, the initial Coulombic efficiency is significantly lower (70–85%), which we will revisit in the SIB section.

The practical consequence for coulomb counting is straightforward: if the BMS uses $\eta_i = 1$ during charging, it will systematically *overestimate* the SOC gain from each charge event. Over many cycles, this overestimate accumulates — another source of drift, distinct from sensor error.

This is conceptually straightforward. For a 3.0 Ah cell ($Q_\text{max} = 3.0$ Ah) starting at SOC = 80%, discharging at $i = 3.0$ A (1C) for 30 minutes ($\Delta t = 1800$ s), and assuming $\eta_i = 1$:

$$\text{SOC}(\text{after 30 min}) = 0.80 - \frac{1 \times 3.0 \times 1800/3600}{3.0} = 0.80 - \frac{1.5}{3.0} = 0.80 - 0.50 = 0.30$$

After 30 minutes at 1C, the SOC estimate is 30%. This is correct by construction — if the current was exactly 3.0 A, the initial SOC was exactly 80%, and the capacity is exactly 3.0 Ah, the estimate is exact.

The problem is that none of those three "exactlys" hold in practice. Each one is an approximation, and their combined errors accumulate over time in a way that makes the estimate increasingly unreliable.

### The Three Sources of Drift

**Source 1 — Current sensor error**: Every current sensor has a combination of gain error, offset error, and noise. The offset error is the most damaging for coulomb counting because it is systematic — a constant offset integrates linearly with time. For a Hall-effect sensor with a 50 mA offset error and a 3.0 Ah cell, the SOC error after one hour of continuous operation at any current is:

$$\Delta \text{SOC}_\text{offset} = \frac{I_\text{offset} \times t}{Q_\text{max} \times 3600} = \frac{0.05 \times 3600}{3.0 \times 3600} = \frac{0.05}{3.0} \approx 1.7\% \text{ SOC per hour} \tag{10.1a}$$

where the factor of 3600 in the denominator converts $Q_\text{max}$ from amp-hours to coulombs for dimensional consistency with $I_\text{offset}$ (in amps) and $t$ (in seconds).

After 8 hours of operation, a 50 mA offset accumulates a 13.5% SOC error — enough to be practically significant. Hall sensors can have offsets of 50–200 mA; precision shunt sensors have lower offsets (5–20 mA) but are not immune.

Gain error (proportional to the measured current) causes an error that scales with total charge throughput. A 0.5% gain error on a cell cycled twice per day at 100% DOD accumulates a SOC error of approximately 0.5% per cycle — about 0.5 × 2 = 1% per day, or 180% per year if no recalibration is performed. This illustrates that gain error is equivalent to having the wrong value of $Q_\text{max}$ in equation (10.1).

Random noise, by contrast, produces a random walk error that grows as $\sqrt{N}$ with the number of samples rather than linearly. For typical current sensor noise levels (10–30 mA RMS), the SOC error from noise alone after 3600 samples (one hour at 1-second intervals) is:

$$\Delta \text{SOC}_\text{noise} = \frac{\sigma_I \sqrt{N} \Delta t}{Q_\text{max} \times 3600} = \frac{0.02 \times \sqrt{3600} \times 1}{3.0 \times 3600} = \frac{0.02 \times 60}{10800} \approx 0.011\% $$

Noise error is manageable with filtering and is much smaller than offset or gain error — but it is non-zero and accumulates over extended operation.

**Source 2 — Incorrect $Q_\text{max}$**: The Coulombic efficiency $\eta_i$ and the maximum capacity $Q_\text{max}$ in equation (10.1) must be correct for the algorithm to work. Both change as the battery ages. If $Q_\text{max}$ has decreased from 3.0 Ah to 2.7 Ah due to degradation (SOH = 90%) but the BMS is still using the original 3.0 Ah value, every charge and discharge operation is miscounted by 10% — a systematic error that persists until $Q_\text{max}$ is recalibrated.

**Source 3 — Unknown initial SOC**: Equation (10.1) requires a known starting SOC. If the battery has been resting for an unknown time (the car was parked, the grid storage system was offline for maintenance), the initial SOC must either be assumed or measured from OCV. Any error in the initial SOC is not a drift — it is a fixed offset bias that persists forever until corrected.

### The Compounding Problem

These three error sources compound. After a day of driving with a 50 mA offset error, a 0.5% gain error, and an initial SOC uncertainty of 2%, the SOC estimate can be off by 5–10% or more. In a 60 kWh EV pack, a 5% SOC error corresponds to 3 kWh of misattributed energy — the difference between "I have enough range to reach my destination" and "I do not." This is not a theoretical concern; early BMS implementations with inadequate current sensor calibration and no correction mechanisms produced exactly these kinds of errors, manifest as range anxiety and unexpected low-battery warnings.

The obvious engineering response is to periodically recalibrate. When the battery reaches a known reference state — fully charged (SOC = 100%) or fully discharged (SOC = 0%) — the accumulated error can be reset. This is why some EV BMS systems use a "balancing charge" to a fixed upper voltage on a regular cycle: it recalibrates the SOC estimate by driving the pack to a known endpoint. But this requires the vehicle to be fully charged (or fully discharged) periodically, which is not always practical or desirable (deep discharge accelerates degradation, as we established in Chapter 7). A better approach is to recalibrate continuously during normal operation, using OCV measurements during rest periods — which leads to the voltage-based approach of Section 10.2, and ultimately to the model-based fusion approach of Section 10.3.

---

## 10.2 OCV-Based SOC Lookup and Why Flat OCV Curves Break It

The second pillar of SOC estimation is the relationship between open-circuit voltage and state of charge. If you know the OCV curve — $E_\text{OCV}(\text{SOC})$ — and you can measure the OCV, you can invert the relationship to get the SOC:

$$\hat{\text{SOC}} = f^{-1}(E_\text{OCV}) \tag{10.2}$$

where $f^{-1}$ denotes the inverse of the OCV-SOC function.

In principle, this provides a recalibration anchor for coulomb counting: whenever the battery has been at rest long enough for the terminal voltage to relax to true OCV, you can read off the SOC from the OCV-SOC curve and reset the coulomb counting estimate. In practice, several complications limit this approach.

### The Rest Time Problem

As we established in Chapters 2 and 3, the terminal voltage after current stops is not immediately equal to the OCV. The concentration overpotentials and activation overpotentials take time to relax — on the order of minutes to hours for diffusion-limited polarisation in thick electrodes. A BMS that reads voltage 30 seconds after the current stops and looks up the result on the OCV curve will get a wrong answer: the voltage is still above OCV for charging (or below OCV for discharging) by the residual overpotential, and the SOC estimate will be biased.

For automotive applications, rest periods are irregular and often short. A driver who parks for 5 minutes and then drives again does not give the battery time to reach true OCV equilibrium. Some BMS algorithms use a **relaxation model** — estimating how much of the overpotential has decayed after a given rest time, and correcting the voltage measurement accordingly — but this requires an accurate model of the overpotential decay dynamics, which is itself temperature- and SOC-dependent.

### The OCV Curve Sensitivity

Assuming the battery has rested long enough for the terminal voltage to approximate the true OCV, we face a second question: how precisely can we convert that OCV reading into an SOC value? This depends entirely on the shape of the OCV-SOC curve, and the key quantity is its slope.

The intuition is straightforward. Think of the OCV-SOC curve as a ruler that maps voltage readings to SOC values. A steep curve is like a ruler with closely-spaced, clearly distinguishable markings — a small change in SOC produces a large, easily measurable change in voltage, so even a slightly noisy voltage reading still maps to a narrow range of SOC. A flat curve is like a ruler with markings so far apart that you cannot tell where you are between them — many different SOC values all produce essentially the same voltage, and the voltage measurement tells you almost nothing.

Let us make this quantitative. If the voltage measurement has an uncertainty of $\sigma_V$ (from sensor noise and residual relaxation error), the resulting SOC uncertainty is:

$$\sigma_\text{SOC} = \frac{\sigma_V}{|dE_\text{OCV}/d\text{SOC}|} \tag{10.3}$$

A steep OCV curve (large $|dE_\text{OCV}/d\text{SOC}|$) gives small SOC uncertainty from a given voltage uncertainty. A flat OCV curve (small $|dE_\text{OCV}/d\text{SOC}|$) gives large SOC uncertainty. In the limit of a perfectly flat plateau, $dE_\text{OCV}/d\text{SOC} = 0$ and equation (10.3) gives infinite SOC uncertainty — voltage provides literally no information about SOC.

For a practical NMC/graphite cell, $dE_\text{OCV}/d\text{SOC}$ varies significantly with SOC. In the steepest regions (below 15% and above 85% SOC), the slope can exceed 2000 mV per unit SOC. In the flattest mid-SOC region — near the graphite Stage 2/Stage 2L transition around 40–55% SOC — it can dip to roughly 300–600 mV per unit SOC. Taking a conservatively flat mid-range value of 500 mV per unit SOC (i.e., a 500 mV OCV change per 100% SOC change), with a voltage measurement uncertainty of $\sigma_V = 5$ mV (a realistic value for a well-calibrated cell voltage monitor with 16-bit ADC resolution over a 4 V range):

$$\sigma_\text{SOC,NMC} = \frac{0.005}{0.5} = 0.01 = 1\%$$

A 1% SOC uncertainty from OCV measurement alone is quite good — this is why OCV-based recalibration works well for NMC cells across most of the SOC range, and why NMC is considered "BMS-friendly." Even in the flattest mid-range region, the OCV measurement provides a useful correction to coulomb counting.

For LFP/graphite, the flat plateau region (spanning roughly 20–80% SOC) has $dE_\text{OCV}/d\text{SOC} \approx 15$–50 mV per unit SOC — the Fe²⁺/Fe³⁺ two-phase reaction produces an extremely flat voltage characteristic near 3.3 V:

$$\sigma_\text{SOC,LFP} = \frac{0.005}{0.025} = 0.20 = 20\%$$

A 20% SOC uncertainty from a 5 mV voltage error renders the OCV measurement essentially useless for SOC estimation in the LFP plateau. Only at the top and bottom of the SOC range, where the curve steepens dramatically (slopes exceeding 1000 mV per unit SOC), does OCV become informative. For the majority of the LFP cell's operating range, a BMS must rely entirely on coulomb counting — with all the drift problems that implies.

### The SIB Hard Carbon Flat Plateau: A More Severe Version of the LFP Problem

For a sodium-ion cell with a hard carbon anode, the full-cell OCV during the plateau region of hard carbon sodiation (approximately 20–50% of the total cell capacity, as established in Chapter 6) is nearly constant. The full cell voltage in this region is approximately the cathode OCV (which itself may be relatively flat for some cathode chemistries) minus the nearly-zero anode potential — producing a doubly-flat region in the full cell OCV.

The numbers are stark. For a representative HiNa BC-1 cell (O3 layered oxide cathode / hard carbon anode), published GITT data show the full-cell OCV varying by approximately 30–50 mV over the SOC range corresponding to the plateau region — spanning roughly 25–30% of total capacity. This gives:

$$\frac{dE_\text{OCV}}{d\text{SOC}} \approx \frac{40 \times 10^{-3}}{0.27} \approx 148 \text{ mV per unit SOC}$$

At first glance, 148 mV per unit SOC is only 2–4× lower than NMC's flattest mid-range region — not the order-of-magnitude deficit we might have expected. So where is the problem? The answer is that the average slope across the entire plateau masks the local behaviour within it. Let us be more careful.

The deeper problem for SIBs is not the average slope per se but that the plateau **anchors** the voltage to a narrow range near 3.1–3.15 V cell OCV regardless of where within the plateau the cell is. When the cell is in the plateau region, the BMS cannot distinguish between 30% SOC and 55% SOC from voltage alone — both produce approximately the same OCV. The 148 mV/unit SOC slope means a 5 mV voltage measurement error gives a 3.4% SOC uncertainty in that region, which sounds acceptable until you realise that the critical uncertainty is not the slope within the region but the ability to determine which plateau the cell is on — slope region or plateau region — and where within the plateau the cell is.

The real challenge is the shape discontinuity. When transitioning between the slope region (large $dE/d\text{SOC}$) and the plateau region (small $dE/d\text{SOC}$), the OCV drops steeply and then flattens. A BMS observing the transition into the plateau from the slope region knows the cell has entered the plateau, but from that moment forward loses the ability to track progress through the plateau using voltage. The cell has essentially disappeared into a voltage dead zone that may last through 25–50% of its remaining capacity.

This is compounded by the **hysteresis** in the hard carbon OCV curve. The slope region and plateau region both exhibit hysteresis between charge and discharge (as discussed in Chapter 6) — the cell OCV at a given SOC during charging is noticeably different from the OCV at the same SOC during discharging. A BMS using a single OCV-SOC table without distinguishing charge from discharge direction introduces a systematic SOC error that can reach 5–10% in the hard carbon plateau region. For SIB BMS algorithms, maintaining separate OCV curves for charge and discharge, and tracking the recent current direction to select the appropriate curve, is necessary but not sufficient — the hysteresis itself is a continuous function of the most recent cycling history, not a simple two-state switch.

**The practical conclusion**: For SIB cells, OCV-based SOC correction is available and useful at the extremes of the SOC range (below ~15% and above ~85% SOC, where both the hard carbon slope region and the cathode OCV are changing significantly). Over the middle 70% of the SOC range — dominated by the hard carbon plateau — the BMS must rely almost entirely on coulomb counting. The consequences for algorithm design are significant and will be discussed further in Section 10.3 and in Chapter 13.

---

## 10.3 Model-Based Estimation: The ECM + Kalman Filter

The limitations of coulomb counting (drift without correction) and OCV lookup (works poorly on flat curves) motivate a more principled approach: a dynamic model that describes how the battery's terminal voltage responds to the current profile, combined with an optimal filter that continuously fuses the model prediction with the voltage measurement to correct the SOC estimate.

The dominant framework for this approach in commercial BMS applications is the **equivalent circuit model (ECM)** paired with an **extended Kalman filter (EKF)**. This pairing was systematised and popularised by Gregory Plett in a series of papers beginning in 2004 and subsequently in his textbook *Battery Management Systems* — the primary source recommended in the chapter plan.

### The Equivalent Circuit Model

An equivalent circuit model represents the battery's electrical behaviour using a circuit consisting of an ideal voltage source (the OCV), a series resistance (the ohmic resistance $R_0$), and one or more parallel RC networks (representing the dynamic polarisation response). The most commonly used form is the **second-order RC model** (also called the **two-RC model** or **Dual Polarization model**):

```text
      R0         R1          R2
  +--/\/\/---+--/\/\---+--/\/\---+
  |          |         |         |
 OCV(SOC)   C1        C2       Terminal
  |          |         |         |
  +----------+---------+---------+
```

Each element in this circuit has a clear physical counterpart. The voltage source $E_\text{OCV}(\text{SOC})$ represents the thermodynamic equilibrium voltage — a nonlinear function of SOC determined by the OCV-SOC curve from Chapter 3. It is the voltage you would measure at the terminals after infinite rest.

The series resistance $R_0$ is the **ohmic resistance**: the sum of the ionic resistance of the electrolyte, the electronic resistance of the current collectors and electrode particles, and the contact resistances at interfaces. When current begins to flow, $R_0$ produces an instantaneous voltage drop — no time constant, just Ohm's law.

The first RC pair ($R_1$, $C_1$) represents the **activation polarisation** — the charge-transfer dynamics at the electrode-electrolyte interface that we described with the Butler-Volmer equation in Chapter 2. Why does a charge-transfer process look like an RC circuit? Because the electrode-electrolyte interface has a double-layer capacitance $C_\text{dl}$ (the capacitor formed by the charge separation at the interface), and the charge-transfer reaction has a finite resistance $R_\text{ct}$ (the linearised Butler-Volmer slope). Together they form a parallel RC with a time constant $\tau_1 = R_1 C_1$, typically 1–30 seconds for lithium-ion cells. This is the same double-layer model you encounter in EIS analysis (Chapter 3, Section 3.10).

The second RC pair ($R_2$, $C_2$) represents the **concentration polarisation** — the slow buildup and relaxation of ion concentration gradients inside the electrode particles and the electrolyte. This process is fundamentally diffusive (governed by Fick's law, as discussed in Chapter 2), and a diffusion process is not truly an RC circuit — it is more accurately modeled as a transmission line, with an infinite number of infinitesimal RC elements in cascade. The single RC pair is an approximation that captures the dominant time constant of the diffusion response, typically $\tau_2 = R_2 C_2 = 30$–600 seconds. It is a useful engineering approximation that sacrifices the fine structure of the diffusion impedance (the Warburg tail visible in EIS data) for computational tractability.

The terminal voltage predicted by this model is:

$$V_\text{terminal}(t) = E_\text{OCV}(\text{SOC}) - R_0 \cdot i(t) - V_{C_1}(t) - V_{C_2}(t) \tag{10.4}$$

where $V_{C_1}$ and $V_{C_2}$ are the voltages across the two capacitors, governed by:

$$\dot{V}_{C_1} = -\frac{V_{C_1}}{R_1 C_1} + \frac{i}{C_1} = -\frac{V_{C_1}}{\tau_1} + \frac{i}{C_1} \tag{10.5}$$

$$\dot{V}_{C_2} = -\frac{V_{C_2}}{R_2 C_2} + \frac{i}{C_2} = -\frac{V_{C_2}}{\tau_2} + \frac{i}{C_2} \tag{10.6}$$

These two differential equations describe the charge/discharge of the polarisation capacitors in response to the applied current. At steady state (constant current for $t \gg \tau_1, \tau_2$), $V_{C_j} = R_j \cdot i$, and the total steady-state voltage drop across the RC networks is $R_1 i + R_2 i$, consistent with the DC polarisation overpotential.

### The State-Space Formulation

To apply the Kalman filter, we need the ECM in discrete-time state-space form. Recall from your controls coursework that a state-space model describes a dynamic system by choosing a set of internal variables — the **state vector** $\mathbf{x}$ — that fully characterise the system's memory (everything the system "remembers" from the past that affects its future behaviour). The state evolves according to a transition equation ($\mathbf{x}(k) = f(\mathbf{x}(k-1), u(k-1))$), and the measurable output is a function of the state ($y(k) = h(\mathbf{x}(k), u(k))$). For our ECM, the "input" $u$ is the current $i$, the "output" $y$ is the terminal voltage, and the internal states are the quantities that carry memory from one time step to the next.

What are those quantities? The SOC itself is one — it tracks the accumulated charge and determines the OCV. The voltages across the polarisation capacitors ($V_{C_1}$ and $V_{C_2}$) are the others — they carry the memory of recent current history and determine the dynamic voltage drops. Together, these three quantities fully characterise the battery's electrical state at any instant. Define the state vector:

$$\mathbf{x}(k) = \begin{bmatrix} \text{SOC}(k) \\ V_{C_1}(k) \\ V_{C_2}(k) \end{bmatrix} \tag{10.7}$$

The state transition equations (using first-order Euler discretisation with sampling interval $\Delta t$, or the exact zero-order hold for the RC equations) are:

$$\text{SOC}(k) = \text{SOC}(k-1) - \frac{\eta_i \cdot i(k-1) \cdot \Delta t}{Q_\text{max}} \tag{10.8}$$

$$V_{C_1}(k) = e^{-\Delta t/\tau_1} V_{C_1}(k-1) + R_1(1 - e^{-\Delta t/\tau_1}) i(k-1) \tag{10.9}$$

$$V_{C_2}(k) = e^{-\Delta t/\tau_2} V_{C_2}(k-1) + R_2(1 - e^{-\Delta t/\tau_2}) i(k-1) \tag{10.10}$$

The output (measurement) equation is:

$$V_\text{terminal}(k) = E_\text{OCV}(\text{SOC}(k)) - R_0 \cdot i(k) - V_{C_1}(k) - V_{C_2}(k) + w(k) \tag{10.11}$$

where $w(k)$ is the measurement noise (voltage sensor noise).

In compact form, this is a nonlinear state-space system:

$$\mathbf{x}(k) = \mathbf{A}\mathbf{x}(k-1) + \mathbf{B}i(k-1) + \mathbf{q}(k-1) \tag{10.12}$$
$$y(k) = h(\mathbf{x}(k), i(k)) + w(k) \tag{10.13}$$

where $\mathbf{A}$ and $\mathbf{B}$ are the state transition and input matrices encoding equations (10.8)–(10.10), $h(\cdot)$ is the nonlinear measurement function in equation (10.11), $\mathbf{q}$ is the process noise (modelling uncertainty in the state equations, including current sensor error), and $w$ is the measurement noise.

The system is nonlinear because $E_\text{OCV}(\text{SOC})$ is a nonlinear function of SOC. This is what requires the **Extended** Kalman filter rather than the standard (linear) Kalman filter.

If your controls coursework covered observability, you may recognise the flat-OCV problem as a loss of observability. A system is observable if its internal state can be uniquely determined from a finite history of output measurements. For the ECM state-space model, the observability matrix depends on the Jacobian $\mathbf{C}$, which contains $dE_\text{OCV}/d\text{SOC}$ as its first element. When this derivative approaches zero, the system loses observability for the SOC state — the voltage output becomes insensitive to SOC, and no amount of voltage data can determine where the cell is within the plateau. The RC polarisation states $V_{C_1}$ and $V_{C_2}$ remain observable (their effect on voltage is always present through the $-1$ entries in $\mathbf{C}$), but SOC becomes a "hidden" state that the output cannot see. This is not a limitation of the EKF algorithm — it is a property of the physical system, and no algorithm can extract information that the physics does not provide.

### The Extended Kalman Filter

The standard Kalman filter is an optimal recursive estimator for linear systems with Gaussian noise. A common misconception deserves attention here. The Kalman filter is "optimal" in a very specific sense: it minimises the mean-squared estimation error among all linear estimators, given a linear system with Gaussian noise and perfectly known model parameters. Three caveats follow immediately. First, the ECM is not linear — the OCV function is nonlinear — so we use the *Extended* KF, which linearises at each step and is therefore *not* guaranteed to be optimal. It is a good approximation when the nonlinearity is mild (which it usually is, except in the plateau region where the OCV curve has a sharp slope change). Second, the noise is not truly Gaussian — current sensor errors have systematic components (bias, temperature drift) that violate the Gaussian assumption. Third, and most importantly, the filter is only as good as its model: if the ECM parameters are wrong (because the cell has aged, or the temperature has changed, or the OCV table is inaccurate), the "optimal" filter produces suboptimal results. In practice, the EKF works well not because it is optimal in the mathematical sense, but because it is robust — it degrades gracefully when assumptions are violated, and it can be augmented with adaptive parameter estimation (Section 10.4) to track slow model changes.

For the nonlinear ECM, we use the Extended Kalman Filter (EKF), which linearises the nonlinear measurement function around the current state estimate at each time step. The EKF proceeds in two alternating steps:

**Prediction step** (propagate the state forward using the model):

$$\hat{\mathbf{x}}^-(k) = \mathbf{A}\hat{\mathbf{x}}(k-1) + \mathbf{B}i(k-1) \tag{10.14}$$

$$\mathbf{P}^-(k) = \mathbf{A}\mathbf{P}(k-1)\mathbf{A}^T + \mathbf{Q} \tag{10.15}$$

where $\hat{\mathbf{x}}^-$ is the a priori (before measurement) state estimate, $\mathbf{P}^-$ is the a priori error covariance matrix (a $3 \times 3$ matrix for the two-RC model), and $\mathbf{Q}$ is the process noise covariance matrix (encoding our uncertainty in the state equations themselves).

**Update step** (correct the prediction using the new voltage measurement):

First, compute the linearised measurement matrix $\mathbf{C}(k)$ — the Jacobian of the measurement function $h$ with respect to the state, evaluated at the current estimate:

$$\mathbf{C}(k) = \frac{\partial h}{\partial \mathbf{x}}\bigg|_{\hat{\mathbf{x}}^-(k)} = \begin{bmatrix} \frac{dE_\text{OCV}}{d\text{SOC}}\bigg|_{\hat{\text{SOC}}^-} & -1 & -1 \end{bmatrix} \tag{10.16}$$

The first element of $\mathbf{C}$ is the slope of the OCV curve evaluated at the current SOC estimate — and this is exactly where the flat-OCV problem enters the Kalman filter. If $dE_\text{OCV}/d\text{SOC} \approx 0$, the measurement matrix has near-zero first element, meaning the voltage measurement carries almost no information about SOC. The filter correctly "ignores" the voltage for SOC correction in this region and relies on the prediction (coulomb counting) instead.

Then compute the Kalman gain $\mathbf{K}(k)$:

$$\mathbf{K}(k) = \mathbf{P}^-(k)\mathbf{C}^T(k)\left[\mathbf{C}(k)\mathbf{P}^-(k)\mathbf{C}^T(k) + R\right]^{-1} \tag{10.17}$$

where $R$ is the measurement noise variance (the variance of the voltage sensor noise $w$). Note the notational overload: this $R$ is the scalar noise variance in the Kalman filter equations — not the resistance parameters $R_0$, $R_1$, $R_2$ of the ECM. Some textbooks use $\sigma_v^2$ or $R_w$ to avoid this collision; we follow Plett's convention and use $R$ for the measurement noise, relying on context to distinguish it from the circuit resistances.

The Kalman gain $\mathbf{K}$ determines how much the state estimate should be corrected based on the measurement residual (the discrepancy between the measured voltage and the predicted voltage). It is the optimal trade-off between trusting the model prediction and trusting the measurement: when $\mathbf{P}^-$ is large (the state estimate is uncertain) relative to $R$ (the measurement noise), the gain is high and the measurement correction is large. When $\mathbf{P}^-$ is small (the estimate is confident) or $R$ is large (the sensor is noisy), the gain is low and the estimate barely moves.

Finally, update the state estimate and covariance:

$$\hat{\mathbf{x}}(k) = \hat{\mathbf{x}}^-(k) + \mathbf{K}(k)\left[y(k) - h(\hat{\mathbf{x}}^-(k), i(k))\right] \tag{10.18}$$

$$\mathbf{P}(k) = [\mathbf{I} - \mathbf{K}(k)\mathbf{C}(k)]\mathbf{P}^-(k) \tag{10.19}$$

The term $y(k) - h(\hat{\mathbf{x}}^-(k), i(k))$ is the **innovation** — the difference between what was measured and what the model predicted. If the innovation is consistently non-zero in a systematic direction (always positive, always increasing), it signals that the model is biased — either the OCV curve is wrong, the resistance parameters are wrong, or the $Q_\text{max}$ is wrong. The innovation signal is a rich diagnostic tool for identifying model parameter errors.

### Intuition for the Kalman Filter

Let me offer the intuitive framing that makes the EKF feel natural rather than mechanical.

Think of the EKF as a person trying to navigate in a fog using two sources of information: a map and a compass. The map (the ECM state equations) says "if you were at position $x$ and walked in direction $\theta$ for time $t$, you should now be at position $x'$." The compass (the voltage measurement) says "your current direction to the lighthouse is $\phi$." Neither is perfectly reliable — the map might be slightly wrong (process noise), and the compass might jitter (measurement noise). The optimal navigator takes both pieces of information and forms a weighted average: if the map is more trustworthy at this moment, rely more on the prediction; if the compass is giving a clear signal and the map is uncertain, trust the compass more.

The Kalman gain $\mathbf{K}$ is precisely this trust weighting, computed optimally at each step. The error covariance $\mathbf{P}$ tracks how uncertain the current estimate is — a large diagonal element in $\mathbf{P}$ corresponding to SOC means the SOC estimate is uncertain, which increases the Kalman gain for SOC, which means the next voltage measurement will move the SOC estimate more aggressively.

The flat OCV curve (small $dE/d\text{SOC}$ in equation 10.16) is equivalent to a navigator in fog whose compass is giving nearly identical readings regardless of which direction the lighthouse is in — the compass is still measuring something, but the information about position is nearly zero. The EKF correctly concludes that the lighthouse measurement is nearly uninformative about position and relies more heavily on dead reckoning (the model). The SOC uncertainty $\mathbf{P}_{11}$ grows throughout the flat-curve region because no good correction mechanism is available.

If the navigator analogy does not resonate, here is a signal-processing framing that may feel more natural. The EKF is a sensor-fusion algorithm — the same class of algorithm used in IMU/GPS fusion for navigation, or in combining accelerometer and gyroscope data in a smartphone. You have two "sensors" that both report on the same hidden quantity (SOC):

Sensor A is the current integral (coulomb counting). It has excellent short-term precision — over a few seconds, the accumulated charge tells you how much SOC has changed with high accuracy. But it has unbounded long-term drift, like an open-loop integrator with a DC offset at its input.

Sensor B is the voltage measurement, interpreted through the OCV curve. It provides an absolute reference (no drift), but its precision depends on the OCV slope and is contaminated by polarisation transients. It is like a position sensor with bounded noise but a signal-to-noise ratio that varies with operating point.

The EKF is the optimal way to combine a drifting integrator with a noisy absolute reference — exactly the problem of fusing an inertial measurement unit (high-bandwidth, drifting) with a GPS receiver (low-bandwidth, absolute). If you have studied complementary filters in signal processing, the EKF is their principled, adaptive, model-based generalisation. The Kalman gain $\mathbf{K}$ adjusts the fusion weights at every time step based on how informative each "sensor" is at that moment — and in the flat-OCV region, Sensor B's SNR drops to near zero, leaving the estimator to coast on Sensor A alone.

### ECM Parameter Identification

The ECM parameters — $R_0$, $R_1$, $C_1$, $R_2$, $C_2$ (or equivalently $R_1$, $\tau_1$, $R_2$, $\tau_2$), and the OCV-SOC curve — must be identified from experimental data. The standard approach is:

**OCV-SOC curve**: Measured by GITT (Chapter 3, Section 3.10) at multiple temperatures. The table $E_\text{OCV}$ vs. SOC is stored in BMS memory as a lookup table, typically sampled at 1% SOC intervals. A polynomial or spline fit allows interpolation and differentiation (to compute $dE_\text{OCV}/d\text{SOC}$ needed for the EKF linearisation).

**$R_0$**: Extracted from the instantaneous voltage drop at the onset of HPPC current pulses (Section 3.10). $R_0 = |\Delta V_\text{instant}| / I$.

**$R_1, \tau_1, R_2, \tau_2$**: Extracted from the voltage relaxation after HPPC pulses, fitting the exponential decay:

$$V(t) = V_\infty + A_1 e^{-t/\tau_1} + A_2 e^{-t/\tau_2} \tag{10.20}$$

where $A_j = R_j \cdot I$ and $V_\infty$ is the final rested OCV value.

All parameters are functions of SOC and temperature, so the identification is performed at multiple SOC setpoints (typically 10%, 20%, ..., 90%) and multiple temperatures (typically −20°C, 0°C, 10°C, 25°C, 40°C). The resulting parameter tables are stored in BMS memory and interpolated during runtime.

For a full ECM characterisation of a single cell chemistry, the experimental effort is substantial: GITT at 5 temperatures × 9 SOC points (45 conditions) plus HPPC at the same 45 conditions, giving 90 individual test events in total — each requiring careful setup, equilibration, and post-processing. This is the hidden cost of deploying a model-based BMS — the upfront characterisation work is significant.

### Comparing SOC Estimation Approaches

Before examining how the EKF performs specifically for SIBs, it is worth pausing to compare the three SOC estimation approaches we have developed. The table below summarises their key characteristics.

| Property | Coulomb Counting | OCV Lookup | ECM + EKF |
| --- | --- | --- | --- |
| Information source | Current sensor | Voltage sensor + OCV curve | Both, fused optimally |
| Accuracy over short intervals | Excellent | N/A (requires rest) | Excellent |
| Accuracy over long intervals | Poor (unbounded drift) | Good (absolute reference) | Good (drift corrected) |
| Requires rest period? | No | Yes (minutes to hours) | No |
| Sensitivity to flat OCV curves | None | Fatal (no information) | Degraded (reverts to coulomb counting) |
| Computational cost | Trivial (one multiply-add) | Trivial (table lookup) | Moderate (matrix operations per time step) |
| Requires model parameterisation? | Only $Q_\text{max}$, $\eta_i$ | OCV-SOC table | Full ECM parameters at multiple SOC/T |
| Initial SOC error correction | None | Yes (if OCV informative) | Yes (converges within seconds to minutes) |

The EKF's strength is clear: it inherits the short-term precision of coulomb counting and the long-term stability of OCV-based correction, at the cost of computational complexity and upfront parameterisation effort. Its weakness — the flat-OCV region — is inherited directly from the OCV lookup and is fundamental, not algorithmic.

### The EKF for SIBs: What Changes

The EKF framework applies identically to SIBs. The state vector is the same (SOC, $V_{C_1}$, $V_{C_2}$), the filter equations are the same, and the OCV-SOC curve is simply replaced with the SIB cell's OCV-SOC curve. The difference is in the performance of the filter during the flat OCV region.

As we showed in Section 10.2, when $dE_\text{OCV}/d\text{SOC} \approx 0$, the measurement matrix $\mathbf{C}$ has near-zero first element. The Kalman gain for SOC drops to near zero, and the SOC uncertainty $\mathbf{P}_{11}$ grows unboundedly during the plateau. Simulations of EKF performance on SIB cells with hard carbon anodes consistently show that SOC error grows during the plateau region and is only corrected when the cell exits the plateau into the slope region (at either end of the SOC range).

Several algorithmic modifications have been proposed in the research literature to improve EKF performance for flat-OCV batteries, and it is worth surveying the landscape briefly.

The **sigma-point (unscented) Kalman filter (UKF)** more accurately propagates non-Gaussian uncertainty through the nonlinear OCV function by using carefully chosen sample points rather than the EKF's first-order Taylor linearisation. This can reduce divergence during the flat region compared to the EKF, but it is an incremental improvement — the fundamental information deficit remains, because no amount of statistical sophistication can extract SOC information from a voltage that genuinely does not depend on SOC.

The **particle filter** takes a different approach entirely: it represents the state distribution with a cloud of weighted "particles" (Monte Carlo samples) rather than a single Gaussian. This allows the filter to represent multimodal distributions — useful when the cell might plausibly be anywhere within a 30-percentage-point-wide plateau. The cost is computational: a particle filter with enough particles for good performance (typically 100–1000) requires far more computation per time step than the EKF, which is challenging for real-time BMS implementation on the low-power microcontrollers that dominate automotive BMS hardware.

A more physics-informed approach uses **online electrochemical impedance spectroscopy (EIS)** to extract SOC-dependent information beyond the DC voltage. The Warburg impedance component — which reflects solid-state diffusion within the electrode particles — changes with the local ion concentration and therefore with SOC, even in the plateau region where the DC voltage is flat. If the BMS hardware can inject a small AC perturbation and measure the impedance at specific frequencies, this provides an additional "sensor channel" for SOC that is independent of the OCV slope. The approach is promising but requires EIS measurement hardware beyond what most commercial BMS systems include today.

Finally, **dual-model frameworks** take a pragmatic engineering approach: they run separate state estimators for the slope and plateau regions, with transition logic to switch between them based on the observed OCV dynamics. The slope-region estimator uses the standard EKF with full voltage correction; the plateau-region estimator relies on a carefully calibrated coulomb counter with temperature-dependent and ageing-dependent corrections applied to $Q_\text{max}$ and $\eta_i$. This approach sacrifices elegance for robustness and is the closest to what current commercial SIB BMS implementations use.

The SOC estimation challenge for SIBs is one of the most practically important open problems in SIB systems engineering, and it is a legitimate target for EE-focused simulation research. We will return to it in Chapter 13.

---

## 10.4 SOH Estimation: Capacity-Based and Resistance-Based

SOC estimation tells you where the battery is right now. **State-of-health (SOH) estimation** tells you how the battery has changed from its original specification — the long-term degradation state that determines remaining useful life and future performance limits.

SOH estimation is harder than SOC estimation for a fundamental reason: SOC changes on the timescale of minutes to hours (a single charge/discharge cycle), while SOH changes on the timescale of months to years (hundreds to thousands of cycles). This temporal separation means that SOH cannot be estimated from a single measurement event — it must be tracked over many cycles.

As defined in Chapter 3, there are two primary SOH metrics:

$$\text{SOH}_Q = \frac{Q_\text{max}(t)}{Q_\text{rated}} \times 100\% \quad \text{(capacity-based)} \tag{10.21}$$

$$\text{SOH}_R = \frac{R_0(t=0)}{R_0(t)} \times 100\% \quad \text{(resistance-based)} \tag{10.22}$$

Both must be estimated because they track different degradation modes (as we established in Chapter 7): LLI primarily drives capacity fade, while impedance growth (from SEI growth and particle cracking) drives resistance rise. A cell can have high SOH$_Q$ and low SOH$_R$ (or vice versa), and the correct operational response differs.

### Capacity-Based SOH Estimation

The maximum capacity $Q_\text{max}$ can be measured directly by performing a slow full charge-discharge cycle at C/20 and integrating the current. This gives the most accurate value but requires a full charge-discharge sequence — not always practical during normal operation.

For online SOH estimation (without dedicated reference tests), the BMS must estimate $Q_\text{max}$ from partial charge and discharge data seen during normal operation. The standard approach is:

**Direct integration between known reference points**: If the BMS observes the battery go from a rest-state OCV reading of $V_1$ (corresponding to SOC$_1$ from the OCV curve) to rest-state OCV reading of $V_2$ (corresponding to SOC$_2$), with total coulombs $\Delta Q$ flowing between the two rest events:

$$Q_\text{max} = \frac{|\Delta Q| \cdot \eta_i}{|\text{SOC}_2 - \text{SOC}_1|} \tag{10.23}$$

where $\Delta Q$ is the total charge throughput (in Ah) measured between the two rest events, and $\eta_i$ accounts for the fraction of charge that actually changes the SOC (versus charge consumed by side reactions). For discharge events where $\eta_i \approx 1$, this simplifies to $Q_\text{max} = |\Delta Q| / |\Delta\text{SOC}|$. The absolute value signs avoid sign confusion across different current conventions.

This is accurate when the two OCV reference points are well separated in SOC (otherwise the denominator is small and the estimate is noisy), and when the OCV measurements are accurate (the flat-OCV problem applies here too — if both reference points are in the plateau region, the denominator $\text{SOC}_2 - \text{SOC}_1$ cannot be determined from OCV alone).

**Adaptive integration via EKF**: If $Q_\text{max}$ is included as an additional state variable in the EKF (turning the 3-state SOC estimator into a 4-state joint SOC/capacity estimator), the filter can update the capacity estimate online as new current-voltage data accumulates. The process noise for the $Q_\text{max}$ state is set to a very small value (capacity changes slowly), while the capacity update is driven by the accumulated innovation between measured and predicted voltage. This "adaptive EKF" or "joint EKF" approach is the state of the art for online capacity tracking.

**Incremental capacity analysis (ICA)**: As discussed in Chapter 7, the $dQ/dV$ curve is a diagnostic fingerprint for degradation. The area under specific peaks corresponds to specific portions of capacity, and as capacity fades, the peak areas decrease proportionally. An online ICA algorithm that tracks peak areas over cycles provides both capacity estimation and degradation mode identification — a rich but computationally demanding approach.

### Resistance-Based SOH Estimation

The ohmic resistance $R_0$ and the charge-transfer resistance $R_\text{ct}$ can be estimated from HPPC-style current pulses that occur naturally in a normal operating cycle. Every time the current changes significantly (an acceleration event in an EV, a step change in grid power demand), a short pulse is effectively applied to the battery and the voltage response can be used to extract impedance information.

For real-time $R_0$ estimation:

$$\hat{R}_0(k) = \frac{|V(k^+) - V(k^-)|}{\Delta I} \tag{10.24}$$

where $V(k^+)$ is the voltage immediately after a current step of magnitude $\Delta I$ at time $k$, and $V(k^-)$ is the voltage immediately before. This is the instantaneous ohmic resistance extracted from the voltage jump at current steps — a technique that works whenever the current changes abruptly, which happens constantly during real drive cycles or variable-power grid operation.

The estimated $R_0$ sequence is noisy at any single event but can be filtered with a **recursive least squares (RLS)** estimator or an EKF to produce a slowly-evolving estimate that tracks the true $R_0$ through aging. RLS is a classic adaptive filtering algorithm — it maintains a running estimate of a parameter (here, $R_0$) by incorporating each new observation with a weight that diminishes as the estimate becomes more confident. If you studied the Wiener filter or LMS adaptive filter in a signals course, RLS is their faster-converging, deterministic cousin: it uses the full inverse correlation matrix rather than a stochastic gradient, giving optimal convergence at each step at the cost of slightly more computation. For resistance tracking, RLS is well-suited because $R_0$ changes slowly (over weeks to months) and each new current-step event provides one fresh data point. The increase in estimated $R_0$ over the pack's life is a direct measure of resistance-based SOH degradation.

For $R_\text{ct}$ and the RC time constants, online estimation is harder because it requires observing the full polarisation dynamics over time windows of 30–600 seconds — longer than many operational events. Dedicated periodic test pulses (inserted by the BMS during rest periods, for example during stationary charging with a deliberate current interruption) can provide cleaner estimates, but at the cost of small energy losses from the test pulses.

### SOH Fusion: Combining Capacity and Resistance

The most complete SOH assessment combines capacity-based and resistance-based estimates. A simple but effective approach is the **SOH map**: a two-dimensional space with SOH$_Q$ on one axis and SOH$_R$ on the other, in which different regions correspond to different dominant degradation modes (following the Birkl et al. framework from Chapter 7). As the pack ages, the SOH trajectory through this space reveals which degradation mechanisms are active and how their relative contributions evolve.

For example, a cell whose SOH trajectory moves primarily along the SOH$_Q$ axis (large capacity loss, small resistance increase) is dominated by LLI — likely SEI growth on the anode. A cell moving primarily along the SOH$_R$ axis (large resistance increase, modest capacity loss) may be dominated by cathode surface reconstruction or electrolyte oxidation. A cell moving diagonally (both capacity and resistance degrading proportionally) may have particle cracking driving both LAM and increased impedance from new SEI formation.

The SOH map approach is used in sophisticated fleet management systems where tracking the degradation trajectory of individual cells helps predict maintenance needs and remaining service life. It connects directly to the degradation physics of Chapter 7 and the diagnostic tools of Chapter 3.

---

## 10.5 Remaining Useful Life (RUL) Prediction

If SOH tells you where the battery is on the degradation curve, **remaining useful life (RUL)** tells you how far it is from the end of that curve. RUL prediction is the forward projection of SOH estimation: given where the battery is today and how fast it has been degrading, when will it reach the end-of-life criterion (typically SOH$_Q$ = 80%)?

RUL is the metric that connects battery management to system-level planning: when to schedule battery replacement in a fleet vehicle, when the warranty obligation expires, whether the pack has enough life remaining to justify an expensive repair, or whether to continue operating a grid storage system or retire it.

### Model-Based RUL: Extrapolating the Degradation Trajectory

The simplest RUL prediction extrapolates the current degradation trajectory forward in time. If the capacity-based SOH has been decreasing at an average rate of $\dot{s}$ (SOH units per cycle), and the current SOH is $s$, then the remaining life in cycles is:

$$\text{RUL}_\text{cycles} = \frac{s - s_\text{EOL}}{|\dot{s}|} \tag{10.25}$$

where $s_\text{EOL} = 0.80$ (80% SOH for the end-of-life criterion). If SOH = 0.92 and the average rate is $\dot{s} = -0.0001$ SOH per cycle, then $\text{RUL} = (0.92 - 0.80)/0.0001 = 1200$ cycles remaining.

The critical limitation is that degradation is not constant-rate. As established in Chapter 7, the degradation rate typically accelerates in late life (the "knee" of the capacity-fade curve), as mechanical degradation exposes more fresh surface for SEI formation and creates a positive feedback loop. A linear extrapolation underestimates end-of-life time when the cell is in early life (before the knee) and overestimates it once the cell is past the knee.

Better models use the physics-based degradation laws from Chapter 7 to project the trajectory more accurately. For calendar aging, the square-root-time model gives:

$$Q_\text{max}(t) = Q_\text{rated} - B \exp(-E_a/RT) \sqrt{t} \tag{10.26}$$

which can be extrapolated forward in time given the current temperature and SOC profile. For cycle aging:

$$Q_\text{max}(N) = Q_\text{rated} - C \cdot N^z \cdot f(\text{DOD}) \cdot g(T) \tag{10.27}$$

where $N$ is the number of equivalent full cycles and the functions $f$, $g$ encode the DOD and temperature stressors as established in Chapter 7. By fitting these models to the historical SOH trajectory and projecting forward under an assumed future operating profile, the BMS can produce a distribution of RUL estimates rather than a single point estimate.

### Probabilistic RUL and Confidence Intervals

Deterministic RUL prediction is useful but misleading — it implies a precision that does not exist. All degradation models have parameter uncertainty, the future operating profile is unknown, and there are stochastic elements in the degradation process itself (random particle cracking events, variable ambient temperature). A more honest representation gives a probability distribution over remaining useful life rather than a single number.

The standard tools for probabilistic RUL estimation are **Bayesian approaches** (which update a prior distribution over degradation model parameters as new data accumulates) and **particle filters** (a Monte Carlo method well-suited to non-Gaussian distributions and nonlinear degradation models). Both produce a posterior distribution over SOH at each future time point, from which percentile RUL estimates (e.g., "80% probability that RUL > 200 cycles") can be extracted.

This probabilistic framing is particularly important for fleet management. Rather than asking "when will this cell reach EOL?", the fleet manager asks "what is the probability that this cell survives to the next scheduled maintenance interval?" This probability can be computed from the RUL distribution and used to schedule predictive maintenance — replacing cells before they fail rather than after, at minimum total cost.

### Data-Driven RUL: Machine Learning Approaches

The alternatives to physics-based RUL prediction are data-driven approaches — machine learning models trained on large datasets of battery aging cycles. The most successful approaches include:

**Gaussian process regression (GPR)**: A non-parametric Bayesian regression method — think of it as fitting an infinite ensemble of smooth curves to the data and averaging over them, weighted by how well each curve matches the observations. Unlike polynomial regression, GPR does not assume a fixed functional form for the capacity-fade trajectory; instead, it defines a prior distribution over possible curves through a kernel function that encodes smoothness assumptions. The result is a flexible curve fit to the capacity-fade history that extrapolates forward with explicit uncertainty quantification — at each future time point, GPR provides both a predicted capacity and a confidence interval.

**Recurrent neural networks (RNN) and long short-term memory (LSTM) networks**: Deep learning models that process the sequence of voltage-current-temperature measurements over many cycles and learn to predict remaining capacity or RUL. These models can be remarkably accurate when trained on large datasets from the same cell chemistry, but they are opaque (no mechanistic interpretation), require large training datasets, and often fail to generalise to different operating conditions or chemistries not seen during training.

**Early-cycle degradation features**: An influential result from Severson et al. (*Nature Energy*, 2019) showed that features extracted from the first 100 charge-discharge cycles (specifically, changes in the capacity vs. voltage curves) predict cycle life with surprisingly high accuracy — comparable to physics-based models that use data from hundreds of cycles. This suggests that early-life degradation patterns contain enough information to predict long-term fate, at least for a given cell chemistry and operating protocol.

For SIB RUL estimation, the data-driven approaches face the specific challenge that large training datasets for SIB cells are not yet available — the technology is too new. Physics-based models, parameterised from the degradation mechanisms established in Chapter 7, are therefore the primary RUL estimation approach for SIB research in the near term. Building those physics-based degradation models for SIBs — and validating them against the limited experimental data available — is one of the open research problems we will identify in Chapter 14.

---

## Worked Interpretation Exercise: Simulating an EKF for a Simple Cell Model

Let us work through a simplified EKF simulation to make the algorithm concrete. We use a one-RC ECM (simplified from the two-RC model, to keep the matrices manageable) with the following parameters for a representative NMC/graphite cell at 25°C:

$Q_\text{max} = 3.0$ Ah; $R_0 = 40$ mΩ; $R_1 = 20$ mΩ; $\tau_1 = R_1 C_1 = 30$ s (so $C_1 = 30/0.020 = 1500$ F).

OCV curve: approximately linear over 20–90% SOC as $E_\text{OCV}(\text{SOC}) = 3.0 + 1.2 \times \text{SOC}$ V (a crude linearisation that captures the general slope; real curves are more complex).

Initial true SOC: 70%; initial estimated SOC: 60% (a 10% initial error, simulating poor calibration at startup).

**Step 0 — Initialise**:

$$\hat{\mathbf{x}}(0) = \begin{bmatrix} 0.60 \\ 0 \end{bmatrix}, \quad \mathbf{P}(0) = \begin{bmatrix} 0.01 & 0 \\ 0 & 10^{-4} \end{bmatrix}$$

The $(1,1)$ element of $\mathbf{P}(0)$ is 0.01 (SOC variance = $0.1^2$, corresponding to ±10% uncertainty). The $(2,2)$ element is small (we are fairly confident the initial RC voltage is near zero since the cell is assumed to have been at rest).

Process noise: $\mathbf{Q} = \text{diag}(10^{-8}, 10^{-6})$ — small, reflecting that our model is fairly accurate.
Measurement noise: $R = (5 \times 10^{-3})^2 = 2.5 \times 10^{-5}$ V² (5 mV RMS sensor noise).

**Step 1 — Prediction** (cell is being discharged at $i = 1.5$ A, $\Delta t = 1$ s):

State transition matrices:

$$A = \begin{bmatrix} 1 & 0 \\ 0 & e^{-1/30} \end{bmatrix} = \begin{bmatrix} 1 & 0 \\ 0 & 0.9672 \end{bmatrix}$$

$$B = \begin{bmatrix} -\eta_i \Delta t / (Q_\text{max} \times 3600) \\ R_1(1 - e^{-1/30}) \end{bmatrix} = \begin{bmatrix} -1 \times 1/(3.0 \times 3600) \\ 0.020 \times 0.0328 \end{bmatrix} = \begin{bmatrix} -9.26 \times 10^{-5} \\ 6.56 \times 10^{-4} \end{bmatrix}$$

Predicted state:
$$\hat{\mathbf{x}}^-(1) = \begin{bmatrix} 1 & 0 \\ 0 & 0.9672 \end{bmatrix}\begin{bmatrix} 0.60 \\ 0 \end{bmatrix} + \begin{bmatrix} -9.26 \times 10^{-5} \\ 6.56 \times 10^{-4} \end{bmatrix}(1.5) = \begin{bmatrix} 0.5999 \\ 9.84 \times 10^{-4} \end{bmatrix}$$

Predicted covariance: $\mathbf{P}^-(1) = \mathbf{A}\mathbf{P}(0)\mathbf{A}^T + \mathbf{Q}$ — computed similarly, grows slightly due to process noise addition.

**Step 1 — Update** (assume measured terminal voltage is $y(1) = 3.779$ V — this is the true terminal voltage at 70% SOC with the given ECM parameters, plus a small noise draw):

Linearised measurement matrix (slope of OCV at estimated SOC = 0.5999):
$$C(1) = \begin{bmatrix} \frac{dE_\text{OCV}}{d\text{SOC}}\bigg|_{0.5999} & -1 \end{bmatrix} = \begin{bmatrix} 1.2 & -1 \end{bmatrix}$$

Predicted output:
$$\hat{y}^-(1) = E_\text{OCV}(0.5999) - R_0 \cdot 1.5 - V_{C_1}^-(1) = (3.0 + 1.2 \times 0.5999) - 0.040 \times 1.5 - 9.84 \times 10^{-4}$$
$$= 3.7199 - 0.0600 - 0.00098 = 3.6589 \text{ V}$$

Innovation: $3.779 - 3.659 = 0.120$ V. This large innovation reflects the 10% initial SOC error — the model predicts a voltage consistent with 60% SOC, but the true cell (at 70% SOC) produces a higher voltage. Even after only 1 second of operation, the voltage mismatch is 120 mV — far larger than the 5 mV sensor noise — giving the filter a strong correction signal.

Kalman gain: $K = P^- C^T / (C P^- C^T + R)$ — at this point the $P^-_{11} = 0.01$ is much larger than $R/C_{11}^2 = 2.5 \times 10^{-5}/1.44 \approx 1.7 \times 10^{-5}$, so the gain is high — the filter trusts the measurement correction.

The state update pushes the SOC estimate significantly toward its true value of 70%. Over approximately 10–30 time steps (10–30 seconds of operation), the EKF converges: the SOC error shrinks from 10% to well below 2%, and the error covariance $\mathbf{P}_{11}$ shrinks to a small value reflecting the converged estimate.

This convergence — the ability to correct a large initial SOC error within seconds to minutes of operation using only terminal current and voltage measurements — is the most important practical property of the EKF-based BMS. It means the BMS does not need to start from a precisely known SOC (which would require a full charge to a reference state); it can self-correct from any reasonable initial estimate.

**What changes in the plateau region**: If this same cell were an SIB with a flat OCV curve, the $C_{11}$ element in the measurement matrix would be small (say, 0.04 instead of 1.2). The Kalman gain for SOC would drop by a factor of 30, and the convergence time would lengthen from 10–30 seconds to 300–900 seconds. With typical SIB operating profiles (rest periods of minutes, not hours), the EKF may never fully converge during the plateau region, and the 10% initial error persists through the plateau — exactly the SIB-specific challenge we identified in Section 10.2.

---

## What Changes for Sodium-Ion?

The state estimation architecture — ECM + EKF, with SOH tracking via adaptive parameters and RUL projection from degradation models — applies directly to SIBs. The algorithms are the same; the parameters and performance differ.

**The flat OCV problem (Sections 10.2 and 10.3)**: This is the central challenge. The EKF Kalman gain for SOC drops near zero during the hard carbon plateau, causing SOC uncertainty to grow. All proposed solutions (UKF, particle filter, EIS-based correction, dual-model frameworks) are active research topics. For a simulation researcher, this is a concrete and tractable problem: implementing an EKF on a simulated SIB cell model and demonstrating the SOC uncertainty growth in the plateau region — and then proposing and evaluating a modification — is a publishable contribution.

**Higher $R_0$ and $R_\text{ct}$**: The ECM parameters for SIB cells are larger than for comparable LIB cells (Section 6.5). This means the voltage excursions during current pulses are larger, which actually helps current-step-based $R_0$ estimation (larger signal-to-noise ratio for the impedance estimate). It is, unexpectedly, one area where the SIB's high internal resistance is an advantage for BMS estimation.

**SOH and capacity tracking**: The lower ICE of hard carbon (typically 70–85%, versus 90–95% for graphite in LIBs) and the possibility of more volatile per-cycle LLI (from less stable SEI) mean that capacity tracking algorithms may need higher process noise on the $Q_\text{max}$ state and more frequent OCV recalibration events to maintain accuracy. The degradation rate parameters for SIBs are not yet as well characterised as for LIBs, which means that physics-based degradation models (for RUL) have higher parameter uncertainty for SIBs in the near term.

**Hysteresis in the OCV curve**: Hard carbon exhibits stronger OCV hysteresis than graphite — the charge and discharge OCV curves differ by 50–100 mV in the slope region and somewhat less in the plateau. Standard EKF implementations use a single OCV curve; BMS algorithms for SIBs must account for hysteresis either through separate charge/discharge OCV tables (with logic to select the appropriate one based on recent current direction) or through a **hysteresis state variable** $h(k)$ added to the state vector. The idea is to augment the state from $[\text{SOC}, V_{C_1}, V_{C_2}]^T$ to $[\text{SOC}, V_{C_1}, V_{C_2}, h]^T$, where $h$ is a scalar that tracks the hysteresis voltage — the gap between the charge-path and discharge-path OCV at the current SOC. The hysteresis state evolves according to a first-order model: $h(k) = \gamma \cdot h(k-1) + (1-\gamma) \cdot M(\text{SOC})$, where $\gamma$ is a rate constant and $M(\text{SOC})$ is the maximum hysteresis at the current SOC. The terminal voltage equation (10.4) is then modified to include $h$ as an additional term: $V_\text{terminal} = E_\text{OCV}(\text{SOC}) + h - R_0 i - V_{C_1} - V_{C_2}$. Plett's group published this framework for LFP cells (which also exhibit significant OCV hysteresis), and it can be adapted for SIB hard carbon anodes — representing another concrete research opportunity for EE-focused simulation work.

---

## Chapter Summary

**Key ideas:**

- Coulomb counting integrates current to track SOC but drifts due to sensor offset error (linear in time), sensor gain error (proportional to charge throughput), incorrect $Q_\text{max}$, and unknown initial SOC. Offset errors of 50–200 mA produce SOC errors of 1–7% per hour; gain errors compound over cycles.
- OCV-based SOC lookup provides absolute reference points but requires sufficient rest time for voltage relaxation and a steep OCV curve. SOC uncertainty from voltage measurement $\sigma_V$ is $\sigma_\text{SOC} = \sigma_V / |dE/d\text{SOC}|$. On flat OCV curves (LFP, SIB hard carbon plateau), $|dE/d\text{SOC}| \approx 0$ and OCV provides negligible information about SOC — the fundamental SIB estimation challenge.
- The ECM (OCV source + $R_0$ + RC network) is the standard model for BMS estimation. The two-RC model captures ohmic, activation, and diffusion dynamics with parameters identified from HPPC and GITT data, tabulated as functions of SOC and temperature.
- The Extended Kalman Filter fuses current integration (model prediction) with voltage measurement (update step) optimally. The Kalman gain $\mathbf{K}$ balances trust between model and measurement. The OCV slope $dE/d\text{SOC}$ appears in the linearised measurement matrix; when the slope is near zero (flat OCV region), the gain drops to zero and the voltage provides no SOC correction — the filter degrades to pure coulomb counting with growing uncertainty.
- SOH is estimated online via: capacity tracking using partial charge integrals between OCV reference points, adaptive EKF with $Q_\text{max}$ as an additional state, or ICA peak area tracking. Resistance-based SOH tracks $R_0$ from step-current voltage jumps using RLS or EKF filtering.
- RUL prediction extrapolates the SOH trajectory forward using physics-based degradation models (calendar: $\sqrt{t}$ Arrhenius; cycle: power-law in cycle count, DOD, temperature) or data-driven models (GPR, LSTM). Probabilistic RUL gives a distribution rather than a point estimate, enabling cost-optimal predictive maintenance.

**Key equations:**

$$\text{SOC}(k) = \text{SOC}(k-1) - \frac{\eta_i i(k) \Delta t}{Q_\text{max}} \quad \text{(coulomb counting)} \tag{10.1}$$

$$\sigma_\text{SOC} = \frac{\sigma_V}{|dE_\text{OCV}/d\text{SOC}|} \quad \text{(OCV-based SOC uncertainty)} \tag{10.3}$$

$$V_\text{terminal} = E_\text{OCV}(\text{SOC}) - R_0 i - V_{C_1} - V_{C_2} \quad \text{(ECM output equation)} \tag{10.4}$$

$$\mathbf{K}(k) = \mathbf{P}^-\mathbf{C}^T[\mathbf{C}\mathbf{P}^-\mathbf{C}^T + R]^{-1} \quad \text{(Kalman gain)} \tag{10.17}$$

$$\hat{\mathbf{x}}(k) = \hat{\mathbf{x}}^-(k) + \mathbf{K}(k)[y(k) - h(\hat{\mathbf{x}}^-(k), i(k))] \quad \text{(EKF update)} \tag{10.18}$$

$$\mathbf{C}(k) = \begin{bmatrix} \frac{dE_\text{OCV}}{d\text{SOC}} & -1 & -1 \end{bmatrix} \quad \text{(linearised measurement matrix; first element drives SOC correction)} \tag{10.16}$$

**Key vocabulary (in order of appearance):**

Coulomb counting, current integration, ampere-hour integration, Coulombic efficiency, sensor offset error, sensor gain error, initial SOC uncertainty, OCV-SOC lookup, OCV curve sensitivity, rest time relaxation, flat OCV problem, equivalent circuit model (ECM), one-RC / two-RC model, ohmic resistance $R_0$, activation polarisation, concentration polarisation, RC time constant, state-space formulation, state vector, observability, state transition matrix, extended Kalman filter (EKF), prediction step, update step, a priori estimate, error covariance matrix $\mathbf{P}$, process noise $\mathbf{Q}$, measurement noise $R$, measurement matrix $\mathbf{C}$, Kalman gain $\mathbf{K}$, innovation, adaptive EKF, SOH estimation, capacity tracking, resistance tracking, recursive least squares (RLS), degradation trajectory, remaining useful life (RUL), physics-based RUL, data-driven RUL, Gaussian process regression, LSTM, OCV hysteresis state, dual-model framework, particle filter.

---

## Deliverable

The primary deliverable for this part of the book (Chapters 9–12) is completing Plett's Coursera specialisation "Algorithms for Battery Management Systems," Courses 1 and 2. This chapter is the direct preparation for that work.

Before starting Course 2 (which covers the SPKF/EKF algorithms), ensure you can answer the following from this chapter without looking up the answers:

Write the discrete-time state equations for the one-RC ECM (equations 10.8 and 10.9). What is the physical meaning of the time constant $\tau_1$? Why is the exponential form ($e^{-\Delta t/\tau}$) used instead of the Euler approximation? (Answer: the exponential form is the exact zero-order-hold solution for a first-order ODE; Euler integration introduces error proportional to $\Delta t/\tau$ which can be significant if $\Delta t$ is not much smaller than $\tau_1$.)

Write the EKF Kalman gain equation. Explain in words why the first element of the measurement matrix $\mathbf{C}$ is $dE_\text{OCV}/d\text{SOC}$ rather than, say, the full $E_\text{OCV}$ value. (Answer: because the gain equation uses the linearised system model — it needs how much the voltage changes for a small change in SOC, which is the derivative of the output with respect to the state, evaluated at the current estimate.)

For an LFP/graphite cell at 50% SOC (in the flat plateau, $dE/d\text{SOC} = 25$ mV per unit SOC) with $\sigma_V = 5$ mV and $P_{11} = 0.04$, compute the Kalman gain for SOC (the $(1,1)$ element of $\mathbf{K}$). Compare to the same cell at 10% SOC where $dE/d\text{SOC} = 80$ mV per unit SOC. Interpret the difference.

---

## Further Reading

1. **Plett, G. L., "Extended Kalman filtering for battery management systems of LiPB-based HEV battery packs. Parts 1, 2, and 3," *Journal of Power Sources* 134 (2), 252–292 (2004).** The three-part paper that established the ECM + EKF framework for BMS estimation. Part 1 covers the dynamic models; Part 2 the parameter identification; Part 3 the filter implementation and validation. This is the foundational reference for the entire field of model-based BMS estimation. Read all three parts.

2. **Plett, G. L., *Battery Management Systems, Vol. 2: Equivalent-Circuit Methods*, Artech House (2015).** The comprehensive textbook treatment of everything in this chapter, with full MATLAB code examples and worked problems. Chapters 4–6 on the EKF, sigma-point Kalman filter (SPKF), and adaptive estimation are the direct reading for this chapter's material. This is the primary Plett reference for the BMS Coursera course.

3. **Hu, X., Li, S., and Peng, H., "A comparative study of equivalent circuit models for Li-ion batteries," *Journal of Power Sources* 198, 359–367 (2012).** A systematic comparison of one-RC, two-RC, and more complex ECM structures against experimental data, showing the accuracy–complexity trade-off. Essential for understanding which model order is sufficient for a given application.

4. **Severson, K. A. et al., "Data-driven prediction of battery cycle life before capacity degradation," *Nature Energy* 4, 383–391 (2019).** The influential paper showing that early-cycle charge-voltage curve features predict long-term cycle life with high accuracy. Read this for the data-driven RUL perspective and to understand what battery degradation information is encoded in early-life data.

5. **Zheng, Y. et al., "State of charge estimation for lithium battery systems using an adaptive extended Kalman filter considering temperature dependence," *IEEE Transactions on Control Systems Technology* 22 (2), 589–600 (2014).** A careful treatment of temperature-dependent ECM parameterisation and adaptive EKF implementation, including a discussion of how parameter uncertainty propagates into SOC estimation error. The most practically useful reference for implementing the temperature-dependent ECM tabulation described in Section 10.3.

---

*Next chapter: **Chapter 11 — Cell Balancing.** We examine why cells drift apart in a series string, the consequences of imbalance, and the two main balancing architectures — passive (resistive bleed) and active — along with the control strategies that govern when and how much to balance. Prompt me with "write Chapter 11" to continue.*

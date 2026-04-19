# Chapter 10: State Estimation

## Chapter Opening

Imagine you are driving an electric vehicle. The instrument cluster shows 47% battery remaining. You are 80 kilometres from home, and the navigation system estimates 75 kilometres of range. You decide to take a detour. How much can you trust that 47%?

The answer depends entirely on the quality of the state estimation algorithm running in your BMS. That algorithm is, in a precise engineering sense, solving a problem that has no perfect solution: it is trying to determine the internal electrochemical state of a battery — a quantity that cannot be measured directly from the outside — from a stream of terminal measurements that are noisy, drift over time, and are related to the hidden state through a nonlinear function that itself changes as the battery ages. The 47% on your dashboard is not a reading from a gauge. It is the output of a recursive estimator, continuously reconciling accumulated charge counts against voltage observations, and it is only as good as the model, the sensors, and the algorithm behind it.

State estimation is where battery science meets control theory, and it is one of the most intellectually satisfying problems in the field precisely because it requires fluency in both. The physics from Chapters 1 through 9 defines what the system is. The algorithms in this chapter define how we learn about it from the outside.

We will build the treatment from the ground up. We start with the simplest possible estimator — integrating the measured current — and examine exactly how and why it fails. We then add voltage measurements through the OCV-SOC lookup approach, and examine the fundamental limitation imposed by the OCV curve's shape — the flat-curve problem that has appeared repeatedly in this book and that will occupy us at length for the SIB case. We then develop the modern solution: a parameterised equivalent circuit model (ECM) combined with a Kalman filter that fuses current and voltage information optimally. Finally, we extend the framework from state-of-charge estimation to state-of-health estimation and remaining useful life prediction.

By the end of this chapter, you will be able to describe the ECM + Kalman filter BMS architecture at the level of a practicing engineer: you will know the model structure, the estimator equations, the tuning procedure, and the failure modes. You will also understand precisely where and why this architecture struggles for sodium-ion batteries — and what algorithmic modifications have been proposed to address it.

---

> **Prerequisites Check**
>
> From your EE/math background:
> - Linear algebra: matrix multiplication, matrix inverse, covariance matrices — essential for Sections 10.3 and beyond
> - Probability and statistics: Gaussian distributions, variance, conditional probability — needed for the Kalman filter derivation
> - State-space representations of dynamic systems ($\dot{x} = Ax + Bu$, $y = Cx + Du$) — the ECM is described in this form
> - Recursive least squares or Wiener filter intuition — helpful but not required
>
> From Chapters 3–5:
> - OCV-SOC curves and their shapes (Chapter 3, Section 3.4; Chapter 5) — central to Section 10.2
> - DCIR and the three resistance components (Chapter 3, Section 3.5) — needed for ECM parameterisation
> - Coulombic efficiency and SOH definitions (Chapter 3, Sections 3.6, 3.7) — needed for Section 10.4
>
> From Chapter 6:
> - Hard carbon OCV flat plateau (Section 6.5) — the central motivation for Section 10.2's flat-curve analysis
>
> From Chapter 9:
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

where $\text{SOC}(k)$ is the estimated SOC at time step $k$, $i(k)$ is the measured current at time step $k$ (positive for discharge, negative for charge by the convention used here), $\Delta t$ is the sampling interval, $\eta_i$ is the Coulombic efficiency (approximately 1 for discharge, slightly less than 1 for charge to account for side-reaction losses), and $Q_\text{max}$ is the current maximum capacity of the battery in amp-hours.

If you have taken a circuits course, this should feel familiar. Coulomb counting is the battery equivalent of tracking the voltage on a capacitor by integrating its current: $V_C(t) = V_C(0) + \frac{1}{C}\int_0^t i(\tau)\,d\tau$. In that analogy, SOC plays the role of capacitor voltage, $Q_\text{max}$ plays the role of capacitance, and the current is the "flow" that changes the stored quantity. The discrete-time recursion in equation (10.1) is simply the rectangular approximation to that integral, updated at each time step. The difference is that a capacitor's voltage can be measured directly with a voltmeter, so you can always check the integral against a measurement. A battery's SOC *cannot* be measured directly — there is no "SOC meter" — and it is this fundamental unobservability that makes the drift problem so consequential.

This is conceptually straightforward. For a 3.0 Ah cell ($Q_\text{max} = 3.0$ Ah) starting at SOC = 80%, discharging at $i = 3.0$ A (1C) for 30 minutes ($\Delta t = 1800$ s), and assuming $\eta_i = 1$:

$$\text{SOC}(\text{after 30 min}) = 0.80 - \frac{1 \times 3.0 \times 1800/3600}{3.0} = 0.80 - \frac{1.5}{3.0} = 0.80 - 0.50 = 0.30$$

After 30 minutes at 1C, the SOC estimate is 30%. This is correct by construction — if the current was exactly 3.0 A, the initial SOC was exactly 80%, and the capacity is exactly 3.0 Ah, the estimate is exact.

The problem is that none of those three "exactlys" hold in practice. Each one is an approximation, and their combined errors accumulate over time in a way that makes the estimate increasingly unreliable.

### The Three Sources of Drift

**Source 1 — Current sensor error**: Every current sensor has a combination of gain error, offset error, and noise. The offset error is the most damaging for coulomb counting because it is systematic — a constant offset integrates linearly with time. For a Hall-effect sensor with a 50 mA offset error and a 3.0 Ah cell, the SOC error after one hour of continuous operation at any current is:

$$\Delta \text{SOC}_\text{offset} = \frac{I_\text{offset} \cdot t}{Q_\text{max}} = \frac{0.05 \times 3600}{3.0 \times 3600} = \frac{0.05}{3.0} \approx 1.7\% \, \text{SOC per hour}$$

After 8 hours of operation, a 50 mA offset accumulates a 13.5% SOC error — enough to be practically significant. Hall sensors can have offsets of 50–200 mA; precision shunt sensors have lower offsets (5–20 mA) but are not immune.

Gain error (proportional to the measured current) is functionally equivalent to having the wrong value of $Q_\text{max}$ in equation (10.1) — the BMS consistently over- or under-counts the fraction of capacity consumed. During a single discharge from 100% to 0%, a 0.5% gain error produces a 0.5% SOC error at the endpoint. However, for a *symmetric* gain error (same fractional error on both charge and discharge current), the error does not truly accumulate cycle over cycle: it resets when the SOC returns to the starting point. The accumulation becomes real when the gain error is asymmetric between charge and discharge directions (common with Hall-effect sensors, which can have direction-dependent offset and gain) or when the BMS's Coulombic efficiency factor $\eta_i$ is imperfect — in which case the small per-cycle residual error compounds over hundreds of cycles. In the worst case, a 0.5% asymmetric gain error on a cell cycled twice per day can grow to several percent SOC error per week without recalibration.

Random noise, by contrast, produces a random walk error that grows as $\sqrt{N}$ with the number of samples rather than linearly. For typical current sensor noise levels (10–30 mA RMS), the SOC error from noise alone after 3600 samples (one hour at 1-second intervals) is:

$$\Delta \text{SOC}_\text{noise} = \frac{\sigma_I \cdot \sqrt{N} \cdot \Delta t}{Q_\text{max} \times 3600} = \frac{0.02 \times \sqrt{3600} \times 1}{3.0 \times 3600} = \frac{0.02 \times 60}{10{,}800} \approx 1.11 \times 10^{-4} = 0.011\%$$

Noise error is negligible compared to offset or gain error — after one hour of 1-second sampling, the $\sqrt{N}$ random walk produces roughly 0.01% SOC error, two orders of magnitude smaller than the offset-induced 1.7% error. This confirms that offset error, not noise, is the dominant concern in coulomb counting.

**Source 2 — Incorrect $Q_\text{max}$**: The Coulombic efficiency $\eta_i$ and the maximum capacity $Q_\text{max}$ in equation (10.1) must be correct for the algorithm to work. Both change as the battery ages. If $Q_\text{max}$ has decreased from 3.0 Ah to 2.7 Ah due to degradation (SOH = 90%) but the BMS is still using the original 3.0 Ah value, every charge and discharge operation is miscounted by 10% — a systematic error that persists until $Q_\text{max}$ is recalibrated.

It is worth noting that $Q_\text{max}$ is not only a function of aging — it also depends on temperature and discharge rate. A cell rated at 3.0 Ah at 25°C and C/3 discharge may deliver only 2.7 Ah at −10°C (due to increased electrolyte resistance and slower diffusion) and 2.85 Ah at 2C (due to higher polarisation causing the cutoff voltage to be reached earlier, with usable capacity still trapped in the electrodes). A BMS that uses a fixed $Q_\text{max}$ without accounting for these operating-condition dependencies will exhibit systematic SOC errors that correlate with temperature and load — precisely the conditions where accurate SOC is most critical (cold starts, high-power acceleration events). Sophisticated BMS implementations maintain $Q_\text{max}$ as a lookup table indexed by temperature and average C-rate, updated periodically as the cell ages.

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

The quality of OCV-based SOC estimation depends fundamentally on the slope of the OCV curve $dE_\text{OCV}/d\text{SOC}$. Let us make this quantitative using a tool every EE has seen: first-order error propagation. If we measure the OCV with uncertainty $\sigma_V$ and then invert the OCV-SOC curve to get SOC, the uncertainty in the inferred SOC depends on how sensitive the inversion is to small voltage errors. For a locally linear OCV curve segment, $\Delta E_\text{OCV} \approx \frac{dE_\text{OCV}}{d\text{SOC}} \cdot \Delta \text{SOC}$, so $\Delta \text{SOC} \approx \Delta E_\text{OCV} / \frac{dE_\text{OCV}}{d\text{SOC}}$. Replacing the deltas with standard deviations:

$$\sigma_\text{SOC} = \frac{\sigma_V}{\left|\frac{dE_\text{OCV}}{d\text{SOC}}\right|} \tag{10.3}$$

This is the inverse-function version of the familiar result that if $y = f(x)$ and $f$ is locally linear, then $\sigma_x = \sigma_y / |f'(x)|$. A steep OCV curve (large $|dE_\text{OCV}/d\text{SOC}|$) compresses voltage errors into small SOC errors — the curve is acting like a high-gain amplifier in reverse. A flat OCV curve (small $|dE_\text{OCV}/d\text{SOC}|$) amplifies voltage errors into large SOC errors. In the limit of a perfectly flat plateau, $dE_\text{OCV}/d\text{SOC} = 0$ and equation (10.3) gives infinite SOC uncertainty — voltage provides literally no information about SOC.

For a practical NMC/graphite cell, $dE_\text{OCV}/d\text{SOC} \approx 50$–200 mV per unit SOC in the mid-SOC range. Here "per unit SOC" means per full SOC swing from 0 to 1 — so 100 mV per unit SOC corresponds to 1 mV per percentage point of SOC. Be aware that some references report slopes in mV/%SOC (a factor of 100 smaller); we use the unit-SOC convention throughout this chapter because it keeps the equations clean (SOC appears as a dimensionless number between 0 and 1 in all our formulas). With a voltage measurement uncertainty of $\sigma_V = 5$ mV (a realistic value for a well-calibrated cell voltage monitor with 16-bit resolution over a 4V range):

$$\sigma_\text{SOC,NMC} = \frac{0.005}{0.1} = 0.05 = 5\%$$

A 5% SOC uncertainty from OCV measurement alone is already not excellent, but it is useful as a correction term. Combined with coulomb counting, the fused estimate is better than either alone.

For LFP/graphite, the flat plateau region (spanning roughly 20–85% SOC) has $dE_\text{OCV}/d\text{SOC} \approx 2$–5 mV per unit SOC at best:

$$\sigma_\text{SOC,LFP} = \frac{0.005}{0.003} \approx 167\%$$

The OCV measurement is essentially useless for SOC estimation in the LFP plateau. Only at the top and bottom of the SOC range, where the curve steepens, does OCV become informative. For the majority of the LFP cell's operating range, a BMS must rely entirely on coulomb counting — with all the drift problems that implies.

### The SIB Hard Carbon Flat Plateau: A More Severe Version of the LFP Problem

For a sodium-ion cell with a hard carbon anode, the full-cell OCV during the plateau region of hard carbon sodiation (approximately 20–50% of the total cell capacity, as established in Chapter 6) is nearly constant. The full cell voltage in this region is approximately the cathode OCV (which itself may be relatively flat for some cathode chemistries) minus the nearly-zero anode potential — producing a doubly-flat region in the full cell OCV.

Let us apply equation (10.3) to a concrete SIB example. For a representative SIB cell with an O3 layered oxide cathode and hard carbon anode (similar to published HiNa or CATL first-generation cells), GITT data show the full-cell OCV varying by approximately 30–50 mV over the SOC range corresponding to the hard carbon plateau — spanning roughly 25–30% of total capacity. The average OCV slope in this region is:

$$\frac{dE_\text{OCV}}{d\text{SOC}} \approx \frac{40 \times 10^{-3}}{0.27} \approx 148 \, \text{mV per unit SOC}$$

At first glance, this seems acceptable — comparable to the mid-SOC slope of an NMC cell. So why does the flat-OCV problem plague SIBs more than NMC? The answer lies in the *shape* of the curve, not just its average slope. An NMC cell's OCV decreases monotonically and relatively smoothly across the full SOC range, providing continuous discrimination between adjacent SOC values. The SIB hard carbon plateau, by contrast, confines the total OCV variation to a band of only 30–50 mV absolute — meaning the *entire* SOC range from approximately 25% to 55% maps into a voltage window narrower than 50 mV. Within this window, the OCV is nearly constant and any structure is smaller than the voltage measurement uncertainty of a typical BMS (5–10 mV). The result is that the BMS cannot distinguish between 30% SOC and 50% SOC from voltage alone — both produce approximately the same OCV of 3.1–3.15 V — even though the average slope computed over the full plateau width is a finite number.

The critical distinction is between *average slope* (which equation (10.3) uses) and *local discriminability* (which determines whether the BMS can actually tell two nearby SOC values apart). In the plateau, the OCV curve may have a slight average tilt, but its local structure is below the noise floor of the voltage measurement. The 148 mV/unit SOC average slope is misleading because it assumes the full 40 mV range is usable — in practice, with $\sigma_V = 5\text{–}10$ mV, much of that range is indistinguishable from measurement noise.

The real challenge is the shape discontinuity. When transitioning between the slope region (large $dE/d\text{SOC}$) and the plateau region (small $dE/d\text{SOC}$), the OCV drops steeply and then flattens. A BMS observing the transition into the plateau from the slope region knows the cell has entered the plateau, but from that moment forward loses the ability to track progress through the plateau using voltage. The cell has essentially disappeared into a voltage dead zone that may last through 25–50% of its remaining capacity.

This is compounded by the **hysteresis** in the hard carbon OCV curve. The slope region and plateau region both exhibit hysteresis between charge and discharge (as discussed in Chapter 6) — the cell OCV at a given SOC during charging is noticeably different from the OCV at the same SOC during discharging. A BMS using a single OCV-SOC table without distinguishing charge from discharge direction introduces a systematic SOC error that can reach 5–10% in the hard carbon plateau region. For SIB BMS algorithms, maintaining separate OCV curves for charge and discharge, and tracking the recent current direction to select the appropriate curve, is necessary but not sufficient — the hysteresis itself is a continuous function of the most recent cycling history, not a simple two-state switch.

**The practical conclusion**: For SIB cells, OCV-based SOC correction is available and useful at the extremes of the SOC range (below ~15% and above ~85% SOC, where both the hard carbon slope region and the cathode OCV are changing significantly). Over the middle 70% of the SOC range — dominated by the hard carbon plateau — the BMS must rely almost entirely on coulomb counting. The consequences for algorithm design are significant and will be discussed further in Section 10.3 and in Chapter 13.

---

## 10.3 Model-Based Estimation: The ECM + Kalman Filter

The limitations of coulomb counting (drift without correction) and OCV lookup (works poorly on flat curves) motivate a more principled approach: a dynamic model that describes how the battery's terminal voltage responds to the current profile, combined with an optimal filter that continuously fuses the model prediction with the voltage measurement to correct the SOC estimate.

The dominant framework for this approach in commercial BMS applications is the **equivalent circuit model (ECM)** paired with an **extended Kalman filter (EKF)**. This pairing was systematised and popularised by Gregory Plett in a series of papers beginning in 2004 and subsequently in his textbook *Battery Management Systems* — the primary source recommended in the chapter plan.

### The Equivalent Circuit Model

An equivalent circuit model represents the battery's electrical behaviour using a circuit consisting of an ideal voltage source (the OCV), a series resistance (the ohmic resistance $R_0$), and one or more parallel RC networks (representing the dynamic polarisation response). The most commonly used form is the **second-order RC model** (also called the **two-RC model** or **Dual Polarization model**):

```
         R₀           R₁              R₂
  +----/\/\/----+----/\/\/----+----/\/\/----+
  |             |             |             |
  |            ═══ C₁        ═══ C₂         |
  |             |             |             |
 (+)            |             |            (+)
 OCV(SOC)       |             |         V_terminal
 (−)            |             |            (−)
  |             |             |             |
  +-------------+-------------+-------------+
                 ←── i(t) ───→
```

In this circuit, $E_\text{OCV}(\text{SOC})$ is the open-circuit voltage — a nonlinear function of SOC (the OCV-SOC curve from Chapter 3). The series element $R_0$ represents the **ohmic resistance**, producing an instantaneous voltage drop proportional to current. The first RC pair, $R_1$ and $C_1$, represents the fast activation polarisation with time constant $\tau_1 = R_1 C_1$, typically 1–30 seconds. The second RC pair, $R_2$ and $C_2$, represents the slower concentration (diffusion) polarisation with time constant $\tau_2 = R_2 C_2$, typically 30–600 seconds. The physical basis for mapping these circuit elements to electrochemical processes was established in Chapter 3, Section 3.5: $R_0$ corresponds to ionic resistance in the electrolyte and electronic resistance in the current collectors, the fast RC pair captures the charge-transfer kinetics at the electrode–electrolyte interface, and the slow RC pair captures solid-state diffusion within the electrode particles.

The terminal voltage predicted by this model is:

$$V_\text{terminal}(t) = E_\text{OCV}(\text{SOC}) - R_0 \cdot i(t) - V_{C_1}(t) - V_{C_2}(t) \tag{10.4}$$

where $V_{C_1}$ and $V_{C_2}$ are the voltages across the two capacitors, governed by:

$$\dot{V}_{C_1} = -\frac{V_{C_1}}{R_1 C_1} + \frac{i}{C_1} = -\frac{V_{C_1}}{\tau_1} + \frac{i}{C_1} \tag{10.5}$$

$$\dot{V}_{C_2} = -\frac{V_{C_2}}{R_2 C_2} + \frac{i}{C_2} = -\frac{V_{C_2}}{\tau_2} + \frac{i}{C_2} \tag{10.6}$$

These two differential equations describe the charge/discharge of the polarisation capacitors in response to the applied current. At steady state (constant current for $t \gg \tau_1, \tau_2$), $V_{C_j} = R_j \cdot i$, and the total steady-state voltage drop across the RC networks is $R_1 i + R_2 i$, consistent with the DC polarisation overpotential.

### The State-Space Formulation

To apply the Kalman filter, we need the ECM in discrete-time state-space form. Define the state vector:

$$\mathbf{x}(k) = \begin{bmatrix} \text{SOC}(k) \\ V_{C_1}(k) \\ V_{C_2}(k) \end{bmatrix} \tag{10.7}$$

The state transition equations must be converted from continuous-time to discrete-time. For the SOC equation, the integral is exact regardless of discretisation method (SOC changes linearly between samples if the current is held constant). For the RC equations, however, the choice of discretisation matters. Euler forward discretisation would give $V_{C_1}(k) = V_{C_1}(k-1) + \dot{V}_{C_1}(k-1) \cdot \Delta t = (1 - \Delta t/\tau_1)V_{C_1}(k-1) + (\Delta t / C_1)i(k-1)$, which is only accurate when $\Delta t \ll \tau_1$. If the sampling interval is comparable to the RC time constant (e.g., $\Delta t = 1$ s and $\tau_1 = 5$ s), Euler introduces significant error and can even become unstable (oscillatory with growing amplitude) when $\Delta t > 2\tau_1$. The better approach is the **exact zero-order hold (ZOH) discretisation**, which solves the first-order ODE exactly under the assumption that the input current is constant between samples. The result is:

$$\text{SOC}(k) = \text{SOC}(k-1) - \frac{\eta_i \cdot i(k-1) \cdot \Delta t}{Q_\text{max}} \tag{10.8}$$

$$V_{C_1}(k) = e^{-\Delta t/\tau_1} V_{C_1}(k-1) + R_1(1 - e^{-\Delta t/\tau_1}) i(k-1) \tag{10.9}$$

$$V_{C_2}(k) = e^{-\Delta t/\tau_2} V_{C_2}(k-1) + R_2(1 - e^{-\Delta t/\tau_2}) i(k-1) \tag{10.10}$$

The exponential factors $e^{-\Delta t/\tau_j}$ are the exact discrete-time equivalents of the continuous-time $e^{-t/\tau}$ decay — they preserve the RC dynamics perfectly at any sampling rate, with no discretisation error. This is the form used in all serious BMS implementations.

The output (measurement) equation is:

$$V_\text{terminal}(k) = E_\text{OCV}(\text{SOC}(k)) - R_0 \cdot i(k) - V_{C_1}(k) - V_{C_2}(k) + w(k) \tag{10.11}$$

where $w(k)$ is the **measurement noise** (voltage sensor noise).

In compact form, this is a nonlinear state-space system:

$$\mathbf{x}(k) = \mathbf{A}\mathbf{x}(k-1) + \mathbf{B}i(k-1) + \mathbf{q}(k-1) \tag{10.12}$$
$$y(k) = h(\mathbf{x}(k), i(k)) + w(k) \tag{10.13}$$

where $\mathbf{A}$ and $\mathbf{B}$ are the state transition and input matrices encoding equations (10.8)–(10.10), $h(\cdot)$ is the nonlinear measurement function in equation (10.11), $\mathbf{q}$ is the **process noise** (modelling uncertainty in the state equations, including current sensor error), and $w$ is the measurement noise.

The system is nonlinear because $E_\text{OCV}(\text{SOC})$ is a nonlinear function of SOC. This is what requires the **Extended** Kalman filter rather than the standard (linear) Kalman filter.

### The Extended Kalman Filter

The standard Kalman filter is an optimal recursive estimator for linear systems with Gaussian noise — if your state-space model has the form $\mathbf{x}(k) = \mathbf{A}\mathbf{x}(k-1) + \mathbf{B}\mathbf{u}(k-1) + \mathbf{q}$ and $\mathbf{y}(k) = \mathbf{C}\mathbf{x}(k) + \mathbf{w}$ with constant $\mathbf{A}$, $\mathbf{B}$, $\mathbf{C}$, the Kalman filter gives the minimum-variance estimate of $\mathbf{x}$, and you may have seen this result in a control theory or estimation course. Our ECM is *almost* in this form — the state transition (equations 10.8–10.10) is linear, and the system would be a standard Kalman filter problem if the output equation were also linear. But the output equation (10.11) contains $E_\text{OCV}(\text{SOC})$, a nonlinear function of the first state. The **Extended Kalman Filter (EKF)** handles this by performing a first-order Taylor expansion of the output function around the current best estimate of the state at each time step — effectively replacing the nonlinear $h(\mathbf{x})$ with a locally linear approximation $h(\hat{\mathbf{x}}) + \mathbf{C}(\mathbf{x} - \hat{\mathbf{x}})$, where $\mathbf{C}$ is the Jacobian $\partial h/\partial \mathbf{x}$ evaluated at $\hat{\mathbf{x}}$. This linearisation is recomputed at every time step as the estimate evolves, so the "C matrix" in the EKF is not constant — it changes with the SOC estimate.

The EKF proceeds in two alternating steps:

**Prediction step** (propagate the state forward using the model):

$$\hat{\mathbf{x}}^-(k) = \mathbf{A}\hat{\mathbf{x}}(k-1) + \mathbf{B}i(k-1) \tag{10.14}$$

$$\mathbf{P}^-(k) = \mathbf{A}\mathbf{P}(k-1)\mathbf{A}^T + \mathbf{Q} \tag{10.15}$$

where $\hat{\mathbf{x}}^-$ is the **a priori estimate** (before measurement) of the state, $\mathbf{P}^-$ is the a priori **error covariance matrix** (a $3 \times 3$ matrix for the two-RC model), and $\mathbf{Q}$ is the process noise covariance matrix (encoding our uncertainty in the state equations themselves).

**Update step** (correct the prediction using the new voltage measurement):

First, compute the linearised measurement matrix $\mathbf{C}(k)$ — the Jacobian of the measurement function $h$ with respect to the state, evaluated at the current estimate:

$$\mathbf{C}(k) = \frac{\partial h}{\partial \mathbf{x}}\bigg|_{\hat{\mathbf{x}}^-(k)} = \begin{bmatrix} \frac{dE_\text{OCV}}{d\text{SOC}}\bigg|_{\hat{\text{SOC}}^-} & -1 & -1 \end{bmatrix} \tag{10.16}$$

The first element of $\mathbf{C}$ is the slope of the OCV curve evaluated at the current SOC estimate — and this is exactly where the flat-OCV problem enters the Kalman filter. If $dE_\text{OCV}/d\text{SOC} \approx 0$, the measurement matrix has near-zero first element, meaning the voltage measurement carries almost no information about SOC. The filter correctly "ignores" the voltage for SOC correction in this region and relies on the prediction (coulomb counting) instead.

Then compute the **Kalman gain** $\mathbf{K}(k)$:

$$\mathbf{K}(k) = \mathbf{P}^-(k)\mathbf{C}^T(k)\left[\mathbf{C}(k)\mathbf{P}^-(k)\mathbf{C}^T(k) + R\right]^{-1} \tag{10.17}$$

where $R$ is the measurement noise variance (the variance of the voltage sensor noise $w$).

The Kalman gain $\mathbf{K}$ determines how much the state estimate should be corrected based on the measurement residual (the discrepancy between the measured voltage and the predicted voltage). It is the optimal trade-off between trusting the model prediction and trusting the measurement: when $\mathbf{P}^-$ is large (the state estimate is uncertain) relative to $R$ (the measurement noise), the gain is high and the measurement correction is large. When $\mathbf{P}^-$ is small (the estimate is confident) or $R$ is large (the sensor is noisy), the gain is low and the estimate barely moves.

Finally, update the state estimate and covariance:

$$\hat{\mathbf{x}}(k) = \hat{\mathbf{x}}^-(k) + \mathbf{K}(k)\left[y(k) - h(\hat{\mathbf{x}}^-(k), i(k))\right] \tag{10.18}$$

$$\mathbf{P}(k) = [\mathbf{I} - \mathbf{K}(k)\mathbf{C}(k)]\mathbf{P}^-(k) \tag{10.19}$$

Equation (10.19) is the computationally efficient form of the covariance update, but it is numerically sensitive: if $\mathbf{K}$ and $\mathbf{C}$ are not computed to full precision (as is common on fixed-point BMS microcontrollers), the product $[\mathbf{I} - \mathbf{K}\mathbf{C}]\mathbf{P}^-$ can lose symmetry or even become negative-definite, causing the filter to diverge. The **Joseph form** of the update guarantees a symmetric, positive-semi-definite result:

$$\mathbf{P}(k) = [\mathbf{I} - \mathbf{K}(k)\mathbf{C}(k)]\mathbf{P}^-(k)[\mathbf{I} - \mathbf{K}(k)\mathbf{C}(k)]^T + \mathbf{K}(k)R\mathbf{K}^T(k) \tag{10.19b}$$

If you implement an EKF on an embedded processor — particularly one with limited floating-point precision — use the Joseph form. It is algebraically equivalent to equation (10.19) when $\mathbf{K}$ is exactly the optimal Kalman gain, but is robust to rounding errors that would make the simplified form misbehave.

The term $y(k) - h(\hat{\mathbf{x}}^-(k), i(k))$ is the **innovation** — the difference between what was measured and what the model predicted. If the innovation is consistently non-zero in a systematic direction (always positive, always increasing), it signals that the model is biased — either the OCV curve is wrong, the resistance parameters are wrong, or the $Q_\text{max}$ is wrong. The innovation signal is a rich diagnostic tool for identifying model parameter errors.

### Intuition for the Kalman Filter

Let me offer the intuitive framing that makes the EKF feel natural rather than mechanical.

Think of the EKF as a person trying to navigate in a fog using two sources of information: a map and a compass. The map (the ECM state equations) says "if you were at position $x$ and walked in direction $\theta$ for time $t$, you should now be at position $x'$." The compass (the voltage measurement) says "your current direction to the lighthouse is $\phi$." Neither is perfectly reliable — the map might be slightly wrong (process noise), and the compass might jitter (measurement noise). The optimal navigator takes both pieces of information and forms a weighted average: if the map is more trustworthy at this moment, rely more on the prediction; if the compass is giving a clear signal and the map is uncertain, trust the compass more.

The Kalman gain $\mathbf{K}$ is precisely this trust weighting, computed optimally at each step. The error covariance $\mathbf{P}$ tracks how uncertain the current estimate is — a large diagonal element in $\mathbf{P}$ corresponding to SOC means the SOC estimate is uncertain, which increases the Kalman gain for SOC, which means the next voltage measurement will move the SOC estimate more aggressively.

The flat OCV curve (small $dE/d\text{SOC}$ in equation 10.16) is equivalent to a navigator in fog whose compass is giving nearly identical readings regardless of which direction the lighthouse is in — the compass is still measuring something, but the information about position is nearly zero. The EKF correctly concludes that the lighthouse measurement is nearly uninformative about position and relies more heavily on dead reckoning (the model). The SOC uncertainty $\mathbf{P}_{11}$ grows throughout the flat-curve region because no good correction mechanism is available.

If you have encountered weighted least squares in a signal processing or controls course, the Kalman filter is its recursive, time-evolving cousin: at each step, it forms a weighted combination of the model prediction and the new measurement, with weights inversely proportional to their respective uncertainties. The key difference from static weighted least squares is that the Kalman filter carries forward the uncertainty from the previous step (through $\mathbf{P}$), so the weights adapt as the estimate becomes more or less confident over time.

**Common misconception: "The Kalman filter is just a fancy low-pass filter."** It is tempting to think of the EKF as a filter in the signal-processing sense — something that smooths noisy voltage measurements to produce a cleaner SOC estimate. While the EKF does attenuate measurement noise, its deeper function is *information fusion*: it combines two qualitatively different sources of SOC information (model-predicted and measurement-derived) with optimal weighting. A low-pass filter cannot correct a systematic SOC drift from coulomb counting, because it has no model to generate a prediction against which to compare the measurement. The EKF can — and this correction ability, not noise smoothing, is its essential contribution to BMS. Understanding this distinction matters especially for the flat-OCV case: one might think that a "better filter" (higher order, wider bandwidth) should solve the problem, but no amount of filtering helps when the measurement itself carries no SOC information. The flat-OCV problem is a fundamental observability limitation, not a noise problem.

### ECM Parameter Identification

The ECM parameters — $R_0$, $R_1$, $C_1$, $R_2$, $C_2$ (or equivalently $R_1$, $\tau_1$, $R_2$, $\tau_2$), and the OCV-SOC curve — must be identified from experimental data. The standard approach is:

**OCV-SOC curve**: Measured by GITT (Chapter 3, Section 3.10) at multiple temperatures. The table $E_\text{OCV}$ vs. SOC is stored in BMS memory as a lookup table, typically sampled at 1% SOC intervals. A polynomial or spline fit allows interpolation and differentiation (to compute $dE_\text{OCV}/d\text{SOC}$ needed for the EKF linearisation).

**$R_0$**: Extracted from the instantaneous voltage drop at the onset of HPPC current pulses (Section 3.10). $R_0 = |\Delta V_\text{instant}| / I$.

**$R_1, \tau_1, R_2, \tau_2$**: Extracted from the voltage relaxation after HPPC pulses, fitting the exponential decay:

$$V(t) = V_\infty + A_1 e^{-t/\tau_1} + A_2 e^{-t/\tau_2} \tag{10.20}$$

where $A_j = R_j \cdot I$ and $V_\infty$ is the final rested OCV value.

All parameters are functions of SOC and temperature, so the identification is performed at multiple SOC setpoints (typically 10%, 20%, ..., 90%) and multiple temperatures (typically −20°C, 0°C, 10°C, 25°C, 40°C). The resulting parameter tables are stored in BMS memory and interpolated during runtime.

For a full ECM characterisation of a single cell chemistry, the experimental effort is substantial: GITT at 5 temperatures × 9 SOC points, plus HPPC at 5 temperatures × 9 SOC points, giving 90 individual measurements each requiring careful setup and analysis. This is the hidden cost of deploying a model-based BMS — the upfront characterisation work is significant.

### The EKF for SIBs: What Changes

The EKF framework applies identically to SIBs. The state vector is the same (SOC, $V_{C_1}$, $V_{C_2}$), the filter equations are the same, and the OCV-SOC curve is simply replaced with the SIB cell's OCV-SOC curve. The difference is in the performance of the filter during the flat OCV region.

As we showed in Section 10.2, when $dE_\text{OCV}/d\text{SOC} \approx 0$, the measurement matrix $\mathbf{C}$ has near-zero first element. The Kalman gain for SOC drops to near zero, and the SOC uncertainty $\mathbf{P}_{11}$ grows unboundedly during the plateau. Simulations of EKF performance on SIB cells with hard carbon anodes consistently show that SOC error grows during the plateau region and is only corrected when the cell exits the plateau into the slope region (at either end of the SOC range).

Several algorithmic modifications have been proposed in the research literature to improve EKF performance for flat-OCV batteries. The **sigma-point (unscented) Kalman filter (UKF)** more accurately propagates non-Gaussian uncertainty through the nonlinear OCV function, which can reduce divergence during the flat region compared to the EKF's linear approximation — but this is an incremental improvement, not a solution to the fundamental information deficit. The **particle filter**, a Monte Carlo-based estimator that represents the state distribution with a set of "particles" rather than a Gaussian approximation, can represent multimodal distributions — useful when the cell might be anywhere within a 30-point-wide plateau — but is computationally expensive for real-time BMS implementation on low-power microcontrollers. A more exotic approach uses **EIS-based current correction**: impedance spectroscopy at specific frequencies can infer SOC-dependent quantities beyond voltage, such as the Warburg component of impedance (which changes with solid-state diffusion coefficient and thus with sodium concentration in hard carbon), providing SOC-relevant information even in the plateau region. This is promising but requires EIS measurement hardware beyond what most commercial BMS systems include. The most pragmatic solution is a **dual-model framework** that runs separate state estimators for the slope and plateau regions, with transition logic to switch between them based on the observed OCV dynamics. The slope-region estimator uses the standard EKF with voltage correction; the plateau-region estimator relies entirely on a carefully calibrated coulomb counter with temperature and ageing corrections. This approach is the closest to what current commercial SIB BMS implementations use.

A practical note for the Coursera course: Plett's *Battery Management Systems* textbook and the accompanying Coursera specialisation emphasise the **sigma-point Kalman filter (SPKF)** — a specific variant of the UKF — as the preferred estimator over the EKF. The SPKF avoids the need to compute the Jacobian $\mathbf{C}$ analytically (which requires differentiating the OCV curve and can introduce errors if the OCV function is stored as a lookup table rather than a smooth polynomial). Instead, the SPKF evaluates the nonlinear measurement function at a small set of carefully chosen "sigma points" around the current estimate and reconstructs the output statistics from these evaluations. For BMS applications, the SPKF and EKF produce very similar results on well-parameterised models; the SPKF's advantage is implementation convenience (no Jacobian) and slightly better performance when the OCV curve has sharp features (like the transition from slope to plateau in hard carbon). We have presented the EKF here because its mathematical structure makes the role of $dE_\text{OCV}/d\text{SOC}$ in the Kalman gain explicit — which is essential for understanding the flat-OCV problem. When you encounter the SPKF in the Coursera course, know that the fundamental information-theoretic limitation (flat OCV → no voltage correction) is identical; it merely enters the algorithm through a different computational path.

The SOC estimation challenge for SIBs is one of the most practically important open problems in SIB systems engineering, and it is a legitimate target for EE-focused simulation research. We will return to it in Chapter 13.

### SOC Estimation Methods at a Glance

The following table summarises the three SOC estimation approaches we have developed, highlighting their strengths, weaknesses, and the specific failure mode each exhibits on flat-OCV cells (LFP and SIB hard carbon).

| Property | Coulomb Counting | OCV Lookup | ECM + EKF |
|---|---|---|---|
| Input required | Current measurement | Voltage at rest | Current + voltage (continuous) |
| Gives absolute SOC? | No (relative only) | Yes | Yes (after convergence) |
| Drift over time | Yes — offset error grows linearly | No drift (each lookup is independent) | Bounded by voltage correction |
| Rest period required? | No | Yes (minutes to hours) | No |
| Flat-OCV impact | None (method ignores voltage) | Catastrophic — SOC unobservable | Degrades to coulomb counting in flat region; SOC uncertainty grows |
| Computational cost | Trivial | Trivial (table lookup) | Moderate (matrix operations at each time step) |
| Model required? | Only $Q_\text{max}$ and $\eta_i$ | OCV-SOC table | Full ECM + OCV table + noise parameters |
| Best use case | Short-term tracking between corrections | Recalibration anchor at rest | Continuous online estimation |

---

## 10.4 SOH Estimation: Capacity-Based and Resistance-Based

SOC estimation tells you where the battery is right now. **State-of-health (SOH) estimation** tells you how the battery has changed from its original specification — the long-term degradation state that determines remaining useful life and future performance limits.

SOH estimation is harder than SOC estimation for a fundamental reason: SOC changes on the timescale of minutes to hours (a single charge/discharge cycle), while SOH changes on the timescale of months to years (hundreds to thousands of cycles). This temporal separation means that SOH cannot be estimated from a single measurement event — it must be tracked over many cycles.

As defined in Chapter 3, there are two primary SOH metrics:

$$\text{SOH}_Q = \frac{Q_\text{max}(t)}{Q_\text{rated}} \times 100\% \quad \text{(capacity-based)} \tag{10.21}$$

$$\text{SOH}_R = \frac{R_0(t=0)}{R_0(t)} \times 100\% \quad \text{(resistance-based)} \tag{10.22}$$

Note that the convention for resistance-based SOH varies across manufacturers and publications. Some define SOH$_R$ using the ratio above (which is unbounded below as $R_0$ grows), while others define it as $\text{SOH}_R = (R_\text{EOL} - R_0(t))/(R_\text{EOL} - R_0(0))$ which is bounded between 0% and 100% by construction. We use the ratio definition because it requires no assumption about the end-of-life resistance value — but be prepared to encounter both conventions in the literature.

Both must be estimated because they track different degradation modes (as we established in Chapter 7): LLI primarily drives capacity fade, while impedance growth (from SEI growth and particle cracking) drives resistance rise. A cell can have high SOH$_Q$ and low SOH$_R$ (or vice versa), and the correct operational response differs.

### Capacity-Based SOH Estimation

The maximum capacity $Q_\text{max}$ can be measured directly by performing a slow full charge-discharge cycle at C/20 and integrating the current. This gives the most accurate value but requires a full charge-discharge sequence — not always practical during normal operation.

For online SOH estimation (without dedicated reference tests), the BMS must estimate $Q_\text{max}$ from partial charge and discharge data seen during normal operation. Three approaches are common, in increasing order of sophistication.

The simplest is **direct integration between known reference points**. If the BMS observes the battery go from a rest-state OCV reading of $V_1$ (corresponding to $\text{SOC}_1$ from the OCV curve) to rest-state OCV reading of $V_2$ (corresponding to $\text{SOC}_2$), with total coulombs $\Delta Q$ flowing between the two rest events:

$$Q_\text{max} = \frac{\Delta Q}{\text{SOC}_2 - \text{SOC}_1} \cdot \frac{1}{\eta_i} \tag{10.23}$$

This is accurate when the two OCV reference points are well separated in SOC (otherwise the denominator is small and the estimate is noisy), and when the OCV measurements are accurate — the flat-OCV problem applies here too, since if both reference points are in the plateau region, the denominator $\text{SOC}_2 - \text{SOC}_1$ cannot be determined from OCV alone.

A more powerful approach is **adaptive integration via EKF**. If $Q_\text{max}$ is included as an additional state variable in the EKF (turning the 3-state SOC estimator into a 4-state joint SOC/capacity estimator), the filter can update the capacity estimate online as new current-voltage data accumulates. The process noise for the $Q_\text{max}$ state is set to a very small value (capacity changes slowly), while the capacity update is driven by the accumulated innovation between measured and predicted voltage. This "adaptive EKF" or "joint EKF" approach is the state of the art for online capacity tracking.

Finally, **incremental capacity analysis (ICA)** — introduced as a characterisation tool in Chapter 3, Section 3.10, and connected to degradation diagnostics in Chapter 7 — provides both capacity estimation and degradation mode identification from the $dQ/dV$ curve. The area under specific ICA peaks corresponds to specific portions of capacity, and as capacity fades, the peak areas decrease proportionally. An online ICA algorithm that tracks peak areas over cycles is a rich but computationally demanding approach.

### Resistance-Based SOH Estimation

The ohmic resistance $R_0$ and the charge-transfer resistance $R_\text{ct}$ can be estimated from HPPC-style current pulses that occur naturally in a normal operating cycle. Every time the current changes significantly (an acceleration event in an EV, a step change in grid power demand), a short pulse is effectively applied to the battery and the voltage response can be used to extract impedance information.

For real-time $R_0$ estimation:

$$\hat{R}_0(k) = \frac{|V(k^+) - V(k^-)|}{\Delta I} \tag{10.24}$$

where $V(k^+)$ is the voltage immediately after a current step of magnitude $\Delta I$ at time $k$, and $V(k^-)$ is the voltage immediately before. This is the instantaneous ohmic resistance extracted from the voltage jump at current steps — a technique that works whenever the current changes abruptly, which happens constantly during real drive cycles or variable-power grid operation.

The estimated $R_0$ sequence is noisy at any single event but can be filtered with a recursive least squares (RLS) or EKF estimator to produce a slowly-evolving estimate that tracks the true $R_0$ through aging. The increase in estimated $R_0$ over the pack's life is a direct measure of resistance-based SOH degradation.

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

which can be extrapolated forward in time given the current temperature and SOC profile.

To ground this in numbers, consider a commercial NMC/graphite cell with $Q_\text{rated} = 3.0$ Ah stored at 25°C and 50% SOC. Published calendar-aging fits for NMC cells typically express the capacity loss as $\Delta Q = A \exp(-E_a/RT) \cdot \sqrt{t}$, where $A$ and $E_a$ are fitted parameters. Using representative values from the literature ($A \approx 2.5 \times 10^4 \, \text{Ah} \cdot \text{s}^{-1/2}$, $E_a \approx 50 \, \text{kJ/mol}$), the capacity loss after one year ($t = 3.15 \times 10^7$ s) at 25°C is:

$$\Delta Q = 2.5 \times 10^4 \times \exp\left(\frac{-50{,}000}{8.314 \times 298}\right) \times \sqrt{3.15 \times 10^7}$$

The Arrhenius factor: $\exp(-50{,}000/2478) = \exp(-20.2) \approx 1.7 \times 10^{-9}$. And $\sqrt{3.15 \times 10^7} \approx 5612$. So $\Delta Q \approx 2.5 \times 10^4 \times 1.7 \times 10^{-9} \times 5612 \approx 0.24$ Ah, giving $Q_\text{max} = 3.0 - 0.24 = 2.76$ Ah, or about 8% capacity loss per year at 25°C. At 45°C, the Arrhenius factor increases by roughly $10\times$ (compute $\exp(-50{,}000/(8.314 \times 318))$), accelerating calendar aging dramatically — consistent with the thermal sensitivity established in Chapter 8.

The $\sqrt{t}$ dependence is physically important: it means calendar aging *decelerates* over time. A cell does not lose the same capacity in its second year as in its first. This is because the dominant calendar-aging mechanism (SEI growth) is diffusion-limited — the SEI must grow thicker to continue consuming lithium inventory, and diffusion through a thicker layer is slower.

For cycle aging:

$$Q_\text{max}(N) = Q_\text{rated} - C \cdot N^z \cdot f(\text{DOD}) \cdot g(T) \tag{10.27}$$

where $N$ is the number of equivalent full cycles and the functions $f$, $g$ encode the DOD and temperature stressors as established in Chapter 7. By fitting these models to the historical SOH trajectory and projecting forward under an assumed future operating profile, the BMS can produce a distribution of RUL estimates rather than a single point estimate.

### Probabilistic RUL and Confidence Intervals

Deterministic RUL prediction is useful but misleading — it implies a precision that does not exist. All degradation models have parameter uncertainty, the future operating profile is unknown, and there are stochastic elements in the degradation process itself (random particle cracking events, variable ambient temperature). A more honest representation gives a probability distribution over remaining useful life rather than a single number.

The standard tools for probabilistic RUL estimation are **Bayesian approaches** (which update a prior distribution over degradation model parameters as new data accumulates) and **particle filters** (a Monte Carlo method well-suited to non-Gaussian distributions and nonlinear degradation models). Both produce a posterior distribution over SOH at each future time point, from which percentile RUL estimates (e.g., "80% probability that RUL > 200 cycles") can be extracted.

This probabilistic framing is particularly important for fleet management. Rather than asking "when will this cell reach EOL?", the fleet manager asks "what is the probability that this cell survives to the next scheduled maintenance interval?" This probability can be computed from the RUL distribution and used to schedule predictive maintenance — replacing cells before they fail rather than after, at minimum total cost.

### Data-Driven RUL: Machine Learning Approaches

The alternatives to physics-based RUL prediction are data-driven approaches — machine learning models trained on large datasets of battery aging cycles. The most successful approaches include:

**Gaussian process regression (GPR)**: A non-parametric Bayesian method that fits a flexible curve to the capacity-fade history and extrapolates forward with explicit uncertainty quantification. GPR naturally provides confidence intervals on the RUL estimate and can capture non-standard degradation trajectories (early knees, temporary recoveries during rest periods) that parametric models cannot.

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

**Step 1 — Update** (the true cell is at SOC $\approx 0.6999$, so the true terminal voltage is $E_\text{OCV}(0.70) - R_0 \cdot 1.5 - V_{C_1,\text{true}} = 3.840 - 0.060 - 0.001 = 3.779$ V; we assume the measured voltage includes a small amount of sensor noise, giving $y(1) = 3.780$ V):

Linearised measurement matrix (slope of OCV at estimated SOC = 0.5999):
$$C(1) = \begin{bmatrix} \frac{dE_\text{OCV}}{d\text{SOC}}\bigg|_{0.60} & -1 \end{bmatrix} = \begin{bmatrix} 1.2 & -1 \end{bmatrix}$$

Predicted output:
$$\hat{y}^-(1) = E_\text{OCV}(0.5999) - R_0 \cdot 1.5 - V_{C_1}^-(1) = (3.0 + 1.2 \times 0.5999) - 0.040 \times 1.5 - 9.84 \times 10^{-4}$$
$$= 3.7199 - 0.0600 - 0.00098 = 3.659 \text{ V}$$

Innovation: $3.780 - 3.659 = 0.121$ V. This substantial innovation reflects the 10% initial SOC error — the model predicts a voltage consistent with 60% SOC, but the true cell (at 70% SOC) produces a voltage roughly 120 mV higher. The innovation is large compared to the measurement noise ($\sigma_V = 5$ mV), so the Kalman filter will apply a strong correction toward the true SOC.

Kalman gain: $K = P^- C^T / (C P^- C^T + R)$ — at this point the $P^-_{11} = 0.01$ is much larger than $R/C_{11}^2 = 2.5 \times 10^{-5}/1.44 \approx 1.7 \times 10^{-5}$, so the gain is high — the filter trusts the measurement correction.

The state update pushes the SOC estimate significantly toward its true value of 70%. Over approximately 10–30 time steps (10–30 seconds of operation), the EKF converges: the SOC error shrinks from 10% to well below 2%, and the error covariance $\mathbf{P}_{11}$ shrinks to a small value reflecting the converged estimate.

This convergence — the ability to correct a large initial SOC error within seconds to minutes of operation using only terminal current and voltage measurements — is the most important practical property of the EKF-based BMS. It means the BMS does not need to start from a precisely known SOC (which would require a full charge to a reference state); it can self-correct from any reasonable initial estimate.

**What changes in the plateau region**: If this same cell were an SIB with a flat OCV curve, the $C_{11}$ element in the measurement matrix would be small (say, 0.04 instead of 1.2). The Kalman gain for SOC would drop by a factor of 30, and the convergence time would lengthen from 10–30 seconds to 300–900 seconds. With typical SIB operating profiles (rest periods of minutes, not hours), the EKF may never fully converge during the plateau region, and the 10% initial error persists through the plateau — exactly the SIB-specific challenge we identified in Section 10.2.

---

## What Changes for Sodium-Ion?

The state estimation architecture — ECM + EKF, with SOH tracking via adaptive parameters and RUL projection from degradation models — applies directly to SIBs. The algorithms are the same; the parameters and performance differ.

**The flat OCV problem (Sections 10.2 and 10.3)**: This is the central challenge. The EKF Kalman gain for SOC drops near zero during the hard carbon plateau, causing SOC uncertainty to grow. All proposed solutions (UKF, particle filter, EIS-based correction, dual-model frameworks) are active research topics. For a simulation researcher, this is a concrete and tractable problem: implementing an EKF on a simulated SIB cell model and demonstrating the SOC uncertainty growth in the plateau region — and then proposing and evaluating a modification — is a publishable contribution.

**Higher $R_0$ and $R_\text{ct}$**: The ECM parameters for SIB cells are larger than for comparable LIB cells (as established in Chapter 6, Section 6.5, where we discussed the higher internal resistance arising from larger Na$^+$ ionic radius and lower ionic conductivity). This means the voltage excursions during current pulses are larger, which actually helps current-step-based $R_0$ estimation (larger signal-to-noise ratio for the impedance estimate). It is, unexpectedly, one area where the SIB's high internal resistance is an advantage for BMS estimation.

**SOH and capacity tracking**: The lower ICE of hard carbon (typically 70–88%, depending on precursor, pyrolysis conditions, and electrolyte formulation) and the possibility of more volatile per-cycle LLI (from less stable SEI) mean that capacity tracking algorithms may need higher process noise on the $Q_\text{max}$ state and more frequent OCV recalibration events to maintain accuracy. The degradation rate parameters for SIBs are not yet as well characterised as for LIBs, which means that physics-based degradation models (for RUL) have higher parameter uncertainty for SIBs in the near term.

**Hysteresis in the OCV curve**: Hard carbon exhibits stronger OCV hysteresis than graphite — the charge and discharge OCV curves differ by 50–100 mV in the slope region and somewhat less in the plateau. Standard EKF implementations use a single OCV curve; BMS algorithms for SIBs must account for hysteresis either through separate charge/discharge OCV tables (with logic to select the appropriate one based on recent current direction) or through a hysteresis state variable added to the state vector. Plett's group has published a hysteresis model for LFP cells (which also exhibit significant OCV hysteresis) that can be adapted for SIB hard carbon anodes; this represents another research opportunity.

---

## Chapter Summary

**Key ideas:**

- Coulomb counting integrates current to track SOC but drifts due to sensor offset error (linear in time), sensor gain error (proportional to charge throughput), incorrect $Q_\text{max}$, and unknown initial SOC. Offset errors of 50–200 mA produce SOC errors of 1–7% per hour; asymmetric gain errors compound over cycles.
- OCV-based SOC lookup provides absolute reference points but requires sufficient rest time for voltage relaxation and a steep OCV curve. SOC uncertainty from voltage measurement $\sigma_V$ is $\sigma_\text{SOC} = \sigma_V / |dE/d\text{SOC}|$. On flat OCV curves (LFP, SIB hard carbon plateau), $|dE/d\text{SOC}| \approx 0$ and OCV provides negligible information about SOC — the fundamental SIB estimation challenge.
- The ECM (OCV source + $R_0$ + RC network) is the standard model for BMS estimation. The two-RC model captures ohmic, activation, and diffusion dynamics with parameters identified from HPPC and GITT data, tabulated as functions of SOC and temperature.
- The Extended Kalman Filter fuses current integration (model prediction) with voltage measurement (update step) optimally. The Kalman gain $\mathbf{K}$ balances trust between model and measurement. The OCV slope $dE/d\text{SOC}$ appears in the linearised measurement matrix; when the slope is near zero (flat OCV region), the gain drops to zero and the voltage provides no SOC correction — the filter degrades to pure coulomb counting with growing uncertainty.
- SOH is estimated online via: capacity tracking using partial charge integrals between OCV reference points, adaptive EKF with $Q_\text{max}$ as an additional state, or ICA peak area tracking. Resistance-based SOH tracks $R_0$ from step-current voltage jumps using RLS or EKF filtering.
- RUL prediction extrapolates the SOH trajectory forward using physics-based degradation models (calendar: $\sqrt{t}$ Arrhenius; cycle: power-law in cycle count, DOD, temperature) or data-driven models (GPR, LSTM). Probabilistic RUL gives a distribution rather than a point estimate, enabling cost-optimal predictive maintenance.

**Key equations:**

$$\text{SOC}(k) = \text{SOC}(k-1) - \frac{\eta_i i(k) \Delta t}{Q_\text{max}} \quad \text{(coulomb counting)} \tag{10.1}$$

$$\sigma_\text{SOC} = \frac{\sigma_V}{|dE_\text{OCV}/d\text{SOC}|} \quad \text{(OCV-based SOC uncertainty)} \tag{10.3}$$

$$V_\text{terminal} = E_\text{OCV}(\text{SOC}) - R_0 i - V_{C_1} - V_{C_2} \quad \text{(ECM output equation)} \tag{10.4}$$

$$C_{11} = \frac{dE_\text{OCV}}{d\text{SOC}} \quad \text{(OCV slope drives SOC correction in EKF)} \tag{10.16}$$

$$\mathbf{K}(k) = \mathbf{P}^-\mathbf{C}^T[\mathbf{C}\mathbf{P}^-\mathbf{C}^T + R]^{-1} \quad \text{(Kalman gain)} \tag{10.17}$$

$$\hat{\mathbf{x}}(k) = \hat{\mathbf{x}}^-(k) + \mathbf{K}(k)[y(k) - h(\hat{\mathbf{x}}^-(k), i(k))] \quad \text{(EKF update)} \tag{10.18}$$

**Key vocabulary (in order of appearance):**

Coulomb counting, current integration, ampere-hour integration, sensor offset error, sensor gain error, initial SOC uncertainty, OCV-SOC lookup, OCV curve sensitivity, rest time relaxation, flat OCV problem, equivalent circuit model (ECM), one-RC / two-RC model, ohmic resistance $R_0$, RC time constant, zero-order hold discretisation, state-space formulation, state vector, state transition matrix, process noise, measurement noise, extended Kalman filter (EKF), prediction step, update step, a priori estimate, error covariance matrix $\mathbf{P}$, process noise $\mathbf{Q}$, measurement noise $R$, measurement matrix $\mathbf{C}$, Kalman gain $\mathbf{K}$, innovation, Joseph form, sigma-point Kalman filter (SPKF), adaptive EKF, SOH estimation, capacity tracking, resistance tracking, recursive least squares (RLS), SOH map, degradation trajectory, remaining useful life (RUL), physics-based RUL, data-driven RUL, Gaussian process regression, LSTM, OCV hysteresis state, dual-model framework, particle filter.

---

## Deliverable

The primary deliverable for this part of the book (Chapters 9–12) is completing Plett's Coursera specialisation "Algorithms for Battery Management Systems," Courses 1 and 2. This chapter is the direct preparation for that work.

Before starting Course 2 (which covers the SPKF/EKF algorithms), ensure you can answer the following from this chapter without looking up the answers:

Write the discrete-time state equations for the one-RC ECM (equations 10.8 and 10.9). What is the physical meaning of the time constant $\tau_1$? Why is the exponential form ($e^{-\Delta t/\tau}$) used instead of the Euler approximation? (Answer: the exponential form is the exact zero-order-hold solution for a first-order ODE; Euler integration introduces error proportional to $\Delta t/\tau$ which can be significant if $\Delta t$ is not much smaller than $\tau_1$.)

Write the EKF Kalman gain equation. Explain in words why the first element of the measurement matrix $\mathbf{C}$ is $dE_\text{OCV}/d\text{SOC}$ rather than, say, the full $E_\text{OCV}$ value. (Answer: because the gain equation uses the linearised system model — it needs how much the voltage changes for a small change in SOC, which is the derivative of the output with respect to the state, evaluated at the current estimate.)

For an LFP/graphite cell at 50% SOC (in the flat plateau, $dE/d\text{SOC} = 3$ mV per unit SOC) with $\sigma_V = 5$ mV and $P_{11} = 0.04$, compute the Kalman gain for SOC (the $(1,1)$ element of $\mathbf{K}$). Compare to the same cell at 10% SOC where $dE/d\text{SOC} = 80$ mV per unit SOC. Interpret the difference.

---

## Further Reading

1. **Plett, G. L., "Extended Kalman filtering for battery management systems of LiPB-based HEV battery packs. Parts 1, 2, and 3," *Journal of Power Sources* 134 (2), 252–292 (2004).** The three-part paper that established the ECM + EKF framework for BMS estimation. Part 1 covers the dynamic models; Part 2 the parameter identification; Part 3 the filter implementation and validation. This is the foundational reference for the entire field of model-based BMS estimation. Read all three parts.

2. **Plett, G. L., *Battery Management Systems, Vol. 2: Equivalent-Circuit Methods*, Artech House (2015).** The comprehensive textbook treatment of everything in this chapter, with full MATLAB code examples and worked problems. Chapters 4–6 on the EKF, sigma-point Kalman filter (SPKF), and adaptive estimation are the direct reading for this chapter's material. This is the primary Plett reference for the BMS Coursera course.

3. **Hu, X., Li, S., and Peng, H., "A comparative study of equivalent circuit models for Li-ion batteries," *Journal of Power Sources* 198, 359–367 (2012).** A systematic comparison of one-RC, two-RC, and more complex ECM structures against experimental data, showing the accuracy–complexity trade-off. Essential for understanding which model order is sufficient for a given application.

4. **Severson, K. A. et al., "Data-driven prediction of battery cycle life before capacity degradation," *Nature Energy* 4, 383–391 (2019).** The influential paper showing that early-cycle charge-voltage curve features predict long-term cycle life with high accuracy. Read this for the data-driven RUL perspective and to understand what battery degradation information is encoded in early-life data.

5. **Zheng, Y. et al., "State of charge estimation for lithium battery systems using an adaptive extended Kalman filter considering temperature dependence," *IEEE Transactions on Control Systems Technology* 22 (2), 589–600 (2014).** A careful treatment of temperature-dependent ECM parameterisation and adaptive EKF implementation, including a discussion of how parameter uncertainty propagates into SOC estimation error. The most practically useful reference for implementing the temperature-dependent ECM tabulation described in Section 10.3.

---

*Next chapter: **Chapter 11 — Cell Balancing.** We examine why cells drift apart in a series string, the consequences of imbalance, and the two main balancing architectures — passive (resistive bleed) and active — along with the control strategies that govern when and how much to balance. Prompt me with "write Chapter 11" to continue.*

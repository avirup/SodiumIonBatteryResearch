# Chapter 8: Heat in Batteries

## Chapter Opening

Of all the ways a battery can fail, thermal failure is the most spectacular and the most feared. A lithium-ion cell in thermal runaway is not simply a dead battery — it is a self-sustaining exothermic reaction that can reach temperatures above 700°C, eject flaming electrolyte, and, in a pack environment, propagate from cell to cell in a cascade that is extremely difficult to arrest. The Boeing 787 grounding in 2013, the Samsung Galaxy Note 7 recall in 2016, the recurring fires in electric vehicle battery packs — all of these trace, at some level, to the thermal physics we are going to study in this chapter.

But thermal management in batteries is not only about preventing catastrophic events. Even under normal operating conditions, heat generation affects every performance metric we care about. Heat accelerates all the degradation mechanisms from Chapter 7. Temperature gradients within a cell cause non-uniform aging. Excess heat at high C-rate discharge reduces the available power (the terminal voltage sags further). Insufficient heat at low temperatures reduces rate capability and can trigger lithium plating. The thermal behaviour of a cell under its expected duty cycle is as important an engineering specification as its energy density or cycle life.

This chapter builds the quantitative framework for battery thermal analysis. We begin with the physics of heat generation — deriving the Bernardi equation from first principles, separating the irreversible and reversible contributions, and calculating real numbers for a commercial cell. We then examine how heat leaves a cell, introducing the thermal resistance network that governs temperature rise. We discuss the safe operating temperature window and the mechanisms that define its boundaries. We derive the conditions for thermal runaway from a stability analysis perspective, using an approach that will feel familiar from control theory. And we close with a quantitative comparison of SIB and LIB thermal safety — not the qualitative "SIB is safer" claim you will hear repeatedly, but a physical accounting of why it is safer and by how much.

By the end of this chapter, you will be able to take a cell datasheet, a duty cycle specification, and a cooling system design, and determine whether the cell will overheat, by how much, and where in the duty cycle the thermal limit is first reached. That is an engineering capability, not just physical understanding. In Chapter 9, we will scale this analysis from a single cell to a battery pack, where cell-to-cell variation and module-level thermal coupling introduce new challenges — but the single-cell thermal model you build here is the foundation for everything that follows.

---

> **Prerequisites Check**
>
> From your EE background:
>
> - Thermal resistance networks (analogous to electrical resistance networks — if you can calculate voltage across a resistor divider, you can calculate temperature rise in a thermal network)
> - Basic control system stability concepts (Section 8.5 uses a stability argument; familiarity with positive/negative feedback will help)
> - Power dissipation calculations ($P = I^2 R$, $P = IV$)
>
> From Chapter 1:
>
> - The Gibbs free energy–voltage relationship $\Delta G = -nFE$ (Section 1.8)
> - The temperature coefficient of cell voltage $(\partial E_\text{OCV}/\partial T)_P = \Delta S/(nF)$ (Section 1.8) — central to Section 8.2
>
> From Chapters 2 and 3:
>
> - The three overpotentials: ohmic, activation, concentration (Chapter 2, Section 2.7)
> - Internal resistance: ohmic and charge-transfer components (Chapter 3, Section 3.5)
>
> From Chapter 7:
>
> - The Arrhenius temperature dependence of degradation rates (Section 7.2) — directly relevant to Section 8.6
> - Thermal runaway as an endpoint of degradation (Section 7.3)

---

## 8.1 Sources of Heat Generation: Ohmic, Polarisation, and Entropic

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

## 8.2 The Bernardi Equation for Heat Generation

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

## 8.3 Heat Transfer Out of a Cell: Thermal Resistance and Time Constants

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

## 8.4 Safe Operating Windows and Why They Exist

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

## 8.5 Thermal Runaway: Triggers, Stages, and Propagation

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

## 8.6 Why Low Temperature Hurts Performance and High Temperature Accelerates Aging

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

## 8.7 Why SIB Is Safer Than LIB — A Quantitative Accounting

The statement "sodium-ion batteries are safer than lithium-ion batteries" appears in almost every SIB review paper and press release, but it is rarely made quantitative. Let us do the quantitative accounting here.

### Cathode Oxygen Release: The Primary Difference

The dominant heat source in a lithium-ion thermal runaway event is the exothermic reaction between oxygen released from the delithiated cathode and the flammable organic electrolyte. As noted in Section 8.4, the onset temperature for oxygen release varies dramatically by cathode chemistry. The following table summarises oxygen release onset temperatures for the major cathode families:

| Chemistry Family | Type | Oxygen Release Onset (°C) | Notes |
| --- | --- | --- | --- |
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
| --- | --- | --- | --- |
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

---

*Next chapter: **Chapter 9 — Pack Architecture.** We ascend from the single cell to the battery pack: series and parallel configurations, nomenclature, cell-to-cell variation, contactors and precharge circuits, current sensing, and CAN bus communication basics. Prompt me with "write Chapter 9" to continue.*

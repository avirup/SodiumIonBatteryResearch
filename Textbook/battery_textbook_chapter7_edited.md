# Chapter 7: Degradation Mechanisms

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

## 7.1 The Three Degradation Modes: A Unifying Framework

The degradation literature contains dozens of named mechanisms. This abundance can be overwhelming. The key to navigating it is a hierarchical classification that separates *how a cell fails* (the mode) from *why it fails* (the mechanism). Birkl, Roberts, McTurk, Bruce, and Howey's 2017 paper systematised the **capacity-fade** side of this picture using LLI, LAMpe, and LAMne. In this chapter we extend that diagnostic language slightly by treating **conductivity loss (CL)** as a third engineering axis, because resistance rise matters just as much as capacity fade in real cells.

At the practical engineering level used in this chapter, there are three top-level degradation modes. Every mechanism we will discuss — SEI growth, lithium plating, particle cracking, transition metal dissolution, electrolyte decomposition — feeds into one or more of these three modes.

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

## 7.2 SEI Growth — The Dominant Calendar Aging Mechanism

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
which is the parabolic growth law in its cleanest form. Writing this with the initial offset restored gives equation (7.1):

$$L_\text{SEI}(t) = \sqrt{L_0^2 + k_\text{SEI}\, t} \tag{7.1}$$

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

## 7.3 Lithium and Sodium Plating — When and Why

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

## 7.4 Particle Cracking and Mechanical Fatigue

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

## 7.5 Transition Metal Dissolution and Crosstalk

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

## 7.6 Electrolyte Decomposition and Gas Generation

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

## 7.7 Calendar Aging vs. Cycle Aging — Different Physics, Different Models

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

## 7.8 Stressors: Temperature, SOC, DOD, C-Rate, Voltage Limits

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

**Section 2 of Birkl et al. — the capacity-fade modes**: The paper focuses on three capacity-fade modes: LLI, LAMpe, and LAMne. That is slightly narrower than the framework used in this chapter, where we add conductivity loss as a separate engineering axis because power fade matters operationally even when low-rate capacity is preserved. Birkl are explicit about what "loss of active material" means: it is not loss of the physical material from the cell but loss of its electrochemical participation — isolation from the electronic or ionic pathway.

**Section 3 — Half-cell model and simulated signatures**: This is the most valuable methodological section for your research. Birkl et al. use a half-cell model: they represent the full cell OCV as the superposition of the cathode OCV curve and the anode OCV curve, parameterised by the electrode stoichiometric windows. By mathematically shifting these windows to simulate LLI, LAMpe, and LAMne, they show how each mode distorts the full-cell OCV curve and $dQ/dV$ curve in a distinct and identifiable way.

The signatures are:

*LLI*: The capacity window of the full cell narrows symmetrically from both ends. The features (peaks) in the $dQ/dV$ curve shift but maintain their relative spacing. The total area under the $dQ/dV$ curve decreases proportionally to the LLI fraction. In the incremental capacity curve $dQ/dV$: peaks shift toward lower voltage on discharge and higher voltage on charge.

*LAMpe* (cathode active material loss): Certain peaks in the $dQ/dV$ curve decrease in height and area — specifically the peaks associated with cathode phase transitions. The peaks associated with anode transitions are relatively preserved. The cell's capacity is limited by the cathode. The shape of the upper portion of the OCV curve changes.

*LAMne* (anode active material loss): The peaks associated with anode staging transitions (the graphite staging peaks at ~3.6–3.7 V in an NMC/graphite cell) decrease in height and shift. The cell's capacity becomes limited by the anode. The lower portion of the discharge curve changes shape.

*CL*: Conductivity loss (impedance growth) sits mostly **outside** Birkl's OCV-fitting framework. It does not affect the OCV curve or $dQ/dV$ curve measured under quasi-equilibrium conditions (very slow rate). However, it shows up as: increased voltage gap between charge and discharge curves at any non-zero current; increased DCIR in HPPC tests; enlarged semicircle(s) in EIS; reduced power capability and increased heat generation under load.

**The key diagnostic insight from Birkl et al.**: LLI, LAMpe, and LAMne are distinguishable from low-rate OCV or $dQ/dV$ analysis. Conductivity loss must then be diagnosed by complementary impedance or pulse-power measurements. All four can coexist in a real cell and must be disentangled systematically. A cell with 20% apparent performance fade might have 15% LLI, 3% LAMne, 2% LAMpe, and significant CL — and the appropriate corrective strategy (electrolyte formulation change to reduce SEI, particle size reduction to reduce cracking, upper voltage limit reduction to reduce metal dissolution) depends on correctly identifying which component dominates.

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

$$L_\text{SEI}(t) = \sqrt{L_0^2 + k_\text{SEI} t} \quad \text{(parabolic SEI growth law)} \tag{7.1}$$

$$k_\text{SEI}(T) = A\exp\!\left(-\frac{E_a}{RT}\right) \quad \text{(Arrhenius temperature dependence)} \tag{7.3}$$

$$\sigma_\text{max} \sim \frac{E\,\Omega\,\Delta c_\text{max}}{1-\nu} \quad \text{(diffusion-induced stress, scaling)} \tag{7.6}$$

$$Q_\text{loss,cal}(t,T) = B(T,\text{SOC})\sqrt{t}, \quad B(T) = B_0\exp\!\left(-\frac{E_a}{RT}\right) \quad \text{(calendar aging model)} \tag{7.12}$$

$$N_\text{f}(\text{DOD}) = N_\text{f,100\%} \left(\frac{1}{\text{DOD}}\right)^{\!\kappa} \quad \text{(cycle life vs.\ DOD)} \tag{7.16}$$

**Key vocabulary (in order of appearance):**

Loss of lithium/sodium inventory (LLI), loss of active material (LAM), conductivity loss (CL), N/P ratio, electrode slippage, lithium inventory drift, incremental capacity analysis (ICA), parabolic SEI growth law, Arrhenius activation energy for SEI, dead lithium/dead sodium, dendrite, diffusion-induced stress (DIS), intergranular cracking, single-crystal NMC, cathode–electrolyte interphase (CEI), transition metal dissolution, HF attack, Hunter mechanism, Mn³⁺ disproportionation, crosstalk, zeolitic water, gas generation, current interrupt device (CID), knee point, Wang model, rainflow counting, stressor, DOD–cycle life relationship, P2 ↔ O2 phase transition.

---

## Deliverable

**Task:** Read Birkl et al. (2017) "Degradation diagnostics for lithium ion cells" (*Journal of Power Sources* 341, 373–386) twice. Write a one-page summary in your own words identifying which mechanisms are diagnosable from external measurements alone.

**Guidance:** The paper is freely available via DOI: 10.1016/j.jpowsour.2016.12.011. On your first reading, focus on the overall framework (Sections 1–3) and absorb the capacity-fade classification (LLI, LAMpe, LAMne) and the concept of the half-cell model. On your second reading, go through Section 4 carefully: this is where specific diagnostic signatures are described for each mechanism.

Your one-page summary should be structured around the diagnostic question: for each mechanism listed in the paper, answer:

1. Which degradation mode does it primarily drive (LLI, LAMpe, LAMne)? If the mechanism primarily appears as impedance rise rather than capacity fade, note that separately.
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

---

*Next chapter: **Chapter 8 — Heat in Batteries.** We derive the Bernardi heat generation equation from first principles, quantify the three heat sources (ohmic, polarisation, entropic), work through a hand-calculation of steady-state heat generation for a commercial cell, and examine thermal runaway — its triggers, stages, and the reason SIBs are inherently safer. Prompt me with "write Chapter 8" to continue.*

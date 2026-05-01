# Lab Chapter 9: Thermal Modeling and Electrothermal Coupling

## Chapter Opening

This chapter is where the battery stops being an electrical object alone. In the theory textbook you learned that temperature is not an afterthought layered on top of electrochemistry. Temperature changes reaction rates, diffusivities, electrolyte conductivity, aging rate, lithium or sodium plating risk, and even the practical definition of "fast charge." A cell that looks safe in an isothermal simulation can become unacceptable once heat generation and heat rejection are allowed to compete.

Keep the thermal portions of Textbook Chapter 8 open as you work. This chapter operationalizes the Bernardi heat-generation equation, the lumped energy balance, and the electrothermal feedback loop you learned there. Also keep Textbook Chapter 10 nearby, because the first exercises deliberately connect an equivalent-circuit model to a thermal state before we return to PyBaMM. Finally, keep the sodium-ion chapter handy. Sodium-ion cells are often advertised as having stronger low-temperature tolerance than lithium-ion analogues, but that claim only becomes research-grade when we can quantify what "stronger" means under the same current, voltage, and thermal boundary conditions.

By the end of this chapter you will be able to build a transparent lumped thermal model from first principles, fit a simple thermal resistance and heat capacity to temperature data, turn on PyBaMM's thermal submodels, compare isothermal and electrothermal simulations, and run a CCCV charge under three ambient temperatures. The deliverable is a coupled electrothermal PyBaMM simulation of a CCCV charge under cold, room-temperature, and warm ambient conditions, with a written interpretation of the observed tradeoffs.

This is publishable-research skill because thermal assumptions are one of the easiest places to fool yourself. A paper can report an impressive fast-charge protocol, an elegant degradation prediction, or a sodium-ion advantage, but the claim becomes weak if the thermal boundary condition is unrealistic or unreported. Reviewers will ask whether the cell was assumed isothermal, whether heat transfer coefficients were justified, whether temperature-dependent parameters were enabled, whether the current profile respects voltage and temperature limits, and whether the conclusions survive a change in ambient temperature. The work in this chapter gives you the practical language to answer those questions.

We will move in five stages. First, we derive and code a lumped thermal model by hand so that every watt and kelvin has a place to live. Second, we use public NASA battery data to estimate thermal parameters from a measured current-voltage-temperature trace. Third, we turn on PyBaMM thermal options and inspect the variables the solver exposes. Fourth, we reproduce the qualitative temperature-profile comparison from a published fast-charging study by comparing 1C, 3C, and 5C CCCV-style protocols. Fifth, we build the chapter deliverable: a coupled electrothermal CCCV charge at three ambient temperatures and a sodium-ion-focused interpretation of what changes.

## Prerequisites Check

- Required software: Python `3.11`, `pybamm==25.10.2`, `numpy==2.1.3`, `scipy==1.14.1`, `pandas==2.2.3`, `matplotlib==3.9.2`, `requests==2.32.3`, and `h5py==3.12.1`
- Optional software: MATLAB `R2024b` or newer with Simulink and Simscape if you want to extend the Simulink thermal section into a block diagram
- Required textbook chapters: Textbook Chapter 8 thermal modeling section is essential; Textbook Chapter 10 is recommended; the sodium-ion chapter is strongly recommended
- Required prior lab chapters: Lab Chapters 1, 2, 3, and 4 are essential; Lab Chapter 6 helps for ECM intuition; Lab Chapter 7 is not required
- Estimated time: 12 to 16 hours for the full chapter

If PyBaMM still feels unfamiliar, revisit Lab Chapter 3 before continuing. If PyBaMM experiments and parameter updates feel shaky, revisit Lab Chapter 4. If ordinary differential equations in `scipy.solve_ivp` feel rusty, reread the solver section of Lab Chapter 2 before starting Walkthrough 1.

## Environment Setup

We will use a fresh Python environment because thermal PyBaMM examples are sensitive to version drift. PyBaMM is an active project, and examples from older notebooks can fail if option names or solver defaults have moved. The version pinned here, `25.10.2`, matches the current stable documentation family used for this chapter's thermal options.

### Step 1: Create the environment

From a terminal, create and activate a new environment:

```bash
cd /home/avirup/SodiumIonBatteryResearch
python3.11 -m venv .venv-chapter9
source .venv-chapter9/bin/activate
python -m pip install --upgrade pip
python -m pip install pybamm==25.10.2 numpy==2.1.3 scipy==1.14.1 pandas==2.2.3 matplotlib==3.9.2 requests==2.32.3 h5py==3.12.1
```

If you use conda instead of `venv`, the equivalent is:

```bash
conda create -n battery-chapter9 python=3.11 -y
conda activate battery-chapter9
python -m pip install pybamm==25.10.2 numpy==2.1.3 scipy==1.14.1 pandas==2.2.3 matplotlib==3.9.2 requests==2.32.3 h5py==3.12.1
```

The installation may take several minutes because PyBaMM pulls in solver and symbolic-model dependencies. This is normal. If the install fails while building `casadi` or a solver dependency, first upgrade `pip`, then retry the exact install command. If it still fails on Windows, use conda for Python itself and pip only for the pinned packages.

### Step 2: Create a chapter workspace

Run this from the project root:

```bash
mkdir -p SimulationCompanion/chapter9_thermal_workspace
cd SimulationCompanion/chapter9_thermal_workspace
```

The code in this chapter writes downloaded data, CSV files, and figures into this folder. Keeping chapter artifacts separate is not just neatness. It makes it possible to rerun the lab months later and know exactly which files were produced by which workflow.

### Step 3: Verify the install

Open a new Jupyter notebook in the activated environment or run the following as a Python script:

```python
import pybamm
import numpy as np
import scipy
import pandas as pd
import matplotlib

print("PyBaMM:", pybamm.__version__)
print("NumPy:", np.__version__)
print("SciPy:", scipy.__version__)
print("pandas:", pd.__version__)
print("Matplotlib:", matplotlib.__version__)

model = pybamm.lithium_ion.SPM({"thermal": "lumped"})
parameter_values = pybamm.ParameterValues("Chen2020")
experiment = pybamm.Experiment(
    ["Discharge at 1C for 10 minutes"],
    period="10 seconds",
    temperature="25 oC",
)
simulation = pybamm.Simulation(
    model,
    parameter_values=parameter_values,
    experiment=experiment,
)
solution = simulation.solve()

final_voltage = solution["Terminal voltage [V]"](solution.t[-1])
final_temperature = solution["Volume-averaged cell temperature [K]"](solution.t[-1])

print(f"Final voltage: {final_voltage:.3f} V")
print(f"Final cell temperature: {final_temperature:.2f} K")
```

Expected output:

```text
PyBaMM: 25.10.2
NumPy: 2.1.3
SciPy: 1.14.1
pandas: 2.2.3
Matplotlib: 3.9.2
Final voltage: 3.xxx V
Final cell temperature: 298.xx K
```

The last digits will vary slightly by platform and solver. What matters is that the simulation runs, the voltage is near the normal lithium-ion operating range, and the final temperature is only slightly above ambient for a short 1C discharge.

### Common installation failures and fixes

`ModuleNotFoundError: No module named 'pybamm'` means your notebook kernel is not using the environment you installed into. In Jupyter, install a kernel with `python -m ipykernel install --user --name battery-chapter9 --display-name "Battery Chapter 9"` and select that kernel.

`pybamm.OptionError` when selecting a thermal model usually means a geometry option is incompatible with the thermal option. In PyBaMM, `x-full` is a pouch-cell through-thickness thermal model, so use it with compatible pouch geometry and a model that supports it. For this chapter, we use `lumped` for the main deliverable because it is robust and fast.

Solver failures during aggressive fast-charge simulations usually mean the requested experiment is physically or numerically too severe for the parameter set. Reduce the C-rate, loosen the final SOC target, add a voltage termination, or switch from DFN to SPMe before assuming PyBaMM is broken.

If plots appear blank in a notebook, run `%matplotlib inline` in a cell before plotting. If you are running scripts from a terminal, make sure the script calls `plt.show()` after creating figures.

## Conceptual Bridge: From Bernardi Heat to PyBaMM Thermal Objects

In Textbook Chapter 8, thermal modeling began with an energy balance. A cell has thermal mass, generates heat internally, and exchanges heat with its surroundings. In its simplest lumped form, the cell temperature $T$ obeys

$$
m c_p \frac{dT}{dt}
=
\dot{Q}_{\mathrm{gen}}
-
h A (T - T_{\infty}),
\tag{1}
$$

where $m$ is cell mass, $c_p$ is average specific heat, $h$ is an effective heat transfer coefficient, $A$ is cooling surface area, and $T_{\infty}$ is ambient temperature. Equation (1) is easy to write down and surprisingly powerful. It tells you immediately why a small cell under a short pulse may barely warm, while a large-format cell under fast charging can remain hot long after current tapers. The thermal time constant is

$$
\tau_{\mathrm{th}} = \frac{m c_p}{h A}.
\tag{2}
$$

If $\tau_{\mathrm{th}}$ is large compared with the electrical event, heat accumulates. If it is small, the cell tracks ambient more closely. This one number will appear repeatedly in your intuition even when the model becomes electrochemical.

The harder part is $\dot{Q}_{\mathrm{gen}}$. Bernardi's heat-generation expression is commonly written as

$$
\dot{Q}_{\mathrm{gen}}
=
I\left(U_{\mathrm{oc}} - V\right)
-
I T \frac{\partial U_{\mathrm{oc}}}{\partial T},
\tag{3}
$$

where $I$ is current under a chosen sign convention, $U_{\mathrm{oc}}$ is open-circuit voltage, $V$ is terminal voltage, and $\partial U_{\mathrm{oc}}/\partial T$ is the entropic coefficient. The first term is irreversible heat. It collects ohmic and reaction losses. In a simple circuit model this is often approximated as $I^2R$. The second term is reversible heat. It can be positive or negative depending on chemistry, SOC, and current direction. This is one reason measured cell temperature sometimes does not follow the naive $I^2R$ picture perfectly.

PyBaMM represents this same physics at a much richer level. In a DFN or SPMe model, the terminal voltage is not just an algebraic input to Equation (3). It emerges from solid potentials, electrolyte potentials, reaction overpotentials, concentration fields, and open-circuit potentials. When you choose `{"thermal": "lumped"}`, PyBaMM computes the volume-averaged heat source from the electrochemical solution and evolves a cell-average temperature. When you choose `{"thermal": "x-full"}`, PyBaMM solves a through-cell thermal PDE for pouch geometry. Newer PyBaMM documentation also describes higher-dimensional pouch-cell thermal models that resolve in-plane temperature variation, but those are more expensive and require geometry and boundary-condition care.

The conceptual map is:

| Textbook idea | Hand model representation | PyBaMM representation |
| --- | --- | --- |
| Thermal mass | `m_cell_kg * cp_j_per_kg_k` | Effective volumetric heat capacity from cell layers |
| Heat loss | `h * area * (T - T_amb)` | Cooling terms from heat-transfer and geometry parameters |
| Ohmic heat | `current_a**2 * resistance_ohm` | Solid/electrolyte ohmic heat submodels |
| Reaction heat | Often folded into an effective resistance | Interfacial current times overpotential |
| Reversible heat | `-I*T*dU_dT` if entropic data are known | Entropic-change functions in the parameter set |
| Temperature feedback | Manual updates to resistance or OCV | Temperature-dependent parameters inside the electrochemical model |

This chapter deliberately starts with the hand model because it gives you a conservation-law audit trail. If your PyBaMM result says the cell warms by `15 K`, you should have a rough sense of whether that is plausible. Suppose a `5 Ah` cell has `m c_p = 900 J/K`. A `3C` charge at `15 A` through an effective `20 mOhm` resistance generates about `4.5 W`. With no cooling, thirty minutes would add `9 K`. With cooling, less. If your simulation predicts `80 K` rise for that case, either the current is far more severe, the cooling is nearly absent, the parameter set is not representing the cell you imagine, or a sign convention has gone wrong.

Thermal modeling also forces us to distinguish three phrases that are often blurred. "Isothermal" means temperature is held fixed. It does not mean heat generation is zero; it means the thermal state is not solved. "Lumped thermal" means the model solves one average cell temperature. It can capture warm-up and cool-down but not internal gradients. "Spatial thermal" means temperature varies across at least one coordinate. Spatial models are essential when tab placement, pouch geometry, cooling plates, or large-format gradients matter. For the simulation-based sodium-ion research path in this companion, lumped electrothermal modeling is the right first publishable tool: simple enough to calibrate with sparse data, rich enough to expose temperature-current tradeoffs, and fast enough to use in sweeps.

## Guided Walkthrough 1: Build a Lumped Thermal Model from First Principles

**Learning objective:** Implement Equation (1) with both irreversible and reversible heat terms, then interpret the temperature response under a pulse-current profile.

Before PyBaMM gets involved, we want a model you can hold in your head. We will prescribe a current profile, compute a simple SOC-dependent OCV, compute terminal voltage using a resistance, compute heat generation, and solve the lumped energy balance. This is a teaching model, not a high-fidelity cell model. Its purpose is to make units, signs, and time constants concrete.

```python
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp


def ocv_from_soc(soc):
    """Smooth teaching OCV curve for a lithium-ion-like cell."""
    soc_clipped = np.clip(soc, 0.0, 1.0)
    baseline = 3.05 + 1.05 * soc_clipped
    plateau_shape = 0.08 * np.tanh((soc_clipped - 0.55) / 0.08)
    low_soc_knee = -0.10 * np.exp(-soc_clipped / 0.08)
    high_soc_knee = 0.05 * np.exp(-(1.0 - soc_clipped) / 0.05)
    return baseline + plateau_shape + low_soc_knee + high_soc_knee


def entropic_coefficient_from_soc(soc):
    """Approximate dUoc/dT in V/K for a teaching cell."""
    soc_clipped = np.clip(soc, 0.0, 1.0)
    return 1.2e-4 * np.sin(2.0 * np.pi * (soc_clipped - 0.15))


def current_profile_a(time_s):
    """Positive current means discharge in this walkthrough."""
    if time_s < 300.0:
        return 0.0
    if time_s < 1500.0:
        return 6.0
    if time_s < 2400.0:
        return 0.0
    if time_s < 3300.0:
        return 10.0
    return 0.0


def electrothermal_rhs(time_s, state, parameters):
    soc, temperature_k = state
    current_a = current_profile_a(time_s)

    capacity_ah = parameters["capacity_ah"]
    resistance_ohm = parameters["resistance_ohm"]
    mass_kg = parameters["mass_kg"]
    cp_j_per_kg_k = parameters["cp_j_per_kg_k"]
    h_w_per_m2_k = parameters["h_w_per_m2_k"]
    area_m2 = parameters["area_m2"]
    ambient_k = parameters["ambient_k"]

    ocv_v = ocv_from_soc(soc)
    dudt_v_per_k = entropic_coefficient_from_soc(soc)
    terminal_voltage_v = ocv_v - current_a * resistance_ohm

    irreversible_heat_w = current_a * (ocv_v - terminal_voltage_v)
    reversible_heat_w = -current_a * temperature_k * dudt_v_per_k
    heat_generation_w = irreversible_heat_w + reversible_heat_w
    heat_loss_w = h_w_per_m2_k * area_m2 * (temperature_k - ambient_k)

    dsoc_dt = -current_a / (3600.0 * capacity_ah)
    dtemperature_dt = (
        heat_generation_w - heat_loss_w
    ) / (mass_kg * cp_j_per_kg_k)

    return [dsoc_dt, dtemperature_dt]


parameters = {
    "capacity_ah": 5.0,
    "resistance_ohm": 0.018,
    "mass_kg": 0.280,
    "cp_j_per_kg_k": 950.0,
    "h_w_per_m2_k": 12.0,
    "area_m2": 0.030,
    "ambient_k": 298.15,
}

initial_state = [0.85, parameters["ambient_k"]]
time_eval_s = np.arange(0.0, 4800.0 + 1.0, 1.0)

solution = solve_ivp(
    fun=lambda time_s, state: electrothermal_rhs(time_s, state, parameters),
    t_span=(time_eval_s[0], time_eval_s[-1]),
    y0=initial_state,
    t_eval=time_eval_s,
    method="BDF",
    rtol=1e-8,
    atol=[1e-9, 1e-6],
)

if not solution.success:
    raise RuntimeError(solution.message)

soc = solution.y[0]
temperature_k = solution.y[1]
current_a = np.array([current_profile_a(t) for t in solution.t])
ocv_v = ocv_from_soc(soc)
voltage_v = ocv_v - current_a * parameters["resistance_ohm"]
temperature_c = temperature_k - 273.15

fig, axes = plt.subplots(4, 1, figsize=(9, 9), sharex=True)

axes[0].plot(solution.t / 60.0, current_a, color="tab:blue", linewidth=1.8)
axes[0].set_ylabel("Current [A]")
axes[0].grid(True)

axes[1].plot(solution.t / 60.0, soc, color="tab:green", linewidth=1.8)
axes[1].set_ylabel("SOC [-]")
axes[1].grid(True)

axes[2].plot(solution.t / 60.0, voltage_v, color="tab:purple", linewidth=1.8)
axes[2].set_ylabel("Voltage [V]")
axes[2].grid(True)

axes[3].plot(solution.t / 60.0, temperature_c, color="tab:red", linewidth=1.8)
axes[3].axhline(parameters["ambient_k"] - 273.15, color="0.4", linestyle="--")
axes[3].set_ylabel("Cell temp. [deg C]")
axes[3].set_xlabel("Time [min]")
axes[3].grid(True)

fig.suptitle("Lumped electrothermal response to discharge pulses")
fig.tight_layout()
plt.show()

print(f"Final SOC: {soc[-1]:.4f}")
print(f"Peak temperature: {temperature_c.max():.2f} deg C")
print(f"Temperature rise: {temperature_c.max() - (parameters['ambient_k'] - 273.15):.2f} K")
print(f"Thermal time constant: {parameters['mass_kg'] * parameters['cp_j_per_kg_k'] / (parameters['h_w_per_m2_k'] * parameters['area_m2']) / 60.0:.1f} min")
```

The code begins with an OCV function and an entropic-coefficient function. These are intentionally smooth teaching functions. Real work should use measured OCV and entropy data where possible. The current profile uses positive current for discharge, matching the sign convention in Lab Chapter 6. The right-hand side computes the electrical variables first, then the irreversible heat, reversible heat, heat loss, SOC derivative, and temperature derivative.

The line `irreversible_heat_w = current_a * (ocv_v - terminal_voltage_v)` is equivalent to $I^2R$ here because the terminal voltage is `ocv_v - current_a * resistance_ohm`. We write it in Bernardi form so the same pattern remains recognizable later when voltage comes from a more complex model. The reversible heat term can change sign because `entropic_coefficient_from_soc` can be positive or negative. This is standard physics, not a numerical trick.

The plot should have four stacked panels. The first panel shows two discharge pulses, one at `6 A` and one at `10 A`. The second panel shows SOC decreasing only during the pulses. The third panel shows voltage stepping downward when current turns on, then recovering during rest. The fourth panel shows cell temperature rising during the pulses and relaxing during rest. The second pulse should cause a visibly faster temperature rise because heat scales roughly with current squared in this simple model.

The printed peak temperature should be only a few degrees above ambient with the parameters shown. The thermal time constant should be around `12.3 min`. That time constant explains why the temperature does not instantly return to ambient during the rest interval.

### What could go wrong

If the temperature decreases during a high-current discharge, check the current sign convention and the entropic term. A large positive entropic coefficient during discharge can create reversible cooling, but it should not dominate the whole response in this teaching example unless you changed the coefficient magnitude.

If SOC increases during discharge, the sign in `dsoc_dt` is wrong. In this chapter's hand models, positive current means discharge, so SOC must decrease.

If `solve_ivp` returns `Required step size is less than spacing between numbers`, you probably introduced a discontinuous expression that creates numerical trouble. Keep the current profile piecewise constant as shown, or split the simulation at current transition times.

If the temperature rise is enormous, inspect units. Area must be in square meters, mass in kilograms, specific heat in joules per kilogram-kelvin, and resistance in ohms.

### Reflection

This exercise gave you a thermal back-of-the-envelope tool. You can now estimate whether a simulated temperature rise is plausible before trusting a high-level package. We will reuse this same energy-balance logic when fitting NASA data and when interpreting PyBaMM's coupled electrothermal output.

## Guided Walkthrough 2: Fit a Lumped Thermal Model to Public NASA Data

**Learning objective:** Parse a public current-voltage-temperature battery trace and fit effective thermal parameters from measured temperature.

The NASA Prognostics Center of Excellence randomized battery datasets contain 18650 lithium-ion cells operated under randomized currents with reference cycles. The room-temperature random-walk discharge dataset includes cells RW3 through RW6 and repeatedly charges cells to `4.2 V`, then discharges them to `3.2 V` using randomized discharge currents. The NASA Open Data portal lists the dataset as public, and NASA's Zenodo mirror gives the full PCoE randomized battery usage collection a DOI, `10.5281/zenodo.15277374`, under a Creative Commons Attribution 4.0 license. We will use the smaller room-temperature discharge ZIP, about `120 MB`, rather than the larger charge-discharge archive.

For a textbook-stable lab, the code below is defensive. It downloads the ZIP if available, searches for MATLAB files inside it, and then normalizes common NASA field names. If the portal changes its resource URL, the parser still teaches the pattern: locate a cycle, extract time, current, voltage, and measured temperature, then fit $m c_p$ and $hA$.

```python
from pathlib import Path
from zipfile import ZipFile
import requests
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.io import loadmat
from scipy.optimize import least_squares
from scipy.integrate import solve_ivp


DATA_URL = (
    "https://zenodo.org/records/15277374/files/"
    "2.%20Battery_Uniform_Distribution_Discharge_Room_Temp_DataSet_2Post.zip"
    "?download=1"
)

workspace = Path("chapter9_data")
workspace.mkdir(exist_ok=True)
zip_path = workspace / "nasa_random_walk_room_temperature_discharge.zip"
extract_dir = workspace / "nasa_random_walk_room_temperature_discharge"


def download_file(url, output_path):
    if output_path.exists() and output_path.stat().st_size > 1_000_000:
        print(f"Using existing file: {output_path}")
        return

    print(f"Downloading {url}")
    response = requests.get(url, stream=True, timeout=60)
    response.raise_for_status()
    with output_path.open("wb") as file:
        for chunk in response.iter_content(chunk_size=1024 * 1024):
            if chunk:
                file.write(chunk)
    print(f"Saved {output_path} ({output_path.stat().st_size / 1e6:.1f} MB)")


def extract_zip(zip_file, destination):
    if destination.exists() and any(destination.rglob("*.mat")):
        print(f"Using existing extracted folder: {destination}")
        return

    destination.mkdir(exist_ok=True)
    with ZipFile(zip_file) as archive:
        archive.extractall(destination)
    print(f"Extracted files into {destination}")


def find_first_mat_file(folder):
    mat_files = sorted(folder.rglob("*.mat"))
    if not mat_files:
        raise FileNotFoundError("No .mat files found after extraction.")
    print("First five MATLAB files:")
    for path in mat_files[:5]:
        print("  ", path)
    return mat_files[0]


def flatten_mat_struct(obj):
    if isinstance(obj, np.ndarray) and obj.dtype.names is not None:
        return {name: flatten_mat_struct(obj[name][0, 0]) for name in obj.dtype.names}
    if isinstance(obj, np.ndarray) and obj.size == 1:
        return flatten_mat_struct(obj.item())
    return obj


def extract_numeric_series(cycle_dict, candidate_names):
    for name in candidate_names:
        if name in cycle_dict:
            value = np.asarray(cycle_dict[name]).squeeze()
            if value.ndim == 1 and value.size > 10:
                return value.astype(float)
    raise KeyError(f"None of the candidate names were present: {candidate_names}")


def load_first_usable_trace(mat_path):
    raw = loadmat(mat_path, squeeze_me=False, struct_as_record=False)
    top_level_keys = [key for key in raw.keys() if not key.startswith("__")]
    print("Top-level keys:", top_level_keys)

    # NASA files appear in several nested formats. This branch handles the common
    # PCoE cycle-structured format and falls back to a flat field search.
    root = raw[top_level_keys[0]]
    root_dict = flatten_mat_struct(root)

    if isinstance(root_dict, dict) and "cycle" in root_dict:
        cycles = np.asarray(root_dict["cycle"]).squeeze()
        for cycle in cycles:
            cycle_dict = flatten_mat_struct(cycle)
            data = cycle_dict.get("data", cycle_dict)
            if not isinstance(data, dict):
                continue
            try:
                time_s = extract_numeric_series(data, ["Time", "time"])
                current_a = extract_numeric_series(
                    data,
                    ["Current_measured", "current", "Current"],
                )
                voltage_v = extract_numeric_series(
                    data,
                    ["Voltage_measured", "voltage", "Voltage"],
                )
                temperature_c = extract_numeric_series(
                    data,
                    ["Temperature_measured", "temperature", "Temperature"],
                )
                return pd.DataFrame(
                    {
                        "time_s": time_s - time_s[0],
                        "current_a_raw": current_a,
                        "voltage_v": voltage_v,
                        "temperature_c": temperature_c,
                    }
                )
            except KeyError:
                continue

    flat_candidates = {}
    for key, value in raw.items():
        if key.startswith("__"):
            continue
        array = np.asarray(value).squeeze()
        if array.ndim == 1 and array.size > 10:
            flat_candidates[key] = array.astype(float)

    required = {
        "time_s": ["Time", "time", "t"],
        "current_a_raw": ["Current", "current", "Current_measured"],
        "voltage_v": ["Voltage", "voltage", "Voltage_measured"],
        "temperature_c": ["Temperature", "temperature", "Temperature_measured"],
    }
    output = {}
    for output_name, names in required.items():
        for name in names:
            if name in flat_candidates:
                output[output_name] = flat_candidates[name]
                break
        if output_name not in output:
            raise KeyError(f"Could not find {output_name} in {mat_path}")

    frame = pd.DataFrame(output)
    frame["time_s"] = frame["time_s"] - frame["time_s"].iloc[0]
    return frame


download_file(DATA_URL, zip_path)
extract_zip(zip_path, extract_dir)
mat_path = find_first_mat_file(extract_dir)
trace = load_first_usable_trace(mat_path)

trace = trace.dropna().sort_values("time_s").drop_duplicates("time_s")
trace = trace.iloc[: min(len(trace), 2500)].copy()

# NASA files may use positive charge or positive discharge depending on source.
# For heat fitting, current squared dominates, but voltage-power signs still matter.
trace["current_a"] = trace["current_a_raw"]
trace["power_w"] = trace["voltage_v"] * trace["current_a"]

ambient_c = float(trace["temperature_c"].iloc[:50].median())
trace["temperature_k"] = trace["temperature_c"] + 273.15

print(trace.head())
print(f"Trace duration: {trace['time_s'].iloc[-1] / 60:.1f} min")
print(f"Ambient estimate: {ambient_c:.2f} deg C")
```

The parser is longer than the model, and that is realistic. Public battery datasets rarely arrive as tidy `time,current,voltage,temperature` CSV files. The helper `flatten_mat_struct` handles MATLAB struct arrays. The loader first tries the common NASA cycle format and then falls back to flat numeric arrays. The current sign is not changed because the thermal fit mostly needs heat magnitude, but we preserve `current_a_raw` so you can audit signs later.

Now fit a simple model:

```python
def simulate_temperature_for_fit(time_s, current_a, voltage_v, theta):
    log_thermal_mass, log_ha, log_resistance = theta
    thermal_mass_j_per_k = np.exp(log_thermal_mass)
    ha_w_per_k = np.exp(log_ha)
    resistance_ohm = np.exp(log_resistance)

    ambient_k = ambient_c + 273.15
    current_interp = lambda t: np.interp(t, time_s, current_a)

    def rhs(t, temperature_k_array):
        current_now = current_interp(t)
        heat_generation_w = (current_now**2) * resistance_ohm
        heat_loss_w = ha_w_per_k * (temperature_k_array[0] - ambient_k)
        return [(heat_generation_w - heat_loss_w) / thermal_mass_j_per_k]

    solution = solve_ivp(
        rhs,
        (time_s[0], time_s[-1]),
        [ambient_k],
        t_eval=time_s,
        method="BDF",
        rtol=1e-6,
        atol=1e-5,
    )
    if not solution.success:
        raise RuntimeError(solution.message)
    return solution.y[0]


time_s = trace["time_s"].to_numpy()
current_a = trace["current_a"].to_numpy()
temperature_k_measured = trace["temperature_k"].to_numpy()
voltage_v = trace["voltage_v"].to_numpy()


def residual(theta):
    predicted_k = simulate_temperature_for_fit(time_s, current_a, voltage_v, theta)
    return predicted_k - temperature_k_measured


initial_guess = np.log([350.0, 0.18, 0.030])
lower_bounds = np.log([50.0, 0.02, 0.001])
upper_bounds = np.log([3000.0, 3.0, 0.300])

fit = least_squares(
    residual,
    initial_guess,
    bounds=(lower_bounds, upper_bounds),
    xtol=1e-8,
    ftol=1e-8,
    gtol=1e-8,
)

thermal_mass_j_per_k, ha_w_per_k, resistance_ohm = np.exp(fit.x)
predicted_temperature_k = simulate_temperature_for_fit(time_s, current_a, voltage_v, fit.x)
rmse_k = np.sqrt(np.mean((predicted_temperature_k - temperature_k_measured) ** 2))

print(f"Fitted thermal mass: {thermal_mass_j_per_k:.1f} J/K")
print(f"Fitted hA: {ha_w_per_k:.4f} W/K")
print(f"Fitted effective resistance: {resistance_ohm:.4f} ohm")
print(f"Temperature RMSE: {rmse_k:.3f} K")

fig, axes = plt.subplots(3, 1, figsize=(9, 8), sharex=True)

axes[0].plot(time_s / 60.0, current_a, linewidth=1.2)
axes[0].set_ylabel("Current [A]")
axes[0].grid(True)

axes[1].plot(time_s / 60.0, voltage_v, linewidth=1.2, color="tab:purple")
axes[1].set_ylabel("Voltage [V]")
axes[1].grid(True)

axes[2].plot(
    time_s / 60.0,
    temperature_k_measured - 273.15,
    label="Measured",
    linewidth=1.5,
)
axes[2].plot(
    time_s / 60.0,
    predicted_temperature_k - 273.15,
    label="Fitted lumped model",
    linewidth=1.5,
)
axes[2].set_ylabel("Temperature [deg C]")
axes[2].set_xlabel("Time [min]")
axes[2].legend()
axes[2].grid(True)

fig.suptitle("NASA trace: lumped thermal fit")
fig.tight_layout()
plt.show()
```

You should see a current trace with irregular steps, a voltage trace responding to the load, and a temperature trace that changes slowly compared with current. The fitted thermal model should follow the broad temperature trend but will not capture every detail. That mismatch is expected. We used a single effective resistance and a single thermal state. Real cells have SOC-dependent resistance, entropic heat, sensor lag, spatial gradients, and chamber dynamics.

The fitted values should be physically plausible. A small 18650 cell may have a thermal mass on the order of tens to hundreds of joules per kelvin. A fitted value outside the bounds means the data segment did not contain enough thermal excitation, the current sign or units are wrong, or the temperature channel is not the cell-surface temperature you think it is.

### Dataset pitfalls

NASA dataset timestamps are not always uniform across files. Always sort by time and remove duplicate timestamps before integrating.

Current sign conventions vary. For thermal fitting, $I^2R$ hides much of that problem, but for Bernardi heat and SOC tracking, sign convention must be explicit.

Temperature may be measured at the cell surface, not the electrochemical volume average. A single lumped model fitted to surface temperature is useful, but do not claim it validates core temperature.

Some files include reference cycles, impedance tests, and randomized loading in the same archive. Always inspect cycle metadata before treating a segment as a fast-charge or discharge experiment.

### Reflection

This exercise turned public data into thermal parameters. The model is deliberately simple, but the workflow is real: parse, normalize, estimate ambient, choose a heat-generation approximation, fit, plot residuals, and discuss what the model can and cannot claim. We will return to public datasets in Chapter 11 with a reusable loader architecture.

## Guided Walkthrough 3: Turn on PyBaMM Thermal Options

**Learning objective:** Compare isothermal and lumped electrothermal PyBaMM simulations under the same discharge protocol.

Now we let PyBaMM compute heat generation from an electrochemical model. We use the SPMe because it is fast enough for repeated thermal experiments while retaining electrolyte effects missing from the simplest SPM. The structure is the same as earlier PyBaMM chapters: choose a model, choose parameter values, define an experiment, solve, and extract variables.

```python
import pybamm
import numpy as np
import matplotlib.pyplot as plt


def run_spme_discharge(thermal_option, ambient_c, c_rate):
    model = pybamm.lithium_ion.SPMe({"thermal": thermal_option})
    parameter_values = pybamm.ParameterValues("Chen2020")

    experiment = pybamm.Experiment(
        [
            f"Rest for 10 minutes",
            f"Discharge at {c_rate}C until 2.8 V",
            f"Rest for 20 minutes",
        ],
        period="20 seconds",
        temperature=f"{ambient_c} oC",
    )

    simulation = pybamm.Simulation(
        model,
        parameter_values=parameter_values,
        experiment=experiment,
    )
    solution = simulation.solve()
    return solution


isothermal_solution = run_spme_discharge("isothermal", ambient_c=25, c_rate=2)
lumped_solution = run_spme_discharge("lumped", ambient_c=25, c_rate=2)


def extract_solution_frame(solution, label):
    time_min = solution["Time [min]"].entries
    voltage_v = solution["Terminal voltage [V]"].entries
    current_a = solution["Current [A]"].entries
    temperature_k = solution["Volume-averaged cell temperature [K]"].entries

    return {
        "label": label,
        "time_min": time_min,
        "voltage_v": voltage_v,
        "current_a": current_a,
        "temperature_c": temperature_k - 273.15,
    }


frames = [
    extract_solution_frame(isothermal_solution, "isothermal"),
    extract_solution_frame(lumped_solution, "lumped thermal"),
]

fig, axes = plt.subplots(3, 1, figsize=(9, 8), sharex=True)

for frame in frames:
    axes[0].plot(frame["time_min"], frame["current_a"], label=frame["label"], linewidth=1.5)
    axes[1].plot(frame["time_min"], frame["voltage_v"], label=frame["label"], linewidth=1.5)
    axes[2].plot(frame["time_min"], frame["temperature_c"], label=frame["label"], linewidth=1.5)

axes[0].set_ylabel("Current [A]")
axes[1].set_ylabel("Voltage [V]")
axes[2].set_ylabel("Temperature [deg C]")
axes[2].set_xlabel("Time [min]")

for axis in axes:
    axis.grid(True)
    axis.legend()

fig.suptitle("PyBaMM SPMe: isothermal vs lumped thermal")
fig.tight_layout()
plt.show()

for frame in frames:
    print(
        f"{frame['label']}: final time = {frame['time_min'][-1]:.2f} min, "
        f"min voltage = {frame['voltage_v'].min():.3f} V, "
        f"max temp = {frame['temperature_c'].max():.2f} deg C"
    )
```

The isothermal temperature line should remain flat at `25 deg C`. The lumped thermal line should rise during discharge and relax during the final rest. The voltage curves may differ slightly because temperature feeds back into transport and kinetic parameters. At moderate C-rate the difference may be small; that is itself a result. Thermal coupling does not always dominate terminal voltage over a short event, but it strongly affects safety margins and degradation interpretation.

The important PyBaMM object-level move is `pybamm.lithium_ion.SPMe({"thermal": thermal_option})`. The model option changes the submodel composition before discretization. You are not post-processing temperature after the electrical simulation. You are asking PyBaMM to solve a coupled model.

The variable name `"Volume-averaged cell temperature [K]"` is a standard high-value output for lumped thermal work. PyBaMM exposes many heat-generation variables too, including irreversible and reversible heating terms in compatible models and parameter sets. Use `solution.all_models[0].variables.keys()` when you need to discover exact variable names for your installed version.

### What could go wrong

If `Volume-averaged cell temperature [K]` is not found, print available temperature variables:

```python
temperature_keys = [
    key for key in lumped_solution.all_models[0].variables.keys()
    if "temperature" in key.lower()
]
for key in temperature_keys:
    print(key)
```

If the lumped and isothermal voltage curves are identical, check that you actually solved the lumped model and did not reuse the isothermal solution object.

If the discharge terminates almost immediately, your voltage cutoff is too high for the initial state and parameter set. Use a lower cutoff or begin with a charge/rest step.

If the simulation is slow, switch from DFN to SPMe. For thermal sweeps, SPMe is often the right first research model because it preserves key electrochemical behavior without DFN-level cost.

### Reflection

This exercise translated the hand energy balance into PyBaMM's model-option language. You now know how to ask whether thermal coupling changes the electrical trajectory under the same experiment. That question is central to every fast-charge, cold-start, and abuse-margin study.

## Guided Walkthrough 4: Reproduce a Published Fast-Charge Temperature Comparison

**Learning objective:** Reproduce the qualitative result of a published fast-charging figure: higher C-rate CCCV protocols produce larger and longer temperature excursions.

Romero, Goldar, and Garone's 2019 Modelica conference paper, "A Model Predictive Control Application for a Constrained Fast Charge of Lithium-ion Batteries," compares CCCV charging protocols at 1C, 3C, and 5C and shows corresponding temperature profiles in their Figure 6. Their model is not PyBaMM, and the paper's exact cell parameters are not fully sufficient for a bit-for-bit reproduction. That makes it a useful research exercise. We will reproduce the qualitative figure: three CCCV-like charging protocols, same ambient, same thermal model family, increasing C-rate, and temperature trajectories that separate strongly as current increases.

This is a "close enough" reproduction exercise. Close enough means the ordering, shape, and physical interpretation match the paper: 5C heats most, 3C heats moderately, 1C heats least; higher C-rate protocols remain above ambient longer. It does not mean the peak temperatures match the paper digit-for-digit.

```python
import pybamm
import matplotlib.pyplot as plt


def run_fast_charge_case(c_rate, ambient_c=25):
    model = pybamm.lithium_ion.SPMe({"thermal": "lumped"})
    parameter_values = pybamm.ParameterValues("Chen2020")

    # We begin from a low-SOC state by discharging first. This keeps the example
    # self-contained without manually setting every initial concentration.
    experiment = pybamm.Experiment(
        [
            "Discharge at 1C until 2.8 V",
            "Rest for 20 minutes",
            f"Charge at {c_rate}C until 4.2 V",
            "Hold at 4.2 V until C/20",
            "Rest for 30 minutes",
        ],
        period="20 seconds",
        temperature=f"{ambient_c} oC",
    )

    simulation = pybamm.Simulation(
        model,
        parameter_values=parameter_values,
        experiment=experiment,
    )
    return simulation.solve()


c_rates = [1, 3, 5]
solutions = {}

for c_rate in c_rates:
    try:
        solutions[c_rate] = run_fast_charge_case(c_rate)
        print(f"{c_rate}C case solved.")
    except Exception as error:
        print(f"{c_rate}C case failed: {error}")

fig, axes = plt.subplots(3, 1, figsize=(9, 8), sharex=True)

for c_rate, solution in solutions.items():
    time_min = solution["Time [min]"].entries
    current_a = solution["Current [A]"].entries
    voltage_v = solution["Terminal voltage [V]"].entries
    temperature_c = solution["Volume-averaged cell temperature [K]"].entries - 273.15

    label = f"{c_rate}C"
    axes[0].plot(time_min, current_a, label=label, linewidth=1.4)
    axes[1].plot(time_min, voltage_v, label=label, linewidth=1.4)
    axes[2].plot(time_min, temperature_c, label=label, linewidth=1.6)

axes[0].set_ylabel("Current [A]")
axes[1].set_ylabel("Voltage [V]")
axes[2].set_ylabel("Temperature [deg C]")
axes[2].set_xlabel("Time [min]")

for axis in axes:
    axis.grid(True)
    axis.legend()

fig.suptitle("Qualitative reproduction: CCCV C-rate temperature comparison")
fig.tight_layout()
plt.show()

for c_rate, solution in solutions.items():
    temperature_c = solution["Volume-averaged cell temperature [K]"].entries - 273.15
    time_min = solution["Time [min]"].entries
    print(
        f"{c_rate}C: peak temperature = {temperature_c.max():.2f} deg C, "
        f"final time = {time_min[-1]:.1f} min"
    )
```

The current plot should show the expected CCCV shape. During the charge step, current is initially high and then tapers during the voltage-hold stage. The 5C case should reach the voltage limit quickly and spend a larger fraction of the charge in the tapering stage. The voltage plot should climb toward `4.2 V`, then remain near that limit during CV. The temperature plot is the reproduction target. The 1C case should show a small temperature rise. The 3C case should rise more sharply. The 5C case should rise the most and remain elevated during the voltage-hold and rest periods.

There are two important ambiguities. First, PyBaMM's `Chen2020` parameter set represents a particular lithium-ion cell, not the exact cell in the Modelica paper. Second, our thermal boundary condition is PyBaMM's lumped parameterization, not their one-dimensional thermal model. Those differences mean a numerical mismatch is expected. In your lab notebook, write this clearly. A reproduction that hides mismatched assumptions is weaker than a reproduction that explains them.

### What could go wrong

The 5C case may fail for some solver/settings combinations because it is aggressive. If it fails, replace `5` with `4` and state that the reproduced comparison is 1C/3C/4C. The qualitative lesson remains.

If all three temperature curves nearly overlap, the thermal model may not be active or the current did not reach the intended C-rate. Inspect the current plot before interpreting temperature.

If the charge begins from a high SOC, the CC stage will be very short. Keep the initial discharge step so every case starts from a comparable low-SOC state.

If the voltage hold never terminates, use a less strict cutoff such as `"Hold at 4.2 V until C/10"` for a faster teaching run.

### Reflection

This reproduction exercise taught a research habit: reproduce the claim structure when exact reproduction is impossible. We matched the protocol class, compared the same independent variable, plotted the same dependent variable, and documented the assumptions that differ. That is often how simulation reproduction begins before you obtain the original code or parameters.

## Guided Walkthrough 5: CCCV Charge Under Three Ambient Temperatures

**Learning objective:** Build the chapter deliverable: a coupled electrothermal PyBaMM CCCV charge under cold, room, and warm ambient temperatures.

This is the workflow you will reuse in your own sodium-ion research. The same cell, same model, and same protocol are simulated under three thermal environments: `0 deg C`, `25 deg C`, and `45 deg C`. The protocol begins by discharging to a low voltage so the charge starts from a comparable low-SOC state. Then it charges with CCCV. We extract charge time, peak temperature, delivered capacity, and the current taper shape.

```python
import pybamm
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


def run_cccv_ambient_case(ambient_c):
    model = pybamm.lithium_ion.SPMe({"thermal": "lumped"})
    parameter_values = pybamm.ParameterValues("Chen2020")

    experiment = pybamm.Experiment(
        [
            "Discharge at 1C until 2.8 V",
            "Rest for 30 minutes",
            "Charge at 2C until 4.2 V",
            "Hold at 4.2 V until C/20",
            "Rest for 30 minutes",
        ],
        period="15 seconds",
        temperature=f"{ambient_c} oC",
    )

    simulation = pybamm.Simulation(
        model,
        parameter_values=parameter_values,
        experiment=experiment,
    )
    solution = simulation.solve()
    return solution


ambient_cases_c = [0, 25, 45]
ambient_solutions = {}

for ambient_c in ambient_cases_c:
    ambient_solutions[ambient_c] = run_cccv_ambient_case(ambient_c)
    print(f"Solved ambient case: {ambient_c} deg C")


def summarize_solution(solution, ambient_c):
    time_h = solution["Time [h]"].entries
    current_a = solution["Current [A]"].entries
    voltage_v = solution["Terminal voltage [V]"].entries
    temperature_c = solution["Volume-averaged cell temperature [K]"].entries - 273.15

    charge_mask = current_a < -0.05
    if not np.any(charge_mask):
        charge_duration_min = np.nan
        charged_capacity_ah = np.nan
    else:
        charge_time_h = time_h[charge_mask]
        charge_current_a = current_a[charge_mask]
        charge_duration_min = (charge_time_h[-1] - charge_time_h[0]) * 60.0
        charged_capacity_ah = np.trapezoid(-charge_current_a, charge_time_h)

    return {
        "ambient_c": ambient_c,
        "final_time_min": time_h[-1] * 60.0,
        "charge_duration_min": charge_duration_min,
        "charged_capacity_ah": charged_capacity_ah,
        "peak_temperature_c": float(np.max(temperature_c)),
        "temperature_rise_k": float(np.max(temperature_c) - ambient_c),
        "max_voltage_v": float(np.max(voltage_v)),
    }


summary = pd.DataFrame(
    summarize_solution(solution, ambient_c)
    for ambient_c, solution in ambient_solutions.items()
)
print(summary.to_string(index=False, float_format=lambda value: f"{value:.3f}"))

fig, axes = plt.subplots(4, 1, figsize=(9, 10), sharex=True)

for ambient_c, solution in ambient_solutions.items():
    time_min = solution["Time [min]"].entries
    current_a = solution["Current [A]"].entries
    voltage_v = solution["Terminal voltage [V]"].entries
    temperature_c = solution["Volume-averaged cell temperature [K]"].entries - 273.15
    discharge_capacity_ah = solution["Discharge capacity [A.h]"].entries

    label = f"{ambient_c} deg C ambient"
    axes[0].plot(time_min, current_a, label=label, linewidth=1.4)
    axes[1].plot(time_min, voltage_v, label=label, linewidth=1.4)
    axes[2].plot(time_min, temperature_c, label=label, linewidth=1.4)
    axes[3].plot(time_min, discharge_capacity_ah, label=label, linewidth=1.4)

axes[0].set_ylabel("Current [A]")
axes[1].set_ylabel("Voltage [V]")
axes[2].set_ylabel("Temperature [deg C]")
axes[3].set_ylabel("Discharge cap. [A h]")
axes[3].set_xlabel("Time [min]")

for axis in axes:
    axis.grid(True)
    axis.legend(fontsize=8)

fig.suptitle("Coupled electrothermal CCCV charge under three ambient temperatures")
fig.tight_layout()
plt.show()

summary.to_csv("chapter9_cccv_ambient_summary.csv", index=False)
print("Wrote chapter9_cccv_ambient_summary.csv")
```

PyBaMM uses negative current for charge in this experiment output, so the summary identifies charging with `current_a < -0.05`. That sign convention is easy to miss if you have just come from the hand model, where we used positive current for discharge and did not run a charge. The integration `np.trapezoid(-charge_current_a, charge_time_h)` computes charged ampere-hours with a positive value.

The current plot should show the same nominal CCCV protocol in all three ambient cases, but the detailed taper may differ because temperature changes internal kinetics and transport. The voltage plot should climb to `4.2 V` during charge and hold near that limit during CV. The temperature plot should be offset by ambient and should also show different rises. The cold case may exhibit stronger polarization and a different charge duration. The warm case may accept current more easily but operates closer to thermal-aging concern. The room-temperature case is the reference.

The summary table is the start of a publishable comparison. For each ambient condition, report charge duration, peak temperature, temperature rise, and charged capacity. Do not report only charge time. A faster charge that reaches a much higher temperature is not automatically better. A colder case that takes longer may still be valuable if sodium-ion chemistry avoids plating-like limits that would constrain a lithium-ion graphite anode.

### What could go wrong

If the cold case fails, reduce the charge rate from `2C` to `1.5C`. Low-temperature simulations are numerically and physically harder because resistance and transport limitations become more severe.

If the output variable `"Discharge capacity [A.h]"` looks confusing during charge, remember that PyBaMM's capacity variables are defined by convention. Use current integration when you need a protocol-specific charge capacity.

If the current sign surprises you, plot current before calculating metrics. In PyBaMM experiment outputs, charge commonly appears as negative current.

If the three ambient cases have identical temperatures except for vertical offset, you may be seeing weak thermal feedback. Increase C-rate cautiously or compare voltage and charge-duration metrics to reveal coupling.

### Reflection

This is the chapter's core deliverable. You have a repeatable electrothermal sweep with metrics and plots. The same pattern can be adapted to sodium-ion parameter sets, alternative OCV curves, different heat-transfer coefficients, or thermal constraints such as "stop charging if cell temperature exceeds `45 deg C`."

## Simulink and Simscape Thermal Modeling: A Practical Bridge

The plan for this chapter includes Simulink thermal modeling with Simscape thermal components. Because the reader profile includes basic Simulink but not Simscape Battery experience, this section is a bridge rather than a required second implementation. The conceptual model is the same as Equation (1). In Simscape language, the cell thermal mass is a `Thermal Mass` block, heat generation is an `Ideal Heat Flow Source`, and convection to ambient is a `Convective Heat Transfer` block connected to a temperature source representing the environment.

A minimal Simulink/Simscape version has five parts. First, an electrical or signal subsystem computes heat generation, usually $I^2R$ for the first model. Second, a `Simulink-PS Converter` sends that heat rate into an `Ideal Heat Flow Source`. Third, the heat source injects heat into a thermal node connected to a `Thermal Mass`. Fourth, that node loses heat through a `Convective Heat Transfer` block to an ambient temperature source. Fifth, a `Temperature Sensor` and `PS-Simulink Converter` send cell temperature back to Simulink for plotting or for resistance lookup.

For a first model, use:

| Quantity | Simscape block or parameter | Teaching value |
| --- | --- | --- |
| Heat source | `Ideal Heat Flow Source` | input `I^2 * R` |
| Thermal mass | `Thermal Mass` | `250 J/K` |
| Convection | `Convective Heat Transfer` | area `0.03 m^2`, coefficient `12 W/(m^2 K)` |
| Ambient | `Temperature Source` | `298.15 K` |
| Sensor | `Temperature Sensor` | output in kelvin |

The main misconception to avoid is treating Simscape thermal components as automatically more physical than a Python ODE. They are more convenient for block-diagram integration, especially once you have a pack, coolant loop, or controller, but the same parameters still need justification. A thermal mass block with guessed heat capacity and guessed convection coefficient is no more validated than our hand model. The advantage is composability: later you can connect cells to cooling plates, coolant channels, or pack enclosures without writing every differential equation yourself.

## Open-Ended Exercises

### Exercise 1: Heat-transfer sensitivity

Using Walkthrough 5, sweep the total heat transfer strength by changing `"Total heat transfer coefficient [W.m-2.K-1]"` in the `Chen2020` parameter set. Compare peak temperature for `h = 5`, `10`, and `20 W.m-2.K-1` at `25 deg C` ambient.

Hints: copy the `ParameterValues` object before updating it. Keep the same experiment and model. Plot all temperature curves on one axis.

### Exercise 2: Thermal cutoff protocol

Modify the CCCV ambient simulation so that charging stops if the cell temperature exceeds `40 deg C`. Compare the delivered charge capacity with and without the thermal cutoff.

Hints: PyBaMM experiment strings support voltage and current terminations directly. For a teaching implementation, you may also post-process the solution and identify the first time temperature exceeds the limit.

### Exercise 3: Sodium-ion-like OCV and low-temperature interpretation

Return to the hand lumped model in Walkthrough 1. Replace the lithium-ion-like OCV curve with a flatter sodium-ion hard-carbon-inspired curve over `20%` to `80%` SOC. Keep the same resistance at `25 deg C`, then add a simple Arrhenius-like resistance multiplier at `0 deg C`. Compare voltage sag and heat generation.

Hints: use a plateau term such as `3.05 + 0.25 * soc + 0.08 * tanh((soc - 0.15) / 0.04) + 0.10 * tanh((soc - 0.85) / 0.04)`. For cold resistance, multiply `resistance_ohm` by `1.8`.

## Worked Solutions to Open-Ended Exercises

### Solution 1: Heat-transfer sensitivity

```python
import pybamm
import matplotlib.pyplot as plt


def run_heat_transfer_case(h_value):
    model = pybamm.lithium_ion.SPMe({"thermal": "lumped"})
    params = pybamm.ParameterValues("Chen2020")
    params.update({"Total heat transfer coefficient [W.m-2.K-1]": h_value})

    experiment = pybamm.Experiment(
        [
            "Discharge at 1C until 2.8 V",
            "Rest for 30 minutes",
            "Charge at 2C until 4.2 V",
            "Hold at 4.2 V until C/20",
            "Rest for 30 minutes",
        ],
        period="20 seconds",
        temperature="25 oC",
    )

    sim = pybamm.Simulation(model, parameter_values=params, experiment=experiment)
    return sim.solve()


h_values = [5.0, 10.0, 20.0]
results = {h: run_heat_transfer_case(h) for h in h_values}

plt.figure(figsize=(8, 4.8))
for h_value, solution in results.items():
    time_min = solution["Time [min]"].entries
    temp_c = solution["Volume-averaged cell temperature [K]"].entries - 273.15
    plt.plot(time_min, temp_c, label=f"h = {h_value:g} W/m2/K", linewidth=1.6)

plt.xlabel("Time [min]")
plt.ylabel("Temperature [deg C]")
plt.title("Heat-transfer sensitivity in a lumped PyBaMM model")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.show()

for h_value, solution in results.items():
    temp_c = solution["Volume-averaged cell temperature [K]"].entries - 273.15
    print(f"h = {h_value:g}: peak temperature = {temp_c.max():.2f} deg C")
```

The correct result is a family of temperature curves with lower peaks as `h` increases. If the curves cross in strange ways, check that each simulation uses a copied or newly constructed parameter object and the same experiment.

### Solution 2: Thermal cutoff protocol

```python
base_solution = run_cccv_ambient_case(25)

time_h = base_solution["Time [h]"].entries
time_min = base_solution["Time [min]"].entries
current_a = base_solution["Current [A]"].entries
temperature_c = base_solution["Volume-averaged cell temperature [K]"].entries - 273.15

charge_mask = current_a < -0.05
charged_capacity_full_ah = np.trapezoid(-current_a[charge_mask], time_h[charge_mask])

over_limit = np.where(temperature_c > 40.0)[0]
if over_limit.size == 0:
    cutoff_index = len(time_h) - 1
    print("Temperature never exceeded 40 deg C.")
else:
    cutoff_index = over_limit[0]
    print(f"Temperature cutoff reached at {time_min[cutoff_index]:.2f} min.")

allowed = np.arange(len(time_h)) <= cutoff_index
charge_allowed = charge_mask & allowed
charged_capacity_cutoff_ah = np.trapezoid(-current_a[charge_allowed], time_h[charge_allowed])

print(f"Full protocol charged capacity: {charged_capacity_full_ah:.3f} A h")
print(f"Thermal-cutoff charged capacity: {charged_capacity_cutoff_ah:.3f} A h")

plt.figure(figsize=(8, 4.8))
plt.plot(time_min, temperature_c, linewidth=1.6)
plt.axhline(40.0, color="tab:red", linestyle="--", label="40 deg C cutoff")
plt.axvline(time_min[cutoff_index], color="0.3", linestyle=":", label="cutoff time")
plt.xlabel("Time [min]")
plt.ylabel("Temperature [deg C]")
plt.title("Post-processed thermal cutoff")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.show()
```

This is a post-processed cutoff, not a true closed-loop controller. That distinction matters. It tells you how much capacity would have been delivered before a temperature limit was crossed, but it does not rerun the model with current set to zero after the limit. A publishable controller study should implement the limit inside the experiment or an external-circuit control law.

### Solution 3: Sodium-ion-like OCV stress test

```python
def sodium_like_ocv_from_soc(soc):
    soc_clipped = np.clip(soc, 0.0, 1.0)
    return (
        2.55
        + 0.28 * soc_clipped
        + 0.08 * np.tanh((soc_clipped - 0.15) / 0.04)
        + 0.10 * np.tanh((soc_clipped - 0.85) / 0.04)
    )


def compare_li_na_voltage_heat(temperature_c):
    cold_multiplier = 1.8 if temperature_c <= 0.0 else 1.0
    soc_grid = np.linspace(0.05, 0.95, 300)
    current_a = 10.0

    li_resistance = 0.018 * cold_multiplier
    na_resistance = 0.022 * cold_multiplier

    li_voltage = ocv_from_soc(soc_grid) - current_a * li_resistance
    na_voltage = sodium_like_ocv_from_soc(soc_grid) - current_a * na_resistance

    li_heat_w = current_a**2 * li_resistance
    na_heat_w = current_a**2 * na_resistance

    return soc_grid, li_voltage, na_voltage, li_heat_w, na_heat_w


fig, axes = plt.subplots(1, 2, figsize=(10, 4.5))

for temperature_c in [25.0, 0.0]:
    soc_grid, li_v, na_v, li_heat, na_heat = compare_li_na_voltage_heat(temperature_c)
    axes[0].plot(soc_grid, li_v, label=f"Li-like {temperature_c:g} deg C")
    axes[0].plot(soc_grid, na_v, linestyle="--", label=f"Na-like {temperature_c:g} deg C")
    axes[1].bar(
        [f"Li {temperature_c:g}", f"Na {temperature_c:g}"],
        [li_heat, na_heat],
    )

axes[0].set_xlabel("SOC [-]")
axes[0].set_ylabel("Loaded voltage [V]")
axes[0].grid(True)
axes[0].legend(fontsize=8)

axes[1].set_ylabel("I^2R heat at 10 A [W]")
axes[1].grid(True, axis="y")

fig.suptitle("Teaching comparison: lithium-like and sodium-like low-temperature behavior")
fig.tight_layout()
plt.show()
```

The sodium-like OCV curve should be flatter through the middle SOC range. The cold case should show larger voltage sag and larger heat generation because resistance was increased. This is not a claim that all sodium-ion cells heat more than lithium-ion cells. It is a controlled teaching test showing how OCV shape and resistance assumptions enter voltage and heat predictions.

## Dataset Integration Notes

For thermal work, public data are less abundant than voltage-current-capacity data. Prioritize datasets that include measured temperature and enough current excitation to identify thermal dynamics. The NASA randomized battery usage datasets are useful because they include randomized current operation and reference cycles. The NASA Open Data portal points to the public dataset pages, and the Zenodo mirror records the PCoE randomized battery usage collection with DOI `10.5281/zenodo.15277374` and a CC BY 4.0 license. Always record the access date and exact resource URL in your research log because NASA legacy resource URLs have changed over time.

The key columns for this chapter are:

| Column | Unit | Meaning | Pitfall |
| --- | --- | --- | --- |
| `time_s` | s | elapsed test time | may reset per cycle |
| `current_a` | A | applied current | sign convention varies |
| `voltage_v` | V | terminal voltage | includes dynamic polarization |
| `temperature_c` | deg C | measured cell or chamber temperature | may be surface, chamber, or sensor-specific |

When adapting a lithium-ion dataset workflow to sodium-ion, the parser barely changes. The interpretation changes. Sodium-ion data may have lower nominal voltage, different OCV slope, different reversible heat, and different low-temperature resistance behavior. If no sodium-ion temperature dataset is available for your exact chemistry, use lithium-ion data only to validate the workflow and then state clearly which sodium-ion parameters are hypothetical, literature-derived, or fitted from digitized figures.

## What Changes for Sodium-Ion?

Three things change immediately for sodium-ion electrothermal simulation. First, the voltage window and OCV shape change. A sodium-ion full cell may operate around a lower nominal voltage than a lithium-ion NMC/graphite cell, and hard-carbon anodes can create broad plateau regions. That affects both voltage limits and the SOC information available to BMS algorithms.

Second, low-temperature behavior can be a genuine sodium-ion advantage, but it is not automatic. The claim depends on electrolyte, hard-carbon structure, electrode loading, and power target. In simulation terms, you need temperature-dependent resistance, diffusivity, exchange-current density, and possibly plating or sodium-metal deposition constraints if relevant. A model that merely changes the OCV curve is not enough to prove low-temperature superiority.

Third, dataset scarcity changes validation strategy. For lithium-ion, you can often find current-voltage-temperature aging datasets with dozens or hundreds of cells. For sodium-ion, you may need to combine sparse experimental data, digitized literature curves, manufacturer datasheets, and sensitivity analysis. That makes uncertainty reporting more important, not less. A sodium-ion thermal paper should show how conclusions move when heat-transfer coefficient, resistance, entropic coefficient, and ambient temperature vary across plausible ranges.

In early sodium-ion work, a defensible workflow is to build the electrothermal method on a well-documented lithium-ion parameter set, replace only the parameters you can justify for sodium-ion, and label every remaining inherited lithium-ion parameter. Then run sensitivity sweeps to identify which missing sodium-ion measurements matter most. That is a research contribution because it tells experimental collaborators what to measure next.

## Chapter Summary and Skill Checklist

- You implemented a lumped thermal energy balance from first principles.
- You connected Bernardi heat generation to $I^2R$ teaching approximations and reversible heat.
- You parsed public NASA current-voltage-temperature data and fitted effective thermal parameters.
- You turned on PyBaMM `isothermal` and `lumped` thermal options.
- You reproduced the qualitative fast-charge temperature comparison from a published CCCV study.
- You built a coupled electrothermal CCCV ambient-temperature sweep.
- You identified which parts of the workflow change for sodium-ion cells.

Commands, functions, and patterns to keep in muscle memory:

- `pybamm.lithium_ion.SPMe({"thermal": "lumped"})`
- `pybamm.Experiment([...], temperature="25 oC")`
- `solution["Volume-averaged cell temperature [K]"].entries`
- `ParameterValues("Chen2020").update({...})`
- `solve_ivp(..., method="BDF")`
- `least_squares(...)` with log-transformed positive parameters
- Plotting current, voltage, temperature, and capacity on synchronized time axes

You should now be able to:

- Explain the difference between isothermal, lumped thermal, and spatial thermal models.
- Estimate a plausible thermal time constant from mass, heat capacity, area, and heat-transfer coefficient.
- Fit a simple thermal model to measured temperature data.
- Run PyBaMM simulations with thermal coupling enabled.
- Compare CCCV charging behavior across ambient temperatures.
- State what assumptions prevent a lithium-ion thermal workflow from being a validated sodium-ion model.

## Deliverable

Your deliverable is a notebook named `chapter9_coupled_electrothermal_cccv.ipynb` and a short Markdown report named `chapter9_thermal_interpretation.md`. The notebook should run the Walkthrough 5 ambient-temperature sweep end to end, save `chapter9_cccv_ambient_summary.csv`, and generate publication-quality plots of current, voltage, cell temperature, and charged capacity. The report should answer four questions in prose:

1. Which ambient condition charged fastest, and why?
2. Which ambient condition produced the largest absolute peak temperature and the largest temperature rise?
3. Did thermal coupling visibly alter the electrical trajectory?
4. What would need to change before this workflow could support a sodium-ion fast-charge claim?

A strong partial solution is already present in Walkthrough 5. To turn it into a research deliverable, add a parameter table, write down the PyBaMM and package versions, save each figure as a `300 dpi` PNG, and include a paragraph on limitations. The limitations paragraph is not a formality. It is where you state that `Chen2020` is a lithium-ion parameter set, the model is lumped rather than spatial, the cooling coefficient is inherited from the parameter set, and sodium-ion conclusions require sodium-ion parameters.

## Further Practice and Reading

Key papers:

1. Bernardi, D., Pawlikowski, E., and Newman, J. "A General Energy Balance for Battery Systems." *Journal of The Electrochemical Society* 132, 5-12 (1985). This is the classic heat-generation reference behind Equation (3).
2. Romero, A., Goldar, A., and Garone, E. "A Model Predictive Control Application for a Constrained Fast Charge of Lithium-ion Batteries." *Proceedings of the 13th International Modelica Conference* (2019). Use Figures 5 and 6 as a protocol-comparison reproduction target.
3. Yang, X.-G., Zhang, G., Ge, S., and Wang, C.-Y. "Fast charging of lithium-ion batteries at all temperatures." *PNAS* 115, 7266-7271 (2018). Read this for the link between fast charging, temperature, and low-temperature limitations.

Official documentation worth bookmarking:

1. PyBaMM thermal models documentation: `https://docs.pybamm.org/en/v25.10.2/source/examples/notebooks/models/thermal-models.html`
2. PyBaMM experiment documentation: `https://docs.pybamm.org/`
3. NASA/Zenodo PCoE randomized battery usage dataset: `https://zenodo.org/records/15277374`

Community resources:

1. PyBaMM GitHub repository and issue tracker: `https://github.com/pybamm-team/PyBaMM`
2. PyBaMM Discourse and community links from the official documentation site
3. MATLAB Simscape Battery examples for thermal and pack modeling when you move from single-cell scripts to pack-level block diagrams

Chapter 10 is next: Bridging PyBaMM and MATLAB.

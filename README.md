
# Wastewater Rising Main Thermal Modelling & Heat-Recovery Assessment

**Discipline:** Mechanical Engineering / Energy Systems  
**Environment:** MATLAB  
**Scope:** Hydraulic Data Processing, Transient Thermal Modelling, and Parametric Sensitivity Analysis

---

## A. Project Background & Scope

###  Overview
Wastewater conveyed through underground rising mains represents a significant source of low-grade waste heat. Capturing this thermal energy depends on dynamic interactions between internal flow regimes, pipe geometry, wall material conductivity, and surrounding soil thermal properties.

###  Objectives
This study establishes a MATLAB-based analytical framework to:
1. **Filter & Process Data:** Screen hydraulic and thermal telemetry from field measurements.
2. **Model Heat Transfer:** Compute internal convective coefficients and 1D radial thermal resistance networks.
3. **Simulate Axial Profiles:** Discretize pipe reaches to predict dynamic fluid temperature drop ($\Delta T$) and total thermal dissipation ($\dot Q$).
4. **Evaluate Seasonal Limits:** Model heat loss across defined winter ($9^\circ\text{C}$) and summer ($13^\circ\text{C}$) ground boundary conditions.
5. **Conduct Sensitivity Analysis:** Assess grid convergence (segment resolution), flow dynamics ($Q$), and soil conductivity ($k_s$).
6. **Quantify Recovery Potential:** Estimate theoretical usable thermal power under target temperature drop scenarios.

---

## B. System Specifications & Heat Transfer Physics

###  Pipe System Parameters
Three rising main (RM) configurations are evaluated:

| Reach Model | Length $L$ (m) | Internal Diameter $D$ (m) | Material | Thermal Conductivity $k_p$ (W/m·K) | Wall Thickness $t$ (m) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **RM1** | 1,730 | 0.150 | PVC | 0.19 | 0.015 |
| **RM2** | 3,303 | 0.600 | Cast Iron | 52.00 | 0.015 |
| **RM3** | 2,927 | 0.500 | Assumed | 1.00 | 0.015 |

###  Thermal Resistance Network
Heat transfer from the bulk fluid to the far-field soil boundary is modeled using a three-stage cylindrical thermal resistance network in series:
[ Bulk Fluid ] ---> R_conv ---> [ Pipe Wall ] ---> R_pipe ---> [ Soil Matrix ] ---> R_soil ---> [ Ground Boundary ]

$$R_{\text{total}} = R_{\text{conv}} + R_{\text{pipe}} + R_{\text{soil}} = \frac{1}{2 \pi r_i L \, h_i} + \frac{\ln(r_o / r_i)}{2 \pi k_p L} + \frac{\ln(r_s / r_o)}{2 \pi k_s L}$$

Where:
* $r_i, r_o$ = internal and external pipe radii ($m$).
* $r_s$ = effective thermal influence boundary radius in soil ($m$).
* $k_s$ = soil thermal conductivity (Base case: $1.5\text{ W/m}\cdot\text{K}$; parametric range covers dry/wet sand, clay, gravel, limestone).

---

## C. Data Screening & Internal Convection

###  Hydraulic Pre-processing
To ensure valid thermal modeling under full-pipe/pressurized conditions, raw hydraulic observations are screened via two primary filters:
1. **Filling Threshold:** Depth-to-diameter ratio $d/D \geq 0.90$. *(Note: A Preissmann slot approximation is applied for $d/D \ge 1.0$ to account for surcharge conditions without full transient pressure modeling).*
2. **High-Flow Selection:** 90th percentile flow rate ($Q_{90}$) filtering to isolate representative high-convective operating periods.

###  Hydro-Thermal Correlations
The internal convective heat transfer coefficient ($h_i$) is calculated dynamically across flow regimes:

$$\begin{aligned}
 Re &= \frac{\rho \, v \, D}{\mu} \\[1ex]
 Nu &= f(Re, Pr) \quad \left[\text{Turbulent correlation applied for } Re \ge 2300\right] \\[1ex]
 h_i &= \frac{Nu \cdot k_w}{D}
\end{aligned}$$

---

## D. Numerical Discretization & Energy Balance

###  Segmental Marching Method
Each reach is discretized into $N$ equal segments along its axial length ($N_{\text{baseline}} = 200$). For each spatial segment $j$, steady-state energy conservation yields:

$$\dot Q_j = \frac{T_{w,j} - T_{\text{ground}}}{R_{\text{total}, j}}$$

$$\Delta T_j = \frac{\dot Q_j}{\dot m \, c_p}$$

$$T_{w, j+1} = T_{w, j} - \Delta T_j$$

Where $\dot m = \rho Q$ is the fluid mass flow rate and $c_p$ is the specific heat capacity of wastewater.

###  Sensitivity Analysis Framework
* **Grid Independence:** Evaluated across $N \in \{25, 50, 100, 200, 500, 1000\}$ to verify spatial convergence.
* **Flow Rate Sweep:** Evaluated across $0.02 \le Q \le 0.25\text{ m}^3/\text{s}$.
* **Soil Matrix Variation:** Parametric study across 7 distinct geological profiles.

---

## E. Theoretical Energy Recovery Model

Recoverable thermal power ($\dot Q_{\text{useful}}$) for target fluid temperature drops ($\Delta T_{\text{target}} \in \{0.25^\circ\text{C}, 0.50^\circ\text{C}, 1.00^\circ\text{C}, 2.00^\circ\text{C}\}$) is defined as:

$$\dot Q_{\text{available}} = \dot m \, c_p \, \Delta T_{\text{target}}$$

$$\dot Q_{\text{useful}} = \eta_{\text{utilization}} \cdot \dot Q_{\text{available}}$$

A baseline utilization factor $\eta_{\text{utilization}} = 0.70$ is applied as a conservative operational ceiling. 

> **Engineering Note:** $\eta_{\text{utilization}}$ accounts for operational downtime and system boundary losses. It is not an assertion of heat exchanger thermal effectiveness or heat pump Coefficient of Performance (COP), which require dedicated secondary-loop modeling.

---

## F. Seasonal Heat-Loss Results & Discussion

This section presents the thermal performance, heat-loss rates, and temperature drops across reach models **RM1**, **RM2**, and **RM3** over continuous 48-hour summer and winter simulation scenarios.

###  Summary of Seasonal Heat-Loss Metrics

| Reach Model | Winter Heat Loss Rate (kW) | Summer Heat Loss Rate (kW) | Avg. Winter Temp Drop (°C) | Avg. Summer Temp Drop (°C) | Valid Observations ($N$) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **RM1** | *N/A (No model output)* | *N/A (No model output)* | *N/A (No model output)* | *N/A (No model output)* | 0 |
| **RM2** | **32.27 – 36.26** | **86.72 – 89.59** | **0.0379 – 0.0425** | **0.1018 – 0.1051** | **4** |
| **RM3** | *N/A (No model output)* | *N/A (No model output)* | *N/A (No model output)* | *N/A (No model output)* | 0 |

---

###  Model Visualizations & Comparative Analysis

<p align="center">
 <img width="702" height="442" alt="Summer Heat Loss Comparison" src="https://github.com/user-attachments/assets/134d3b8c-e095-420e-9fa6-3e8692424047" />

  <br>
  <em>Figure 1: Modelled summer heat-loss rate comparison across reach models (RM1, RM2, RM3).</em>
</p>

<p align="center">

 <img width="704" height="444" alt="Winter Heat Loss Comparison" src="https://github.com/user-attachments/assets/b8604639-49c4-404e-a40c-98cc703b185c" />
<br>
  <em>Figure 2: Modelled winter heat-loss rate comparison across reach models (RM1, RM2, RM3).</em>
</p>

#### 1. Reach Model Execution Status (RM1 vs. RM2 vs. RM3)
* **RM2 Functional Validation:** Model **RM2** is the only formulation that produced valid, non-zero output streams for outlet temperature, reach temperature drop, and total heat loss.
* **RM1 and RM3 Null Outputs:** Inspection of the temperature profile plots confirms that the modelled outlet temperature data series for **RM1** and **RM3** are absent, yielding zero valid observations for thermal calculation.

#### 2. Heat-Loss Rate Dynamics (RM2)
* **Summer Operations:** The heat-loss rate ranges from **86.72 kW to 89.59 kW**. The elevated summer heat dissipation is primarily driven by higher wastewater inlet temperatures (**16.25 °C to 18.55 °C**), which increase the thermal gradient relative to internal reach boundaries.
* **Winter Operations:** The heat-loss rate ranges from **32.27 kW to 36.26 kW**. Lower baseline inlet fluid temperatures (**9.90 °C to 11.30 °C**) result in lower absolute thermal dissipation along the reach length.

<p align="center">
 <img width="710" height="443" alt="summer temperature drop" src="https://github.com/user-attachments/assets/d9ed541f-55af-41f3-af26-69cf41aa62b1" />

  <br>
  <em>Figure 3: Modelled summer temperature drop (ΔT) along reach length.</em>
</p>

<p align="center">
 <img width="710" height="445" alt="winter temperature drop" src="https://github.com/user-attachments/assets/d172f856-2a67-43a1-a86a-cef9042a1d94" />
  <br>
  <em>Figure 4: Modelled winter temperature drop (ΔT) along reach length.</em>
</p>

#### 3. Wastewater Temperature Drop ($\Delta T$)
* Across both seasonal evaluations, localized fluid cooling per unit length remains minimal:
  * **Summer $\Delta T$:** **0.1018 °C to 0.1051 °C**
  * **Winter $\Delta T$:** **0.0379 °C to 0.0425 °C**
* **Thermal Mass Significance:** High wastewater flow volume cushions the stream against rapid thermal degradation, even while dissipating up to **89.59 kW** of total heat energy to surrounding boundaries.

<p align="center">
<img width="758" height="344" alt="RM2 summer " src="https://github.com/user-attachments/assets/b6c1a541-569e-4293-87dc-71f8b1860589" />

 <br>
  <em>Figure 5: RM2 Summer inlet vs. modelled outlet temperature over a 48-hour simulation.</em>
</p>

<p align="center">
<img width="763" height="347" alt="RM2 Winter" src="https://github.com/user-attachments/assets/0b402c6f-5553-4b03-9ff2-a45dd0f023d5" />

 <br>
  <em>Figure 6: RM2 Winter inlet vs. modelled outlet temperature over a 48-hour simulation.</em>
</p>

#### 4. Sampling Windows & Diurnal Response
* **Observation Structure:** Quantitative heat loss and temperature drop outputs for **RM2** were captured across $N = 4$ discrete 1-hour observation windows centered at $t = [18, 19]\text{ h}$ and $t = [42, 43]\text{ h}$ across the 48-hour run period.
* **Diurnal Tracking:** Modelled outlet temperature closely mirrors the incoming diurnal boundary curve across both 24-hour cycles, verifying numerical stability under dynamic inlet flow conditions.

---

## G. Key Modeling Assumptions & Future Scope


| ASSUMPTIONS & LIMITATIONS                                                        |
|:--------------------------------------------------------------------------------:|
| • 1D radial steady-state heat conduction (transient ground storage omitted).     |
| • Uniform pipe-wall thickness (0.015 m nominal across all mains).                 |
| • Constant soil boundary temperatures (Winter: 9°C, Summer: 13°C).                |
| • Temperature-independent wastewater thermophysical properties.                   |


| FUTURE DEVELOPMENT PATHWAY                                                        |
|:---------------------------------------------------------------------------------:|
| 1. Field Validation: Integrate in-situ ground temperature & conductivity probes.  |
| 2. Advanced Hydraulics: Integrate 1D unsteady pressurized flow solvers.          |
| 3. System Integration: Model HEX fouling factors, heat pump COP, and parasitic    |
|    pumping loads against local building heat demand curves.                        |



---

## H. Data Confidentiality & Reproducibility

The source code ingests raw hydraulic and thermal telemetry via external spreadsheet bindings. Confidential telemetry is excluded from public source control. The analytical workflow can be reproduced by executing the core MATLAB script paired with any standard-compliant dataset matching the required schemas.

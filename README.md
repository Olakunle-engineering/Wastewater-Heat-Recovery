# Wastewater Rising Main Thermal Modelling and Heat-Recovery Assessment

**Project discipline:** Mechanical Engineering | Thermal Systems | Sustainable Energy  
**Modelling environment:** MATLAB  
**Project type:** Engineering analysis and numerical modelling

---

## 1. Project Overview

### 1.1 Background

Wastewater transported through urban sewer networks retains thermal energy originating from domestic, commercial and industrial activities. During transportation, a proportion of this energy may be transferred through the pipeline wall into the surrounding ground.

Wastewater infrastructure therefore represents a potential source of low-grade thermal energy that could contribute towards sustainable heating and low-carbon energy systems.

This project develops a MATLAB-based thermal modelling framework to investigate heat transfer from wastewater flowing through buried pressurised rising mains.

The model combines hydraulic operating data, wastewater temperature measurements, pipe geometry, material properties and assumed soil thermal conditions to estimate wastewater temperature changes and natural thermal dissipation.

A separate theoretical heat-extraction assessment investigates the relationship between wastewater flow rate, assumed extraction temperature reduction and potential useful thermal power.

### 1.2 Project Aim

To develop and apply a numerical thermal model for assessing heat transfer and theoretical heat-recovery potential in urban wastewater rising mains under different hydraulic, material and seasonal conditions.

### 1.3 Engineering Scope

The investigation comprises:

- Hydraulic data processing and operating-condition screening.
- Internal convective heat-transfer estimation.
- Cylindrical thermal resistance modelling.
- Axial wastewater temperature-profile prediction.
- Seasonal heat-loss assessment.
- Numerical segmentation sensitivity analysis.
- Flow-rate and theoretical heat-extraction assessment.
- Soil thermal conductivity sensitivity analysis.

---

## 2. Engineering System Description

### 2.1 Rising Main Configurations

The model considers three buried wastewater rising mains with different geometries and pipe materials.

| Parameter | RM1 | RM2 | RM3 |
|---|---:|---:|---:|
| Pipeline length (m) | 1,730 | 3,303 | 2,927 |
| Internal diameter (mm) | 150 | 600 | 500 |
| Pipe material | PVC | Cast iron | Unknown |
| Thermal conductivity (W/m·K) | 0.19 | 52 | 1.0* |

*The thermal conductivity assigned to RM3 is an assumed value because the pipe material is unidentified.*

### 2.2 Physical Heat-Transfer Mechanism

The model represents heat transfer from the wastewater to the surrounding ground through three consecutive mechanisms:

1. Internal convection between the wastewater and the pipe's internal surface.
2. Conduction through the pipe wall.
3. Conduction through the surrounding soil.

The combined thermal resistance determines the heat-transfer rate for a given temperature difference between the wastewater and the surrounding ground.

---

## 3. Input Parameters and Boundary Conditions

### 3.1 Hydraulic and Temperature Data

The MATLAB script imports measurements from a locally selected Excel workbook.

The hydraulic dataset includes:

- Measurement timestamps.
- Volumetric flow rate.
- Wastewater velocity.
- Wastewater depth.

The temperature dataset provides seasonal wastewater inlet temperatures for winter and summer analysis.

The imported measurements are checked for consistency and aligned using their corresponding timestamps before thermal calculations are performed.

### 3.2 Pipe and Material Parameters

| Parameter | Symbol | Model value |
|---|---|---:|
| Pipe wall thickness | \(t_p\) | 0.015 m |
| PVC conductivity | \(k_p\) | 0.19 W/m·K |
| Cast iron conductivity | \(k_p\) | 52 W/m·K |
| Assumed RM3 conductivity | \(k_p\) | 1.0 W/m·K |
| Soil reference radius | \(r_s\) | 2.0 m |

### 3.3 Wastewater Thermophysical Properties

Wastewater is approximated using constant water properties.

| Property | Symbol | Value | Unit |
|---|---|---:|---|
| Density | \(\rho\) | 1,000 | kg/m³ |
| Specific heat capacity | \(c_p\) | 4,180 | J/kg·K |
| Dynamic viscosity | \(\mu\) | 0.001 | Pa·s |
| Thermal conductivity | \(k_w\) | 0.60 | W/m·K |
| Prandtl number | \(Pr\) | 7 | – |

### 3.4 Seasonal Boundary Conditions

| Condition | Assumed soil temperature |
|---|---:|
| Winter | 9°C |
| Summer | 13°C |

The soil thermal conductivity baseline is 1.5 W/m·K.

Alternative soil conductivity values are investigated separately through sensitivity analysis.

---

## 4. Engineering Methodology

### 4.1 Hydraulic Data Processing and Validation

The hydraulic measurements are screened before being passed into the thermal model.

The depth-to-diameter ratio is calculated as:

\[
\frac{d}{D}
\]

Where:

- \(d\) = wastewater depth (m).
- \(D\) = internal pipe diameter (m).

The model applies a minimum depth ratio of:

\[
\frac{d}{D}\geq0.90
\]

This identifies near-full, full and potentially surcharged operating conditions.

A simplified Preissmann-slot interpretation permits depth ratios greater than 1.0 to remain in the analysis. The model retains these ratios but does not implement a separate pressure-head hydraulic solution.

A high-flow selection threshold is also applied using the 90th percentile of qualifying flow measurements:

\[
Q_{90}=P_{90}(Q_{\mathrm{candidate}})
\]

The hydraulic screening process also checks for positive and finite measurements, matching timestamps and consistent data lengths.

### 4.2 Internal Convective Heat Transfer

The internal convective heat-transfer coefficient is estimated using the Reynolds number and Nusselt number.

The Reynolds number is:

\[
Re=\frac{\rho vD}{\mu}
\]

The model uses a simplified flow-regime distinction.

For laminar flow:

\[
Nu=3.66 \qquad Re<2300
\]

For turbulent flow:

\[
Nu=0.023Re^{0.8}Pr^{0.4}
\qquad Re\geq2300
\]

The internal heat-transfer coefficient is then calculated as:

\[
h_i=\frac{Nu\,k_w}{D}
\]

This coefficient represents convective heat transfer between the moving wastewater and the internal pipe surface.

### 4.3 Cylindrical Thermal Resistance Model

The model represents radial heat transfer using three thermal resistances in series.

The internal and external pipe radii are:

\[
r_i=\frac{D}{2}
\]

\[
r_o=r_i+t_p
\]

The individual resistances per unit pipe length are:

**Internal convection:**

\[
R'_{\mathrm{conv}}=
\frac{1}{2\pi r_i h_i}
\]

**Pipe-wall conduction:**

\[
R'_{\mathrm{pipe}}=
\frac{\ln(r_o/r_i)}{2\pi k_p}
\]

**Soil conduction:**

\[
R'_{\mathrm{soil}}=
\frac{\ln(r_s/r_o)}{2\pi k_s}
\]

The total thermal resistance is:

\[
R'_{\mathrm{total}}=
R'_{\mathrm{conv}}+
R'_{\mathrm{pipe}}+
R'_{\mathrm{soil}}
\]

Where \(k_s\) represents soil thermal conductivity.

The resulting resistance is expressed in K·m/W.

### 4.4 Axial Temperature-Profile Modelling

Each rising main is divided into smaller computational segments.

The main model uses 200 segments, with the segment length determined by:

\[
\Delta x=\frac{L}{N}
\]

At each segment, the heat-transfer rate per unit length is calculated using:

\[
q'_j=\frac{T_j-T_s}{R'_{\mathrm{total}}}
\]

The heat-transfer rate across an individual segment is:

\[
\dot Q_j=q'_j\Delta x
\]

The wastewater mass flow rate is:

\[
\dot m=\rho Q
\]

Using a steady-flow energy balance, the temperature reduction across each segment is:

\[
\Delta T_j=
\frac{\dot Q_j}{\dot m c_p}
\]

The outlet temperature from each segment becomes the inlet temperature for the next segment:

\[
T_{j+1}=T_j-\Delta T_j
\]

This calculation is repeated along the full pipeline to estimate the final wastewater outlet temperature.

The procedure is performed independently for winter and summer boundary conditions.

### 4.5 Seasonal Heat-Loss Assessment

The predicted overall wastewater temperature reduction is:

\[
\Delta T_{\mathrm{pipe}}=
T_{\mathrm{in}}-T_{\mathrm{out}}
\]

The corresponding natural thermal dissipation rate is:

\[
\dot Q_{\mathrm{loss}}=
\dot m c_p\Delta T_{\mathrm{pipe}}
\]

Or:

\[
\dot Q_{\mathrm{loss}}=
\rho Qc_p\Delta T_{\mathrm{pipe}}
\]

The calculated value is converted from watts to kilowatts for reporting.

The model produces seasonal estimates of:

- Average temperature reduction.
- Maximum temperature reduction.
- Average thermal dissipation rate.
- Maximum thermal dissipation rate.
- Estimated accumulated thermal energy.

---

## 5. Numerical and Sensitivity Analysis

### 5.1 Numerical Segmentation Sensitivity

The model evaluates alternative axial discretisations to investigate the effect of segment size on predicted wastewater outlet temperature.

| Number of segments | Element length |
|---:|---:|
| 25 | \(L/25\) |
| 50 | \(L/50\) |
| 100 | \(L/100\) |
| 200 | \(L/200\) |
| 500 | \(L/500\) |
| 1,000 | \(L/1000\) |

The comparison assesses whether further refinement produces meaningful changes in predicted temperature reduction.

### 5.2 Flow-Rate and Heat-Extraction Assessment

A separate theoretical heat-extraction calculation investigates the thermal power associated with an assumed wastewater temperature reduction.

The wastewater-side theoretical thermal power is:

\[
\dot Q_{\mathrm{theoretical}}=
\rho Qc_p\Delta T_{\mathrm{extract}}
\]

The model applies an assumed recovery factor of 70%:

\[
\dot Q_{\mathrm{useful}}=
0.70\dot Q_{\mathrm{theoretical}}
\]

The following extraction temperature reductions are assessed:

- 0.25°C
- 0.50°C
- 1.00°C
- 2.00°C

A parametric flow-rate sweep is conducted between:

\[
0.02\leq Q\leq0.25\ \mathrm{m^3/s}
\]

This analysis is used to investigate the theoretical relationship between flow rate, assumed extraction temperature reduction and useful thermal power.

The 70% factor is an assumed modelling parameter and does not represent measured heat-exchanger performance or a heat-pump coefficient of performance.

### 5.3 Soil Thermal Conductivity Sensitivity

The influence of soil thermal conductivity on thermal performance is investigated using seven assumed soil conditions.

| Soil condition | Thermal conductivity (W/m·K) |
|---|---:|
| Dry sand | 0.560 |
| Moist/wet sand | 0.955 |
| Soaked sand | 2.160 |
| Dry clay | 0.435 |
| Wet clay | 1.300 |
| Sandy gravel | 2.510 |
| Limestone | 1.300 |

The sensitivity analysis focuses on RM2 and retains the same pipe geometry and qualifying hydraulic operating records for each soil case.

The outputs include changes in predicted temperature reduction, outlet temperature, heat-loss rate and estimated thermal energy dissipation.

---

## 6. Model Outputs and Visualisation

The MATLAB model generates graphical and numerical outputs to support interpretation of the thermal behaviour.

| Output | Engineering application |
|---|---|
| Hydraulic depth-ratio assessment | Operating-condition screening |
| Inlet and outlet temperature plots | Seasonal thermal comparison |
| Axial temperature profiles | Temperature variation along the pipeline |
| Heat-loss plots | Assessment of natural thermal dissipation |
| Segmentation sensitivity plots | Numerical refinement assessment |
| Flow-rate extraction plots | Theoretical heat-recovery assessment |
| Soil sensitivity plots | Investigation of ground-property uncertainty |
| Summary tables | Consolidation of hydraulic and thermal results |

The script also generates Excel output tables containing model summaries, sensitivity results and supporting numerical data.

---

## 7. Software and Engineering Techniques

**Primary modelling environment:** MATLAB

**Engineering methods and competencies demonstrated:**

- Thermal systems modelling.
- Convective heat-transfer analysis.
- Cylindrical thermal resistance calculations.
- Hydraulic data interpretation.
- Steady-flow energy balances.
- Numerical segmentation.
- Parametric modelling.
- Sensitivity analysis.
- Engineering data processing and visualisation.
- Technical interpretation of low-carbon energy opportunities.

---

## 8. Engineering Assumptions and Limitations

The model provides a simplified numerical assessment and is subject to several assumptions.

### 8.1 Thermal and Material Assumptions

- Wastewater is represented using constant water properties.
- Soil boundary temperatures are fixed for each seasonal scenario.
- Soil conductivity is assumed uniform within each simulation.
- The unidentified RM3 pipe material is assigned an assumed conductivity.
- Soil temperature variation with depth and time is not explicitly modelled.

### 8.2 Hydraulic and Numerical Assumptions

- Hydraulic operating conditions are treated as constant within each modelled time record.
- The depth-ratio threshold is used as an operating-condition screening criterion.
- The Preissmann-slot treatment does not independently calculate pressure head.
- Internal convection correlations are applied using a simplified Reynolds-number switching threshold.
- The axial thermal model uses a fixed resistance within each individual pipe simulation.
- The main discretisation uses 200 segments and is assessed through a separate sensitivity investigation.

### 8.3 Heat-Recovery Assumptions

- The theoretical extraction assessment uses prescribed wastewater temperature reductions.
- A 70% recovery factor is assumed.
- Heat-exchanger design, fouling, heat-pump performance and auxiliary energy consumption are not explicitly simulated.
- Economic feasibility and installation constraints are outside the current model scope.

The accumulated thermal energy calculations also require attention where the source timestamps are irregular, because the current implementation uses a median time interval.

Further validation against measured outlet temperatures and site-specific ground conditions would improve confidence in the predictions.

---

## 9. Data Confidentiality and Reproducibility

The original hydraulic and temperature dataset is confidential and is not distributed with this repository.

The MATLAB script requests the input workbook locally at runtime. Users wishing to reproduce the analysis must provide their own appropriately structured dataset.

The original source workbook and generated output workbook must remain in approved secure storage and must not be uploaded without authorisation.

The published repository is intended to demonstrate the modelling methodology, engineering calculations and software implementation without disclosing confidential operational measurements.

---

## 10. Engineering Significance and Further Development

This project demonstrates the application of mechanical engineering principles to the investigation of low-carbon thermal energy opportunities within existing wastewater infrastructure.

The modelling framework provides a basis for understanding how hydraulic conditions, pipe materials, soil properties and seasonal temperatures influence wastewater thermal behaviour.

Potential further development includes:

1. Validation against measured outlet temperatures.
2. Site-specific investigation of soil thermal properties.
3. Improved representation of transient ground-temperature behaviour.
4. Assessment of alternative internal convection correlations.
5. Improved integration using individual timestamp intervals.
6. Detailed heat-exchanger and heat-pump system modelling.
7. Assessment of pumping energy and net useful thermal output.
8. Techno-economic and carbon-emissions assessment.

The longer-term objective is to develop the model towards a more comprehensive engineering assessment of wastewater heat recovery as a potential contributor to sustainable urban energy systems.

---

## 11. Repository Structure

```text
Wastewater-Heat-Recovery/
│
├── README.md
│
├── .gitignore
│
├── MATLAB/
│   └── main_thermal_model.m
│
├── Results/
│
├── Figures/
│
└── Documentation/
    └── methodology.md
```

*The repository structure may be extended as validated figures, technical documentation and non-confidential outputs become available.*

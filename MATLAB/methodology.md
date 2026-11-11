# Engineering Methodology
## Wastewater Rising Main Thermal Modelling and Heat-Recovery Assessment

**Project discipline:** Mechanical Engineering / Energy Systems  
**Modelling environment:** MATLAB  
**Analysis type:** Hydraulic data processing, thermal modelling and sensitivity analysis  
**Document:** Technical Methodology

---

## 1. Introduction

### 1.1. Background

Wastewater flowing through underground rising mains contains thermal energy that may offer an opportunity for heat recovery. However, the amount of recoverable energy depends on several interacting factors, including flow conditions, pipe geometry, pipe-wall material, surrounding soil properties and wastewater temperature.

This project develops a MATLAB-based thermal model to investigate heat transfer between wastewater flowing through selected rising mains and the surrounding ground.

### 1.2. Aim

The aim is to assess the thermal behaviour of selected wastewater rising mains and estimate their potential for heat recovery under defined operating and environmental conditions.

### 1.3. Objectives

The modelling objectives are to:

a. Process hydraulic and temperature measurements from the supplied dataset.
b. Define the physical and thermal properties of the selected pipe systems.
c. Screen hydraulic operating conditions for thermal analysis.
d. Estimate internal convective heat transfer and external thermal resistance.
e. Calculate wastewater temperature variation along each pipe.
f. Estimate seasonal heat dissipation under winter and summer boundary conditions.
g. Investigate numerical discretisation and flow-rate sensitivity.
h. Evaluate theoretical heat extraction under selected temperature-drop assumptions.
i. Assess the influence of surrounding soil thermal conductivity.

---

## 2. Engineering System Description

### 2.1. Pipe configurations

The model considers three wastewater rising mains with different pipe dimensions and materials.

| Rising main | Length (m) | Internal diameter (m) | Pipe material |
|---|---:|---:|---|
| RM1 | 1,730 | 0.150 | PVC |
| RM2 | 3,303 | 0.600 | Cast iron |
| RM3 | 2,927 | 0.500 | Unknown / assumed |

The pipe configurations are used to investigate how differences in geometry and material properties influence thermal resistance and heat transfer.

### 2.2. Physical heat-transfer mechanism

The model represents heat transfer from the wastewater to the surrounding ground through three principal mechanisms:

a. **Internal convection:** Heat transfer between the flowing wastewater and the internal pipe wall.
b. **Conduction through the pipe wall:** Heat transfer through the pipe material.
c. **Conduction into the surrounding soil:** Heat transfer through the external ground surrounding the pipe.

The overall thermal behaviour is represented using a series thermal-resistance approach.

---

## 3. Input Data and Pre-processing

### 3.1. Data sources

The MATLAB model imports hydraulic and temperature measurements from an external Excel workbook.

The original dataset is treated as confidential and is not included in the public GitHub repository.

### 3.2. Hydraulic data processing

Hydraulic measurements are imported and processed to obtain the operating parameters required by the thermal model.

The processing includes:

- Importing flow and depth measurements.
- Checking data availability and validity.
- Converting depth measurements where required.
- Calculating the depth-to-diameter ratio.
- Screening operating conditions against the selected hydraulic criteria.
- Identifying representative high-flow conditions.

### 3.3. Temperature data processing

Temperature measurements are imported separately and prepared for seasonal thermal analysis.

The model uses the available temperature observations to establish wastewater temperature conditions and assess temperature variation under the selected seasonal scenarios.

### 3.4. Data screening

Data screening is applied before thermal calculations to reduce the influence of unsuitable or incomplete observations.

The model uses a minimum depth-to-diameter ratio of:

\[
\frac{d}{D} \geq 0.90
\]

where:

- \(d\) = measured wastewater depth
- \(D\) = internal pipe diameter

A 90th-percentile flow criterion is also used to identify representative high-flow operating conditions.

These criteria are modelling choices and should not be interpreted as a complete hydraulic assessment of the rising mains.

---

## 4. Hydraulic Operating Conditions

### 4.1. Depth-to-diameter ratio

The depth-to-diameter ratio is calculated as:

\[
\frac{d}{D}
\]

This ratio is used to screen the hydraulic measurements and identify observations meeting the selected depth threshold.

### 4.2. Preissmann slot interpretation

The model includes a Preissmann-slot-related depth treatment that permits calculated depth-to-diameter ratios greater than one.

This is intended to accommodate the treatment of pressurised or full-pipe conditions within the data-processing approach.

**Limitation:** This treatment does not constitute a complete pressure-flow hydraulic model. It does not independently calculate pressure head, transient pressure behaviour or a fully defined slot geometry.

### 4.3. High-flow selection

The 90th percentile of the available flow measurements is used as a high-flow screening criterion.

This provides a representative operating condition for selected thermal calculations without relying exclusively on the maximum recorded flow.

---

## 5. Thermophysical Properties and Boundary Conditions

### 5.1. Pipe properties

The model assigns thermal conductivity values to the pipe materials.

| Pipe material | Thermal conductivity (W/m·K) |
|---|---:|
| PVC | 0.19 |
| Cast iron | 52 |
| Unknown material assumption | 1.0 |

A nominal pipe-wall thickness of 0.015 m is used in the thermal-resistance calculations.

Where the material is unknown, the assigned conductivity is an assumption rather than a measured material property.

### 5.2. Soil properties

A base-case soil thermal conductivity of:

\[
k_s = 1.5 \text{ W/m·K}
\]

is used.

Additional soil conditions are investigated through sensitivity analysis, including assumed sand, clay, gravel and limestone cases, with wet and dry conditions where represented in the model.

These values are scenario assumptions and should ideally be replaced with site-specific ground investigation data.

### 5.3. Seasonal boundary conditions

Two seasonal ground-temperature scenarios are considered:

| Scenario | Ground temperature |
|---|---:|
| Winter | 9°C |
| Summer | 13°C |

These temperatures are applied as external thermal boundary conditions to investigate seasonal differences in heat transfer.

### 5.4. Wastewater properties

The model uses assumed or specified wastewater thermophysical properties for the internal heat-transfer calculations.

These properties are treated as representative values within the model rather than a complete characterisation of wastewater composition or temperature-dependent behaviour.

---

## 6. Internal Convective Heat Transfer

### 6.1. Reynolds number

The Reynolds number is used to characterise the internal flow regime.

\[
Re = \frac{\rho v D}{\mu}
\]

Where:

- \(\rho\) = wastewater density (kg/m³)
- \(v\) = mean flow velocity (m/s)
- \(D\) = internal pipe diameter (m)
- \(\mu\) = dynamic viscosity (Pa·s)

### 6.2. Nusselt number

The Nusselt number is used to estimate the strength of convective heat transfer relative to conduction within the fluid.

The model applies a flow-regime-dependent correlation, with a turbulent-flow correlation activated at:

\[
Re \geq 2300
\]

The selected correlation is used to estimate the convective heat-transfer coefficient.

### 6.3. Convective heat-transfer coefficient

The internal convective heat-transfer coefficient is calculated from:

\[
h_i = \frac{Nu \, k_w}{D}
\]

Where:

- \(h_i\) = internal convective heat-transfer coefficient (W/m²·K)
- \(Nu\) = Nusselt number
- \(k_w\) = thermal conductivity of wastewater (W/m·K)
- \(D\) = internal pipe diameter (m)

The resulting coefficient is used in the internal convective thermal resistance.

**Engineering consideration:** The transition between laminar and turbulent flow requires careful treatment. The selected correlation and its validity should be reviewed when applying the model to different operating conditions.

---

## 7. Thermal Resistance Model

### 7.1. Overall thermal resistance

Heat transfer is represented using three thermal resistances in series:

\[
R_{\text{total}} =
R_{\text{convection}} +
R_{\text{pipe}} +
R_{\text{soil}}
\]

The individual resistances represent:

- Internal convection between wastewater and pipe wall.
- Conduction through the pipe wall.
- Conduction through the surrounding soil.

### 7.2. Internal convective resistance

For a cylindrical pipe:

\[
R_{\text{convection}} =
\frac{1}{h_i 2\pi r_i L}
\]

### 7.3. Pipe-wall conduction resistance

\[
R_{\text{pipe}} =
\frac{\ln(r_o/r_i)}
{2\pi k_p L}
\]

Where:

- \(r_i\) = internal pipe radius (m)
- \(r_o\) = external pipe radius (m)
- \(k_p\) = pipe thermal conductivity (W/m·K)
- \(L\) = pipe length considered (m)

### 7.4. Soil conduction resistance

The soil resistance is represented using a cylindrical conduction approximation:

\[
R_{\text{soil}} =
\frac{\ln(r_s/r_o)}
{2\pi k_s L}
\]

Where:

- \(r_s\) = effective external soil radius (m)
- \(k_s\) = soil thermal conductivity (W/m·K)

The effective soil radius is a modelling approximation used to represent heat conduction into the surrounding ground.

### 7.5. Overall heat-transfer rate

The heat-transfer rate is estimated from the temperature difference across the overall thermal resistance:

\[
\dot Q =
\frac{\Delta T}{R_{\text{total}}}
\]

Where:

- \(\dot Q\) = heat-transfer rate (W)
- \(\Delta T\) = temperature difference between wastewater and surrounding ground (K)

The model uses this relationship to estimate thermal dissipation along the pipe.

---

## 8. Axial Temperature Profile

### 8.1. Pipe segmentation

The pipe is divided into a series of numerical segments to estimate the variation in wastewater temperature along its length.

The main calculation uses 200 segments.

Each segment is assigned a representative length and thermal resistance, allowing the model to calculate the temperature change progressively along the pipe.

### 8.2. Segment energy balance

The temperature change is evaluated using an energy balance:

\[
\dot Q = \dot m c_p \Delta T
\]

Rearranging:

\[
\Delta T =
\frac{\dot Q}{\dot m c_p}
\]

Where:

- \(\dot m\) = wastewater mass-flow rate (kg/s)
- \(c_p\) = specific heat capacity (J/kg·K)
- \(\Delta T\) = temperature change (K)

The outlet temperature of one segment becomes the inlet temperature of the next segment.

### 8.3. Axial temperature distribution

This process generates an estimated temperature profile along the pipe length.

The profile is used to investigate how pipe geometry, material properties, flow conditions and soil temperature influence the thermal behaviour of the wastewater.

---

## 9. Seasonal Heat-Loss Assessment

### 9.1. Winter and summer scenarios

The model evaluates heat transfer under the two defined seasonal ground-temperature conditions.

The winter scenario uses a ground temperature of 9°C, while the summer scenario uses 13°C.

The resulting thermal calculations are compared to assess the influence of seasonal boundary conditions.

### 9.2. Natural thermal dissipation

Natural thermal dissipation describes the heat transferred from wastewater into the surrounding ground.

The model estimates this process through the overall thermal resistance and axial temperature calculations.

It is important to distinguish natural heat dissipation from the amount of heat that could practically be recovered using a heat-exchanger installation.

### 9.3. Thermal energy calculations

Thermal energy is calculated from the heat-transfer rate and the relevant time interval:

\[
E = \dot Q \Delta t
\]

Where:

- \(E\) = thermal energy (J)
- \(\dot Q\) = heat-transfer rate (W)
- \(\Delta t\) = time interval (s)

The accuracy of cumulative energy estimates depends on the time intervals represented in the dataset and the method used to integrate the observations.

---

## 10. Numerical Discretisation and Sensitivity Analysis

### 10.1. Segment-size sensitivity

A numerical discretisation assessment is performed to investigate the effect of pipe segmentation on the predicted thermal results.

The following segment counts are evaluated:

| Number of segments |
|---:|
| 25 |
| 50 |
| 100 |
| 200 |
| 500 |
| 1,000 |

The results are compared to assess whether increasing the number of segments produces meaningful changes in the calculated temperature profile and heat-transfer estimates.

This provides an indication of numerical sensitivity to the selected spatial resolution.

### 10.2. Flow-rate sensitivity

The model includes a parametric flow-rate sweep over:

\[
0.02 \leq Q \leq 0.25 \text{ m}^3/\text{s}
\]

This analysis investigates how changes in wastewater flow rate influence the theoretical thermal performance.

The results can help identify the relationship between hydraulic operating conditions and potential thermal energy availability.

### 10.3. Soil thermal conductivity sensitivity

The soil sensitivity analysis evaluates seven assumed soil conditions.

The purpose is to investigate how changes in soil thermal conductivity influence the external thermal resistance and predicted heat transfer.

The results are compared against the base-case soil conductivity of 1.5 W/m·K.

---

## 11. Theoretical Heat-Extraction Assessment

### 11.1. Purpose

The heat-extraction assessment investigates the theoretical thermal energy that may be available for recovery from the wastewater stream.

This is distinct from the natural heat-loss calculation because a practical recovery system would require additional equipment and operating considerations.

### 11.2. Temperature-drop scenarios

The model investigates four assumed wastewater temperature reductions:

| Scenario | Assumed temperature reduction |
|---|---:|
| 1 | 0.25°C |
| 2 | 0.50°C |
| 3 | 1.00°C |
| 4 | 2.00°C |

### 11.3. Theoretical recoverable heat

The thermal power associated with a selected wastewater temperature reduction is estimated using:

\[
\dot Q_{\text{available}} =
\dot m c_p \Delta T
\]

An assumed recovery or utilisation factor of 70% is then applied:

\[
\dot Q_{\text{useful}} =
0.70 \times \dot Q_{\text{available}}
\]

The 70% factor is a modelling assumption used to estimate a potentially useful fraction of the theoretical thermal energy.

**Important qualification:** This factor is not a measured heat-exchanger efficiency, heat-pump coefficient of performance (COP), or verified whole-system efficiency. A practical installation would require separate assessment of heat-exchanger performance, heat-pump electricity consumption, pumping requirements, fouling and operating conditions.

---

## 12. Model Outputs and Visualisation

The MATLAB model generates a range of outputs to support the thermal assessment.

These include:

a. Hydraulic data screening results.
b. Selected operating conditions.
c. Seasonal heat-transfer estimates.
d. Axial wastewater temperature profiles.
e. Numerical segment-size sensitivity results.
f. Flow-rate sensitivity results.
g. Theoretical heat-extraction estimates.
h. Soil thermal conductivity sensitivity results.
i. Summary tables and exported calculation results.

The model also generates plots to help visualise the relationship between operating conditions, pipe characteristics and predicted thermal performance.

Only outputs that have been checked for confidentiality and technical accuracy should be included in the public portfolio.

---

## 13. Engineering Assumptions and Limitations

The model provides an engineering estimation framework rather than a fully validated representation of an installed wastewater heat-recovery system.

The principal assumptions and limitations are summarised below.

| Area | Assumption or limitation |
|---|---|
| Soil properties | Thermal conductivity values are assumed rather than measured at the site. |
| Seasonal conditions | Winter and summer ground temperatures are represented by fixed boundary conditions. |
| Pipe materials | The unknown pipe material is represented using an assumed conductivity. |
| Hydraulic behaviour | The Preissmann-slot-related treatment does not constitute a complete pressurised hydraulic model. |
| Heat transfer | A simplified series thermal-resistance model is used. |
| Ground behaviour | Detailed transient ground response and groundwater movement are not fully represented. |
| Fluid properties | Wastewater properties are treated as representative values. |
| Numerical method | Results may be influenced by the selected segment size. |
| Heat recovery | The 70% factor is an assumed recovery/utilisation factor, not measured system efficiency. |
| Energy integration | Time-series energy estimates require appropriate treatment of irregular sampling intervals and missing data. |
| Practical installation | Heat-exchanger design, fouling, pumping energy and heat-pump performance are outside the complete scope of the model. |

These limitations should be considered when interpreting the results or applying the methodology to other wastewater networks.

---

## 14. Further Engineering Development

The model could be developed further through:

a. **Site-specific ground investigation:** Replace assumed soil properties with measured thermal conductivity and ground-temperature data.
b. **Improved hydraulic modelling:** Incorporate a more detailed representation of pressurised flow and transient hydraulic behaviour.
c. **Transient thermal modelling:** Investigate time-dependent heat transfer and seasonal ground-temperature variation.
d. **Heat-exchanger modelling:** Introduce a defined heat-exchanger arrangement and realistic thermal performance parameters.
e. **Heat-pump integration:** Evaluate COP, electrical demand and useful heat output.
f. **Energy-demand matching:** Compare available thermal energy with nearby building or process heating demand.
g. **Economic assessment:** Estimate capital costs, operating costs, energy savings and payback period.
h. **Model validation:** Compare predicted temperatures and heat-transfer rates against independent field measurements or experimental data.

---

## 15. Reproducibility and Data Confidentiality

The MATLAB model is designed to import the required Excel workbook externally rather than embedding the original dataset within the source code.

The original workbook and confidential measurements are not published in this repository.

To reproduce the analysis, a user would need:

- MATLAB or a compatible MATLAB environment.
- The model source code.
- A suitably structured input workbook containing the required hydraulic and temperature data.
- Appropriate input parameters and assumptions.

The public repository provides the modelling methodology and source-code structure without disclosing confidential project data.

---

## 16. Conclusion

This methodology establishes a MATLAB-based framework for investigating heat transfer from wastewater rising mains to the surrounding ground.

The approach combines hydraulic data screening, internal convection, cylindrical thermal resistance, axial temperature modelling, seasonal assessment and sensitivity analysis.

The additional theoretical heat-extraction assessment provides an initial indication of potential thermal energy availability while recognising that practical recovery requires further system-level engineering and validation.

The model therefore provides a foundation for further investigation into wastewater heat recovery as a potential low-carbon energy resource.

---

**End of methodology document**

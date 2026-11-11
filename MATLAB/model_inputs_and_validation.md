# Model Inputs, Parameters and Validation

**Project:** Wastewater Rising Main Thermal Modelling  
**Software:** MATLAB  
**Discipline:** Mechanical Engineering / Thermal Energy Recovery

---

## 1. Input Parameters

The model uses hydraulic measurements, wastewater temperatures, pipe geometry and thermal properties to estimate heat transfer from wastewater rising mains.

### 1.1 Pipe configuration

| Parameter | RM1 | RM2 | RM3 |
|---|---:|---:|---:|
| Length (m) | 1,730 | 3,303 | 2,927 |
| Internal diameter (m) | 0.150 | 0.600 | 0.500 |
| Material | PVC | Cast iron | Unknown |

### 1.2 Material properties

| Parameter | Value |
|---|---:|
| Pipe-wall thickness | 0.015 m |
| PVC conductivity | 0.19 W/m·K |
| Cast iron conductivity | 52 W/m·K |
| Assumed unknown-material conductivity | 1.0 W/m·K |
| Base-case soil conductivity | 1.5 W/m·K |

### 1.3 Hydraulic and thermal conditions

| Parameter | Model setting |
|---|---|
| Minimum depth-to-diameter ratio | 0.90 |
| High-flow selection | 90th percentile |
| Flow-rate sensitivity range | 0.02–0.25 m³/s |
| Winter ground temperature | 9°C |
| Summer ground temperature | 13°C |
| Main numerical discretisation | 200 segments |

Wastewater properties include density, specific heat capacity, dynamic viscosity and thermal conductivity. Their numerical values should be documented consistently with the MATLAB source code.

---

## 2. Input Classification and Assumptions

Model parameters are classified as follows:

- **Measured:** Hydraulic and temperature observations obtained from the original project dataset.
- **Assumed:** Soil properties, seasonal boundary temperatures and unknown pipe-material properties.
- **Calculated:** Flow velocity, Reynolds number, Nusselt number, thermal resistance and heat-transfer rate.

The principal assumptions include:

1. Fixed winter and summer ground temperatures.
2. Representative wastewater thermal properties.
3. Simplified cylindrical thermal resistance.
4. An assumed material conductivity for RM3.
5. A 70% recovery/utilisation factor for theoretical heat extraction.

The 70% factor is not a measured heat-exchanger efficiency or heat-pump COP.

---

## 3. Data Quality and Processing

The model imports hydraulic and temperature measurements from an external Excel workbook.

Important data-quality checks include:

- Missing or invalid observations.
- Consistency of measurement units.
- Duplicate records.
- Unrealistic hydraulic values.
- Incomplete temperature measurements.
- Timestamp consistency.

All calculations should use consistent SI units.

For time-series energy calculations, actual elapsed time between observations should be considered. Where sampling intervals are irregular, numerical integration using individual timestamps is preferable to assuming a constant interval.

---

## 4. Model Validation

The following checks are recommended to assess the reliability and physical consistency of the model.

| Validation area | Engineering check |
|---|---|
| Input validation | Confirm positive and physically reasonable parameter values. |
| Unit consistency | Check SI units throughout calculations. |
| Thermal resistance | Confirm individual resistances are positive and sum correctly. |
| Energy balance | Compare heat transfer against wastewater mass-flow energy change. |
| Numerical convergence | Compare results using 25, 50, 100, 200, 500 and 1,000 segments. |
| Physical behaviour | Check that changes in conductivity and temperature difference produce reasonable trends. |
| Time-series integration | Verify energy calculations against actual observation intervals. |

The energy balance is expressed as:

\[
\dot Q = \dot m c_p(T_{\mathrm{in}}-T_{\mathrm{out}})
\]

Numerical convergence can be assessed by comparing predicted outlet temperatures and heat-transfer rates at different segment counts.

These are proposed validation checks; they should only be reported as completed once the corresponding tests have been performed.

---

## 5. Sensitivity and Uncertainty

The model investigates the influence of:

- Soil thermal conductivity.
- Wastewater flow rate.
- Numerical segment count.
- Assumed wastewater temperature reduction (0.25°C, 0.50°C, 1.00°C and 2.00°C).

Key uncertainty sources include assumed material properties, ground conditions, wastewater properties, hydraulic measurements and simplified heat-transfer assumptions.

Site-specific measurements and comparison against independent temperature data would improve confidence in the predictions.

---

## 6. Reproducibility

The MATLAB source code imports the required Excel workbook externally.

To reproduce the analysis, users require:

1. MATLAB or a compatible environment.
2. The project source code.
3. A suitably structured hydraulic and temperature dataset.
4. The documented engineering parameters.

The original project dataset is confidential and is therefore excluded from the public repository.

---

## 7. Further Development

Potential improvements include:

- Confirming unknown pipe-material properties.
- Obtaining site-specific soil thermal measurements.
- Improving hydraulic and transient thermal modelling.
- Validating predictions against field measurements.
- Incorporating heat-exchanger and heat-pump performance.
- Assessing energy demand, operating costs and carbon savings.

---

## 8. Conclusion

This document provides a concise reference for the parameters, assumptions and validation approach underpinning the wastewater rising-main thermal model.

It supports transparent interpretation of the MATLAB calculations and identifies the checks and further engineering work required before applying the model to a practical heat-recovery installation.

**End of document**

# Wastewater Rising Main Thermal Model

## 1. Project Overview

This MATLAB script implements a thermal modelling framework to investigate heat transfer and potential thermal energy recovery from wastewater flowing through urban rising mains.

The model evaluates the temperature change of wastewater as it travels through buried pipeline infrastructure, considering the thermal properties of the pipe material, surrounding soil and wastewater flow conditions.

The primary objective is to estimate heat loss from wastewater to the surrounding ground under different seasonal conditions and investigate the potential for recovering useful thermal energy from wastewater flows.

The model also incorporates hydraulic data validation, pipe-specific thermal analysis, numerical segmentation, flow-rate sensitivity analysis and soil thermal conductivity sensitivity analysis.

## 2. Engineering Objectives

The model was developed to:

- Investigate heat transfer between wastewater, pipe walls and surrounding soil.
- Estimate wastewater temperature reduction along individual rising mains.
- Quantify thermal energy loss under winter and summer boundary conditions.
- Examine the influence of pipe geometry and material properties on heat transfer.
- Assess the sensitivity of predicted heat loss to soil thermal conductivity.
- Investigate how wastewater flow rate and extraction temperature influence potential recoverable thermal power.
- Evaluate numerical sensitivity to pipeline segmentation.
- Establish a structured modelling framework for assessing wastewater heat recovery opportunities.

## 3. Model Inputs

The script imports hydraulic and temperature measurements from a locally selected Excel workbook.

The hydraulic dataset provides information including:

- Time records.
- Wastewater flow rates.
- Flow velocities.
- Wastewater depth measurements.

The temperature dataset provides seasonal wastewater inlet temperatures for winter and summer analysis.

Additional model parameters include:

- Pipeline length and internal diameter.
- Pipe material and thermal conductivity.
- Pipe wall thickness.
- Soil thermal conductivity.
- Soil temperature boundary conditions.
- Wastewater density and specific heat capacity.
- Dynamic viscosity and thermal conductivity.
- Prandtl number.
- Numerical segmentation settings.

The model includes three rising-main configurations, identified as RM1, RM2 and RM3.

## 4. Thermal Modelling Methodology

### 4.1 Hydraulic Data Processing

Hydraulic measurements are imported and evaluated to identify physically valid operating conditions.

The model applies positive-depth validation, depth-to-diameter ratio checks and a high-flow selection criterion. A minimum depth ratio of 0.90 is used to identify near-full pipeline conditions.

The Preissmann slot interpretation allows depth ratios greater than one to represent surcharge or pressurised conditions where applicable.

### 4.2 Internal Convective Heat Transfer

The internal convective heat-transfer coefficient is estimated using the Reynolds number and Nusselt number.

The script distinguishes between laminar and turbulent flow using a Reynolds-number threshold of 2,300.

For laminar flow, a constant Nusselt number of 3.66 is applied. For turbulent flow, a Dittus–Boelter-type correlation is used.

### 4.3 Thermal Resistance Model

Heat transfer is represented using three principal thermal resistances:

1. Internal convection between wastewater and the pipe wall.
2. Conduction through the pipe material.
3. Conduction through the surrounding soil.

The total thermal resistance is calculated per unit pipe length using cylindrical thermal resistance relationships.

### 4.4 Axial Temperature Profile

Each pipeline is divided into a specified number of numerical segments.

The wastewater temperature is calculated progressively along the pipeline by estimating heat transfer through each segment.

The model produces winter and summer outlet-temperature profiles and calculates the corresponding wastewater temperature reduction.

### 4.5 Seasonal Heat-Loss Assessment

The thermal model evaluates winter and summer conditions independently using their respective wastewater inlet temperatures and surrounding soil temperatures.

Heat-loss rates are calculated from wastewater mass flow rate, specific heat capacity and predicted temperature reduction.

The outputs include average and maximum temperature reductions, average and maximum heat-loss rates and estimated thermal energy dissipation.

## 5. Numerical and Sensitivity Analysis

### 5.1 Pipeline Segmentation Sensitivity

The script evaluates different axial segment counts to investigate the effect of numerical discretisation on predicted outlet temperatures.

This provides an indication of whether the selected segmentation is sufficiently refined for the model.

### 5.2 Flow-Rate Sensitivity

A parametric flow-rate sweep is performed using RM2 as the reference pipeline.

The analysis investigates flow rates between 0.02 and 0.25 m³/s and evaluates potential thermal extraction at temperature reductions of:

- 0.25°C
- 0.50°C
- 1.00°C
- 2.00°C

A heat-exchanger efficiency assumption of 70% is applied to estimate useful thermal power.

These calculations represent theoretical extraction potential under the specified assumptions, rather than measured heat recovery performance.

### 5.3 Soil Thermal Conductivity Sensitivity

The model investigates seven soil conditions with different assumed thermal conductivities:

- Dry sand.
- Moist or wet sand.
- Saturated sand.
- Dry clay.
- Wet clay.
- Sandy gravel.
- Limestone.

The effect of changing soil thermal conductivity on temperature reduction, heat-loss rate, outlet temperature and estimated thermal energy dissipation is evaluated for RM2.

## 6. Model Outputs

The script generates numerical summaries, plots and Excel output tables.

The outputs include:

- Hydraulic depth and depth-ratio assessments.
- Wastewater inlet and outlet temperature profiles.
- Seasonal temperature reductions.
- Pipeline heat-loss estimates.
- RM2 axial temperature profiles.
- Numerical segmentation sensitivity results.
- Theoretical heat extraction potential.
- Parametric flow-rate sensitivity results.
- Soil thermal conductivity sensitivity results.
- Model input and assumption documentation tables.

Results are exported locally to an Excel workbook alongside the selected source dataset.

## 7. Software and Engineering Techniques

**Primary software:** MATLAB

**Engineering techniques:**
- Heat-transfer modelling.
- Internal convection analysis.
- Cylindrical thermal resistance modelling.
- Hydraulic data processing.
- Numerical discretisation.
- Parametric analysis.
- Sensitivity analysis.
- Engineering data visualisation.
- Thermal energy assessment.

## 8. Assumptions and Limitations

The model uses simplified thermal and hydraulic assumptions to provide an engineering assessment of wastewater heat transfer.

Important considerations include:

- Soil thermal conductivity is represented by assumed values for each soil condition.
- Soil boundary temperatures are prescribed rather than dynamically simulated.
- The model uses a segmented axial heat-transfer calculation.
- Internal convective heat transfer is estimated using simplified Nusselt-number correlations.
- The 70% heat-exchanger efficiency is an assumed value and requires validation against actual equipment performance.
- The parametric extraction assessment does not constitute a detailed heat-exchanger design.
- The model does not independently establish the long-term thermal response of surrounding soil.
- Predicted results depend on the quality, alignment and representativeness of the source hydraulic and temperature measurements.

Further validation against field measurements and a more detailed transient thermal model would improve confidence in the predictions.

## 9. Data Confidentiality

The original hydraulic and temperature dataset is confidential and is not distributed with this repository.

The MATLAB script requests the input workbook locally at runtime. The source workbook and generated output workbook must remain in approved secure storage and must not be uploaded to a public repository without authorisation.

## 10. Engineering Relevance

This project demonstrates the application of mechanical engineering principles and numerical modelling to sustainable energy recovery from existing wastewater infrastructure.

It provides experience in thermal systems analysis, hydraulic data interpretation, MATLAB programming, engineering assumptions, sensitivity analysis and the evaluation of low-carbon energy opportunities.

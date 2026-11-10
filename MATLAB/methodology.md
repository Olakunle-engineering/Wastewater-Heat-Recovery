Engineering Methodology
Thermal Energy Dissipation and Heat-Recovery Potential in Pressurised Sewer Rising Mains
Project: MSc Individual Research Project
Software: MATLAB
Engineering discipline: Mechanical Engineering, Thermal Systems and Sustainable Energy
 
1. Introduction
This study investigates heat transfer between wastewater flowing through buried pressurised sewer rising mains and the surrounding ground. Wastewater contains thermal energy originating from domestic, commercial and industrial activities. Some of this energy is dissipated during transportation through underground pipe networks.
The engineering objective is to estimate the extent of this thermal dissipation and investigate the potential for recovering a proportion of the wastewater's thermal energy.
A one-dimensional, segmented thermal model was developed in MATLAB. The model combines hydraulic measurements, wastewater temperatures, pipe geometry, material properties and assumed ground thermal conditions to estimate wastewater temperature changes along the rising mains.

The model represents heat transfer through three principal mechanisms:
a.	Convective heat transfer between the moving wastewater and the internal pipe wall.
b.	Conductive heat transfer through the pipe wall.
c.	Conductive heat transfer through the surrounding soil.

The methodology also includes hydraulic data screening, seasonal analysis, numerical discretisation testing, soil conductivity sensitivity analysis and theoretical heat-extraction scenarios.

The investigation distinguishes between two separate engineering questions:
•	Natural thermal dissipation: How much heat is transferred from the wastewater to the surrounding ground during transportation?
•	Potential heat extraction: How much thermal power could theoretically be extracted from the wastewater under specified flow and temperature-extraction conditions?
These calculations are related but represent different physical processes.

2. Physical System and Study Configuration

2.1 Pressurised sewer rising mains

A rising main is a pumped wastewater pipeline that generally operates full or under pressure. Unlike a conventional gravity sewer, it does not normally contain a continuous free water surface.
This distinction is important when assessing hydraulic conditions and selecting the appropriate thermal modelling approach.

The model investigates three rising mains, using the following geometric and material parameters.
Parameter	RM1	RM2	RM3
Pipe length (m)	1,730	3,303	2,927
Internal diameter (mm)	150	600	500
Pipe material	PVC	Cast iron	Unknown
Pipe conductivity (W/m·K)	0.19	52	1.0*

An assumed thermal conductivity of 1.0 W/m·K is assigned to the unidentified pipe material for modelling purposes.

The pipe wall thickness is assumed to be 0.015 m for all three rising mains.

The surrounding ground is represented using an equivalent radial thermal resistance. A soil reference radius of 2.0 m is used in the model.

2.2 Modelling assumptions

The physical system is simplified using the following assumptions:
•	Wastewater is approximated as water for thermophysical property calculations.
•	Pipe geometry and material properties remain constant along each rising main.
•	Soil temperature is represented by a fixed seasonal boundary condition.
•	Soil thermal conductivity is assumed uniform within each individual simulation.
•	Heat transfer is represented using a one-dimensional axial model with radial heat transfer.
•	Hydraulic operating conditions are treated as constant within each individual modelled time record.
These assumptions provide a computationally manageable representation of the thermal behaviour of the rising mains.

3. Data Acquisition and Pre-processing

3.1 Input data

The model imports hydraulic and temperature measurements from a locally selected Excel workbook.
The workbook contains the following information:

Hydraulic measurements
•	Flow rate for each rising main, (Q), in m³/s.
•	Flow velocity, (v), in m/s.
•	Measured wastewater depth, (d), in m or mm.
•	Corresponding time records.

Temperature measurements
•	Winter wastewater inlet temperature.
•	Summer wastewater inlet temperature.
•	Corresponding seasonal time records.
The MATLAB script uses the second worksheet for hydraulic measurements and the third worksheet for temperature measurements, with alternative worksheet-name references provided in the import procedure.

3.2 Data alignment and validation
Before performing thermal calculations, the model checks that the hydraulic and temperature records are aligned.
The following checks are implemented:
a.	Hydraulic flow, velocity and depth measurements must have matching timestamps.
b.	Winter and summer temperature timestamps must match the hydraulic time records.
c.	Non-finite measurements are excluded from the analysis.
d.	At least two valid, strictly increasing time records must be available.
e.	Records with inconsistent data lengths are rejected rather than silently truncated.
This procedure reduces the risk of pairing hydraulic measurements with unrelated temperature observations.

3.3 Depth unit conversion
The thermal model requires pipe depth in metres.
Where the median absolute depth measurement is greater than five times the pipe diameter, the model assumes that the imported depth measurements are in millimetres and converts them into metres:
[d_{\mathrm{m}}=\frac{d_{\mathrm{mm}}}{1000}]

This is an automatic unit-detection rule rather than a definitive identification of the original measurement units. The source workbook should therefore be checked before interpreting the converted values.

4. Hydraulic Screening and Operating Condition Selection
The thermal model is intended to assess representative near-full, full or surcharged operating conditions. Hydraulic screening is therefore performed before the heat-transfer calculations.

4.1 Depth-to-diameter ratio

The relative depth of wastewater within a pipe is assessed using:
[
\frac{d}{D}
]
Where:
•	(d) = measured wastewater depth (m).
•	(D) = internal pipe diameter (m).

The model applies a minimum depth-to-diameter ratio of:
[
\frac{d}{D}\geq0.90
]
This criterion identifies records where the pipe is operating at or above 90% of its internal diameter.
Non-positive or non-finite source depths are excluded before calculating the ratio.

4.2 Preissmann slot interpretation

The model allows depth-to-diameter ratios greater than 1.0.
This is used to retain records that may represent surcharged or pressurised conditions above the pipe crown, rather than automatically rejecting them as physically impossible.
The approach is described as a Preissmann-slot interpretation in the MATLAB script.
Importantly, the implementation retains the measured ratio above 1.0; it does not construct a separate slot geometry or solve a full pressure-head hydraulic model. Consequently, this treatment should be understood as a simplified representation of surcharge conditions.

4.3 High-flow selection
A high-flow criterion is applied to focus the thermal analysis on the upper range of qualifying hydraulic operating conditions.
First, candidate records are identified using the following conditions:
•	Positive and finite flow rate.
•	Positive and finite velocity.
•	Positive and finite depth.
•	Depth-to-diameter ratio of at least 0.90.

The 90th percentile of the qualifying flow-rate measurements is then calculated separately for each rising main:
[
Q_{90}=P_{90}(Q_{\mathrm{candidate}})
]
Where (P_{90}) represents the 90th percentile.
Only measurements satisfying:
[
Q\geq Q_{90}
]
are retained for the main thermal analysis.
This method provides a pipe-specific high-flow threshold rather than applying one common flow-rate limit to all three rising mains.

4.4 Temperature-drop acceptance criteria

Following the thermal calculations, the MATLAB model applies additional temperature-drop limits:
Season	Maximum accepted temperature drop
Winter	0.20°C
Summer	0.50°C
These thresholds are implemented as screening criteria to remove unusually large temperature-drop results from the main analysis.
A record is classified as a fully valid modelled point when both its winter and summer calculations satisfy their respective acceptance criteria.
The thresholds are modelling choices and should be justified against measurement uncertainty, expected operating conditions and the research objectives.

5. Thermophysical Properties and Boundary Conditions

5.1 Wastewater properties

Wastewater is approximated as water using the following constant properties:
Property	Symbol	Value	Unit
Density	(\rho)	1,000	kg/m³
Specific heat capacity	(c_p)	4,180	J/kg·K
Dynamic viscosity	(\mu)	0.001	Pa·s
Thermal conductivity	(k_w)	0.60	W/m·K
Prandtl number	(Pr)	7	–
The approximation simplifies the calculation of fluid velocity effects, internal convection and thermal energy transport.
Actual wastewater properties may vary with temperature and composition. These variations are not explicitly modelled.

5.2 Seasonal thermal boundary conditions

Two seasonal soil temperatures are considered:
Season	Assumed soil temperature
Winter	9°C
Summer	13°C
The wastewater inlet temperatures are obtained separately from the imported seasonal temperature records.
The difference between wastewater and surrounding soil temperature provides the driving temperature difference for heat transfer.

5.3 Soil thermal conductivity
The baseline soil thermal conductivity is:
[
k_s=1.5\ \mathrm{W/(m\cdot K)}
]
A separate sensitivity investigation evaluates the influence of seven assumed soil conditions, using the following values:
Soil condition	Thermal conductivity (W/m·K)
Dry sand	0.560
Moist/wet sand	0.955
Soaked sand	2.160
Dry clay	0.435
Wet clay	1.300
Sandy gravel	2.510
Limestone	1.300
These values are treated as representative modelling inputs. They are not site-specific measurements of the ground surrounding the rising mains.

6. Internal Convective Heat Transfer

Heat transfer from the moving wastewater to the internal pipe wall is represented using an internal convective heat-transfer coefficient.
The coefficient is estimated using dimensionless flow parameters.

6.1 Mass flow rate
The wastewater mass flow rate is calculated from:
[
\dot m=\rho Q
]
Where:
•	(\dot m) = mass flow rate (kg/s).
•	(\rho) = wastewater density (kg/m³).
•	(Q) = volumetric flow rate (m³/s).
Mass flow rate is important because it determines the thermal capacity of the wastewater passing through the pipeline.
6.2 Reynolds number
The Reynolds number is calculated using:
[
Re=\frac{\rho vD}{\mu}
]
Where:
•	(v) = wastewater velocity (m/s).
•	(D) = internal pipe diameter (m).
•	(\mu) = dynamic viscosity (Pa·s).
The Reynolds number characterises the flow regime and provides the basis for selecting the internal heat-transfer correlation.

6.3 Nusselt number
The MATLAB model uses a simplified piecewise relationship:
For:
[
Re<2300
]
The model applies:
[
Nu=3.66
]
For:
[
Re\geq2300
]
The model applies:
[
Nu=0.023Re^{0.8}Pr^{0.4}
]
The first relationship represents a commonly used approximation for fully developed laminar flow in a circular tube under constant wall-temperature conditions.
The second relationship is based on the Dittus–Boelter correlation for turbulent internal flow.
The implementation uses the Reynolds number of 2300 as its switching threshold. This is a simplified treatment of the transition region, and the turbulent correlation should be checked for suitability where Reynolds numbers are close to the transition or below the usual range of applicability of the correlation.

6.4 Internal heat-transfer coefficient
The internal convective heat-transfer coefficient is determined from:
[
h_i=\frac{Nu,k_w}{D}
]
Where:
•	(h_i) = internal convective heat-transfer coefficient (W/m²·K).
•	(Nu) = Nusselt number.
•	(k_w) = wastewater thermal conductivity (W/m·K).
A higher heat-transfer coefficient indicates stronger convective heat transfer between the wastewater and the pipe wall for a given temperature difference.

7. Thermal Resistance Model

7.1 Conceptual approach

Heat transfer from wastewater to the surrounding ground is represented as three thermal resistances connected in series:
a.	Internal convection.
b.	Pipe-wall conduction.
c.	Soil conduction.
The total thermal resistance is calculated by adding the individual resistances.
The model uses cylindrical coordinates because the heat transfer occurs radially through a cylindrical pipe wall and the surrounding soil.

7.2 Pipe radii

The internal pipe radius is:
[
r_i=\frac{D}{2}
]
The external pipe radius is:
[
r_o=r_i+t_p
]
Where:
•	(r_i) = internal pipe radius (m).
•	(r_o) = external pipe radius (m).
•	(t_p) = pipe wall thickness (m).
7.3 Internal convective resistance
The convective resistance per unit pipe length is:
[
R'_{\mathrm{conv}}=
\frac{1}{h_i,2\pi r_i}
]

7.4 Pipe-wall conductive resistance
The cylindrical pipe-wall resistance per unit length is:
[
R'_{\mathrm{pipe}}=
\frac{\ln(r_o/r_i)}{2\pi k_p}
]
Where (k_p) represents the thermal conductivity of the pipe material.

7.5 Soil conductive resistance
The soil resistance per unit pipe length is:
[
R'_{\mathrm{soil}}=
\frac{\ln(r_s/r_o)}{2\pi k_s}
]
Where:
•	(r_s) = assumed radial soil boundary distance (m).
•	(k_s) = soil thermal conductivity (W/m·K).
The model uses an assumed soil boundary radius of 2.0 m.

7.6 Overall thermal resistance
The combined thermal resistance per unit length is:
[
R'{\mathrm{total}}=
R'{\mathrm{conv}}+
R'{\mathrm{pipe}}+
R'{\mathrm{soil}}
]
The resulting unit is:
[
\mathrm{K\cdot m/W}
]
This formulation allows the radial heat-transfer rate per metre of pipeline to be calculated for a given wastewater-to-soil temperature difference.

8. Axial Temperature Profile and Numerical Solution

8.1 Discretisation of the rising main

The rising main is divided into a number of smaller axial elements to calculate the temperature change along its length.
For a pipeline of length (L), divided into (N) equal segments:
[
\Delta x=\frac{L}{N}
]
The main model uses:
[
N=200
]
Therefore, the element length is calculated individually for each rising main.
The temperature of the wastewater at the beginning of the pipeline is taken from the corresponding inlet temperature measurement.

8.2 Heat transfer per unit length
At each computational segment, the heat transfer rate per unit length is estimated using:
[
q'j=
\frac{T_j-T_s}{R'{\mathrm{total}}}
]
Where:
•	(q'_j) = heat-transfer rate per unit length at segment (j) (W/m).
•	(T_j) = wastewater temperature entering segment (j) (°C).
•	(T_s) = surrounding soil temperature (°C).
•	(R'_{\mathrm{total}}) = overall thermal resistance per unit length (K·m/W).
The heat transferred across an individual segment is:
[
\dot Q_j=q'_j\Delta x
]
Where (\dot Q_j) is the segment heat-transfer rate in watts.

8.3 Wastewater energy balance
The temperature change across each segment is determined using a steady-flow energy balance:
[
\dot Q_j=\dot m c_p\Delta T_j
]
Rearranging:
[
\Delta T_j=
\frac{\dot Q_j}{\dot m c_p}
]
The outlet temperature from the segment is then:
[
T_{j+1}=T_j-\Delta T_j
]
The calculated outlet temperature becomes the inlet temperature for the next segment.
This process is repeated until the full pipeline length has been modelled.
The MATLAB model applies the same numerical procedure independently to winter and summer conditions.

8.4 Modelled outlet temperature
After the final segment:
[
T_{\mathrm{out}}=T_N
]
The overall wastewater temperature change is:
[
\Delta T_{\mathrm{pipe}}=
T_{\mathrm{in}}-T_{\mathrm{out}}
]
This represents the predicted temperature reduction along the rising main under the selected hydraulic and thermal conditions.
The model recalculates the local heat-transfer driving temperature difference at each segment as the wastewater temperature changes. However, the thermal resistance is treated as constant along an individual modelled pipe.

9. Estimation of Natural Thermal Dissipation
The heat-transfer rate from the wastewater is estimated from the mass flow rate and the overall temperature change:
[
\dot Q_{\mathrm{loss}}=
\dot m c_p
\left(T_{\mathrm{in}}-T_{\mathrm{out}}\right)
]
Equivalently:
[
\dot Q_{\mathrm{loss}}=
\rho Qc_p\Delta T_{\mathrm{pipe}}
]
The result is initially obtained in watts and converted to kilowatts:
[
\dot Q_{\mathrm{loss,kW}}=
\frac{\rho Qc_p\Delta T_{\mathrm{pipe}}}{1000}
]
This calculation provides an estimate of the thermal power dissipated during wastewater transportation.
The model calculates this quantity separately for winter and summer conditions and compares the results across the three rising mains.
A distinction is maintained between thermal power, expressed in kW, and thermal energy, expressed in kWh.

9.1 Thermal energy over time
For an interval of constant duration:
[
E_{\mathrm{loss}}=
\sum_{i=1}^{n}
\dot Q_{\mathrm{loss},i}\Delta t
]
Where:
•	(E_{\mathrm{loss}}) = accumulated thermal energy (kWh).
•	(\dot Q_{\mathrm{loss},i}) = thermal power during record (i) (kW).
•	(\Delta t) = time interval (h).
The model converts energy from kWh to MJ using:
[
E_{\mathrm{MJ}}=3.6E_{\mathrm{kWh}}
]
Time-integration qualification: The current MATLAB implementation uses the median time interval for all records. Where timestamps are irregular or there are gaps, the calculated accumulated energy should be checked against the actual individual time intervals before being reported as a reliable total.

10. Numerical Discretisation Sensitivity
A numerical sensitivity investigation is performed to determine whether the predicted outlet temperature depends significantly on the selected number of axial segments.
The model evaluates the following discretisations:
Number of segments	Segment length
25	(L/25)
50	(L/50)
100	(L/100)
200	(L/200)
500	(L/500)
1,000	(L/1000)
For each case, the model recalculates the winter and summer outlet temperatures and corresponding temperature reductions.
The comparison provides an indication of numerical discretisation sensitivity.
A sufficiently fine discretisation should produce progressively smaller changes in the predicted outlet temperature as the number of segments increases.
The 200-segment model is retained as the main computational configuration. Its suitability should be supported by the sensitivity results rather than assumed solely from the selected segment count.

11. Theoretical Heat-Extraction Potential
11.1 Purpose
The natural heat-loss model estimates how much thermal energy is dissipated from wastewater into the surrounding ground.
A separate calculation investigates the theoretical thermal power associated with extracting a specified temperature reduction from the wastewater.
This is not a detailed simulation of an installed sewer heat exchanger or heat pump.
11.2 Theoretical wastewater-side thermal power
The thermal power associated with an assumed extraction temperature reduction is:
[
\dot Q_{\mathrm{theoretical}}=
\rho Qc_p\Delta T_{\mathrm{extract}}
]
Where:
•	(Q) = wastewater flow rate (m³/s).
•	(\Delta T_{\mathrm{extract}}) = assumed wastewater temperature reduction (K or °C difference).
Converting into kilowatts:
[
\dot Q_{\mathrm{theoretical,kW}}=
\frac{\rho Qc_p\Delta T_{\mathrm{extract}}}{1000}
]

11.3 Assumed recovery factor
The MATLAB model applies an assumed recovery factor of 70%:
[
\eta=0.70
]
The indicative useful thermal power is calculated as:
[
\dot Q_{\mathrm{useful}}=
\eta\dot Q_{\mathrm{theoretical}}
]
Therefore:
[
\boxed{
\dot Q_{\mathrm{useful,kW}}=
\frac{\eta\rho Qc_p\Delta T_{\mathrm{extract}}}{1000}
}
]
The extraction temperature reductions investigated are:
•	0.25°C
•	0.50°C
•	1.00°C
•	2.00°C

11.4 Parametric flow-rate analysis
A parametric investigation is conducted over the following flow-rate range:
[
0.02\leq Q\leq0.25\ \mathrm{m^3/s}
]
The flow range is divided into 100 calculation points.
The model evaluates the indicative useful thermal power for each combination of flow rate and extraction temperature reduction.
This allows the relationship between wastewater flow rate, assumed extraction temperature reduction and theoretical thermal power to be investigated.
The 70% factor is an assumed recovery/utilisation factor within the calculation. It is not a measured heat-exchanger efficiency, a heat-pump coefficient of performance or a complete system performance factor.
The results should therefore be interpreted as conditional thermal potential rather than confirmed delivered heating capacity.

12. Soil Thermal Conductivity Sensitivity Analysis
The thermal resistance of the surrounding soil can significantly influence the rate at which heat is transferred away from the wastewater.
The MATLAB model investigates this influence using seven alternative soil thermal conductivity values.
For each soil condition:
a.	The same RM2 pipe geometry is retained.
b.	The same selected hydraulic operating records are used.
c.	The pipe material and fluid properties remain unchanged.
d.	The soil thermal conductivity is varied.
e.	The thermal resistance is recalculated.
f.	Winter and summer outlet temperatures are recalculated.
g.	Temperature reductions and thermal power are estimated.
The resulting outputs include:
•	Average and maximum winter temperature reduction.
•	Average and maximum summer temperature reduction.
•	Average and maximum winter heat-loss rate.
•	Average and maximum summer heat-loss rate.
•	Accumulated thermal energy for each season.
•	Average outlet wastewater temperature.
Keeping the hydraulic conditions and pipe geometry constant allows the effect of changing soil conductivity to be examined independently.
This sensitivity analysis is particularly important because the soil properties are assumed rather than established through site-specific ground investigations.

13. Model Outputs and Data Export
The MATLAB script produces graphical and tabular outputs to support the engineering assessment.
The principal outputs include:
Output	Engineering purpose
Depth-to-diameter ratio plots	Assess hydraulic operating conditions
Inlet and outlet temperature plots	Compare seasonal wastewater temperatures
Temperature-drop plots	Examine predicted thermal changes
Heat-loss plots	Compare estimated thermal power
RM2 axial temperature profile	Illustrate temperature variation along the pipe
Segment-size sensitivity	Assess numerical discretisation
Flow-rate extraction plots	Investigate theoretical thermal potential
Soil sensitivity plots	Examine ground-property uncertainty
Summary tables	Consolidate thermal and hydraulic results
The script also exports summary tables, modelled pipe results, input assumptions, sensitivity outputs and numerical profile data to an Excel workbook.
The original input workbook and generated results workbook are kept locally because they may contain confidential source or derived information.

14. Model Assumptions and Limitations
The model provides a simplified engineering assessment of thermal behaviour. Its outputs must be interpreted in the context of the assumptions and limitations below.

14.1 Hydraulic and operating assumptions
•	The model uses measured flow rate, velocity and depth records.
•	The near-full/full/surcharged screening threshold is set at (d/D\geq0.90).
•	The high-flow selection uses the 90th percentile of qualifying flow records.
•	The simplified Preissmann-slot interpretation does not independently calculate pressure head.
•	Hydraulic conditions are treated as constant within each modelled time record.

14.2 Thermal assumptions
•	Wastewater is approximated using constant water properties.
•	Seasonal soil temperatures are fixed at 9°C and 13°C.
•	The soil is represented using an equivalent radial thermal resistance.
•	The soil reference radius is assumed to be 2.0 m.
•	Pipe wall thickness is fixed at 0.015 m.
•	The unidentified pipe material is assigned an assumed thermal conductivity.
•	The model does not explicitly simulate groundwater movement, soil moisture variation, seasonal ground-temperature profiles or detailed soil layering.

14.3 Numerical assumptions
•	The model uses a one-dimensional axial discretisation.
•	Radial heat transfer is represented through combined thermal resistances.
•	Thermal resistance is treated as constant along an individual pipe simulation.
•	The main model uses 200 axial segments.
•	The accumulated energy calculation uses a median time interval, which requires verification where measurement intervals are irregular.

14.4 Practical heat-recovery limitations
The theoretical extraction calculations do not include:
•	Detailed heat-exchanger geometry and design.
•	Heat-exchanger fouling or blockage.
•	Heat-pump coefficient of performance.
•	Pumping and auxiliary electricity consumption.
•	Thermal demand profiles or demand matching.
•	Heat-storage requirements.
•	Installation constraints and maintenance.
•	Capital costs, operating costs or lifecycle economics.
Consequently, the model estimates thermal behaviour and conditional source-side heat potential. It does not establish the technical or economic feasibility of a complete wastewater heat-recovery installation.

15. Further Engineering Development
The following investigations would improve the reliability and practical applicability of the model:
a.	Obtain longer-duration hydraulic and temperature measurements across different seasons.
b.	Validate predicted outlet temperatures against field measurements.
c.	Confirm pipe material, wall thickness, burial depth and actual ground conditions.
d.	Investigate soil temperature variation with depth and time.
e.	Examine the suitability of internal convection correlations across the actual Reynolds number range.
f.	Improve time integration by using individual timestamp intervals.
g.	Develop a detailed heat-exchanger and heat-pump model.
h.	Include pumping energy and auxiliary electricity demand.
i.	Assess fouling, maintenance and operational constraints.
j.	Complete a techno-economic and carbon-emissions assessment.
These developments would help progress the investigation from a theoretical thermal assessment towards a site-specific engineering design study.

16. Methodology Summary
The MATLAB methodology combines hydraulic screening, internal convective heat-transfer estimation, cylindrical thermal resistance modelling and a segmented wastewater energy balance.
The resulting framework is used to estimate seasonal wastewater temperature changes and natural thermal dissipation in three buried pressurised rising mains.
Further parametric calculations investigate the influence of flow rate, assumed extraction temperature reduction and soil thermal conductivity on the estimated thermal potential.
The approach provides a structured numerical framework for investigating wastewater as a potential low-carbon thermal resource while recognising the importance of data quality, model validation and practical system constraints.

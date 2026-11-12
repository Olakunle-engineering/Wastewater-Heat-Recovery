

##  Results and Discussion

This section presents the comparative performance and seasonal heat-transfer dynamics evaluated across reach models **RM1**, **RM2**, and **RM3**. Data processing, numerical MARCHING solutions, and parametric sensitivity analyses were executed using continuous 48-hour summer and winter simulation profiles.

---

###   Data Screening & Hydraulic Filtering Results

Raw hydraulic telemetry was subjected to four sequential physical validation filters prior to thermal modeling:
1. **Physical Depth Validation:** Removal of non-positive depth sensor records ($d \le 0$).
2. **Pressurized/Full-Pipe Criterion:** Retention of depth-to-diameter ratios $d/D \ge 0.90$. Surcharged states ($d/D \ge 1.0$) were retained under a virtual Preissmann slot formulation.
3. **High-Flow Percentile Filtering:** Selection of flow rates at or above the 90th percentile ($Q \ge Q_{90}$) to isolate strong convective transport periods.
4. **Thermal Stability Outliers:** Upper limits on physical temperature drop ($\Delta T_{\text{winter}} \le 0.20^\circ\text{C}$, $\Delta T_{\text{summer}} \le 0.50^\circ\text{C}$) to eliminate low-flow transitional spikes.

Raw Telemetry (48 Hours) ──► Depth Filter (d > 0) ──► Fullness (d/D ≥ 0.90) ──► High Flow (Q ≥ Q_90) ──► Valid Cases


#### Hydraulic Filtering Summary Across Reaches

| Parameter | RM1 | RM2 | RM3 |
| :--- | :---: | :---: | :---: |
| **Pipe Length ($L$)** | $1,730\text{ m}$ | $3,303\text{ m}$ | $2,927\text{ m}$ |
| **Internal Diameter ($D$)** | $0.150\text{ m}$ ($150\text{ mm}$) | $0.600\text{ m}$ ($600\text{ mm}$)| $0.500\text{ m}$ ($500\text{ mm}$) |
| **Pipe Material** | PVC ($0.19\text{ W/m}\cdot\text{K}$) | Cast Iron ($52.00\text{ W/m}\cdot\text{K}$) | Assumed ($1.00\text{ W/m}\cdot\text{K}$) |
| **Excluded Non-Positive Depth Points** | 44 hourly points | 0 points | 48 hourly points |
| **High-Flow Threshold ($Q_{90}$)** | $0.0132\text{ m}^3/\text{s}$ | $0.2028\text{ m}^3/\text{s}$| $0.0131\text{ m}^3/\text{s}$ |
| **Surcharged Points ($d/D \ge 1.0$)** | 0| 22 | 0 |
| **Final Valid Modelled Points ($N$)** | **0**| **4** ($t = [18, 19, 42, 43]\text{ h}$) | **0** |

> **Discussion Note:** **RM2** was the only asset with valid, continuous high-flow pressurized telemetry satisfying all screening constraints. **RM1** and **RM3** suffered from severe sensor anomalies (negative depth readings) and failed the $90\%$ fullness threshold, yielding zero valid observations for detailed thermal evaluation.

---

###  Seasonal Wastewater Temperature Drops ($\Delta T$)

For the 4 qualifying high-flow observations on **RM2**, the dynamic wastewater temperature reduction along the $3,303\text{ m}$ reach remained minimal:

<p align="center">
 
  <img width="763" height="347" alt="winter_heat_loss" src="https://github.com/user-attachments/assets/d5603edb-be1f-4e3f-9460-29618d09b3e4" />
  
  <img width="758" height="344" alt="summer_heat_loss" src="https://github.com/user-attachments/assets/764fad9a-e361-4a16-9441-e12dd25da42b" />

  <br>
  <em>Figure 1: RM2 48-hour diurnal inlet vs. modelled outlet temperature profile for Summer (below) and Winter (Above). Highlighted segments show qualifying high-flow observation windows.</em>
</p>

* **Winter Conditions ($T_{\text{soil}} = 9^\circ\text{C}$):** Inlet temperature ranged between $10.90^\circ\text{C}$ and $11.30^\circ\text{C}$. The temperature drop along the reach ranged from **$0.0379^\circ\text{C}$ to $0.0425^\circ\text{C}$** (mean: $\approx 0.04^\circ\text{C}$).
* **Summer Conditions ($T_{\text{soil}} = 13^\circ\text{C}$):** Inlet temperature ranged between $18.20^\circ\text{C}$ and $18.40^\circ\text{C}$. The temperature drop along the reach ranged from **$0.1018^\circ\text{C}$ to $0.1051^\circ\text{C}$** (mean: $\approx 0.10^\circ\text{C}$).

<p align="center">
  <img width="710" height="443" alt="Screenshot 2026-11-11 at 13 10 40" src="https://github.com/user-attachments/assets/654cd6c6-a291-4fc4-9fdd-8df98c98e021" />
  <img width="710" height="445" alt="Screenshot 2026-11-11 at 13 10 28" src="https://github.com/user-attachments/assets/893cdff7-da59-4a6a-9b79-a11fc90afe63" />
  <br>
  </em>Figure 2: Modelled temperature drop ($\Delta T$) along reach length for Summer (left) and Winter (right)[cite: 12].</em>
</p>

**Discussion:** The larger temperature drop in summer is driven by a larger initial thermal gradient ($\Delta T_{\text{gradient}} = T_{\text{in}} - T_{\text{soil}} \approx 5.4^\circ\text{C}$ in summer vs. $\approx 2.1^\circ\text{C}$ in winter). The extremely small bulk temperature drops ($\le 0.105^\circ\text{C}$) confirm that the high thermal mass capacity rate ($\dot m c_p$) of pressurized mains cushions the fluid against rapid axial thermal degradation[cite: 12].

---

###  Natural Heat Loss and Thermal Energy Dissipation

Despite small localized temperature reductions, the high mass flow rate ($\dot m \approx 204\text{ kg/s}$) drives substantial thermal energy dissipation into the surrounding ground:

<p align="center">
 <img width="702" height="442" alt="Summer Heat Loss Comparison" src="https://github.com/user-attachments/assets/1c79594b-be81-45a6-aac7-a9bd28f01adc"  />

  <img width="704" height="444" alt="Winter Heat Loss Comparison" src="https://github.com/user-attachments/assets/92368112-234c-4648-a96f-3db8cca51146" />
  <br>
  </em>Figure 3: Modelled rate of natural heat dissipation $`\text{kW}`$ during qualifying operational hours for Summer (left) and Winter (right)].</em>
</p>

#### RM2 Seasonal Heat Loss & Dissipated Energy Summary

| Metric | Winter Scenario ($T_{\text{soil}} = 9^\circ\text{C}$)| Summer Scenario ($T_{\text{soil}} = 13^\circ\text{C}$) |
| :--- | :---: | :---: |
| **Valid Hourly Points ($N$)** | 4 | 4 |
| **Heat Loss Rate Range ($\text{kW}$)** | $32.27 - 36.26\text{ kW}$| $86.72 - 89.59\text{ kW}$ |
| **Average Heat Loss Rate ($\text{kW}$)** | **$34.27\text{ kW}$**| **$88.16\text{ kW}$** |
| **Cumulative Dissipated Energy ($\text{kWh}$)** | **$137.07\text{ kWh}$** | **$352.63\text{ kWh}$**|
| **Cumulative Dissipated Energy ($\text{MJ}$)** | $493.46\text{ MJ}$ | $1,269.50\text{ MJ}$ |

---

### Theoretical Heat-Recovery Potential

To assess active heat extraction via an in-stream heat exchanger, useful thermal power ($\dot Q_{\text{useful}}$) was modeled assuming an exchanger effectiveness factor $\eta_{\text{hx}} = 70\%$ across four target temperature drop scenarios:

$$\dot Q_{\text{useful}} = 0.70 \times (\rho \cdot Q \cdot c_p \cdot \Delta T_{\text{extract}})$$

#### Useful Thermal Power & Recovery Energy for RM2 ($Q_{\text{avg}} = 0.204\text{ m}^3/\text{s}$)

| Target Extraction Drop ($\Delta T_{\text{extract}}$) | Average Useful Thermal Power ($\text{kW}$) | Total Useful Energy over 4 Valid Hours ($\text{kWh}$) |
| :---: | :---: | :---: |
| **$0.25^\circ\text{C}$** | $149.13\text{ kW}$| $596.52\text{ kWh}$ |
| **$0.50^\circ\text{C}$** | $298.26\text{ kW}$ | $1,193.00\text{ kWh}$ |
| **$1.00^\circ\text{C}$** | **$596.52\text{ kW}$** | **$2,386.10\text{ kWh}$** |
| **$2.00^\circ\text{C}$** | $1,193.00\text{ kW}$ | $4,772.10\text{ kWh}$ |



**Parametric Flow Sweep:** A broader sweep across flow rates ($0.02 \le Q \le 0.25\text{ m}^3/\text{s}$) confirms a strong linear relationship between volumetric flow and extractable thermal power. Under high-flow operation ($Q = 0.204\text{ m}^3/\text{s}$), a modest $1.0^\circ\text{C}$ fluid cooling yields **$596.5\text{ kW}$** of useful thermal power.

---

###  Parametric Sensitivity Analysis

#### 1. Soil Thermal Conductivity ($k_{\text{soil}}$)
The surrounding ground acts as an external thermal resistance. Modeling seven distinct geological matrices demonstrates the sensitivity of heat loss to ground composition:

| Soil Condition / Matrix | Thermal Conductivity $k_{\text{soil}}$ ($\text{W/m}\cdot\text{K}$) | Average Winter Loss ($\text{kW}$) | Average Summer Loss ($\text{kW}$) | Cumulative Summer Loss ($\text{kWh}$) |
| :--- | :---: | :---: | :---: | :---: |
| **Dry Clay** | 0.435 | 10.0 | 25.8 | 103.2 |
| **Dry Sand** | 0.560 | 13.0 | 33.4 | 133.6 |
| **Moist Sand** | 0.955 | 21.9| 56.2| 224.8 |
| **Wet Clay / Base Case** | 1.300 / 1.500 | 29.8 / 34.3| 76.5 / 88.2 | 306.0 / 352.6|
| **Soaked Sand** | 2.160| 49.0| 126.0| 504.0|
| **Sandy Gravel / Frozen Clay** | 2.510 | **56.9** | **146.3** | **585.2** |

**Key Finding:** Transitioning ground conditions from dry clay ($0.435\text{ W/m}\cdot\text{K}$) to sandy gravel ($2.51\text{ W/m}\cdot\text{K}$) increases natural heat loss by **$467\%$**. High soil moisture content significantly decreases external thermal resistance, resulting in accelerated thermal dissipation into surrounding ground layers.

#### 2. Grid Discretization Convergence
Spatial segment-size tests were conducted across $N \in \{25, 50, 100, 200, 500, 1000\}$ elements to verify numerical stability:

| Number of Segments ($N$) | Spatial Element Size $\Delta x$ ($\text{m}$) | Winter $\Delta T$ ($^\circ\text{C}$) | Summer $\Delta T$ ($^\circ\text{C}$) | Relative Error vs. $N=1000$ |
| :---: | :---: | :---: | :---: | :---: |
| **25** | 132.12| 0.04251 | 0.10515| $< 0.05\%$ |
| **50** | 66.06 | 0.04250 | 0.10513 | $< 0.02\%$ |
| **100** | 33.03 | 0.04249 | 0.10512| $< 0.01\%$ |
| **200 (Baseline)** | **16.52**| **0.04249** | **0.10511** | **Reference** |
| **500** | 6.61 | 0.04249| 0.10511 | $0.00\%$ |
| **1000** | 3.30 | 0.04249 | 0.10511 | $0.00\%$ |

**Verification:** Numerical variations between $N = 200$ ($\Delta x = 16.52\text{ m}$) and $N = 1000$ ($\Delta x = 3.30\text{ m}$) were negligible ($< 0.01\%$), establishing full grid independence for the baseline 200-segment model.

---

### Engineering Discussion & Operational Limitations


| PRACTICAL SYSTEM DESIGN CONSTRAINTS                                              |
|:--------------------------------------------------------------------------------:|
| 1. Exchanger Fouling: Biofilm and solids deposition increase thermal resistance.|
| 2. Downstream Impact: Excessive heat extraction may impair biological treatment. |
| 3. Temporal Coincidence: Heat generation must align with thermal demand.         |
| 4. Parasitic Loads: Pumping energy and heat-pump electricity impact net COP.     |


1. **Hydraulic Data Quality:** Telemetry screening revealed that field sensors frequently record non-positive depths or erroneous pressure heads. Robust, validated flow monitoring is essential before allocating capital to heat-recovery infrastructure.
2. **Conveyance vs. Recovery:** High-flow rising mains experience high natural heat loss rates while maintaining high thermal retention (small $\Delta T$). This makes pressurized mains superior candidates for heat recovery relative to gravity sewers, provided downstream treatment plant thermal boundaries are respected.

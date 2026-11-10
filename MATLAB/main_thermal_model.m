clc;
clear;
close all;

%% Rising Main Thermal Model - Version 5.1
% Final validation model with:
% 1. Preissmann slot interpretation
% 2. 90% depth threshold
% 3. High-flow filtering
% 4. Temperature-drop outlier filtering
% 5. RM2 segment temperature profile
% 6. Segment-size sensitivity test
% 7. Model input documentation exported to Excel
% 8. Non-positive source depths excluded from physical depth-ratio analysis

%% 1. Select confidential Excel input file
%
% CONFIDENTIALITY:
% The source workbook is selected locally and is NOT uploaded by this script.
% Keep the original workbook outside GitHub and any public portfolio repository.
% Before publishing this script, review the pipe geometry/material parameters
% in Section 2 and confirm that they are approved for public disclosure.

[file, path] = uigetfile({'*.xlsx;*.xls'}, 'Select the confidential Rising Main Excel file');

if isequal(file,0)
    error('No Excel file selected.');
end

filename = fullfile(path, file);

disp('Input workbook selected successfully. Full file path is not displayed.');

try
    sheets = sheetnames(filename);
    disp('Sheets found in workbook:');
    disp(sheets);
catch
    error(['MATLAB cannot open this file as a valid workbook. ' ...
        'Open the file in Excel, save it again as .xlsx, then rerun this script.']);
end

%% 2. Pipe input data

pipeID = ["RM1"; "RM2"; "RM3"];

pipeLength = [1730; 3303; 2927];        % [m]
pipeDiameter_mm = [150; 600; 500];      % [mm]
pipeMaterial = ["PVC"; "Cast Iron"; "Unknown"];

nPipes = length(pipeID);

%% 3. Import hydraulic data

% Hydraulic data layout:
% A = flow time
% B:D = flow rate RM1, RM2, RM3 [m3/s]
% G = velocity time
% H:J = velocity RM1, RM2, RM3 [m/s]
% M = depth time
% N:P = depth RM1, RM2, RM3 [m]

try
    hydData = readmatrix(filename, 'Sheet', 2, 'Range', 'A3:P51');
catch
    hydData = readmatrix(filename, 'Sheet', 'Hydraulic data', 'Range', 'A3:P51');
end

hydData = hydData(~all(isnan(hydData),2), :);

time_hr = hydData(:,1);
hydraulicVelocityTime_hr = hydData(:,7);
hydraulicDepthTime_hr = hydData(:,13);

Q_all = hydData(:,2:4);
v_all = hydData(:,8:10);
depth_all = hydData(:,14:16);

% Check that flow, velocity and depth records use the same time axis.
timeTolerance_hr = 1e-6;
if numel(time_hr) ~= numel(hydraulicVelocityTime_hr) || ...
        numel(time_hr) ~= numel(hydraulicDepthTime_hr) || ...
        any(~isfinite(time_hr)) || ...
        any(abs(time_hr - hydraulicVelocityTime_hr) > timeTolerance_hr) || ...
        any(abs(time_hr - hydraulicDepthTime_hr) > timeTolerance_hr)
    error(['Hydraulic flow, velocity and depth time columns do not match. ' ...
        'Check the workbook before running the model.']);
end

%% 4. Import temperature data

% Temperature data layout:
% B = winter time
% C = winter inlet temperature
% F = summer time
% G = summer inlet temperature

try
    tempData = readmatrix(filename, 'Sheet', 3, 'Range', 'B3:G51');
catch
    tempData = readmatrix(filename, 'Sheet', 'Temperature data', 'Range', 'B3:G51');
end

tempData = tempData(~all(isnan(tempData),2), :);

temperatureWinterTime_hr = tempData(:,1);
T_in_winter = tempData(:,2);
temperatureSummerTime_hr = tempData(:,5);
T_in_summer = tempData(:,6);

%% 5. Validate and align imported data

nHyd = length(time_hr);
nTemp = length(T_in_winter);

% Do not silently truncate records: row-by-row truncation can pair the
% wrong hydraulic and temperature measurements.
if nHyd ~= nTemp || numel(T_in_summer) ~= nHyd
    error(['Hydraulic and temperature datasets contain different numbers ' ...
        'of records. Align the source data before running the model.']);
end

timeTolerance_hr = 1e-6;
if any(~isfinite(temperatureWinterTime_hr)) || ...
        any(~isfinite(temperatureSummerTime_hr)) || ...
        any(abs(time_hr - temperatureWinterTime_hr) > timeTolerance_hr) || ...
        any(abs(time_hr - temperatureSummerTime_hr) > timeTolerance_hr)
    error(['Hydraulic, winter-temperature and summer-temperature time ' ...
        'columns do not match. Align the time records before modelling.']);
end

validRows = isfinite(time_hr) & isfinite(T_in_winter) & isfinite(T_in_summer);

time_hr = time_hr(validRows);
Q_all = Q_all(validRows,:);
v_all = v_all(validRows,:);
depth_all = depth_all(validRows,:);
T_in_winter = T_in_winter(validRows);
T_in_summer = T_in_summer(validRows);

if numel(time_hr) < 2 || any(diff(time_hr) <= 0)
    error('At least two strictly increasing time records are required.');
end

timeIntervals_hr = diff(time_hr);
dt_hours = median(timeIntervals_hr, 'omitnan');

if any(abs(timeIntervals_hr - dt_hours) > max(1e-6, 0.01*dt_hours))
    warning(['Time records are not evenly spaced. Energy calculations use ' ...
        'the median time interval and should be checked against the actual ' ...
        'measurement schedule before reporting total energy.']);
end

%% 6. Convert depth units if required

% The thermal model needs depth in metres.
% If depth appears much larger than pipe diameter, assume it was imported in mm.

for p = 1:nPipes

    D_m = pipeDiameter_mm(p) / 1000;
    medianDepth = median(abs(depth_all(:,p)), 'omitnan');

    if medianDepth > 5 * D_m
        depth_all(:,p) = depth_all(:,p) / 1000;
        fprintf('Depth for %s appears to be in mm. Converted to m.\n', pipeID(p));
    end

end

%% 7. Seasonal temperature inputs

T_soil_winter = 9;       % [degC]
T_soil_summer = 13;      % [degC]

%% 8. Fluid property inputs

% Wastewater approximated as water

rho = 1000;              % [kg/m3]
cp = 4180;               % [J/kg.K]
mu = 0.001;              % [Pa.s]
k_w = 0.6;               % [W/m.K]
Pr = 7;                  % [-]

%% 9. Pipe and soil thermal inputs

k_soil = 1.5;            % [W/m.K]
r_soil = 2.0;            % [m]
t_pipe = 0.015;          % [m]

%% 10. Filtering and numerical inputs

% Preissmann slot interpretation:
% depth_ratio > 1 is allowed because this represents surcharge/pressurised
% head through a virtual slot above the pipe crown.

use_preissmann_slot = true;


% Near-full/full/surcharged pipe threshold
depth_threshold = 0.90;

% High-flow filter:
% Uses only the upper 10% of positive near-full/surcharged flow values.
high_flow_percentile = 90;

% Safety limits to avoid division by zero
Q_safety_min = 1e-9;
v_safety_min = 1e-9;

% Maximum acceptable temperature drop for steady high-flow model
% These remove unrealistic low-flow/transitional spikes.
max_winter_deltaT = 0.20;    % [degC]
max_summer_deltaT = 0.50;    % [degC]

% Main number of axial pipe segments
Nseg = 200;

% Segment-size sensitivity test
segmentList = [25; 50; 100; 200; 500; 1000];

%% 11. Validate depths, calculate depth ratios and high-flow thresholds

nTime = length(time_hr);

% A physical water depth and the corresponding depth-to-diameter ratio
% cannot be zero or negative. Retain depth_all unchanged for traceability,
% but exclude non-positive or non-finite values from the ratio analysis.
valid_depth_all = isfinite(depth_all) & depth_all > 0;

depth_ratio_valid = NaN(nTime, nPipes);
Q_high_threshold_all = NaN(1, nPipes);
NearFullCandidatePoints = NaN(nPipes,1);
SurchargedCandidatePoints = NaN(nPipes,1);
InvalidOrNonPositiveDepthPoints = sum(~valid_depth_all, 1)';

for p = 1:nPipes

    D = pipeDiameter_mm(p) / 1000;

    % Calculate d/D only where source depth is physically valid.
    depth_ratio_valid(valid_depth_all(:,p),p) = ...
        depth_all(valid_depth_all(:,p),p) / D;

    % Valid hydraulic candidates for high-flow threshold
    candidateMask = valid_depth_all(:,p) & ...
                    isfinite(Q_all(:,p)) & isfinite(v_all(:,p)) & ...
                    isfinite(depth_ratio_valid(:,p)) & ...
                    Q_all(:,p) > 0 & v_all(:,p) > 0 & ...
                    depth_ratio_valid(:,p) >= depth_threshold;

    Q_candidates = Q_all(candidateMask,p);

    NearFullCandidatePoints(p) = sum(candidateMask);
    SurchargedCandidatePoints(p) = sum(valid_depth_all(:,p) & ...
        depth_ratio_valid(:,p) >= 1.0 & Q_all(:,p) > 0 & v_all(:,p) > 0);

    if ~isempty(Q_candidates)
        Q_high_threshold_all(p) = prctile(Q_candidates, high_flow_percentile);
    end

end

disp('Non-positive or non-finite source-depth points excluded from depth-ratio analysis:');
disp(array2table(InvalidOrNonPositiveDepthPoints, ...
    'VariableNames', {'ExcludedDepthPoints'}, ...
    'RowNames', cellstr(pipeID)));

disp('High-flow thresholds for each pipe [m3/s]:');
disp(array2table(Q_high_threshold_all', ...
    'VariableNames', {'HighFlowThreshold_m3s'}, ...
    'RowNames', cellstr(pipeID)));

%% 12. Preallocate result arrays

T_out_winter_all = NaN(nTime, nPipes);
T_out_summer_all = NaN(nTime, nPipes);

deltaT_winter_all = NaN(nTime, nPipes);
deltaT_summer_all = NaN(nTime, nPipes);

heat_loss_winter_all = NaN(nTime, nPipes);
heat_loss_summer_all = NaN(nTime, nPipes);

Re_all = NaN(nTime, nPipes);
h_all = NaN(nTime, nPipes);
R_total_all = NaN(nTime, nPipes);
depth_ratio_all = NaN(nTime, nPipes);
validFlag_all = false(nTime, nPipes);

%% 13. Main model loop

for p = 1:nPipes

    L = pipeLength(p);
    D = pipeDiameter_mm(p) / 1000;

    r_i = D/2;
    r_o = r_i + t_pipe;
    dx = L / Nseg;

    k_pipe = get_pipe_conductivity(pipeMaterial(p));

    for n = 1:nTime

        Q = Q_all(n,p);
        v = v_all(n,p);
        depth = depth_all(n,p);

        if ~isfinite(Q) || ~isfinite(v) || ~isfinite(depth)
            continue;
        end

        % Non-positive source depths are invalid for physical d/D analysis.
        % Do not replace them with zero; leave the ratio as NaN.
        if ~valid_depth_all(n,p)
            continue;
        end

        depth_ratio = depth_ratio_valid(n,p);
        depth_ratio_all(n,p) = depth_ratio;

        % With Preissmann slot, depth_ratio > 1 is retained as surcharged flow.
        if use_preissmann_slot == false
            if depth_ratio > 1.20
                continue;
            end
        end

        % Apply 90% near-full/full/surcharged threshold
        if depth_ratio < depth_threshold
            continue;
        end

        % Apply high-flow threshold
        if isnan(Q_high_threshold_all(p)) || Q < Q_high_threshold_all(p)
            continue;
        end

        % Safety checks
        if Q <= Q_safety_min || v <= v_safety_min
            continue;
        end

        mdot = rho * Q;

        Re = (rho * v * D) / mu;
        Re_all(n,p) = Re;

        if Re < 2300
            Nu = 3.66;
        else
            Nu = 0.023 * Re^0.8 * Pr^0.4;
        end

        h_i = (Nu * k_w) / D;
        h_all(n,p) = h_i;

        R_conv = 1 / (h_i * 2*pi*r_i);
        R_pipe = log(r_o/r_i) / (2*pi*k_pipe);
        R_soil = log(r_soil/r_o) / (2*pi*k_soil);

        R_total = R_conv + R_pipe + R_soil;
        R_total_all(n,p) = R_total;

        %% Winter calculation

        T = T_in_winter(n);

        for j = 1:Nseg
            q_per_m = (T - T_soil_winter) / R_total;
            q_seg = q_per_m * dx;
            dT = q_seg / (mdot * cp);
            T = T - dT;
        end

        winterDeltaT = T_in_winter(n) - T;

        if winterDeltaT <= max_winter_deltaT
            T_out_winter_all(n,p) = T;
            deltaT_winter_all(n,p) = winterDeltaT;
            heat_loss_winter_all(n,p) = mdot * cp * winterDeltaT;
        end

        %% Summer calculation

        T = T_in_summer(n);

        for j = 1:Nseg
            q_per_m = (T - T_soil_summer) / R_total;
            q_seg = q_per_m * dx;
            dT = q_seg / (mdot * cp);
            T = T - dT;
        end

        summerDeltaT = T_in_summer(n) - T;

        if summerDeltaT <= max_summer_deltaT
            T_out_summer_all(n,p) = T;
            deltaT_summer_all(n,p) = summerDeltaT;
            heat_loss_summer_all(n,p) = mdot * cp * summerDeltaT;
        end

        % A point is only fully valid if both seasonal calculations passed.
        if ~isnan(deltaT_winter_all(n,p)) && ~isnan(deltaT_summer_all(n,p))
            validFlag_all(n,p) = true;
        end

    end

end

%% 14. Valid point check

ValidModelledPoints_check = sum(validFlag_all, 1);

for p = 1:nPipes

    fprintf('%s valid modelled points after filtering: %d\n', ...
        pipeID(p), ValidModelledPoints_check(p));

    if ValidModelledPoints_check(p) == 0
        warning('%s has no valid points after the depth, high-flow and DeltaT filters.', pipeID(p));
    elseif ValidModelledPoints_check(p) < 5
        warning('%s has fewer than 5 valid points. Interpret results carefully.', pipeID(p));
    end

end

%% 15. Plot valid positive depth ratios and Preissmann slot interpretation

figure;
plot(time_hr, depth_ratio_valid(:,1), 'o-', 'LineWidth', 1.5);
hold on;
plot(time_hr, depth_ratio_valid(:,2), 's-', 'LineWidth', 1.5);
plot(time_hr, depth_ratio_valid(:,3), 'd-', 'LineWidth', 1.5);

yline(depth_threshold, '--', '90% near-full threshold', 'LineWidth', 1.5);
yline(1.00, ':', 'Pipe full / crown level', 'LineWidth', 1.5);

grid on;
xlabel('Time [hours]');
ylabel('Depth ratio, depth / diameter [-]');
title('Valid Positive Depth Ratios with Preissmann Slot Surcharge Representation');
legend('RM1','RM2','RM3','90% threshold','Full pipe level','Location','best');

%% 16. Plot winter inlet and outlet temperatures

for p = 1:nPipes

    figure;
    plot(time_hr, T_in_winter, 'o-', 'LineWidth', 1.5);
    hold on;
    plot(time_hr, T_out_winter_all(:,p), 's-', 'LineWidth', 1.5);
    grid on;
    xlabel('Time [hours]');
    ylabel('Temperature [deg C]');
    title(pipeID(p) + " Winter: Inlet and Modelled Outlet Temperature");
    legend('Inlet temperature', 'Modelled outlet temperature', 'Location', 'best');

end

%% 17. Plot summer inlet and outlet temperatures

for p = 1:nPipes

    figure;
    plot(time_hr, T_in_summer, 'o-', 'LineWidth', 1.5);
    hold on;
    plot(time_hr, T_out_summer_all(:,p), 's-', 'LineWidth', 1.5);
    grid on;
    xlabel('Time [hours]');
    ylabel('Temperature [deg C]');
    title(pipeID(p) + " Summer: Inlet and Modelled Outlet Temperature");
    legend('Inlet temperature', 'Modelled outlet temperature', 'Location', 'best');

end

%% 18. Plot temperature drop comparisons

figure;
plot(time_hr, deltaT_winter_all(:,1), 'o-', 'LineWidth', 1.5);
hold on;
plot(time_hr, deltaT_winter_all(:,2), 's-', 'LineWidth', 1.5);
plot(time_hr, deltaT_winter_all(:,3), 'd-', 'LineWidth', 1.5);
grid on;
xlabel('Time [hours]');
ylabel('Temperature drop [deg C]');
title('Winter Modelled Temperature Drop Comparison');
legend('RM1','RM2','RM3','Location','best');

figure;
plot(time_hr, deltaT_summer_all(:,1), 'o-', 'LineWidth', 1.5);
hold on;
plot(time_hr, deltaT_summer_all(:,2), 's-', 'LineWidth', 1.5);
plot(time_hr, deltaT_summer_all(:,3), 'd-', 'LineWidth', 1.5);
grid on;
xlabel('Time [hours]');
ylabel('Temperature drop [deg C]');
title('Summer Modelled Temperature Drop Comparison');
legend('RM1','RM2','RM3','Location','best');

%% 19. Plot heat loss comparisons

figure;
plot(time_hr, heat_loss_winter_all(:,1)/1000, 'o-', 'LineWidth', 1.5);
hold on;
plot(time_hr, heat_loss_winter_all(:,2)/1000, 's-', 'LineWidth', 1.5);
plot(time_hr, heat_loss_winter_all(:,3)/1000, 'd-', 'LineWidth', 1.5);
grid on;
xlabel('Time [hours]');
ylabel('Heat loss [kW]');
title('Winter Modelled Heat Loss Comparison');
legend('RM1','RM2','RM3','Location','best');

figure;
plot(time_hr, heat_loss_summer_all(:,1)/1000, 'o-', 'LineWidth', 1.5);
hold on;
plot(time_hr, heat_loss_summer_all(:,2)/1000, 's-', 'LineWidth', 1.5);
plot(time_hr, heat_loss_summer_all(:,3)/1000, 'd-', 'LineWidth', 1.5);
grid on;
xlabel('Time [hours]');
ylabel('Heat loss [kW]');
title('Summer Modelled Heat Loss Comparison');
legend('RM1','RM2','RM3','Location','best');

%% 20. RM2 segment temperature profile

targetPipe = 2;      % RM2
p = targetPipe;

validProfileRows = find(validFlag_all(:,p));

if isempty(validProfileRows)

    warning('No valid RM2 time step found for segment profile.');

else

    % Select the valid time step with the highest RM2 flow rate.
    [~, localIndex] = max(Q_all(validProfileRows,p));
    profileTimeIndex = validProfileRows(localIndex);

    fprintf('RM2 segment profile selected at time %.2f hr with flow %.4f m3/s.\n', ...
        time_hr(profileTimeIndex), Q_all(profileTimeIndex,p));

    [x_profile, T_profile_winter, T_profile_summer] = calculate_temperature_profile( ...
        pipeLength(p), pipeDiameter_mm(p), pipeMaterial(p), ...
        Q_all(profileTimeIndex,p), v_all(profileTimeIndex,p), ...
        T_in_winter(profileTimeIndex), T_in_summer(profileTimeIndex), ...
        T_soil_winter, T_soil_summer, ...
        rho, cp, mu, k_w, Pr, ...
        k_soil, r_soil, t_pipe, Nseg);

    figure;
    plot(x_profile, T_profile_winter, 'LineWidth', 1.8);
    hold on;
    plot(x_profile, T_profile_summer, 'LineWidth', 1.8);
    grid on;
    xlabel('Distance along pipe [m]');
    ylabel('Wastewater temperature [deg C]');
    title(pipeID(p) + " Temperature Profile Along Pipe Length at Time = " + time_hr(profileTimeIndex) + " hr");
    legend('Winter profile', 'Summer profile', 'Location', 'best');

end

%% 21. Segment-size sensitivity test for RM2

Sensitivity_Nseg = segmentList;
Sensitivity_dx_m = NaN(length(segmentList),1);
Sensitivity_WinterOutlet_C = NaN(length(segmentList),1);
Sensitivity_SummerOutlet_C = NaN(length(segmentList),1);
Sensitivity_WinterDeltaT_C = NaN(length(segmentList),1);
Sensitivity_SummerDeltaT_C = NaN(length(segmentList),1);

if exist('profileTimeIndex', 'var')

    for i = 1:length(segmentList)

        Nseg_test = segmentList(i);

        [x_test, T_test_winter, T_test_summer] = calculate_temperature_profile( ...
            pipeLength(p), pipeDiameter_mm(p), pipeMaterial(p), ...
            Q_all(profileTimeIndex,p), v_all(profileTimeIndex,p), ...
            T_in_winter(profileTimeIndex), T_in_summer(profileTimeIndex), ...
            T_soil_winter, T_soil_summer, ...
            rho, cp, mu, k_w, Pr, ...
            k_soil, r_soil, t_pipe, Nseg_test);

        Sensitivity_dx_m(i) = pipeLength(p) / Nseg_test;
        Sensitivity_WinterOutlet_C(i) = T_test_winter(end);
        Sensitivity_SummerOutlet_C(i) = T_test_summer(end);
        Sensitivity_WinterDeltaT_C(i) = T_in_winter(profileTimeIndex) - T_test_winter(end);
        Sensitivity_SummerDeltaT_C(i) = T_in_summer(profileTimeIndex) - T_test_summer(end);

    end

    figure;
    plot(Sensitivity_Nseg, Sensitivity_WinterDeltaT_C, 'o-', 'LineWidth', 1.6);
    hold on;
    plot(Sensitivity_Nseg, Sensitivity_SummerDeltaT_C, 's-', 'LineWidth', 1.6);
    grid on;
    xlabel('Number of pipe segments');
    ylabel('Predicted temperature drop [deg C]');
    title(pipeID(p) + " Segment-Size Sensitivity Test");
    legend('Winter Delta T', 'Summer Delta T', 'Location', 'best');

    figure;
    plot(Sensitivity_dx_m, Sensitivity_WinterDeltaT_C, 'o-', 'LineWidth', 1.6);
    hold on;
    plot(Sensitivity_dx_m, Sensitivity_SummerDeltaT_C, 's-', 'LineWidth', 1.6);
    grid on;
    xlabel('Element size, dx [m]');
    ylabel('Predicted temperature drop [deg C]');
    title(pipeID(p) + " Element-Size Sensitivity Test");
    legend('Winter Delta T', 'Summer Delta T', 'Location', 'best');

end

%% 22. Results summary table

AvgWinterDrop = mean(deltaT_winter_all, 1, 'omitnan')';
AvgSummerDrop = mean(deltaT_summer_all, 1, 'omitnan')';

MaxWinterDrop = max(deltaT_winter_all, [], 1, 'omitnan')';
MaxSummerDrop = max(deltaT_summer_all, [], 1, 'omitnan')';

AvgWinterHeatLoss_kW = mean(heat_loss_winter_all/1000, 1, 'omitnan')';
AvgSummerHeatLoss_kW = mean(heat_loss_summer_all/1000, 1, 'omitnan')';

MaxWinterHeatLoss_kW = max(heat_loss_winter_all/1000, [], 1, 'omitnan')';
MaxSummerHeatLoss_kW = max(heat_loss_summer_all/1000, [], 1, 'omitnan')';

ValidModelledPoints = sum(validFlag_all, 1)';

AvgDepthRatio = mean(depth_ratio_valid, 1, 'omitnan')';
MaxDepthRatio = max(depth_ratio_valid, [], 1, 'omitnan')';

SurchargedPoints = sum(depth_ratio_valid >= 1.0, 1)';
NearFullOrSurchargedPoints = sum(depth_ratio_valid >= depth_threshold, 1)';

QHighThreshold_m3s = Q_high_threshold_all';

Summary = table(pipeID, pipeLength, pipeDiameter_mm, pipeMaterial, ...
    InvalidOrNonPositiveDepthPoints, AvgDepthRatio, MaxDepthRatio, ...
    SurchargedPoints, NearFullOrSurchargedPoints, ...
    QHighThreshold_m3s, ValidModelledPoints, ...
    AvgWinterDrop, AvgSummerDrop, MaxWinterDrop, MaxSummerDrop, ...
    AvgWinterHeatLoss_kW, AvgSummerHeatLoss_kW, ...
    MaxWinterHeatLoss_kW, MaxSummerHeatLoss_kW, ...
    'VariableNames', {'PipeID','Length_m','Diameter_mm','Material', ...
    'InvalidOrNonPositiveDepthPoints','AvgDepthRatio','MaxDepthRatio', ...
    'SurchargedPoints','NearFullOrSurchargedPoints', ...
    'HighFlowThreshold_m3s','ValidModelledPoints', ...
    'AvgWinterDeltaT_C','AvgSummerDeltaT_C', ...
    'MaxWinterDeltaT_C','MaxSummerDeltaT_C', ...
    'AvgWinterHeatLoss_kW','AvgSummerHeatLoss_kW', ...
    'MaxWinterHeatLoss_kW','MaxSummerHeatLoss_kW'});

disp('--- Final Preissmann Slot Depth-Threshold Model Summary ---');
disp(Summary); 
%% 22b. Energy calculation from modelled heat loss

% The model calculates heat loss as power [kW].
% Energy is obtained by integrating heat loss over time.
%
% Since the dataset is hourly, each valid modelled point is assumed to
% represent one hour of operation.
%
% Energy [kWh] = Heat loss [kW] * time [h]

% dt_hours was validated from the imported time vector in Section 5.

WinterEnergy_kWh = NaN(nPipes,1);
SummerEnergy_kWh = NaN(nPipes,1);

WinterEnergy_MJ = NaN(nPipes,1);
SummerEnergy_MJ = NaN(nPipes,1);

AverageWinterPower_kW = NaN(nPipes,1);
AverageSummerPower_kW = NaN(nPipes,1);

ValidWinterEnergyPoints = NaN(nPipes,1);
ValidSummerEnergyPoints = NaN(nPipes,1);

for p = 1:nPipes

    % Valid winter heat-loss points
    winterMask = ~isnan(heat_loss_winter_all(:,p));
    summerMask = ~isnan(heat_loss_summer_all(:,p));

    ValidWinterEnergyPoints(p) = sum(winterMask);
    ValidSummerEnergyPoints(p) = sum(summerMask);

    % Convert W to kW, then integrate over valid hourly periods
    winterHeatLoss_kW = heat_loss_winter_all(winterMask,p) / 1000;
    summerHeatLoss_kW = heat_loss_summer_all(summerMask,p) / 1000;

    WinterEnergy_kWh(p) = sum(winterHeatLoss_kW * dt_hours);
    SummerEnergy_kWh(p) = sum(summerHeatLoss_kW * dt_hours);

    % Convert kWh to MJ
    WinterEnergy_MJ(p) = WinterEnergy_kWh(p) * 3.6;
    SummerEnergy_MJ(p) = SummerEnergy_kWh(p) * 3.6;

    % Average power over valid modelled points
    AverageWinterPower_kW(p) = mean(winterHeatLoss_kW, 'omitnan');
    AverageSummerPower_kW(p) = mean(summerHeatLoss_kW, 'omitnan');

end

EnergySummary = table(pipeID, ValidWinterEnergyPoints, ValidSummerEnergyPoints, ...
    AverageWinterPower_kW, AverageSummerPower_kW, ...
    WinterEnergy_kWh, SummerEnergy_kWh, ...
    WinterEnergy_MJ, SummerEnergy_MJ, ...
    'VariableNames', {'PipeID','ValidWinterEnergyPoints','ValidSummerEnergyPoints', ...
    'AverageWinterPower_kW','AverageSummerPower_kW', ...
    'WinterEnergy_kWh','SummerEnergy_kWh', ...
    'WinterEnergy_MJ','SummerEnergy_MJ'});

disp('--- Modelled Thermal Energy Dissipated ---');
disp(EnergySummary);


%% 23. Segment sensitivity table

if exist('profileTimeIndex', 'var')

    SegmentSensitivity = table(Sensitivity_Nseg, Sensitivity_dx_m, ...
        Sensitivity_WinterOutlet_C, Sensitivity_SummerOutlet_C, ...
        Sensitivity_WinterDeltaT_C, Sensitivity_SummerDeltaT_C, ...
        'VariableNames', {'NumberOfSegments','ElementSize_m', ...
        'WinterOutlet_C','SummerOutlet_C', ...
        'WinterDeltaT_C','SummerDeltaT_C'});

    disp('--- RM2 Segment-Size Sensitivity Table ---');
    disp(SegmentSensitivity);

end

%% 23b. Flow-rate and heat extraction potential analysis

% This section estimates how much heat could be extracted from the wastewater
% for different assumed heat-exchanger temperature drops.
%
% Extractable heat [kW] = rho * Q * cp * DeltaT_extract / 1000
%
% This is not the same as natural heat loss to soil. It estimates potential
% heat extraction by a heat exchanger.

DeltaT_extract_cases = [0.25; 0.50; 1.00; 2.00];   % [degC]

hx_efficiency = 0.70;   % assumed heat exchanger efficiency

% dt_hours was validated from the imported time vector in Section 5.

nCases = length(DeltaT_extract_cases);
nRows = nPipes * nCases;

% Preallocate result variables
PipeID_extract = strings(nRows,1);
AssumedDeltaTExtract_C = NaN(nRows,1);
HeatExchangerEfficiency = NaN(nRows,1);
ValidPoints_extract = NaN(nRows,1);
AvgFlowRate_m3s = NaN(nRows,1);
MaxFlowRate_m3s = NaN(nRows,1);
AvgUsefulExtractableHeat_kW = NaN(nRows,1);
MaxUsefulExtractableHeat_kW = NaN(nRows,1);
UsefulExtractableEnergy_kWh = NaN(nRows,1);
TheoreticalWastewaterEnergy_kWh = NaN(nRows,1);

row = 0;

for p = 1:nPipes

    validMask = validFlag_all(:,p) & ~isnan(Q_all(:,p)) & Q_all(:,p) > 0;

    for c = 1:nCases

        row = row + 1;

        DeltaT_extract = DeltaT_extract_cases(c);

        PipeID_extract(row) = pipeID(p);
        AssumedDeltaTExtract_C(row) = DeltaT_extract;
        HeatExchangerEfficiency(row) = hx_efficiency;
        ValidPoints_extract(row) = sum(validMask);

        if sum(validMask) == 0

            AvgFlowRate_m3s(row) = NaN;
            MaxFlowRate_m3s(row) = NaN;
            AvgUsefulExtractableHeat_kW(row) = NaN;
            MaxUsefulExtractableHeat_kW(row) = NaN;
            UsefulExtractableEnergy_kWh(row) = NaN;
            TheoreticalWastewaterEnergy_kWh(row) = NaN;

        else

            Q_valid = Q_all(validMask,p);

            % Theoretical wastewater-side heat available [kW]
            TheoreticalHeat_kW = rho .* Q_valid .* cp .* DeltaT_extract ./ 1000;

            % Useful extracted heat after assumed heat exchanger efficiency [kW]
            ExtractableHeat_kW = hx_efficiency .* TheoreticalHeat_kW;

            AvgFlowRate_m3s(row) = mean(Q_valid, 'omitnan');
            MaxFlowRate_m3s(row) = max(Q_valid, [], 'omitnan');

            AvgUsefulExtractableHeat_kW(row) = mean(ExtractableHeat_kW, 'omitnan');
            MaxUsefulExtractableHeat_kW(row) = max(ExtractableHeat_kW, [], 'omitnan');

            UsefulExtractableEnergy_kWh(row) = sum(ExtractableHeat_kW .* dt_hours, 'omitnan');
            TheoreticalWastewaterEnergy_kWh(row) = sum(TheoreticalHeat_kW .* dt_hours, 'omitnan');

        end

    end

end

FlowHeatSummary = table(PipeID_extract, AssumedDeltaTExtract_C, HeatExchangerEfficiency, ...
    ValidPoints_extract, AvgFlowRate_m3s, MaxFlowRate_m3s, ...
    AvgUsefulExtractableHeat_kW, MaxUsefulExtractableHeat_kW, ...
    UsefulExtractableEnergy_kWh, TheoreticalWastewaterEnergy_kWh, ...
    'VariableNames', {'PipeID','AssumedDeltaTExtract_C','HeatExchangerEfficiency', ...
    'ValidPoints','AvgFlowRate_m3s','MaxFlowRate_m3s', ...
    'AvgUsefulExtractableHeat_kW','MaxUsefulExtractableHeat_kW', ...
    'UsefulExtractableEnergy_kWh','TheoreticalWastewaterEnergy_kWh'});

disp('--- Flow Rate and Heat Extraction Potential Summary ---');
disp(FlowHeatSummary);
%% 23c. RM2 flow rate versus extractable heat plot

targetPipe = 2;   % RM2
p = targetPipe;

validMask = validFlag_all(:,p) & ~isnan(Q_all(:,p)) & Q_all(:,p) > 0;

if sum(validMask) == 0

    warning('No valid RM2 points available for flow-rate heat extraction plot.');

else

    Q_valid = Q_all(validMask,p);

    figure;
    hold on;

    for c = 1:length(DeltaT_extract_cases)

        DeltaT_extract = DeltaT_extract_cases(c);

        TheoreticalHeat_kW = rho .* Q_valid .* cp .* DeltaT_extract ./ 1000;
        ExtractableHeat_kW = hx_efficiency .* TheoreticalHeat_kW;

        plot(Q_valid, ExtractableHeat_kW, 'o-', 'LineWidth', 1.5);

    end

    grid on;
    xlabel('Flow rate [m^3/s]');
    ylabel('Useful extractable heat [kW]');
    title('RM2 Flow Rate versus Useful Extractable Heat');

    legend('0.25deg C extraction', '0.50deg C extraction', '1.00deg C extraction', '2.00deg C extraction', ...
        'Location', 'best');

end
%% 23d. RM2 extractable heat over time

targetPipe = 2;   % RM2
p = targetPipe;

% Choose one extraction case for time-series display
DeltaT_extract_selected = 1.00;    % [degC]

validMask = validFlag_all(:,p) & ~isnan(Q_all(:,p)) & Q_all(:,p) > 0;

ExtractableHeatTime_kW = NaN(nTime,1);

ExtractableHeatTime_kW(validMask) = hx_efficiency .* ...
    rho .* Q_all(validMask,p) .* cp .* DeltaT_extract_selected ./ 1000;

figure;
yyaxis left
plot(time_hr, Q_all(:,p), 'o-', 'LineWidth', 1.5);
ylabel('Flow rate [m^3/s]');

yyaxis right
plot(time_hr, ExtractableHeatTime_kW, 's-', 'LineWidth', 1.5);
ylabel('Useful extractable heat [kW]');

grid on;
xlabel('Time [hours]');
title('RM2 Flow Rate and Useful Extractable Heat Over Time');
legend('Flow rate', 'Useful extractable heat, 1deg C extraction', 'Location', 'best');
%% 23e. Parametric flow-rate sweep for heat extraction potential

% This section investigates the effect of flow rate on useful extractable heat.
% Instead of only using the measured valid RM2 flow points, it tests a wider
% range of possible flow rates.
%
% Useful extractable heat [kW] =
% hx_efficiency * rho * Q * cp * DeltaT_extract / 1000

targetPipe = 2;   % RM2 used as the reference pipe for this sweep

% Parametric flow-rate range [m3/s]
% This range can be adjusted depending on the observed RM2 flow values.
Q_sweep = linspace(0.02, 0.25, 100)';

% Heat exchanger extraction temperature drops [degC]
DeltaT_extract_cases = [0.25; 0.50; 1.00; 2.00];

% Heat exchanger efficiency
hx_efficiency = 0.70;

nQ = length(Q_sweep);
nCases = length(DeltaT_extract_cases);

% Preallocate heat extraction matrix
% Rows = flow-rate values
% Columns = DeltaT extraction cases
UsefulHeatSweep_kW = NaN(nQ, nCases);
TheoreticalHeatSweep_kW = NaN(nQ, nCases);

for c = 1:nCases

    DeltaT_extract = DeltaT_extract_cases(c);

    % Theoretical wastewater-side thermal power [kW]
    TheoreticalHeatSweep_kW(:,c) = rho .* Q_sweep .* cp .* DeltaT_extract ./ 1000;

    % Useful heat after heat exchanger efficiency [kW]
    UsefulHeatSweep_kW(:,c) = hx_efficiency .* TheoreticalHeatSweep_kW(:,c);

end

%% Create table for parametric sweep

ParametricSweepTable = table(Q_sweep, ...
    UsefulHeatSweep_kW(:,1), UsefulHeatSweep_kW(:,2), ...
    UsefulHeatSweep_kW(:,3), UsefulHeatSweep_kW(:,4), ...
    TheoreticalHeatSweep_kW(:,1), TheoreticalHeatSweep_kW(:,2), ...
    TheoreticalHeatSweep_kW(:,3), TheoreticalHeatSweep_kW(:,4), ...
    'VariableNames', {'FlowRate_m3s', ...
    'UsefulHeat_0p25C_kW','UsefulHeat_0p50C_kW', ...
    'UsefulHeat_1p00C_kW','UsefulHeat_2p00C_kW', ...
    'TheoreticalHeat_0p25C_kW','TheoreticalHeat_0p50C_kW', ...
    'TheoreticalHeat_1p00C_kW','TheoreticalHeat_2p00C_kW'});

disp('--- RM2 Parametric Flow-Rate Sweep for Heat Extraction ---');
disp(ParametricSweepTable);

%% Plot parametric flow-rate sweep

figure;
plot(Q_sweep, UsefulHeatSweep_kW(:,1), 'LineWidth', 1.6);
hold on;
plot(Q_sweep, UsefulHeatSweep_kW(:,2), 'LineWidth', 1.6);
plot(Q_sweep, UsefulHeatSweep_kW(:,3), 'LineWidth', 1.6);
plot(Q_sweep, UsefulHeatSweep_kW(:,4), 'LineWidth', 1.6);

grid on;
xlabel('Flow rate [m^3/s]');
ylabel('Useful extractable heat [kW]');
title('RM2 Parametric Flow-Rate Sweep for Useful Heat Extraction');
legend('0.25deg C extraction','0.50deg C extraction','1.00deg C extraction','2.00deg C extraction', ...
    'Location', 'northwest');

%% Create smaller summary table at selected flow rates

SelectedFlowRates = [0.05; 0.10; 0.15; 0.20; 0.25];

UsefulHeat_Selected = NaN(length(SelectedFlowRates), nCases);

for c = 1:nCases

    DeltaT_extract = DeltaT_extract_cases(c);

    UsefulHeat_Selected(:,c) = hx_efficiency .* rho .* SelectedFlowRates .* cp .* DeltaT_extract ./ 1000;

end

ParametricSummaryTable = table(SelectedFlowRates, ...
    UsefulHeat_Selected(:,1), UsefulHeat_Selected(:,2), ...
    UsefulHeat_Selected(:,3), UsefulHeat_Selected(:,4), ...
    'VariableNames', {'FlowRate_m3s', ...
    'UsefulHeat_0p25C_kW','UsefulHeat_0p50C_kW', ...
    'UsefulHeat_1p00C_kW','UsefulHeat_2p00C_kW'});

disp('--- Selected Flow-Rate Heat Extraction Summary ---');
disp(ParametricSummaryTable);
%% 24. Soil thermal conductivity sensitivity analysis for RM2

% This section investigates the effect of different soil thermal
% conductivities on RM2 heat loss, temperature drop and dissipated energy.
%
% The same valid RM2 high-flow points from the main model are used for every
% soil case. This means the only variable being changed is soil thermal
% conductivity.

targetPipe = 2;          % RM2
p_soil = targetPipe;

% Mean soil thermal conductivity values [W/m.K]
% Values selected from the soil conductivity table.
SoilType = ["Sand dry";
            "Sand moist/wet";
            "Sand soaked";
            "Clay dry";
            "Clay wet";
            "Gravel sandy";
            "Limestone"];

SoilConductivity_WmK = [0.56;
                        0.955;
                        2.16;
                        0.435;
                        1.30;
                        2.51;
                        1.30];

nSoilCases = length(SoilConductivity_WmK);

% Use same RM2 geometry as the main model
L_soil = pipeLength(p_soil);
D_soil = pipeDiameter_mm(p_soil) / 1000;

r_i_soil = D_soil / 2;
r_o_soil = r_i_soil + t_pipe;
dx_soil = L_soil / Nseg;

k_pipe_soil = get_pipe_conductivity(pipeMaterial(p_soil));

% Use the same valid high-flow RM2 model points
validMask_soil = validFlag_all(:,p_soil) & ...
                 ~isnan(Q_all(:,p_soil)) & Q_all(:,p_soil) > Q_safety_min & ...
                 ~isnan(v_all(:,p_soil)) & v_all(:,p_soil) > v_safety_min;

dt_hours_soil = dt_hours;

% Preallocate summary variables
Soil_ValidPoints = NaN(nSoilCases,1);

Soil_AvgWinterDeltaT_C = NaN(nSoilCases,1);
Soil_AvgSummerDeltaT_C = NaN(nSoilCases,1);

Soil_MaxWinterDeltaT_C = NaN(nSoilCases,1);
Soil_MaxSummerDeltaT_C = NaN(nSoilCases,1);

Soil_AvgWinterHeatLoss_kW = NaN(nSoilCases,1);
Soil_AvgSummerHeatLoss_kW = NaN(nSoilCases,1);

Soil_MaxWinterHeatLoss_kW = NaN(nSoilCases,1);
Soil_MaxSummerHeatLoss_kW = NaN(nSoilCases,1);

Soil_WinterEnergyLoss_kWh = NaN(nSoilCases,1);
Soil_SummerEnergyLoss_kWh = NaN(nSoilCases,1);

Soil_AvgWinterOutletTemp_C = NaN(nSoilCases,1);
Soil_AvgSummerOutletTemp_C = NaN(nSoilCases,1);

% Optional time-series storage
Soil_WinterDeltaT_Time = NaN(nTime, nSoilCases);
Soil_SummerDeltaT_Time = NaN(nTime, nSoilCases);
Soil_WinterHeatLoss_Time_kW = NaN(nTime, nSoilCases);
Soil_SummerHeatLoss_Time_kW = NaN(nTime, nSoilCases);

for s = 1:nSoilCases

    k_soil_current = SoilConductivity_WmK(s);

    WinterOutletTemp_soil = NaN(nTime,1);
    SummerOutletTemp_soil = NaN(nTime,1);

    WinterDeltaT_soil = NaN(nTime,1);
    SummerDeltaT_soil = NaN(nTime,1);

    WinterHeatLoss_soil_W = NaN(nTime,1);
    SummerHeatLoss_soil_W = NaN(nTime,1);

    for n = 1:nTime

        if ~validMask_soil(n)
            continue;
        end

        Q_current = Q_all(n,p_soil);
        v_current = v_all(n,p_soil);

        mdot_current = rho * Q_current;

        Re_current = (rho * v_current * D_soil) / mu;

        if Re_current < 2300
            Nu_current = 3.66;
        else
            Nu_current = 0.023 * Re_current^0.8 * Pr^0.4;
        end

        h_i_current = (Nu_current * k_w) / D_soil;

        % Thermal resistance per metre
        R_conv_current = 1 / (h_i_current * 2*pi*r_i_soil);
        R_pipe_current = log(r_o_soil/r_i_soil) / (2*pi*k_pipe_soil);
        R_soil_current = log(r_soil/r_o_soil) / (2*pi*k_soil_current);

        R_total_current = R_conv_current + R_pipe_current + R_soil_current;

        %% Winter calculation for current soil

        T_current = T_in_winter(n);

        for j = 1:Nseg

            q_per_m_current = (T_current - T_soil_winter) / R_total_current;
            q_seg_current = q_per_m_current * dx_soil;
            dT_current = q_seg_current / (mdot_current * cp);

            T_current = T_current - dT_current;

        end

        WinterOutletTemp_soil(n) = T_current;
        WinterDeltaT_soil(n) = T_in_winter(n) - WinterOutletTemp_soil(n);
        WinterHeatLoss_soil_W(n) = mdot_current * cp * WinterDeltaT_soil(n);

        %% Summer calculation for current soil

        T_current = T_in_summer(n);

        for j = 1:Nseg

            q_per_m_current = (T_current - T_soil_summer) / R_total_current;
            q_seg_current = q_per_m_current * dx_soil;
            dT_current = q_seg_current / (mdot_current * cp);

            T_current = T_current - dT_current;

        end

        SummerOutletTemp_soil(n) = T_current;
        SummerDeltaT_soil(n) = T_in_summer(n) - SummerOutletTemp_soil(n);
        SummerHeatLoss_soil_W(n) = mdot_current * cp * SummerDeltaT_soil(n);

    end

    % Store time-series values
    Soil_WinterDeltaT_Time(:,s) = WinterDeltaT_soil;
    Soil_SummerDeltaT_Time(:,s) = SummerDeltaT_soil;

    Soil_WinterHeatLoss_Time_kW(:,s) = WinterHeatLoss_soil_W ./ 1000;
    Soil_SummerHeatLoss_Time_kW(:,s) = SummerHeatLoss_soil_W ./ 1000;

    % Summary values
    Soil_ValidPoints(s) = sum(validMask_soil);

    Soil_AvgWinterDeltaT_C(s) = mean(WinterDeltaT_soil, 'omitnan');
    Soil_AvgSummerDeltaT_C(s) = mean(SummerDeltaT_soil, 'omitnan');

    Soil_MaxWinterDeltaT_C(s) = max(WinterDeltaT_soil, [], 'omitnan');
    Soil_MaxSummerDeltaT_C(s) = max(SummerDeltaT_soil, [], 'omitnan');

    Soil_AvgWinterHeatLoss_kW(s) = mean(WinterHeatLoss_soil_W ./ 1000, 'omitnan');
    Soil_AvgSummerHeatLoss_kW(s) = mean(SummerHeatLoss_soil_W ./ 1000, 'omitnan');

    Soil_MaxWinterHeatLoss_kW(s) = max(WinterHeatLoss_soil_W ./ 1000, [], 'omitnan');
    Soil_MaxSummerHeatLoss_kW(s) = max(SummerHeatLoss_soil_W ./ 1000, [], 'omitnan');

    Soil_WinterEnergyLoss_kWh(s) = sum((WinterHeatLoss_soil_W ./ 1000) .* dt_hours_soil, 'omitnan');
    Soil_SummerEnergyLoss_kWh(s) = sum((SummerHeatLoss_soil_W ./ 1000) .* dt_hours_soil, 'omitnan');

    Soil_AvgWinterOutletTemp_C(s) = mean(WinterOutletTemp_soil, 'omitnan');
    Soil_AvgSummerOutletTemp_C(s) = mean(SummerOutletTemp_soil, 'omitnan');

end

SoilSensitivitySummary = table(SoilType, SoilConductivity_WmK, Soil_ValidPoints, ...
    Soil_AvgWinterDeltaT_C, Soil_AvgSummerDeltaT_C, ...
    Soil_MaxWinterDeltaT_C, Soil_MaxSummerDeltaT_C, ...
    Soil_AvgWinterHeatLoss_kW, Soil_AvgSummerHeatLoss_kW, ...
    Soil_MaxWinterHeatLoss_kW, Soil_MaxSummerHeatLoss_kW, ...
    Soil_WinterEnergyLoss_kWh, Soil_SummerEnergyLoss_kWh, ...
    Soil_AvgWinterOutletTemp_C, Soil_AvgSummerOutletTemp_C, ...
    'VariableNames', {'SoilType','SoilThermalConductivity_WmK','ValidPoints', ...
    'AvgWinterDeltaT_C','AvgSummerDeltaT_C', ...
    'MaxWinterDeltaT_C','MaxSummerDeltaT_C', ...
    'AvgWinterHeatLoss_kW','AvgSummerHeatLoss_kW', ...
    'MaxWinterHeatLoss_kW','MaxSummerHeatLoss_kW', ...
    'WinterEnergyLoss_kWh','SummerEnergyLoss_kWh', ...
    'AvgWinterOutletTemp_C','AvgSummerOutletTemp_C'});

disp('--- RM2 Soil Thermal Conductivity Sensitivity Summary ---');
disp(SoilSensitivitySummary);
%% 24b. Plot soil type effect on RM2 average heat loss

figure;

x_soil = categorical(cellstr(SoilType));
x_soil = reordercats(x_soil, cellstr(SoilType));

bar(x_soil, [Soil_AvgWinterHeatLoss_kW Soil_AvgSummerHeatLoss_kW]);

grid on;
xlabel('Soil condition');
ylabel('Average heat loss [kW]');
title('Effect of Soil Thermal Conductivity on RM2 Average Heat Loss');
legend('Winter','Summer','Location','northwest');
xtickangle(45);
%% 24c. Plot soil type effect on RM2 average temperature drop

figure;

bar(x_soil, [Soil_AvgWinterDeltaT_C Soil_AvgSummerDeltaT_C]);

grid on;
xlabel('Soil condition');
ylabel('Average temperature drop [deg C]');
title('Effect of Soil Thermal Conductivity on RM2 Average Temperature Drop');
legend('Winter','Summer','Location','northwest');
xtickangle(45);
%% 24d. Plot soil type effect on RM2 dissipated energy

figure;

bar(x_soil, [Soil_WinterEnergyLoss_kWh Soil_SummerEnergyLoss_kWh]);

grid on;
xlabel('Soil condition');
ylabel('Thermal energy dissipated [kWh]');
title('Effect of Soil Thermal Conductivity on RM2 Thermal Energy Dissipation');
legend('Winter','Summer','Location','northwest');
xtickangle(45);
%% 24e. Plot thermal conductivity versus average heat loss

[k_sorted, sortIndex] = sort(SoilConductivity_WmK);

figure;
plot(k_sorted, Soil_AvgWinterHeatLoss_kW(sortIndex), 'o-', 'LineWidth', 1.6);
hold on;
plot(k_sorted, Soil_AvgSummerHeatLoss_kW(sortIndex), 's-', 'LineWidth', 1.6);

grid on;
xlabel('Soil thermal conductivity [W/m.K]');
ylabel('Average heat loss [kW]');
title('RM2 Heat Loss Sensitivity to Soil Thermal Conductivity');
legend('Winter','Summer','Location','northwest');
%% 25. Input documentation tables

PipeInputs = table(pipeID, pipeLength, pipeDiameter_mm, pipeMaterial, ...
    [get_pipe_conductivity(pipeMaterial(1)); get_pipe_conductivity(pipeMaterial(2)); get_pipe_conductivity(pipeMaterial(3))], ...
    'VariableNames', {'PipeID','Length_m','Diameter_mm','Material','PipeThermalConductivity_WmK'});

SeasonalInputs = table( ...
    ["Winter"; "Summer"], ...
    [T_soil_winter; T_soil_summer], ...
    ["Winter inlet temperature from spreadsheet column C"; "Summer inlet temperature from spreadsheet column G"], ...
    'VariableNames', {'Season','SoilTemperature_C','InletTemperatureSource'});

FluidInputs = table( ...
    ["Density"; "Specific heat capacity"; "Dynamic viscosity"; "Water thermal conductivity"; "Prandtl number"], ...
    ["rho"; "cp"; "mu"; "k_w"; "Pr"], ...
    [rho; cp; mu; k_w; Pr], ...
    ["kg/m3"; "J/kg.K"; "Pa.s"; "W/m.K"; "-"], ...
    'VariableNames', {'Property','MATLABSymbol','Value','Unit'});

ThermalInputs = table( ...
    ["Soil thermal conductivity"; "Soil penetration radius"; "Pipe wall thickness"], ...
    ["k_soil"; "r_soil"; "t_pipe"], ...
    [k_soil; r_soil; t_pipe], ...
    ["W/m.K"; "m"; "m"], ...
    'VariableNames', {'Property','MATLABSymbol','Value','Unit'});

FilterInputs = table( ...
    ["Preissmann slot used"; ...
     "Valid physical depth requirement"; ...
     "Depth threshold"; ...
     "High-flow percentile"; ...
     "Winter maximum DeltaT filter"; ...
     "Summer maximum DeltaT filter"; ...
     "Q safety minimum"; ...
     "Velocity safety minimum"], ...
    ["use_preissmann_slot"; ...
     "valid_depth_all"; ...
     "depth_threshold"; ...
     "high_flow_percentile"; ...
     "max_winter_deltaT"; ...
     "max_summer_deltaT"; ...
     "Q_safety_min"; ...
     "v_safety_min"], ...
    [string(use_preissmann_slot); ...
     "depth > 0 and finite"; ...
     string(depth_threshold); ...
     string(high_flow_percentile); ...
     string(max_winter_deltaT); ...
     string(max_summer_deltaT); ...
     string(Q_safety_min); ...
     string(v_safety_min)], ...
    ["Preissmann slot allows depth ratio above 1 to represent surcharge/pressurised head"; ...
     "Excludes non-positive or non-finite source depths before calculating d/D"; ...
     "Keeps depth ratio >= 0.90"; ...
     "Keeps upper 10% of near-full/surcharged positive flow values"; ...
     "Removes unrealistic winter temperature-drop spikes"; ...
     "Removes unrealistic summer temperature-drop spikes"; ...
     "Avoids division by zero"; ...
     "Avoids invalid Reynolds number calculation"], ...
    'VariableNames', {'Input','MATLABSymbol','Value','Purpose'});

NumericalInputs = table( ...
    ["Main axial segments"; "Segment sensitivity cases"; "Element length calculation"], ...
    ["Nseg"; "segmentList"; "dx"], ...
    [string(Nseg); join(string(segmentList'), ", "); "L / Nseg"], ...
    ["Number of segments used for main model"; ...
     "Used to check whether element size affects outlet temperature"; ...
     "Pipe length divided by number of segments"], ...
    'VariableNames', {'Input','MATLABSymbol','Value','Purpose'});

HydraulicThresholdInputs = table(pipeID, InvalidOrNonPositiveDepthPoints, ...
    QHighThreshold_m3s, NearFullCandidatePoints, SurchargedCandidatePoints, ...
    'VariableNames', {'PipeID','InvalidOrNonPositiveDepthPoints', ...
    'HighFlowThreshold_m3s','NearFullCandidatePoints','SurchargedCandidatePoints'});

%% 26. Export all results and inputs
%
% The output workbook is written locally beside the selected source workbook.
% It may contain derived values from confidential inputs. Do NOT upload this
% output workbook, or any exported sheets/CSVs, to a public GitHub repository.

outputFile = fullfile(path, 'Rising_Main_Model_Results_V5_1_Preissmann_Validation.xlsx');

writetable(Summary, outputFile, 'Sheet', 'Summary');
writetable(FlowHeatSummary, outputFile, 'Sheet', 'Flow_Heat_Extraction');
writetable(EnergySummary, outputFile, 'Sheet', 'Energy_Summary');
writetable(SoilSensitivitySummary, outputFile, 'Sheet', 'Soil_Sensitivity');

writetable(PipeInputs, outputFile, 'Sheet', 'Input_Pipes');
writetable(SeasonalInputs, outputFile, 'Sheet', 'Input_Seasonal');
writetable(FluidInputs, outputFile, 'Sheet', 'Input_Fluid');
writetable(ThermalInputs, outputFile, 'Sheet', 'Input_Thermal');
writetable(FilterInputs, outputFile, 'Sheet', 'Input_Filters');
writetable(NumericalInputs, outputFile, 'Sheet', 'Input_Numerical');
writetable(HydraulicThresholdInputs, outputFile, 'Sheet', 'Input_HydraulicThresholds');
writetable(ParametricSweepTable, outputFile, 'Sheet', 'Parametric_Flow_Sweep');
writetable(ParametricSummaryTable, outputFile, 'Sheet', 'Parametric_Summary');

for p = 1:nPipes

    ResultsPipe = table(time_hr, Q_all(:,p), v_all(:,p), depth_all(:,p), ...
        valid_depth_all(:,p), depth_ratio_valid(:,p), ...
        validFlag_all(:,p), Re_all(:,p), h_all(:,p), R_total_all(:,p), ...
        T_in_winter, T_out_winter_all(:,p), deltaT_winter_all(:,p), heat_loss_winter_all(:,p)/1000, ...
        T_in_summer, T_out_summer_all(:,p), deltaT_summer_all(:,p), heat_loss_summer_all(:,p)/1000, ...
        'VariableNames', {'Time_hr','FlowRate_m3s','Velocity_ms','SourceDepth_m', ...
        'ValidPositiveDepth','DepthRatio', ...
        'ValidModelledPoint','ReynoldsNumber','h_internal_Wm2K','R_total_KmW', ...
        'Winter_Inlet_C','Winter_Outlet_C','Winter_DeltaT_C','Winter_HeatLoss_kW', ...
        'Summer_Inlet_C','Summer_Outlet_C','Summer_DeltaT_C','Summer_HeatLoss_kW'});

    writetable(ResultsPipe, outputFile, 'Sheet', char(pipeID(p)));

end

if exist('profileTimeIndex', 'var')

    SegmentProfile = table((0:Nseg)', x_profile(:), T_profile_winter(:), T_profile_summer(:), ...
        'VariableNames', {'SegmentNumber','Distance_m','WinterTemperature_C','SummerTemperature_C'});

    writetable(SegmentProfile, outputFile, 'Sheet', 'RM2_Profile');
    writetable(SegmentSensitivity, outputFile, 'Sheet', 'RM2_Sensitivity');

end

disp('Results and input documentation exported to the selected workbook folder.');

disp('Model complete.');
disp(['This version includes positive-depth validation, Preissmann slot interpretation, ' ...
    '90% depth threshold, high-flow filtering, DeltaT filtering, and input documentation.']);

%% Local functions
% Keep these functions at the end of this script. MATLAB scripts with local
% functions require the function definitions to follow all script commands.

%% Local function 1: pipe thermal conductivity

function k_pipe = get_pipe_conductivity(material)

    mat = upper(strtrim(string(material)));

    if contains(mat, "PVC")
        k_pipe = 0.19;       % [W/m.K]
    elseif contains(mat, "CAST")
        k_pipe = 52;         % [W/m.K]
    else
        k_pipe = 1.0;        % [W/m.K] placeholder for unknown material
    end

end

%% Local function 2: calculate temperature profile along pipe

function [x_profile, T_profile_winter, T_profile_summer] = calculate_temperature_profile( ...
    L, D_mm, material, Q, v, T_in_winter, T_in_summer, T_soil_winter, T_soil_summer, ...
    rho, cp, mu, k_w, Pr, k_soil, r_soil, t_pipe, Nseg)

    D = D_mm / 1000;
    r_i = D/2;
    r_o = r_i + t_pipe;
    dx = L / Nseg;

    k_pipe = get_pipe_conductivity(material);

    mdot = rho * Q;

    Re = (rho * v * D) / mu;

    if Re < 2300
        Nu = 3.66;
    else
        Nu = 0.023 * Re^0.8 * Pr^0.4;
    end

    h_i = (Nu * k_w) / D;

    R_conv = 1 / (h_i * 2*pi*r_i);
    R_pipe = log(r_o/r_i) / (2*pi*k_pipe);
    R_soil = log(r_soil/r_o) / (2*pi*k_soil);

    R_total = R_conv + R_pipe + R_soil;

    x_profile = linspace(0, L, Nseg+1);

    T_profile_winter = NaN(Nseg+1,1);
    T_profile_summer = NaN(Nseg+1,1);

    %% Winter profile

    T = T_in_winter;
    T_profile_winter(1) = T;

    for j = 1:Nseg
        q_per_m = (T - T_soil_winter) / R_total;
        q_seg = q_per_m * dx;
        dT = q_seg / (mdot * cp);
        T = T - dT;
        T_profile_winter(j+1) = T;
    end

    %% Summer profile

    T = T_in_summer;
    T_profile_summer(1) = T;

    for j = 1:Nseg
        q_per_m = (T - T_soil_summer) / R_total;
        q_seg = q_per_m * dx;
        dT = q_seg / (mdot * cp);
        T = T - dT;
        T_profile_summer(j+1) = T;
    end
end

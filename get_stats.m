% PULL CSV FILES INTO DATA STRUCTURE
% NOTE: DEPENDS PURELY ON THE LOCATION IN EACH CSV, DO NOT CHANGE THIS
    % also for some reason loading the CSV ignores the .mat filename, which
    % is ok for now but be careful out here
    % Parisi 12Aug2023

clc, clearvars, close all, format compact


% --Obtained List of CSVs
    % to access different folder of CSVs, you can change the currect folder
csvFiles = dir(fullfile('*.csv'));
dataStruct = struct();


% --Loop Through Each Files to Pull Information
for i = 1:length(csvFiles)
    
    % --Load file into a table
    fileData = readtable(csvFiles(i).name);

    % --Grab Truth x and y
    dataStruct.truthx(i) = fileData.Var2(1);
    dataStruct.truthy(i) = fileData.Var3(1);

    % --Grab Mean x and y
    dataStruct.meanx(i) = fileData.Var2(2);
    dataStruct.meany(i) = fileData.Var3(2);

    % --Grab Median x and y
    dataStruct.medianx(i) = fileData.Var2(3);
    dataStruct.mediany(i) = fileData.Var3(3);

    % --Grab Density x and y
    dataStruct.densityx(i) = fileData.Var2(4);
    dataStruct.densityy(i) = fileData.Var3(4);

    % --Grab Time
    dataStruct.time(i) = fileData.Var2(5);


end

disp('done loading, calculating stats')

% --Mean & StdDev Compute Time
stats.avg_time = mean(dataStruct.time);
stats.std_time = std(dataStruct.time);

% --Distances & Stats for Mean
stats.mean_dist = sqrt((dataStruct.meanx - dataStruct.truthx).^2 + (dataStruct.meany - dataStruct.truthy).^2);
stats.mean_dist_avg = mean(stats.mean_dist);
stats.meanx_stddev = std(dataStruct.meanx);
stats.meany_stddev = std(dataStruct.meany);

stats.mean_meanx = mean(dataStruct.meanx);
stats.mean_meany = mean(dataStruct.meany);

% --Distances & Stats for Median
stats.median_dist = sqrt((dataStruct.medianx - dataStruct.truthx).^2 + (dataStruct.mediany - dataStruct.truthy).^2);
stats.median_dist_avg = mean(stats.median_dist);
stats.medianx_stddev = std(dataStruct.medianx);
stats.mediany_stddev = std(dataStruct.mediany);

stats.mean_medianx = mean(dataStruct.medianx);
stats.mean_mediany = mean(dataStruct.mediany);

% --Distances & Stats for Density
stats.density_dist = sqrt((dataStruct.densityx - dataStruct.truthx).^2 + (dataStruct.densityy - dataStruct.truthy).^2);
stats.density_dist_avg = mean(stats.density_dist);
stats.densityx_stddev = std(dataStruct.densityx);
stats.densityy_stddev = std(dataStruct.densityy);

stats.mean_densityx = mean(dataStruct.densityx);
stats.mean_densityy = mean(dataStruct.densityy);
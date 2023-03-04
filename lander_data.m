% lander_data script
% Bonney and Parisi

% GOAL: Load data for particle filter localization.
clc, clearvars

%% Load lander data (lat, lon, range, depth)
fn_topside = "20180921_110812.mat"; % topside filename
fn_lander = "20180921_110738.mat"; % lander filename
load(fn_topside) % load topside .mat file into workspace
load(fn_lander) % load lander .mat file into workspace

ship.lat = gps_gprmc_t_GPS_GPRMC_DATA.lat;
ship.lon = gps_gprmc_t_GPS_GPRMC_DATA.lon;
ship.timestamp = gps_gprmc_t_GPS_GPRMC_DATA.timestamp
range.range = benthos_release_status_t_BENTHOS_RELEASE_STATUS.range;
range.timestamp = benthos_release_status_t_BENTHOS_RELEASE_STATUS.timestamp
lander.depth = lander_mission_state_t_MIS_STATE.depth;
lander.timestamp = lander_mission_state_t_MIS_STATE.timestamp

%% Plot lander data 
% ship GPS position
figure
plot(ship.lat,ship.lon)
title('Ship GPS Position'); xlabel('Latitude'); ylabel('Longitude')
grid on

% range measurements
figure 
plot(range.timestamp,range.range)
title('Range & Depth vs Time'); ylabel('Distance (meters)'); xlabel('Time')
grid on
hold on

% lander depth
plot(lander.timestamp,lander.depth)
legend('Range','Depth')
axis ij
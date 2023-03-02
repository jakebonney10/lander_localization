% lander_localization main script
% Bonney and Parisi

% GOAL: Particle filter localization of a full ocean depth autonomous surveyor.

clc, clearvars

%% Load lander data (lat, lon, range, depth)

fn_topside = "20180921_110812.mat"; % topside filename
fn_lander = "20180921_110738.mat"; % lander filename
load(fn_topside) % load topside .mat file into workspace
load(fn_lander) % load lander .mat file into workspace

lat = gps_gprmc_t_GPS_GPRMC_DATA.lat;
lon = gps_gprmc_t_GPS_GPRMC_DATA.lon;
range = benthos_release_status_t_BENTHOS_RELEASE_STATUS.range;
depth = lander_mission_state_t_MIS_STATE.depth;

%% Knowns

ocean_depth = 8000;
ssp = 1500;
range = range;
lat = lat;
lon = lon;

%% Particle initialization


%% Particle updates


%% Weights and particle culling


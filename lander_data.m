function [ship, measurement, lander] = lander_data(fn_topside, fn_lander)
% lander_data 
% Bonney and Parisi
% GOAL: Load lander data (lat, lon, range, depth) for particle filter localization.

load(fn_topside); % load topside .mat file into workspace
load(fn_lander); % load lander .mat file into workspace

ship.lat = gps_gprmc_t_GPS_GPRMC_DATA.lat;
ship.lon = gps_gprmc_t_GPS_GPRMC_DATA.lon;
ship.timestamp = double(gps_gprmc_t_GPS_GPRMC_DATA.timestamp)/1e6;

measurement.range = benthos_release_status_t_BENTHOS_RELEASE_STATUS.range;
measurement.timestamp = double(benthos_release_status_t_BENTHOS_RELEASE_STATUS.timestamp)/1e6;

% Get rid of all 0,1,2 NFG ranges 
idx = measurement.range > 2;
measurement.range = measurement.range(idx);
measurement.timestamp = measurement.timestamp(idx);

lander.depth = lander_mission_state_t_MIS_STATE.depth;
lander.timestamp = double(lander_mission_state_t_MIS_STATE.timestamp)/1e6;

end
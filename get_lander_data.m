function [ship, measurement, lander, ssp] = get_lander_data(fn_topside, fn_lander)
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

% Get rid of all 0,1,2 NFG ranges and ranges less than 150
idx = measurement.range > 150;
measurement.range = measurement.range(idx);
measurement.timestamp = measurement.timestamp(idx);

lander.depth = lander_mission_state_t_MIS_STATE.depth;
lander.timestamp = double(lander_mission_state_t_MIS_STATE.timestamp)/1e6;
lander.state = lander_mission_state_t_MIS_STATE.state;

% Load SSP info
ssp.pres_db = sbe9_data_t_SBE9_DATA.pres - 10.1325;
ssp.temp_its90 = sbe9_data_t_SBE9_DATA.temp;
ssp.sal_psu = sbe9_data_t_SBE9_DATA.sal;
ssp.ctd_t = double(sbe9_data_t_SBE9_DATA.timestamp);

end
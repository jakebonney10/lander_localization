
% Load table of iridium GPS data
iridium_tb = readtable('lander_iridium_sept2018.csv');
iridium_tb = sortrows(iridium_tb,"DataDate_EST_","ascend")
utc_time = iridium_tb.DataDate_EST_ + hours(4) % Convert to utc time from est

% Convert origin time to datetime
origin_t_dt = datetime(p.origin_t, 'ConvertFrom', 'posixtime','Format', 'uuuu-MM-dd''T''HH:mm:ss.SSS')

% Find first 5 surface GPS hits from Iridium after origin time
surface_time_idx = find(utc_time > origin_t_dt , 5);

% Grab lat/lon from iridium table with surface_time_index
lander_lat = iridium_tb.Latitude(surface_time_idx);
lander_lon = iridium_tb.Longitude(surface_time_idx);

% Convert lat/lon to UTM
utm_zone = 19; % TODO: Dont hardcode this
[lander_x, lander_y] = ll2utm(lander_lat, lander_lon, utm_zone);
[origin_x, origin_y] = ll2utm(p.origin_lat, p.origin_lon, utm_zone);
local_x = lander_x - origin_x;
local_y = lander_y - origin_y;

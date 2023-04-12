function [local_x, local_y, surface_t] = ground_truth(csv_fn, p)
% Find the surface GPS measurement that comes when the lander surfaces.
% Input:
%   csv_fn: filename for csv containing Iridium satellite pings for lander.
%   p: struct containing information (origin_t) for particle filter.
% Output:
%   local_x: local x position in meters when the lander is at the surface.
%   local_y: local y position in meters when the lander is at the surface.
%   surface_t: UTC time when the lander is at the surface.


    % Load table of iridium GPS data
    iridium_tb = readtable(csv_fn);
    iridium_tb = sortrows(iridium_tb,"DataDate_EST_","ascend");
    utc_time = iridium_tb.DataDate_EST_ + hours(4); % Convert to utc time from est
    
    % Convert origin time to datetime
    origin_t_dt = datetime(p.origin_t, 'ConvertFrom', 'posixtime','Format', 'uuuu-MM-dd''T''HH:mm:ss.SSS');
    
    % Find first surface GPS hit from Iridium after origin time + 1 hour
    surface_time_idx = find(utc_time > origin_t_dt + hours(1) , 1);
    
    % Grab lat/lon from iridium table with surface_time_index
    lander_lat = iridium_tb.Latitude(surface_time_idx);
    lander_lon = iridium_tb.Longitude(surface_time_idx);
    
    % Convert lat/lon to UTM
    utm_zone = 19; % TODO: Dont hardcode this
    [lander_x, lander_y] = ll2utm(lander_lat, lander_lon, utm_zone);
    [origin_x, origin_y] = ll2utm(p.origin_lat, p.origin_lon, utm_zone);
    local_x = lander_x - origin_x;
    local_y = lander_y - origin_y;
    surface_t =  utc_time(surface_time_idx);
    
    % OUTPUTS
    fprintf('The ground truth @ the surface is x = %.2f, y = %.2f',local_x, local_y)

end

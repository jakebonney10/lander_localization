function [origin_x, origin_y, origin_t] = lander_origin(ship, lander, start_depth)
%lander_origin Grab lander depth start time
% Bonney and Parisi
% GOAL: Find lander origin lat, lon, timestamp.

[lander_start_idx] = find(lander.depth >= start_depth , 1); % lander descends after depth
[ship_start_idx] = find(ship.timestamp >= lander.timestamp(lander_start_idx) , 1);
origin_x = ship.lat(ship_start_idx);
origin_y = ship.lon(ship_start_idx);
origin_t = ship.timestamp(ship_start_idx);

end
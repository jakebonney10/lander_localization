function [z] = get_lander_measurement(lander, p, t, delta_t)
% Find the closest range measurement to timestamp t within delta_t seconds
% Input:
%   measurement: struct array containing range measurements
%   t: unix timestamp in seconds
%   delta_t: time range to search for range measurement, in seconds
% Output:
%   range: range measurement, or empty if not found
%   range_time: timestamp of the range measurement, or NaN if not found

z = [];     % initialize z

for i = 1:length(lander.depth)
    if abs(lander.timestamp(i) - t) <= delta_t
        z = lander.depth(i);
        break;  % stop searching after the first depth measurement found
    end
end

z = z * ones(p.num_particles, 1); % create array of size p.num_particles with all elements set to x


end
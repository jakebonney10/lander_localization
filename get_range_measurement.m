function [range, range_time] = get_range_measurement(measurement, t, delta_t)
% Find the closest range measurement to timestamp t within delta_t seconds
% Input:
%   measurement: struct array containing range measurements
%   t: unix timestamp in seconds
%   delta_t: time range to search for range measurement, in seconds
% Output:
%   range: range measurement, or empty if not found
%   range_time: timestamp of the range measurement, or NaN if not found

range = [];     % initialize range and range_time
range_time = NaN;

for i = 1:length(measurement.range)
    if abs(measurement.timestamp(i) - t) <= delta_t
        range = measurement.range(i);
        range_time = measurement.timestamp(i);
        break;  % stop searching after the first range measurement found
    end
end

end


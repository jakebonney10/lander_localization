function [particle_range, weight, local_x, local_y] = measurement_update(state, p, ship, range, range_t)



% Define the current ship coordinates
[idx] = find(ship.timestamp >= range_t , 1);
ship_lat = ship.lat(idx);
ship_lon = ship.lon(idx);


% Convert the global coordinates to local coordinates (UTM-origin)
utm_zone = 19; % TODO: Dont hardcode this
[ship_x, ship_y] = ll2utm(ship_lat, ship_lon, utm_zone);
[origin_x, origin_y] = ll2utm(p.origin_lat, p.origin_lon, utm_zone);
local_x = ship_x - origin_x;
local_y = ship_y - origin_y;


% Display the local coordinates
disp(['Local x: ', num2str(local_x)]);
disp(['Local y: ', num2str(local_y)]);


% Define ship z position TODO: This could be depth of sounder, Im not sure if
% there is an offset so we should check with Dave.
local_z = 0;


% Gaussian params
sigma = 100; % set the standard deviation of the Gaussian distribution
mu = range;  % set mu to be the true range, we want particles that are
% closer to the true range to have higher weights than those farther away.


for i = 1:p.num_particles

    % Calculate range to ship for each particle
    x = state.x(i) - local_x;
    y = state.y(i) - local_y;
    z = state.z(i) - local_z;
    particle_range(i) = sqrt(x.^2 + y.^2 + z.^2);

    % Calculate weight of each particle using Gaussian function
    weight(i) = normpdf(particle_range(i), mu, sigma);

end


% Normalize the weights so that their sum is equal to 1
weight = weight / sum(weight);


% Display
disp(range)
%disp(particle_range)
%disp(weight)



end
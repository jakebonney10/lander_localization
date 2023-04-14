function [particle_range, weight, local_x, local_y] = measurement_update(state, p, ship, range, range_t)
% measurement update and weighting of particles for a given range measurement. 

    % Start the timer
    tic
    
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
        
    % Define ship z position, offset of transducer hanging off ship
    local_z = 5;
    
    % Gaussian params
    sigma = 50; % set the standard deviation of the Gaussian distribution
    mu = range;  % set mu to be the true range, we want particles that are
    % closer to the true range to have higher weights than those farther away.
    
    % Initialize arrays for parallel processing
    particle_range = zeros(1, p.num_particles);
    weight = zeros(1, p.num_particles);
        
    % Calculate range to ship for each particle
    x = state.x - local_x;
    y = state.y - local_y;
    z = state.z - local_z;
    particle_range = sqrt(x.^2 + y.^2 + z.^2);
    
    % Calculate weight of each particle using Gaussian function
    weight = normpdf(particle_range, mu, sigma);
        
    % Normalize the weights so that their sum is equal to 1
    weight = weight / sum(weight);
        
    % Display true range
    disp('The true range measurement is: ')
    disp(range)
        
    % Stop the timer and record the elapsed time
    elapsed_time = toc;
        
    disp('The elapsed time for the measurement update is: ')
    disp(elapsed_time)

end
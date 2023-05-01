function [x, y, z] = range_sphere(range, ship_x, ship_y)        

    % Define the range of values for the sphere
    r = range; % radius
    theta = linspace(0, 2*pi, 50); % azimuthal angle
    phi = linspace(0, pi/2, 50); % polar angle
    
    % Create meshgrid of angles
    [theta, phi] = meshgrid(theta, phi);
    
    % Calculate the x, y, and z coordinates of each point on the sphere
    x = r*sin(phi).*cos(theta) + ship_x;
    y = r*sin(phi).*sin(theta) + ship_y;
    z = r*cos(phi);
    
end
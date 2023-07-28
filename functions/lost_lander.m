function [x,y,z] = lost_lander(p, radius)
% The "oh shit" we forgot to mark where we put the lander function.
% Initializes a random particle cloud with x,y radius and z depth. 
% P is number of particles, radius is initial radius of uncertainty.

rng(0); % Set random seed for reproducibility/debugging
r = sqrt(rand(p.num_particles,1)); % Random radius between 0 and 1
theta = 2*pi*rand(p.num_particles,1); % Random angle between 0 and 2*pi

x = radius * r.*cos(theta);
y = radius * r.*sin(theta);
z = abs(p.start_depth_sigma*randn(p.num_particles,1)); % Gaussian distribution with mean 0 and std 1

figure;
scatter3(x, y, z, '.');
xlabel('X');
ylabel('Y');
zlabel('Z');

end
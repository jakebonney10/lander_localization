% lander_pf script
% Bonney and Parisi

% GOAL: Initialize particles for particle filter localization and perform 
% motion update step for each particle.

clc; clear all; 

% Initial State
ship_x = 0; % Ship latitude at launch
ship_y = 0; % Ship longitude at launch
position_std_dev = 1; % (m)
velocity_std_dev = 0.1; % (m/s)
avg_descent_veloc = 0.5; % (m/s)
descent_std_dev = 0.1; % (m/s)

% Define time vector
Tmax = 1000;
DeltaT = 0.2;

% Define state vector
state = struct('x', [], 'y', [], 'z', [], 'u', [], 'v', [], 'w', [], 'mode', [], 'bottom_time', []);

% Initialize particles
num_particles = 10;
initial_x = ship_x + position_std_dev * randn(num_particles, 1);
initial_y = ship_y + position_std_dev * randn(num_particles, 1);
initial_z = 5 + position_std_dev * randn(num_particles, 1);
initial_u = velocity_std_dev * randn(num_particles, 1);
initial_v = velocity_std_dev * randn(num_particles, 1);
initial_w = avg_descent_veloc + descent_std_dev * randn(num_particles, 1);
initial_mode = zeros(num_particles, 1);
initial_bottom_time = NaN(num_particles, 1);

state.x = initial_x;
state.y = initial_y;
state.z = initial_z;
state.u = initial_u;
state.v = initial_v;
state.w = initial_w;
state.mode = initial_mode;
state.bottom_time = initial_bottom_time;

% Plot initial particle state
plot3(state.x,state.y,state.z,'b.')
set(gca, 'ZDir', 'reverse');
axis equal
hold on

% Define motion model
dt = 1; % time step in seconds
motion_noise = 0.1; % noise parameter for velocity and acceleration
mode_probabilities = [0.5, 0.1, 0.1, 0.3]; % probabilities of mode transitions

for t=0:DeltaT:Tmax

    % motion model update for each particle
    for i=1:num_particles

        state.x(i) = state.x(i) + normrnd(0, position_std_dev);
        state.y(i) = state.y(i) + normrnd(0, position_std_dev);
        state.z(i) = state.z(i) + state.w(i)*DeltaT + normrnd(0, descent_std_dev);
        state.u(i) = state.u(i) + normrnd(0, velocity_std_dev);
        state.v(i) = state.v(i) + normrnd(0, velocity_std_dev);
        state.w(i) = avg_descent_veloc + normrnd(0, velocity_std_dev);
        state.mode(i) = state.mode(i);
        state.bottom_time(i) = state.bottom_time(i);

    end

    plot3(state.x,state.y,state.z,'r.')

    %pause(0.1)

end

%%%%% OUTPUTS
disp('simulation ended!')
final_particle_pose_x = mean(state.x);
final_particle_pose_y = mean(state.y);
final_particle_pose_z = mean(state.z);
fprintf('The estimated position is x = %.2f, y = %.2f\n, z = %.2f\n',final_particle_pose_x, final_particle_pose_y, final_particle_pose_z)
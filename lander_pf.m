% lander_pf script
% Bonney and Parisi

% GOAL: Initialize particles for particle filter localization.

clc; clear all; 

% Initial State
ship_x = 0; % Ship latitude at launch
ship_y = 0; % Ship longitude at launch
position_std_dev = 5; % (m)
velocity_std_dev = 0.1; % (m/s)
avg_descent_veloc = 0.5; % (m/s)
descent_std_dev = 0.1; % (m/s)

% Define time vector
Tmax = 1000;
DeltaT = 0.2;

% Define state vector
state = struct('x', [], 'y', [], 'z', [], 'u', [], 'v', [], 'w', [], 'mode', [], 'bottom_time', []);

% Initialize particles
num_particles = 1000;
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

% Plot particles
plot3(state.x,state.y,state.z,'b.')
axis equal
hold on

% Define motion model
dt = 1; % time step in seconds
motion_noise = 0.1; % noise parameter for velocity and acceleration
mode_probabilities = [0.5, 0.1, 0.1, 0.3]; % probabilities of mode transitions

for t=0:DeltaT:Tmax
    
    % motion model update
    state.x = state.x + normrnd(0, position_std_dev);
    state.y = state.y + normrnd(0, position_std_dev);
    state.z = state.z + state.w*DeltaT + normrnd(0, descent_std_dev);
    state.u = state.u + normrnd(0, velocity_std_dev);
    state.v = state.v + normrnd(0, velocity_std_dev);
    state.w = avg_descent_veloc + normrnd(0, velocity_std_dev);
    state.mode = state.mode;
    state.bottom_time = state.bottom_time;
    plot3(state.x,state.y,state.z,'r.')

end

set(gca, 'ZDir', 'reverse');
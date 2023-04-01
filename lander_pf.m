% lander_pf script
% Bonney and Parisi

% GOAL: Initialize particles for particle filter localization and perform 
% motion update step for each particle.

clc; clear all; 

%%%%% PARAMETERS

% Time
Tmax = 1000;     % in seconds, maximum time to run the simulation
DeltaT = 0.2;       % in seconds, time step as we move through the simulation

% Knowns
sound_speed = 1500; % (m/s) constant for now, will need this for range measurement later
ocean_depth = 100; % approximate ocean depth known before deployment (m) 
total_bottom_time = 60; % estimated total bottom time in seconds
avg_descent_veloc = 0.5; % descent velocity (m/s)
avg_ascent_veloc = -0.5; % ascent velocity (m/s)

% Initial State
ship_x = 0; % Ship latitude at launch
ship_y = 0; % Ship longitude at launch
descent_std_dev = 0.1; % (m/s)
position_std_dev = 1; % (m)
velocity_std_dev = 0.1; % (m/s)

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
initial_mode = zeros(num_particles, 1); % descending, on bottom, ascending, on surface
initial_bottom_time = zeros(num_particles, 1);

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
mode_probabilities = [0.5, 0.1, 0.1, 0.3]; % probabilities of mode transitions???

for t=0:DeltaT:Tmax

    % motion model update for each particle
    for i=1:num_particles

        state.x(i) = state.x(i) + normrnd(0, position_std_dev);
        state.y(i) = state.y(i) + normrnd(0, position_std_dev);
        state.z(i) = state.z(i) + state.w(i)*DeltaT + normrnd(0, descent_std_dev);
        state.u(i) = state.u(i) + normrnd(0, velocity_std_dev);
        state.v(i) = state.v(i) + normrnd(0, velocity_std_dev);
        
        % Check mode state and set state.w
        if state.mode(i) == 0 % descending
            state.w(i) = avg_descent_veloc + normrnd(0, velocity_std_dev);
        elseif state.mode(i) == 1 % on bottom
            state.w(i) = 0;
            state.bottom_time(i) = state.bottom_time(i) + DeltaT;
        elseif state.mode(i) == 2 % ascending
            state.w(i) = avg_ascent_veloc + normrnd(0, velocity_std_dev);
        else % either on bottom or on surface
            state.w(i) = 0; 
        end
        
        % Check if on bottom
        if state.z(i) >= ocean_depth % on bottom
            state.mode(i) = 1; 
        end

        % Check if ascending
        if state.bottom_time(i) >= total_bottom_time % ascending
            state.mode(i) = 2;
        end

        % Check to see if on surface
        if state.z(i) < 1 & state.bottom_time(i) >= total_bottom_time % on surface
            state.mode(i) = 3; 
        end

    end

    plot3(state.x,state.y,state.z,'r.')

    pause(0.01)

end

%%%%% OUTPUTS
disp('simulation ended!')
final_particle_pose_x = mean(state.x);
final_particle_pose_y = mean(state.y);
final_particle_pose_z = mean(state.z);
fprintf('The estimated position is x = %.2f, y = %.2f\n, z = %.2f\n',final_particle_pose_x, final_particle_pose_y, final_particle_pose_z)
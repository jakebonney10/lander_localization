% lander_pf script
% Bonney and Parisi

% GOAL: Initialize particles for particle filter localization and perform 
% motion update step for each particle.

% MODE LAYOUT
    % 0. Descending (motion and measurement updates)
    % 1. On Bottom (no motion, measurement updates only)
    % 2. Ascending (motion and measurement updates)
    % 3. At Surface (no motion, particle's sim ends)


clc, clearvars, close all

%%%%% USER INPUTS
ocean_depth = 20;           % approximate ocean depth known before deployment (m) 
ocean_depth_sigma = 2;      % for particle transition to bottom (level of confidence of bottom)
num_particles = 10;         % num of particles to use in estimation
total_bottom_time = 20;     % seconds lander is programmed to sit on the bottom


%%%%% IMMUTABLE PARAMETERS

% Time
p.t_max = 1000;         % in seconds, maximum time to run the simulation
p.delta_t = 0.2;        % in seconds, time step as we move through the simulation

% Knowns
p.sound_speed = 1500; % (m/s) constant for now, will need this for range measurement later
p.ocean_depth = ocean_depth; % approximate ocean depth known before deployment (m) 
p.ocean_depth_sigma = ocean_depth_sigma; % used for the probability of particles landing on the seafloor
p.total_bottom_time = total_bottom_time; % estimated total bottom time in seconds
p.avg_descent_veloc = 0.5; % descent velocity (m/s)
p.avg_ascent_veloc = -0.5; % ascent velocity (m/s)
p.num_particles = num_particles;

% Uncertainties
p.descent_std_dev = 0.1; % (m/s)
p.position_std_dev = 0.1; % (m)
p.velocity_std_dev = 0.01; % (m/s)

%%%%% OTHER PARAMETERS

% Initial State
ship_x = 0; % Ship latitude at launch
ship_y = 0; % Ship longitude at launch


%%%%% INITIALIZE PARTICLES

initial_x = ship_x + normrnd(0, p.position_std_dev, num_particles, 1);
initial_y = ship_y + normrnd(0, p.position_std_dev, num_particles, 1);
initial_z = 5 + normrnd(0, p.position_std_dev, num_particles, 1);
initial_u = normrnd(0, p.velocity_std_dev, num_particles, 1);
initial_v = p.velocity_std_dev * randn(p.num_particles, 1);
initial_w = p.avg_descent_veloc + normrnd(0,p.descent_std_dev,num_particles,1);

initial_z_transition = normrnd(ocean_depth,ocean_depth_sigma,num_particles,1);
initial_mode = zeros(p.num_particles, 1); % descending, on bottom, ascending, on surface
initial_bottom_time = zeros(p.num_particles, 1);

% define State (hold all particles)
state = struct('x', [], 'y', [], 'z', [], 'u', [], 'v', [], 'w', [], 'weight', [], 'mode', [], 'bottom_time', []);
state.x = initial_x;
state.y = initial_y;
state.z = initial_z;
state.u = initial_u;
state.v = initial_v;
state.w = initial_w;
state.z_transition = initial_z_transition;
state.mode = initial_mode;
state.bottom_time = initial_bottom_time;
state.finished_particles = 0;

% Plot initial particle state
plot3(state.x,state.y,state.z,'b.')
set(gca, 'ZDir', 'reverse');
axis equal
hold on

disp('displaying particles')
pause(5)


%%%%% RUN PARTICLE FILTER SIMULATION 
disp('running particle filter')

for t=0:p.delta_t:p.t_max

    % motion update (update all states)
    state = motion_update(state,p);

    % measurement update
    

    % cull and resample particles


    % visualize and pause
    plot3(state.x,state.y,state.z,'r.'), hold off
    pause(0.01)

    % kill sim for any reason
    if state.finished_particles == p.num_particles
        disp('all particles at surface!')
        break
    end

end


%%%%% OUTPUTS

disp('simulation ended!')
final_particle_pose_x = mean(state.x);
final_particle_pose_y = mean(state.y);
final_particle_pose_z = mean(state.z);
fprintf('The estimated position is x = %.2f, y = %.2f, z = %.2f\n',final_particle_pose_x, final_particle_pose_y, final_particle_pose_z)
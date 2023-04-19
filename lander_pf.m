% lander_pf script
% Bonney and Parisi

% GOAL: Initialize particles for particle filter localization and perform 
% motion update step for each particle.

% MODE LAYOUT
    % 0. Descending (motion and measurement updates)
    % 1. On Bottom (no motion, measurement updates only)
    % 2. Ascending (motion and measurement updates)
    % 3. At Surface (no motion, particle's sim ends)

% add path variables to access file + functions
    if ispc() % windows
        addpath("gsw_matlab_v3_06_16\","latlonutm\")
    else      % mac, ubuntu
        addpath("gsw_matlab_v3_06_16/","latlonutm/")
    end

clc, clearvars, close all

%TODO: mess with scale on figure
%TODO: try another dive

%%%%% USER INPUTS
burnwire_time = 60*5;
ocean_depth = 8375;               % approximate ocean depth known before deployment (m) 
ocean_depth_percent_error = 0.01;       % confidence in bottom estimate (1%)
ocean_depth_sigma = ocean_depth * ocean_depth_percent_error;        % for particle transition to bottom (level of confidence of bottom)
num_particles = 1e5;            % num of particles to use in estimation
total_bottom_time = 3600*4 + burnwire_time;     % seconds lander is programmed to sit on the bottom
total_bottom_time_sigma = 60*5;         % variation in minutes for total bottom time
use_range_correction = 0;       % Set to 1 to use range correction with ssp
use_lander_depth = 0;           % Set to 1 to use lander depth post processed solution

%%%%% IMMUTABLE PARAMETERS

% Load & plot lander data
fn_topside = '20180921_110812.mat'; % topside .mat filename
fn_lander = '20180921_110738.mat'; % lander .mat filename
[ship, measurement, lander, ssp] = get_lander_data(fn_topside, fn_lander);

% SSP range correction
if use_range_correction == 1
    [measurement.range] = range_correction(ssp, measurement, lander);
end

% Find lander origin (lat, lon, timestamp)
p.start_depth = 1; %transition h = 1; % approximate depth to call start time for descent
[p.origin_lat, p.origin_lon, p.origin_t] = lander_origin(ship, lander, p.start_depth);

% Time
p.t_start = p.origin_t;   % in seconds, unix timestamp from ship time
p.t_max = 1e8;         % in seconds, maximum time to run the simulation
p.delta_t = 1;        % in seconds, time step as we move through the simulation

% Knowns
p.ocean_depth = ocean_depth; % approximate ocean depth known before deployment (m) 
p.total_bottom_time = total_bottom_time; % estimated total bottom time in seconds
p.avg_descent_veloc = 1.1; % descent velocity (m/s) 60 (m/min)
p.avg_ascent_veloc = -1.1; % ascent velocity (m/s) 60 (m/min)
p.num_particles = num_particles;

% Uncertainties
p.descent_std_dev = 0.0005; % (m/s)
p.position_std_dev = 15; % (m)
p.velocity_std_dev = 0.0005; % (m/s)
p.start_depth_sigma = 25; % (m)
p.on_bottom_position_sigma = 0.5; % (m)
p.total_bottom_time_sigma = total_bottom_time_sigma; % used for probability of transition time bottom 
p.ocean_depth_sigma = ocean_depth_sigma; % used for the probability of particles landing on the seafloor
p.measurement_sigma = 20; % for particle weighting (m) 



%%%%% OTHER PARAMETERS

% Initial State
ship_x = 0; % Ship latitude at launch
ship_y = 0; % Ship longitude at launch


%%%%% INITIALIZE PARTICLES

initial.x = ship_x + normrnd(0, p.position_std_dev, num_particles, 1);
initial.y = ship_y + normrnd(0, p.position_std_dev, num_particles, 1);
initial.z = abs(normrnd(0, p.start_depth_sigma, num_particles, 1));
initial.u = normrnd(0, p.velocity_std_dev, num_particles, 1);
initial.v = normrnd(0, p.velocity_std_dev, num_particles, 1);
initial.w = p.avg_descent_veloc + normrnd(0,p.descent_std_dev,num_particles,1);

initial.z_transition = normrnd(ocean_depth,ocean_depth_sigma,num_particles,1);
initial.total_bottom_time = normrnd(p.total_bottom_time,p.total_bottom_time_sigma,num_particles,1);
initial.mode = zeros(p.num_particles, 1); % descending, on bottom, ascending, on surface
initial.bottom_time = zeros(p.num_particles, 1);

% define State (hold all particles)
state = struct('x', [], 'y', [], 'z', [], 'u', [], 'v', [], 'w', [], 'weight', [], 'mode', [], 'bottom_time', [], 'total_bottom_time', [], 'finished_particles', []);
state.x = initial.x;
state.y = initial.y;
state.z = initial.z;
state.u = initial.u;
state.v = initial.v;
state.w = initial.w;
state.z_transition = initial.z_transition;
state.mode = initial.mode;
state.bottom_time = initial.bottom_time;
state.total_bottom_time = initial.total_bottom_time;
state.finished_particles = 0;

% Plot initial particle state
f1 = figure;
scatter3(state.x, state.y, state.z,'r.')
set(gca, 'ZDir', 'reverse');
axis equal
title('Initial Particle Position')
xlabel('x position (m)')
ylabel('y position (m)')
zlabel('depth (m)')

%%
% Get the screen size
screen_size = get(groot, 'ScreenSize');

% Set the figure window size to the screen size
set(gcf, 'Position', screen_size);

%%%% RECORD FRAMES FOR A VIDEO
writerObj = VideoWriter(datestr(datetime('now'), 'yyyymmddHHMMSS'),'Motion JPEG AVI');
writerObj.FrameRate = 1;
open(writerObj);

%%%%% RUN PARTICLE FILTER SIMULATION 
disp('running particle filter')

%for t=p.t_start:p.delta_t:p.t_start + p.t_max
for t=p.t_start:p.delta_t:p.t_start + p.t_max

    % motion update (update all states)
    state = motion_update(state,p);

    % Lander depth post processed solution
    if use_lander_depth == 1
        [state.z] = get_lander_measurement(lander, p, t, p.delta_t/4);
        state.z_transition = ones(p.num_particles, 1) * max(lander.depth) - 0.1;
        if state.z >= state.z_transition
            state.mode = ones(p.num_particles, 1) * 1; % on bottom
        elseif state.z <= 3 & state.mode == 2
            state.mode = ones(p.num_particles, 1) * 3;
        end
    end

    % get range measurement (if available)
    [range, range_t] = get_range_measurement(measurement, t, p.delta_t/2);

    % if we have a range measurement
    if ~isempty(range)
        % measurement update
        disp("updating with range measurement")
        [particle_range, state.weight, ship_x, ship_y] = measurement_update(state, p, ship, range, t);

        % Pause and visualize 
        plot3(state.x,state.y,state.z,'r.'), hold on

        % resample particles
        disp("resampling particles")
        state = resample_particles(state);

        % Pause and visualize 
        plot3(state.x,state.y,state.z,'k.'), hold on

        % Add a marker at the position of the ship
        ship_z = 0;
        scatter3(ship_x, ship_y, ship_z, 'Marker', 'o', 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'none', 'SizeData', 200);

        % Plot sphere using plot3
        [x, y, z] = range_sphere(range, ship_x, ship_y);
        surf(x,y,z,'FaceAlpha',0.3, 'EdgeAlpha', 0.3); % Set the FaceAlpha property to 0.5 for semi-opacity
        colormap(gray); % Set the colormap to grayscale
        axis equal;
        set(gca, 'ZDir', 'reverse');
        hold off
        title_str = strcat(num2str(p.num_particles),'p, range=',num2str(range),', avgparticle=(x=',num2str(mean(state.x)),',y=',num2str(mean(state.y)),',z=',num2str(mean(state.z)),')');
        title(title_str,'fontsize',8) 
        pause(1)
    
        % write the figure to a frame, save into the video
        F = getframe(f1);
        writeVideo(writerObj,F);
        
    end


%     % Record mean data for post analysis
%     master_particle.x(t) = mean(state.x);
%     master_particle.y(t) = mean(state.y);
%     master_particle.z(t) = mean(state.z);
%     master_particle.u(t) = mean(state.u);
%     master_particle.v(t) = mean(state.v);
%     master_particle.w(t) = mean(state.w);


    % kill sim for any reason
    if state.finished_particles == p.num_particles
        disp('all particles at surface!')
        break
    end

end

%%
%%%%% OUTPUTS

disp('simulation ended!')
final_particle_pose_x = mean(state.x);
final_particle_pose_y = mean(state.y);
final_particle_pose_z = mean(state.z);
fprintf('The estimated position is x = %.2f, y = %.2f, z = %.2f\n.',final_particle_pose_x, final_particle_pose_y, final_particle_pose_z)

%%%%% Ground truth
csv_fn = 'lander_iridium_sept2018.csv';
[local_x, local_y, surface_t] = ground_truth(csv_fn, p);
distance = sqrt((local_x - final_particle_pose_x)^2 + (local_y - final_particle_pose_y)^2);
fprintf(' The distance between the ground truth and estimate is %.2f meters',distance)


% Plot final point cloud top down view
figure
scatter(state.x,state.y,'b.'); hold on
plot(local_x, local_y, 'ro'); hold on
plot(final_particle_pose_x, final_particle_pose_y, 'y^')
plot(median(state.x), median(state.y), 'g*')
legend('Point Cloud', 'True Position', 'Mean Position', 'Median Position')
axis equal


%%%%% implement density solution here







%%%%%

% close video
close(writerObj)

% lander_pf script
% Bonney and Parisi
%clc, clearvars, close all

% GOAL: Initialize particles for particle filter localization and perform 
% motion update step for each particle.

% MODE LAYOUT
    % 0. Descending (motion and measurement updates)
    % 1. On Bottom (no motion, measurement updates only)
    % 2. Ascending (motion and measurement updates)
    % 3. At Surface (no motion, particle's sim ends)

% add path variables to access file + functions
    if ispc() % windows
        addpath(genpath('functions'),genpath('data'))
        vid_folder = "video\";
    else      % mac, ubuntu [not sure how genpath works on ubuntu and mac yet!]
        addpath(genpath('functions'),genpath('data'))
        vid_folder = "video/";
    end


% Load & plot lander data
fn_topside = '20180921_223525.mat'; % topside .mat filename (smaller file)
fn_lander = '20180921_223442.mat'; % lander .mat filename (bigger file)
[ship, measurement, lander, ssp] = get_lander_data(fn_topside, fn_lander);

lander_on_bottom_start_idx = find(lander.depth > max(lander.depth)-5,1);
lander_on_bottom_finish_idx = find(lander.depth > max(lander.depth)-5,1,"last");
total_bottom_time = (lander.timestamp(lander_on_bottom_finish_idx)-lander.timestamp(lander_on_bottom_start_idx))/3600 % hours
max_depth = max(lander.depth) % meters
last_range_measurment = measurement.range(end) % meters

%% Particle Filter Setup

%%%%% USER INPUTS
ocean_depth = 8400;               % approximate ocean depth known before deployment (m) 
ocean_depth_percent_error = 0.01;       % confidence in bottom estimate (1%)
num_particles = 1e5;            % num of particles to use in estimation
burnwire_time = 60*5;           % seconds it takes for burnwire to corrode
total_bottom_time = 380*60 + burnwire_time;     % seconds lander is programmed to sit on the bottom
use_range_correction = 0;       % Set to 1 to use range correction with ssp
use_lander_depth = 0;           % Set to 1 to use lander depth post processed solution
use_lost_lander = [0 1000];     % Set to 1 if running lost lander problem and change radius (m)


%%%%% IMMUTABLE PARAMETERS


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
p.descent_std_dev = 0.002; % (m/s)
p.position_std_dev = 15; % (m)
p.velocity_std_dev_surface = 0.005; % (m/s)
p.velocity_std_dev = p.velocity_std_dev_surface; % (m/s)
p.start_depth_sigma = 50; % (m)
p.on_bottom_position_sigma = 0.25; % (m)
p.total_bottom_time_sigma = 60*5; % variation in minutes used for probability of transition time bottom 
p.ocean_depth_sigma = ocean_depth * ocean_depth_percent_error; % for particle transition to bottom (level of confidence of bottom)
p.measurement_sigma = 20; % for particle weighting (m) 


%%%%% OTHER PARAMETERS

% Initial State
ship_x = 0; % Ship origin x at launch
ship_y = 0; % Ship origin y at launch


%%%%% INITIALIZE PARTICLES

initial.x = ship_x + normrnd(0, p.position_std_dev, p.num_particles, 1);
initial.y = ship_y + normrnd(0, p.position_std_dev, p.num_particles, 1);
initial.z = abs(normrnd(0, p.start_depth_sigma, p.num_particles, 1));
initial.u = normrnd(0, p.velocity_std_dev, p.num_particles, 1);
initial.v = normrnd(0, p.velocity_std_dev, p.num_particles, 1);
initial.w = p.avg_descent_veloc + normrnd(0,p.descent_std_dev,p.num_particles,1);

initial.z_transition = normrnd(ocean_depth,p.ocean_depth_sigma,p.num_particles,1);
initial.total_bottom_time = normrnd(p.total_bottom_time,p.total_bottom_time_sigma,p.num_particles,1);
initial.mode = zeros(p.num_particles, 1); % descending, on bottom, ascending, on surface
initial.bottom_time = zeros(p.num_particles, 1);

% Lost lander problem
if use_lost_lander(1) == 1
    [initial.x, initial.y, initial.z] = lost_lander(p, use_lost_lander(2));
end

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

%% Plot initial particle state
f1 = figure(1);
scatter3(state.x, state.y, state.z,'r.')
set(gca, 'ZDir', 'reverse');
axis equal
title('Initial Particle Position')
xlabel('x position (m)')
ylabel('y position (m)')
zlabel('depth (m)')
disp('observe initial cloud. run next code section to start particle filter.')

%% Main pf loop 
disp('...starting particle filter...')
total_runtimer = tic;

% Get the screen size
%screen_size = get(groot, 'ScreenSize');

% Set the figure window size to the screen size
%set(gcf, 'Position', screen_size);

%%%% RECORD FRAMES FOR A VIDEO
%video_name = strcat(vid_folder,datestr(datetime('now'), 'yyyymmddHHMMSS'));
%writerObj = VideoWriter(video_name,'Motion JPEG AVI');
%writerObj.FrameRate = 1;
%open(writerObj);

%%%%% RUN PARTICLE FILTER SIMULATION 
disp('running particle filter')

%for t=p.t_start:p.delta_t:p.t_start + p.t_max
for t=p.t_start:p.delta_t:p.t_start + p.t_max

    % motion update (update all states)
    state = motion_update(state,p);

    % varying horizontal velocity implementation
    %p.velocity_std_dev = set_velocity_uncertainty(p, mean(state.z))

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
    if ~isempty(range) && ~(mean(state.z) < 600 && min(state.mode) >= 2)
        % measurement update
        disp("updating with range measurement")
        
        [particle_range, state.weight, ship_x, ship_y] = measurement_update(state, p, ship, range, t);

        % Pause and visualize
        %figure(f1)
        %plot3(state.x,state.y,state.z,'r.'), hold on

        % resample particles
        disp("resampling particles")
        state = resample_particles(state,p);

        % Pause and visualize 
        %plot3(state.x,state.y,state.z,'k.')

        % Add a marker at the position of the ship
        %ship_z = 0;
        %scatter3(ship_x, ship_y, ship_z, 'Marker', 'o', 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'none', 'SizeData', 200);

        % Plot sphere using plot3
        %[x, y, z] = range_sphere(range, ship_x, ship_y);
        %surf(x,y,z,'FaceAlpha',0.3, 'EdgeAlpha', 0.3); % Set the FaceAlpha property to 0.5 for semi-opacity
        %colormap(gray); % Set the colormap to grayscale
        %axis equal;
        %set(gca, 'ZDir', 'reverse');
        %hold off
        %title_str = strcat(num2str(p.num_particles),'p, range=',num2str(range),', avgparticle=(x=',num2str(mean(state.x)),',y=',num2str(mean(state.y)),',z=',num2str(mean(state.z)),',u=',num2str(mean(state.u)),',v=',num2str(mean(state.v)),',w=',num2str(mean(state.w)),')');
        %title(title_str,'fontsize',8) 
        %pause(1)
    
        % write the figure to a frame, save into the video
        %F = getframe(f1);
        %writeVideo(writerObj,F);
        
    end


%     % Record mean data for post analysis
%     master_particle.x(t) = mean(state.x);
%     master_particle.y(t) = mean(state.y);
%     master_particle.z(t) = mean(state.z);
%     master_particle.u(t) = mean(state.u);
%     master_particle.v(t) = mean(state.v);
%     master_particle.w(t) = mean(state.w);


    % kill sim if 95% of particles are finished
    if state.finished_particles > p.num_particles*0.95 
        disp('all particles at surface! or particle depth < 600 meters!')
        break
    end

end

disp('particle filter has ended! run next section for plot and to save the video.')
total_elapsed_time = toc(total_runtimer);

%%
%%%%% OUTPUTS
clc, close all

% add path variables to access file + functions
if ispc() % windows
    addpath("gsw_matlab_v3_06_16\","latlonutm\")
else      % mac, ubuntu
    addpath("gsw_matlab_v3_06_16/","latlonutm/")
end

disp('simulation ended!')
final_particle_pose_x = mean(state.x);
final_particle_pose_y = mean(state.y);
final_particle_pose_z = mean(state.z);
fprintf('The MEAN estimated position is x = %.2f, y = %.2f, z = %.2f\n.',final_particle_pose_x, final_particle_pose_y, final_particle_pose_z)

%open(writerObj);

%% Ground truth
csv_fn = 'lander_iridium_sept2018.csv';
[local_x, local_y, surface_t] = ground_truth(csv_fn, p);
distance = sqrt((local_x - final_particle_pose_x)^2 + (local_y - final_particle_pose_y)^2);
fprintf(' The distance between the ground truth and mean estimate is %.2f meters\n',distance)


%% Calculate density solution
density_solution = get_probdensity_solution(state);


%%%%% Final Plot of all Solutions
figure()
plot(state.x,         state.y,          'b.'), hold on
plot(local_x,         local_y,          'ro'),
plot(mean(state.x),   mean(state.y),    'm^'),
plot(median(state.x), median(state.y),  'g*'),
plot(density_solution.x, density_solution.y, 'ws')
xlabel('x'), ylabel('y'), axis equal
legend('particles','truth','mean','median','density')
title('Final Particle Cloud and DAP Estimates')



%%%%% Output a CSV file
current_datetime = datetime;
filename = strcat(datestr(current_datetime, 'yyyy-mm-dd_HH-MM-SS'), ".csv"); % Format date and time for a valid filename
fileID = fopen(filename, 'w');

fprintf(fileID,"%s\n",fn_lander);
fprintf(fileID, "truth, %f, %f\n", local_x, local_y);
fprintf(fileID, "mean, %f, %f\n", mean(state.x), mean(state.y));
fprintf(fileID, "median, %f, %f\n", median(state.x), median(state.y));
fprintf(fileID, "density, %f, %f\n", density_solution.x, density_solution.y);
fprintf(fileID, "time, %f", total_elapsed_time);

fclose(fileID);


%%%%% Save the 'state' variable in case it's needed later
save(strcat(datestr(datetime),".mat"), 'state')

% close video
%close(writerObj)

%% Calculate total ship movement
 
[totalMovement, totalXMovement, totalYmovement] = get_total_ship_movement(ship, p.t_start, posixtime(surface_t), p.origin_lat, p.origin_lon)
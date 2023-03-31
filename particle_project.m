% Final Project - Naive Particle Filter
clc, clear all, close all

%%%%% PARAMETERS

% time
tmax = 100;     % in seconds, maximum time to run the simulation
dt = 0.2;       % in seconds, time step as we move through the simulation

% initial position of robot
x = 0;          % meters
y = 0;          % meters
th = 0;         % radians

% control inputs
v = 0.02;       % velocity m/s
om = 0.05;      % angular velocity rad/s

% plot initial positions
figure;
plot(x,y,'bo');
hold on
axis equal

% noise/uncertainty/variance on each state
uncertainty = 0.02; 

% initialize particle variables
n = 100;
particle = zeros(3, n);

% initialize x_data and y_data variables to store positions over time (initial position is 0)
x_data = 0;
y_data = 0;


% run the simulation
for t=0:dt:tmax
    
    % update actual robot position
    eps_x = normrnd(0, uncertainty);
    eps_y = normrnd(0, uncertainty);        % random noise
    eps_th = normrnd(0, uncertainty);
    
    th_new = th+dt*om + dt*eps_th;
    x_new = x+dt*v*cos(th_new) + dt*eps_x;   % move forward and add above noise to get new position
    y_new = y+dt*v*sin(th_new) + dt*eps_y;
    
    % motion update for each particle
    for i=1:n

        % generate new noise for each particle
        eps_x = normrnd(0, uncertainty);
        eps_y = normrnd(0, uncertainty);
        eps_th = normrnd(0, uncertainty);

        % update each particle's position
        particle(3,i) = particle(3,i)+dt*om + dt*eps_th;
        particle(1,i) = particle(1,i)+dt*v*cos(particle(3,i)) + dt*eps_x;
        particle(2,i) = particle(2,i)+dt*v*sin(particle(3,i)) + dt*eps_y;

    end

    % plot each particle x and y as red dots
    plot(particle(1,:),particle(2,:),'r.'), hold on

    % plot the track of our robot x and y
    plot(x_data,y_data,'k.','markersize',3,'markerfacecolor','k');
    axis([-1 1 -0.5 1])
    hold off

    % pause to allow plot to update
    pause(0.01)
    
    % update variables for next loop
    x = x_new;
    y = y_new;
    th = th_new;

    % save x and y variables to do a time series
    x_data = [x_data x];
    y_data = [y_data y];

end


%%%%% OUTPUTS

disp('simulation ended!')
final_particle_pose_x = mean(particle(1,:));
final_particle_pose_y = mean(particle(2,:));

fprintf('The estimated position is x = %.2f, y = %.2f\n',final_particle_pose_x, final_particle_pose_y)
fprintf('The actual position is x = %.2f, y = %.2f\n', x_data(end), y_data(end))


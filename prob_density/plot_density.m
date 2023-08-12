% working on the final plot of density, which is majorly fucked rn.

% --Clear and Load Data and Set Parameters
clc, clearvars, close all
load("state_testing.mat")
n = length(state.x);
grid_pts = 50;

% --Shift x for clearer visibility [don't include this in final implementation]
data_shift_x = -000; data_shift_y = -0000;
state.x = state.x + data_shift_x;
state.y = state.y + data_shift_y;

truth.x = -117.10 + data_shift_x; truth.y = -186.88 + data_shift_y;




%%%%%%%%%%%%%% ACTUAL CODE TO IMPLEMENT IN LANDER_PF.m &&&&&&&&&&&&&&

% --Particle Cloud Plot
figure(1)
plot(state.x,         state.y,          'b.'), hold on
plot(mean(state.x),   mean(state.y),    'm^'),
plot(median(state.x), median(state.y),  'g*')
xlabel('x'), ylabel('y'), axis equal


% --Define Grid for Mesh
x_grid_pts = linspace(min(state.x),max(state.x),grid_pts);
y_grid_pts = linspace(min(state.y),max(state.y),grid_pts); % maybe flip max/min for orienatation on map

%[X, Y] = meshgrid(x_grid_pts,y_grid_pts); % fuck this function
X = repmat(x_grid_pts,grid_pts,1);
Y = repmat(sort(y_grid_pts',"descend"),1,grid_pts);


% --Count Particles between grid_pts
counts = histcounts2(state.x, state.y, x_grid_pts, y_grid_pts); % this function is fukcy
counts = flipud(counts'); % need to rotate for orientation purposes...? 90deg counter clockwise for some reason

% --Plot the Counts as Probabilities [and center the counting locations]
x_grid_shift = diff(x_grid_pts);               y_grid_shift = diff(y_grid_pts);
x_count_grid = x_grid_pts + x_grid_shift(1)/2; y_count_grid = y_grid_pts + y_grid_shift(1)/2;
x_count_grid = x_count_grid(1:end-1);        y_count_grid = y_count_grid(1:end-1);

X_counts = repmat(x_count_grid,grid_pts-1,1);
Y_counts = repmat(sort(y_count_grid',"descend"),1,grid_pts-1);

% --Surface plot of the counts
figure(2)
surf(X_counts, Y_counts, counts)
axis equal, xlabel('x'), ylabel('y')


% --Get the max point and indices from probability density
[max_count, max_count_ind] = max(counts(:));
[max_row, max_col] = ind2sub(size(counts), max_count_ind);


% --Plot Ground Truth
figure(1)
scatter(truth.x,truth.y,'ro')

% --Plot Max Probability Point
figure(1)
scatter(X_counts(max_row,max_col), Y_counts(max_row,max_col), 'ws')


% --add plot legend
legend('particles','mean','median','truth','max prob')


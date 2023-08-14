function [density_solution] = get_probdensity_solution(state)
% pass 'state' and get out the probability density solution, and a plot

% --Set Parameters
n = length(state.x);
grid_pts = 50;



%%%%%%%%%%%%%% ACTUAL METHOD &&&&&&&&&&&&&&

% --Define Grid for Mesh
x_grid_pts = linspace(min(state.x),max(state.x),grid_pts);
y_grid_pts = linspace(min(state.y),max(state.y),grid_pts); % maybe flip max/min for orienatation on map

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
title('Particle Density')
axis equal, xlabel('x'), ylabel('y'), zlabel('particle counts')


% --Get the max point and indices from probability density
[~, max_count_ind] = max(counts(:));
[max_row, max_col] = ind2sub(size(counts), max_count_ind);


% --Return Max Probability Point
density_solution.x = X_counts(max_row,max_col);
density_solution.y = Y_counts(max_row,max_col);



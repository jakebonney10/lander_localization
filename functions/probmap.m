clc, clearvars, close all

% generate 2D normrnd data
n = 100000;
mu = 0; sigma = 2;
x = normrnd(mu,sigma,1,n);
y = normrnd(mu+5, sigma*2, 1,n);

% scatter plot
figure()
scatter(x,y,'b.')

% generate meshgrid
grid_size = 20;
x_edges = linspace(min(x),max(x),20);
y_edges = linspace(min(y),max(y)+15,20);
[X, Y] = meshgrid(x_edges, y_edges);

% Count the number of points in each meshgrid cell
counts = histcounts2(x, y, x_edges, y_edges);
        % gives us values between our edges

% create new probability map with shifted coords (x,y,counts)
X_diff = abs(X(1,1) - X(1,2))/2;  % get shift
X_new = X + X_diff;               % shift X
X_new = X_new(1:end-1,1:end-1);   % fix size
prob_map.X = X_new;

Y_diff = abs(Y(1,1) - Y(2,1))/2;  % get shift
Y_new = Y + Y_diff;               % shift Y
Y_new = Y_new(1:end-1,1:end-1);   % fix size
prob_map.Y = Y_new;

prob_map.Z = counts/n;  % 'probability' in z

% surface plot
figure()
surf(prob_map.X, prob_map.Y, prob_map.Z)
xlabel('x'),ylabel('y'),zlabel('probability')

% heat map
figure()
imagesc(prob_map.X(1,:), prob_map.Y(:,1)', prob_map.Z)
set(gca, 'YDir', 'normal');
xlabel('x'),ylabel('y')
cb = colorbar;
cb.Label.String = 'probability';

% output the peak
[prob_map.max_z, max_idx] = max(prob_map.Z(:));
[max_row, max_col] = ind2sub(size(counts), max_idx);

prob_map.max_y = prob_map.Y(max_row,1);
prob_map.max_x = prob_map.X(1,max_col);

fprintf('Max x is %0.3f, max y is %0.3f\n', prob_map.max_x, prob_map.max_y)

%%

% Find the indices of the grid cell with the highest point density
[max_count, max_idx] = max(counts(:));
[max_row, max_col] = ind2sub(size(counts), max_idx);

figure()
imagesc(counts);
colorbar;
hold on;

figure()
surf(X,Y,counts)

figure()
scatter(x,y, 'b.');

%%

% put the meshgrid lines on the scatter plot
scatter(x,y,'b.'), hold on

for i = 1:length(x_edges)
    line([x_edges(i), x_edges(i)], [y_edges(1), y_edges(end)], 'Color', 'k', 'LineWidth', 1, 'LineStyle', '-');
end
for j = 1:length(y_edges)
    line([x_edges(1), x_edges(end)], [y_edges(j), y_edges(j)], 'Color', 'k', 'LineWidth', 1, 'LineStyle', '-');
end




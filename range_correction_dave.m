%% get data
lon = -66.0;
lat = 20.0;
pres_db = sbe9_data_t_SBE9_DATA.pres - 10.1325;
temp_its90 = sbe9_data_t_SBE9_DATA.temp;
sal_psu = sbe9_data_t_SBE9_DATA.sal;
ctd_t = double(sbe9_data_t_SBE9_DATA.timestamp);

%% seawater stuff
depth = -gsw_z_from_p(pres_db, lat);
sal_abs = gsw_SA_from_SP(sal_psu, pres_db, lon, lat);
svel = gsw_sound_speed(sal_abs, temp_its90, pres_db);
 
%% find start and end times of descent
% there's some messy state stuff when we're bouncing around at the surface, so only look before we hit bottom for the first time
ibottom = find(lander_mission_state_t_MIS_STATE.state == 2, 1, 'first');
istart = find(lander_mission_state_t_MIS_STATE.state(1:ibottom)==1, 1, 'first');
iend = find(lander_mission_state_t_MIS_STATE.state(1:ibottom)==1, 1, 'last');
tstart = lander_mission_state_t_MIS_STATE.timestamp(istart);
tend = lander_mission_state_t_MIS_STATE.timestamp(iend);
 
i_descent = find(sbe9_data_t_SBE9_DATA.timestamp > tstart & sbe9_data_t_SBE9_DATA.timestamp < tend);
depth_descent = depth(i_descent);
svel_descent = svel(i_descent);
 
%% filter svel
d_depth = 10;
samples_per_m = numel(depth_descent) / (max(depth_descent) - min(depth_descent));
fc = 1 / d_depth; % cutoff frequency
fs = samples_per_m; % sample frequency
Wn = fc / (fs/2);
[b,a] = butter(5, Wn);
svel_filt = filtfilt(b, a, svel_descent);
 
%% downsample
[~, i] = unique(depth_descent);
depth_bins = d_depth:d_depth:max(depth_descent);
svel_bins = interp1(depth_descent(i), svel_filt(i), depth_bins);
 
%% harmonic mean sound speed
svel_har_mean = zeros(size(svel_bins));
%svel_geo_mean = zeros(size(svel_bins));
for i=1:numel(depth_bins)
    svel_har_mean(i) = i / sum(1 ./ svel_bins(1:i));
    %svel_geo_mean(i) = geomean(svel_bins(1:i));
end
 
figure(1); clf;
plot(svel_descent, depth_descent); hold on;
plot(svel_bins, depth_bins);
plot(svel_har_mean, depth_bins);
%plot(svel_geo_mean, depth_bins);
set(gca,'YDir','reverse');
legend('Raw Sound Speed', 'Filtered and Decimated', 'Harmonic Mean');
xlabel('Sound Speed (m/s)'); ylabel('Depth (m)');
 
 
%% grab data for range circles
range_i = find(benthos_release_status_t_BENTHOS_RELEASE_STATUS.range > 150);
range_t = double(benthos_release_status_t_BENTHOS_RELEASE_STATUS.timestamp(range_i));
range = benthos_release_status_t_BENTHOS_RELEASE_STATUS.range(range_i);
gps_t = double(gps_gprmc_t_GPS_GPRMC_DATA.timestamp);
gps_lat = double(gps_gprmc_t_GPS_GPRMC_DATA.lat);
gps_lon = double(gps_gprmc_t_GPS_GPRMC_DATA.lon);
 
%% hard coded stuff for histogram figure
grid_lon = -66.42:.0002:-66.33; % .0001 is about 10 meters
grid_lat = 19.68:.0002:19.75;
grid_circles = zeros(numel(grid_lat), numel(grid_lon));
 
figure(2); clf; hold on;
for i=1:numel(range)
    lat_i = interp1(gps_t, gps_lat, range_t(i));
    lon_i = interp1(gps_t, gps_lon, range_t(i));
    depth_i = interp1(ctd_t, depth, range_t(i));
    svel_i = interp1(depth_bins, svel_har_mean, depth_i, 'linear', 'extrap');
    range_i(i) = svel_i * range(i) / 1500;
    
    if (range_i > depth_i) % if this isn't true we'll have an imaginary circle
        dist = sqrt(range_i(i)^2 - depth_i^2);
        t = linspace(0, 2*pi, 1000);
        x = (dist * cos(t)) / (60 * 1852) + lon_i;
        y = (dist * sin(t)) / (60 * 1852 * cosd(lat_i)) + lat_i; % turn the circle into an ellipse
        plot(lon_i, lat_i, 'ro');
        plot(x, y, 'b');
        for j=1:numel(t) % add points to histogram
            [~,x_pt] = min(abs(grid_lon - x(j)));
            [~,y_pt] = min(abs(grid_lat - y(j)));
            grid_circles(y_pt, x_pt) = grid_circles(y_pt, x_pt) + 1;
        end
    end
end
legend('Ship Location', 'Lander Range Circle');
xlabel('Latitude (deg E)');
ylabel('Longitude (deg N)');
title('Lander Range Circles, corrected with a posteriori depth and sound speed profile');
 
[~, max_i] = max(grid_circles(:));
[max_y, max_x] = ind2sub(size(grid_circles), max_i);
pos_lat = grid_lat(max_y);
pos_lon = grid_lon(max_x);
 
% scale figure 2 axes
daspect([1/cosd(pos_lat) 1 1]);
 
%% plot 2d histogram
figure(3); clf; hold on;
pcolor(grid_lon, grid_lat, grid_circles);
shading flat; colorbar;
plot(pos_lon, pos_lat, 'ko');
axis([min(grid_lon), max(grid_lon), min(grid_lat), max(grid_lat)]);
daspect([1/cosd(pos_lat) 1 1]);
xlabel('Latitude (deg E)');
ylabel('Longitude (deg N)');
title(sprintf('Most Probable Location: %.4f N, %.4f E', pos_lat, pos_lon));
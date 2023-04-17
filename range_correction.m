function [range_true] = range_correction(ssp, measurement, lander)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    % seawater stuff
    lon = -66.0;
    lat = 20.0;
    depth = -gsw_z_from_p(ssp.pres_db, lat);
    sal_abs = gsw_SA_from_SP(ssp.sal_psu, ssp.pres_db, lon, lat);
    svel = gsw_sound_speed(sal_abs, ssp.temp_its90, ssp.pres_db);
    
    % find start and end times of descent
    % there's some messy state stuff when we're bouncing around at the surface, so only look before we hit bottom for the first time
    ibottom = find(lander.state == 2, 1, 'first');
    istart = find(lander.state(1:ibottom)==1, 1, 'first');
    iend = find(lander.state(1:ibottom)==1, 1, 'last');
    tstart = lander.timestamp(istart)*1e6;
    tend = lander.timestamp(iend)*1e6;
     
    i_descent = find(ssp.ctd_t > tstart & ssp.ctd_t < tend);
    depth_descent = depth(i_descent);
    svel_descent = svel(i_descent);

    % filter svel
    d_depth = 10;
    samples_per_m = numel(depth_descent) / (max(depth_descent) - min(depth_descent));
    fc = 1 / d_depth; % cutoff frequency
    fs = samples_per_m; % sample frequency
    Wn = fc / (fs/2);
    [b,a] = butter(5, Wn);
    svel_filt = filtfilt(b, a, svel_descent);
     
    % downsample
    [~, i] = unique(depth_descent);
    depth_bins = d_depth:d_depth:max(depth_descent);
    svel_bins = interp1(depth_descent(i), svel_filt(i), depth_bins);
     
    % calculate harmonic mean sound speed
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

    % Calculate corrected range
    for i=1:numel(measurement.range)
        depth_i = interp1(ssp.ctd_t, depth, measurement.timestamp(i)*1e6);
        svel_i = interp1(depth_bins, svel_har_mean, depth_i, 'linear', 'extrap');
        range_true(i) = svel_i * measurement.range(i) / 1500;
    end

    figure
    plot(measurement.range); hold on;
    plot(range_true)
    set(gca,'YDir','reverse');
    legend('Range', 'Corrected Range')
    ylabel('Range (m)');

end
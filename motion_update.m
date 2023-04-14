function [state] = motion_update(state, p)
% motion update for particles vectorized using boolean statements for mode
% switching and transitions. 

    % Start the timer
    tic
    
    % Initialize velocity matrices
    u = state.u;
    v = state.v;
    w = zeros(size(state.w));
    
    % Descending
    idx_descending = state.mode == 0;
    u(idx_descending) = u(idx_descending) + normrnd(0, p.velocity_std_dev, sum(idx_descending), 1);
    v(idx_descending) = v(idx_descending) + normrnd(0, p.velocity_std_dev, sum(idx_descending), 1);
    w(idx_descending) = p.avg_descent_veloc + normrnd(0, p.descent_std_dev, sum(idx_descending), 1);
    
    % On bottom
    idx_on_bottom = state.mode == 1;
    bottom_time = state.bottom_time;
    bottom_time(idx_on_bottom) = bottom_time(idx_on_bottom) + p.delta_t;
    x = state.x + normrnd(0, p.velocity_std_dev, size(state.x));
    y = state.y + normrnd(0, p.velocity_std_dev, size(state.y));
    z = state.z + normrnd(0, p.velocity_std_dev, size(state.z));
    idx_transition = bottom_time > state.total_bottom_time;
    w(idx_on_bottom & ~idx_transition) = 0 + normrnd(0, p.velocity_std_dev, sum(idx_on_bottom & ~idx_transition), 1);
    
    % Ascending
    idx_ascending = state.mode == 2;
    u(idx_ascending) = u(idx_ascending) + normrnd(0, p.velocity_std_dev, sum(idx_ascending), 1);
    v(idx_ascending) = v(idx_ascending) + normrnd(0, p.velocity_std_dev, sum(idx_ascending), 1);
    w(idx_ascending) = p.avg_ascent_veloc + normrnd(0, p.descent_std_dev, sum(idx_ascending), 1);
    
    % Update positions
    state.x = state.x + u .* p.delta_t;
    state.y = state.y + v .* p.delta_t;
    state.z = state.z + w .* p.delta_t;
    
    % Update velocities
    state.u = u;
    state.v = v;
    state.w = w;
    
    % State transitions
    idx_transition = state.z >= state.z_transition & state.mode == 0;
    state.mode(idx_transition) = 1;
    state.u(idx_transition) = 0;
    state.v(idx_transition) = 0;
    state.w(idx_transition) = 0;
    
    idx_transition = bottom_time > state.total_bottom_time & state.mode == 1;
    state.mode(idx_transition) = 2;
    state.u(idx_transition) = 0;
    state.v(idx_transition) = 0;
    state.w(idx_transition) = 0;
    
    idx_transition = state.z <= 0 & state.mode == 2;
    state.mode(idx_transition) = 3;
    state.u(idx_transition) = 0;
    state.v(idx_transition) = 0;
    state.w(idx_transition) = 0;
    state.finished_particles = state.finished_particles + sum(idx_transition);
    
    % Update bottom time
    state.bottom_time = bottom_time;
    
    % Stop the timer and record the elapsed time
    elapsed_time = toc;
    
    disp('The elapsed time for the motion update is: ')
    disp(elapsed_time)
    
end
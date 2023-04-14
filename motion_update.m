function [state] = motion_update(state, p)
% motion update for particles vectorized using boolean statements for mode
% switching and transitions. 

    % Start the timer
    tic
    
    % Descending
    idx_descending = state.mode == 0;
    state.u(idx_descending) = state.u(idx_descending) + normrnd(0, p.velocity_std_dev, sum(idx_descending), 1);
    state.v(idx_descending) = state.v(idx_descending) + normrnd(0, p.velocity_std_dev, sum(idx_descending), 1);
    state.w(idx_descending) = p.avg_descent_veloc + normrnd(0, p.descent_std_dev, sum(idx_descending), 1);
    state.x(idx_descending) = state.x(idx_descending) + state.u(idx_descending)*p.delta_t;
    state.y(idx_descending) = state.y(idx_descending) + state.v(idx_descending)*p.delta_t;
    state.z(idx_descending) = state.z(idx_descending) + state.w(idx_descending)*p.delta_t;

    % Transition to on bottom
    idx_transition = state.z >= state.z_transition & state.mode == 0;
    state.mode(idx_transition) = 1;
    
    % On bottom
    idx_on_bottom = state.mode == 1;
    state.bottom_time(idx_on_bottom) = state.bottom_time(idx_on_bottom) + p.delta_t;
    state.u(idx_on_bottom) = 0;
    state.v(idx_on_bottom) = 0;
    state.w(idx_on_bottom) = 0;
    x(idx_on_bottom) = state.x(idx_on_bottom) + normrnd(0, p.velocity_std_dev, sum(idx_on_bottom),1);
    y(idx_on_bottom) = state.y(idx_on_bottom) + normrnd(0, p.velocity_std_dev, sum(idx_on_bottom),1);
    z(idx_on_bottom) = state.z(idx_on_bottom) + normrnd(0, p.velocity_std_dev, sum(idx_on_bottom),1);
    
    % Transition to ascending
    idx_transition = state.bottom_time > state.total_bottom_time & state.mode == 1;
    state.mode(idx_transition) = 2;
    
    % Ascending
    idx_ascending = state.mode == 2;
    state.u(idx_ascending) = state.u(idx_ascending) + normrnd(0, p.velocity_std_dev, sum(idx_ascending), 1);
    state.v(idx_ascending) = state.v(idx_ascending) + normrnd(0, p.velocity_std_dev, sum(idx_ascending), 1);
    state.w(idx_ascending) = p.avg_ascent_veloc + normrnd(0, p.descent_std_dev, sum(idx_ascending), 1);
    state.x(idx_ascending) = state.x(idx_ascending) + state.u(idx_ascending)*p.delta_t;
    state.y(idx_ascending) = state.y(idx_ascending) + state.v(idx_ascending)*p.delta_t;
    state.z(idx_ascending) = state.z(idx_ascending) + state.w(idx_ascending)*p.delta_t;

    
    % Transition to surface
    

    % On surface


       
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
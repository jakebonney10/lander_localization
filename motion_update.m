function [state] = motion_update(state, p)
% motion update for particles vectorized using boolean statements for mode
% switching and transitions. 

    % Start the timer
    tic
    
    %%%% MODE 0: DESCENDING
    % Descending Motion Model
    idx_descending = state.mode == 0;
    state.u(idx_descending) = state.u(idx_descending) + normrnd(0, p.velocity_std_dev, sum(idx_descending), 1);
    state.v(idx_descending) = state.v(idx_descending) + normrnd(0, p.velocity_std_dev, sum(idx_descending), 1);
    state.w(idx_descending) = p.avg_descent_veloc + normrnd(0, p.descent_std_dev, sum(idx_descending), 1);
    state.x(idx_descending) = state.x(idx_descending) + state.u(idx_descending)*p.delta_t;
    state.y(idx_descending) = state.y(idx_descending) + state.v(idx_descending)*p.delta_t;
    state.z(idx_descending) = state.z(idx_descending) + state.w(idx_descending)*p.delta_t;

    % Transition from Descending to On Bottom
    idx_0_to_1 = (state.z >= state.z_transition & state.mode == 0);
    state.mode(idx_0_to_1) = 1;


    %%%% MODE 1: ON BOTTOM
    % On Bottom Motion Model
    idx_on_bottom = (state.mode == 1);
    state.bottom_time(idx_on_bottom) = state.bottom_time(idx_on_bottom) + p.delta_t;
    state.u(idx_on_bottom) = 0;
    state.v(idx_on_bottom) = 0; % set velocities to zero on bottom
    state.w(idx_on_bottom) = 0;
    state.x(idx_on_bottom) = state.x(idx_on_bottom) + normrnd(0, p.on_bottom_position_sigma, sum(idx_on_bottom),1);
    state.y(idx_on_bottom) = state.y(idx_on_bottom) + normrnd(0, p.on_bottom_position_sigma, sum(idx_on_bottom),1);
    state.z(idx_on_bottom) = state.z(idx_on_bottom) + normrnd(0, p.on_bottom_position_sigma, sum(idx_on_bottom),1);

    % Transition from On Bottom to Ascending
    idx_1_to_2 = (state.bottom_time > state.total_bottom_time & state.mode == 1);
    state.mode(idx_1_to_2) = 2;


    %%%% MODE 2: ASCENDING
    % Ascending Motion Model
    idx_ascending = (state.mode == 2);
    state.u(idx_ascending) = state.u(idx_ascending) + normrnd(0, p.velocity_std_dev, sum(idx_ascending), 1);
    state.v(idx_ascending) = state.v(idx_ascending) + normrnd(0, p.velocity_std_dev, sum(idx_ascending), 1);
                                                            %p.ascent_std_dev? rename this param maybe
    state.w(idx_ascending) = p.avg_ascent_veloc + normrnd(0, p.descent_std_dev, sum(idx_ascending), 1);
    state.x(idx_ascending) = state.x(idx_ascending) + state.u(idx_ascending)*p.delta_t;
    state.y(idx_ascending) = state.y(idx_ascending) + state.v(idx_ascending)*p.delta_t;
    state.z(idx_ascending) = state.z(idx_ascending) + state.w(idx_ascending)*p.delta_t;
    
    % Transition to surface
    idx_2_to_3 = (state.z <= 0 & state.mode == 2);
    state.mode(idx_2_to_3) = 3;
    

    %%%% MODE 3: ON SURFACE
    % On Surface Motion Model (no motion)
            % just do nothing. calculations stop when in mode 3.
    idx_on_surface = (state.mode == 3);
    state.finished_particles = sum(idx_on_surface);

    
    % Stop the timer and record the elapsed time
    elapsed_time = toc;
    
    disp('The elapsed time for the motion update is: ')
    disp(elapsed_time)
    
end
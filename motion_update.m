function [state] = motion_update(state, p)


    % motion model update for each particle
    for i=1:p.num_particles
        

        % SWITCH BASED ON MODE for each particle
        switch state.mode(i)


            case 0      % descending

                % Update velocities u,v,w
                state.u(i) = state.u(i) + normrnd(0, p.velocity_std_dev);
                state.v(i) = state.v(i) + normrnd(0, p.velocity_std_dev);
                state.w(i) = p.avg_descent_veloc + normrnd(0, p.descent_std_dev);

                % Update positions x,y,z
                state.x(i) = state.x(i) + state.u(i)*p.delta_t;
                state.y(i) = state.y(i) + state.v(i)*p.delta_t;
                state.z(i) = state.z(i) + state.w(i)*p.delta_t;
                
                % State transition
                if state.z(i) >= state.z_transition(i)            % if at the seafloor
                    state.mode(i) = 1;                            % switch to 'on bottom'

                    state.u(i) = 0;
                    state.v(i) = 0;               % set velocities to zero
                    state.w(i) = 0;
                end


            case 1      % on bottom
                
                % Update bottom_time
                state.bottom_time(i) = state.bottom_time(i) + p.delta_t;

                % TO DO: ADD RANDOM 'JITTER'/WALK to PARTICLES RESTING ON BOTTOM
                % x, y, z motion updates

                % State transition
                if state.bottom_time(i) > p.total_bottom_time     % if reach max time on bottom, start ascent
                    state.mode(i) = 2;                            % switch to 'ascending'
                end


            case 2      % ascending

                % Update velocities u,v,w
                state.u(i) = state.u(i) + normrnd(0, p.velocity_std_dev);
                state.v(i) = state.v(i) + normrnd(0, p.velocity_std_dev);
                state.w(i) = p.avg_ascent_veloc + normrnd(0, p.descent_std_dev);

                % Update positions x,y,z
                state.x(i) = state.x(i) + state.u(i)*p.delta_t;
                state.y(i) = state.y(i) + state.v(i)*p.delta_t;
                state.z(i) = state.z(i) + state.w(i)*p.delta_t;
                
                % State transition
                if state.z(i) <= 0          % if reach z = 0
                    state.mode(i) = 4;      % switch to 'at surface'

                    state.u(i) = 0;
                    state.v(i) = 0;         % set velocities to zero
                    state.w(i) = 0;

                    state.finished_particles = state.finished_particles + 1;
                end


            case 3      % at surface

                % basically don't do anything. let particles sit and wait for the rest to come up.
                % this is the final state.

        end     % end switch statement


    end     % end for loop over each particle


end         % end function definition
function state = resample_particles(state)
% stochastic universal resampling (SUR) for particles based off their weights


% Compute cumulative sum of particle weights
w_cumulative = cumsum(state.weight);

% Compute step size
n = length(state.weight);
extractions = 1/(2*n):1/n:(2*n-1)/(2*n); % where we pull indices from on the cumsum

% Initialize indices
indices = zeros(length(state.weight), 1);

% Loop over all particles, find the index in the cumsum closest to our extraction values
for i = 1:n             % to go thru extractions
    for j = 1:n         % to go thru w_cumulative
        if (w_cumulative(j)> extractions(i)) % criteria to select a particle to live on
            indices(i) = j; % save the particle index we want to include
            break;
        end
    end
end


% save particle states and weights
state.x = state.x(indices);
state.y = state.y(indices);
state.z = state.z(indices);
state.u = state.u(indices);
state.v = state.v(indices);
state.w = state.w(indices);
state.z_transition = state.z_transition(indices);

% save particle mode and bottom time
state.mode = state.mode(indices);
state.bottom_time = state.bottom_time(indices);

% reset particle weights to uniform values
state.weight = ones(length(state.weight), 1) / length(state.weight); 


end
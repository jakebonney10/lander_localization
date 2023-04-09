function [rng] = particle_range(state,ship_pos)
%PARTICLE_RANGE Calculate range to individual particle.
%   Range is needed for measurement update and weighting of particles
%   compared to measured range. 

x = state.x - ship_pos.x;
y = state.y - ship_pos.y;
z = state.z - ship_pos.z; % ship_pos.z should be 0 (@ ocean surface)
rng = sqrt(x.^2 + y.^2 + z.^2);

end



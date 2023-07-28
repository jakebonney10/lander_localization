function [uncertainty] = set_velocity_uncertainty(p, depth)
    % Change velocity uncertainty linearly with depth until 500m then
    % constant uncertainty.
    % p.velocity_std_dev: velocity uncertainty
    % p.velocity_std_dev_surface: velocity uncertainty at the surface
    
    % Linearly decrease uncertainty from 0-500 meters
    if depth <= 500
        slope = (p.velocity_std_dev_surface - p.velocity_std_dev_surface/10) / 500;
        uncertainty = p.velocity_std_dev_surface - slope * depth;
    % Set constant uncertainty after 500 meters until the seafloor
    else
        uncertainty = p.velocity_std_dev_surface/10;
    end
    
    % Ensure uncertainty is non-negative
    uncertainty = max(uncertainty, 0);
end
function [totalMovement, totalXMovement, totalYMovement] = get_total_ship_movement(shipData, start_time, surface_time, origin_lat, origin_lon)
    % Extract dive-specific ship location data
    diveIndices = shipData.timestamp >= start_time & shipData.timestamp <= surface_time;
    
    % Convert lat/lon to UTM
    utm_zone = 19; % TODO: Dont hardcode this
    [ship_x, ship_y] = ll2utm(shipData.lat, shipData.lon, utm_zone);
    [origin_x, origin_y] = ll2utm(origin_lat, origin_lon, utm_zone);
    local_x = ship_x - origin_x;
    local_y = ship_y - origin_y;
    
    diveX = local_x(diveIndices);
    diveY = local_y(diveIndices);
    
    % Calculate distance moved during the dive
    distances = sqrt(diff(diveX).^2 + diff(diveY).^2);
    xDistances = diff(diveX);
    yDistances = diff(diveY);
    
    % Sum up the distances to get total movement
    totalMovement = sum(distances);
    totalXMovement = sum(xDistances);
    totalYMovement = sum(yDistances);
    
    % Plot ship movement
    plot(diveX,diveY)
    xlabel('X (meters)')
    ylabel('Y (meters)')
    axis equal
    
    
end


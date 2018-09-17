function brush = marker_to_brush(high1, med1, low1, high2, med2, ...
    low2, pencil_model)
% MARKER_TO_BRUSH compute the brush position given the marker 3D points
% The function assumes that everithing is in the camera frame, in this way
% it is reasonable to assume the brush to be at more depth than the marker.
% This avoid the need of distinguish between left and right points of the
% marker
% Parameters:
% - points of the marker
% - pencil_model: see pencil_model.m

    mean_low = (low1 + low2) / 2;
    mean_mid = (med1 + med2) / 2;
    dir = (mean_low - mean_mid) / norm(mean_low - mean_mid);
    plane = plane_ls([high1; med1; low1; high2; med2; low2]);
    normal = plane(1:3) / norm(plane(1:3));
    brush1 = mean_low + dir * pencil_model.marker_low_brush_distance + ...
        normal * pencil_model.depth_distance;
    brush2 = mean_low + dir * pencil_model.marker_low_brush_distance - ...
        normal * pencil_model.depth_distance;
    % check on z coordinate
    if brush1(3) > brush2(3)
        brush = brush1;
    else
        brush = brush2;
    end
end
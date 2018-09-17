function d = point_plane_distance(plane, pt)
%POINT_PLANE_DISTANCE distance from the point to the plane
%   Parameters:
%   - plane is a 1x4 vector
%   - pt is a 1x3 vector
    numerator = abs(dot(plane, [pt, 1]));
    denominator = norm(plane(1:3));
    d = numerator / denominator;
end


function p_prime = project_points_to_plane(points,plane)
%PROJECT_POINT_TO_PLANE Project points to plane
%   Parameters:
%   - point: Nx3
%   - plane: 1x4
% t as column vector, for each point its t
t = - ((plane(1:3)*points' + plane(4))/(norm(plane(1:3))^2))';
p_prime = points + plane(1:3).*t;
end


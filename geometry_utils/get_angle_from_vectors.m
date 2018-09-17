function angle = get_angle_from_vectors(v1,v2)
%GET_ANGLE_FROM_LINES Summary of this function goes here
%   Detailed explanation goes here
% extract only the useful part for computing the angle
% l1 = l1(1:2,:); 
% l2 = l2(1:2,:);

% measure the cosine between lines
cos_theta = (v1.' * v2)/(norm(v1,2)*norm(v2,2));
angle = acosd(cos_theta);
end


function angle = get_angle_from_lines(l1,l2)
%GET_ANGLE_FROM_LINES Summary of this function goes here
%   Detailed explanation goes here
% extract only the useful part for computing the angle
    l1 = l1(1:2,:) / l1(3); 
    l2 = l2(1:2,:) / l2(3);

    % measure the cosine between lines
    cos_theta = (l1.' * l2)/(norm(l1,2)*norm(l2,2));
    angle = acosd(cos_theta);
end


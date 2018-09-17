function [R, t] = planar_object_localization(H, K)
%PLANAR_OBJECT_LOCALIZATION Localize a planar object in camera frame given an homography from the real world to the image
    
    ijo = K \ H;
    
    % normalize the i and j vectors
    i_norm = norm(ijo(:, 1), 2);
    i = ijo(:, 1) / norm(ijo(:, 1), 2);
    j = ijo(:, 2) / norm(ijo(:, 2), 2);
    k = cross(i, j) / norm(cross(i, j), 2);
    t = ijo(:, 3)/i_norm;

    R = [i, j, k];
    % due to numerical error R might not be a rotation matrix, approximate it
    [U, ~, V] = svd(R);
    R = (U * V');
end


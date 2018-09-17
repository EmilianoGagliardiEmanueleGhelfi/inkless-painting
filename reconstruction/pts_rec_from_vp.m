function [high, med, low] = pts_rec_from_vp( ...
    M, img_points, vanishing_point, distances)
%PTS_REC_FROM_VP Reconstruct 3 colinear point with known scene distance given the image of the vanishing point on the same line
% Parameters:
% - M: first 3x3 matrix of P (K*R)
% - img_points: three points as row vectors (homog coordinates)
% - vanishing_point: vanishing point of the direction of the 3 input
%                    points (homog coordinates)
% - distances: vector of two elements, distance from first to second
%              distance from second to third
% Returns:
% reconstructed 3D points
    
    high_med_real = distances(1);
    med_low_real = distances(2);
    high_low_real = high_med_real + med_low_real;
    
    high_back = M \ img_points(1, :)';
    med_back = M \ img_points(2, :)';
    low_back = M \ img_points(3, :)';
    v_back = M \ vanishing_point';
    
    % compute the 3d position of low 
    % compute angles
    alpha = get_angle_from_vectors(high_back, low_back);
    gamma = get_angle_from_vectors(high_back, v_back);
    
    distance_low = high_low_real*sind(gamma)/sind(alpha);
    
    % to compute the 3d position of low, move on the low_back of
    % distance_low
    low = (low_back*distance_low/norm(low_back))';
    
    % compute the 3d position of med
    % compute angles
    beta = get_angle_from_vectors(high_back, med_back);
    
    distance_med = high_med_real*sind(gamma)/sind(beta);
    
    % to compute the 3d position of med, move on the med_back of
    % distance_med
    med = (med_back*distance_med/norm(med_back))';
    
    % compute the 3d position of high
    % compute angles
    delta = get_angle_from_vectors(low_back, v_back);
    
    distance_high = high_low_real*sind(delta)/sind(alpha);
    
    % to compute the 3d position of med, move on the med_back of
    % distance_med
    high = (high_back*distance_high/norm(high_back))';
    alpha + gamma + delta;
end


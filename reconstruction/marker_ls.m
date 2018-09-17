function [high1, med1, low1, high2, med2, low2, ok] =  marker_ls(points, ...
    threshold, marker_model)
% MARKER_LS compute the least square marker given its 6 points
% Paramters:
% - points: 3D points of the marker
% - threshold: if a point is distant from the corresponding point in the
% fitted marker more than threshold then ok is set to false
% - marker_model: see pencil_model.m

    % marker model 
    marker = [% left points
              0, marker_model.high_med_distance + ... 
                marker_model.med_low_distance, 0; 
              0, marker_model.med_low_distance, 0;
              0, 0, 0;
              % right
              marker_model.horiz_distance, ...
              marker_model.high_med_distance + ... 
                marker_model.med_low_distance, 0;
              marker_model.horiz_distance, marker_model.med_low_distance, 0;
              marker_model.horiz_distance, 0, 0];
    [R, t] = absolute_orientation(marker', points);
    if any(any(isnan(R)))
        ok = false;
    end
    points_prime = R*marker' + t;
    % norm over columns, how much points on the image are non coplanar 
    errors = vecnorm(points_prime - points, 2, 1);
    ok = all(errors < threshold);
    if ~ok
        disp('Reconstruction failed, fitting residuals:');
        errors
    end
    high1 = points_prime(:,1)';
    med1 =  points_prime(:,2)';
    low1 =  points_prime(:,3)';
    high2 =  points_prime(:,4)';
    med2 =  points_prime(:,5)';
    low2 =  points_prime(:,6)';
end
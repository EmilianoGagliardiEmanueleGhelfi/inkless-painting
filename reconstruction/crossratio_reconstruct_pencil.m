function [high1, med1, low1, high2, med2, low2, brush_position] ...
          = crossratio_reconstruct_pencil(K, lines, corners, pencil_model, ...
                check_3D_threshold, use_parallel_lines, debug)
% CROSSRATIO_RECONSTRUCT_PENCIL compute the ls 3D positions of the 6 intersection points on the marker and the pencil using cross ratio colinear points reconstruction   
% Parameters:
% - K: calibration matrix
% - lines: marker lines
% - corners: high, med, low for both vertical lines on the brush (6 pts)
%   6x3 matrix
% - pencil_model: see pencil_model.m
% - check_3D_threshold: maximum error allowed between the reconstructed
% - use_parallel_lines: if set to false parallel lines of the marker
% intersection is excluded in the fitting of the vanishing point
% points and the least square marker
% Returns:
% markers points 3D reconstruction
    
    if nargin <= 5
        debug = false;
    end
        
    lines_h = lines2homogeneous(lines);
    
    img_pts_1 = [corners(1:3, :), ones(3, 1)];
    img_pts_2 = [corners(4:6, :), ones(3, 1)];
    
    line1 = line_ls(img_pts_1);
    line2 = line_ls(img_pts_2);
    lines_h = [line1; line2];
     
    % compute the image of the vanishing point from crossratio
    % conservation. 
    vpguess = (img_pts_1(3,1:2) + img_pts_2(3,1:2))./ 2;
    vp = nonlinearfit_vp(lines_h(1,:), lines_h(2,:), img_pts_1, img_pts_2,...
                         [pencil_model.marker_model.high_med_distance, ...
                         pencil_model.marker_model.med_low_distance], ...
                         vpguess, use_parallel_lines);
    % check that the vanishing point has been found
    if isnan(vp)
        disp("Vanishing point optimization terminated with error");
        [high1, med1, low1, high2, med2, low2, brush_position] = fail();
        return
    end
    
    % reconstruction from vanishing point of the two triples of colinear
    % points
    [high1_, med1_, low1_] = pts_rec_from_vp(K, img_pts_1, vp, ...
        [pencil_model.marker_model.high_med_distance, ...
         pencil_model.marker_model.med_low_distance]);
    [high2_, med2_, low2_] = pts_rec_from_vp(K, img_pts_2, vp, ...
        [pencil_model.marker_model.high_med_distance, ...
         pencil_model.marker_model.med_low_distance]);
    
    % fit the least square model
    [high1, med1, low1, high2, med2, low2, ok] = marker_ls(...
        [high1_; med1_; low1_; high2_; med2_; low2_]',...
        check_3D_threshold, pencil_model.marker_model);
    
    brush_position = marker_to_brush(high1, med1, low1, high2, med2, ...
    low2, pencil_model);
    
    % debug
    if debug
       f = figure();
       plotCamera('Location', [0,0,0],'Orientation', eye(3), 'Size',1);
       hold on
       scatter3(high1_(1), high1_(2), high1_(3), 10, 'red', 'filled');
       scatter3(med1_(1), med1_(2), med1_(3), 10, 'red', 'filled');
       scatter3(low1_(1), low1_(2), low1_(3), 10, 'red', 'filled');
       scatter3(high2_(1), high2_(2), high2_(3), 10, 'red', 'filled');
       scatter3(med2_(1), med2_(2), med2_(3), 10, 'red', 'filled');
       scatter3(low2_(1), low2_(2), low2_(3), 10, 'red', 'filled');
       scatter3(high1(1), high1(2), high1(3), 10, 'green', 'filled');
       scatter3(med1(1), med1(2), med1(3), 10, 'green', 'filled');
       scatter3(low1(1), low1(2), low1(3), 10, 'green', 'filled');
       scatter3(high2(1), high2(2), high2(3), 10, 'green', 'filled');
       scatter3(med2(1), med2(2), med2(3), 10, 'green', 'filled');
       scatter3(low2(1), low2(2), low2(3), 10, 'green', 'filled');
       scatter3(brush_position(1), brush_position(2), brush_position(3), ...
           10, 'black', 'filled');
       axis equal;
       title('reconstruction in camera frame (red reconstructed, green fitted)');
       xlabel('X');
       ylabel('Y');
       zlabel('Z');
       pause;
       close(f)
    end
    
    if ~ok
        [high1, med1, low1, high2, med2, low2, brush_position] = fail();
        return
    end
end


function [high1, med1, low1, high2, med2, low2, brush_position] = fail()
    high1 = nan(1,3); 
    med1 = nan(1,3); 
    low1 = nan(1,3);
    brush_position = nan(1,3);
    high2 = nan(1,3); 
    med2 = nan(1,3);
    low2 = nan(1,3);
end
         
              


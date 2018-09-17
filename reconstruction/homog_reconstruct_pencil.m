function [high1, med1, low1, high2, med2, low2, brush_position] = homog_reconstruct_pencil(H, K, pencil_model)
%HOMOG_RECONSTRUCT_PENCIL compute the ls 3D positions of the 6 intersection points on the marker and the pencil using planar object localization
    
    marker_model_2D = marker_model_to_pts(pencil_model.marker_model);
    marker_model_3D = [marker_model_2D, zeros(6, 1)];
    [R, t] = planar_object_localization(H, K);
    marker_3D = marker_model_3D * R'  + t';
    high1 = marker_3D(1, :);
    med1 = marker_3D(2, :);
    low1 = marker_3D(3, :);
    high2 = marker_3D(4, :);
    med2 = marker_3D(5, :);
    low2 = marker_3D(6, :);
    brush_position = marker_to_brush(high1, med1, low1, high2, med2, ...
        low2, pencil_model);
end


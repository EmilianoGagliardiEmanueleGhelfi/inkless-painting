function [R, t] = camera_localization(K, homog_templato_to_image, ...
    width_template_image, height_template_image, width_template_scene, ...
    height_template_scene)
    % returns the rotation and traslation of the camera with respect to the 
    % planar object.
    
    % compute the scaling matrix from the real template size (the real size
    % of the sheet) to the template image size
    s_pts = [0, 0; height_template_scene, 0;  0, width_template_scene; ...
        height_template_scene, width_template_scene];
    i_pts = [0, 0; 0, height_template_image; width_template_image, 0; ...
        width_template_image, height_template_image];
    Hresize_trans = fitgeotrans(s_pts, i_pts, 'affine');
    % compute the homography from the scene to the image
    H = homog_templato_to_image * Hresize_trans.T';
    [R_, t_] = planar_object_localization(H, K);
    R = R_';
    t = -R_' * t_;
end


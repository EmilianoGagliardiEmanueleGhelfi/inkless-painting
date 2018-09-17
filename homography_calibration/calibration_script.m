% load parameters in your workspace before running this

% obtain calibration matrix from template images
K = homog_calibration(TEMPLATE_IMAGE_FILENAME, ...
    CALIBRATION_IMAGES_DIRECTORY, HOMOGRAPHY_REJECTION_PARAMS, ...
    MATCHING_PARAMS, CALIBRATION_DEBUG);

% localize the camera using the localization image
template = rgb2gray(imread(TEMPLATE_IMAGE_FILENAME));
localization_image = rgb2gray(imread(LOCALIZATION_IMAGE_FILENAME));
H = get_homog(template, localization_image, ...
    HOMOGRAPHY_REJECTION_PARAMS, MATCHING_PARAMS, LOCALIZATION_DEBUG, ...
    LOCALIZATION_IMAGE_FILENAME);
% Using a precomputed H
if any(any(isnan(H)))    
    R = nan;
    t = nan;
    disp('localization failed');
else
    disp(['Homography succesfully found in ', LOCALIZATION_IMAGE_FILENAME]);
    [R, t] = camera_localization(K, H, size(template, 1), ...
                                size(template, 2), ...
                                REAL_TEMPLATE_SIZE(1), ...
                                REAL_TEMPLATE_SIZE(2));
    disp('Localization completed: ');
    disp('R =');
    disp(R);
    disp('t = ');
    disp(t);
end


save(CALIB_OUTPUT_PATH, 'K', 'R', 't');
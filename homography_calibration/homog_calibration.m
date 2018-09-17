function K = homog_calibration(template_name, directory_name, ...
    rejection_params, matching_params, debug)
% HOMOG_CALIBRATION Computes calibration matrix from a set of images representing a known template
% For each scene image in the given directory compute the homography from
% the template to the image using SURF features matching and outliers 
% rejection. The homographies are used to impose constraints on IAC, and
% then obtain K. 
% Parameters:
% - template_name: file name of the image containing the template
% - directory_name: file name of the directory contaning images
% - rejection_params: struct containing the fields:
%   - min_inliers: minimum number of inliers to accept an homography
%   - confidence: outlier rejection algorithm confidence
%   - max_distance: max distance allowed between matched features after an
%       homography H has been applied to consider the pair as an inlier
%   - iterations: maximum number of iteration of the outlier rejection
%       mechanism
% - matching_params: a struct with fields
%   - desc_distance_threshold: see matchFeatures function 'MatchThreshold'
%   - ratio_threshold: see matchFeatures function 'MaxRatio'

% Returns:
% - K: calibration matrix

    if nargin <= 4
        debug = false;
    end

    % read the template file
    template = rgb2gray(imread(template_name));
    % extract template features and descriptors
    template_keypoints = detectSURFFeatures(template);
    [template_desc, template_keypoints] = extractFeatures(template, ...
            template_keypoints);
        
    % read all files contained in the directory
    d = dir(directory_name);

    % structure containing the homographies
    Hs = {};

    % for each file find H
    for ii = 1:size(d',2)  
        % read the image and convert into grayscale
        scene_filename = [d(ii).folder, '/', d(ii).name];
        scene_image = rgb2gray(imread(scene_filename));
        % find the homography
        Hs_temp = get_homog_from_prec_feat(template_keypoints, ...
            template_desc, scene_image, rejection_params, ...
            matching_params, debug, template, scene_filename);

        % check if an homography has been found
        if size(Hs_temp,1) == 3
            % concatenate
            Hs = [Hs, Hs_temp];
            disp(['Homography succesfully found in ', scene_filename]);
        else
            disp(['Homography not found in ', scene_filename]);
        end
    end

    IAC = IAC_from_homographies(Hs);

    % compute K, calibration matrix
    a = sqrt(IAC(1, 1));
    u = -IAC(1, 3)/IAC(1, 1);
    v = -IAC(2, 3);
    fy = sqrt(IAC(3, 3) - IAC(1, 1)*u^2 - v^2);
    fx = fy/a;
    K = [fx,  0, u;
         0,  fy, v;
         0,   0, 1];
     

    disp('Calibration completed');
    disp('K = ');
    disp(K);
end


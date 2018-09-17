function H = get_homog(template, scene_image, rejection_params, ... 
    matching_params, debug, fig_title) 
% GET_HOMOG Computer the homography between the template and the scene file using SURF descriptors matching and outliers rejection
% Parameters:
% - template: grayscale template image
% - scene_image: grayscale scene image 
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


    if nargin <= 4
        debug = false;
        fig_title = '';
    end
    % extract template features and descriptors
    template_keypoints = detectSURFFeatures(template);
    [template_desc, template_keypoints] = extractFeatures(template, ...
            template_keypoints);
    % pass them to the helper function togheter with the scene image, 
    % this avoid to repeat computation of template keypoints and 
    H = get_homog_from_prec_feat(template_keypoints, template_desc, ...
        scene_image, rejection_params, matching_params, debug, template, ...
        fig_title);
end
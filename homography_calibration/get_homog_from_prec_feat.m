function H = get_homog_from_prec_feat(...
    template_keypoints, template_descr, scene_image, rejection_params, ...
    matching_params, debug, template, fig_title)
% GET_HOMOG_FROM_PREC_FEAT Compute the homography between two set of points with outliers rejection
% Parameters:
% - template_keypoints: keypoints extracted from the template image
% - template_descr: descriptors associated to the template image keypoints
% - scene_image: image in which the template is searched
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
% other parameters are used for debugging
% Returns:
% - H: fitted homography, nan if failed

    if nargin <= 5
        debug = false;
    end
    
    % extract features and descriprors from the scene image
    scene_keypoints = detectSURFFeatures(scene_image);
    [scene_descr, scene_keypoints] = extractFeatures(scene_image, ...
        scene_keypoints);

    % Match features using descriptors
    pairs = matchFeatures(template_descr, scene_descr, ...
        'MatchThreshold', matching_params.desc_distance_threshold, ...
        'MaxRatio', matching_params.ratio_threshold);

    matchedTemplatePoints = template_keypoints(pairs(:, 1), :);
    matchedScenePoints = scene_keypoints(pairs(:, 2), :);
    
    % Locate the object
    [tform, inl, ~, status] = ...
        estimateGeometricTransform(matchedTemplatePoints, ...
        matchedScenePoints, 'projective', 'MaxDistance', ...
        rejection_params.max_distance,  'MaxNumTrials', ...
        rejection_params.iterations, 'Confidence', ...
        rejection_params.confidence);

    if debug
        boxPolygon = [0, 0;...                           % top-left
                size(template, 2), 0;...                 % top-right
                size(template, 2), size(template, 1);... % bottom-right
                0, size(template, 1);...                 % bottom-left
                0, 0];                   % top-left again to close the polygon

        %Transform the bounding box according to the homography
        newBoxPolygon = transformPointsForward(tform, boxPolygon);

        figure;
        imshow(scene_image);
        hold on;
        line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'r');
        title(fig_title);
        pause
        close all
    end

    % filter on the number of the inlier points, we request at least
    % inlier_number
    if size(inl, 1) < rejection_params.min_inliers | status ~= 0
        H = nan;
    else
        H = tform.T';
    end

end


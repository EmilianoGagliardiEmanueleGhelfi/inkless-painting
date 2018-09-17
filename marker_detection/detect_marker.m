function [out_lines, model_image, H] = detect_marker(rgb, rgb_filter, ...
    hough_params_v, hough_params_h, dilate_disk_size, ROI_size, ...
    min_corner_quality, marker_model, threshold, debug)
% DETECT_MARKER given an image containing the marker detects the 6 points that are intersection of the lines in the marker
% Hough lines of the marker are detected, then intersected to obtain a
% guess for the marker corners. For each guess the nearest Harris corner is
% kept as marker corner.
% Parameters:
% - rgb: input image
% - rgb_filter: function handle applying rgb filter to keep the marker mask
% - hough_params_v: parameters of the hough algorithm that select vertical
% lines of the marker, detailed description in get_houg_vertical_lines.m
% - hough_params_h: parameters of the hough algorithm that select
% horizontal lines of the marker, detailed description in 
% get_houg_horizontal_lines.m
% dilate_disk_size: disk size of the dilation applied to the output of the
% rgb filter
% - ROI_size: size of the region of interest in which the nearest corner is
% searched
% - min_corner_quality: see detectHarrisFeatures 'MinQuality'
% - marker_model: see pencil_model.m
% - threshold: maximum pixel distance allowed between the fitted marker
% image and the found harris corners
% Returns
% - out_lines: lines of the marker in the image as struct like the 
% houghlines output. The first two lines are the long vertical lines of the
% marker, the others are the short horizontal ones
% - model_image: 6x3 matrix contaning high1, med1, low1, high2, med2, low2
% points of the marker. It is not assured that high1, med1,
% low1 corresponds to left point or right points. Only the height of the
% points is considered for distinguish them

    % apply the rgb filter 
    mask = rgb_filter(rgb);
    
    if debug.RGB_debug
        f = figure();
        imshow(mask);
        title('RGB filter output');
        pause;
        close(f);
    end
    
    % apply dilation and erosion
    dilatedImage = imdilate(mask,strel('disk', dilate_disk_size));
    mask_eroded = bwmorph(dilatedImage,'thin', inf);
    
    if debug.dilation_erosion_debug
        f = figure();
        imshow(mask_eroded);
        title('Dilation and erosion output');
        pause;
        close(f);
    end
    
    % apply hough to obtain vertical canditate, then obtain the most
    % parallel ones
    vertical_candidates = get_hough_vertical_lines(mask_eroded, ...
        hough_params_v, debug.vertical_lines_debug);
    vertical_lines = vertical_pair(vertical_candidates);
    if ~isstruct(vertical_lines) % vertical lines detection failed
        out_lines = nan;
        model_image = nan;
        H = nan;
        return
    end
    
    % apply hough to obtain horizontal candidates, then choose the ones
    % that are most perpendicular to the vertical ones
    horizontal_candidates = get_hough_horizontal_lines(mask_eroded, ...
        hough_params_h, debug.horizontal_lines_debug);
    horizontal_lines = horizontal_triple(horizontal_candidates, ...
       vertical_lines);
    if ~isstruct(horizontal_lines) % horizontal lines detection failed
        out_lines = nan;
        model_image = nan;
        H = nan;
        return
    end
    
    
    out_lines = [vertical_lines horizontal_lines];
    colors = 'r';
    if debug.resulting_lines_debug
        f = plot_lines(rgb, out_lines, colors, 'Selected lines');
        hold on
        pause;
        close(f);
    end
    
    % get the corners of the marker, using the lines intersections as
    % guesses
    lines_h = lines2homogeneous(out_lines);
    img_pts_1 = apply_to_rows(@(x) cross(lines_h(1, :), x), ...
        lines_h(3:end, :));
    img_pts_2 = apply_to_rows(@(x) cross(lines_h(2, :), x), ...
        lines_h(3:end, :));
     % normalize dividing by last component
    img_pts_1 = img_pts_1 ./ img_pts_1(:, 3);
    img_pts_2 = img_pts_2 ./ img_pts_2(:, 3);
    % order points from the highest one in the image to the
    % lowest one
    img_pts_1 = sortrows(img_pts_1, 2);
    img_pts_2 = sortrows(img_pts_2, 2);
    img_pts = [img_pts_1; img_pts_2];
    harris_corners = nan(6, 2);
    for ii = 1:size(img_pts, 1)
        harris_corners(ii, :) = detect_marker_corner(rgb, ...
             ROI_size, min_corner_quality, img_pts(ii, :), ...
             debug.extracted_corners_debug); 
    end
    
    % check that all harris corners have been found
    if any(any(isnan(harris_corners)))
        out_lines = nan;
        model_image = nan;
        H = nan;
        return
    end
    
    % fit an homography from the marker model to the 
    model2D = marker_model_to_pts(marker_model);
    try
        T = fitgeotrans(model2D, harris_corners, 'projective');
        model_image = transformPointsForward(T, model2D);
    catch
        out_lines = nan;
        model_image = nan;
        H = nan;
        return;
    end
    
    H = T.T';
    
    if debug.resulting_corners_debug
        f = figure();
        imshow(rgb);
        hold on;
        plot(harris_corners(:, 1), harris_corners(:, 2), 'r+');
        plot(model_image(:, 1), model_image(:, 2), 'g+');
        title('Detected points in red, fitted in green');
        pause;
        close(f);
    end
    
    % 2D geometrical check
    errors = vecnorm(harris_corners - model_image, 2, 2);
    if any(errors > threshold) % 2D geometrical check failed
        out_lines = nan;
        model_image = nan;
        H = nan;
    end
end


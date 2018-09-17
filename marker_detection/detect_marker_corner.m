function out = detect_marker_corner(im, ROI_size, min_quality, point_guess, debug)
% DETECT_MARKER_CORNER returns the nearest harris features to the input
% guess
% Params
% - im: the dilation of the mask of the corner
% - ROI_size: size of the region of interest in which the corner is
% searched
% - min_quality: see detectHarrisFeatures 'MinQuality'
% - point_guess: pixel coordinates of a point likely to be near to a
% corner of the marker, 1x2 matrix [x, y]. This is the center of the region
% of interes
    if length(point_guess) == 3
        point_guess = point_guess(1:2) / point_guess(3);
    end
    
    if size(im, 3) == 3
        im = rgb2gray(im);
    end
    
    ROI = [point_guess - ROI_size/2, ROI_size, ROI_size];
    
    imsize = size(im);
    if ROI(1) < 1 || ROI(2) < 1 ...
       || ROI(1)+ROI(3) > imsize(2)+1 ...
       || ROI(2)+ROI(4) > imsize(1)+1
        out = nan;
        return;
    end
    
    corners = detectHarrisFeatures(im, 'ROI', ROI, 'MinQuality', ...
        min_quality);
    pts = corners.Location;
    if isempty(pts)
        out = nan;
        return;
    end

    out = mean(pts, 1);
    
    if debug
        f = figure();
        imshow(im);
        hold on
        % plot roi
        rectangle('Position', ROI);
        m = mean(pts, 1);
        plot(pts(:, 1), pts(:, 2), 'go', 'MarkerSize', 5);
        plot(m(1), m(2), 'r+', 'MarkerSize', 5);
        pause;
        close(f);
    end
end


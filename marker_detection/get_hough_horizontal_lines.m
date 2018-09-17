function lines = get_hough_horizontal_lines(edges, hough_params, debug)    
% GET_HOUGH_HORIZONTAL_LINES apply hough transform and find horizontal lines of the marker
% Parameters
% - edges: image containing the marker edges
% - hough_params: a struct with fields
%   - theta_rotated_image: see hough 'Theta'. Consider that the image is 
%     rotated by 90 degree before
%   - rho_resolution: see hough 'RhoResolution'
%   - peacks_number: number of peacks selected
%   - nhood_size_scale: size(H) is divided by this parameter, obtaining the
%     hough space nhood size. H is the hough transform
%   - fill_gap: see houghlines 'FillGap'
%   - min_length: see houghlines 'MinLength'
% Returns
% - the set of lines returned bu hough
    
    % rotate so that horizontal lines, potentially on disjoint intervals of
    % theta, get in a single connected interval
    edges_r = imrotate(edges, 90);
    [H, T, R] = hough(edges_r, 'Theta', hough_params.theta_rotated_image, ...
        'RhoResolution', hough_params.rho_resolution);
    P  = houghpeaks(H, hough_params.peacks_number, ...
        'NHoodSize', smallest_odd(size(H)/hough_params.nhood_size_scale), ...
        'Threshold', hough_params.threshold_mult * max(H(:)));
    lines = houghlines(edges_r, T, R, P, 'FillGap', ...
        hough_params.fill_gap, 'MinLength', hough_params.min_length);
    % rotate back the lines
    t = [size(edges, 2); 0];
    R = [cosd(90), -sind(90); sind(90), cosd(90)];
    for ii = 1:length(lines)
        lines(ii).point1 = (t + R * lines(ii).point1')';
        lines(ii).point2 = (t + R * lines(ii).point2')';
    end
    if debug
        f = plot_lines(edges, lines,'r', 'Hough horizontal lines');
        pause;
        close(f);
    end
end
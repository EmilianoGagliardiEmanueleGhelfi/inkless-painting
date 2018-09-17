function lines = get_hough_vertical_lines(edges, hough_params, debug)    
% GET_HOUGH_VERTICAL_LINES apply hough transform and find vertical lines of the marker
% Parameters
% - edges: image containing the marker edges
% - hough_params: a struct with fields
%   - theta: see hough 'Theta'
%   - rho_resolution: see hough 'RhoResolution'
%   - peacks_number: number of peacks selected
%   - nhood_size_scale: size(H) is divided by this parameter, obtaining the
%     hough space nhood size. H is the hough transform
%   - fill_gap: see houghlines 'FillGap'
%   - min_length: see houghlines 'MinLength'
% Returns
% - the set of lines returned bu hough    
    
    [H,T,R] = hough(edges, 'Theta', hough_params.theta, ...
        'RhoResolution', hough_params.rho_resolution);
    P  = houghpeaks(H, hough_params.peacks_number, 'NHoodSize', ...
        smallest_odd(size(H) / hough_params.nhood_size_scale), ...
        'Threshold', hough_params.threshold_mult * max(H(:)));
    lines = houghlines(edges, T, R, P, 'FillGap', hough_params.fill_gap, ...
        'MinLength', hough_params.min_length);
    if debug
        f = plot_lines(edges,lines, 'r', 'Hough vertical lines');
        pause;
        close(f);
    end
end
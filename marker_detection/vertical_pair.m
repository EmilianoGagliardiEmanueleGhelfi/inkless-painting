function pair = vertical_pair(lines)
    % given a set of lines found by hough, select the pair of lines that
    % have smaller angle and do not intersect in the image (lines are
    % segments when computed with hough)
    
    candidates = generate_vertical_pairs(lines);
    
    % if there are no candidates return nan
    if isempty(candidates)
        pair = nan;
    else
        % select the pair with the smallest angle
        min = inf;
        for ii = 1:size(candidates, 1)
            l1 = candidates(ii, 1);
            l2 = candidates(ii, 2);
            angle = abs(l1.theta - l2.theta);
            if angle < min
                min = angle;
                pair = candidates(ii, :);
            end
        end
    end
end

function pairs = generate_vertical_pairs(lines)
    % from a set of lines generate all the possible pair, removing the
    % pairs of lines that corresponds to segments intersecting in the image
    % data are returned in a matrix Nx2
    lines_number = size(lines, 2);
    pairs = [];
    for ii = 1:lines_number
        for jj = (ii+1):lines_number
            if ~do_segments_intersect(lines(ii), lines(jj))
                pairs = [pairs; lines(ii), lines(jj)];
            end
        end
    end
end

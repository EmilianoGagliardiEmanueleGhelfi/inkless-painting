function triple = horizontal_triple(lines, vertical_lines)%, K)
    % obtain the lines that are likely to be the horizontal lines of the
    % marker (lines is a list containg structs as returned by hough)
    
    if isempty(lines)
        triple = nan;
    else
        triples = generate_triples(lines);
        if size(triples, 1) == 0
            triple = nan;
            return
        end
        % remove the triples containing segments too near to each other
        triples = filter_triples(vertical_lines, triples);
        if size(triples, 1) == 0
            triple = nan;
        else
            % obtain the triple of lines that is most likely to be 
            % orthogonal to the pair of vertical lines in the real scene,
            % by the IAC constraint IAC = inv(K*K')
            
            % compute the vertical vanishing point
            %lv_h = lines2homogeneous(vertical_lines);
            %vertical_vp = cross(lv_h(1, :), lv_h(2, :));
            min = inf;
            for ii = 1:size(triples, 1)
                score = compute_score_perp(vertical_lines, triples(ii, :));
                if score < min 
                    triple = triples(ii,:);
                    min = score;
                end
            end
        end
    end
end

function triples = generate_triples(lines)
% from a set of lines generate all the possible triples, removing the 
    % triples of lines that corresponds to segments intersecting in the
    % image
    lines_number = size(lines, 2);
    triples = [];
    for ii = 1:lines_number
        for jj = ii+1:lines_number
            for kk = jj+1:lines_number
                if ~do_segments_intersect(lines(ii), lines(jj)) && ...
                   ~do_segments_intersect(lines(ii), lines(kk)) && ...
                   ~do_segments_intersect(lines(jj), lines(kk))
                    triples = [triples; lines(ii), ...
                                        lines(jj), ...
                                        lines(kk)];
                end
            end
        end
    end
end
    

function filtered = filter_triples(vertical_pair, triples)
    % for the triple t we compute the 6 intersecting points with the
    % vertical lines. Then we take the minimum of the distances between
    % points on the same lines, called d(t). 
    % if for a triple t, d(t) < 0.7 * max_{t' in triples} d(t'), then t is
    % discarded d(t) = min_distance_triple(vert, t)
    distances = apply_to_rows(@(h) min_distance_triple(...
        vertical_pair, h), triples);
    threshold = 0.7 * max(distances);
    filtered = triples( distances > threshold, :);
end

function d = min_distance_triple(vert_pair, horiz_triple)
    lv_h = lines2homogeneous(vert_pair);
    lh_h = lines2homogeneous(horiz_triple);
    % first vertical line intersection
    pts_l = zeros(3, 2);
    for ii = 1:3
        pt = cross(lv_h(1, :), lh_h(ii, :));
        pts_l(ii, :) = pt(1:2)/pt(3);
    end
    pts_r = zeros(3, 2);
    for ii = 1:3
        pt = cross(lv_h(2, :), lh_h(ii, :));
        pts_r(ii, :) = pt(1:2)/pt(3);
    end
    d = min([min_distance_points(pts_l), min_distance_points(pts_r)]);
end

function d = min_distance_points(points)
    d = min([   norm(points(1, :) - points(2, :)), ...
                norm(points(1, :) - points(3, :)), ...
                norm(points(2, :) - points(3, :))]);
end

function score = compute_score_K(vertical_vp, horiz_triple, K)
    % the score represents how much vert pair and horiz triple are
    % perpendicular in the real world. This is obtained using the
    % calibration matrix. 
    % if the marker is not inclined enough then the perspective effect is
    % not appreciable, so perpendicularity cna be directly checked in the
    % image
    
    epsilon = 1e-4;
    
    % check wether lines in the triple are parallel
    lh_h = lines2homogeneous(horiz_triple);
    angle12 = get_angle_from_lines(lh_h(1, :)', lh_h(2, :)');
    angle13 = get_angle_from_lines(lh_h(1, :)', lh_h(3, :)');
    angle23 = get_angle_from_lines(lh_h(1, :)', lh_h(2, :)');
    
    parallel12 = abs(angle12) < epsilon;
    parallel13 = abs(angle13) < epsilon;
    parallel23 = abs(angle23) < epsilon;
  
    if parallel12 && parallel13 && parallel23
        horizontal_vp = cross(lh_h(1, :), lh_h(2, :));
    elseif ~parallel12 && ~parallel23 && ~parallel13
        horizontal_vp = point_ls(lh_h);
    % only 1 couple must be non parallel, so use the non parallel one with
    % one of the parallel to compute the vp
    elseif ~parallel12
        horizontal_vp = cross(lh_h(1, :), lh_h(2, :));
    elseif ~parallel23
        horizontal_vp = cross(lh_h(2, :), lh_h(3, :));
    else % 1 and 3 are not parallel
        horizontal_vp = cross(lh_h(1, :), lh_h(3, :));
    end
    
    score = abs(horizontal_vp * ((K*K') \ vertical_vp'));
end


function score = compute_score_perp(vertical_pair, horiz_triple)
    % check wether lines in the triple are parallel
    lh_h = lines2homogeneous(horiz_triple);
    lv_h = lines2homogeneous(vertical_pair);
    score = 0;
    for ii = 1:3
        score = score + abs(get_angle_from_lines(lh_h(ii, :)', lv_h(1, :)') - 90);
        score = score + abs(get_angle_from_lines(lh_h(ii, :)', lv_h(2, :)') - 90);
    end
end





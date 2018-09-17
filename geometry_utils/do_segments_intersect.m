function they_intersect = do_segments_intersect(l1, l2)
    % given a pair of lines check that they do not intersect (as segments
    % returned by houg) in the image
    if isequal(l1.point1, l2.point1) || isequal(l1.point2, l2.point2) || ...
            isequal(l1.point1, l2.point2) || isequal(l1.point2, l2.point1)
        they_intersect = true;
    else
        lines = lines2homogeneous([l1, l2]);
        inters_h = cross(lines(1, :), lines(2, :));
        inters = inters_h(1:2) / inters_h(3);
        is_on_segment1 = is_on_segment(l1, inters);
        is_on_segment2 = is_on_segment(l2, inters);
        they_intersect = is_on_segment1 && is_on_segment2;
    end
end

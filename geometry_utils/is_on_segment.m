function is_on = is_on_segment(line, p)
    epsilon = 1e-6; % desired tolerance
    line_h = lines2homogeneous(line);
    is_on_line = abs(line_h * [p(1); p(2); 1]) <= epsilon;
    A = line.point1;
    B = line.point2;
    AB = (B-A);
    AB_squared = dot(AB,AB);
    Ap = (p-A);
    % Consider the line extending the segment, parameterized as A + t 
    % (B - A). We find projection of point p onto the line. 
    % It falls where t = [(p-A) . (B-A)] / |B-A|^2
    t = dot(Ap,AB)/AB_squared;
    is_on = t >= 0.0 && t <= 1.0 && is_on_line;
end

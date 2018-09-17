function pts = marker_model_to_pts(m)
%MARKER_MODEL_TO_PTS Summary of this function goes here
%   Detailed explanation goes here

    pts = [% left pts
           0, m.high_med_distance + m.med_low_distance;
           0, m.med_low_distance;
           0, 0;
           % right pts
           m.horiz_distance, m.high_med_distance + m.med_low_distance;
           m.horiz_distance, m.med_low_distance;
           m.horiz_distance, 0];
end


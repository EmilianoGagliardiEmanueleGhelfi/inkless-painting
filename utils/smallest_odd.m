function out = smallest_odd(in)
    % from a two elements vector returns a vector containing the nearest
    % odd integers for each of the two entries
    out = floor(in);
    if mod(out(1), 2) == 0
        out(1) = out(1) + 1;
    end
    if mod(out(2), 2) == 0
        out(2) = out(2) + 1;
    end
end


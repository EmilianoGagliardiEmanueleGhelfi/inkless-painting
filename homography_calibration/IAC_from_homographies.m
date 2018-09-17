function IAC = IAC_from_homographies(Hs)
% CALIB_FROM_H Compute IAC from a set of homographies
% Parameters:
% - Hs: cell array of matrices representing homographies from a planar
% object to its image
% Returns:
% - IAC: image of the absolute coninc

    % matrix parametrization
    syms a b c d;
    omega = [a 0 b; 0 1 c; b c d];

    X = []; % should be nxm matrix (n is ls size 2, m is 4)
    Y = []; % should be n matrix of target values

    % add constraints on homography
    for H = Hs
        H = cell2mat(H);
        % scaling factor needed in order to get an homogeneous matrix
        % get columns
        h1 = H(:,1);
        h2 = H(:,2);

        % first constraint: h1' w h2 = 0
        eq1 = h1.' * omega * h2 == 0;
        % second equation h1'wh1 = h2' w h2
        eq2 = h1.' * omega * h1 == h2.' * omega * h2;

        [A,y] = equationsToMatrix([eq1,eq2],[a,b,c,d]);
        A = double(A);
        y = double(y);

        % concatenate matrices
        X = [X;A];
        Y = [Y;y];
    end

    % fit a linear model without intercept
    lm = fitlm(X,Y, 'y ~ x1 + x2 + x3 + x4 - 1');
    % get the coefficients
    W = lm.Coefficients.Estimate;

    % image of absolute conic
    IAC = double([W(1,1) 0 W(2,1); 0 1 W(3,1); W(2,1) W(3,1) W(4,1)]);

end




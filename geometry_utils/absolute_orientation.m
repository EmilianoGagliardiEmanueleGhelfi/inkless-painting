function [R,t] = absolute_orientation(pts1, pts2)
% ABSOLUTE-ORIENTATION: implementation of "Closed form solution of absolute orientation using unit quaternions" from Berthold K. P. Horn
    % Here no scale factor is considered.
    % Parameters:
    % - pts1, pts2: 3xN matrices, where columns are 3D vectors
    % representing the same points in different coordinates system. 
    % pts1(:, ii) needs to represent the same point as pts2(:, ii)
    % Returns:
    % The rototralsation that applied to pts1 minimizes:
    % sum_ii{ norm(R * pts1(:, ii) + t - pts2(:, ii)) }
    
    n = size(pts1, 2);
    
    % centroids
    c1 = mean(pts1, 2);
    c2 = mean(pts2, 2);
    
    % ROTATION
    pts1_ = pts1 - c1;
    pts2_ = pts2 - c2;
    M = pts1_ * pts2_.';
    % compute the matrix N
    diagonal = diag( [M(1, 1) + M(2, 2) + M(3, 3), ...
        M(1, 1) - M(2, 2) - M(3, 3), ...
        -M(1, 1) + M(2, 2) - M(3, 3), ...
        -M(1, 1) - M(2, 2) + M(3, 3)]);
    up_left = ...
        [0, M(2, 3) - M(3, 2), M(3, 1) - M(1, 3), M(1, 2) - M(2, 1);
         0,                 0, M(1, 2) + M(2, 1), M(1, 3) + M(3, 1);
         0,                 0,                 0, M(2, 3) + M(3, 2);
         0,                 0,                 0,                 0];
    N = diagonal + up_left + up_left';
    % eigenvector corresponding to the most positive eigenvalue of N
    try
        [V,D]=eig(N);
        [~,emax]=max(real(diag(D))); 
        emax=emax(1);
        q = V(:,emax); % Gets eigenvector corresponding to maximum eigenvalue
        q = real(q);   % Get rid of imaginary part caused by numerical error
        [~, ii]=max(abs(q)); 
        sgn=sign(q(ii(1)));
        q=q*sgn; % Sign ambiguity
        quat=q(:);
        nrm=norm(quat);
        if ~nrm
         disp 'Quaternion distribution is 0'    
        end

        quat=quat./norm(quat);

        q0=quat(1);
        qx=quat(2); 
        qy=quat(3); 
        qz=quat(4);
        v =quat(2:4);


        Z=[q0 -qz qy;...
           qz q0 -qx;...
          -qy qx  q0 ];

        R=v*v.' + Z^2;

        % TRANSLATION
        t = c2 - R * c1;
    catch
        R = nan;
        t = nan;
    end
end


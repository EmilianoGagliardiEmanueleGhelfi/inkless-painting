function vp = nonlinearfit_vp(l1, l2, img_points1, img_points2, ...
    distances, vpguess, use_parallel_lines)
%NONLINEARFIT_VP Fit the vanishing point using LM imposing 2 lines intersection and crossratio equation for two triples of colinear poins
% Since the vanishing point fitting using the cross ration magic equation
% is a non linear problem we need to use non linear fitting method.
% The image of the vanishing point must belong to the two lines and
% satisfy the Cross Ratio equations for the two triples of points.
% Parameters:
% - l1, l2 lines as row vectors
% - img_points1, img_points2 3x3 row points in homogeneus coordinates
% (colinear)
% - distances: 1x2 vector containing real world distance from
% img_points(1, :) to img_points(2, :) and from img_points(2, :) to
% img_poins(3, :)
% - vpguess: vanishing point guess for starting the non linear lsquare
% problem
% - use_parallel_lines: if set to false lines are not used in the fitting
% of the vp

    high_image1 = img_points1(1,1:2)';
    med_image1 = img_points1(2,1:2)';
    low_image1 = img_points1(3,1:2)';
    
    high_image2 = img_points2(1,1:2)';
    med_image2 = img_points2(2,1:2)';
    low_image2 = img_points2(3,1:2)';
    
    high_low_real = distances(1) + distances(2);
    med_low_real = distances(2);
    
    % cross ratio equations
    cr1 = @(x)  norm(high_image1-low_image1)*norm(med_image1-x)/ ...
         (norm(med_image1-low_image1)*norm(high_image1-x)) - high_low_real/med_low_real;
    cr2 = @(x)  norm(high_image2-low_image2)*norm(med_image2-x)/ ...
         (norm(med_image2-low_image2)*norm(high_image2-x)) - high_low_real/med_low_real;
    
    if use_parallel_lines
        % vp belongs to both lines
        l1eq = @(x) l1*[x(1); x(2); 1];
        l2eq = @(x) l2*[x(1); x(2); 1];
    
        eqs = @(x) [cr1(x); cr2(x); l1eq(x); l2eq(x)];
    else
        eqs = @(x) [cr1(x); cr2(x)];
    end
    options = optimoptions(@lsqnonlin,'Algorithm','levenberg-marquardt', ...
        'FunctionTolerance', 1e-10, 'OptimalityTolerance', 1e-10, ...
        'StepTolerance', 1e-10, 'Display', 'off', 'UseParallel', true);
    try
        vp = lsqnonlin(eqs,vpguess, [], [], options);
        vp = [vp, 1];
    catch e
        disp("WARNING, nan objective function");
        disp(e.message);
        vp = nan;
    end
         
end


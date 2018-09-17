
clear
close all
clc

% load parameters
%% if you want to run the reconstruction algorithm on the "ciao" video
ciao_parameters

%% do this if you want instead to run the reconstruction algorithm on the "triangle" video
%triangle_parameters

%% load or compute calibration data
if ~exist(CALIB_OUTPUT_PATH, 'file')
    disp('No stored calibration, running calibration script');
    calibration_script;
else
    disp('Calibration data found, using them');
end
calib_data = load(CALIB_OUTPUT_PATH);
K = calib_data.K;
R = calib_data.R;
t = calib_data.t;

%% Run reconstruction over all frames
reader = vision.VideoFileReader(VIDEO_PATH);
highs1 = [];
meds1 = [];
lows1 = [];
poses1 = [];
highs2 = [];
meds2 = [];
lows2 = [];

highsh1 = [];
medsh1 = [];
lowsh1 = [];
posesh1 = [];
highsh2 = [];
medsh2 = [];
lowsh2 = [];

time=0;
not_found = 0;
found = 0;
start_video_from = 1;
samples = [];

while ~isDone(reader)
    % read the frame
    frame = reader.step();
    %frame = imrotate(frame, -90);
    time = time + 1;
    if time < start_video_from
        continue
    end
    
    % detection
    [lines, corners, H] = detect_marker(frame, RGB_FILTER_FUNCTION, ...
        HOUGH_PARAMS_VERTICAL_LINES, HOUGH_PARAMS_HORIZONTAL_LINES, ...
        DILATION_DISK_SIZE, HARRIS_ROI_SIZE, HARRIS_QUALITY, ...
        PENCIL_MODEL.marker_model, GEO_2D_CHECK_THRESHOLD, DETECTION_DEBUG);

    % check if everything has been detected
    if ~isstruct(lines) || any(any(isnan(corners)))
        disp(['Detection failed in frame ' int2str(time)]);
        not_found = not_found + 1;
        
        empty_vec = nan(1,3);
        sample = struct('frame', frame, 'time', time, 'high1', ...
            empty_vec, 'low1', empty_vec, 'med1', empty_vec, 'high2', ...
            empty_vec, 'med2', empty_vec, 'low2', empty_vec, 'pos', ...
            empty_vec);
        samples = [samples, sample];
        continue
    end
    
    % HOMOGRAPHY RECONSTRUCTION
    [high1h, med1h, low1h, high2h, med2h, low2h, posh] = ...
        homog_reconstruct_pencil(H, K, PENCIL_MODEL);
    
    highsh1 = [highsh1, high1h'];
    medsh1 = [medsh1, med1h'];
    lowsh1 = [lowsh1, low1h'];
    highsh2 = [highsh2, high2h'];
    medsh2 = [medsh2, med2h'];
    lowsh2 = [lowsh2, low2h'];
    posesh1 = [posesh1, posh'];
    
    % CROSSRATIO RECONSTRUCTION
    [high1, med1, low1, high2, med2, low2, pos] = ...
        crossratio_reconstruct_pencil(K, lines, corners, PENCIL_MODEL, ...
        GEO_3D_CHECK_THRESHOLD , USE_PARALLEL_LINES, RECONSTRUCTION_DEBUG);

    sample = struct('frame', frame, 'time', time, 'high1', high2, 'low1', low2, ...
                    'med1', med1, 'high2', high2, 'med2', med2, 'low2', low2, ...
                    'pos', pos);
    samples = [samples, sample];
    
    if prod(isnan(high1))
        disp(['Reconstruction failed in frame ' int2str(time)]);
        not_found = not_found + 1;
        continue
    end
    
    disp(['Succesful reconstruction of frame ', int2str(time)]);
    
    highs1 = [highs1, high1'];
    meds1 = [meds1, med1'];
    lows1 = [lows1, low1'];
    highs2 = [highs2, high2'];
    meds2 = [meds2, med2'];
    lows2 = [lows2, low2'];
    poses1 = [poses1, pos'];
    found = found + 1;
end

disp("Finished");
disp(['Successful reconstruction in ', num2str(found), '/', ...
    num2str(time), ' frames']);

release(reader);


%% Display the reconstruction with crossratio
highs1_w = R*highs1 + t;
meds1_w = R*meds1 +t;
lows1_w = R*lows1 +t;
highs2_w = R*highs2 + t;
meds2_w = R*meds2 + t;
lows2_w = R*lows2 + t;
poses1_w = R*poses1 + t;
figure();
hold on;
title('Reconstruction of pencil tip and marker points before smoothing');
scatter3(poses1_w(1,:), poses1_w(2,:), poses1_w(3,:),5, 'black', 'filled');
scatter3(meds1_w(1,:), meds1_w(2,:), meds1_w(3,:), 5, 'R', 'filled')
scatter3(lows1_w(1,:), lows1_w(2,:), lows1_w(3,:), 5, 'G', 'filled')
scatter3(highs1_w(1,:), highs1_w(2,:), highs1_w(3,:), 5 ,'B', 'filled')
scatter3(meds2_w(1,:), meds2_w(2,:), meds2_w(3,:), 5, 'MarkerFaceColor', [1, 0.47, 0])
scatter3(lows2_w(1,:), lows2_w(2,:), lows2_w(3,:), 5, 'MarkerFaceColor', [0.6, 0.9, 0])
scatter3(highs2_w(1,:), highs2_w(2,:), highs2_w(3,:), 5,'MarkerFaceColor', [0.3, 0.5, 0.9])
plotCamera('Location', t,'Orientation', R', 'Size',1);
% rectangle
sheet = [0, 0 0; 18.5, 0, 0; 0, 26.6, 0; 18.5, 26.6, 0];
pcshow(sheet, 'MarkerSize', 200);
xlabel('X');
ylabel('Y');
zlabel('Z');
axis equal;

%% Smoothing and outliers rejection
% extract a sliding window, discard if |x-mean| > k*mean_error
offset = 1;
window_size = 10;
poses_fitted = [];
k = 1;
for ii=1:offset:time-window_size
    % extract samples
    poses = reshape([samples(ii:ii+window_size-1).pos]', 3, window_size)';
    poses = poses(~any(isnan(poses),2),:);
    if ~isempty(poses)
        mean_pos = mean(poses, 1);
        errors = vecnorm(poses - mean_pos,2,2);
        mean_error = mean(errors);
        
        % find poses having errors < mean_errors
        poses = poses(errors <= k*mean_error, :);
        new_mean = mean(poses,1);
        poses_fitted = [poses_fitted, new_mean'];
    end
end

poses_fitted_w = R * poses_fitted + t;

% plot in 2D
threshold = 1.5;
drawing = poses_fitted_w(1:2, poses_fitted_w(3, :) < threshold);
figure();
scatter(drawing(1, :), drawing(2, :), 'k');
title('Drawing');
axis equal;

% plot in 3D
figure();
hold on;
title('Pencil tip position after smoothing and outliers rejection');
scatter3(poses_fitted_w(1,:), poses_fitted_w(2,:), poses_fitted_w(3,:),5, 'black', 'filled');
plotCamera('Location', t,'Orientation', R', 'Size',1);
% rectangle
sheet = [0, 0 0; 18.5, 0, 0; 0, 26.6, 0; 18.5, 26.6, 0];
pcshow(sheet, 'MarkerSize', 200);
xlabel('X');
ylabel('Y');
zlabel('Z');
axis equal;


%% Display the reconstruction with homography (generally it gives bad results
highsh1_w = R*highsh1 + t;
medsh1_w = R*medsh1 + t ;
lowsh1_w = R*lowsh1 + t;
highsh2_w = R*highsh2 + t;
medsh2_w = R*medsh2 + t;
lowsh2_w = R*lowsh2 + t;
posesh1_w = R*posesh1 + t;
figure();
hold on;
title('Reconstruction of pencil tip and marker points before smoothing');
scatter3(posesh1_w(1,:), posesh1_w(2,:), posesh1_w(3,:),5, 'black', 'filled');
scatter3(medsh1_w(1,:), medsh1_w(2,:), medsh1_w(3,:), 5, 'R', 'filled')
scatter3(lowsh1_w(1,:), lowsh1_w(2,:), lowsh1_w(3,:), 5, 'G', 'filled')
scatter3(highsh1_w(1,:), highsh1_w(2,:), highsh1_w(3,:), 5 ,'B', 'filled')
scatter3(medsh2_w(1,:), medsh2_w(2,:), medsh2_w(3,:), 5, 'MarkerFaceColor', [1, 0.47, 0])
scatter3(lowsh2_w(1,:), lowsh2_w(2,:), lowsh2_w(3,:), 5, 'MarkerFaceColor', [0.6, 0.9, 0])
scatter3(highsh2_w(1,:), highsh2_w(2,:), highsh2_w(3,:), 5,'MarkerFaceColor', [0.3, 0.5, 0.9])
plotCamera('Location', t,'Orientation', R', 'Size',1);
% rectangle
sheet = [0, 0 0; 18.5, 0, 0; 0, 26.6, 0; 18.5, 26.6, 0];
pcshow(sheet, 'MarkerSize', 200);
xlabel('X');
ylabel('Y');
zlabel('Z');
axis equal

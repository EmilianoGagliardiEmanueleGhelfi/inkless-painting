global VIDEO_PATH;
global CALIBRATION_DEBUG;
global LOCALIZATION_DEBUG;
global TEMPLATE_IMAGE_FILENAME;
global LOCALIZATION_IMAGE_FILENAME;
global CALIBRATION_IMAGES_DIRECTORY;
global CALIB_OUTPUT_PATH;
global HOMOGRAPHY_REJECTION_PARAMS;
global REAL_TEMPLATE_SIZE;
global MATCHING_PARAMS;
global GEO_2D_CHECK_THRESHOLD;
global HARRIS_ROI_SIZE;
global HARRIS_QUALITY;
global RGB_FILTER_FUNCTION;
global DILATION_DISK_SIZE;
global HOUGH_PARAMS_VERTICAL_LINES;
global HOUGH_PARAMS_HORIZONTAL_LINES;
global GEO_3D_CHECK_THRESHOLD;
global USE_PARALLEL_LINES;
global RECONSTRUCTION_DEBUG;
global PENCIL_MODEL;
global DETECTION_DEBUG;

% video
VIDEO_PATH = 'data/ciao/ciao.mov';

% calibration parameters
CALIBRATION_DEBUG = false;
LOCALIZATION_DEBUG = false;
CALIB_OUTPUT_PATH = 'data/ciao/calibration_data/ciao_calibration.mat';
TEMPLATE_IMAGE_FILENAME = 'stones.jpg';
LOCALIZATION_IMAGE_FILENAME = 'data/ciao/calibration_images/localization1.png';
CALIBRATION_IMAGES_DIRECTORY = 'data/ciao/calibration_images/*.png';
REAL_TEMPLATE_SIZE = [20.02, 28.6]; % cm
HOMOGRAPHY_REJECTION_PARAMS = struct('min_inliers', 50, ...
                                     'confidence', 99, ...
                                     'max_distance', 8, ... % pixels
                                     'iterations', 1000);
MATCHING_PARAMS = struct('desc_distance_threshold', 1, ...
                         'ratio_threshold', 0.8);

% detection parameters   
DETECTION_DEBUG = struct('RGB_debug', false, ...
                         'dilation_erosion_debug', false, ...
                         'vertical_lines_debug', false, ...
                         'horizontal_lines_debug', false, ...
                         'resulting_lines_debug', false, ...
                         'extracted_corners_debug', false, ...
                         'resulting_corners_debug', false);           
HOUGH_PARAMS_VERTICAL_LINES = struct('theta', -80:1:80, ...
                                     'rho_resolution', 2, ...
                                     'peacks_number', 20, ...
                                     'nhood_size_scale', 200, ...
                                     'fill_gap',100, ...
                                     'min_length', 200, ...
                                     'threshold_mult', 0.5);
HOUGH_PARAMS_HORIZONTAL_LINES = struct('theta_rotated_image', 0:1:80, ...
                                       'rho_resolution', 2, ...
                                       'peacks_number', 10, ...
                                       'nhood_size_scale', 50, ...
                                       'fill_gap', 20, ...
                                       'min_length', 30, ...
                                       'threshold_mult', 0);
RGB_FILTER_FUNCTION = @(x) createMask_ciaocorsivo1(x) | ...
    createMask_ciaocorsivo2(x) | createMask_ciaocorsivo3(x);                                   
DILATION_DISK_SIZE = 2;
HARRIS_QUALITY = 0.05;
HARRIS_ROI_SIZE = 15;                                   
GEO_2D_CHECK_THRESHOLD = 2^2; % pixels


% reconstruction parameters
GEO_3D_CHECK_THRESHOLD = 0.5^2;
USE_PARALLEL_LINES = true;
RECONSTRUCTION_DEBUG = false;


% model
marker_model = struct('high_med_distance', 3.45, ... 
                      'med_low_distance', 3.45, ... 
                      'horiz_distance', 0.45);

PENCIL_MODEL = struct('marker_model', marker_model, ...
                      'marker_low_brush_distance', 7.6, ...
                      'depth_distance', 0.);

global CALIBRATION_DEBUG;
global LOCALIZATION_DEBUG;
global TEMPLATE_IMAGE_FILENAME;
global LOCALIZATION_IMAGE_FILENAME;
global CALIBRATION_IMAGES_DIRECTORY;
global HOMOGRAPHY_REJECTION_PARAMS;
global REAL_TEMPLATE_SIZE;
global MATCHING_PARAMS;
CALIBRATION_DEBUG = true;


LOCALIZATION_DEBUG = true;


TEMPLATE_IMAGE_FILENAME = 'stones.jpg';


LOCALIZATION_IMAGE_FILENAME = 'localization1.png';


CALIBRATION_IMAGES_DIRECTORY = 'data/dataset_blue/*.png';


REAL_TEMPLATE_SIZE = [20.02, 28.6]; % cm


HOMOGRAPHY_REJECTION_PARAMS = struct('min_inliers', 50, ...
                                     'confidence', 99, ...
                                     'max_distance', 8, ... % pixels
                                     'iterations', 1000);

MATCHING_PARAMS = struct('desc_distance_threshold', 1, ...
                         'ratio_threshold', 0.8);
                                 
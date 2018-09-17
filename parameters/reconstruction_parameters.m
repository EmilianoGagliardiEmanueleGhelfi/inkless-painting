
global GEO_3D_CHECK_THRESHOLD;
GEO_3D_CHECK_THRESHOLD = 0.5^2; % unity measure consistent with pencil_model.m

% if set to true the vanishing point along the direction of the long lines
% on the marker is fitted imposing also the intersection between the long
% lines of the marker
global USE_PARALLEL_LINES;
USE_PARALLEL_LINES = true;

global RECONSTRUCTION_DEBUG;
RECONSTRUCTION_DEBUG = false;
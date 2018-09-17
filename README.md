# How ro run
Run the script video_processing/video_reconstruction.m
If you want to visualize the input video and reconstruction output in parallel, run video_processing/play_video.m (you need to run video_reconstruction.m before)

The video_reconstruction.m script loads parameters calling either ciao_parameters.m or triangle_parameters.m scripts. 
The two scripts correspond to two different dataset we generated, and define the parameters needed by the algorithm (pencil and marker model, RGB filter function, and others). 
Comment one of the two lines to see the results for the other dataset.
A dataset folder has the form:  

dataset_name/  
  |__ video  
  |__ calibration_data/  
  |__ calibration_images/  
  |__ color_filters/  

Where video represents the input of the algorithm, calibration_data contains a .mat file with extrinsic and intrinsic parameters, calibration_images contains calibration images (intrinsic and extrinsic), and color_filters contains matlab functions representing color filters to be aplied to the frames of the video. 

The video_reconstruction.m scripts also calls the calibration script if it does not find stored calibration parameters. If you want to run calibration, for instance on the "ciao" dataset, go to data/ciao/calibration_data and delete the file ciao_calibration.mat; the same holds for the "triangle" dataset. 

To see intermediate results, like extracted lines, extracted keypoints, and others, open for instance the file ciao_parameters.m and set the corresponding debug variable to "true". Running the video_processing.m script, the intermediate results you asked will be shown and the system will pause. Press ENTER to go on with the successive frame. 
If you want the algorithm to start from frame i, go to line 45 and change the value of the variable "start_video_from" in i.


Please refer to the documentation for a detailed explanation of the algorithm.

# Demo

![Alt Text](https://github.com/EmilianoGagliardiEmanueleGhelfi/inkless-painting/blob/master/gif/demo.gif)

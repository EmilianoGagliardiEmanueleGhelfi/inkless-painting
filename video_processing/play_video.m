% you need to run the video reconstruction script before

videoReader = vision.VideoFileReader(VIDEO_PATH);
videoPlayer = vision.VideoPlayer;

f = figure();
gcf = f;
axis equal
plotCamera('Location', t,'Orientation', R', 'Size',1);
hold on
% rectangle
sheet = [0, 0 0; 18.5, 0, 0; 0, 26.6, 0; 18.5, 26.6, 0];
pcshow(sheet, 'MarkerSize', 200);
xlabel('X')
ylabel('Y')
zlabel('Z')
hold on
last = [];
last_label = logical([]);
color_label = [];
max_last = 20;
% movie
for i=1:size(poses_fitted_w,2)
  if size(last,2) > max_last  
      last = last(:,2:end);
      last_label = last_label(2:end);     
      if any(last_label)
        delete(findobj('Color','r')); 
        % plot others
        plot3(last(1,last_label),last(2,last_label),last(3,last_label),'ro');
      end
  end
  frame = videoReader.step();
  videoPlayer.step(frame);
  c = 'bo';
  label = false;
  if poses_fitted_w(3,i) > 1.5
     c = 'ro'; 
     label = true;
  end
  plot3(poses_fitted_w(1,i),poses_fitted_w(2,i),poses_fitted_w(3,i),c);
  last = [last, poses_fitted_w(:,i)];
  last_label = [last_label, label];
  axis equal;
  hold on;
end
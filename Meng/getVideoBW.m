function [videoData, videoClasses] = getVideoBW(filename, resizeScale)
% function: Short description
%
% Extended description
videoName = [filename '.mp4'];
matName = [filename '_gt.mat'];

% Load the .mat file to get annotations info
load(matName);

% Counter to record the current frame number
currentFrame = 0;

% Load video using VideoFileReader because there is a handy step() function
videoReader = vision.VideoFileReader(videoName);

frame = step(videoReader);
% frame = rgb2gray(step(videoReader));
% frame = imresize(frame, resizeScale);
figure; imshow(frame); title('Video Frame');

%% Extract HOG feature
% hog = extractHOGFeatures(frame, 'cellsize', [128 128], 'blocksize', [4 4]);
% hog = extractHOGFeatures(frame, 'cellsize', [64 64], 'blocksize', [4 4]);
% Update current frame counter
bwRatio = getBWratio(frame);
currentFrame = currentFrame + 1;

% Create and initialize matrix to store HOG features for each frame + label
% based on the size of hog feature and the total number of frames in the video
% videoData = zeros(num_frames, size(hog, 2) + 1); % + 1 for class label
% videoData(1, 1:size(hog, 2)) = hog;
videoData = zeros(num_frames, size(bwRatio, 2) + 1); % + 1 for class label
videoData(1, 1:size(bwRatio, 2)) = bwRatio;

% Get the HOG features of the frames for the rest of the video
% TODO(MZ): Use a for-loop might speed it up a bit
% while ~isDone(videoReader)
for i = 2:num_frames
    frame = step(videoReader);
    bwRatio = getBWratio(frame);
    % frame = rgb2gray(step(videoReader)); % read the next video frame
    % frame = imresize(frame, 0.25);
    % hog = extractHOGFeatures(frame, 'cellsize', [128 128], 'blocksize', [4 4]);
    % hog = extractHOGFeatures(frame, 'cellsize', [64 64], 'blocksize', [4 4]);
    currentFrame = currentFrame + 1;
    % videoData(currentFrame, 1:size(hog, 2)) = hog;
    videoData(currentFrame, 1:size(bwRatio, 2)) = bwRatio;
end

release(videoReader);

%% Complete building data matrix by looping through the annotations matrix and
%  set the number of cars for certain frame number
for j = 1:size(annotations, 2)
    idx = annotations{j}.frame;
    % Because all data in the annotations matrix are class "car", so + 1 for
    % every frame appeared in the matrix
    videoData(idx, end) = videoData(idx, end) + 1;
end

videoClasses = videoData(:, end);
videoData = videoData(:, 1:end-1);

%% Save data to a file
outFileName = [filename '_bwdata.mat'];
save(outFileName, 'videoData', 'videoClasses');

end  % function

clear
clc

noImages = 3;

for i = 1 : noImages
    files(i) = fullfile("Cal/chessboard" + (i-1) + ".png");
end
img = imread(files(1));

% Detect the checkerboard corners in the images.
[imagePoints, boardSize] = detectCheckerboardPoints(files);

% Generate the world coordinates of the checkerboard corners in the
% pattern-centric coordinate system, with the upper-left corner at (0,0).
squareSize = 25; % in millimeters
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Calibrate the camera.
imageSize = [size(img, 1), size(img, 2)];
cameraParams = estimateCameraParameters(imagePoints, worldPoints, 'ImageSize', imageSize);


imOrig = imread("Rims/0.png");
[im, newOrigin] = undistortImage(imOrig, cameraParams, 'OutputView', 'full');

% Detect the checkerboard.
% [imagePoints, boardSize] = detectCheckerboardPoints(im);

% Adjust the imagePoints so that they are expressed in the coordinate system
% used in the original image, before it was undistorted.  This adjustment
% makes it compatible with the cameraParameters object computed for the original image.
% imagePoints = imagePoints + newOrigin; % adds newOrigin to every row of imagePoints

% Compute rotation and translation of the camera.
% [R, t] = extrinsics(imagePoints, worldPoints, cameraParams);
iP = imagePoints(:,:,1);
[R, t] = extrinsics(iP, worldPoints, cameraParams);

[rXY, rR] = imfindcircles(im, [250, 450], 'ObjectPolarity', 'bright', 'Sensitivity', 0.96, 'Method', 'twostage');

imagePoints1 = [rXY(1)-rR,rXY(2);rXY(1)+rR,rXY(2)];
worldPoints1 = pointsToWorld(cameraParams, R, t, imagePoints1);
d = worldPoints1(2, :) - worldPoints1(1, :);
diameterInMillimeters = hypot(d(1), d(2));
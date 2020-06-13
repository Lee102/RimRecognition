function [cameraParams, rotation, translation, tim] = calibrateCamera(calibrationSetPath, squareSize, varargin)
% CALIBRATECAMERA  Builds a camera calibration model.
%   [cameraParams, rotation, translation] =
%   CALIBRATECAMERA(calibrationSetPath, squareSize) - builds a camera
%   calibration model with images saved in calibrationSetPath which squares
%   size equals squareSize in tim seconds.
    
    t = tic;
    
    checkPositiveNumParams = @(x) isnumeric(x) && x > 0;
    
    parser = inputParser();
    addRequired(parser, 'calibrationSetPath', @isstring);
    addRequired(parser, 'squareSize', checkPositiveNumParams);
    parse(parser, calibrationSetPath, squareSize);
    
    files = imageDatastore(calibrationSetPath);
    
    [imagePoints, boardSize] = detectCheckerboardPoints(files.Files);
    worldPoints = generateCheckerboardPoints(boardSize, squareSize);
    imageSize = size(readimage(files, 1));
    imageSize(3) = [];
    cameraParams = estimateCameraParameters(imagePoints, worldPoints, 'ImageSize', imageSize);
    [rotation, translation] = extrinsics(imagePoints(:,:,1), worldPoints, cameraParams);
    
    tim = toc(t);
end
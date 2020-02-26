function [cameraParams, rotation, translation] = calibrateCam(calibrationSetPath, squareSize)
% output:
    % cameraParams - camera inside parameters
    % rotation - camera rotation
    % translation - camera translation
% input:
    % calibrationSetPath - calibrate chessboards path
    % squareSize - size of single square side
    files = imageDatastore(calibrationSetPath);
    
    [imagePoints, boardSize] = detectCheckerboardPoints(files.Files);
    worldPoints = generateCheckerboardPoints(boardSize, squareSize);
    imageSize = size(readimage(files, 1));
    imageSize(3) = [];
    cameraParams = estimateCameraParameters(imagePoints, worldPoints, 'ImageSize', imageSize);
    [rotation, translation] = extrinsics(imagePoints(:,:,1), worldPoints, cameraParams);
end
function worldDistance = calculateWorldDistance(cameraParams, rotation, translation, p1, p2)
% CALCULATEWORLDDISTANCE  Calculates the actual distance between 2 points.
%   worldDistance = CALCULATEWORLDDISTANCE(cameraParams, rotation,
%   translation, p1, p2) - Converts 2 points (p1, p2) into the distance between
%   them using the camera model (cameraParams, rotation, translation).
    
    checkCameraParams = @(x) all(class(x) == 'cameraParameters');
    checkRotation = @(x) ismatrix(x) && all(size(x) == [3 3]);
    checkTranslation = @(x) ismatrix(x) && all(size(x) == [1 3]);
    checkPoint = @(x) ismatrix(x) && isnumeric(x) && length(x) == 2;
    
    parser = inputParser();
    addRequired(parser, 'cameraParams', checkCameraParams);
    addRequired(parser, 'rotation', checkRotation);
    addRequired(parser, 'translation', checkTranslation);
    addRequired(parser, 'p1', checkPoint);
    addRequired(parser, 'p2', checkPoint);
    parse(parser, cameraParams, rotation, translation, p1, p2);
    
    worldPoints = pointsToWorld(cameraParams, rotation, translation, [p1; p2]);
    d = worldPoints(2, :) - worldPoints(1, :);
    worldDistance = hypot(d(1), d(2));
end
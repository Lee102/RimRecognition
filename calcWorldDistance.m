function worldDistance = calcWorldDistance(cameraParams, rotation, translation, p1, p2)
% output:
    % worldDistance - calculated world distance between p1 and p2
% input:
    % cameraParams - camera inside parameters
    % rotation - camera rotation
    % translation - camera translation
    % p1 - 1st point xy
    % p2 - 2nd point xy
    worldPoints = pointsToWorld(cameraParams, rotation, translation, [p1; p2]);
    d = worldPoints(2, :) - worldPoints(1, :);
    worldDistance = hypot(d(1), d(2));
end
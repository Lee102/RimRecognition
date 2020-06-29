function features = getHOGFeatures(img, varargin)
% GETHOGFEATURES  Extracts HOG features.
%   features = GETHOGFEATURES(img) - extracts HOG features from an img image.
% 
%   [___] = GETHOGFEATURES(___, Name, Value, ...) - allows to override
%   default parameters such as:
%     'cellSize' - extractHOGFeatures cellSize,
%     'numBins' - extractHOGFeatures numBins,
%     'rimRadiusBounds' - bounds for rim imfindcircles,
%     'rimObjectPolarity' - ObjectPolarity for rim imfindcircles,
%     'rimSensitivity' - Sensitivity for rim imfindcircles,
%     'rimMethod' - Method for rim imfindcircles,
%     'rimXY' - precalculated rim mid point coordinates,
%     'rimRadius' - precalculated rim radius.
    
    checkImg = @(x) ismatrix(x) && ismember(class(x), {'uint8', 'uint16', 'double', 'logical', 'single', 'int16'});
    checkMatrixParams = @(x) ismatrix(x) && length(x) == 2;
    checkObjectPolarity = @(x) any(validatestring(x, {'bright', 'dark'}));
    checkSensitivity = @(x) isfloat(x) && x >= 0 && x <= 1;
    checkMethod = @(x) any(validatestring(x, {'phasecode', 'twostage'}));
    checkRimRadius = @(x) isnumeric(x) && x > 0;
    checkSignedOrientation = @(x) x == 1 || x == 0;
    
    parser = inputParser();
    parser.KeepUnmatched = true;
    addRequired(parser, 'img', checkImg);
    addParameter(parser, 'cellSize', getDefaultValue('hogCellSize'), checkMatrixParams);
    addParameter(parser, 'numBins', getDefaultValue('hogNumBins'), @isnumeric);
    addParameter(parser, 'rimRadiusBounds', getDefaultValue('rimRadiusBounds'), checkMatrixParams);
    addParameter(parser, 'rimObjectPolarity', getDefaultValue('rimObjectPolarity'), checkObjectPolarity);
    addParameter(parser, 'rimSensitivity', getDefaultValue('rimSensitivity'), checkSensitivity);
    addParameter(parser, 'rimMethod', getDefaultValue('rimMethod'), checkMethod);
    addParameter(parser, 'rimXY', [], checkMatrixParams);
    addParameter(parser, 'rimRadius', -1, checkRimRadius);
    addParameter(parser, 'blockSize', [2 2], checkMatrixParams);
    addParameter(parser, 'useSignedOrientation', false, checkSignedOrientation);
    parse(parser, img, varargin{:});
    cellSize = parser.Results.cellSize;
    numBins = parser.Results.numBins;
    rimRadiusBounds = parser.Results.rimRadiusBounds;
    rimObjectPolarity = parser.Results.rimObjectPolarity;
    rimSensitivity = parser.Results.rimSensitivity;
    rimMethod = parser.Results.rimMethod;
    rimXY = parser.Results.rimXY;
    rimRadius = parser.Results.rimRadius;
    blockSize = parser.Results.blockSize;
    useSignedOrientation = parser.Results.useSignedOrientation;
    
    if ~isempty(rimXY) && rimRadius > 0
        xy = rimXY;
        r = rimRadius;
    else
        [xy, r] = imfindcircles(img, rimRadiusBounds, 'ObjectPolarity', rimObjectPolarity, 'Sensitivity', rimSensitivity, 'Method', rimMethod);
    end
    
    diff = size(img) / 2 - xy;
    img = imtranslate(img, diff);
    xy = size(img) / 2;
    
    figure('visible','off');
    roi = drawcircle('Center', xy, 'Radius', r);
    mask = createMask(roi, img);
    img(mask == 0) = 0;
    
    features = extractHOGFeatures(img, 'CellSize', cellSize, 'NumBins', numBins, 'BlockSize', blockSize, 'UseSignedOrientation', useSignedOrientation);
end
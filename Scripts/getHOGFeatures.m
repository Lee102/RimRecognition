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
%     'rimMethod' - Method for rim imfindcircles.
    
    checkImg = @(x) ismatrix(x) && ismember(class(x), {'uint8', 'uint16', 'double', 'logical', 'single', 'int16'});
    checkMatrixParams = @(x) ismatrix(x) && length(x) == 2;
    checkObjectPolarity = @(x) any(validatestring(x, {'bright', 'dark'}));
    checkSensitivity = @(x) isfloat(x) && x >= 0 && x <= 1;
    checkMethod = @(x) any(validatestring(x, {'phasecode', 'twostage'}));
    
    parser = inputParser();
    parser.KeepUnmatched = true;
    addRequired(parser, 'img', checkImg);
    addParameter(parser, 'cellSize', getDefaultValue('hogCellSize'), checkMatrixParams);
    addParameter(parser, 'numBins', getDefaultValue('hogNumBins'), @isnumeric);
    addParameter(parser, 'rimRadiusBounds', getDefaultValue('rimRadiusBounds'), checkMatrixParams);
    addParameter(parser, 'rimObjectPolarity', getDefaultValue('rimObjectPolarity'), checkObjectPolarity);
    addParameter(parser, 'rimSensitivity', getDefaultValue('rimSensitivity'), checkSensitivity);
    addParameter(parser, 'rimMethod', getDefaultValue('rimMethod'), checkMethod);
    parse(parser, img, varargin{:});
    cellSize = parser.Results.cellSize;
    numBins = parser.Results.numBins;
    rimRadiusBounds = parser.Results.rimRadiusBounds;
    rimObjectPolarity = parser.Results.rimObjectPolarity;
    rimSensitivity = parser.Results.rimSensitivity;
    rimMethod = parser.Results.rimMethod;
    
    [xy, r] = imfindcircles(img, rimRadiusBounds, 'ObjectPolarity', rimObjectPolarity, 'Sensitivity', rimSensitivity, 'Method', rimMethod);
    figure('visible','off');
    roi = drawcircle('Center', xy, 'Radius', r);
    mask = createMask(roi, img);
    img = regionfill(img, ~mask);
    
    features = extractHOGFeatures(img, 'CellSize', cellSize, 'NumBins', numBins);
end
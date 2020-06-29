function [label, tim] = recognizeRimByHOG(classifier, img, varargin)
% RECOGNIZERIMBYHOG  Recognizes rim.
%   [label, tim] = RECOGNIZERIMBYHOG(classifier, img) - uses the hog 
%   classifier (classifier) to detect the rim model (label) from the photo
%   (img) in (tim) seconds.
% 
%   [___] = RECOGNIZERIMBYHOG(___, Name, Value, ...) - allows to override
%   default parameters such as:
%     'cellSize' - extractHOGFeatures cellSize,
%     'numBins' - extractHOGFeatures numBins,
%     'rimXY' - precalculated rim mid point coordinates,
%     'rimRadius' - precalculated rim radius.
    
    t = tic;
    
    checkClassifier = @(x) all(class(classifier) == 'ClassificationECOC');
    checkImg = @(x) ismatrix(x) && ismember(class(x), {'uint8', 'uint16', 'double', 'logical', 'single', 'int16'});
    checkMatrixParams = @(x) ismatrix(x) && length(x) == 2;
    checkRimRadius = @(x) isnumeric(x) && x > 0;
    
    parser = inputParser();
    parser.KeepUnmatched = true;
    addRequired(parser, 'classifier', checkClassifier);
    addRequired(parser, 'img', checkImg);
    addParameter(parser, 'cellSize', getDefaultValue('hogCellSize'), checkMatrixParams);
    addParameter(parser, 'numBins', getDefaultValue('hogNumBins'), @isnumeric);
    addParameter(parser, 'rimXY', [], checkMatrixParams);
    addParameter(parser, 'rimRadius', -1, checkRimRadius);
    parse(parser, classifier, img, varargin{:});
    cellSize = parser.Results.cellSize;
    numBins = parser.Results.numBins;
    rimXY = parser.Results.rimXY;
    rimRadius = parser.Results.rimRadius;
    
    features = getHOGFeatures(img, varargin{:});
    
    label = cellstr(predict(classifier, features));
    tim = toc(t);
end
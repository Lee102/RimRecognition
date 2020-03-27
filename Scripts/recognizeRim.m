function label = recognizeRim(classifier, img, varargin)
% RECOGNIZERIM  Recognizes rim.
%   label = RECOGNIZERIM(classifier, img) - using the hog classifier
%   (classifier) to recognize the rim label from the image (img).
% 
%   [___] = RECOGNIZERIM(___, Name, Value, ...) - allows to override
%   default parameters such as:
%     'cellSize' - extractHOGFeatures cellSize,
%     'numBins' - extractHOGFeatures numBins.
    
    checkClassifier = @(x) all(class(classifier) == 'ClassificationECOC');
    checkImg = @(x) ismatrix(x) && ismember(class(x), {'uint8', 'uint16', 'double', 'logical', 'single', 'int16'});
    checkMatrixParams = @(x) ismatrix(x) && length(x) == 2;
    
    parser = inputParser();
    parser.KeepUnmatched = true;
    addRequired(parser, 'classifier', checkClassifier);
    addRequired(parser, 'img', checkImg);
    addParameter(parser, 'cellSize', getDefaultValue('hogCellSize'), checkMatrixParams);
    addParameter(parser, 'numBins', getDefaultValue('hogNumBins'), @isnumeric);
    parse(parser, classifier, img, varargin{:});
    cellSize = parser.Results.cellSize;
    numBins = parser.Results.numBins;
    
    features = extractHOGFeatures(img, 'CellSize', cellSize, 'NumBins', numBins);
    
    label = cellstr(predict(classifier, features));
end
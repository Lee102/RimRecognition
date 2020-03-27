function classifier = buildHogClassifier(trainSetPath, varargin)
% BUILDHOGCLASSIFIER  Builds a hog classifier.
%   classifier = BUILDHOGCLASSIFIER(trainSetPath) - trains hog classifier
%   with a set of pictures saved in the trainSetPath path.
%
%   [___] = BUILDHOGCLASSIFIER(___, Name, Value, ...) - allows to override
%   default parameters such as:
%     'cellSize' - extractHOGFeatures cellSize,
%     'numBins' - extractHOGFeatures numBins,
%     'rimRadiusBounds' - bounds for rim imfindcircles,
%     'rimObjectPolarity' - ObjectPolarity for rim imfindcircles,
%     'rimSensitivity' - Sensitivity for rim imfindcircles,
%     'rimMethod' - Method for rim imfindcircles.
    
    parser = inputParser();
    parser.KeepUnmatched = true;
    addRequired(parser, 'trainSetPath', @isstring);
    parse(parser, trainSetPath);
    
    trainSet = imageDatastore(trainSetPath, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
    
    firstHOGFeatures = getHOGFeatures(readimage(trainSet, 1), varargin{:});
    
    numImages = numel(trainSet.Files);
    trainFeatures = zeros(numImages, length(firstHOGFeatures), 'single');
    trainFeatures(1, :) = firstHOGFeatures;
    for i = 2 : numImages
        img = readimage(trainSet, i);
        trainFeatures(i, :) = getHOGFeatures(img, varargin{:});
    end
    trainLabels = trainSet.Labels;
    
    classifier = fitcecoc(trainFeatures, trainLabels);
end
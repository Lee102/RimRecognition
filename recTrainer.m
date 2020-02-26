function classifier = recTrainer(trainSetPath, cellSize, numBins, rimImfindcirclesBounds, cutRimSize)
% output:
    % classifier - builded hog classifier
% input:
    % trainSetPath - path to train set folder
    % cellSize - extractHOGFeatures cellSize
    % numBins - extractHOGFeatures numBins
    % rimImfindcirclesBounds - bounds for rim imfindcircles
    trainSet = imageDatastore(trainSetPath, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

    firstHOGFeatures = getHOGFeatures(readimage(trainSet, 1), cellSize, numBins, rimImfindcirclesBounds, cutRimSize);

    numImages = numel(trainSet.Files);
    trainFeatures = zeros(numImages, length(firstHOGFeatures), 'single');
    trainFeatures(1, :) = firstHOGFeatures;
    for i = 2 : numImages
        img = readimage(trainSet, i);
        trainFeatures(i, :) = getHOGFeatures(img, cellSize, numBins, rimImfindcirclesBounds, cutRimSize);
    end
    trainLabels = trainSet.Labels;

    classifier = fitcecoc(trainFeatures, trainLabels);
end

function features = getHOGFeatures(img, cellSize, numBins, imfindcirclesBounds, cutRimSize)
    [rXY, rR] = imfindcircles(img, imfindcirclesBounds, 'ObjectPolarity', 'bright', 'Sensitivity', 0.96, 'Method', 'twostage');
    img = cutRim(img, rXY, rR, cutRimSize);
    
    features = extractHOGFeatures(img, 'CellSize', cellSize, 'NumBins', numBins);
end
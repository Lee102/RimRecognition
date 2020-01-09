function classifier = recTrainer(trainSetPath)
    trainSet = imageDatastore(trainSetPath, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

    firstHOGFeatures = getHOGFeatures(readimage(trainSet, 1));

    numImages = numel(trainSet.Files);
    trainFeatures = zeros(numImages, length(firstHOGFeatures), 'single');
    trainFeatures(1, :) = firstHOGFeatures;
    for i = 2:numImages
        img = readimage(trainSet, i);
        trainFeatures(i, :) = getHOGFeatures(img);
    end
    trainLabels = trainSet.Labels;

    classifier = fitcecoc(trainFeatures, trainLabels);
end

function features = getHOGFeatures(img)
    cellSize = [55 55];
    numBins = 25;

    [rXY, rR] = imfindcircles(img, [250, 450], 'ObjectPolarity', 'bright', 'Sensitivity', 0.96, 'Method', 'twostage');
    img = cutRim(img, rXY, rR);
    
    features = extractHOGFeatures(img, 'CellSize', cellSize, 'NumBins', numBins);
end
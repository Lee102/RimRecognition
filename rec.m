function recognizedLabel = rec(classifier, img, cellSize, numBins)
% output:
    % recognizedLabel - label of recognized image
% input:
    % classifier - hog classifier
    % img - image to recognize
    % cellSize - extractHOGFeatures cellSize
    % numBins - extractHOGFeatures numBins
    
    features = extractHOGFeatures(img, 'CellSize', cellSize, 'NumBins', numBins);
    
    recognizedLabel = predict(classifier, features);
end
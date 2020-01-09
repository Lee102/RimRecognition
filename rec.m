function recognizedLabel = rec(classifier, img)
    cellSize = [55 55];
    numBins = 25;
    
    features = extractHOGFeatures(img, 'CellSize', cellSize, 'NumBins', numBins);
    
    recognizedLabel = predict(classifier, features);
end
function maxSize = calcSetsMaxSize(testSetPath, hogTrainSetPath)
    testSet = imageDatastore(testSetPath);
    hogTrainSet = imageDatastore(hogTrainSetPath, 'IncludeSubfolders', true);
    maxSize = 0;
    
    for i = 1 : numel(testSet.Files)
        img = readimage(testSet, i);
        maxSize = max([maxSize, size(img)]);
    end
    
    for i = 1 : numel(hogTrainSet.Files)
        img = readimage(hogTrainSet, i);
        maxSize = max([maxSize, size(img)]);
    end
end
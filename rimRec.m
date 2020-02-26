% temporary
clear
clc

trainSet = imageDatastore("Rims/RimsRec/Train",   'IncludeSubfolders', true, 'LabelSource', 'foldernames');
testSet = imageDatastore("Rims/RimsRec/Raw", 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

cellSize = [55 55];
numBins = 25;

hog = extractHOGFeatures(readimage(trainSet, 1),'CellSize',cellSize, 'NumBins', numBins);
hogFeatureSize = length(hog);

% numImages = numel(trainSet.Files);
% trainFeatures = zeros(numImages, hogFeatureSize, 'single');
% for i = 1:numImages
%     img = readimage(trainSet, i);
%     [rXY, rR] = imfindcircles(img, [250, 450], 'ObjectPolarity', 'bright', 'Sensitivity', 0.96, 'Method', 'twostage');
%     img = cutRim(img, rXY, rR);
% %     img = imbinarize(img);
% 
%     trainFeatures(i, :) = extractHOGFeatures(img, 'CellSize', cellSize, 'NumBins', numBins);
% end
% trainLabels = trainSet.Labels;

% classifier = fitcecoc(trainFeatures, trainLabels);
classifier = recTrainer("Rims/RimsRec/Train");

noTranslations = 1;
ind = 0;
numImages = numel(testSet.Files);
testFeatures = zeros((noTranslations*2+1)^2*numImages, hogFeatureSize, 'single');
for i = 1 : numImages
    img = readimage(testSet, i);
    [rXY, rR] = imfindcircles(img, [250, 450], 'ObjectPolarity', 'bright', 'Sensitivity', 0.96, 'Method', 'twostage');
    img = cutRim(img, rXY, rR);
%     img = imbinarize(img);
    
    [xSiz, ySiz, colCh] = size(img);
    xShift = (xSiz / 2 - rR) / noTranslations;
    yShift = (ySiz / 2 - rR) / noTranslations;
    for j = -noTranslations : noTranslations
        for k = -noTranslations : noTranslations
            ind = ind + 1;
            img1 = imtranslate(img, [j*xShift, k*yShift]);
            
            testFeatures(ind, :) = extractHOGFeatures(img1, 'CellSize', cellSize, 'NumBins', numBins);
            testLabels(ind) = testSet.Labels(i);
        end
    end
end

[predictedLabels,PredictedStateCovariance] = predict(classifier, testFeatures);
confMat = confusionmat(testLabels, predictedLabels);
correct = 0;
wrong = 0;
for i=1:ind
   if (predictedLabels(i) == testLabels(i))
       correct = correct + 1;
   else
       wrong = wrong + 1;
   end
end
disp(correct+"/"+wrong)
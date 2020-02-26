clear
clc

% start params
testSetPath = "Rims";
logMode = 2;
maxNoTranslations = 1;
% camera calibration
calibrationSetPath = "Cal";
squareSize = 25;
% imfindcircles
rimImfindcirclesBounds = [250, 450];
centralHoleImfindcirclesBounds = [30, 45];
outerHolesImfindcirclesBounds = [10, 22];
innerHolesImfindcirclesBounds = [6, 13];
% hog
hogTrainSetPath = "Rims/RimsRec/Raw";
cellSize = [55 55];
numBins = 25;
% cutRim
cutRimSize = calcSetsMaxSize(testSetPath, hogTrainSetPath);

warning('off', 'images:imfindcircles:warnForLargeRadiusRange');
warning('off', 'images:imfindcircles:warnForSmallRadius');

% camera calibration and hog classificator build
disp("Camera calibration");
tic;
[cameraParams, rotation, translation] = calibrateCam(calibrationSetPath, squareSize);
cameraCalibrationTime = toc;
if (logMode >= 2)
    disp("Camera calibration done within " + cameraCalibrationTime + " s.");
end
disp("Classifier build")
tic;
classifier = recTrainer(hogTrainSetPath, cellSize, numBins, rimImfindcirclesBounds, cutRimSize);
classifierBuildTime = toc;
if (logMode >= 2)
    disp("Classifier builded within " + cameraCalibrationTime + " s.");
end
disp("===============================================================")

disp("Rims calculations")
testSet = imageDatastore(testSetPath);
for i = 1 : numel(testSet.Files)
    imgName = extractAfter(testSet.Files(i), testSetPath+"\");
    if (logMode >= 1)
        disp("Calculated image: " + imgName)
    end
    result(i).path = imgName;
    result(i).maxNoTranslations = maxNoTranslations;
    for j = 1 : (maxNoTranslations+1)
        if (logMode >= 2)
            disp("Translations: " + (j-1));
        end
        try
            [result(i).tac(j).data, result(i).tac(j).stat, result(i).tac(j).recognized] = translateAndCalculate(classifier, readimage(testSet, i), j-1, logMode, rimImfindcirclesBounds, centralHoleImfindcirclesBounds, outerHolesImfindcirclesBounds, innerHolesImfindcirclesBounds, cellSize, numBins, cutRimSize);
            result(i).tac(j).err = "";
        catch x
            result(i).tac(j).err = x;
        end
        if (logMode >= 2 && j < (maxNoTranslations+1))
            disp("-----------------------------------------------------------")
        end
    end
    if (logMode >= 2)
        disp("===============================================================")
    end
end

disp("===============================================================")
disp("Calculating world sizes")
for i = 1 : numel(testSet.Files)
    for j = 1 : (maxNoTranslations+1)
        for k = 1 : length(result(i).tac(j).data)
            result(i).tac(j).data(k).rRW = calcWorldDistance(cameraParams, rotation, translation, result(i).tac(j).data(k).rXY, [result(i).tac(j).data(k).rXY(1) + result(i).tac(j).data(k).rR, result(i).tac(j).data(k).rXY(2)]);
            result(i).tac(j).data(k).chRW = calcWorldDistance(cameraParams, rotation, translation, result(i).tac(j).data(k).chXY, [result(i).tac(j).data(k).chXY(1) + result(i).tac(j).data(k).chR, result(i).tac(j).data(k).chXY(2)]);
            for l = 1 : result(i).tac(j).data(k).sQ
                result(i).tac(j).data(k).sRW(l) = calcWorldDistance(cameraParams, rotation, translation, result(i).tac(j).data(k).sXY(l,:), [result(i).tac(j).data(k).sXY(l,1) + result(i).tac(j).data(k).sR(l), result(i).tac(j).data(k).sXY(l,2)]);
            end
            result(i).tac(j).data(k).vRW = calcWorldDistance(cameraParams, rotation, translation, result(i).tac(j).data(k).vXY, [result(i).tac(j).data(k).vXY(1) + result(i).tac(j).data(k).vR, result(i).tac(j).data(k).vXY(2)]);
        end
    end
end

disp("===============================================================")
disp("Comparing recognized rims with their parameters")
labelsIndexes = unique(classifier.Y);











disp("via dominant lable")
for i = 1 : numel(testSet.Files)
    score(1 : length(labelsIndexes)) = 0;
    for j = 1 : (maxNoTranslations+1)
        for k = 1 : length(result(i).tac(j).recognized)
            ind = find(labelsIndexes == result(i).tac(j).recognized(k));
            score(ind) = score(ind) + 1;
        end
        result(i).tac(j).stat.correctRecognition = 0;
        result(i).tac(j).stat.wrongRecognition = 0;
    end
    dominantLable = labelsIndexes(find(score == max(score)));
    for j = 1 : (maxNoTranslations+1)
        for k = 1 : length(result(i).tac(j).recognized)
            if result(i).tac(j).recognized(k) == dominantLable
                result(i).tac(j).correctRecognition(k) = true;
                result(i).tac(j).stat.correctRecognition = result(i).tac(j).stat.correctRecognition + 1;
            else
                result(i).tac(j).correctRecognition(k) = false;
                result(i).tac(j).stat.wrongRecognition = result(i).tac(j).stat.wrongRecognition + 1;
            end
        end
    end
end

disp("via data")
for l = 1 : length(labelsIndexes)
    label = labelsIndexes(l);
    clear results
    ind = 1;
    for i = 1 : numel(testSet.Files)
        for j = 1 : (maxNoTranslations+1)
            for k = 1 : length(result(i).tac(j).recognized)
                if result(i).tac(j).recognized(k) == label
                    results(ind).data = result(i).tac(j).data(k);
                    results(ind).i = i;
                    results(ind).j = j;
                    results(ind).k = k;
                    ind = ind + 1;
                end
            end
        end
    end
    
    d = [results.data];
    fs = ["rR", "chR", "sQ", "vR", "aRad", "centr"];
    ma = max([d.sQ]);
    mi = min([d.sQ]);
    if ma == mi
        fs(7) = "sR";
    else
        q = zeros(ma - mi + 1, 1);
        for i = 1 : ma - mi + 1
            q(i) = sum([d.sQ] == i + mi - 1);
        end
        dom = find(max(q)) + mi - 1;
        for res = results
            if res.data.sQ ~= dom && result(res.i).tac(res.j).correctRecognition(res.k) == true
                result(res.i).tac(res.j).correctRecognition(res.k) = false;
                result(res.i).tac(res.j).stat.correctRecognition = result(res.i).tac(res.j).stat.correctRecognition - 1;
                result(res.i).tac(res.j).stat.wrongRecognition = result(res.i).tac(res.j).stat.wrongRecognition + 1;
            end
        end
    end
    for f = fs
        if var([d.(f)]) > 0
            me = mean([d.(f)]);
            tol = 1;
            for res = results
                if res.data.(f) < (me-tol) || res.data.(f) > (me+tol)
                    if result(res.i).tac(res.j).correctRecognition(res.k) == true
                        result(res.i).tac(res.j).correctRecognition(res.k) = false;
                        result(res.i).tac(res.j).stat.correctRecognition = result(res.i).tac(res.j).stat.correctRecognition - 1;
                        result(res.i).tac(res.j).stat.wrongRecognition = result(res.i).tac(res.j).stat.wrongRecognition + 1;
                    end
                end
            end
        end
    end
end
clear
clc
addpath('Scripts')

% start params
testSetPath = "Rims";
logMode = 2;
maxNoTranslations = 1;
% camera calibration
calibrationSetPath = "Cal";
squareSize = 25;
% hog
hogTrainSetPath = "Hog";

warning('off', 'images:imfindcircles:warnForLargeRadiusRange');
warning('off', 'images:imfindcircles:warnForSmallRadius');

% camera calibration and hog classificator build
disp("Camera calibration");
tic;
[cameraParams, rotation, translation] = calibrateCamera(calibrationSetPath, squareSize);
cameraCalibrationTime = toc;
if (logMode >= 2)
    disp("Camera calibration done within " + cameraCalibrationTime + " s.");
end
disp("Classifier build")
tic;
classifier = buildHogClassifier(hogTrainSetPath);
classifierBuildTime = toc;
if (logMode >= 2)
    disp("Classifier builded within " + cameraCalibrationTime + " s.");
end
disp("===============================================================")

disp("Rims calculations")
testSet = imageDatastore(testSetPath);
for i = 1 : numel(testSet.Files)
    imgName = char(extractAfter(testSet.Files(i), testSetPath+"\"));
    if (logMode >= 1)
        disp("Calculated image: " + imgName)
    end
    result(i).path = imgName;
    for j = 1 : (maxNoTranslations+1)
        if (logMode >= 2)
            disp("Translations: " + (j-1));
        end
        try
            tacData = translateAndCalculateRim(classifier, readimage(testSet, i), j-1, logMode);
            tacData.err = "";
            result(i).tac(j) = tacData;
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
tic;
for i = 1 : numel(testSet.Files)
    for j = 1 : (maxNoTranslations + 1)
        for k = 1 : length(result(i).tac(j).data)
            result(i).tac(j).data(k).rDW = calculateWorldDistance(cameraParams, rotation, translation, result(i).tac(j).data(k).rXY, [result(i).tac(j).data(k).rXY(1) + result(i).tac(j).data(k).rD, result(i).tac(j).data(k).rXY(2)]);
            result(i).tac(j).data(k).chDW = calculateWorldDistance(cameraParams, rotation, translation, result(i).tac(j).data(k).chXY, [result(i).tac(j).data(k).chXY(1) + result(i).tac(j).data(k).chD, result(i).tac(j).data(k).chXY(2)]);
            for l = 1 : result(i).tac(j).data(k).sQ
                result(i).tac(j).data(k).sDW(l) = calculateWorldDistance(cameraParams, rotation, translation, result(i).tac(j).data(k).sXY(l,:), [result(i).tac(j).data(k).sXY(l,1) + result(i).tac(j).data(k).sD(l), result(i).tac(j).data(k).sXY(l,2)]);
            end
            result(i).tac(j).data(k).vDW = calculateWorldDistance(cameraParams, rotation, translation, result(i).tac(j).data(k).vXY, [result(i).tac(j).data(k).vXY(1) + result(i).tac(j).data(k).vD, result(i).tac(j).data(k).vXY(2)]);
            result(i).tac(j).data(k).sCDW = calculateWorldDistance(cameraParams, rotation, translation, [0 0], [result(i).tac(j).data(k).sCD, 0]);
        end
    end
end
worldSizeCalculationTime = toc;
if (logMode >= 2)
    disp("Camera calibration done within " + worldSizeCalculationTime + " s.");
end

disp("===============================================================")
disp("Comparing recognized rims with their parameters")
labelsIndexes = unique(classifier.Y);

fData = [result.tac];
fData = [fData.data];
ind = 1;
for f = ["rD", "chD", "vD", "vAngle", "sQ", "sCD", "sCentr", "chCentr"]
    fData1(:,ind) = [fData.(f)];
    ind=ind+1;
end

[centers, partition] = fcm(fData1, length(labelsIndexes));
partionMax = max(partition);

for a = 1 : length(labelsIndexes)
    el = [];
    ind = 1;
    for b = find(partition(a, :) == partionMax) - 1
        i = floor(b / numel(testSet.Files)) + 1;
        m = mod(b, numel(testSet.Files)) + 1;
        j = 0;
        while m > 0
            k = m;
            m = m - (2 * j + 1) ^2;
            j = j + 1;
        end
        el(ind).i = i;
        el(ind).j = j;
        el(ind).k = k;
        el(ind).rec = result(i).tac(j).rec(k);
        ind = ind + 1;
    end
    
    uniqueLabels = unique([el.rec]);
    q = zeros(length(uniqueLabels), 1);
    for i = 1:length(uniqueLabels)
        q(i) = length(find(strcmp(uniqueLabels{i}, [el.rec])));
    end
    [~, ind] = max(q);
    m = el(ind).rec;
    
    for i = 1 : length(el)
        result(el(i).i).tac(el(i).j).correctRec(el(i).k) = m;
%         if strcmp(el(i).rec, m)
%             result(el(i).i).tac(el(i).j).wrongRec(el(i).k) = {''};
%         else
%             result(el(i).i).tac(el(i).j).wrongRec(el(i).k) = result(el(i).i).tac(el(i).j).rec(el(i).k);
%             result(el(i).i).tac(el(i).j).rec(el(i).k) = m;
%         end
    end
end
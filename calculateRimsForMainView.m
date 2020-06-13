function result = calculateRimsForMainView(calibrationSetPath, squareSize, hogTrainSetPath, testSetPath, maxNoTranslations)
% CALCULATERIMSFORMAINVIEW  Calculates rims parameters.
%   result = CALCULATERIMSFORMAINVIEW(calibrationSetPath, squareSize, 
%     hogTrainSetPath, testSetPath, maxNoTranslations) - Returns the calculated
%     rim parameters for the passed function parameters.
% 
% Basically it's starter.m for MainView.mlapp
    
    addpath('Scripts')
    logMode = 0;

    warning('off', 'images:imfindcircles:warnForLargeRadiusRange');
    warning('off', 'images:imfindcircles:warnForSmallRadius');

    [cameraParams, rotation, translation] = calibrateCamera(calibrationSetPath, squareSize);

    classifier = buildHogClassifier(hogTrainSetPath);

    testSet = imageDatastore(testSetPath);
    for i = 1 : numel(testSet.Files)
        imgName = char(extractAfter(testSet.Files(i), testSetPath+"\"));
        result(i).path = imgName;
        for j = 1 : (maxNoTranslations+1)
            try
                tacData = translateAndCalculateRim(classifier, readimage(testSet, i), j-1, logMode);
                tacData.err = "";
                result(i).tac(j) = tacData;
            catch x
                result(i).tac(j).err = x;
            end
        end
    end

    for i = 1 : numel(testSet.Files)
        for j = 1 : (maxNoTranslations + 1)
            for k = 1 : length(result(i).tac(j).data)
                result(i).tac(j).data(k).rDW = calculateWorldDistance(cameraParams, rotation, translation, result(i).tac(j).data(k).rXY, [result(i).tac(j).data(k).rXY(1) + result(i).tac(j).data(k).rD, result(i).tac(j).data(k).rXY(2)]);
                result(i).tac(j).data(k).chDW = calculateWorldDistance(cameraParams, rotation, translation, result(i).tac(j).data(k).chXY, [result(i).tac(j).data(k).chXY(1) + result(i).tac(j).data(k).chD, result(i).tac(j).data(k).chXY(2)]);
                for l = 1 : result(i).tac(j).data(k).sQ
                    result(i).tac(j).data(k).sDW(l) = calculateWorldDistance(cameraParams, rotation, translation, result(i).tac(j).data(k).sXY(l,:), [result(i).tac(j).data(k).sXY(l,1) + result(i).tac(j).data(k).sD(l), result(i).tac(j).data(k).sXY(l,2)]);
                end
                result(i).tac(j).data(k).vDW = calculateWorldDistance(cameraParams, rotation, translation, result(i).tac(j).data(k).vXY, [result(i).tac(j).data(k).vXY(1) + result(i).tac(j).data(k).vD, result(i).tac(j).data(k).vXY(2)]);
                result(i).tac(j).data(k).pcDW = calculateWorldDistance(cameraParams, rotation, translation, [0 0], [result(i).tac(j).data(k).pcD, 0]);
            end
        end
    end

    labelsIndexes = unique(classifier.Y);

    fData = [result.tac];
    fData = [fData.data];
    ind = 1;
    for f = ["rD", "chD", "sQ", "pcD", "vD", "vA"]
        fData1(:,ind) = [fData.(f)];
        ind=ind+1;
    end

    [~, partition] = fcm(fData1, length(labelsIndexes));
    partionMax = max(partition);

    for a = 1 : length(labelsIndexes)
        el = [];
        ind = 1;
        for b = find(partition(a, :) == partionMax) - 1
            i = floor(b / numel(testSet.Files)) + 1;
            m = mod(b, numel(testSet.Files)) + 1;
            if maxNoTranslations > 0
                j = 0;
                while m > 0
                    k = m;
                    m = m - (2 * j + 1) ^2;
                    j = j + 1;
                end
            else
                j = 1;
                k = 1;
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
        end
    end
    disp('a');
end
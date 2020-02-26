% temporary
% starter
clear
clc

warning('off', 'images:imfindcircles:warnForLargeRadiusRange');
%warning('off', 'images:imfindcircles:warnForSmallRadius');

rimImfindcirclesBounds = [250, 450];
centralHoleImfindcirclesBounds = [30, 45];
outerHolesImfindcirclesBounds = [10, 22];
innerHolesImfindcirclesBounds = [6, 13];
cellSize = [55 55];
numBins = 25;

logMode = 2;
maxNoTranslations = 1;
noImages = 10;

if (logMode >= 1)
    disp("Calculating classifier")
end
classifier = recTrainer("Rims/RimsRec/Raw", cellSize, numBins, rimImfindcirclesBounds);
if (logMode >= 2)
    disp("===============================================================")
end

if (logMode >= 1)
    disp("Translating and calculating rims")
end
for i = 1 : noImages
    path = "Rims/" + (i-1) + ".png";
    if (logMode >= 1)
        disp("path: " + path)
    end
    result(i).path = path;
    result(i).maxNoTranslations = maxNoTranslations;
    for j = 1 : (maxNoTranslations+1)
        try
            [data, stat, recognized] = translateAndCalculate(classifier, path, j-1, logMode, rimImfindcirclesBounds, centralHoleImfindcirclesBounds, outerHolesImfindcirclesBounds, innerHolesImfindcirclesBounds, cellSize, numBins);
            result(i).tac(j).data = data;
            result(i).tac(j).stat = stat;
            result(i).tac(j).recognized = recognized;
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

labelsIndexes = unique(classifier.Y);

for i = 1 : noImages
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

for l = 1 : length(labelsIndexes)
    label = labelsIndexes(l);
    clear results
    ind = 1;
    for i = 1 : noImages
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
    for f = ["rR", "chR", "sQ", "sR", "vR", "aRad", "aDeg", "centr"]
        if var([d.(f)]) > 0
            me = mean([d.(f)]);
            tol = 1;
            for res = results
                if res.data.(f) < (me-tol) || res.data.(f) > (me+tol)
                    if result(res.i).tac(res.j).correctRecognition(res.k) == true
                        result(res.i).tac(res.j).correctRecognition(res.k) = false;
                        result(res.i).tac(res.j).stat.correctRecognition = result(res.i).tac(res.j).stat.correctRecognition + 1;
                        result(res.i).tac(res.j).stat.wrongRecognition = result(res.i).tac(res.j).stat.wrongRecognition + 1;
                    end
                end
            end
        end
    end
end

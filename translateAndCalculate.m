function [data, stats, recognized] = translateAndCalculate(classifier, path, noTranslations, logMode)
    tic;
    
    if (logMode >= 2)
        disp("Opening image...")
    end
    
    warning('off', 'images:imfindcircles:warnForLargeRadiusRange');
%     warning('off', 'images:imfindcircles:warnForSmallRadius');
    img = imread(path);
    [xSiz, ySiz, colCh] = size(img);
    if colCh > 1
        img = rgb2gray(img);
    end
    
    if (logMode >= 2)
        disp("Calculating rim radius...")
    end
    
    [~, rR] = imfindcircles(img, [250, 450], 'ObjectPolarity', 'bright', 'Sensitivity', 0.96, 'Method', 'twostage');
   
    xShift = (xSiz / 2 - rR) / noTranslations;
    yShift = (ySiz / 2 - rR) / noTranslations;
    
    if (logMode >= 1)
        if (logMode >= 2)
            disp("Translating image and calculating rim dimensions...")
        end
        disp("Progress:")
    end
    
    if noTranslations > 0
        lind = (noTranslations * 2 + 1) ^ 2;
        ind = 1;
        for i = -noTranslations : noTranslations
            for j = -noTranslations : noTranslations
                if (logMode >=1)
                    disp(ind + " of " + lind)
                end

                img1 = imtranslate(img, [i*xShift, j*yShift]);
                [data(ind).rXY, data(ind).rR, data(ind).chXY, data(ind).chR, data(ind).sQ, data(ind).sXY, data(ind).sR, data(ind).scXY, data(ind).vXY, data(ind).vR, data(ind).aRad, data(ind).aDeg, data(ind).centr] = calcParams(img1, rR);
                recognized(ind) = rec(classifier, img);
                
                ind = ind + 1;
            end
        end
    else
        if (logMode >=1)
            disp("1 of 1")
        end
        [data(1).rXY, data(1).rR, data(1).chXY, data(1).chR, data(1).sQ, data(1).sXY, data(1).sR, data(1).scXY, data(1).vXY, data(1).vR, data(1).aRad, data(1).aDeg, data(1).centr] = calcParams(img, rR);
        recognized(1) = rec(classifier, img);
    end
    
    if (logMode >= 2)
        disp("Calculating data statistics...")
    end
    
    for f = ["rR", "chR", "sQ", "sR", "vR", "aRad", "aDeg", "centr"]
        try
            if (f ~= "sR")
                d = [data.(f)];
            else
                d = mean([data.(f)]);
            end
            stats.min.(f) = min(d);
            stats.max.(f) = max(d);
            stats.mean.(f) = mean(d);
            stats.median.(f) = median(d);
            stats.mode.(f) = mode(d);
            stats.var.(f) = var(d);
            stats.std.(f) = sqrt(stats.var.(f));
        catch x
            disp(x)
        end
    end
    stats.noTranslations = noTranslations;
    stats.time = toc;
    
    if (logMode >= 2)
        disp("Elapsed time: " + stats.time + " seconds")
    end
end
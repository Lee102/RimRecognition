function tacData = translateAndCalculateRim(classifier, img, noTranslations, logMode, varargin)
% TRANSLATEANDCALCULATERIM  Translates and calcutales rim parameters.
%   tacData = TRANSLATEANDCALCULATERIM(img) - Return the tacData structure
%   containing the following parameters calculated from the rim image (img):
%   - data - rim parameters calculated by CALCULATERIMPARAMETERES,
%   - stats - statistics for rim parameters rD, chD, sD, vD, vAngle, sQ, 
%       sCR, sCentr, chCentr, tim:
%     + min - minimum,
%     + max - maximum,
%     + mean,
%     + median,
%     + mode - modal,
%     + var - variation,
%     + std - standard deviation;
%   - rec - recognized by RECOGNIZERIM rim labels,
%   - tim - calculation time.
% 
%   [___] = TRANSLATEANDCALCULATERIM(___, Name, Value, ...) - allows to override
%   default parameters such as:
%     'rimRadiusBounds' - bounds for rim imfindcircles,
%     'rimObjectPolarity' - ObjectPolarity for rim imfindcircles,
%     'rimSensitivity' - Sensitivity for rim imfindcircles,
%     'rimMethod' - Method for rim imfindcircles,
%     'centralHoleRadiusBounds' - bounds for rim imfindcircles,
%     'centralHoleObjectPolarity' - ObjectPolarity for rim imfindcircles,
%     'centralHoleSensitivity' - Sensitivity for rim imfindcircles,
%     'centralHoleMethod' - Method for rim imfindcircles,
%     'smallOuterHolesRadiusBounds' - bounds for rim imfindcircles,
%     'smallOuterHolesObjectPolarity' - ObjectPolarity for rim imfindcircles,
%     'smallOuterHolesSensitivity' - Sensitivity for rim imfindcircles,
%     'smallOuterHolesMethod' - Method for rim imfindcircles,
%     'smallInnerHolesRadiusBounds' - bounds for rim imfindcircles,
%     'smallInnerHolesObjectPolarity' - ObjectPolarity for rim imfindcircles,
%     'smallInnerHolesSensitivity' - Sensitivity for rim imfindcircles,
%     'smallInnerHolesMethod' - Method for rim imfindcircles,
%     'cellSize' - extractHOGFeatures cellSize,
%     'numBins' - extractHOGFeatures numBins.
    
    t = tic;
    
    checkClassifier = @(x) all(class(classifier) == 'ClassificationECOC');
    checkImg = @(x) ismatrix(x) && ismember(class(x), {'uint8', 'uint16', 'double', 'logical', 'single', 'int16'});
    checkMatrixParams = @(x) ismatrix(x) && length(x) == 2;
    checkObjectPolarity = @(x) any(validatestring(x, {'bright', 'dark'}));
    checkSensitivity = @(x) isfloat(x) && x >= 0 && x <= 1;
    checkMethod = @(x) any(validatestring(x, {'phasecode', 'twostage'}));
    
    parser = inputParser();
    parser.KeepUnmatched = true;
    addRequired(parser, 'classifier', checkClassifier);
    addRequired(parser, 'img', checkImg);
    addRequired(parser, 'noTranslations', @isnumeric);
    addRequired(parser, 'logMode', @isnumeric);
    addParameter(parser, 'rimRadiusBounds', getDefaultValue('rimRadiusBounds'), checkMatrixParams);
    addParameter(parser, 'rimObjectPolarity', getDefaultValue('rimObjectPolarity'), checkObjectPolarity);
    addParameter(parser, 'rimSensitivity', getDefaultValue('rimSensitivity'), checkSensitivity);
    addParameter(parser, 'rimMethod', getDefaultValue('rimMethod'), checkMethod);
    parse(parser, classifier, img, noTranslations, logMode, varargin{:});
    rimRadiusBounds = parser.Results.rimRadiusBounds;
    rimObjectPolarity = parser.Results.rimObjectPolarity;
    rimSensitivity = parser.Results.rimSensitivity;
    rimMethod = parser.Results.rimMethod;
    
    if (logMode >= 2)
        disp("Opening image...")
    end
    
    [xSiz, ySiz, colCh] = size(img);
    if colCh > 1
        img = rgb2gray(img);
    end
    
    if (logMode >= 2)
        disp("Calculating rim radius...")
    end
    
    [~, rR] = imfindcircles(img, rimRadiusBounds, 'ObjectPolarity', rimObjectPolarity, 'Sensitivity', rimSensitivity, 'Method', rimMethod);
    
    if (logMode >= 1)
        if (logMode >= 2)
            disp("Translating image and calculating rim dimensions...")
        end
        disp("Progress:")
    end
    
    if noTranslations > 0
        xShift = (xSiz / 2 - rR) / noTranslations;
        yShift = (ySiz / 2 - rR) / noTranslations;
        lind = (noTranslations * 2 + 1) ^ 2;
        ind = 1;
        for i = -noTranslations : noTranslations
            for j = -noTranslations : noTranslations
                if (logMode >=1)
                    disp(ind + " of " + lind)
                end

                img1 = imtranslate(img, [i * xShift, j * yShift]);
                tacData.data(ind) = calculateRimParameters(img1, varargin{:}, 'rimRadius', rR);
                tacData.rec(ind) = recognizeRim(classifier, img1, varargin{:});
                
                ind = ind + 1;
            end
        end
    else
        if (logMode >=1)
            disp("1 of 1")
        end
        tacData.data(1) = calculateRimParameters(img, varargin{:}, 'rimRadius', rR);
        tacData.rec(1) = recognizeRim(classifier, img, varargin{:});
    end
    
    if (logMode >= 2)
        disp("Calculating data statistics...")
    end
    
    for f = ["rD", "chD", "sD", "vD", "vAngle", "sQ", "sCD", "sCentr", "chCentr", "tim"]
        d = cat(1, tacData.data.(f));
        
        stats.min.(f) = min(d);
        stats.max.(f) = max(d);
        stats.mean.(f) = mean(d);
        stats.median.(f) = median(d);
        stats.mode.(f) = mode(d);
        stats.var.(f) = var(d);
        stats.std.(f) = sqrt(stats.var.(f));
    end
    
    tacData.stats = stats;
    tacData.tim = toc(t);
    
    if (logMode >= 2)
        disp("Elapsed time: " + tacData.tim + " seconds")
    end
end
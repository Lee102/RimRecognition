function rimData = calculateRimParameters(img, varargin)
% CALCULATERIMPARAMETERES  Calculates rim parameters.
%   rimData = CALCULATERIMPARAMETERES(img) - Returns the rimData structure
%     containing the following rim parameters calculated from the img image:
%     - mid point coordinates and diameter of:
%       + rXY, rD - rim,
%       + chXY, chD - central hole,
%       + sXY, sD - screw holes,
%       + vXY, vD - ventil hole;
%     - vAngle - angle between ventil and screws,
%     - sQ - screws quantity,
%     - sCD - pitch circle diameter,
%     - centrity of:
%       + chCentr - central hole,
%       + sCentr - screws;
%     - tim - calculation time.
% 
%   [___] = CALCULATERIMPARAMETERES(___, Name, Value, ...) - allows to override
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
%     'rimRadius' - precalculated rR.
    
    t = tic;
    
    defaultRimRadius = -1;
    checkImg = @(x) ismatrix(x) && ismember(class(x), {'uint8', 'uint16', 'double', 'logical', 'single', 'int16'});
    checkMatrixParams = @(x) ismatrix(x) && length(x) == 2;
    checkObjectPolarity = @(x) any(validatestring(x, {'bright', 'dark'}));
    checkSensitivity = @(x) isfloat(x) && x >= 0 && x <= 1;
    checkMethod = @(x) any(validatestring(x, {'phasecode', 'twostage'}));
    checkRimRadius = @(x) isnumeric(x) && x > 0;
    
    parser = inputParser();
    parser.KeepUnmatched = true;
    addRequired(parser, 'img', checkImg);
    addParameter(parser, 'rimRadiusBounds', getDefaultValue('rimRadiusBounds'), checkMatrixParams);
    addParameter(parser, 'rimObjectPolarity', getDefaultValue('rimObjectPolarity'), checkObjectPolarity);
    addParameter(parser, 'rimSensitivity', getDefaultValue('rimSensitivity'), checkSensitivity);
    addParameter(parser, 'rimMethod', getDefaultValue('rimMethod'), checkMethod);
    addParameter(parser, 'centralHoleRadiusBounds', getDefaultValue('centralHoleRadiusBounds'), checkMatrixParams);
    addParameter(parser, 'centralHoleObjectPolarity', getDefaultValue('centralHoleObjectPolarity'), checkObjectPolarity);
    addParameter(parser, 'centralHoleSensitivity', getDefaultValue('centralHoleSensitivity'), checkSensitivity);
    addParameter(parser, 'centralHoleMethod', getDefaultValue('centralHoleMethod'), checkMethod);
    addParameter(parser, 'smallOuterHolesRadiusBounds', getDefaultValue('smallOuterHolesRadiusBounds'), checkMatrixParams);
    addParameter(parser, 'smallOuterHolesObjectPolarity', getDefaultValue('smallOuterHolesObjectPolarity'), checkObjectPolarity);
    addParameter(parser, 'smallOuterHolesSensitivity', getDefaultValue('smallOuterHolesSensitivity'), checkSensitivity);
    addParameter(parser, 'smallOuterHolesMethod', getDefaultValue('smallOuterHolesMethod'), checkMethod);
    addParameter(parser, 'smallInnerHolesRadiusBounds', getDefaultValue('smallInnerHolesRadiusBounds'), checkMatrixParams);
    addParameter(parser, 'smallInnerHolesObjectPolarity', getDefaultValue('smallInnerHolesObjectPolarity'), checkObjectPolarity);
    addParameter(parser, 'smallInnerHolesSensitivity', getDefaultValue('smallInnerHolesSensitivity'), checkSensitivity);
    addParameter(parser, 'smallInnerHolesMethod', getDefaultValue('smallInnerHolesMethod'), checkMethod);
    addParameter(parser, 'rimRadius', defaultRimRadius, checkRimRadius);
    parse(parser, img, varargin{:});
    rimRadiusBounds = parser.Results.rimRadiusBounds;
    rimObjectPolarity = parser.Results.rimObjectPolarity;
    rimSensitivity = parser.Results.rimSensitivity;
    rimMethod = parser.Results.rimMethod;
    centralHoleRadiusBounds = parser.Results.centralHoleRadiusBounds;
    centralHoleObjectPolarity = parser.Results.centralHoleObjectPolarity;
    centralHoleSensitivity = parser.Results.centralHoleSensitivity;
    centralHoleMethod = parser.Results.centralHoleMethod;
    smallOuterHolesRadiusBounds = parser.Results.smallOuterHolesRadiusBounds;
    smallOuterHolesObjectPolarity = parser.Results.smallOuterHolesObjectPolarity;
    smallOuterHolesSensitivity = parser.Results.smallOuterHolesSensitivity;
    smallOuterHolesMethod = parser.Results.smallOuterHolesMethod;
    smallInnerHolesRadiusBounds = parser.Results.smallInnerHolesRadiusBounds;
    smallInnerHolesObjectPolarity = parser.Results.smallInnerHolesObjectPolarity;
    smallInnerHolesSensitivity = parser.Results.smallInnerHolesSensitivity;
    smallInnerHolesMethod = parser.Results.smallInnerHolesMethod;
    rimRadius = parser.Results.rimRadius;
    
    if rimRadius > 0
        [rXY, rR] = imfindcircles(img, [rimRadius - 5, rimRadius + 5], 'ObjectPolarity', rimObjectPolarity, 'Sensitivity', rimSensitivity, 'Method', rimMethod);
    else
        [rXY, rR] = imfindcircles(img, rimRadiusBounds, 'ObjectPolarity', rimObjectPolarity, 'Sensitivity', rimSensitivity, 'Method', rimMethod);
    end
    
    figure('visible','off');
    roi = drawcircle('Center', rXY, 'Radius', rR);
    mask = createMask(roi, img);
    img = regionfill(img, ~mask);
    
    figure('visible','off');
    roi = drawcircle('Center', rXY, 'Radius', 2 * max(centralHoleRadiusBounds));
    mask = createMask(roi, img);
    chImg = regionfill(img, ~mask);
    [chXY, chR] = imfindcircles(chImg, centralHoleRadiusBounds, 'ObjectPolarity', centralHoleObjectPolarity, 'Sensitivity', centralHoleSensitivity, 'Method', centralHoleMethod);
    
    figure('visible','off');
    roi = drawcircle('Center', rXY, 'Radius', 3 * chR);
    mask = createMask(roi, img);
    sImg = regionfill(img, ~mask);
    [sOHXY, sOHR] = imfindcircles(sImg, smallOuterHolesRadiusBounds, 'ObjectPolarity', smallOuterHolesObjectPolarity, 'Sensitivity', smallOuterHolesSensitivity, 'Method', smallOuterHolesMethod);
    [sIHXY, sIHR] = imfindcircles(sImg, smallInnerHolesRadiusBounds, 'ObjectPolarity', smallInnerHolesObjectPolarity, 'Sensitivity', smallInnerHolesSensitivity, 'Method', smallInnerHolesMethod);
    
    figure('visible','off');
    roi = drawcircle('Center', rXY, 'Radius', 3 * rR / 4);
    mask = createMask(roi, img);
    vImg = regionfill(img, mask);
    [vOHXY, vOHR] = imfindcircles(vImg, smallOuterHolesRadiusBounds, 'ObjectPolarity', smallOuterHolesObjectPolarity, 'Sensitivity', smallOuterHolesSensitivity, 'Method', smallOuterHolesMethod);
    [vIHXY, vIHR] = imfindcircles(vImg, smallInnerHolesRadiusBounds, 'ObjectPolarity', smallInnerHolesObjectPolarity, 'Sensitivity', smallInnerHolesSensitivity, 'Method', smallInnerHolesMethod);
    
    close all
    
    ind = 1;
    for i = 1 : length(sOHR)
        for j = 1 : length(sIHR)
            if ((sIHXY(j,1) - sOHXY(i,1)) ^ 2 + (sIHXY(j,2) - sOHXY(i,2)) ^2 <= sOHR(i) ^ 2)
                sXY(ind,:) = sIHXY(j,:);
                sR(ind,1) = sIHR(j);
                ind = ind + 1;
            end
        end
    end
    
    ind = 1;
    for i = 1 : length(vOHR)
        for j = 1 : length(vIHR)
            if ((vIHXY(j,1) - vOHXY(i,1)) ^ 2 + (vIHXY(j,2) - vOHXY(i,2)) ^2 <= vOHR(i) ^ 2)
                vXY(ind,:) = vIHXY(j,:);
                vR(ind,1) = vIHR(j);
                ind = ind + 1;
            end
        end
    end
    
    hXY = [sXY; vXY];
    mid = mean(hXY);
    ord = atan2(hXY(:,2) - mid(2), hXY(:,1) - mid(1));
    [~, order] = sort(ord);
    sHXY = hXY(order,:);
    ind = find(sHXY(:,1) == vXY(1) & sHXY(:,2) == vXY(2));
    if ind < length(sHXY)
        ind = ind + 1;
    else
        ind = 1;
    end
    
    oSs = sqrt((rXY(1) - sHXY(ind,1)) ^ 2 + (rXY(2) - sHXY(ind,2)) ^ 2);
    oSw = sqrt((rXY(1) - vXY(1)) ^ 2 + (rXY(2) - vXY(2)) ^ 2);
    osw = sqrt((sHXY(ind,1) - vXY(1)) ^ 2 + (sHXY(ind,2) - vXY(2)) ^ 2);
    
    sCXY = mean(sXY);
    sCR = 0;
    for i = 1 : length(sXY)
        sCR = sCR + sqrt((sCXY(1) - sXY(i,1)) ^ 2 + (sCXY(2) - sXY(i,2)) ^ 2);
    end
    sCR = sCR / length(sXY);
    
    rimData.rXY = rXY;
    rimData.rD = 2 * rR;
    rimData.chXY = chXY;
    rimData.chD = 2 * chR;
    rimData.sXY = sXY;
    rimData.sD = 2 * sR;
    rimData.vXY = vXY;
    rimData.vD = 2 * vR;
    rimData.vAngle = acos((oSs ^ 2 + oSw ^ 2 - osw ^ 2) / (2 * oSs * oSw)) * 180 / pi;
    rimData.sQ = length(sR);
    rimData.sCD = 2 * sCR;
    rimData.sCentr = sqrt((rXY(1) - sCXY(1)) ^ 2 + (rXY(2) - sCXY(2)) ^ 2);
    rimData.chCentr = sqrt((rXY(1) - chXY(1)) ^ 2 + (rXY(2) - chXY(2)) ^ 2);
    rimData.tim = toc(t);
end
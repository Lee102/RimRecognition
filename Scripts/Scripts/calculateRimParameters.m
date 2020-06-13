function rimData = calculateRimParameters(img, varargin)
% CALCULATERIMPARAMETERES  Calculates rim parameters.
%   rimData = CALCULATERIMPARAMETERES(img) - Returns the rimData structure
%     containing the following rim parameters calculated from the img image:
%     - mid point coordinates and diameter of:
%       + rXY, rD - rim,
%       + chXY, chD - central hole,
%       + sXY, sD - screw holes,
%       + vXY, vD - ventil hole;
%     - vA - angle between ventil and screws,
%     - sQ - screws quantity,
%     - pcD - pitch circle diameter,
%     - centrity vector of:
%       + chC - rim - central hole,
%       + pcC - central hole - pitch circle;
%     - tim - calculation time.
% 
%   [___] = CALCULATERIMPARAMETERES(___, Name, Value, ...) - allows to override
%   default parameters such as:
%     'rimRadiusBounds' - bounds for rim imfindcircles,
%     'rimObjectPolarity' - ObjectPolarity for rim imfindcircles,
%     'rimSensitivity' - Sensitivity for rim imfindcircles,
%     'rimMethod' - Method for rim imfindcircles,
%     'centralHoleRadiusBounds' - bounds for central hole imfindcircles,
%     'centralHoleObjectPolarity' - ObjectPolarity for central hole imfindcircles,
%     'centralHoleSensitivity' - Sensitivity for central hole imfindcircles,
%     'centralHoleMethod' - Method for central hole imfindcircles,
%     'smallHolesObjectPolarity' - ObjectPolarity for screw and ventil imfindcircles,
%     'smallHolesSensitivity' - Sensitivity for screw and ventil imfindcircles,
%     'smallHolesMethod' - Method for screw and ventil imfindcircles,
%     'screwHolesRadiusBounds' - bounds for screw imfindcircles,
%     'screwHolesScoreMaxDiff' - max difference between screws imfindcircle score,
%     'screwRadiusMaxDiff' - max difference between screws radiuses,
%     'screwAngleMaxDiff' - max difference between two screws angles,
%     'ventilHoleRadiusBounds' - bounds for ventil imfindcircles,
%     'rimRadius' - precalculated rR.
    
    t = tic;
    
    defaultRimRadius = -1;
    checkImg = @(x) ismatrix(x) && ismember(class(x), {'uint8', 'uint16', 'double', 'logical', 'single', 'int16'});
    checkMatrixParams = @(x) ismatrix(x) && length(x) == 2;
    checkObjectPolarity = @(x) any(validatestring(x, {'bright', 'dark'}));
    checkSensitivity = @(x) isfloat(x) && x >= 0 && x <= 1;
    checkMethod = @(x) any(validatestring(x, {'phasecode', 'twostage'}));
    checkRimRadius = @(x) isnumeric(x) && x > 0;
    checkScrewAngleMaxDiff = @(x) isfloat(x) && x >= 0 && x <= 180;
    
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
    addParameter(parser, 'smallHolesObjectPolarity', getDefaultValue('smallHolesObjectPolarity'), checkObjectPolarity);
    addParameter(parser, 'smallHolesSensitivity', getDefaultValue('smallHolesSensitivity'), checkSensitivity);
    addParameter(parser, 'smallHolesMethod', getDefaultValue('smallHolesMethod'), checkMethod);
    addParameter(parser, 'screwHolesRadiusBounds', getDefaultValue('screwHolesRadiusBounds'), checkMatrixParams);
    addParameter(parser, 'screwHolesScoreMaxDiff', getDefaultValue('screwHolesScoreMaxDiff'), @isfloat);
    addParameter(parser, 'screwRadiusMaxDiff', getDefaultValue('screwRadiusMaxDiff'), @isfloat);
    addParameter(parser, 'screwAngleMaxDiff', getDefaultValue('screwAngleMaxDiff'), checkScrewAngleMaxDiff);
    addParameter(parser, 'ventilHoleRadiusBounds', getDefaultValue('ventilHoleRadiusBounds'), checkMatrixParams);
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
    smallHolesObjectPolarity = parser.Results.smallHolesObjectPolarity;
    smallHolesSensitivity = parser.Results.smallHolesSensitivity;
    smallHolesMethod = parser.Results.smallHolesMethod;
    screwHolesRadiusBounds = parser.Results.screwHolesRadiusBounds;
    screwHolesScoreMaxDiff = parser.Results.screwHolesScoreMaxDiff;
    screwRadiusMaxDiff = parser.Results.screwRadiusMaxDiff;
    screwAngleMaxDiff = parser.Results.screwAngleMaxDiff;
    ventilHoleRadiusBounds = parser.Results.ventilHoleRadiusBounds;
    rimRadius = parser.Results.rimRadius;
    
    if rimRadius > 0
        [rXY, rR] = imfindcircles(img, [rimRadius - 5, rimRadius + 5], 'ObjectPolarity', rimObjectPolarity, 'Sensitivity', rimSensitivity, 'Method', rimMethod);
    else
        [rXY, rR] = imfindcircles(img, rimRadiusBounds, 'ObjectPolarity', rimObjectPolarity, 'Sensitivity', rimSensitivity, 'Method', rimMethod);
    end
    rXY = rXY(1, :);
    rR = rR(1);
    
    figure('visible','off');
    roi = drawcircle('Center', rXY, 'Radius', rR);
    mask = createMask(roi, img);
    img(mask == 0) = 0;
    
    roi = drawcircle('Center', rXY, 'Radius', rR / 2);
    mask = createMask(roi, img);
    chImg = img;
    chImg(mask == 0) = 0;
    [chXY, chR] = imfindcircles(chImg, centralHoleRadiusBounds, 'ObjectPolarity', centralHoleObjectPolarity, 'Sensitivity', centralHoleSensitivity, 'Method', centralHoleMethod);
    chXY = chXY(1, :);
    chR = chR(1);
    
    roi = drawcircle('Center', rXY, 'Radius', chR);
    mask = createMask(roi, img);
    sImg = chImg;
    sImg(mask == 1) = 0;
    [sXY, sR, score] = imfindcircles(sImg, screwHolesRadiusBounds, 'ObjectPolarity', smallHolesObjectPolarity, 'Sensitivity', smallHolesSensitivity, 'Method', smallHolesMethod);
    scoreDiff = zeros(1, length(score) - 1);
    for i = 1 : length(score) - 1
        scoreDiff(i) = score(i) - score(i + 1);
    end
    i = find(scoreDiff > screwHolesScoreMaxDiff);
    if ~isempty(i)
        sXY(i(1) + 1 : end, :) = [];
        sR(i(1) + 1 : end) = [];
    end
    
    roi = drawcircle('Center', rXY, 'Radius', 3 * rR / 4);
    mask = createMask(roi, img);
    vImg = img;
    vImg(mask == 1) = 0;
    [vXY, vR] = imfindcircles(vImg, ventilHoleRadiusBounds, 'ObjectPolarity', smallHolesObjectPolarity, 'Sensitivity', smallHolesSensitivity, 'Method', smallHolesMethod);
    vXY = vXY(1, :);
    vR = vR(1);
    
    close all
    
    hXY = [sXY; vXY];
    ord = atan2(hXY(:, 2) - rXY(2), hXY(:, 1) - rXY(1));
    [~, order] = sort(ord);
    sHXY = hXY(order, :);
    ind = find(sHXY(:, 1) == vXY(1) & sHXY(:, 2) == vXY(2));
    sSXY = sHXY;
    sSXY(ind, :) = [];
    if ind < length(sHXY)
        ind = ind + 1;
    else
        ind = 1;
    end
    
    sQ = length(sR);
    sDC = true;
    
    if any(abs(sR - mean(sR)) > screwRadiusMaxDiff)
        sDC = false;
    end
    
    sA = zeros(1, sQ);
    for i = 1 : sQ
		if i < length(sSXY)
            j = i + 1;
        else
            j = 1;
		end
		oSs1 = sqrt((rXY(1) - sSXY(i, 1)) ^ 2 + (rXY(2) - sSXY(i, 2)) ^ 2);
		oSs2 = sqrt((rXY(1) - sSXY(j, 1)) ^ 2 + (rXY(2) - sSXY(j, 2)) ^ 2);
		os1s2 = sqrt((sSXY(i, 1) - sSXY(j, 1)) ^ 2 + (sSXY(i, 2) - sSXY(j, 2)) ^ 2);
		sA(i) = acos((oSs1 ^ 2 + oSs2 ^ 2 - os1s2 ^ 2) / (2 * oSs1 * oSs2)) * 180 / pi;
    end
    if any(abs(sA - 360 / sQ) > screwAngleMaxDiff)
        sDC = false;
    end
    
    oSs = sqrt((rXY(1) - sHXY(ind,1)) ^ 2 + (rXY(2) - sHXY(ind,2)) ^ 2);
    oSw = sqrt((rXY(1) - vXY(1)) ^ 2 + (rXY(2) - vXY(2)) ^ 2);
    osw = sqrt((sHXY(ind,1) - vXY(1)) ^ 2 + (sHXY(ind,2) - vXY(2)) ^ 2);
    
    pcXY = mean(sXY);
    pcR = mean(sqrt((pcXY(1) - sXY(:,1)) .^ 2 + (pcXY(2) - sXY(:,2)) .^ 2));
    
    rimData.rXY = rXY;
    rimData.rD = 2 * rR;
    rimData.chXY = chXY;
    rimData.chD = 2 * chR;
    rimData.chC = chXY - rXY;
    rimData.sXY = sXY;
    rimData.sD = 2 * sR;
    rimData.sQ = sQ;
    rimData.sDC = sDC;
    rimData.pcD = 2 * pcR;
    rimData.pcC = pcXY - chXY;
    rimData.vXY = vXY;
    rimData.vD = 2 * vR;
    rimData.vA = acos((oSs ^ 2 + oSw ^ 2 - osw ^ 2) / (2 * oSs * oSw)) * 180 / pi;
    rimData.tim = toc(t);
end
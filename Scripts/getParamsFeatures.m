function features = getParamsFeatures(img, varargin)
% GETPARAMSFEATURES  Extracts params features.
%   features = GETHOGFEATURES(img) - extracts params features from an img image.
% 
%   [___] = GETPARAMSFEATURES(___, Name, Value, ...) - allows to override
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
%     'ventilHoleRadiusBounds' - bounds for ventil imfindcircles.
    
    checkImg = @(x) ismatrix(x) && ismember(class(x), {'uint8', 'uint16', 'double', 'logical', 'single', 'int16'});
    
    parser = inputParser();
    parser.KeepUnmatched = true;
    addRequired(parser, 'img', checkImg);
    parse(parser, img);
    
    data = calculateRimParameters(img, varargin{:});
    
    features = zeros(1, 11, 'single');
    
    ind = 1;
    for f = ["rD", "chD", "sQ", "pcD", "vD", "vA"]
        features(ind) = data.(f);
    ind = ind + 1;
    end
    
    features(7) = data.chC(1);
    features(8) = data.chC(2);
    features(9) = mean(data.sD);
    features(10) = data.pcC(1);
    features(11) = data.pcC(2);
end


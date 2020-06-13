function [label, tim] = recognizeRimByParams(classifier, data, varargin)
% RECOGNIZERIMBYPARAMS  Recognizes rim.
%   label = RECOGNIZERIMBYPARAMS(classifier, img) - uses the rim params 
%   classifier (classifier) to detect the rim model (label) from the rim 
%   params (data) in (tim) seconds.
% 
%   [___] = RECOGNIZERIMBYPARAMS(___, Name, Value, ...) - allows to override
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
%     'ventilHoleRadiusBounds' - bounds for ventil imfindcircles.
    
    t = tic;
    
    checkClassifier = @(x) all(class(classifier) == 'ClassificationECOC');
    checkData = @(x) isstruct(x) && all(isfield(x, ["rD", "chD", "chC", "sD", "sQ", "pcD", "pcC", "vD", "vA"]));
    
    parser = inputParser();
    parser.KeepUnmatched = true;
    addRequired(parser, 'classifier', checkClassifier);
    addRequired(parser, 'data', checkData);
    parse(parser, classifier, data);
    
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
    
    label = cellstr(predict(classifier, features));
    tim = toc(t);
end


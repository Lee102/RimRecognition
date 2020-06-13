function [classifier, tim] = buildParamsClassifier(trainSetPath, varargin)
% BUILDPARMSCLASSIFIER  Builds a params classifier.
%   classifier = BUILDHOGCLASSIFIER(trainSetPath) - trains classifier
%   with a set of rim parameters captured from pictures saved in the 
%   trainSetPath path in tim seconds.
%
%   [___] = BUILDPARMSCLASSIFIER(___, Name, Value, ...) - allows to override
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
    
    t = tic;
    
    parser = inputParser();
    parser.KeepUnmatched = true;
    addRequired(parser, 'trainSetPath', @isstring);
    parse(parser, trainSetPath);
    
    trainSet = imageDatastore(trainSetPath, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
    
    firstParamsFeatures = getParamsFeatures(readimage(trainSet, 1), varargin{:});
    
    numImages = numel(trainSet.Files);
    trainFeatures = zeros(numImages, length(firstParamsFeatures), 'single');
    trainFeatures(1, :) = firstParamsFeatures;
    for i = 2 : numImages
        img = readimage(trainSet, i);
        trainFeatures(i, :) = getParamsFeatures(img, varargin{:});
    end
    trainLabels = trainSet.Labels;
    
    classifier = fitcecoc(trainFeatures, trainLabels);
    tim = toc(t);
end


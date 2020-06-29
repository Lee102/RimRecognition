function [label, tim] = recognizeRimByParams(classifier, data)
% RECOGNIZERIMBYPARAMS  Recognizes rim.
%   label = RECOGNIZERIMBYPARAMS(classifier, img) - uses the rim params 
%   classifier (classifier) to detect the rim model (label) from the rim 
%   params (data) in (tim) seconds.
    
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


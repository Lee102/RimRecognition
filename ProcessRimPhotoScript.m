clear
clc
addpath('Scripts')

% start params
imagePath = "Rims/0.png";
logMode = 2;
maxNoTranslations = 0;
% camera calibration
calibrationSetPath = "CalibrationSet";
squareSize = 25;
% hog classifier
hogTrainSetPath = "ClassifierBuildSet";
% params classifier
paramsTrainSetPath = "ClassifierBuildSet";

warning('off', 'images:imfindcircles:warnForLargeRadiusRange');
warning('off', 'images:imfindcircles:warnForSmallRadius');

% camera calibration and classificators builds
disp("Camera calibration");
[cameraParams, cameraRotation, cameraTranslation, cameraCalibrationTime] = calibrateCamera(calibrationSetPath, squareSize);
if (logMode >= 2)
    disp("Camera calibration done within " + cameraCalibrationTime + " s.")
end
disp("Hog classifier build")
[hogClassifier, hogClassifierBuildTime] = buildHogClassifier(hogTrainSetPath);
if (logMode >= 2)
    disp("Hog classifier builded within " + hogClassifierBuildTime + " s.")
end
disp("Params classifier build")
[paramsClassifier, paramsClassifierBuildTime] = buildParamsClassifier(paramsTrainSetPath);
if (logMode >= 2)
    disp("Params classifier builded within " + paramsClassifierBuildTime + " s.")
end
disp("===============================================================")

disp("Rim calculations")
img = imread(imagePath);
[~, ~, colCh] = size(img);
if colCh > 1
    img = rgb2gray(img);
end

result.data = calculateRimParameters(img);
disp("Rim params calculated within " + result.data.tim + " s:")

disp("Rim:")
disp("  xy: [" + result.data.rXY(1) + " " + result.data.rXY(2) + "]")
disp("  diameter: " + result.data.rD + " px")
disp("Central hole:")
disp("  xy: [" + result.data.chXY(1) + " " + result.data.chXY(2) + "]")
disp("  diameter: " + result.data.chD + " px")
disp("  centricity vector: [" + result.data.chC(1) + " " + result.data.chC(2) + "]")
disp("Screw holes:")
disp("  quantity: " + result.data.sQ)
disp("  xy:")
for i = 1 : result.data.sQ
    disp("    [" + result.data.sXY(1) + " " + result.data.sXY(2) + "]")
end
disp("  diameters:")
for i = 1 : result.data.sQ
    disp("    " + result.data.sD(i) + " px")
end
if ~result.data.sDC
    disp("    Screws was not detected correctly!")
end
disp("Pitch circle:")
disp("  diameter: " + result.data.pcD + " px")
disp("  centricity vector: [" + result.data.pcC(1) + " " + result.data.pcC(2) + "]")
disp("Ventil hole:")
disp("  xy: [" + result.data.vXY(1) + " " + result.data.vXY(2) + "]")
disp("  diameter: " + result.data.vD + " px")
disp("  angle: " + result.data.vA + " deg")

disp("===============================================================")
disp("Calculating real sizes")
result.data.rDW = calculateWorldDistance(cameraParams, cameraRotation, cameraTranslation, result.data.rXY, [result.data.rXY(1) + result.data.rD, result.data.rXY(2)]);
result.data.chDW = calculateWorldDistance(cameraParams, cameraRotation, cameraTranslation, result.data.chXY, [result.data.chXY(1) + result.data.chD, result.data.chXY(2)]);
for l = 1 : result.data.sQ
    result.data.sDW(l) = calculateWorldDistance(cameraParams, cameraRotation, cameraTranslation, result.data.sXY(l,:), [result.data.sXY(l,1) + result.data.sD(l), result.data.sXY(l,2)]);
end
result.data.vDW = calculateWorldDistance(cameraParams, cameraRotation, cameraTranslation, result.data.vXY, [result.data.vXY(1) + result.data.vD, result.data.vXY(2)]);
result.data.pcDW = calculateWorldDistance(cameraParams, cameraRotation, cameraTranslation, [0 0], [result.data.pcD, 0]);

disp("Rim diameter: " + result.data.rDW + " mm")
disp("Central hole diameter: " + result.data.chDW + " mm")
disp("Screws diameters:")
for i = 1 : result.data.sQ
    disp("  " + result.data.sDW(i) + " mm")
end
disp("Pitch circle diameter: " + result.data.pcDW + " mm");
disp("Ventil diameter: " + result.data.vDW + " mm")

disp("===============================================================")
disp("Recognizing rim model")

disp("Recognizing rim model by hog features");
[result.hogRec, result.hogTim] = recognizeRimByHOG(hogClassifier, img, 'rimXY', result.data.rXY, 'rimRadius', result.data.rD / 2);
disp("Hog recognizion ended within " + result.hogTim + " s with result " + result.hogRec)

disp("Recognizing rim model by params");
[result.paramsRec, result.paramsTim] = recognizeRimByParams(paramsClassifier, result.data);
disp("Params recognizion ended within " + result.paramsTim + " s with result " + result.paramsRec)
function ds_classifier = trainDynamicSwitchClassifier(datasetPath)
%TRAINDYNAMICSWITCHCLASSIFIER
%
% Prepares the training data and trains the CNN classifier for the dynamic
% switch

[XTrain, labelName] = getDataTrain_Switch(datasetPath);
ds_classifier = fitSwitchClassifier(XTrain, labelName);
end
function ds_classifier = trainDynamicSwitchClassifier(data, labels, files)
%TRAINDYNAMICSWITCHCLASSIFIER Prepares the training data and trains the CNN
%classification network

[XTrain, labelName] = getDataTrain_Switch(data, labels, files);
ds_classifier = fitSwitchClassifier(XTrain, labelName);
end
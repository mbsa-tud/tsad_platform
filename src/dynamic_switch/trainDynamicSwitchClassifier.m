function ds_classifier = trainDynamicSwitchClassifier(data, labels, fileNames)
%TRAINDYNAMICSWITCHCLASSIFIER Prepares the training data and trains the CNN
%classification network

[XTrain, labelName] = getDataTrain_Switch(data, labels, fileNames);
ds_classifier = fitSwitchClassifier(XTrain, labelName);
end
function ds_classifier = trainDynamicSwitchClassifier(datasetPath)
[XTrain, labelName] = getDataTrain_Switch(datasetPath);
ds_classifier = fitSwitchClassifier(XTrain, labelName);
end
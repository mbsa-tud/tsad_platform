function [XTest, YTest, labelsTest] = prepareDataTest_DL(modelOptions, data, labels)
%PREPAREDATATEST_DNN Prepares the testing data for DNN models

switch modelOptions.name
    case "Your model name"
    otherwise
        [XTest, YTest, labelsTest] = splitDataTest(data, labels, ...
            modelOptions.hyperparameters.windowSize, modelOptions.modelType, ...
            modelOptions.dataType);
end
end

function [XTest, TSTest, labelsTest] = prepareDataTest_DL(modelOptions, data, labels)
%PREPAREDATATEST_DNN Prepares the testing data for DNN models

switch modelOptions.name
    case "Your model name"
    otherwise
        [XTest, TSTest, labelsTest] = splitDataTest(data, labels, ...
            modelOptions.hyperparameters.windowSize, modelOptions.modelType, ...
            modelOptions.dataType);
end
end

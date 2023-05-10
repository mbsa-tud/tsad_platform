function [XTest, TSTest, labelsTest] = prepareDataTest(modelOptions, data, labels)
%PREPAREDATATEST_DNN Prepares the testing data for DNN models

switch modelOptions.name
    case "Your model name"
    otherwise
        if strcmp(modelOptions.type, "deep-learning")
            [XTest, TSTest, labelsTest] = splitDataTest(data, labels, ...
                modelOptions.hyperparameters.windowSize, modelOptions.modelType, ...
                modelOptions.dataType);
        else
            if modelOptions.useSubsequences
                [XTest, TSTest, labelsTest] = splitDataTest(data, labels, ...
                    modelOptions.hyperparameters.windowSize, ...
                    "reconstructive", modelOptions.dataType);
            else
                XTest = cell2mat(data);
                TSTest = XTest;
                labelsTest = cell2mat(labels);
            end
        end
end
end

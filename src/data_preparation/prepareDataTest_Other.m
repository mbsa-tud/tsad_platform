function [XTest, TSTest, labelsTest] = prepareDataTest_Other(modelOptions, data, labels)
%PREPAREDATATEST_CML Prepares the testing data for classic ML models

switch modelOptions.name
    case "Your model name"
    otherwise
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

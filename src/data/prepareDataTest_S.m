function [XTest, YTest, labelsTest] = prepareDataTest_S(modelOptions, data, labels)
%PREPAREDATATEST_S Prepares the testing data for statistical models

switch modelOptions.name
    case 'Your model name'
    otherwise
        if modelOptions.useSubsequences
            [XTest, YTest, labelsTest] = splitDataTest(data, labels, ...
                modelOptions.hyperparameters.windowSize.value, ...
                'reconstructive', modelOptions.dataType);
        else
            XTest = cell2mat(data);
            YTest = XTest;
            labelsTest = cell2mat(labels);
        end
end
end


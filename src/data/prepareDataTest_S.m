function [XTest, YTest, labelsTest] = prepareDataTest_S(options, data, labels)
%PREPAREDATATEST_S
%
% Prepares the testing data for statistical models

switch options.model
    case 'Your model'
    otherwise
        if options.useSubsequences
            [XTest, YTest, labelsTest] = splitDataTest(data, labels, ...
                options.hyperparameters.windowSize.value, ...
                'reconstructive', options.dataType);
        else
            XTest = cell2mat(data);
            YTest = XTest;
            labelsTest = cell2mat(labels);
        end
end
end


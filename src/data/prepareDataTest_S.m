function [XTest, YTest, labels] = prepareDataTest_S(options, testingData, testingLabels)
%PREPAREDATATEST_S
%
% Prepares the testing data for statistical models

switch options.model
    case 'Your model'
    otherwise
        [XTest, ~, labels] = splitDataTest(testingData, testingLabels, ...
            options.hyperparameters.data.windowSize.value, ...
            'Predictive', 1);
        XTest = cell2mat(XTest);
        YTest = XTest(:, end);
end
end

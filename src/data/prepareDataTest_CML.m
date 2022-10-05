function [XTest, YTest, labels] = prepareDataTest_CML(options, testingData, testingLabels)
%PREPAREDATATEST_CML
%
% Prepares the testing data for classic ML models

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

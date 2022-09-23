function [XTest, YTest, labels] = prepareDataTest_S(options, testingData, testingLabels)
% PREPAREDATATEST_S % prepare S data for testing
%
% Description: prepare data for testing Statistical models
%
% Input:  options: struct of model options
%         testingData: data
%         testingLabels: labels
%
% Output: XTest: prepared data for testing
%         labels: labels for testing

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

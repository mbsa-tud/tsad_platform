function [XTest, labels] = prepareDataTest_S(options, testingData, testingLabels)
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
        XTest = cell2mat(testingData);
        labels = cell2mat(testingLabels);
end
end

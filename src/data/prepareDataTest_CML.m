function [XTest, labels] = prepareDataTest_CML(options, testingData, testingLabels)
% PREPAREDATATEST_CML % prepare CML data for testing
%
% Description: prepare data for testing Machine Learning models
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

function [XTest, YTest, labels] = prepareDataTest_DNN(options, testingData, testingLabels)
% PREPAREDATATEST_DNN % prepare DNN data for testing
%
% Description: prepare data for testing Deep Learning models
%
% Input:  options: struct of model options
%         testingData: data
%         testingLabels: labels
%
% Output: XTest: prepared data for testing
%         YTest: YTest for testing
%         labels: labels for testing

switch options.model
    case 'Your model'
    otherwise
        [XTest, YTest, labels] = splitDataTest(testingData, testingLabels, ...
            options.hyperparameters.data.windowSize.value, options.modelType, options.dataType);
end
end

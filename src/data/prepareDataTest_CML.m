function [XTest, YTest, labels] = prepareDataTest_CML(options, testingData, testingLabels)
%PREPAREDATATEST_CML
%
% Prepares the testing data for classic ML models

switch options.model
    case 'Your model'        
    otherwise
        [XTest, YTest, labels] = splitDataTest(testingData, testingLabels, ...
            options.hyperparameters.data.windowSize.value, ...
            'Predictive', 1, options.isMultivariate);
        
        for i = 1:size(XTest{1, 1}, 1)
            XTest{1, 1}{i, 1} = reshape(XTest{1, 1}{i, 1}', [1, options.hyperparameters.data.windowSize.value * size(testingData{1, 1}, 2)]);
        end
        
        XTest = cell2mat(XTest{1, 1});
        YTest = cell2mat(YTest);
end
end

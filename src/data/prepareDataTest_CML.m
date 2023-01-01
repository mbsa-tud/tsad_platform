function [XTest, YTest, labels] = prepareDataTest_CML(options, dataTest, labelsTest)
%PREPAREDATATEST_CML
%
% Prepares the testing data for classic ML models

switch options.model
    case 'Your model'
    case 'Merlin'
        XTest = cell2mat(dataTest);
        YTest = XTest;
        labels = cell2mat(labelsTest);
    otherwise
        [XTest, YTest, labels] = splitDataTest(dataTest, labelsTest, ...
            options.hyperparameters.data.windowSize.value, ...
            'reconstructive', 1, options.isMultivariate);
        
        XTest = XTest{1, 1};
end
end

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
            'reconstructive', 2, options.isMultivariate);
        
        for i = 1:size(XTest{1, 1}, 1)
            XTest{1, 1}{i, 1} = reshape(XTest{1, 1}{i, 1}', [1, options.hyperparameters.data.windowSize.value * size(dataTest{1, 1}, 2)]);
        end
        
        XTest = cell2mat(XTest{1, 1});
        YTest = cell2mat(YTest);
end
end

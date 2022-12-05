function [XTest, YTest, labels] = prepareDataTest_S(options, dataTest, labelsTest)
%PREPAREDATATEST_S
%
% Prepares the testing data for statistical models

switch options.model
    case 'Your model'
    otherwise
        [XTest, YTest, labels] = splitDataTest(dataTest, labelsTest, ...
            options.hyperparameters.data.windowSize.value, ...
            'reconstructive', 1, options.isMultivariate);
        
        for i = 1:size(XTest{1, 1}, 1)
            XTest{1, 1}{i, 1} = reshape(XTest{1, 1}{i, 1}', [1, options.hyperparameters.data.windowSize.value * size(dataTest{1, 1}, 2)]);
        end
        
        XTest = cell2mat(XTest{1, 1});
        YTest = cell2mat(YTest);
end
end

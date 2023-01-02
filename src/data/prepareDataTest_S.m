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
    end
end

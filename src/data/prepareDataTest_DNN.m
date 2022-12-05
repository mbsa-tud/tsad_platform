function [XTest, YTest, labels] = prepareDataTest_DNN(options, dataTest, labelsTest)
%PREPAREDATATEST_DNN
%
% Prepares the testing data for DL models

switch options.model
    case 'Your model'
    otherwise
        [XTest, YTest, labels] = splitDataTest(dataTest, labelsTest, ...
            options.hyperparameters.data.windowSize.value, options.modelType, ...
            options.dataType, options.isMultivariate);
end
end

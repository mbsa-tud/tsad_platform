function [XTest, YTest, labels] = prepareDataTest_DNN(options, testingData, testingLabels)
%PREPAREDATATEST_DNN
%
% Prepares the testing data for DL models

switch options.model
    case 'Your model'
    otherwise
        [XTest, YTest, labels] = splitDataTest(testingData, testingLabels, ...
            options.hyperparameters.data.windowSize.value, options.modelType, options.dataType);
end
end

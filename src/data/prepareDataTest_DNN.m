function [XTest, YTest, labelsTest] = prepareDataTest_DNN(options, data, labels)
%PREPAREDATATEST_DNN
%
% Prepares the testing data for DL models

switch options.model
    case 'Your model'
    otherwise
        [XTest, YTest, labelsTest] = splitDataTest(data, labels, ...
            options.hyperparameters.data.windowSize.value, options.modelType, ...
            options.dataType);
end
end

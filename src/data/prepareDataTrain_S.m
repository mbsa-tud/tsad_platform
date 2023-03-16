function [XTrain, YTrain] = prepareDataTrain_S(modelOptions, data, labels)
%PREPAREDATATRAIN_S Prepares the training data for statistical models

switch modelOptions.name
    case 'Your model name'
    otherwise
        YTrain = [];
        
        if modelOptions.useSubsequences
            [XTrain, ~, ~, ~] = splitDataTrain(data, ...
                modelOptions.hyperparameters.windowSize.value,  ...
                modelOptions.hyperparameters.stepSize.value,  ...
                0, 'reconstructive', modelOptions.dataType);
        else
            XTrain = cell2mat(data);
        end
end
end

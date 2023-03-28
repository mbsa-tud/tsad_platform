function [XTrain, YTrain] = prepareDataTrain_Other(modelOptions, data, labels)
%PREPAREDATATRAIN_CML Prepares the training data for classic ML models

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

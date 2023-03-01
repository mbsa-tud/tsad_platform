function [XTrain, YTrain] = prepareDataTrain_CML(options, data, labels)
%PREPAREDATATRAIN_CML
%
% Prepares the training data for classic ML models

switch options.model
    case 'Your model'
    otherwise
        YTrain = [];
        
        if options.useSubsequences
            [XTrain, ~, ~, ~] = splitDataTrain(data, ...
                options.hyperparameters.windowSize.value,  ...
                options.hyperparameters.stepSize.value,  ...
                0, 'reconstructive', options.dataType);
        else
            XTrain = cell2mat(data);
        end
end
end

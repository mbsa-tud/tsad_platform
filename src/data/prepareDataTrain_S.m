function [XTrain, YTrain] = prepareDataTrain_S(options, data, labels)
%PREPAREDATATRAIN_S
%
% Prepares the training data for statistical models

switch options.model
    case 'Your model'
    otherwise
        YTrain = [];
        
        if options.useSubsequences
            [XTrain, ~, ~, ~] = splitDataTrain(data, ...
                options.hyperparameters.data.windowSize.value,  ...
                options.hyperparameters.data.stepSize.value,  ...
                0, 'reconstructive', options.dataType);
        else
            XTrain = cell2mat(data);
        end
end
end

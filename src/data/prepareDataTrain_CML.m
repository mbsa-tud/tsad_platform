function XTrain = prepareDataTrain_CML(options, dataTrain)
%PREPAREDATATRAIN_CML
%
% Prepares the training data for classic ML models

switch options.model
    case 'Your model'
    otherwise
        if options.useSubsequences
            [XTrain, ~, ~, ~] = splitDataTrain(dataTrain, ...
                options.hyperparameters.data.windowSize.value,  ...
                options.hyperparameters.data.stepSize.value, ...
                1, 'reconstructive', options.dataType, options.isMultivariate);
        else
            if options.isMultivariate
                XTrain = dataTrain;
            else
                numChannels = size(dataTrain{1, 1}, 2);
                XTrain = cell(1, numChannels);
                for i = 1:numChannels
                    XTrain{1, i} = dataTrain{1, 1}(:, i);
                end
            end
        end
end
end

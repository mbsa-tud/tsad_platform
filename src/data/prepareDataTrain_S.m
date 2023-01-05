function XTrain = prepareDataTrain_S(options, dataTrain)
%PREPAREDATATRAIN_S
%
% Prepares the training data for statistical models

switch options.model
    case 'Your model'
    otherwise
        [XTrain, ~, ~, ~] = splitDataTrain(dataTrain, ...
            options.hyperparameters.data.windowSize.value,  ...
            options.hyperparameters.data.stepSize.value, ...
            1, 'reconstructive', options.dataType, options.isMultivariate);
end
end

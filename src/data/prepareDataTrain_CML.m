function XTrain = prepareDataTrain_CML(options, dataTrain)
%PREPAREDATATRAIN_CML
%
% Prepares the training data for classic ML models

switch options.model
    case 'Your model'
    otherwise
        [XTrain, ~, ~, ~] = splitDataTrain(dataTrain, ...
            options.hyperparameters.data.windowSize.value,  ...
            options.hyperparameters.data.stepSize.value, ...
            1, 'reconstructive', options.dataType, options.isMultivariate);
end
end

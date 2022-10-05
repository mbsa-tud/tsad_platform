function XTrain = prepareDataTrain_S(options, trainingData)
%PREPAREDATATRAIN_S
%
% Prepares the training data for statistical models

switch options.model
    case 'Your model'
    otherwise
        [XTrain, ~, ~, ~] = splitDataTrain(trainingData, ...
            options.hyperparameters.data.windowSize.value,  ...
            options.hyperparameters.data.stepSize.value, ...
            1, 'Reconstructive', 1);
        XTrain = cell2mat(XTrain);
end
end

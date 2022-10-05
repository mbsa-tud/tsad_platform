function XTrain = prepareDataTrain_CML(options, trainingData)
%PREPAREDATATRAIN_CML
%
% Prepares the training data for classic ML models

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

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
            1, 'Reconstructive', 1, options.isMultivariate);
        
        for i = 1:size(XTrain{1, 1}, 1)
            XTrain{1, 1}{i, 1} = reshape(XTrain{1, 1}{i, 1}', [1, options.hyperparameters.data.windowSize.value * size(trainingData{1, 1}, 2)]);
        end
        
        XTrain = cell2mat(XTrain{1, 1});
end
end

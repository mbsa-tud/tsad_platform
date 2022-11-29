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
            1, 'Predictive', 2, options.isMultivariate);
        
        for i = 1:size(XTrain{1, 1}, 1)
            XTrain{1, 1}{i, 1} = reshape(XTrain{1, 1}{i, 1}', [1, options.hyperparameters.data.windowSize.value * size(trainingData{1, 1}, 2)]);
        end
        
        XTrain = cell2mat(XTrain{1, 1});
end
end

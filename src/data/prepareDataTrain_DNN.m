function [XTrain, YTrain, XVal, YVal] = prepareDataTrain_DNN(options, trainingData, trainingLabels)
%PREPAREDATATRAIN_DNN
%
% Prepares the training data for DL models

switch options.model
    case 'Your model'
    otherwise
        [XTrain, YTrain, XVal, YVal] = splitDataTrain(trainingData, ...
            options.hyperparameters.data.windowSize.value, ...
            options.hyperparameters.data.stepSize.value, ...
            options.hyperparameters.training.ratioTrainVal.value, ...
            options.modelType, options.dataType, options.isMultivariate);
end
end

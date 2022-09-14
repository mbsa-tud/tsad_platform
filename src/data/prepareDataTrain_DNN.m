function [XTrain, YTrain, XVal, YVal] = prepareDataTrain_DNN(options, trainingData, trainingLabels)
% PREPAREDATATRAIN_DNN % prepare DNN data for training
%
% Description: prepare data for training Deep Learning models
%
% Input:  options: struct of model options
%         trainingData: data
%         trainingLabels: labels
%
% Output: XTrain: prepared XTrain for training
%         YTrain: prepared YTrain for training
%         XVal: prepared XVal for training
%         YVal: prepared YVal for training

switch options.model
    case 'Your model'
    otherwise
        [XTrain, YTrain, XVal, YVal] = splitDataTrain(trainingData, ...
            options.hyperparameters.data.windowSize.value, ...
            options.hyperparameters.data.stepSize.value, ...
            options.hyperparameters.training.ratioTrainVal.value, ...
            options.modelType, ...
            options.dataType);
end
end

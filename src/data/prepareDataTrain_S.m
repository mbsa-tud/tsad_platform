function [XTrain, XVal] = prepareDataTrain_S(options, trainingData)
% PREPAREDATATRAIN_S % prepare S data for training
%
% Description: prepare data for training Statistical models
%
% Input:  options: struct of model options
%         trainingData: data
%
% Output: XTrain: prepared data for training

switch options.model
    case 'Your model'
    otherwise
        XTrain = cell2mat(trainingData);
        XVal = [];
        if options.hyperparameters.training.ratioTrainVal.value ~= 1
            splitPoint = floor(options.hyperparameters.training.ratioTrainVal.value * size(XTrain, 1));
            XVal = XTrain((splitPoint + 1):end, :);
            XTrain = XTrain(1:splitPoint, :);
        end
end
end

function XTrain = prepareDataTrain_CML(options, trainingData)
% PREPAREDATATRAIN_CML % prepare CML data for training
%
% Description: prepare data for training Machine Learning models
%
% Input:  options: struct of model options
%         trainingData: data
%
% Output: XTrain: prepared data for training

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

function XTrain = prepareDataTrain_S(options, trainingData)
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
end
end

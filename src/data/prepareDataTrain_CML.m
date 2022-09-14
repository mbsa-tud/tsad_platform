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
        XTrain = cell2mat(trainingData);
end
end

function [XTrain, YTrain, XVal, YVal] = prepareDataTrain(modelOptions, data, labels)
%PREPAREDATATRAIN Prepars the training data according to the selected model

XTrain = [];
YTrain = [];
XVal = [];
YVal = [];

switch modelOptions.name
    case "Your model name"
    otherwise
        if strcmp(modelOptions.type, "deep-learning")
            [XTrain, YTrain, XVal, YVal] = splitDataTrain(data, ...
                modelOptions.hyperparameters.windowSize, ...
                modelOptions.hyperparameters.stepSize,  ...
                modelOptions.hyperparameters.ratioTrainVal, ...
                modelOptions.modelType, modelOptions.dataType);
        else        
            if modelOptions.useSlidingWindow
                [XTrain, ~, ~, ~] = splitDataTrain(data, ...
                    modelOptions.hyperparameters.windowSize,  ...
                    modelOptions.hyperparameters.stepSize,  ...
                    0, "reconstructive", modelOptions.dataType);
            else
                XTrain = cell2mat(data);
            end
        end
end
end
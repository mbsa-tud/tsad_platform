function trainedModels = trainingWrapper(models, dataTrain, labelsTrain, dataTestVal, labelsTestVal, thresholds, trainingPlots, parallelEnabled)
%TRAINMODELS Main wrapper function for training models and calculating static thresholds

trainedModelsCell = cell(numel(models), 1);
if parallelEnabled
    parfor model_idx = 1:numel(models)
        trainedModelsCell{model_idx} = trainModel(models(model_idx).modelOptions, dataTrain, labelsTrain, dataTestVal, labelsTestVal, thresholds, trainingPlots, false);
    end
else
    for model_idx = 1:numel(models)
        trainedModelsCell{model_idx} = trainModel(models(model_idx).modelOptions, dataTrain, labelsTrain, dataTestVal, labelsTestVal, thresholds, trainingPlots, true);
    end
end

for model_idx = 1:numel(models)
    trainedModels.(trainedModelsCell{model_idx}.modelOptions.id) = trainedModelsCell{model_idx};
end

% Delete parallel pool
if ~isempty(gcp("nocreate"))
    delete(gcp("nocreate"));
end
end
function trainedModels = trainingWrapper(models, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds, trainingPlots, parallelEnabled)
%TRAINMODELS Main wrapper function for training models and calculating static thresholds

tic
trainedModelsCell = cell(length(models), 1);
if parallelEnabled
    parfor model_idx = 1:length(models)
        trainedModelsCell{model_idx, 1} = trainModel(models(model_idx).modelOptions, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds, trainingPlots);
    end
    delete(gcp('nocreate'));
else
    parfor model_idx = 1:length(models)
        trainedModelsCell{model_idx, 1} = trainModel(models(model_idx).modelOptions, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds, trainingPlots);
    end
end

for model_idx = 1:length(models)
    trainedModels.(trainedModelsCell{model_idx, 1}.modelOptions.id) = trainedModelsCell{model_idx, 1};
end
toc
end
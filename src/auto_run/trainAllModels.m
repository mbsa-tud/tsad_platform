function trainedModels = trainAllModels(models, dataTrain, labelsTrain, dataTestVal, labelsTestVal, thresholds, trainingPlots, parallelEnabled)
%TRAINALLMODELS Trains all selected models

numChannels = size(dataTrain{1, 1}, 2);

% Training DNN models
if ~isempty(models)
    fprintf('\nTraining models\n\n');
    trainedModels_tmp = trainingWrapper(models, ...
                                    dataTrain, ...
                                    labelsTrain, ...
                                    dataTestVal, ...
                                    labelsTestVal, ...
                                    thresholds, ...
                                    trainingPlots, ...
                                    parallelEnabled);

    trainedModelIds = fieldnames(trainedModels_tmp);
    for model_idx = 1:length(trainedModelIds)
        trainedModels.(trainedModelIds{model_idx}) = trainedModels_tmp.(trainedModelIds{model_idx});
    end
else
    error("No models found for training");
end
end
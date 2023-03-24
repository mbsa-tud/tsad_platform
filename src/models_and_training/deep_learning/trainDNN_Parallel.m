function [Mdl, MdlInfo] = trainDNN_Parallel(models, XTrainCell, YTrainCell, XValCell, YValCell, trainingPlots, closeOnFinished)
%TRAINDNN_PARALLEL Trains DNN models parallel

numModels = length(models);

if ~isempty(gcp('nocreate'))
    delete(gcp('nocreate'));
end

parpool

if strcmp(trainingPlots, 'training-progress')
    dataqueue = parallel.pool.DataQueue;
else
    dataqueue = [];
end

layersCell = cell(1, numModels);
trainOptionsCell = cell(1, numModels);
modelLabels = strings(1, numModels);

for model_idx = 1:numModels
    modelOptions = models(model_idx).modelOptions;
    modelLabels(model_idx) = modelOptions.label;

    XTrain = XTrainCell{model_idx};
    YTrain = YTrainCell{model_idx};
    XVal = XValCell{model_idx};
    YVal = YValCell{model_idx};
    
    [numFeatures, numResponses] = getNumFeaturesAndResponses(XTrain, YTrain, modelOptions.modelType, modelOptions.dataType);

    layersCell{model_idx} = getLayers(modelOptions, numFeatures, numResponses);
    trainOptionsCell{model_idx} = getTrainOptionsForParallel(modelOptions, XVal, YVal, size(XTrain, 1), dataqueue, model_idx, trainingPlots);
end

if strcmp(trainingPlots, 'training-progress')
    [f, handles] = preparePlots(modelLabels);
    afterEach(dataqueue, @(data) updatePlots(handles, data));
end

trainingFuture(1:numel(layersCell)) = parallel.FevalFuture;

for model_idx = 1:numel(layersCell)
    trainingFuture(model_idx) = parfeval(@trainNetwork, 2, XTrainCell{model_idx}, YTrainCell{model_idx}, layersCell{model_idx}, trainOptionsCell{model_idx});
end

[Mdl, MdlInfo] = fetchOutputs(trainingFuture, 'UniformOutput', false);

delete(gcp('nocreate'));

if strcmp(trainingPlots, 'training-progress')
    if closeOnFinished
        close(f);
    end
end
end

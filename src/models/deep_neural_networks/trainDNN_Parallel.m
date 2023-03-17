function [Mdl, MdlInfo] = trainDNN_Parallel(models, XTrainCell, YTrainCell, XValCell, YValCell, trainingPlots, closeOnFinished)
%TRAINDNN_PARALLEL Trains DNN models parallel

numNetworks = length(models);

if ~isempty(gcp('nocreate'))
    delete(gcp('nocreate'));
end

parpool

if strcmp(trainingPlots, 'training-progress')
    dataqueue = parallel.pool.DataQueue;
else
    dataqueue = [];
end

layersCell = cell(1, numNetworks);
trainOptionsCell = cell(1, numNetworks);
modelLabels = strings(1, numNetworks);

for i = 1:numNetworks
    modelOptions = models(i).modelOptions;
    modelLabels(i) = modelOptions.label;

    XTrain = XTrainCell{i};
    YTrain = YTrainCell{i};
    XVal = XValCell{i};
    YVal = YValCell{i};
    
    [numFeatures, numResponses] = getNumFeaturesAndResponses(XTrain, YTrain, modelOptions.modelType, modelOptions.dataType);

    layersCell{i} = getLayers(modelOptions, numFeatures, numResponses);
    trainOptionsCell{i} = getTrainOptionsForParallel(modelOptions, XVal, YVal, size(XTrain, 1), dataqueue, i, trainingPlots);
end

if strcmp(trainingPlots, 'training-progress')
    [f, handles] = preparePlots(modelLabels);
    afterEach(dataqueue, @(data) updatePlots(handles, data));
end

trainingFuture(1:numel(layersCell)) = parallel.FevalFuture;

for i=1:numel(layersCell)
    trainingFuture(i) = parfeval(@trainNetwork, 2, XTrainCell{i}, YTrainCell{i}, layersCell{i}, trainOptionsCell{i});
end

[Mdl, MdlInfo] = fetchOutputs(trainingFuture, 'UniformOutput', false);

delete(gcp('nocreate'));

if strcmp(trainingPlots, 'training-progress')
    if closeOnFinished
        close(f);
    end
end
end

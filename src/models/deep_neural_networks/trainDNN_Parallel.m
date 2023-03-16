function [Mdl, MdlInfo] = trainDNN_Parallel(models, XTrainCell, YTrainCell, XValCell, YValCell, closeOnFinished)
%TRAINDNN_PARALLEL Trains DNN models parallel

numNetworks = length(models);

if ~isempty(gcp('nocreate'))
    delete(gcp('nocreate'));
end

parpool

dataqueue = parallel.pool.DataQueue;

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
    trainOptionsCell{i} = getTrainOptionsForParallel(modelOptions, XVal, YVal, size(XTrain, 1), dataqueue, i);
end

[f, handles] = preparePlots(modelLabels);
afterEach(dataqueue, @(data) updatePlots(handles, data));

trainingFuture(1:numel(layersCell)) = parallel.FevalFuture;

for i=1:numel(layersCell)
    trainingFuture(i) = parfeval(@trainNetwork, 2, XTrainCell{i}, YTrainCell{i}, layersCell{i}, trainOptionsCell{i});
end

[Mdl_tmp, MdlInfo_tmp] = fetchOutputs(trainingFuture, 'UniformOutput', false);

% Rearrange into cell array
Mdl = cell(numNetworks, 1);
MdlInfo = cell(numNetworks, 1);
for i = 1:numNetworks
    Mdl{i, 1} = Mdl_tmp(i);
    MdlInfo{i, 1} = MdlInfo_tmp(i);
end


delete(gcp('nocreate'));

if closeOnFinished
    close(f);
end
end

function [Mdls, MdlInfos] = trainDNN_Parallel(models, XTrainCell, YTrainCell, XValCell, YValCell, closeOnFinished)
%TRAINDNN_PARALLEL
%
% Train DL models in parallel

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
    options = models(i).options;
    modelLabels(i) = options.label;

    XTrain = XTrainCell{i};
    YTrain = YTrainCell{i};
    XVal = XValCell{i};
    YVal = YValCell{i};
    
    if options.dataType == 1
        numResponses = size(YTrain, 2);
    else
        if strcmp(options.modelType, 'Reconstructive')
            numResponses = size(YTrain{1, 1}, 1);
        else
            numResponses = 1;
        end
    end

    if options.dataType == 1
        numFeatures = size(XTrain, 2);
    else
        numFeatures = size(XTrain{1, 1}, 1);
    end
    layersCell{i} = getLayers(options, numFeatures, numResponses);
    trainOptionsCell{i} = getOptionsForParallel(options, XVal, YVal, size(XTrain, 1), dataqueue, i);
end

[f, handles] = preparePlots(modelLabels);
afterEach(dataqueue, @(data) updatePlots(handles, data));

trainingFuture(1:numel(layersCell)) = parallel.FevalFuture;

for i=1:numel(layersCell)
    trainingFuture(i) = parfeval(@trainNetwork, 2, XTrainCell{i}, YTrainCell{i}, layersCell{i}, trainOptionsCell{i});
end

[Mdls, MdlInfos] = fetchOutputs(trainingFuture, 'UniformOutput', false);

delete(gcp('nocreate'));

if closeOnFinished
    close(f);
end
end

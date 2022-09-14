function trainedModels = trainModels_DNN_Parallel(models, trainingData, trainingLabels, testValData, testValLabels, thresholds, closeOnFinished)
numNetworks = length(models);

XTrainCell = cell(1, numNetworks);
YTrainCell = cell(1, numNetworks);
XValCell = cell(1, numNetworks);
YValCell = cell(1, numNetworks);

for i = 1:numNetworks
    options = models(i).options;

    [XTrain, YTrain, XVal, YVal] = prepareDataTrain_DNN(options, trainingData, trainingLabels);

    XTrainCell{i} = XTrain{1};
    YTrainCell{i} = YTrain{1};
    XValCell{i} = XVal{1};
    YValCell{i} = YVal{1};
end

[Mdls, MdlInfos] = trainDNN_Parallel(models, XTrainCell, YTrainCell, XValCell, YValCell, closeOnFinished);

for i = 1:numel(models)
    options = models(i).options;
    staticThreshold = getStaticThreshold_DNN(options, Mdls{i}, XTrainCell(i), YTrainCell(i), XValCell(i), YValCell(i), testValData, testValLabels, thresholds);

    trainedNetwork.Mdl = Mdls{i};
    trainedNetwork.MdlInfo = MdlInfos{i};
    trainedNetwork.options = options;
    trainedNetwork.staticThreshold = staticThreshold;

    trainedModels.(options.id) = trainedNetwork;
end
end                              

function trainedModels = trainModels_DNN_Parallel(models, dataTrain, labelsTrain, dataValTest, labelsValTest, ratioValTest, thresholds, scoringFunction, closeOnFinished)
%TRAINMODELS_DNN_PARALLEL
%
% Trains all DL models in parallel and calculates the thresholds

numNetworks = length(models);

XTrainCell = cell(1, numNetworks);
YTrainCell = cell(1, numNetworks);
XValCell = cell(1, numNetworks);
YValCell = cell(1, numNetworks);

for i = 1:numNetworks
    options = models(i).options;

    switch options.learningType
        case 'unsupervised'
        case 'semisupervised'
            if ratioValTest == 1
                models(i).options.calcThresholdLast = true;
            else
                models(i).options.calcThresholdLast = false;
            end

            [XTrain, YTrain, XVal, YVal] = prepareDataTrain_DNN(options, dataTrain, labelsTrain);
        case 'supervised'
    end

    XTrainCell{i} = XTrain{1};
    YTrainCell{i} = YTrain{1};
    XValCell{i} = XVal{1};
    YValCell{i} = YVal{1};
end

[Mdls, MdlInfos] = trainDNN_Parallel(models, XTrainCell, YTrainCell, XValCell, YValCell, closeOnFinished);

for i = 1:numel(models)
    options = models(i).options;

    switch options.learningType
        case 'unsupervised'
        case 'semisupervised'
            if XVal
                YValCell(i) = convertYForTesting(YValCell(i), options.modelType);
                pd = getProbDist(options, Mdl, XValCell(i), YValCell(i));
            else
                pd = getProbDist(options, Mdl, XTrainCell(i), YTrainCell(i));
            end

            if ~options.calcThresholdLast
                staticThreshold = getStaticThreshold_DNN(options, Mdls{i}, XTrainCell(i), YTrainCell(i), XValCell(i), YValCell(i), dataValTest, labelsValTest, thresholds, scoringFunction, pd);
            else
                staticThreshold = [];
            end
        case 'supervised'
    end


    trainedNetwork.Mdl = Mdls{i};
    trainedNetwork.MdlInfo = MdlInfos{i};
    trainedNetwork.options = options;
    trainedNetwork.staticThreshold = staticThreshold;

    trainedModels.(options.id) = trainedNetwork;
end
end                              

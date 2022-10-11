function trainedModels = trainModels_DNN_Consecutive(models, trainingData, trainingLabels, testValData, testValLabels, thresholds)
%TRAINMODELS_DNN_CONSECUTIVE
%
% Trains all DL models consecutively and calculates the thresholds

for i = 1:length(models)
    options = models(i).options;
    
    if ~options.trainOnAnomalousData
        [XTrain, YTrain, XVal, YVal] = prepareDataTrain_DNN(options, trainingData, trainingLabels);
    else
        [XTrain, YTrain, XVal, YVal] = prepareDataTrain_DNN(options, testValData, testValLabels);
    end

    [Mdl, MdlInfo] = trainDNN(options, XTrain, YTrain, XVal, YVal, 'training-progress');

    if ~options.calcThresholdLast
        staticThreshold = getStaticThreshold_DNN(options, Mdl, XTrain, YTrain, XVal, YVal, testValData, testValLabels, thresholds);
    else
        staticThreshold = [];
    end
    
    trainedNetwork.Mdl = Mdl;
    trainedNetwork.MdlInfo = MdlInfo;
    trainedNetwork.options = options;
    trainedNetwork.staticThreshold = staticThreshold;

    trainedModels.(options.id) = trainedNetwork;
end
end
function trainedModels = trainModels_DNN_Consecutive(models, trainingData, trainingLabels, testValData, testValLabels, thresholds)
for i = 1:length(models)
    options = models(i).options;

    [XTrain, YTrain, XVal, YVal] = prepareDataTrain_DNN(options, trainingData, trainingLabels);

    [Mdl, MdlInfo] = trainDNN(options, XTrain, YTrain, XVal, YVal, 'training-progress');
    [staticThreshold, pd] = getStaticThreshold_DNN(options, Mdl, XTrain, YTrain, XVal, YVal, testValData, testValLabels, thresholds);
    
    trainedNetwork.Mdl = Mdl;
    trainedNetwork.MdlInfo = MdlInfo;
    trainedNetwork.options = options;
    trainedNetwork.staticThreshold = staticThreshold;
    trainedNetwork.pd = pd;

    trainedModels.(options.id) = trainedNetwork;
end
end
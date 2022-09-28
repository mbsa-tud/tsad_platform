function trainedModels_S = trainModels_S(models, trainingData, testValData, testValLabels, thresholds)
for i = 1:length(models)
    options = models(i).options;

    if ~options.trainOnAnomalousData
        XTrain = prepareDataTrain_S(options, trainingData);
    else
        XTrain = prepareDataTrain_S(options, testValData);
    end

    Mdl = trainS(options, XTrain);

    [staticThreshold, pd] = getStaticThreshold_S(options, Mdl, XTrain, testValData, testValLabels, thresholds);

    trainedModel.staticThreshold = staticThreshold;
    trainedModel.options = options;
    trainedModel.Mdl = Mdl;    
    trainedModel.pd = pd;
    
    trainedModels_S.(models(i).options.id) = trainedModel;
end
end

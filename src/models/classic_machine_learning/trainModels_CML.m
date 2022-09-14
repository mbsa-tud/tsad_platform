function trainedModels_CML = trainModels_CML(models, trainingData, testValData, testValLabels, thresholds)
for i = 1:length(models)    
    options = models(i).options;
    
    XTrain = prepareDataTrain_CML(options, trainingData);

    Mdl = trainCML(options, XTrain);

    staticThreshold = getStaticThreshold_CML(options, Mdl, XTrain, testValData, testValLabels, thresholds);

    trainedModel.staticThreshold = staticThreshold;        
    trainedModel.options = options;
    trainedModel.Mdl = Mdl;

    trainedModels_CML.(models(i).options.id) = trainedModel;
end
end

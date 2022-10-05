function trainedModels_CML = trainModels_CML(models, trainingData, testValData, testValLabels, thresholds)
%TRAINMODELS_CML
%
% Trains the classic ML models and calculates the static thresholds

for i = 1:length(models)    
    options = models(i).options;

    if ~options.trainOnAnomalousData
        XTrain = prepareDataTrain_CML(options, trainingData);
    else
        XTrain = prepareDataTrain_CML(options, testValData);
    end
    
    Mdl = trainCML(options, XTrain);

    [staticThreshold, pd] = getStaticThreshold_CML(options, Mdl, XTrain, testValData, testValLabels, thresholds);

    trainedModel.staticThreshold = staticThreshold;        
    trainedModel.options = options;
    trainedModel.Mdl = Mdl;
    trainedModel.pd = pd;

    trainedModels_CML.(models(i).options.id) = trainedModel;
end
end

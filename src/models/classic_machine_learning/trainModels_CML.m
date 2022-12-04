function trainedModels_CML = trainModels_CML(models, dataTrain, dataValTest, labelsValTest, ratioValTest, thresholds)
%TRAINMODELS_CML
%
% Trains the classic ML models and calculates the static thresholds

for i = 1:length(models)
    options = models(i).options;
    
    switch options.requiresPriorTraining
        case true
            if ratioValTest == 1
                options.calcThresholdLast = true;
            else
                options.calcThresholdLast = false;
            end
    
            XTrain = prepareDataTrain_CML(options, dataTrain);
            Mdl = trainCML(options, XTrain);
            if ~options.calcThresholdLast
                staticThreshold = getStaticThreshold_CML(options, Mdl, XTrain, dataValTest, labelsValTest, thresholds);
            else
                staticThreshold = [];
            end
        case false
            options.calcThresholdLast = true;
            Mdl = [];
            staticThreshold = [];
    end
         
    trainedModel.options = options;
    trainedModel.Mdl = Mdl;
    trainedModel.staticThreshold = staticThreshold;

    trainedModels_CML.(models(i).options.id) = trainedModel;
end
end

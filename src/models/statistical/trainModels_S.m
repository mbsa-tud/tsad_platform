function trainedModels_S = trainModels_S(models, dataTrain, dataValTest, labelsValTest, ratioValTest, thresholds)
%TRAINMODELS_S
%
% Trains all statistical models and calculates the thresholds

for i = 1:length(models)
    options = models(i).options;

    switch options.requiresPriorTraining
        case true
            if ratioValTest == 1
                options.calcThresholdLast = true;
            else
                options.calcThresholdLast = false;
            end
    
            XTrain = prepareDataTrain_S(options, dataTrain);
            Mdl = trainCML(options, XTrain);
            if ~options.calcThresholdLast
                staticThreshold = getStaticThreshold_S(options, Mdl, XTrain, dataValTest, labelsValTest, thresholds);
            else
                staticThreshold = [];
            end
        case false
            options.calcThresholdLast = true;
            Mdl = [];
            staticThreshold = [];
    end

    trainedModel.staticThreshold = staticThreshold;
    trainedModel.options = options;
    trainedModel.Mdl = Mdl;    
    
    trainedModels_S.(models(i).options.id) = trainedModel;
end
end

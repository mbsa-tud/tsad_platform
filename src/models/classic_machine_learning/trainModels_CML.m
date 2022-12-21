function trainedModels_CML = trainModels_CML(models, dataTrain, dataValTest, labelsValTest, thresholds)
%TRAINMODELS_CML
%
% Trains the classic ML models and calculates the static thresholds

for i = 1:length(models)
    options = models(i).options;
    
    switch options.requiresPriorTraining
        case true
            if isempty(dataTrain)
                error("One of the selected models requires prior training, but the dataset doesn't contain training data (train folder).")
            end
            
            XTrain = prepareDataTrain_CML(options, dataTrain);
            Mdl = trainCML(options, XTrain);
            staticThreshold = getStaticThreshold_CML(options, Mdl, XTrain, dataValTest, labelsValTest, thresholds);
        case false
            Mdl = [];
            staticThreshold = [];
    end
         
    trainedModel.options = options;
    trainedModel.Mdl = Mdl;
    trainedModel.staticThreshold = staticThreshold;

    trainedModels_CML.(models(i).options.id) = trainedModel;
end
end

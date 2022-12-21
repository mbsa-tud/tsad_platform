function trainedModels_S = trainModels_S(models, dataTrain, dataValTest, labelsValTest, thresholds)
%TRAINMODELS_S
%
% Trains all statistical models and calculates the thresholds

for i = 1:length(models)
    options = models(i).options;

    switch options.requiresPriorTraining
        case true
            if isempty(dataTrain)
                error("One of the selected models requires prior training, but the dataset doesn't contain training data (train folder).")
            end
            
            XTrain = prepareDataTrain_S(options, dataTrain);
            Mdl = trainCML(options, XTrain);
            staticThreshold = getStaticThreshold_S(options, Mdl, XTrain, dataValTest, labelsValTest, thresholds);
        case false
            Mdl = [];
            staticThreshold = [];
    end

    trainedModel.staticThreshold = staticThreshold;
    trainedModel.options = options;
    trainedModel.Mdl = Mdl;    
    
    trainedModels_S.(models(i).options.id) = trainedModel;
end
end

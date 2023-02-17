function trainedModels_CML = trainModels_CML(models, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds)
%TRAINMODELS_CML
%
% Trains the classic ML models and calculates the static thresholds

for i = 1:length(models)
    options = models(i).options;
    
    if options.requiresPriorTraining
        if isempty(dataTrain)
            error("One of the selected models requires prior training, but the dataset doesn't contain training data (train folder).")
        end
        
        XTrain = prepareDataTrain_CML_wrapper(options, dataTrain, labelsTrain);
        Mdl = trainCML_wrapper(options, XTrain);

        if ~options.outputsLabels
            staticThreshold = getStaticThreshold_CML(options, Mdl, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds);
        else
            staticThreshold = [];
        end
    else
        Mdl = [];
        staticThreshold = getStaticThreshold_CML(options, Mdl, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds);
    end
         
    trainedModel.options = options;
    trainedModel.Mdl = Mdl;
    trainedModel.staticThreshold = staticThreshold;

    trainedModels_CML.(models(i).options.id) = trainedModel;
end
end

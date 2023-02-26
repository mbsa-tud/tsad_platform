function trainedModels_CML = trainModels_CML(models, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds)
%TRAINMODELS_CML
%
% Trains the classic ML models and calculates the static thresholds

for i = 1:length(models)    
    options = models(i).options;
    trainedModel.options = options;

    fprintf("Training: %s\n", options.model);

    if options.requiresPriorTraining
        if isempty(dataTrain)
            error("The %s model requires prior training, but the dataset doesn't contain training data (train folder).", options.model);
        end
        
        [XTrain, YTrain] = prepareDataTrain_CML_wrapper(options, dataTrain, labelsTrain);
        trainedModel.Mdl = trainCML_wrapper(options, XTrain, YTrain);

        if ~options.outputsLabels
            trainedModel.staticThreshold = getStaticThreshold_CML(trainedModel, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds);
        else
            trainedModel.staticThreshold = [];
        end
    else
        trainedModel.Mdl = [];
        trainedModel.staticThreshold = getStaticThreshold_CML(trainedModel, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds);
    end

    trainedModels_CML.(models(i).options.id) = trainedModel;
end
end

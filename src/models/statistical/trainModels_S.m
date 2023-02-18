function trainedModels_S = trainModels_S(models, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds)
%TRAINMODELS_S
%
% Trains all statistical models and calculates the thresholds

for i = 1:length(models)
    options = models(i).options;
    trainedModel.options = options;

    if options.requiresPriorTraining
        if isempty(dataTrain)
            error("One of the selected models requires prior training, but the dataset doesn't contain training data (train folder).")
        end
        
        XTrain = prepareDataTrain_S_wrapper(options, dataTrain, labelsTrain);
        trainedModel.Mdl = trainS_wrapper(options, XTrain);

        if ~options.outputsLabels
            trainedModel.staticThreshold = getStaticThreshold_S(trainedModel, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds);
        else
            trainedModel.staticThreshold = [];
        end
    else
        trainedModel.Mdl = [];
        trainedModel.staticThreshold = getStaticThreshold_S(trainedModel, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds);
    end

    trainedModels_S.(models(i).options.id) = trainedModel;
end
end

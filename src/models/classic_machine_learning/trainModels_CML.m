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
        
        [XTrain, YTrain] = prepareDataTrain(options, dataTrain, labelsTrain);
        trainedModel.Mdl = trainCML_wrapper(options, XTrain, YTrain);

        if ~options.outputsLabels
            XTrainTestCell = cell(size(dataTrain, 1), 1);
            YTrainTestCell = cell(size(dataTrain, 1), 1);

        
            for j = 1:size(dataTrain, 1)
                [XTrainTestCell{j, 1}, YTrainTestCell{j, 1}, ~] = prepareDataTest(options, dataTrain(j, :), labelsTrain(j, :));
            end

            [trainedModel.trainingAnomalyScoresRaw, trainedModel.trainingAnomalyScoreFeatures] = getTrainingAnomalyScoreFeatures(trainedModel, XTrainTestCell, YTrainTestCell);
            
            trainedModel.staticThreshold = getStaticThresholds(trainedModel, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds);
        end
    end

    trainedModels_CML.(models(i).options.id) = trainedModel;
end
end

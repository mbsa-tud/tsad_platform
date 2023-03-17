function trainedModels = trainModels(models, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds, trainingPlots, trainParallel)
%TRAINMODELS Main wrapper function for training models and calculating static thresholds

for i = 1:length(models)
    modelOptions = models(i).modelOptions;

    trainedModel = [];
    trainedModel.modelOptions = modelOptions;

    fprintf("Training: %s\n", modelOptions.label);

    if modelOptions.requiresPriorTraining
        if isempty(dataTrain)
            error("The %s model requires prior training, but the dataset doesn't contain training data (train folder).", modelOptions.label);
        end

        % Save dimensionality of data
        trainedModel.dimensionality = size(dataTrain{1, 1}, 2);
        
        % Train model
        switch modelOptions.type
            case 'DNN'
                [XTrain, YTrain, XVal, YVal] = prepareDataTrain(modelOptions, dataTrain, labelsTrain);
                [trainedModel.Mdl, trainedModel.MdlInfo] = trainDNN_wrapper(modelOptions, XTrain, YTrain, XVal, YVal, trainingPlots, trainParallel);
            case 'CML'
                [XTrain, YTrain] = prepareDataTrain(modelOptions, dataTrain, labelsTrain);
                trainedModel.Mdl = trainCML_wrapper(modelOptions, XTrain, YTrain);
            case 'S'
                [XTrain, YTrain] = prepareDataTrain(modelOptions, dataTrain, labelsTrain);
                trainedModel.Mdl = trainS_wrapper(modelOptions, XTrain, YTrain);
        end
        
        % Get static thresholds
        if ~modelOptions.outputsLabels
            XTrainTestCell = cell(size(dataTrain, 1), 1);
            YTrainTestCell = cell(size(dataTrain, 1), 1);
            labelsTrainTest = [];
        
            for j = 1:size(dataTrain, 1)
                [XTrainTestCell{j, 1}, YTrainTestCell{j, 1}, labelsTrainTest_tmp] = prepareDataTest(modelOptions, dataTrain(j, :), labelsTrain(j, :));
                labelsTrainTest = [labelsTrainTest; labelsTrainTest_tmp];
            end
            
            trainedModel.trainingLabels = labelsTrainTest;

            [trainedModel.trainingAnomalyScoresRaw, trainedModel.trainingAnomalyScoreFeatures] = getTrainingAnomalyScoreFeatures(trainedModel, XTrainTestCell, YTrainTestCell);
            
            if isfield(modelOptions, "calcThresholdsOn")
                if strcmp(modelOptions.calcThresholdsOn, "anomalous-validation-data")
                    trainedModel.staticThresholds = getStaticThresholds(trainedModel, dataValTest, labelsValTest, thresholds, "anomalous-validation-data");
                elseif strcmp(modelOptions.calcThresholdsOn, "training-data")
                    trainedModel.staticThresholds = getStaticThresholds(trainedModel, [], [], thresholds, "training-data");
                end
            end
        end
    end

    trainedModels.(modelOptions.id) = trainedModel;
end
end
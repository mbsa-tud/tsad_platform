function trainedModels_DNN = trainModels_DNN_Consecutive(models, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds, trainingPlots, trainParallel)
%TRAINMODELS_DNN_CONSECUTIVE
%
% Trains all DL models consecutively and calculates the thresholds

for i = 1:length(models)
    options = models(i).options;
    trainedModel.options = options;

    fprintf("Training: %s\n", options.label);

    if options.requiresPriorTraining
        if isempty(dataTrain)
            error("The %s model requires prior training, but the dataset doesn't contain training data (train folder).", options.model);
        end

        % Save dimensionality of data
        trainedModel.dimensionality = size(dataTrain{1, 1}, 2);

        [XTrain, YTrain, XVal, YVal] = prepareDataTrain(options, dataTrain, labelsTrain);

        [trainedModel.Mdl, trainedModel.MdlInfo] = trainDNN_wrapper(options, XTrain, YTrain, XVal, YVal, trainingPlots, trainParallel);
        
        if ~options.outputsLabels
            XTrainTestCell = cell(size(dataTrain, 1), 1);
            YTrainTestCell = cell(size(dataTrain, 1), 1);
            labelsTrainTest = [];
        
            for j = 1:size(dataTrain, 1)
                [XTrainTestCell{j, 1}, YTrainTestCell{j, 1}, labelsTrainTest_tmp] = prepareDataTest(options, dataTrain(j, :), labelsTrain(j, :));
                labelsTrainTest = [labelsTrainTest; labelsTrainTest_tmp];
            end
            
            trainedModel.trainingLabels = labelsTrainTest;

            [trainedModel.trainingAnomalyScoresRaw, trainedModel.trainingAnomalyScoreFeatures] = getTrainingAnomalyScoreFeatures(trainedModel, XTrainTestCell, YTrainTestCell);
            
            if isfield(options, "calcThresholdsOn")
                if strcmp(options.calcThresholdsOn, "anomalous-validation-data")
                    trainedModel.staticThreshold = getStaticThresholds(trainedModel, dataValTest, labelsValTest, thresholds, "anomalous-validation-data");
                elseif strcmp(options.calcThresholdsOn, "training-data")
                    trainedModel.staticThreshold = getStaticThresholds(trainedModel, [], [], thresholds, "training-data");
                end
            end
        end
    end

    trainedModels_DNN.(options.id) = trainedModel;
end
end
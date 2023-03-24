function trainedModels_DNN = trainModels_DNN_Parallel(models, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds, trainingPlots, closeOnFinished)
%TRAINMODELS_DNN_PARALLEL Trains DNN models in parallel and calculates static
%thresholds

numModels = length(models);

% Prepare training data
XTrainCell = cell(1, numModels);
YTrainCell = cell(1, numModels);
XValCell = cell(1, numModels);
YValCell = cell(1, numModels);

for model_idx = 1:numModels
    modelOptions = models(model_idx).modelOptions;
    
    if modelOptions.requiresPriorTraining
        if isempty(dataTrain)
            error("The %s model requires prior training, but the dataset doesn't contain training data (train folder).", modelOptions.label);
        end
        
        [XTrain, YTrain, XVal, YVal] = prepareDataTrain(modelOptions, dataTrain, labelsTrain);
    else
        error("One of the selected models for parallel training doesn't require prior training.");
    end

    XTrainCell{model_idx} = XTrain{1, 1};
    YTrainCell{model_idx} = YTrain{1, 1};
    XValCell{model_idx} = XVal{1, 1};
    YValCell{model_idx} = YVal{1, 1};
end

% Train model
[Mdl, MdlInfo] = trainDNN_Parallel(models, XTrainCell, YTrainCell, XValCell, YValCell, trainingPlots, closeOnFinished);

for model_idx = 1:numel(models)
    modelOptions = models(model_idx).modelOptions;

    trainedModel = [];
    trainedModel.modelOptions = modelOptions;

    % Save dimensionality of data
    trainedModel.dimensionality = size(dataTrain{1, 1}, 2);

    trainedModel.Mdl = Mdl(model_idx);
    trainedModel.MdlInfo = MdlInfo(model_idx);
    
    % Get static thresholds
    if ~modelOptions.outputsLabels
        XTrainTestCell = cell(size(dataTrain, 1), 1);
        YTrainTestCell = cell(size(dataTrain, 1), 1);
        labelsTrainTest = [];
    
        for data_idx = 1:size(dataTrain, 1)
            [XTrainTestCell{data_idx, 1}, YTrainTestCell{data_idx, 1}, labelsTrainTest_tmp] = prepareDataTest(modelOptions, dataTrain(data_idx, :), labelsTrain(data_idx, :));
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

    trainedModels_DNN.(modelOptions.id) = trainedModel;
end
end                              

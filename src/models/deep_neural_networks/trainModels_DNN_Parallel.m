function trainedModels_DNN = trainModels_DNN_Parallel(models, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds, trainingPlots, closeOnFinished)
%TRAINMODELS_DNN_PARALLEL Trains DNN models in parallel and calculates static
%thresholds

numNetworks = length(models);

% Prepare training data
XTrainCell = cell(1, numNetworks);
YTrainCell = cell(1, numNetworks);
XValCell = cell(1, numNetworks);
YValCell = cell(1, numNetworks);

for i = 1:numNetworks
    modelOptions = models(i).modelOptions;
    
    if modelOptions.requiresPriorTraining
        if isempty(dataTrain)
            error("The %s model requires prior training, but the dataset doesn't contain training data (train folder).", modelOptions.label);
        end
        
        [XTrain, YTrain, XVal, YVal] = prepareDataTrain(modelOptions, dataTrain, labelsTrain);
    else
        error("One of the selected models for parallel training doesn't require prior training.");
    end

    XTrainCell{i} = XTrain{1, 1};
    YTrainCell{i} = YTrain{1, 1};
    XValCell{i} = XVal{1, 1};
    YValCell{i} = YVal{1, 1};
end

% Train model
[Mdl, MdlInfo] = trainDNN_Parallel(models, XTrainCell, YTrainCell, XValCell, YValCell, trainingPlots, closeOnFinished);

for i = 1:numel(models)
    modelOptions = models(i).modelOptions;

    trainedModel = [];
    trainedModel.modelOptions = modelOptions;

    % Save dimensionality of data
    trainedModel.dimensionality = size(dataTrain{1, 1}, 2);

    trainedModel.Mdl = Mdl(i);
    trainedModel.MdlInfo = MdlInfo(i);
    
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

    trainedModels_DNN.(modelOptions.id) = trainedModel;
end
end                              

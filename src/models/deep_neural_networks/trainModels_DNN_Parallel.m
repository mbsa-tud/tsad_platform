function trainedModels_DNN = trainModels_DNN_Parallel(models, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds, closeOnFinished)
%TRAINMODELS_DNN_PARALLEL
%
% Trains all DL models in parallel and calculates the thresholds

numNetworks = length(models);

XTrainCell = cell(1, numNetworks);
YTrainCell = cell(1, numNetworks);
XValCell = cell(1, numNetworks);
YValCell = cell(1, numNetworks);

for i = 1:numNetworks
    options = models(i).options;
    
    if options.requiresPriorTraining
        if isempty(dataTrain)
            error("The %s model requires prior training, but the dataset doesn't contain training data (train folder).", options.model);
        end
        
        [XTrain, YTrain, XVal, YVal] = prepareDataTrain(options, dataTrain, labelsTrain);
    else
        error("One of the selected models for parallel training doesn't require prior training.");
    end

    XTrainCell{i} = XTrain{1, 1};
    YTrainCell{i} = YTrain{1, 1};
    XValCell{i} = XVal{1, 1};
    YValCell{i} = YVal{1, 1};
end

[Mdl, MdlInfo] = trainDNN_Parallel(models, XTrainCell, YTrainCell, XValCell, YValCell, closeOnFinished);

for i = 1:numel(models)
    options = models(i).options;
    trainedModel.options = options;

    % Save dimensionality of data
    trainedModel.dimensionality = size(dataTrain{1, 1}, 2);

    trainedModel.Mdl = Mdl{i};
    trainedModel.MdlInfo = MdlInfo{i};

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

    trainedModels_DNN.(options.id) = trainedModel;
end
end                              

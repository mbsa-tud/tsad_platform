function trainedModel = trainModel(modelOptions, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds, trainingPlots, verbose)
%TRAINMODELS Main wrapper function for training models and calculating static thresholds

trainedModel = [];
trainedModel.modelOptions = modelOptions;

fprintf("Training: %s\n", modelOptions.label);

if ~strcmp(modelOptions.learningType, "unsupervised")
    if isempty(dataTrain)
        error("The %s model requires prior training, but the dataset doesn't contain training data (train folder).", modelOptions.label);
    end
    
    % Save dimensionality of data
    trainedModel.dimensionality = size(dataTrain{1, 1}, 2);
    
    % Train model
    switch modelOptions.type
        case 'deep-learning'
            [XTrain, YTrain, XVal, YVal] = prepareDataTrain(modelOptions, dataTrain, labelsTrain);
            [trainedModel.Mdl, trainedModel.MdlInfo] = trainWrapper_DL(modelOptions, XTrain, YTrain, XVal, YVal, trainingPlots, verbose);
        otherwise
            [XTrain, YTrain] = prepareDataTrain(modelOptions, dataTrain, labelsTrain);
            trainedModel.Mdl = trainWrapper_Other(modelOptions, XTrain, YTrain);
    end
    
    % Get static thresholds
    if ~modelOptions.outputsLabels
        XTrainTestCell = cell(size(dataTrain, 1), 1);
        YTrainTestCell = cell(size(dataTrain, 1), 1);
        labelsTrainTest = [];
    
        for data_idx = 1:size(dataTrain, 1)
            [XTrainTestCell{data_idx, 1}, YTrainTestCell{data_idx, 1}, labelsTrainTest_tmp] = prepareDataTest(modelOptions, dataTrain(data_idx, :), labelsTrain(data_idx, :));
            labelsTrainTest = [labelsTrainTest; labelsTrainTest_tmp];
        end
        
        % Store raw training errors and training labels in trainedModel. Required for some
        % static thresholds and scoring functions later on.
        trainedModel.trainingLabels = labelsTrainTest;
        [trainedModel.trainingAnomalyScoresRaw, trainedModel.trainingAnomalyScoreFeatures] = getTrainingAnomalyScoreFeatures(trainedModel, XTrainTestCell, YTrainTestCell);
        
        switch modelOptions.learningType
            case "semi-supervised"
                % Calc thresholds on anomalous validation set for
                % semi-supervised models
                trainedModel.staticThresholds = getStaticThresholds(trainedModel, dataValTest, labelsValTest, thresholds, "anomalous-validation-data");
            case "supervised"
                % Calc thresholds on training data for supervised models.
                % (The raw training errors are already stored in the
                % trainedModel.)
                trainedModel.staticThresholds = getStaticThresholds(trainedModel, [], [], thresholds, "training-data");
        end
    end
end
end
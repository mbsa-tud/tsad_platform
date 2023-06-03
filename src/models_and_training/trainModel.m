function trainedModel = trainModel(modelOptions, dataTrain, labelsTrain, dataTestVal, labelsTestVal, thresholds, trainingPlots, verbose)
%TRAINMODEL Function for training a model including the calculation of
%static thresholds

trainedModel = [];
trainedModel.modelOptions = modelOptions;

fprintf("Training: %s ...\n", modelOptions.label);

switch modelOptions.learningType
    case "unsupervised"
        % Do nothing as they don't need to be trained at this point
    case "semi-supervised"
        if isempty(dataTrain)
            error("The %s model requires prior training, but the dataset doesn't contain training data (train folder).", modelOptions.label);
        end
        
        % Save dimensionality of data
        trainedModel.dimensionality = size(dataTrain{1}, 2);
        
        % Train model
        [XTrain, YTrain, XVal, YVal] = dataTrainPreparationWrapper(modelOptions, dataTrain, labelsTrain);
        if strcmp(modelOptions.dimensionality, "multivariate")
            % Train single model on entire data
            Mdl = train(modelOptions, XTrain{1}, YTrain{1}, XVal{1}, YVal{1}, trainingPlots, verbose);
            trainedModel.Mdl = {Mdl};
        else
            % Train the same model for each channel seperately
            
            numChannels = numel(XTrain);
            Mdl = cell(numChannels, 1);
        
            for channel_idx = 1:numChannels
                Mdl{channel_idx} = train(modelOptions, XTrain{channel_idx}, YTrain{channel_idx}, XVal{channel_idx}, YVal{channel_idx}, trainingPlots, verbose);
            end
            trainedModel.Mdl = Mdl;
        end
        
        % Get static thresholds and training anomaly scores
        if ~modelOptions.outputsLabels
            [trainedModel.trainingAnomalyScoresRaw, ...
                trainedModel.trainingAnomalyScoreFeatures, ...
                trainedModel.trainingLabels] = getTrainingAnomalyScoreFeatures(trainedModel, dataTrain, labelsTrain);
            
            % Calc thresholds on anomalous validation set
            trainedModel.staticThresholds = getStaticThresholds(trainedModel, dataTestVal, labelsTestVal, thresholds, "anomalous-validation-data");
        end
    case "supervised"
        if isempty(dataTrain)
            error("The %s model requires prior training, but the dataset doesn't contain training data (train folder).", modelOptions.label);
        end
        
        % Save dimensionality of data
        trainedModel.dimensionality = size(dataTrain{1}, 2);
        
        % Train model
        [XTrain, YTrain, XVal, YVal] = dataTrainPreparationWrapper(modelOptions, dataTrain, labelsTrain);
        if strcmp(modelOptions.dimensionality, "multivariate")
            % Train single model on entire data
            Mdl = train(modelOptions, XTrain{1}, YTrain{1}, XVal{1}, YVal{1}, trainingPlots, verbose);
            trainedModel.Mdl = {Mdl};
        else
            % Train the same model for each channel seperately
            
            numChannels = numel(XTrain);
            Mdl = cell(numChannels, 1);
        
            for channel_idx = 1:numChannels
                Mdl{channel_idx} = train(modelOptions, XTrain{channel_idx}, YTrain{channel_idx}, XVal{channel_idx}, YVal{channel_idx}, trainingPlots, verbose);
            end
            trainedModel.Mdl = Mdl;
        end
        
        % Get static thresholds and training anomaly scores
        if ~modelOptions.outputsLabels
            [trainedModel.trainingAnomalyScoresRaw, ...
                trainedModel.trainingAnomalyScoreFeatures, ...
                trainedModel.trainingLabels] = getTrainingAnomalyScoreFeatures(trainedModel, dataTrain, labelsTrain);
            
            % Calc thresholds on training data
            trainedModel.staticThresholds = getStaticThresholds(trainedModel, [], [], thresholds, "training-data");
        end
end

fprintf("Successfully trained: %s!\n", modelOptions.label);
end
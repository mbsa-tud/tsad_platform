function staticThresholds = getStaticThresholds(trainedModel, data, labels, thresholds, type)
%GETSTATICTHRESHOLDS Compute all static thresholds
%   Compute static thresholds either using the training data or the
%   anomalous validation data

fprintf("Calculating static thresholds ...\n");

staticThresholds = [];

if strcmp(type, "anomalous-validation-data")
    % For semi-supervised models trained on fault-free data
    if ~isempty(data)
        XTestCell = cell(numel(data), 1);
        TSTestCell = cell(numel(data), 1);
        labelsTestCell = cell(numel(data), 1);
        
        numAnoms = 0;
    
        for data_idx = 1:numel(data)
            [XTestCell{data_idx}, TSTestCell{data_idx}, labelsTestCell{data_idx}] = dataTestPreparationWrapper(trainedModel.modelOptions, data(data_idx), labels(data_idx));
    
            numAnoms = numAnoms + sum(labelsTestCell{end} == 1);
        end
    
        anomalyScoresTest = [];
        labelsTest = [];

        for data_idx = 1:numel(XTestCell)
            anomalyScores_tmp = detectionWrapper(trainedModel, XTestCell{data_idx}, TSTestCell{data_idx}, labelsTestCell{data_idx});
            anomalyScoresTest = [anomalyScoresTest; anomalyScores_tmp];
            labelsTest = [labelsTest; labelsTestCell{data_idx}];
        end
        
        % Get all thresholds which are set using anomaly scores for test validation data
        if numAnoms ~= 0
            if ismember("bestF1ScorePointwise", thresholds)
                staticThresholds.bestF1ScorePointwise = calcStaticThreshold(anomalyScoresTest, labelsTest, "bestF1ScorePointwise", trainedModel.modelOptions.name);
            end
            if ismember("bestF1ScoreEventwise", thresholds)
                staticThresholds.bestF1ScoreEventwise = calcStaticThreshold(anomalyScoresTest, labelsTest, "bestF1ScoreEventwise", trainedModel.modelOptions.name);
            end
            if ismember("bestF1ScorePointAdjusted", thresholds)
                staticThresholds.bestF1ScorePointAdjusted = calcStaticThreshold(anomalyScoresTest, labelsTest, "bestF1ScorePointAdjusted", trainedModel.modelOptions.name);
            end
            if ismember("bestF1ScoreComposite", thresholds)
                staticThresholds.bestF1ScoreComposite = calcStaticThreshold(anomalyScoresTest, labelsTest, "bestF1ScoreComposite", trainedModel.modelOptions.name);
            end            
        else
            warning("Warning! Anomalous validation set doesn't contain anomalies, possibly couldn't calculate some static thresholds.");
        end

        if ismember("topK", thresholds)
            staticThresholds.topK = calcStaticThreshold(anomalyScoresTest, labelsTest, "topK", trainedModel.modelOptions.name);
        end
    end
    
    % Get all thresholds which are set using anomaly scores for train data
    if isfield(trainedModel, "trainingAnomalyScoresRaw")
        if ismember("meanStdTrain", thresholds) || ismember("maxTrainAnomalyScore", thresholds)    
            if isfield(trainedModel.modelOptions, 'hyperparameters') && isfield(trainedModel.modelOptions.hyperparameters, 'scoringFunction')
                anomalyScoresTrain = applyScoringFunction(trainedModel, trainedModel.trainingAnomalyScoresRaw);
            else
                anomalyScoresTrain = trainedModel.trainingAnomalyScoresRaw;
            end
        end
        
        if ismember("meanStdTrain", thresholds)
            staticThresholds.meanStdTrain = mean(mean(anomalyScoresTrain)) + 4 * mean(std(anomalyScoresTrain));
        end
        if ismember("maxTrainAnomalyScore", thresholds)
            staticThresholds.maxTrainAnomalyScore = max(max(anomalyScoresTrain));
        end
    end
    
    % Get all thresholds which don't require anomaly scores
    if ismember("pointFive", thresholds)
        staticThresholds.pointFive = calcStaticThreshold([], [], "pointFive", trainedModel.modelOptions.name);
    end
    if ismember("custom", thresholds)
        staticThresholds.custom = calcStaticThreshold([], [], "custom", trainedModel.modelOptions.name);
    end
elseif strcmp(type, "training-data")
    % For supervised models trained on faulty-data

    
    if isfield(trainedModel, "trainingAnomalyScoresRaw")
        % Apply optional scoring function to raw scores
        if isfield(trainedModel.modelOptions, 'hyperparameters') && isfield(trainedModel.modelOptions.hyperparameters, 'scoringFunction')
            anomalyScoresTrain = applyScoringFunction(trainedModel, trainedModel.trainingAnomalyScoresRaw);
        else
            anomalyScoresTrain = trainedModel.trainingAnomalyScoresRaw;
        end

        labelsTrain = trainedModel.trainingLabels;
        

        % Get all thresholds which are set using anomaly scores for train data
        if ~isequal(sum(labelsTrain), 0)
            if ismember("bestF1ScorePointwise", thresholds)
                staticThresholds.bestF1ScorePointwise = calcStaticThreshold(anomalyScoresTrain, labelsTrain, "bestF1ScorePointwise", trainedModel.modelOptions.name);
            end
            if ismember("bestF1ScoreEventwise", thresholds)
                staticThresholds.bestF1ScoreEventwise = calcStaticThreshold(anomalyScoresTrain, labelsTrain, "bestF1ScoreEventwise", trainedModel.modelOptions.name);
            end
            if ismember("bestF1ScorePointAdjusted", thresholds)
                staticThresholds.bestF1ScorePointAdjusted = calcStaticThreshold(anomalyScoresTrain, labelsTrain, "bestF1ScorePointAdjusted", trainedModel.modelOptions.name);
            end
            if ismember("bestF1ScoreComposite", thresholds)
                staticThresholds.bestF1ScoreComposite = calcStaticThreshold(anomalyScoresTrain, labelsTrain, "bestF1ScoreComposite", trainedModel.modelOptions.name);
            end
        else
            warning("Warning! Traininng data doesn't contain anomalies, possibly couldn't calculate some static thresholds.");
        end
        
        if ismember("topK", thresholds)
            staticThresholds.topK = calcStaticThreshold(anomalyScoresTrain, labelsTrain, "topK", trainedModel.modelOptions.name);
        end
        if ismember("meanStdTrain", thresholds)
            staticThresholds.meanStdTrain = mean(mean(anomalyScoresTrain)) + 4 * mean(std(anomalyScoresTrain));
        end
        if ismember("maxTrainAnomalyScore", thresholds)
            staticThresholds.maxTrainAnomalyScore = max(max(anomalyScoresTrain));
        end
    end
    
    % Get all thresholds which don't require anomaly scores
    if ismember("pointFive", thresholds)
        staticThresholds.pointFive = calcStaticThreshold([], [], "pointFive", trainedModel.modelOptions.name);
    end
    if ismember("custom", thresholds)
        staticThresholds.custom = calcStaticThreshold([], [], "custom", trainedModel.modelOptions.name);
    end
end
end

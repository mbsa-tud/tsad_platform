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
        numTimeSteps = 0;
    
        for data_idx = 1:numel(data)
            [XTestCell{data_idx}, TSTestCell{data_idx}, labelsTestCell{data_idx}] = prepareDataTest(trainedModel.modelOptions, data(data_idx), labels(data_idx));
    
            numAnoms = numAnoms + sum(labelsTestCell{end} == 1);
            numTimeSteps = numTimeSteps + size(labelsTestCell{end}, 1);
        end
    
        contaminationFraction = numAnoms / numTimeSteps;
        
        if contaminationFraction > 0
            anomalyScoresTest = [];
            labelsTest = [];
    
            for data_idx = 1:numel(XTestCell)
                anomalyScores_tmp = detectionWrapper(trainedModel, XTestCell{data_idx}, TSTestCell{data_idx}, labelsTestCell{data_idx});
                anomalyScoresTest = [anomalyScoresTest; anomalyScores_tmp];
                labelsTest = [labelsTest; labelsTestCell{data_idx}];
            end
    
    
            if ismember("bestFscorePointwise", thresholds)
                staticThresholds.bestFscorePointwise = calcStaticThreshold(anomalyScoresTest, labelsTest, "bestFscorePointwise", trainedModel.modelOptions.name);
            end
            if ismember("bestFscoreEventwise", thresholds)
                staticThresholds.bestFscoreEventwise = calcStaticThreshold(anomalyScoresTest, labelsTest, "bestFscoreEventwise", trainedModel.modelOptions.name);
            end
            if ismember("bestFscorePointAdjusted", thresholds)
                staticThresholds.bestFscorePointAdjusted = calcStaticThreshold(anomalyScoresTest, labelsTest, "bestFscorePointAdjusted", trainedModel.modelOptions.name);
            end
            if ismember("bestFscoreComposite", thresholds)
                staticThresholds.bestFscoreComposite = calcStaticThreshold(anomalyScoresTest, labelsTest, "bestFscoreComposite", trainedModel.modelOptions.name);
            end
            if ismember("topK", thresholds)
                staticThresholds.topK = calcStaticThreshold(anomalyScoresTest, labelsTest, "topK", trainedModel.modelOptions.name);
            end
        else
            warning("Warning! Anomalous validation set doesn't contain anomalies, possibly couldn't calculate some static thresholds.");
        end
    end
    
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
    
    if ismember("pointFive", thresholds)
        staticThresholds.pointFive = calcStaticThreshold([], [], "pointFive", trainedModel.modelOptions.name);
    end
    if ismember("custom", thresholds)
        staticThresholds.custom = calcStaticThreshold([], [], "custom", trainedModel.modelOptions.name);
    end
elseif strcmp(type, "training-data")
    % For supervised models trained on faulty-data

    if ~isequal(sum(trainedModel.trainingLabels), 0)
        if isfield(trainedModel, "trainingAnomalyScoresRaw")
            % Apply optional scoring function to raw scores
            if isfield(trainedModel.modelOptions, 'hyperparameters') && isfield(trainedModel.modelOptions.hyperparameters, 'scoringFunction')
                anomalyScoresTrain = applyScoringFunction(trainedModel, trainedModel.trainingAnomalyScoresRaw);
            else
                anomalyScoresTrain = trainedModel.trainingAnomalyScoresRaw;
            end
    
            labelsTrain = trainedModel.trainingLabels;
    
            if ismember("bestFscorePointwise", thresholds)
                staticThresholds.bestFscorePointwise = calcStaticThreshold(anomalyScoresTrain, labelsTrain, "bestFscorePointwise", trainedModel.modelOptions.name);
            end
            if ismember("bestFscoreEventwise", thresholds)
                staticThresholds.bestFscoreEventwise = calcStaticThreshold(anomalyScoresTrain, labelsTrain, "bestFscoreEventwise", trainedModel.modelOptions.name);
            end
            if ismember("bestFscorePointAdjusted", thresholds)
                staticThresholds.bestFscorePointAdjusted = calcStaticThreshold(anomalyScoresTrain, labelsTrain, "bestFscorePointAdjusted", trainedModel.modelOptions.name);
            end
            if ismember("bestFscoreComposite", thresholds)
                staticThresholds.bestFscoreComposite = calcStaticThreshold(anomalyScoresTrain, labelsTrain, "bestFscoreComposite", trainedModel.modelOptions.name);
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
    else
        warning("Warning! Traininng data doesn't contain anomalies, possibly couldn't calculate some static thresholds.");
    end
    
    if ismember("pointFive", thresholds)
        staticThresholds.pointFive = calcStaticThreshold([], [], "pointFive", trainedModel.modelOptions.name);
    end
    if ismember("custom", thresholds)
        staticThresholds.custom = calcStaticThreshold([], [], "custom", trainedModel.modelOptions.name);
    end
end
end

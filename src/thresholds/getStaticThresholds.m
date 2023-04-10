function staticThresholds = getStaticThresholds(trainedModel, data, labels, thresholds, type)
%GETSTATICTHRESHOLDS Compute all static thresholds
%   Compute static thresholds either using the training data or the
%   anomalous validation data

fprintf("Calculating static thresholds\n");

staticThresholds = [];

if strcmp(type, "anomalous-validation-data")
    % For semi-supervised models trained on fault-free data
    if ~isempty(data)
        XValTestCell = cell(size(data, 1), 1);
        YValTestCell = cell(size(data, 1), 1);
        labelsValTestCell = cell(size(data, 1), 1);
        
        numAnoms = 0;
        numTimeSteps = 0;
    
        for data_idx = 1:size(data, 1)
            [XValTestCell{data_idx, 1}, YValTestCell{data_idx, 1}, labelsValTestCell{data_idx, 1}] = prepareDataTest(trainedModel.modelOptions, data(data_idx, :), labels(data_idx, :));
    
            numAnoms = numAnoms + sum(labelsValTestCell{end} == 1);
            numTimeSteps = numTimeSteps + size(labelsValTestCell{end}, 1);
        end
    
        contaminationFraction = numAnoms / numTimeSteps;
        
        if contaminationFraction > 0
            anomalyScoresValTest = [];
            labelsValTest = [];
    
            for data_idx = 1:size(XValTestCell, 1)
                anomalyScores_tmp = detectionWrapper(trainedModel, XValTestCell{data_idx, 1}, YValTestCell{data_idx, 1}, labelsValTestCell{data_idx, 1});
                anomalyScoresValTest = [anomalyScoresValTest; anomalyScores_tmp];
                labelsValTest = [labelsValTest; labelsValTestCell{data_idx, 1}];
            end
    
    
            if ismember("bestFscorePointwise", thresholds)
                staticThresholds.bestFscorePointwise = calcStaticThreshold(anomalyScoresValTest, labelsValTest, "bestFscorePointwise", trainedModel.modelOptions.name);
            end
            if ismember("bestFscoreEventwise", thresholds)
                staticThresholds.bestFscoreEventwise = calcStaticThreshold(anomalyScoresValTest, labelsValTest, "bestFscoreEventwise", trainedModel.modelOptions.name);
            end
            if ismember("bestFscorePointAdjusted", thresholds)
                staticThresholds.bestFscorePointAdjusted = calcStaticThreshold(anomalyScoresValTest, labelsValTest, "bestFscorePointAdjusted", trainedModel.modelOptions.name);
            end
            if ismember("bestFscoreComposite", thresholds)
                staticThresholds.bestFscoreComposite = calcStaticThreshold(anomalyScoresValTest, labelsValTest, "bestFscoreComposite", trainedModel.modelOptions.name);
            end
            if ismember("topK", thresholds)
                staticThresholds.topK = calcStaticThreshold(anomalyScoresValTest, labelsValTest, "topK", trainedModel.modelOptions.name);
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

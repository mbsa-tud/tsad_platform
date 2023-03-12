function staticThreshold = getStaticThresholds(trainedModel, data, labels, thresholds, type)
%GETSTATICTHRESHOLD_DNN
%
% This function calculates the static threshold for DL models and
% returnes them in the staticThreshold struct

fprintf("Calculating static thresholds\n");

staticThreshold = [];

if strcmp(type, "anomalous-validation-data")
    % For semi-supervised models trained on fault-free data
    if ~isempty(data)
        XValTestCell = cell(size(data, 1), 1);
        YValTestCell = cell(size(data, 1), 1);
        labelsValTestCell = cell(size(data, 1), 1);
        
        numAnoms = 0;
        numTimeSteps = 0;
    
        for i = 1:size(data, 1)
            [XValTestCell{i, 1}, YValTestCell{i, 1}, labelsValTestCell{i, 1}] = prepareDataTest(trainedModel.options, data(i, :), labels(i, :));
    
            numAnoms = numAnoms + sum(labelsValTestCell{end} == 1);
            numTimeSteps = numTimeSteps + size(labelsValTestCell{end}, 1);
        end
    
        contaminationFraction = numAnoms / numTimeSteps;
        
        if contaminationFraction > 0
            anomalyScoresValTest = [];
            labelsValTest = [];
    
            for i = 1:size(XValTestCell, 1)
                anomalyScores_tmp = detectWith(trainedModel, XValTestCell{i, 1}, YValTestCell{i, 1}, labelsValTestCell{i, 1});
                anomalyScoresValTest = [anomalyScoresValTest; anomalyScores_tmp];
                labelsValTest = [labelsValTest; labelsValTestCell{i, 1}];
            end
    
    
            if ismember("bestFscorePointwise", thresholds)
                staticThreshold.bestFscorePointwise = calcStaticThreshold(anomalyScoresValTest, labelsValTest, "bestFscorePointwise", trainedModel.options.model);
            end
            if ismember("bestFscoreEventwise", thresholds)
                staticThreshold.bestFscoreEventwise = calcStaticThreshold(anomalyScoresValTest, labelsValTest, "bestFscoreEventwise", trainedModel.options.model);
            end
            if ismember("bestFscorePointAdjusted", thresholds)
                staticThreshold.bestFscorePointAdjusted = calcStaticThreshold(anomalyScoresValTest, labelsValTest, "bestFscorePointAdjusted", trainedModel.options.model);
            end
            if ismember("bestFscoreComposite", thresholds)
                staticThreshold.bestFscoreComposite = calcStaticThreshold(anomalyScoresValTest, labelsValTest, "bestFscoreComposite", trainedModel.options.model);
            end
            if ismember("topK", thresholds)
                staticThreshold.topK = calcStaticThreshold(anomalyScoresValTest, labelsValTest, "topK", trainedModel.options.model);
            end
            if ismember("meanStd", thresholds)
                staticThreshold.meanStd = calcStaticThreshold(anomalyScoresValTest, labelsValTest, "meanStd", trainedModel.options.model);
            end
        else
            warning("Warning! Anomalous validation set doesn't contain anomalies, possibly couldn't calculate some static thresholds.");
        end
    end
    
    if isfield(trainedModel, "trainingAnomalyScoresRaw")
        if ismember("meanStdTrain", thresholds) || ismember("maxTrainAnomalyScore", thresholds)    
            if isfield(trainedModel.options, 'hyperparameters') && isfield(trainedModel.options.hyperparameters, 'scoringFunction')
                anomalyScoresTrain = applyScoringFunction(trainedModel, trainedModel.trainingAnomalyScoresRaw);
            else
                anomalyScoresTrain = trainedModel.trainingAnomalyScoresRaw;
            end
        end
        
        if ismember("meanStdTrain", thresholds)
            staticThreshold.meanStdTrain = mean(mean(anomalyScoresTrain)) + 4 * mean(std(anomalyScoresTrain));
        end
        if ismember("maxTrainAnomalyScore", thresholds)
            staticThreshold.maxTrainAnomalyScore = max(max(anomalyScoresTrain));
        end
    end
    
    if ismember("pointFive", thresholds)
        staticThreshold.pointFive = calcStaticThreshold([], [], "pointFive", trainedModel.options.model);
    end
    if ismember("custom", thresholds)
        staticThreshold.custom = calcStaticThreshold([], [], "custom", trainedModel.options.model);
    end
elseif strcmp(type, "training-data")
    % For supervised models trained on faulty-data

    if ~isequal(sum(trainedModel.trainingLabels), 0)
        if isfield(trainedModel, "trainingAnomalyScoresRaw")
            if isfield(trainedModel.options, 'hyperparameters') && isfield(trainedModel.options.hyperparameters, 'scoringFunction')
                anomalyScoresTrain = applyScoringFunction(trainedModel, trainedModel.trainingAnomalyScoresRaw);
            else
                anomalyScoresTrain = trainedModel.trainingAnomalyScoresRaw;
            end
    
            labelsTrain = trainedModel.trainingLabels;
    
            if ismember("bestFscorePointwise", thresholds)
                staticThreshold.bestFscorePointwise = calcStaticThreshold(anomalyScoresTrain, labelsTrain, "bestFscorePointwise", trainedModel.options.model);
            end
            if ismember("bestFscoreEventwise", thresholds)
                staticThreshold.bestFscoreEventwise = calcStaticThreshold(anomalyScoresTrain, labelsTrain, "bestFscoreEventwise", trainedModel.options.model);
            end
            if ismember("bestFscorePointAdjusted", thresholds)
                staticThreshold.bestFscorePointAdjusted = calcStaticThreshold(anomalyScoresTrain, labelsTrain, "bestFscorePointAdjusted", trainedModel.options.model);
            end
            if ismember("bestFscoreComposite", thresholds)
                staticThreshold.bestFscoreComposite = calcStaticThreshold(anomalyScoresTrain, labelsTrain, "bestFscoreComposite", trainedModel.options.model);
            end
            if ismember("topK", thresholds)
                staticThreshold.topK = calcStaticThreshold(anomalyScoresTrain, labelsTrain, "topK", trainedModel.options.model);
            end
            if ismember("meanStd", thresholds)
                staticThreshold.meanStd = calcStaticThreshold(anomalyScoresTrain, labelsTrain, "meanStd", trainedModel.options.model);
            end
            if ismember("meanStdTrain", thresholds)
                staticThreshold.meanStdTrain = mean(mean(anomalyScoresTrain)) + 4 * mean(std(anomalyScoresTrain));
            end
            if ismember("maxTrainAnomalyScore", thresholds)
                staticThreshold.maxTrainAnomalyScore = max(max(anomalyScoresTrain));
            end
        end
    else
        warning("Warning! Traininng data doesn't contain anomalies, possibly couldn't calculate some static thresholds.");
    end
    
    if ismember("pointFive", thresholds)
        staticThreshold.pointFive = calcStaticThreshold([], [], "pointFive", trainedModel.options.model);
    end
    if ismember("custom", thresholds)
        staticThreshold.custom = calcStaticThreshold([], [], "custom", trainedModel.options.model);
    end
end
end

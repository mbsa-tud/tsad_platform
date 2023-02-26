function staticThreshold = getStaticThreshold_S(trainedModel, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds)
%GETSTATICTHRESHOLD_S
%
% This function calculates the static threshold for statistical models and
% returnes them in the staticThreshold struct

fprintf("Calculating static thresholds\n");

staticThreshold = [];

if ~isempty(dataValTest)
    XValTestCell = cell(size(dataValTest, 1), 1);
    YValTestCell = cell(size(dataValTest, 1), 1);
    labelsValTestCell = cell(size(dataValTest, 1), 1);
    
    numAnoms = 0;
    numTimeSteps = 0;

    for i = 1:size(dataValTest, 1)
        [XValTestCell{i, 1}, YValTestCell{i, 1}, labelsValTestCell{i, 1}] = prepareDataTest_S_wrapper(trainedModel.options, dataValTest(i, 1), labelsValTest(i, 1));
        
        numAnoms = numAnoms + sum(labelsValTestCell{end} == 1);
        numTimeSteps = numTimeSteps + size(labelsValTestCell{end}, 1);
    end

    contaminationFraction = numAnoms / numTimeSteps;                       
    
    if contaminationFraction > 0
        anomalyScoresValTest = [];
        labels = [];

        for i = 1:size(XValTestCell, 1)
            anomalyScores_tmp = detectWithS_wrapper(trainedModel, XValTestCell{i, 1}, YValTestCell{i, 1}, labelsValTestCell{i, 1});
            anomalyScoresValTest = [anomalyScoresValTest; anomalyScores_tmp];
            labels = [labels; labelsValTestCell{i, 1}];
        end
        
        if ismember("bestFscorePointwise", thresholds)
            staticThreshold.bestFscorePointwise = calcStaticThreshold(anomalyScoresValTest, labels, "bestFscorePointwise", trainedModel.options.model);
        end
        if ismember("bestFscoreEventwise", thresholds)
            staticThreshold.bestFscoreEventwise = calcStaticThreshold(anomalyScoresValTest, labels, "bestFscoreEventwise", trainedModel.options.model);
        end
        if ismember("bestFscorePointAdjusted", thresholds)
            staticThreshold.bestFscorePointAdjusted = calcStaticThreshold(anomalyScoresValTest, labels, "bestFscorePointAdjusted", trainedModel.options.model);
        end
        if ismember("bestFscoreComposite", thresholds)
            staticThreshold.bestFscoreComposite = calcStaticThreshold(anomalyScoresValTest, labels, "bestFscoreComposite", trainedModel.options.model);
        end
        if ismember("topK", thresholds)
            staticThreshold.topK = calcStaticThreshold(anomalyScoresValTest, labels, "topK", trainedModel.options.model);
        end
        if ismember("meanStd", thresholds)
            staticThreshold.meanStd = calcStaticThreshold(anomalyScoresValTest, labels, "meanStd", trainedModel.options.model);
        end
    else
        fprintf("Warning! Anomalous validation set doesn't contain anomalies, possibly couldn't calculate some static thresholds.");
    end
end

if ~isempty(dataTrain)
    if ismember("meanStdTrain", thresholds) || ismember("maxTrainAnomalyScore", thresholds)
        XTrainTestCell = cell(size(dataTrain, 1), 1);
        YTrainTestCell = cell(size(dataTrain, 1), 1);
        labelsTrainTestCell = cell(size(dataTrain, 1), 1);
    
        for i = 1:size(dataTrain, 1)
            [XTrainTestCell{i, 1}, YTrainTestCell{i, 1}, labelsTrainTestCell{i, 1}] = prepareDataTest_S_wrapper(trainedModel.options, dataTrain(i, :), labelsTrain(i, :));
        end
    
        anomalyScoresTrain = [];
        for i = 1:size(XTrainTestCell, 1)
            anomalyScores_tmp = detectWithS_wrapper(trainedModel, XTrainTestCell{i, 1}, YTrainTestCell{i, 1}, labelsTrainTestCell{i, 1});
            anomalyScoresTrain = [anomalyScoresTrain; anomalyScores_tmp];
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
end


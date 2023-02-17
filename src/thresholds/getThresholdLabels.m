function labels = getThresholdLabels(ids)
numIds = numel(ids);
labels = strings(1, numIds);

for i = 1:numIds
    switch ids(i)
        case "bestFscorePointwise"
            labels(1, i) = "Best F1 Score (point-wise)";
        case "bestFscoreEventwise"
            labels(1, i) = "Best F1 Score (event-wise)";
        case "bestFscorePointAdjusted"
            labels(1, i) = "Best F1 Score (point-adjusted)";
        case "bestFscoreComposite"
            labels(1, i) = "Best F1 Score (composite)";
        case "topK"
            labels(1, i) = "Top k";
        case "meanStd"
            labels(1, i) = "Mean + 4 * Std";
        case "meanStdTrain"
            labels(1, i) = "Mean + 4 * Std (Train)";
        case "maxTrainAnomalyScore"
            labels(1, i) = "Max Train Anomaly Score";
        case "pointFive"
            labels(1, i) = "0.5";
        case "dynamic"
            labels(1, i) = "Dynamic";
        case "custom"
            labels(1, i) = "Custom";
    end
end
end
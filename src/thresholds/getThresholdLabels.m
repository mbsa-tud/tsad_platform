function labels = getThresholdLabels(ids)
%GETTHRESHOLDLABELS convert threshold identifiers to correspondig labels
%   This is the inverse function to the getThresholdId function. It
%   converts all ids to the labels which are nicer to display.

numIds = numel(ids);
labels = strings(numIds, 1);

for i = 1:numIds
    switch ids(i)
        case "bestF1ScorePointwise"
            labels(i) = "Best F1 Score (point-wise)";
        case "bestF1ScoreEventwise"
            labels(i) = "Best F1 Score (event-wise)";
        case "bestF1ScorePointAdjusted"
            labels(i) = "Best F1 Score (point-adjusted)";
        case "bestF1ScoreComposite"
            labels(i) = "Best F1 Score (composite)";
        case "topK"
            labels(i) = "Top k";
        case "meanStd"
            labels(i) = "Mean + 3 * Std";
        case "meanStdTrain"
            labels(i) = "Mean + 3 * Std (Train)";
        case "maxTrainAnomalyScore"
            labels(i) = "Max Train Anomaly Score";
        case "pointFive"
            labels(i) = "0.5";
        case "dynamic"
            labels(i) = "Dynamic";
        case "custom"
            labels(i) = "Custom";
    end
end
end
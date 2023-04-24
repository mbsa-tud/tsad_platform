function labels = getThresholdLabels(ids)
%GETTHRESHOLDLABELS convert threshold identifiers to correspondig labels
%   This is the inverse function to the getThresholdId function. It
%   converts all ids to the labels which are nicer to display.

numIds = numel(ids);
labels = strings(1, numIds);

for id_idx = 1:numIds
    switch ids(id_idx)
        case "bestFscorePointwise"
            labels(1, id_idx) = "Best F1 Score (point-wise)";
        case "bestFscoreEventwise"
            labels(1, id_idx) = "Best F1 Score (event-wise)";
        case "bestFscorePointAdjusted"
            labels(1, id_idx) = "Best F1 Score (point-adjusted)";
        case "bestFscoreComposite"
            labels(1, id_idx) = "Best F1 Score (composite)";
        case "topK"
            labels(1, id_idx) = "Top k";
        case "meanStd"
            labels(1, id_idx) = "Mean + 3 * Std";
        case "meanStdTrain"
            labels(1, id_idx) = "Mean + 3 * Std (Train)";
        case "maxTrainAnomalyScore"
            labels(1, id_idx) = "Max Train Anomaly Score";
        case "pointFive"
            labels(1, id_idx) = "0.5";
        case "dynamic"
            labels(1, id_idx) = "Dynamic";
        case "custom"
            labels(1, id_idx) = "Custom";
    end
end
end
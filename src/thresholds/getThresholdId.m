function id = getThresholdId(thr)
switch thr
    case "Best F1 Score (point-wise)"
        id = "bestFscorePointwise";
    case "Best F1 Score (event-wise)"
        id = "bestFscoreEventwise";
    case "Best F1 Score (point-adjusted)"
        id = "bestFscorePointAdjusted";
    case "Best F1 Score (composite)"
        id = "bestFscoreComposite";
    case "Top k"
        id = "topK";
    case "Mean + 4 * Std"
        id = "meanStd";
    case "Mean + 4 * Std (Train)"
        id = "meanStdTrain";
    case "Max Train Anomaly Score"
        id = "maxTrainAnomalyScore";
    case "0.5"
        id = "pointFive";
    case "Dynamic"
        id = "dynamic";
    case "Custom"
        id = "custom";
end
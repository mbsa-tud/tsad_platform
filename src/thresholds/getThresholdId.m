function id = getThresholdId(label)
%GETTHRESHOLDID convert threshold label to correspondig id
%   This is the inverse function to the getThresholdLabels function. It
%   converts a single label to the correct id

switch label
    case "Best F1 Score (point-wise)"
        id = "bestF1ScorePointwise";
    case "Best F1 Score (event-wise)"
        id = "bestF1ScoreEventwise";
    case "Best F1 Score (point-adjusted)"
        id = "bestF1ScorePointAdjusted";
    case "Best F1 Score (composite)"
        id = "bestF1ScoreComposite";
    case "Top k"
        id = "topK";
    case "Mean + 3 * Std"
        id = "meanStd";
    case "Mean + 3 * Std (Train)"
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
function reshapedAnomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores)
%MERGEOVERLAPPINGANOMALYSCORES Gets the median anomaly score for each
%observation of the time series

switch modelOptions.name
    case "Your model name"
    otherwise
        windowSize = modelOptions.hyperparameters.windowSize.value;
        anomalyScores = repmat(anomalyScores, 1, windowSize);

        reshapedAnomalyScores = mergeSequences(anomalyScores, windowSize);
end
end

function reshapedAnomalyScores = mergeOverlappingAnomalyScores(options, anomalyScores)
switch options.model
    case "Your model"
    otherwise
        windowSize = options.hyperparameters.windowSize.value;
        anomalyScores = repmat(anomalyScores, 1, windowSize);

        reshapedAnomalyScores = mergeSequences(anomalyScores, windowSize);
end
end

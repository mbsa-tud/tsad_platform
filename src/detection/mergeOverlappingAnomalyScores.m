function reshapedanomalyScores = mergeOverlappingAnomalyScores(options, anomalyScores)
%mergeOverlappingAnomalyScores
%
% Calculates the median anomaly score for all overlapping subsequences for
% the ML and statistical algorithms

switch options.model
    case "Your model"
    otherwise
        windowSize = options.hyperparameters.windowSize.value;
        anomalyScores = repmat(anomalyScores, 1, windowSize);

        reshapedanomalyScores = mergeSequences(anomalyScores, windowSize);
end
end

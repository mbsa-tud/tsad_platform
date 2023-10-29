function reshapedAnomalyScores = mergeOverlappingAnomalyScores(anomalyScores, windowSize, averagingFunction)
%MERGEOVERLAPPINGANOMALYSCORES Gets the average anomaly score for each
%observation of the time series

anomalyScores = repmat(anomalyScores, 1, windowSize);

reshapedAnomalyScores = mergeSequences(anomalyScores, windowSize, averagingFunction);
end

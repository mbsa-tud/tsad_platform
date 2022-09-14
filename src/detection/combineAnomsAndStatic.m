function labels_pred = combineAnomsAndStatic(anomalyScores, labels_pred)
d = diff(anomalyScores);
labels_pred(d == 0) = true;
end

function labels_pred = combineAnomsAndStatic(anomalyScores, labels_pred)
%COMBINEANOMSANDSTATIC If two consecutive points have the same anomaly
%score, they're labelled as anomalous

d = diff(anomalyScores);
labels_pred(d == 0) = true;
end

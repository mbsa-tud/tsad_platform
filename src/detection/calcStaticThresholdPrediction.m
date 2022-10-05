function labels_pred = calcStaticThresholdPrediction(anomalyScores, staticThreshold, pd, useGaussianScores)
%CALCSTATICTHRESHOLDPREDICTION
%
% Converts anomaly scores to binary detection using the static threshold


labels_pred_tmp = logical([]);
numChannels = size(anomalyScores, 2);


for j = 1:numChannels
    labels_pred_tmp(:, j) = anomalyScores(:, j) > staticThreshold;
end
labels_pred = any(labels_pred_tmp, 2);

% anoms = combineAnomsAndStatic(anomalyScores, anoms);
end

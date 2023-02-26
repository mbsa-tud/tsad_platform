function [labels_pred, staticThreshold] = calcStaticThresholdPrediction(anomalyScores, labels, staticThreshold, model)
%CALCSTATICTHRESHOLDPREDICTION
%
% Converts anomaly scores to binary detection using the static threshold

if isstring(staticThreshold)
    fprintf("Calculating static threshold: %s\n", staticThreshold);
    staticThreshold = calcStaticThreshold(anomalyScores, labels, staticThreshold, model);
end

numChannels = size(anomalyScores, 2);

if numChannels > 1
    labels_pred_tmp = logical([]);
    for j = 1:numChannels
        labels_pred_tmp(:, j) = anomalyScores(:, j) > staticThreshold;
    end
    labels_pred = any(labels_pred_tmp, 2);
else
    labels_pred = anomalyScores > staticThreshold;
end
% anoms = combineAnomsAndStatic(anomalyScores, anoms);
end

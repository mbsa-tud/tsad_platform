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
    labels_pred = any(anomalyScores > staticThreshold, 2);
else
    labels_pred = anomalyScores > staticThreshold;
end
% anoms = combineAnomsAndStatic(anomalyScores, anoms);
end

function [anoms, threshold] = calcDynamicThresholdPrediction(anomalyScores, labels, padding, windowSize, min_percent, z_range)
[anom_times, threshold] = find_anomalies(anomalyScores, 'anomaly_padding', padding, ...
    'window_size', windowSize, 'min_percent', min_percent, 'z_range', z_range);

anoms = false(length(labels), 1);
for i = 1:size(anom_times, 1)
    begIdx = anom_times(i, 1);
    endIdx = anom_times(i, 2);
    if endIdx > length(anoms)
        endIdx = length(anoms);
    end
    if isnan(begIdx) || isnan(endIdx) || (begIdx > endIdx)
        return;
    end
    anoms(begIdx:endIdx, 1) = 1;
end
% anoms = combineAnomsAndStatic(anomalyScores, anoms);
end

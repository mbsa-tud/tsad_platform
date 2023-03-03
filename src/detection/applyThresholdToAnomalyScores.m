function [predictedLabels, threshold] = applyThresholdToAnomalyScores(anomalyScores, labels, model, threshold, dynamicThresholdSettings)
%CALCSTATICTHRESHOLDPREDICTION
%
% Converts anomaly scores to binary detection using the static threshold

% If threshold not yet has a value
if isstring(threshold)
    if strcmp(threshold, 'dynamic')
        % Dynamic threshold

        fprintf("Calculating dynamic threshold");
        padding = dynamicThresholdSettings.anomalyPadding;
        windowSize = max(1, floor(length(anomalyScores) * (dynamicThresholdSettings.windowSize / 100)));
        min_percent = dynamicThresholdSettings.minPercent;
        z_range = 1:dynamicThresholdSettings.zRange;
        
        [anom_times, threshold] = find_anomalies(anomalyScores, 'anomaly_padding', padding, ...
            'window_size', windowSize, 'min_percent', min_percent, 'z_range', z_range);
        
        predictedLabels = false(length(labels), 1);
        for i = 1:size(anom_times, 1)
            begIdx = anom_times(i, 1);
            endIdx = anom_times(i, 2);
            if endIdx > length(predictedLabels)
                endIdx = length(predictedLabels);
            end
            if isnan(begIdx) || isnan(endIdx) || (begIdx > endIdx)
                return;
            end
            predictedLabels(begIdx:endIdx, 1) = 1;
        end
        % predictedLabels = combineAnomsAndStatic(anomalyScores, predictedLabels);
    else
        % Other static thresholds
        fprintf("Calculating static threshold (%s) on test set\n", threshold);
        threshold = calcStaticThreshold(anomalyScores, labels, threshold, model);

        numChannels = size(anomalyScores, 2);

        if numChannels > 1
            predictedLabels = any(anomalyScores > threshold, 2);
        else
            predictedLabels = anomalyScores > threshold;
        end
        % predictedLabels = combineAnomsAndStatic(anomalyScores, predictedLabels);
    end
else
    numChannels = size(anomalyScores, 2);
    
    if numChannels > 1
        predictedLabels = any(anomalyScores > threshold, 2);
    else
        predictedLabels = anomalyScores > threshold;
    end
    % predictedLabels = combineAnomsAndStatic(anomalyScores, predictedLabels);
end
end

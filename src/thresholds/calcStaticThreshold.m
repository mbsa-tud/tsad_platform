function thr = calcStaticThreshold(anomalyScores, labels, threshold, model)
%CALCSTATICTHRESHOLD
%
% Calculates the static threshold specified in the threshold parameter

if ~isempty(labels)
    numOfAnoms = sum(labels == 1);
    contaminationFraction = numOfAnoms / size(labels, 1);
end

switch threshold
    case "bestFscorePointwise"
        thr = computeBestFscoreThreshold(anomalyScores, labels, 'point-wise');
    case "bestFscoreEventwise"
        thr = computeBestFscoreThreshold(anomalyScores, labels, 'event-wise');
    case "bestFscorePointAdjusted"
        thr = computeBestFscoreThreshold(anomalyScores, labels, 'point-adjusted');
    case "bestFscoreComposite"
        thr = computeBestFscoreThreshold(anomalyScores, labels, 'composite');
    case "topK"
        thr = quantile(anomalyScores, 1 - contaminationFraction);
    case "meanStd"
        % The outer mean is required for separate anomaly Scores
        % for each channel.
        thr = mean(mean(anomalyScores)) + 4 * mean(std(anomalyScores));
    case "pointFive"
        thr = 0.5;
    case "custom"
        switch model
            case "Your model"
			% Add your custom threshold here
            otherwise
                thr = 0.5;
        end
    otherwise
        error("The selected static threshold  - %s -  can't be calculated after detection. See file src/thresholds/calcStaticThreshold.m", threshold);
end

% If thr is NaN, set it very high to only produce NaN values after
% detection but don't throw an error
if isnan(thr)
    fprintf("Warning (file: src/thresholds/calcStaticThreshold.m): Threshold %s was calculated to be NaN for %s.\n", threshold, model);
end
end

function staticThreshold = calcStaticThreshold(anomalyScores, labels, threshold, model)
%CALCSTATICTHRESHOLD
%
% Calculates the static threshold specified in the threshold parameter

numOfAnoms = sum(labels == 1);
contaminationFraction = numOfAnoms / size(labels, 1);

switch model
    case 'Your model'
    otherwise
        switch threshold
            case "bestFscorePointwise"
                thr = computeBestFscoreThreshold(anomalyScores, labels, 0, 0, 'point-wise');
            case "bestFscoreEventwise"
                thr = computeBestFscoreThreshold(anomalyScores, labels, 0, 0, 'event-wise');
            case "bestFscorePointAdjusted"
                thr = computeBestFscoreThreshold(anomalyScores, labels, 0, 0, 'point-adjusted');
            case "bestFscoreComposite"
                thr = computeBestFscoreThreshold(anomalyScores, labels, 0, 0, 'composite');
            case "topK"
                thr = quantile(anomalyScores, 1 - contaminationFraction);
            case "meanStd"
                % The outer mean is required for separate anomaly Scores
                % for each channel.
                thr = mean(mean(anomalyScores)) + 4 * mean(std(anomalyScores));
            otherwise
                thr = 0.5;
                disp("Warning! The selected static threshold can't be calculated after detection. See file src/thresholds/calcStaticThreshold.m");
        end
        if ~isnan(thr)
            staticThreshold = thr;
        else
            staticThreshold = 0;
        end
end
end

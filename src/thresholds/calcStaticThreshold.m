function thr = calcStaticThreshold(anomalyScores, labels, threshold, model)
%CALCSTATICTHRESHOLD
%
% Calculates the static threshold specified in the threshold parameter

if ~isempty(labels)
    numAnoms = sum(labels == 1);
    contaminationFraction = numAnoms / size(labels, 1);
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
        numChannels = size(anomalyScores, 2);

        if numChannels > 1
            thresholdCandidates = uniquetol(anomalyScores, 0.0001);
            numThresholdCandidates = size(thresholdCandidates, 1);

            currentMinDistance = numel(labels);
            thr = NaN;
            for i = 1:numThresholdCandidates
                distance = abs(numAnoms - sum(any(anomalyScores > thresholdCandidates(i), 2)));
                if distance < currentMinDistance
                    thr = thresholdCandidates(i);
                    if distance == 0
                        break;
                    end
                    currentMinDistance = distance;
                end
            end
        else
            thr = quantile(anomalyScores, 1 - contaminationFraction);
        end
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
        warning("The selected static threshold  - %s -  can't be calculated after detection. Setting threshold to 0. See file src/thresholds/calcStaticThreshold.m", threshold);
        thr = 0;
end

% If thr is NaN, set it very high to only produce NaN values after
% detection but don't throw an error
if isnan(thr)
    warning("(file: src/thresholds/calcStaticThreshold.m): Threshold %s was calculated to be NaN for %s.\n", threshold, model);
end
end

function thr = calcStaticThreshold(anomalyScores, labels, threshold, modelName)
%CALCSTATICTHRESHOLD Calculates the static threshold on the testing data
%   Compute the static threshold using the anomaly scores after running
%   test on the test data

if ~isempty(labels)
    numAnoms = sum(labels == 1);
    contaminationFraction = numAnoms / size(labels, 1);
end

switch threshold
    case "bestFscorePointwise"
        thr = computeBestFscoreThreshold(anomalyScores, labels, "point-wise");
    case "bestFscoreEventwise"
        thr = computeBestFscoreThreshold(anomalyScores, labels, "event-wise");
    case "bestFscorePointAdjusted"
        thr = computeBestFscoreThreshold(anomalyScores, labels, "point-adjusted");
    case "bestFscoreComposite"
        thr = computeBestFscoreThreshold(anomalyScores, labels, "composite");
    case "topK"        
        numChannels = size(anomalyScores, 2);

        if numChannels > 1
            thresholdCandidates = uniquetol(anomalyScores, 0.0001);
            numThresholdCandidates = size(thresholdCandidates, 1);

            currentMinDistance = numel(labels);
            thr = NaN;
            for cand_idx = 1:numThresholdCandidates
                distance = abs(numAnoms - sum(any(anomalyScores > thresholdCandidates(cand_idx), 2)));
                if distance < currentMinDistance
                    thr = thresholdCandidates(cand_idx);
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
        switch modelName
            case "Your model name"
			% Add your custom threshold here
            otherwise
                thr = 0.5;
        end
    otherwise
        warning("The selected static threshold  - %s -  can't be calculated after detection. Setting threshold to NaN. See file src/thresholds/calcStaticThreshold.m", threshold);
        thr = NaN;
end

if isnan(thr)
    warning("(file: src/thresholds/calcStaticThreshold.m): Threshold %s was calculated to be NaN for %s.\n", threshold, modelName);
end
end

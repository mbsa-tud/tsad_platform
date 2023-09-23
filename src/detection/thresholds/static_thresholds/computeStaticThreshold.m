function thr = computeStaticThreshold(anomalyScores, labels, threshold, modelName)
%COMPUTESTATICTHRESHOLD

if ~isempty(labels)
    numAnoms = sum(labels == 1);
    contaminationFraction = numAnoms / numel(labels);
end

switch threshold
    case "best_pointwise_f1_score"
        thr = computeBestF1ScoreThreshold(anomalyScores, labels, "point-wise");
    case "best_eventwise_f1_score"
        thr = computeBestF1ScoreThreshold(anomalyScores, labels, "event-wise");
    case "best_pointadjusted_f1_score"
        thr = computeBestF1ScoreThreshold(anomalyScores, labels, "point-adjusted");
    case "best_composite_f1_score"
        thr = computeBestF1ScoreThreshold(anomalyScores, labels, "composite");
    case "top_k"        
        numChannels = size(anomalyScores, 2);

        if numChannels > 1
            thresholdCandidates = uniquetol(anomalyScores, 0.0001);
            numThresholdCandidates = numel(thresholdCandidates);

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
    case "probabilistic"
        % The outer mean is required for separate anomaly Scores
        % for each channel.
        thr = mean(mean(anomalyScores)) + 4 * mean(std(anomalyScores));
    case "0.5"
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

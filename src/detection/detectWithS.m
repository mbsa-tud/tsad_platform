function [anomalyScores, compTime] = detectWithS(options, Mdl, XTest, YTest, labels, getCompTime)
%DETECTWITHS
%
% Runs the detection for statistical models and returns anomaly Scores
compTime = NaN;

% Detect with model
switch options.model
    case 'Grubbs test'
        anomalyScores = grubbs_test(XTest, options.hyperparameters.alpha.value);

        if options.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(options, anomalyScores);
        end
    case 'OD_wpca'
        [~, anomalyScores, ~] = OD_wpca(XTest, options.hyperparameters.ratioOversample.value);

        if options.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(options, anomalyScores);
        end
end
end

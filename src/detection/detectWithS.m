function [anomalyScores, compTime] = detectWithS(modelOptions, Mdl, XTest, YTest, labels, getCompTime)
%DETECTWITHS Runs the detection for statistical models

% Comptime measure the computation time for a single subsequence. Might be
% unavailable for some models
compTime = NaN;

% Detect with model
switch modelOptions.name
    case 'Your model name'
    case 'Grubbs test'
        anomalyScores = grubbs_test(XTest, modelOptions.hyperparameters.alpha.value);
    case 'over-sampling PCA'
        [~, anomalyScores, ~] = OD_wpca(XTest, modelOptions.hyperparameters.ratioOversample.value);

        if modelOptions.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
        end
end
end

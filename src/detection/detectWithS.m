function [anomalyScores, compTime] = detectWithS(modelOptions, Mdl, XTest, YTest, labels, getCompTime)
%DETECTWITHS Runs the detection for statistical models

compTime = NaN;

% Detect with model
switch modelOptions.name
    case 'Your model name'
    case 'Grubbs test'
        anomalyScores = grubbs_test(XTest, modelOptions.hyperparameters.alpha.value);
    case 'OD_wpca'
        [~, anomalyScores, ~] = OD_wpca(XTest, modelOptions.hyperparameters.ratioOversample.value);

        if modelOptions.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores);
        end
end
end

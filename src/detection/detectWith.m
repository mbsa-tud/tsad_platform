function [anomalyScores, compTimeOut] = detectWith(trainedModel, XTest, YTest, labels, getCompTime)
%DETECTWITH
%
% Runs the detection and returns anomaly Scores

if ~exist('getCompTime', 'var')
    getCompTime = false;
end

% Get raw scores
[anomalyScores, compTime] = detectWithModel(trainedModel, XTest, YTest, labels, getCompTime);

if nargout == 2
    compTimeOut = compTime;
end

% Bypass scoring function for models which output labels
if trainedModel.options.outputsLabels
    anomalyScores = any(anomalyScores, 2);
    return;
end

% Apply optional scoring function
if isfield(trainedModel.options, 'hyperparameters')
    if isfield(trainedModel.options.hyperparameters, 'scoringFunction')
        anomalyScores = applyScoringFunction(trainedModel, anomalyScores);
    end
end
end

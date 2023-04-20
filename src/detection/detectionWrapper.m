function [anomalyScores, compTimeOut] = detectionWrapper(trainedModel, XTest, YTest, labels, getCompTime)
%DETECTIONWRAPPER Main detection wrapper function
%   Runs the detection applys a scoring function and returns anomaly scores
%   and computational time

if ~exist("getCompTime", "var")
    getCompTime = false;
end

% Get raw scores
[anomalyScores, compTime] = detectWithModel(trainedModel, XTest, YTest, labels, getCompTime);

if nargout == 2
    compTimeOut = compTime;
end

% Bypass scoring function for models which output labels
if trainedModel.modelOptions.outputsLabels
    anomalyScores = any(anomalyScores, 2);
    return;
end

% Apply optional scoring function
if isfield(trainedModel.modelOptions, "hyperparameters")
    if isfield(trainedModel.modelOptions.hyperparameters, "scoringFunction")
        anomalyScores = applyScoringFunction(trainedModel, anomalyScores);
    end
end
end

function anomalyScores = EWMAScoring(rawAnomalyScores, alpha)
%EWMASCORING Applies the Exponetially Weighted Moving Average to the Root
%Mean Square of the raw channel-wise anomaly scores. The
%smoothing-factor alpha can be between 0 and 1 (Higher means LESS
%smoothing)

% RMS across channels of raw scores
anomalyScores = rms(rawAnomalyScores, 2);

% Calculate EWMA. The first value is not changed as EWMA is recursive
for i = 2:size(anomalyScores, 1)
    anomalyScores(i) = alpha * anomalyScores(i) + (1 - alpha) * anomalyScores(i - 1);
end
end


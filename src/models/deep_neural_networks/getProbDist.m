function pd = getProbDist(options, Mdl, X, Y)
[anomalyScoresVal, ~, ~] = detectWithDNN(options, Mdl, X, Y, zeros(size(Y{1, 1}, 1), 1), 'channelwise-errors', []);
% iterate here.
pd = fitdist(anomalyScoresVal, "Normal");
end
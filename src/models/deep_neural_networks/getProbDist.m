function pd = getProbDist(options, Mdl, X, Y)
[anomalyScores, ~, ~] = detectWithDNN(options, Mdl, X, Y, zeros(size(Y{1, 1}, 1), 1), 'channelwise-errors', []);
% iterate here.
numChannels = size(anomalyScores, 2);
pd = [];
for i = 1:numChannels
pd = [pd, fitdist(anomalyScores(:, i), "Normal")];
end
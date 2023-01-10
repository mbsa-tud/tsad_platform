function pd = getProbDist(options, Mdl, X, Y)
anomalyScores = detectWithDNN(options, Mdl, X, Y, [], 'separate', []);

% pd.mu = mean(anomalyScores, 1);
% pd.sigma = cov(anomalyScores);
numChannels = size(anomalyScores, 2);
pd = [];
for i = 1:numChannels
    pd = [pd, fitdist(anomalyScores(:, i), "Normal")];
end
end
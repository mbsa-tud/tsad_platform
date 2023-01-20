function features = getTrainingErrorFeatures(options, Mdl, X, Y)
anomalyScores = detectWithDNN(options, Mdl, X, Y, [], 'separate', []);
features.mu = mean(anomalyScores, 1);
features.covar = cov(anomalyScores);
end
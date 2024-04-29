function anomalyScores = multivariateGaussianScoring(anomalyScores, mu, covar)
%MULTIVARIATEGAUSSIANSCORING Applies -log(1 - cdf) to raw multi-channel anomaly scores.
%mu and covar is the raw training anomaly scores distribution.

anomalyScores = -log(1 - mvncdf(anomalyScores, mu, covar));
anomalyScores(isinf(anomalyScores)) = 100; % Cap scores
end


function anomalyScores = univariateGaussianScoring(anomalyScores, mu, covar, channelwise)
%UNIVARIATEGAUSSIANSCORING Applies -log(1 - cdf) to each channel of raw anomaly
%scores separately. Then channelwise scores are summed.
%mu and covar is the raw training anomaly scores distribution.

if ~exist("channelwise", "var")
    channelwise = false;
end

numChannels = size(anomalyScores, 2);

for channel_idx = 1:numChannels
    anomalyScores(:, channel_idx) = -log(1 - cdf("Normal", anomalyScores(:, channel_idx), ...
                                         mu(channel_idx), sqrt(covar(channel_idx, channel_idx))));
end
anomalyScores(isinf(anomalyScores)) = 100; % Cap scores

if ~channelwise
    anomalyScores = sum(anomalyScores, 2);
end
end


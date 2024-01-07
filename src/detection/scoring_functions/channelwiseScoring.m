function anomalyScores = channelwiseScoring(anomalyScores, mu)
%CHANNELWISESCORING Subtracts channelwise mean fromt raw anomaly scores
%(only for multivariate scores)

numChannels = size(anomalyScores, 2);
% Only has an effect for multivariate data
if numChannels > 1
    for channel_idx = 1:numChannels
        anomalyScores(:, channel_idx) = anomalyScores(:, channel_idx) - mu(channel_idx);
    end
end
end


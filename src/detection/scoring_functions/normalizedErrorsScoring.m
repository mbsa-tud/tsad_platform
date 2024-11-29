function anomalyScores = normalizedErrorsScoring(anomalyScores, mu, channelwise)
%NORMALIZEDERRORSSCORING Subtracts channel-wise mean from raw anomaly scores before computing the RMS accross
%channels (only for multivariate scores)

if ~exist("channelwise", "var")
    channelwise = false;
end

numChannels = size(anomalyScores, 2);
% Only has an effect for multivariate data
if numChannels > 1
    for channel_idx = 1:numChannels
        anomalyScores(:, channel_idx) = anomalyScores(:, channel_idx) - mu(channel_idx);
    end

    if ~channelwise
        anomalyScores = rms(anomalyScores, 2);
    end
end
end


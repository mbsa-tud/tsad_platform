function anomalyScores = applyScoringFunction(trainedModel, anomalyScores)
%APPLYSCORINGFUNCTION Applys a scoring function to the anomaly scores

% Apply scoring function
numChannels = size(anomalyScores, 2);

switch trainedModel.modelOptions.hyperparameters.scoringFunction
    case 'channelwise-errors'
        if numChannels > 1
            for channel_idx = 1:numChannels
                anomalyScores(:, channel_idx) = anomalyScores(:, channel_idx) - trainedModel.trainingAnomalyScoreFeatures.mu(channel_idx);
            end
        end
    case 'aggregated-errors'
        if numChannels > 1
            for channel_idx = 1:numChannels
                anomalyScores(:, channel_idx) = anomalyScores(:, channel_idx) - trainedModel.trainingAnomalyScoreFeatures.mu(channel_idx);
            end
            anomalyScores = rms(anomalyScores, 2);
        end
    case 'gauss'
        anomalyScores = -log(1 - mvncdf(anomalyScores, trainedModel.trainingAnomalyScoreFeatures.mu, trainedModel.trainingAnomalyScoreFeatures.covar));
        anomalyScores(isinf(anomalyScores)) = 100; % Cap scores
    case 'aggregated-gauss'
        for channel_idx = 1:numChannels
            anomalyScores(:, channel_idx) = -log(1 - cdf('Normal', anomalyScores(:, channel_idx), ...
                trainedModel.trainingAnomalyScoreFeatures.mu(channel_idx), sqrt(trainedModel.trainingAnomalyScoreFeatures.covar(channel_idx, channel_idx))));
        end
        anomalyScores(isinf(anomalyScores)) = 100; % Cap scores
        anomalyScores = sum(anomalyScores, 2);
    case 'channelwise-gauss'
        for channel_idx = 1:numChannels
            anomalyScores(:, channel_idx) = -log(1 - cdf('Normal', anomalyScores(:, channel_idx), ...
                trainedModel.trainingAnomalyScoreFeatures.mu(channel_idx), sqrt(trainedModel.trainingAnomalyScoreFeatures.covar(channel_idx, channel_idx))));
        end
        anomalyScores(isinf(anomalyScores)) = 100; % Cap scores
    otherwise
        % Do nothing
end
end

function anomalyScores = applyScoringFunction(trainedModel, anomalyScores)
%APPLYSCORINGFUNCTION Applys a scoring function to the anomaly scores

% Apply scoring function
numChannels = size(anomalyScores, 2);

switch trainedModel.modelOptions.hyperparameters.scoringFunction
    case "Aggregated"
        % Only has an effect for multivariate data
        if numChannels > 1
            for channel_idx = 1:numChannels
                anomalyScores(:, channel_idx) = anomalyScores(:, channel_idx) - trainedModel.trainingAnomalyScoreFeatures.mu(channel_idx);
            end
            anomalyScores = rms(anomalyScores, 2);
        end
    case "Channel-wise"
        % Only has an effect for multivariate data
        if numChannels > 1
            for channel_idx = 1:numChannels
                anomalyScores(:, channel_idx) = anomalyScores(:, channel_idx) - trainedModel.trainingAnomalyScoreFeatures.mu(channel_idx);
            end
        end
    case "Gauss"
        anomalyScores = -log(1 - mvncdf(anomalyScores, trainedModel.trainingAnomalyScoreFeatures.mu, trainedModel.trainingAnomalyScoreFeatures.covar));
        anomalyScores(isinf(anomalyScores)) = 100; % Cap scores
    case "Gauss (aggregated)"
        for channel_idx = 1:numChannels
            anomalyScores(:, channel_idx) = -log(1 - cdf("Normal", anomalyScores(:, channel_idx), ...
                trainedModel.trainingAnomalyScoreFeatures.mu(channel_idx), sqrt(trainedModel.trainingAnomalyScoreFeatures.covar(channel_idx, channel_idx))));
        end
        anomalyScores(isinf(anomalyScores)) = 100; % Cap scores
        anomalyScores = sum(anomalyScores, 2);
    case "Gauss (channel-wise)"
        for channel_idx = 1:numChannels
            anomalyScores(:, channel_idx) = -log(1 - cdf("Normal", anomalyScores(:, channel_idx), ...
                trainedModel.trainingAnomalyScoreFeatures.mu(channel_idx), sqrt(trainedModel.trainingAnomalyScoreFeatures.covar(channel_idx, channel_idx))));
        end
        anomalyScores(isinf(anomalyScores)) = 100; % Cap scores
    case "EWMA"
        anomalyScores = rms(anomalyScores, 2);
    
        smoothingFactor = 0.7;
        weights = (smoothingFactor).^(0:size(anomalyScores, 1) - 1);
        weights = weights / sum(weights);

        anomalyScores(:, 1) = filter(weights, 1, anomalyScores(:, 1));
    otherwise
        % Do nothing
end
end

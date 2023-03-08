function anomalyScores = applyScoringFunction(trainedModel, anomalyScores)
%DETECTWITH
%
% Runs the detection and returns anomaly Scores

% Apply scoring function
numChannels = size(anomalyScores, 2);

switch trainedModel.options.hyperparameters.scoringFunction.value
    case 'channelwise-errors'
        if numChannels > 1
            for i = 1:numChannels
                anomalyScores(:, i) = anomalyScores(:, i) - trainedModel.trainingAnomalyScoreFeatures.mu(i);
            end
        end
    case 'aggregated-errors'
        if numChannels > 1
            for i = 1:numChannels
                anomalyScores(:, i) = anomalyScores(:, i) - trainedModel.trainingAnomalyScoreFeatures.mu(i);
            end
            anomalyScores = rms(anomalyScores, 2);
        end
    case 'gauss'
        anomalyScores = -log(1 - mvncdf(anomalyScores, trainedModel.trainingAnomalyScoreFeatures.mu, trainedModel.trainingAnomalyScoreFeatures.covar));
        anomalyScores(isinf(anomalyScores)) = 0; % Does this make sense?
    case 'aggregated-gauss'
        for i = 1:numChannels
            anomalyScores(:, i) = -log(1 - cdf('Normal', anomalyScores(:, i), ...
                trainedModel.trainingAnomalyScoreFeatures.mu(i), sqrt(trainedModel.trainingAnomalyScoreFeatures.covar(i, i))));
        end
        anomalyScores(isinf(anomalyScores)) = 0; % Does this make sense?
        anomalyScores = sum(anomalyScores, 2);
    case 'channelwise-gauss'
        for i = 1:numChannels
            anomalyScores(:, i) = -log(1 - cdf('Normal', anomalyScores(:, i), ...
                trainedModel.trainingAnomalyScoreFeatures.mu(i), sqrt(trainedModel.trainingAnomalyScoreFeatures.covar(i, i))));
        end
        anomalyScores(isinf(anomalyScores)) = 0; % Does this make sense?
    otherwise
        % Do nothing
end
end

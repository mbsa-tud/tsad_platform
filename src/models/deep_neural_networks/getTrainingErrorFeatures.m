function features = getTrainingErrorFeatures(trainedModel, X, Y)
switch trainedModel.options.model
    case 'Your model'
    otherwise
        if isfield(trainedModel.options, 'hyperparameters')
            if isfield(trainedModel.options.hyperparameters, 'scoringFunction')
                % Remove scoring function field to not apply a scoring function
                % for this step
                trainedModel.options.hyperparameters = rmfield(trainedModel.options.hyperparameters, 'scoringFunction');
            end
        end

        anomalyScores = [];
        for i = 1:size(X, 1)
            anomalyScores_tmp = detectWith(trainedModel, X{i, 1}, Y{i, 1}, []);
            anomalyScores = [anomalyScores; anomalyScores_tmp];
        end

        features.mu = mean(anomalyScores, 1);
        features.covar = cov(anomalyScores);
end
end
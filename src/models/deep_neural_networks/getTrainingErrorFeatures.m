function features = getTrainingErrorFeatures(options, Mdl, X, Y)
switch options.model
    case 'Your model'
    otherwise
        if isfield(options, 'scoringFunction')
            % Remove scoring function field to not apply a scoring function
            % for this step
            options = rmfield(options, 'scoringFunction');
        end

        anomalyScores = [];
        for i = 1:size(X, 1)
            anomalyScores_tmp = detectWithDNN_wrapper(options, Mdl, X{i, 1}, Y{i, 1}, [], []);
            anomalyScores = [anomalyScores; anomalyScores_tmp];
        end

        features.mu = mean(anomalyScores, 1);
        features.covar = cov(anomalyScores);
end
end
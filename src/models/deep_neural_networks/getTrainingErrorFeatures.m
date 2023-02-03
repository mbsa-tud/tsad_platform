function features = getTrainingErrorFeatures(options, Mdl, X, Y)
switch options.model
    case 'Your model'
    otherwise
        if isfield(options, 'scoringFunction')
            % Remove scoring function field to not apply a scoring function
            % for this step
            options = rmfield(options, 'scoringFunction');
        end
        anomalyScores = detectWithDNN_wrapper(options, Mdl, X, Y, [], []);
        features.mu = mean(anomalyScores, 1);
        features.covar = cov(anomalyScores);
end
end
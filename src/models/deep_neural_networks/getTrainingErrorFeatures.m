function [trainingErrors, features] = getTrainingErrorFeatures(trainedModel, X, Y)
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

        trainingErrors = [];
        for i = 1:size(X, 1)
            trainingErrors_tmp = detectWith(trainedModel, X{i, 1}, Y{i, 1}, [], false);
            trainingErrors = [trainingErrors; trainingErrors_tmp];
        end

        features.mu = mean(trainingErrors, 1);
        features.covar = cov(trainingErrors);
end
end
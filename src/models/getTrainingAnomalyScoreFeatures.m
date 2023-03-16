function [trainingAnomalyScores, trainingAnomalyScoreFeatures] = getTrainingAnomalyScoreFeatures(trainedModel, X, Y)
%GETTRAININGANOMALYSCOREFEATURES Get the raw anomaly scores and their
%statistical features for the training data


switch trainedModel.modelOptions.name
    case 'Your model'
    otherwise
        trainingAnomalyScores = [];
        for i = 1:size(X, 1)
            trainingAnomalyScores_tmp = detectWithModel(trainedModel, X{i, 1}, Y{i, 1}, [], false);
            trainingAnomalyScores = [trainingAnomalyScores; trainingAnomalyScores_tmp];
        end

        trainingAnomalyScoreFeatures.mu = mean(trainingAnomalyScores, 1);
        trainingAnomalyScoreFeatures.covar = cov(trainingAnomalyScores);
end
end
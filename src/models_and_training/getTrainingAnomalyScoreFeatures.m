function [trainingAnomalyScores, trainingAnomalyScoreFeatures] = getTrainingAnomalyScoreFeatures(trainedModel, X, Y)
%GETTRAININGANOMALYSCOREFEATURES Get the raw anomaly scores and their
%statistical features for the training data

fprintf("Calculating anomaly scores for training data ...\n");

switch trainedModel.modelOptions.name
    case "Your model"
    otherwise
        trainingAnomalyScores = [];
        for data_idx = 1:size(X, 1)
            trainingAnomalyScores_tmp = detectWithModel(trainedModel, X{data_idx, 1}, Y{data_idx, 1}, [], false);
            trainingAnomalyScores = [trainingAnomalyScores; trainingAnomalyScores_tmp];
        end

        trainingAnomalyScoreFeatures.mu = mean(trainingAnomalyScores, 1);
        trainingAnomalyScoreFeatures.covar = cov(trainingAnomalyScores);
end
end
function [trainingAnomalyScores, trainingAnomalyScoreFeatures, trainingLabels] = getTrainingAnomalyScoreFeatures(trainedModel, dataTrain, labelsTrain)
%GETTRAININGANOMALYSCOREFEATURES Get the raw anomaly scores and their
%statistical features for the training data

fprintf("Calculating anomaly scores for training data ...\n");

switch trainedModel.modelOptions.name
    case "Your model"
    otherwise
        trainingAnomalyScores = [];
        trainingLabels = [];
        
        % Get anomaly scores for every file of training data
        for data_idx = 1:numel(dataTrain)            
            [XTrainTest_tmp, TSTrainTest_tmp, labelsTrainTest_tmp] = dataTestPreparationWrapper(trainedModel.modelOptions, dataTrain(data_idx), labelsTrain(data_idx));
            
            % Get anomaly scores and store in one array
            trainingAnomalyScores_tmp = detectWith(trainedModel, XTrainTest_tmp, TSTrainTest_tmp, [], false);
            trainingAnomalyScores = [trainingAnomalyScores; trainingAnomalyScores_tmp];
            
            % Store labels in one array
            trainingLabels = [trainingLabels; labelsTrainTest_tmp];
        end

        trainingAnomalyScoreFeatures.mu = mean(trainingAnomalyScores, 1);
        trainingAnomalyScoreFeatures.covar = cov(trainingAnomalyScores);
end
end
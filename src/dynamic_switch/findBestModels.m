function bestModels = findBestModels(trainedModels, dataTest, labelsTest, filesTest, threshold, dynamicThresholdSettings, cmpMetric)
%FINDBESTMODELS
%
% Labels the test dataset according to what model is best using the
% cmpMetric as the comparison metric

allScores = evaluateAllModels(trainedModels, dataTest, labelsTest, filesTest, threshold, dynamicThresholdSettings);
allModelNames = fieldnames(trainedModels);

switch cmpMetric
    case 'F1 Score (point-wise)'
        score_idx = 1;
    case 'F1 Score (event-wise)'
        score_idx = 2;
    case 'F1 Score (point-adjusted)'
        score_idx = 3;
    case 'F1 Score (composite)'
        score_idx = 4;
    case 'F0.5 Score (point-wise)'
        score_idx = 5;
    case 'F0.5 Score (event-wise)'
        score_idx = 6;
    case 'F0.5 Score (point-adjusted)'
        score_idx = 7;
    case 'F0.5 Score (composite)'
        score_idx = 8;
    case 'Precision (point-wise)'
        score_idx = 9;
    case 'Precision (event-wise)'
        score_idx = 10;
    case 'Precision (point-adjusted)'
        score_idx = 11;
    case 'Recall (point-wise)'
        score_idx = 12;
    case 'Recall (event-wise)'
        score_idx = 13;
    case 'Recall (point-adjusted)'
        score_idx = 14;
end

scores_all = allScores{1, 1};
for i = 1:length(scores_all)
    [~, idx] = max(scores_all{i, 1}(score_idx, :));
    
    bestModels.(filesTest(i)) = allModelNames{idx};
end
end
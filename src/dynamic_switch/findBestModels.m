function bestModels = findBestModels(trainedModels, dataTest, labelsTest, filesTest, threshold, cmpMetric)
%FINDBESTMODELS
%
% Labels the test dataset according to what model is best using the
% cmpMetric as the comparison metric

allScores = evaluateAllModels(trainedModels, dataTest, labelsTest, filesTest, threshold);
allModelNames = fieldnames(trainedModels);

switch cmpMetric
    case 'Composite F1 Score'
        score_idx = 1;
    case 'Point-wise F1 Score'
        score_idx = 2;
    case 'Event-wise F1 Score'
        score_idx = 3;
    case 'Point-adjusted F1 Score'
        score_idx = 4;
    case 'Composite F0.5 Score'
        score_idx = 5;
    case 'Point-wise F0.5 Score'
        score_idx = 6;
    case 'Event-wise F0.5 Score'
        score_idx = 7;
    case 'Point-adjusted F0.5 Score'
        score_idx = 8;
    case 'Point-wise Precision'
        score_idx = 9;
    case 'Event-wise Precision'
        score_idx = 10;
    case 'Point-adjusted Precision'
        score_idx = 11;
    case 'Point-wise Recall'
        score_idx = 12;
    case 'Event-wise Recall'
        score_idx = 13;
    case 'Point-adjusted Recall'
        score_idx = 14;
end

scores_all = allScores{1, 1};
for i = 1:length(scores_all)
    [~, idx] = max(scores_all{i, 1}(score_idx, :));
    
    bestModels.(filesTest(i)) = allModelNames{idx};
end
end
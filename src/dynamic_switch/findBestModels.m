function bestModels = findBestModels(trainedModels, dataTest, labelsTest, filesTest, threshold, dynamicThresholdSettings, selectedMetric)
%FINDBESTMODELS Labels the test dataset according to what model is best
%using the cmpMetric as the measure of performance

allScores = evaluateAllModels(trainedModels, dataTest, labelsTest, filesTest, threshold, dynamicThresholdSettings);
allModelIds = fieldnames(trainedModels);

[~, score_idx] = ismember(selectedMetric, METRIC_NAMES);

scores_all = allScores{1, 1};
for data_idx = 1:length(scores_all)
    [~, idx] = max(scores_all{data_idx, 1}(score_idx, :));
    
    bestModels.(filesTest(data_idx)).id = allModelIds{idx};
    bestModels.(filesTest(data_idx)).label = trainedModels.(allModelIds{idx}).modelOptions.label;
end
end
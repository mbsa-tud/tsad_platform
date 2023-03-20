function bestModels = findBestModels(trainedModels, dataTest, labelsTest, filesTest, threshold, dynamicThresholdSettings, selectedMetric)
%FINDBESTMODELS Labels the test dataset according to what model is best
%using the cmpMetric as the measure of performance

allScores = evaluateAllModels(trainedModels, dataTest, labelsTest, filesTest, threshold, dynamicThresholdSettings);
allModelIds = fieldnames(trainedModels);

[~, scoreIdx] = ismember(selectedMetric, METRIC_NAMES);

scores_all = allScores{1, 1};
for i = 1:length(scores_all)
    [~, idx] = max(scores_all{i, 1}(scoreIdx, :));
    
    bestModels.(filesTest(i)).id = allModelIds{idx};
    bestModels.(filesTest(i)).label = trainedModels.(allModelIds{idx}).modelOptions.label;
end
end
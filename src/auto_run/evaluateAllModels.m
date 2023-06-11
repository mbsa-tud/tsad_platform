function finalScores = evaluateAllModels(trainedModels, dataTest, labelsTest, fileNamesTest, thresholds, dynamicThresholdSettings, getCompTime)
% EVALUATEALLMODELS Tests all specified trained models on the test data for
% all selected thresholds and returns the scores


finalScores = cell(numel(thresholds), 1);
for i = 1:numel(finalScores)
    finalScores{i} = cell(numel(fileNamesTest), 1);
end


% Detection
if ~isempty(trainedModels)
    fprintf("\nDetecting with models\n\n")
    trainedModelIds = fieldnames(trainedModels);

    for model_idx = 1:numel(trainedModelIds)
        trainedModel = trainedModels.(trainedModelIds{model_idx});
        
        fprintf("Detecting with: %s\n", trainedModel.modelOptions.label);

        % For all test files
        for data_idx = 1:numel(fileNamesTest)
            [XTest, TSTest, labels] = dataTestPreparationWrapper(trainedModel.modelOptions, dataTest(data_idx), labelsTest(data_idx));
                
            [anomalyScores, compTime] = detectionWrapper(trainedModel, XTest, TSTest, labels, getCompTime);
            
            % For all thresholds in the thresholds variable
            for thr_idx = 1:numel(thresholds)
                if ~trainedModel.modelOptions.outputsLabels
                    [predictedLabels, ~] = applyThresholdToAnomalyScores(trainedModel, anomalyScores, labels, thresholds(thr_idx), dynamicThresholdSettings);
                else
                    predictedLabels = anomalyScores;
                end

                scores = [compTime; computeMetrics(anomalyScores, predictedLabels, labels)];
        
                tmp = finalScores{thr_idx};
                tmp{data_idx} = [tmp{data_idx}, scores];
                finalScores{thr_idx} = tmp;
            end
        end
    end
end
end
function finalScores = evaluateAllModels(trainedModels, dataTest, labelsTest, filesTest, thresholds, dynamicThresholdSettings)
% EVALUATEALLMODELS Tests all specified trained models on the test data for
% all selected thresholds and returns the scores


finalScores = cell(length(thresholds), 1);
for tmp_idx = 1:length(finalScores)
    finalScores{tmp_idx, 1} = cell(length(filesTest), 1);
end


% Detection
if ~isempty(trainedModels)
    fprintf('\nDetecting with models\n\n')
    fields = fieldnames(trainedModels);

    for model_idx = 1:length(fields)
        trainedModel = trainedModels.(fields{model_idx});
        
        fprintf("Detecting with: %s\n", trainedModel.modelOptions.label);

        % For all test files
        for data_idx = 1:length(filesTest)
            [XTest, YTest, labels] = prepareDataTest(trainedModel.modelOptions, dataTest(data_idx, 1), labelsTest(data_idx, 1));
                
            anomalyScores = detectionWrapper(trainedModel, XTest, YTest, labels);
            
            % For all thresholds in the thresholds variable
            for thr_idx = 1:length(thresholds)
                if ~trainedModel.modelOptions.outputsLabels
                    [predictedLabels, ~] = applyThresholdToAnomalyScores(trainedModel, anomalyScores, labels, thresholds(thr_idx), dynamicThresholdSettings);
                else
                    predictedLabels = anomalyScores;
                end

                scores = calcScores(anomalyScores, predictedLabels, labels, trainedModel.modelOptions.outputsLabels);
        
                tmp = finalScores{thr_idx, 1};
                tmp{data_idx, 1} = [tmp{data_idx, 1}, scores];
                finalScores{thr_idx, 1} = tmp;
            end
        end
    end
end
end
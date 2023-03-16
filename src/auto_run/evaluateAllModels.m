function finalScores = evaluateAllModels(trainedModels, dataTest, labelsTest, filesTest, thresholds, dynamicThresholdSettings)
% EVALUATEALLMODELS Tests all specified trained models on the test data and
% returns the scores


finalScores = cell(length(thresholds), 1);
for tmpIdx = 1:length(finalScores)
    finalScores{tmpIdx, 1} = cell(length(filesTest), 1);
end


% Detection
if ~isempty(trainedModels)
    fprintf('\nDetecting with models\n\n')
    fields = fieldnames(trainedModels);

    for modelIdx = 1:length(fields)
        trainedModel = trainedModels.(fields{modelIdx});
        
        fprintf("Detecting with: %s\n", trainedModel.modelOptions.label);

        % For all test files
        for dataIdx = 1:length(filesTest)
            [XTest, YTest, labels] = prepareDataTest(trainedModel.modelOptions, dataTest(dataIdx, 1), labelsTest(dataIdx, 1));
                
            anomalyScores = detectWith(trainedModel, XTest, YTest, labels);
            
            % For all thresholds in the thresholds variable
            for thrIdx = 1:length(thresholds)
                if ~trainedModel.modelOptions.outputsLabels
                    [predictedLabels, ~] = applyThresholdToAnomalyScores(trainedModel, anomalyScores, labels, thresholds(thrIdx), dynamicThresholdSettings);
                else
                    predictedLabels = anomalyScores;
                end

                [scoresPointwise, scoresEventwise, ...
                    scoresPointAdjusted, scoresComposite] = calcScores(predictedLabels, labels);
                
                fullScores = [scoresPointwise(3); ...
                                scoresEventwise(3); ...
                                scoresPointAdjusted(3); ...
                                scoresComposite(1); ...
                                scoresPointwise(4); ...
                                scoresEventwise(4); ...
                                scoresPointAdjusted(4); ...
                                scoresComposite(2); ...
                                scoresPointwise(1); ...
                                scoresEventwise(1); ...
                                scoresPointAdjusted(1); ...
                                scoresPointwise(2); ...
                                scoresEventwise(2); ...
                                scoresPointAdjusted(2)];
        
                tmp = finalScores{thrIdx, 1};
                tmp{dataIdx, 1} = [tmp{dataIdx, 1}, fullScores];
                finalScores{thrIdx, 1} = tmp;
            end
        end
    end
end
end
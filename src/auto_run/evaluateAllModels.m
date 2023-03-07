function tmpScores = evaluateAllModels(trainedModels, dataTest, labelsTest, filesTest, thresholds, dynamicThresholdSettings)
% EVALUATEALLMODELS
% 
% Tests all models on a the data within the dataTest argument


tmpScores = cell(length(thresholds), 1);
for tmpIdx = 1:length(tmpScores)
    tmpScores{tmpIdx, 1} = cell(length(filesTest), 1);
end


% Detection
if ~isempty(trainedModels)
    fprintf('\nDetecting with models\n\n')
    fields = fieldnames(trainedModels);

    for modelIdx = 1:length(fields)
        trainedModel = trainedModels.(fields{modelIdx});
        
        fprintf("Detecting with: %s\n", trainedModel.options.model);

        % For all test files
        for dataIdx = 1:length(filesTest)
            [XTest, YTest, labels] = prepareDataTest(trainedModel.options, dataTest(dataIdx, 1), labelsTest(dataIdx, 1));
                
            anomalyScores = detectWith(trainedModel, XTest, YTest, labels);
            
            % For all thresholds in the thresholds variable
            for thrIdx = 1:length(thresholds)
                if ~trainedModel.options.outputsLabels
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
        
                tmp = tmpScores{thrIdx, 1};
                tmp{dataIdx, 1} = [tmp{dataIdx, 1}, fullScores];
                tmpScores{thrIdx, 1} = tmp;
            end
        end
    end
end
end
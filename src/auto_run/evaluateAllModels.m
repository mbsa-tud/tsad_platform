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

    for j = 1:length(fields)
        trainedModel = trainedModels.(fields{j});
    
        % For all test files
        for dataIdx = 1:length(filesTest)
            switch trainedModel.options.type
                case 'DNN'
                    [XTest, YTest, labels] = prepareDataTest_DNN_wrapper(trainedModel.options, dataTest(dataIdx, 1), labelsTest(dataIdx, 1));
                        
                    anomalyScores = detectWithDNN_wrapper(trainedModel, XTest, YTest, labels);
                case 'CML'
                    [XTest, YTest, labels] = prepareDataTest_CML_wrapper(trainedModel.options, dataTest(dataIdx, 1), labelsTest(dataIdx, 1));

                    anomalyScores = detectWithCML_wrapper(trainedModel, XTest, YTest, labels);
                case 'S'
                    [XTest, YTest, labels] = prepareDataTest_S_wrapper(trainedModel.options, dataTest(dataIdx, 1), labelsTest(dataIdx, 1));

                    anomalyScores = detectWithS_wrapper(trainedModel, XTest, YTest, labels);
            end
            
            % For all thresholds in the thresholds variable
            for k = 1:length(thresholds)
                if ~trainedModel.options.outputsLabels
                    if ~strcmp(thresholds(k), 'dynamic')
                        % Static thresholds
                        if ~isempty(trainedModel.staticThreshold) && isfield(trainedModel.staticThreshold, thresholds(k))  
                            selectedThreshold = trainedModel.staticThreshold.(thresholds(k));
                        else
                            selectedThreshold = thresholds(k);
                        end
           
                        predictedLabels = calcStaticThresholdPrediction(anomalyScores, labels, selectedThreshold, trainedModel.options.model);
                    else
                        % Dynamic threshold            
                        [predictedLabels, ~] = calcDynamicThresholdPrediction(anomalyScores, labels, dynamicThresholdSettings); 
                    end
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
        
                tmp = tmpScores{k, 1};
                tmp{dataIdx, 1} = [tmp{dataIdx, 1}, fullScores];
                tmpScores{k, 1} = tmp;
            end
        end
    end
end
end
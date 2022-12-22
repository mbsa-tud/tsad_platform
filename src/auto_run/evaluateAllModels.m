function tmpScores = evaluateAllModels(trainedModels, dataTest, labelsTest, filesTest, thresholds)
% EVALUATEALLMODELS
% 
% Tests all models on a the data within the dataTest argument


tmpScores = cell(length(thresholds), 1);
for tmpIdx = 1:length(tmpScores)
    tmpScores{tmpIdx, 1} = cell(length(filesTest), 1);
end


% Detection
if ~isempty(trainedModels)
    fprintf('Detecting with models\n')
    fields = fieldnames(trainedModels);

    for j = 1:length(fields)
        trainedModel = trainedModels.(fields{j});
        options = trainedModel.options;
        Mdl = trainedModel.Mdl;
    
        % For all test files
        for dataIdx = 1:length(filesTest)
            switch options.type
                case 'DNN'
                    [XTest, YTest, labels] = prepareDataTest_DNN(options, dataTest(dataIdx, 1), labelsTest(dataIdx, 1));
                        
                    anomalyScores = detectWithDNN(options, Mdl, XTest, YTest, labels, options.scoringFunction, trainedModel.pd);
                case 'CML'
                    [XTest, YTest, labels] = prepareDataTest_CML(options, dataTest(dataIdx, 1), labelsTest(dataIdx, 1));

                    anomalyScores = detectWithCML(options, Mdl, XTest, YTest, labels);
                case 'S'
                    [XTest, YTest, labels] = prepareDataTest_S(options, dataTest(dataIdx, 1), labelsTest(dataIdx, 1));

                    anomalyScores = detectWithS(options, Mdl, XTest, YTest, labels);
            end

            staticThreshold =  trainedModel.staticThreshold;
            
            % For all thresholds in the thresholds variable
            for k = 1:length(thresholds)
                if ~strcmp(thresholds(k), 'dynamic')
                    % Static thresholds
                    if ~isempty(staticThreshold) && isfield(staticThreshold, thresholds(k))  
                        selectedThreshold = staticThreshold.(thresholds(k));
                    else
                        selectedThreshold = thresholds(k);
                    end
       
                    anoms = calcStaticThresholdPrediction(anomalyScores, labels, selectedThreshold, options.model);
                else
                    % Dynamic threshold
                    % TODO: make this configurable
                    if iscell(YTest)
                        windowSize = floor(size(YTest{1, 1}, 1) / 2);
                    else
                        windowSize = floor(size(YTest, 1) / 2);
                    end
                    padding = 3;
                    z_range = 1:2;
                    min_percent = 1;
            
                    [anoms, ~] = calcDynamicThresholdPrediction(anomalyScores, labels, padding, ...
                        windowSize, min_percent, z_range); 
                end

                [scoresPointwise, scoresEventwise, ...
                    scoresPointAdjusted, scoresComposite] = calcScores(anoms, labels);
                
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
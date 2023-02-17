function [tmpScores, filesTest, trainedModels, preprocParameters] = GT_trainAndEvaluateAllModels(datasetPath, models_DNN, models_CML, models_S, ...
                                        preprocMethod, ratioTestVal, thresholds, dynamicThresholdSettings, trainingPlots, trainParallel,augmentationChoice,intensity,trained)
% EVALUATEALLMODELS
% 
% Trains and tests all models on a dataset

fprintf('Loading data\n')
% Loading data
[rawDataTrain, ~, labelsTrain, ~, ...
    rawDataTest, ~, labelsTest, filesTest] = loadCustomDataset(datasetPath);

if size(rawDataTest{1, 1}, 2) > 1
    isMultivariate = true;
else
    isMultivariate = false;
end

fprintf('Preprocessing data with method: %s\n', preprocMethod);
% Preprocessing
[dataTrain, dataTest, preprocParameters] = preprocessData(rawDataTrain, ...
                                                            rawDataTest, ...
                                                            preprocMethod, ...
                                                            false, ...
                                                            []); 
% Augmentation
[dataTrain,dataTest]=augmentationData(dataTrain,dataTest,augmentationChoice,intensity,trained);

% Splitting test/val set
[dataTest, labelsTest, filesTest, ...
    dataTestVal, labelsTestVal, ~] = splitTestVal(dataTest, labelsTest, filesTest, ratioTestVal);

% Training DNN models
if ~isempty(models_DNN)
    fprintf('Training DNN models\n')
    
    if trainParallel && ~isMultivariate
        trainedModels_DNN = trainModels_DNN_Parallel(models_DNN, ...
                                                        dataTrain, ...
                                                        labelsTrain, ...
                                                        dataTestVal, ...
                                                        labelsTestVal, ...
                                                        settings_thresholds, ...
                                                        false);
    else
        trainedModels_DNN = trainModels_DNN_Consecutive(models_DNN, ...
                                                        dataTrain, ...
                                                        labelsTrain, ...
                                                        dataTestVal, ...
                                                        labelsTestVal, ...
                                                        thresholds, ...
                                                        trainingPlots, ...
                                                        trainParallel);
    end

    fields = fieldnames(trainedModels_DNN);
    for f_idx = 1:length(fields)
        trainedModels.(fields{f_idx}) = trainedModels_DNN.(fields{f_idx});
    end
end

if ~isempty(models_CML)
    % Training CML models
    fprintf('Training CML models\n')
    trainedModels_CML = trainModels_CML(models_CML, dataTrain, labelsTrain, ...
                                        dataTestVal, labelsTestVal, thresholds);
    fields = fieldnames(trainedModels_CML);
    for f_idx = 1:length(fields)
        trainedModels.(fields{f_idx}) = trainedModels_CML.(fields{f_idx});
    end
end

if ~isempty(models_S)
    % Training S models
    fprintf('Training Statistical models\n')
    trainedModels_S = trainModels_S(models_S, dataTrain, labelsTrain,  ...
                                        dataTestVal, labelsTestVal, thresholds);
    fields = fieldnames(trainedModels_S);
    for f_idx = 1:length(fields)
        trainedModels.(fields{f_idx}) = trainedModels_S.(fields{f_idx});
    end
end

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
    
        % For all files in the test folder
        for dataIdx = 1:length(filesTest)
            switch options.type
                case 'DNN'
                    [XTest, YTest, labels] = prepareDataTest_DNN_wrapper(options, dataTest(dataIdx, 1), labelsTest(dataIdx, 1));
                        
                    anomalyScores = detectWithDNN_wrapper(options, Mdl, XTest, YTest, labels, trainedModel.trainingErrorFeatures);
                case 'CML'
                    [XTest, YTest, labels] = prepareDataTest_CML_wrapper(options, dataTest(dataIdx, 1), labelsTest(dataIdx, 1));

                    anomalyScores = detectWithCML_wrapper(options, Mdl, XTest, YTest, labels);
                case 'S'
                    [XTest, YTest, labels] = prepareDataTest_S_wrapper(options, dataTest(dataIdx, 1), labelsTest(dataIdx, 1));

                    anomalyScores = detectWithS_wrapper(options, Mdl, XTest, YTest, labels);
            end

            staticThreshold = trainedModel.staticThreshold;
            
            % For all thresholds in the thresholds variable
            for k = 1:length(thresholds)
                if ~options.outputsLabels
                    if ~strcmp(thresholds(k), 'dynamic')
                        % Static thresholds
                        if ~isempty(staticThreshold) && isfield(staticThreshold, thresholds(k))  
                            selectedThreshold = staticThreshold.(thresholds(k));
                        else
                            selectedThreshold = thresholds(k);
                        end
           
                        predictedLabels = calcStaticThresholdPrediction(anomalyScores, labels, selectedThreshold, options.model);
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
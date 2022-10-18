function [tmpScores, filesTestingData, trainedModels] = evaluateAllModels(datasetPath, testFolderName, models_DNN, models_CML, models_S, ...
                                        preprocMethod, ratioTestVal, thresholds, saveModels, savePreprocParams)
% EVALUATEALLMODELS
% 
% Trains and tests all models on a dataset

fprintf('Loading data\n')
% Loading data
[rawTrainingData, ~, labelsTrainingData, ~, ...
    rawTestingData, ~, labelsTestingData, filesTestingData] = loadCustomDataset(datasetPath, testFolderName);

if size(rawTestingData{1, 1}, 2) > 1
    isMultivariate = true;
else
    isMultivariate = false;
end

fprintf('Preprocessing data with method: %s\n', preprocMethod);
% Preprocessing
[preprocessedTrainingData, ...
    preprocessedTestingData, maximum, minimum, mu, sigma] = preprocessData(rawTrainingData, rawTestingData, preprocMethod, false, []);         

if savePreprocParams
    preprocParams.maximum = maximum;
    preprocParams.minimum = minimum;
    preprocParams.mu = mu;
    preprocParams.sigma = sigma;
    preprocParams.preprocMethod = preprocMethod;

    fileID = fopen(fullfile(datasetPath, 'preprocParams.json'), 'w');
    fprintf(fileID, jsonencode(preprocParams, PrettyPrint=true));
    fclose(fileID);
end

% Splitting test/val set
[preprocessedTestingData, labelsTestingData, ...
    testValData, testValLabels, filesTestingData] = splitTestVal(preprocessedTestingData, labelsTestingData, ratioTestVal, filesTestingData);

% Training DNN models
if ~isempty(models_DNN)
    fprintf('Training DNN models\n')
    if isMultivariate
        trainedModels_DNN = trainModels_DNN_Consecutive(models_DNN, preprocessedTrainingData, ...
                                                        labelsTrainingData, testValData, ...
                                                        testValLabels, thresholds);
    else
        trainedModels_DNN = trainModels_DNN_Parallel(models_DNN, preprocessedTrainingData, ...
                                                        labelsTrainingData, testValData, ...
                                                        testValLabels, thresholds, true);
    end
    fields = fieldnames(trainedModels_DNN);
    for f_idx = 1:length(fields)
        trainedModels.(fields{f_idx}) = trainedModels_DNN.(fields{f_idx});
    end
end

if ~isempty(models_CML)
    % Training CML models
    fprintf('Training CML models\n')
    trainedModels_CML = trainModels_CML(models_CML, preprocessedTrainingData, ...
                                        testValData, testValLabels, thresholds);
    fields = fieldnames(trainedModels_CML);
    for f_idx = 1:length(fields)
        trainedModels.(fields{f_idx}) = trainedModels_CML.(fields{f_idx});
    end
end

if ~isempty(models_S)
    % Training S models
    fprintf('Training Statistical models\n')
    trainedModels_S = trainModels_S(models_S, preprocessedTrainingData, ...
                                        testValData, testValLabels, thresholds);
    fields = fieldnames(trainedModels_S);
    for f_idx = 1:length(fields)
        trainedModels.(fields{f_idx}) = trainedModels_S.(fields{f_idx});
    end
end

% Save models to models.mat file
if saveModels
    fileName = fullfile(datasetPath, 'models.mat');
    assignin('base', 'allModels', trainedModels);
    save(fileName, 'trainedModels');
end

tmpScores = cell(length(thresholds), 1);
for tmpIdx = 1:length(tmpScores)
    tmpScores{tmpIdx, 1} = cell(length(filesTestingData), 1);
end


% Detection with DNN models
if ~isempty(trainedModels)
    fprintf('Detecting with models\n')
    fields = fieldNames(trainedModels);

    for j = 1:length(fields)
        trainedModel = trainedModels.(fields{j});
        options = trainedModel.options;
        Mdl = trainedModel.Mdl;
    
        % For all files in the test folder
        for dataIdx = 1:length(filesTestingData)
            switch options.type
                case 'DNN'
                    [XTest, YTest, labels] = prepareDataTest_DNN(options, preprocessedTestingData(dataIdx, 1), labelsTestingData(dataIdx, 1));
                        
                    [anomalyScores, YTest, labels] = detectWithDNN(options, Mdl, XTest, YTest, labels);
                case 'CML'
                    [XTest, YTest, labels] = prepareDataTest_CML(options, preprocessedTestingData(dataIdx, 1), labelsTestingData(dataIdx, 1));

                    [anomalyScores, YTest, labels] = detectWithCML(options, Mdl, XTest, YTest, labels);
                case 'S'
                    [XTest, YTest, labels] = prepareDataTest_S(options, preprocessedTestingData(dataIdx, 1), labelsTestingData(dataIdx, 1));

                    [anomalyScores, YTest, labels] = detectWithS(options, Mdl, XTest, YTest, labels);
            end

            staticThreshold =  trainedModel.staticThreshold;
            
            % For all thresholds in the thresholds variable
            for k = 1:length(thresholds)
                if ~strcmp(thresholds(k), 'dynamic')
                    % Static thresholds

                    if ~options.calcThresholdLast
                        if isfield(staticThreshold, thresholds(k))
                            selectedThreshold = staticThreshold.(thresholds(k));
                        else
                            thrFields = fieldnames(staticThreshold);
                            selectedThreshold = staticThreshold.(thrFields{1});
                        end
                    else
                        selectedThreshold = thresholds(k);
                    end

                    if iscell(YTest)
                        YTest = cell2mat(YTest);
                    end
       
                    anomsStatic = calcStaticThresholdPrediction(anomalyScores, labels, selectedThreshold, options.calcThresholdLast, options.model);

                    [scoresPointwiseStatic, scoresEventwiseStatic, ...
                        scoresPointAdjustedStatic, scoresCompositeStatic] = calcScores(anomsStatic, labels);
                    
                    fullScores = [scoresCompositeStatic(1); ...
                                    scoresPointwiseStatic(3); ...
                                    scoresEventwiseStatic(3); ...
                                    scoresPointAdjustedStatic(3); ...
                                    scoresCompositeStatic(2); ...
                                    scoresPointwiseStatic(4); ...
                                    scoresEventwiseStatic(4); ...
                                    scoresPointAdjustedStatic(4); ...
                                    scoresPointwiseStatic(1); ...
                                    scoresEventwiseStatic(1); ...
                                    scoresPointAdjustedStatic(1); ...
                                    scoresPointwiseStatic(2); ...
                                    scoresEventwiseStatic(2); ...
                                    scoresPointAdjustedStatic(2)];
                else
                    % Dynamic threshold
                    if iscell(YTest)
                        windowSize = floor(size(YTest{1, 1}, 1) / 2);
                    else
                        windowSize = floor(length(YTest) / 2);
                    end
                    padding = 3;
                    z_range = 1:2;
                    min_percent = 1;
            
                    [anomsDynamic, ~] = calcDynamicThresholdPrediction(anomalyScores, labels, padding, ...
                        windowSize, min_percent, z_range);
                    [scoresPointwiseDynamic, scoresEventwiseDynamic, ...
                        scoresPointAdjustedDynamic, scoresCompositeDynamic] = calcScores(anomsDynamic, labels);

                    fullScores = [scoresCompositeDynamic(1); ...
                                    scoresPointwiseDynamic(3); ...
                                    scoresEventwiseDynamic(3); ...
                                    scoresPointAdjustedDynamic(3); ...
                                    scoresCompositeDynamic(2); ...
                                    scoresPointwiseDynamic(4); ...
                                    scoresEventwiseDynamic(4); ...
                                    scoresPointAdjustedDynamic(4); ...
                                    scoresPointwiseDynamic(1); ...
                                    scoresEventwiseDynamic(1); ...
                                    scoresPointAdjustedDynamic(1); ...
                                    scoresPointwiseDynamic(2); ...
                                    scoresEventwiseDynamic(2); ...
                                    scoresPointAdjustedDynamic(2)];
                end
        
                tmp = tmpScores{k, 1};
                tmp{dataIdx, 1} = [tmp{dataIdx, 1}, fullScores];
                tmpScores{k, 1} = tmp;
            end
        end
    end
end
end
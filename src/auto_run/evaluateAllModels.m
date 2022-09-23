function [tmpScores, filesTestingData, trainedModels] = evaluateAllModels(datasetPath, testFolderName, models_DNN, models_CML, models_S, ...
                                        preprocMethod, ratioTestVal, thresholds, saveModels, savePreprocParams)
% EVALUATEALLMODELS % evaluat all models for a dataset
% Description: Run training and detection all files of the selected dataset
%
% Input: datasetPath:    string - path to the dataset. should contain a 
%                                 train and a test folder with the time
%                                 series data in .csv format with 
%                                 the columns:
%                                 timestamp, value1, value2, ..., is_anomaly
%        preprocMethod:  string - method for preprocessing
%                                 Possible values: raw data, 
%                                                  standardize, 
%                                                  rescale
%        ratioTestVal:   double (0, 1] - ratio of validation set to full
%                                        test set
%        thresholds:     strings - thresholds to use for evaluation.
%                                  should be subset of:
%                                  ["bestFscorePointwise", ...
%                                  "bestFscoreEventwise", ...
%                                  "bestFscorePointAdjusted", ...
%                                  "bestFscoreComposite", ...
%                                  "bestFscorePointwiseGauss", ...
%                                  "bestFscoreEventwiseGauss", ...
%                                  "bestFscorePointAdjustedGauss", ...
%                                  "bestFscoreCompositeGauss", ...
%                                  "topK", ...
%                                  "meanStd"]
%       saveModels:     boolean - if true, save trained models to
%                                 datasetPath
%       savePreprocParams: boolean - if true, save preprocessing parameters
%                                    to datasetPath
%
% Output: tmpScores:   table - scores for all models
%         filesTestingData: strings - all filenames of testing dataset

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
        allModels.(fields{f_idx}) = trainedModels_DNN.(fields{f_idx});
    end
end

if ~isempty(models_CML)
    % Training CML models
    fprintf('Training CML models\n')
    trainedModels_CML = trainModels_CML(models_CML, preprocessedTrainingData, ...
                                        testValData, testValLabels, thresholds);
    fields = fieldnames(trainedModels_CML);
    for f_idx = 1:length(fields)
        allModels.(fields{f_idx}) = trainedModels_CML.(fields{f_idx});
    end
end

if ~isempty(models_S)
    % Training S models
    fprintf('Training Statistical models\n')
    trainedModels_S = trainModels_S(models_S, preprocessedTrainingData, ...
                                        testValData, testValLabels, thresholds);
    fields = fieldnames(trainedModels_S);
    for f_idx = 1:length(fields)
        allModels.(fields{f_idx}) = trainedModels_S.(fields{f_idx});
    end
end

% Save models to models.mat file
if saveModels
    fileName = fullfile(datasetPath, 'models.mat');
    assignin('base', 'allModels', allModels);
    save(fileName, 'allModels');
end

tmpScores = cell(length(thresholds), 1);
for tmpIdx = 1:length(tmpScores)
    tmpScores{tmpIdx, 1} = cell(length(filesTestingData), 1);
end

% Detection with DNN models
if ~isempty(models_DNN)
    fprintf('Detecting with DNN models\n')
    for j = 1:length(models_DNN)
        trainedModel = trainedModels_DNN.(models_DNN(j).options.id);
        options = trainedModel.options;
        Mdl = trainedModel.Mdl;
    
        % For all files in the test folder
        for dataIdx = 1:length(filesTestingData)            
            [XTest, YTest, labels] = prepareDataTest_DNN(options, preprocessedTestingData(dataIdx, 1), labelsTestingData(dataIdx, 1));
                
            [anomalyScores, YTest, labels] = detectWithDNN(options, Mdl, XTest, YTest, labels);
    
            staticThreshold =  trainedModel.staticThreshold;
            
            % For all thresholds in the thresholds variable
            for k = 1:length(thresholds)
                if ~strcmp(thresholds(k), 'dynamic')
                    % Static thresholds
                    if isfield(staticThreshold, thresholds(k))
                        selectedThreshold = staticThreshold.(thresholds(k));

                        if endsWith(thresholds(k), 'Gauss')
                            pd = trainedModel.pd;
                            useGaussianScores = true;
                        else
                            pd = 0;
                            useGaussianScores = false;
                        end
                    else
                        thrFields = fieldnames(staticThreshold);
                        selectedThreshold = staticThreshold.(thrFields{1});

                        if endsWith(thrFields{1}, 'Gauss')
                            pd = trainedModel.pd;
                            useGaussianScores = true;
                        else
                            pd = 0;
                            useGaussianScores = false;
                        end
                    end                    
            
                    anomsStatic = calcStaticThresholdPrediction(anomalyScores, selectedThreshold, pd, useGaussianScores);
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
                    padding = 3;
                    windowSize = floor(size(YTest{1, 1}, 1) / 2);           
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

% Detection with CML models
if ~isempty(models_CML)
    fprintf('Detecting with CML models\n')
    for j = 1:length(models_CML)
        trainedModel = trainedModels_CML.(models_CML(j).options.id);
        options = trainedModel.options;
    
        % For all files in the test folder
        for dataIdx = 1:length(filesTestingData)            
            Mdl = trainedModel.Mdl;

            [XTest, YTest, labels] = prepareDataTest_CML(options, preprocessedTestingData(dataIdx, 1), labelsTestingData(dataIdx, 1));

            [anomalyScores, YTest, labels] = detectWithCML(options, Mdl, XTest, YTest, labels);

            staticThreshold = trainedModel.staticThreshold;
            
            % For all thresholds in the thresholds variable
            for k = 1:length(thresholds)
                if ~strcmp(thresholds(k), 'dynamic')
                    % Static thresholds
                    if isfield(staticThreshold, thresholds(k))
                        selectedThreshold = staticThreshold.(thresholds(k));

                        if endsWith(thresholds(k), 'Gauss')
                            pd = trainedModel.pd;
                            useGaussianScores = true;
                        else
                            pd = 0;
                            useGaussianScores = false;
                        end
                    else
                        thrFields = fieldnames(staticThreshold);
                        selectedThreshold = staticThreshold.(thrFields{1});

                        if endsWith(thrFields{1}, 'Gauss')
                            pd = trainedModel.pd;
                            useGaussianScores = true;
                        else
                            pd = 0;
                            useGaussianScores = false;
                        end
                    end 
            
                    anomsStatic = calcStaticThresholdPrediction(anomalyScores, selectedThreshold, pd, useGaussianScores);
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
                    padding = 3;
                    windowSize = floor(size(YTest, 1) / 2);           
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

% Detection with S models
if ~isempty(models_S)
    fprintf('Detecting with S models\n')
    for j = 1:length(models_S)
        trainedModel = trainedModels_S.(models_S(j).options.id);
        options = trainedModel.options;
    
        % For all files in the test folder
        for dataIdx = 1:length(filesTestingData)            
            Mdl = trainedModel.Mdl;

            [XTest, YTest, labels] = prepareDataTest_S(options, preprocessedTestingData(dataIdx, 1), labelsTestingData(dataIdx, 1));

            [anomalyScores, YTest, labels] = detectWithS(options, Mdl, XTest, YTest, labels);

            staticThreshold = trainedModel.staticThreshold;
            
            % For all thresholds in the thresholds variable
            for k = 1:length(thresholds)
                if ~strcmp(thresholds(k), 'dynamic')
                    % Static thresholds
                    if isfield(staticThreshold, thresholds(k))
                        selectedThreshold = staticThreshold.(thresholds(k));

                        if endsWith(thresholds(k), 'Gauss')
                            pd = trainedModel.pd;
                            useGaussianScores = true;
                        else
                            pd = 0;
                            useGaussianScores = false;
                        end
                    else
                        thrFields = fieldnames(staticThreshold);
                        selectedThreshold = staticThreshold.(thrFields{1});

                        if endsWith(thrFields{1}, 'Gauss')
                            pd = trainedModel.pd;
                            useGaussianScores = true;
                        else
                            pd = 0;
                            useGaussianScores = false;
                        end
                    end 
            
                    anomsStatic = calcStaticThresholdPrediction(anomalyScores, selectedThreshold, pd, useGaussianScores);
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
                    padding = 3;
                    windowSize = floor(size(YTest, 1) / 2);           
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

% Sort trained models into struct to return
if ~isempty(models_DNN)
    fields = fieldnames(trainedModels_DNN);
    for i = 1:numel(fields)
        trainedModels.(fields{i}) = trainedModels_DNN.(fields{i});
    end
end
if ~isempty(models_CML)
    fields = fieldnames(trainedModels_CML);
    for i = 1:numel(fields)
        trainedModels.(fields{i}) = trainedModels_CML.(fields{i});
    end
end
if ~isempty(models_S)
    fields = fieldnames(trainedModels_S);
    for i = 1:numel(fields)
        trainedModels.(fields{i}) = trainedModels_S.(fields{i});
    end
end
end
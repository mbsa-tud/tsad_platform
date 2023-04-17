function [finalScores, filesTest] = trainAndEvaluateAllModels(datasetPath, models, ...
                                        preprocMethod, ratioTestVal, thresholds, ...
                                        dynamicThresholdSettings, trainingPlots, ...
                                        parallelEnabled, augmentationEnabled, ...
                                        augmentationMode, augmentationIntensity, ...
                                        augmentedTrainingEnabled)
%TRAINANDEVALUATEALLMODELS Trains all specified models on a single dataset
%and returns all scores and file names of test data

fprintf('\nLoading data\n\n')
% Loading data
[dataTrainRaw, ~, labelsTrain, ~, ...
    dataTestRaw, ~, labelsTest, filesTest, ~] = loadCustomDataset(datasetPath);

if isempty(dataTestRaw) && isempty(dataTrainRaw)
    error("Invalid dataset selected");
end

fprintf('\nPreprocessing data with method: %s\n', preprocMethod);
% Preprocessing
[dataTrain, dataTest, ~] = preprocessData(dataTrainRaw, ...
                                            dataTestRaw, ...
                                            preprocMethod, ...
                                            false, ...
                                            []);

if ~augmentationEnabled
    % Splitting test/val set
    [dataTest, labelsTest, filesTest, ...
        dataTestVal, labelsTestVal, ~] = splitTestVal(dataTest, labelsTest, filesTest, ratioTestVal);
    
    % Train all models
    trainedModels = trainAllModels(models, dataTrain, labelsTrain, dataTestVal, labelsTestVal, thresholds, trainingPlots, parallelEnabled);
    
    % Run detection and get scores
    finalScores = evaluateAllModels(trainedModels, dataTest, labelsTest, filesTest, thresholds, dynamicThresholdSettings);
else
    % Evaluation with data augmentation
    fprintf("\n\nRunning with data augmentation\n\n");

    % Augment data
    [dataTrainAugmented, dataTestAugmented] = augmentData(dataTrain, dataTest, augmentationMode, augmentationIntensity, augmentedTrainingEnabled);

    % Splitting test/val set
    [dataTestAugmented, labelsTestAugmented, filesTestAugmented, ...
        dataTestValAugmented, labelsTestValAugmented, ~] = splitTestVal(dataTestAugmented, labelsTest, filesTest, ratioTestVal);
    
    % Train all models
    trainedModels = trainAllModels(models, dataTrainAugmented, labelsTrain, dataTestValAugmented, labelsTestValAugmented, thresholds, trainingPlots, parallelEnabled);
    
    % Run detection and get scores
    allScoresWithAugmentation = evaluateAllModels(trainedModels, dataTestAugmented, labelsTestAugmented, filesTestAugmented, thresholds, dynamicThresholdSettings);


    % Evaluation without augmentation for comparison
    fprintf("\n\nRunning without data augmentation\n\n");

    % Splitting test/val set
    [dataTest, labelsTest, filesTest, ...
        dataTestVal, labelsTestVal, ~] = splitTestVal(dataTest, labelsTest, filesTest, ratioTestVal);
    
    % Train all models
    trainedModels = trainAllModels(models, dataTrain, labelsTrain, dataTestVal, labelsTestVal, thresholds, trainingPlots, parallelEnabled);
    
    % Run detection and get scores
    allScoresWithoutAugmentation = evaluateAllModels(trainedModels, dataTest, labelsTest, filesTest, thresholds, dynamicThresholdSettings);


    % Reorder scores
    numTestedFiles = numel(filesTest);
    numModels = numel(fieldnames(trainedModels));
    finalScores = cell(numel(thresholds), 1);

    for thr_idx = 1:numel(thresholds)
        scores = allScoresWithoutAugmentation{thr_idx, 1};
        scoresAugmented = allScoresWithAugmentation{thr_idx, 1};
        scoresMerged = cell(numTestedFiles, 1);
    
        for data_idx = 1:numTestedFiles
            for model_idx = 1:numModels
                scoresMerged{data_idx, 1} = [scoresMerged{data_idx, 1}, ...
                    scores{data_idx, 1}(:, model_idx), ...
                    scoresAugmented{data_idx, 1}(:, model_idx)];
            end
        end
        finalScores{thr_idx, 1} = [finalScores{thr_idx, 1}; scoresMerged];
    end
end
end
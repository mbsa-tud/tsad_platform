function [finalScores, fileNamesTest] = trainAndEvaluateAllModels(datasetPath, models, ...
                                                                  preprocMethod, ratioTestVal, thresholds, ...
                                                                  dynamicThresholdSettings, trainingPlots, ...
                                                                  parallelEnabled, augmentationEnabled, ...
                                                                  augmentationMode, augmentationIntensity, ...
                                                                  augmentedTrainingEnabled, getCompTime)
%TRAINANDEVALUATEALLMODELS Trains all specified models on a single dataset
%and returns all scores and file names of test data

fprintf("\nLoading data\n\n")
% Loading data
[dataTrainRaw, ~, labelsTrain, ~, ...
    dataTestRaw, ~, labelsTest, fileNamesTest, ~] = loadCustomDataset(datasetPath);

if isempty(dataTestRaw) && isempty(dataTrainRaw)
    error("Invalid dataset selected");
end

fprintf("\nPreprocessing data with method: %s\n", preprocMethod);
% Preprocessing
[dataTrain, dataTest, ~] = preprocessData(dataTrainRaw, ...
                                            dataTestRaw, ...
                                            preprocMethod, ...
                                            false, ...
                                            []);

if ~augmentationEnabled
    % Splitting test/val set
    [dataTest, labelsTest, fileNamesTest, ...
        dataTestVal, labelsTestVal, ~] = splitTestVal(dataTest, labelsTest, fileNamesTest, ratioTestVal);
    
    % Train all models
    trainedModels = trainAllModels(models, dataTrain, labelsTrain, dataTestVal, labelsTestVal, thresholds, trainingPlots, parallelEnabled);
    
    % Run detection and get scores
    finalScores = evaluateAllModels(trainedModels, dataTest, labelsTest, fileNamesTest, thresholds, dynamicThresholdSettings, getCompTime);
else
    % Augment data
    [dataTrainAugmented, dataTestAugmented] = augmentData(dataTrain, dataTest, augmentationMode, augmentationIntensity, augmentedTrainingEnabled);
    

    % Splitting test/val set for augmented and non-augmented data
    [dataTestAugmented, ~, ~, ...
        dataTestValAugmented, ~, ~] = splitTestVal(dataTestAugmented, labelsTest, fileNamesTest, ratioTestVal);
    [dataTest, labelsTest, fileNamesTest, ...
        dataTestVal, labelsTestVal, ~] = splitTestVal(dataTest, labelsTest, fileNamesTest, ratioTestVal);
    

    % Evaluation without augmentation for comparison
    fprintf("\n\nRunning without data augmentation\n\n");
    
    % Train all models
    trainedModels = trainAllModels(models, dataTrain, labelsTrain, dataTestVal, labelsTestVal, thresholds, trainingPlots, parallelEnabled);
    
    % Run detection and get scores
    allScoresWithoutAugmentation = evaluateAllModels(trainedModels, dataTest, labelsTest, fileNamesTest, thresholds, dynamicThresholdSettings, getCompTime);
    

    % Evaluation with data augmentation
    fprintf("\n\nRunning with data augmentation\n\n");

    % Train all models
    trainedModels = trainAllModels(models, dataTrainAugmented, labelsTrain, dataTestValAugmented, labelsTestVal, thresholds, trainingPlots, parallelEnabled);
    
    % Run detection and get scores
    allScoresWithAugmentation = evaluateAllModels(trainedModels, dataTestAugmented, labelsTest, fileNamesTest, thresholds, dynamicThresholdSettings, getCompTime);


    % Reorder scores
    numTestedFiles = numel(fileNamesTest);
    numModels = numel(fieldnames(trainedModels));
    finalScores = cell(numel(thresholds), 1);

    for thr_idx = 1:numel(thresholds)
        scores = allScoresWithoutAugmentation{thr_idx};
        scoresAugmented = allScoresWithAugmentation{thr_idx};
        scoresMerged = cell(numTestedFiles, 1);
    
        for data_idx = 1:numTestedFiles
            for model_idx = 1:numModels
                scoresMerged{data_idx} = [scoresMerged{data_idx}, ...
                    scores{data_idx}(:, model_idx), ...
                    scoresAugmented{data_idx}(:, model_idx)];
            end
        end
        finalScores{thr_idx} = [finalScores{thr_idx}; scoresMerged];
    end
end
end
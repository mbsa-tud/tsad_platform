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
[rawDataTrain, ~, labelsTrain, ~, ...
    rawDataTest, ~, labelsTest, filesTest, ~] = loadCustomDataset(datasetPath);

if isempty(rawDataTest) && isempty(rawDataTrain)
    error("Invalid dataset selected");
end

fprintf('\nPreprocessing data with method: %s\n', preprocMethod);
% Preprocessing
[dataTrain, dataTest, ~] = preprocessData(rawDataTrain, ...
                                            rawDataTest, ...
                                            preprocMethod, ...
                                            false, ...
                                            []);

if augmentationEnabled
    % Augmentation
    [dataTrain, dataTest] = augmentData(dataTrain, dataTest, augmentationMode, augmentationIntensity, augmentedTrainingEnabled);
end

% Splitting test/val set
[dataTest, labelsTest, filesTest, ...
    dataTestVal, labelsTestVal, ~] = splitTestVal(dataTest, labelsTest, filesTest, ratioTestVal);

% Train all models
trainedModels = trainAllModels(models, dataTrain, labelsTrain, dataTestVal, labelsTestVal, thresholds, trainingPlots, parallelEnabled);

% Run detection and get scores
finalScores = evaluateAllModels(trainedModels, dataTest, labelsTest, filesTest, thresholds, dynamicThresholdSettings);
end
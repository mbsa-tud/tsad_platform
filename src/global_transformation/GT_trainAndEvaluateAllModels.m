function [finalScores, filesTest] = GT_trainAndEvaluateAllModels(datasetPath, models, ...
                                        preprocMethod, ratioTestVal, thresholds, dynamicThresholdSettings, trainingPlots, ...
                                        parallelEnabled, augmentationChoice, intensity, trained)
%GT_TRAINANDEVALUATEALLMODELS Trains all specified models on a single dataset
%with data augmentation and returns all scores and testing file names

fprintf('\nLoading data\n\n')
% Loading data
[rawDataTrain, ~, labelsTrain, ~, ...
    rawDataTest, ~, labelsTest, filesTest, ~] = loadCustomDataset(datasetPath);

if isempty(rawDataTest) && isempty(rawDataTrain)
    error("Invalid dataset selected");
end

fprintf('\nPreprocessing data with method: %s\n\n', preprocMethod);
% Preprocessing
[dataTrain, dataTest, ~] = preprocessData(rawDataTrain, ...
                                            rawDataTest, ...
                                            preprocMethod, ...
                                            false, ...
                                            []); 
% Augmentation
[dataTrain,dataTest] = augmentationData(dataTrain,dataTest,augmentationChoice,intensity,trained);

% Splitting test/val set
[dataTest, labelsTest, filesTest, ...
    dataTestVal, labelsTestVal, ~] = splitTestVal(dataTest, labelsTest, filesTest, ratioTestVal);

% Train models
trainedModels = trainAllModels(models, dataTrain, labelsTrain, dataTestVal, labelsTestVal, thresholds, trainingPlots, parallelEnabled);

% Run detection and get scores
finalScores = evaluateAllModels(trainedModels, dataTest, labelsTest, filesTest, thresholds, dynamicThresholdSettings);
end
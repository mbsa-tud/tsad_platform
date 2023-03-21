function [finalScores, filesTest] = trainAndEvaluateAllModels(datasetPath, models_DNN, models_CML, models_S, ...
                                        preprocMethod, ratioTestVal, thresholds, dynamicThresholdSettings, trainingPlots, trainParallel)
%TRAINANDEVALUATEALLMODELS Trains all specified models on a single dataset
%and returns all scores and testing file names

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

% Splitting test/val set
[dataTest, labelsTest, filesTest, ...
    dataTestVal, labelsTestVal, ~] = splitTestVal(dataTest, labelsTest, filesTest, ratioTestVal);

% Train all models
trainedModels = trainAllModels(models_DNN, models_CML, models_S, dataTrain, labelsTrain, dataTestVal, labelsTestVal, thresholds, trainingPlots, trainParallel);

% Run detection and get scores
finalScores = evaluateAllModels(trainedModels, dataTest, labelsTest, filesTest, thresholds, dynamicThresholdSettings);
end
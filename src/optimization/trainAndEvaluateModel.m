function scoresCell = trainAndEvaluateModel(modelOptions, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, threshold, dynamicThresholdSettings, trainingPlots, trainParallel)
%TRAINANDEVALUATEMODEL Train and test a model and return scores
%   This function does the entire pipeline for a single model from training
%   to caluclating a threshold and running tests. It returns all scores.

scoresCell = cell(size(dataTest, 1), 1);

model.modelOptions = modelOptions;

% Train model
trainedModel = trainModels(model, dataTrain, ...
                            labelsTrain, dataValTest, ...
                            labelsValTest, threshold, ...
                            trainingPlots, trainParallel);

% Run detection
for data_idx = 1:size(dataTest, 1)
    fullScores = detectAndEvaluateWith(trainedModel.(modelOptions.id), dataTest(data_idx, 1), labelsTest(data_idx, 1), threshold, dynamicThresholdSettings);

    scoresCell{data_idx, 1} = fullScores;
end
end
function scoresCell = trainAndEvaluateModel(modelOptions, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, threshold, dynamicThresholdSettings, trainingPlots, parallelEnabled)
%TRAINANDEVALUATEMODEL Train and test a model and return scores
%   This function does the entire pipeline for a single model from training
%   to caluclating a threshold and running tests. It returns all scores.

scoresCell = cell(numel(dataTest), 1);

model.modelOptions = modelOptions;

% Train model
trainedModel = trainingWrapper(model, dataTrain, ...
                            labelsTrain, dataValTest, ...
                            labelsValTest, threshold, ...
                            trainingPlots, parallelEnabled);

% Run detection for all test files
for data_idx = 1:numel(dataTest)
    fullScores = detectAndEvaluateWith(trainedModel.(modelOptions.id), dataTest(data_idx), labelsTest(data_idx), threshold, dynamicThresholdSettings);

    scoresCell{data_idx} = fullScores;
end
end
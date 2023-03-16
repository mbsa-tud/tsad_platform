function scoresCell = trainAndEvaluateModel(modelOptions, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, threshold, dynamicThresholdSettings, trainingPlots, trainParallel)
%TRAINANDEVALUATEMODEL Train and test a model and return scores
%   This function does the entire pipeline for a single model from training
%   to caluclating a threshold and running tests. It returns all scores.

scoresCell = cell(size(dataTest, 1), 1);

model.modelOptions = modelOptions;

switch modelOptions.type
    case 'DNN'
        trainedModel = trainModels_DNN_Consecutive(model, dataTrain, ...
                                                labelsTrain, dataValTest, ...
                                                labelsValTest, threshold, ...
                                                trainingPlots, trainParallel);
    case 'CML'
        trainedModel = trainModels_CML(model, dataTrain, labelsTrain, ...
                                                dataValTest, labelsValTest, threshold);
    case 'S'
        trainedModel = trainModels_S(model, dataTrain, labelsTrain, ...
                                        dataValTest, labelsValTest, threshold);
end

for dataIdx = 1:size(dataTest, 1)
    fullScores = detectAndEvaluateWith(trainedModel.(modelOptions.id), dataTest(dataIdx, 1), labelsTest(dataIdx, 1), threshold, dynamicThresholdSettings);

    scoresCell{dataIdx, 1} = fullScores;
end
end
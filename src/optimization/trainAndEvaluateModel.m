function scoresCell = trainAndEvaluateModel(options, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, threshold, dynamicThresholdSettings, trainingPlots, trainParallel)
%FITANDEVALUATEMODEL_CML
%
% Trains and tests the selected model configured in the options parameter

scoresCell = cell(size(dataTest, 1), 1);

model.options = options;

switch options.type
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
    fullScores = detectAndEvaluateWith(trainedModel.(options.id), dataTest(dataIdx, 1), labelsTest(dataIdx, 1), threshold, dynamicThresholdSettings);

    scoresCell{dataIdx, 1} = fullScores;
end
end
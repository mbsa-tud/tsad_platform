function scoresCell = fitAndEvaluateModel_CML(options, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, threshold, dynamicThresholdSettings)
%FITANDEVALUATEMODEL_CML
%
% Trains and tests the selected model configured in the options parameter

scoresCell = cell(size(dataTest, 1), 1);

model.options = options;
trainedModel = trainModels_CML(model, dataTrain, labelsTrain, ...
                                        dataValTest, labelsValTest, threshold);

for dataIdx = 1:size(dataTest, 1)
    fullScores = detectAndEvaluateWith(trainedModel.(options.id), dataTest(dataIdx, 1), labelsTest(dataIdx, 1), threshold, dynamicThresholdSettings);

    scoresCell{dataIdx, 1} = fullScores;
end
end
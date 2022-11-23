function scoresCell = fitAndEvaluateModel_S(options, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, ratioValTest, thresholds)
%FITANDEVALUATEMODEL_S
%
% Trains and tests the selected model configured in the options parameter

scoresCell = cell(size(dataTest, 1), 1);

model.options = options;

trainedModel = trainModels_CML(model, dataTrain, ...
                                        dataValTest, labelsValTest, ratioValTest, thresholds);

options = trainedModel.(options.id).options;
Mdl = trainedModel.(options.id).Mdl;
staticThreshold = trainedModel.(options.id).staticThreshold;

if ~options.calcThresholdLast    
    fields = fieldnames(staticThreshold);
    selectedThreshold = staticThreshold.(fields{1});
else
    selectedThreshold = thresholds(1);
end

for dataIdx = 1:size(dataTest, 1)
    [XTest, YTest, labelsTrain] = prepareDataTest_S(options, dataTest(dataIdx, 1), labelsTest(dataIdx, 1));
    [anomalyScores, ~, labelsTrain] = detectWithS(options, Mdl, XTest, YTest, labelsTrain);
    
    [labels_pred, ~] = calcStaticThresholdPrediction(anomalyScores, labelsTrain, selectedThreshold, options.calcThresholdLast, options.model);
    [scoresPointwise, scoresEventwise, scoresPointAdjusted, scoresComposite] = calcScores(labels_pred, labelsTrain);

   fullScores = [scoresComposite(1); ...
                    scoresPointwise(3); ...
                    scoresEventwise(3); ...
                    scoresPointAdjusted(3); ...
                    scoresComposite(2); ...
                    scoresPointwise(4); ...
                    scoresEventwise(4); ...
                    scoresPointAdjusted(4); ...
                    scoresPointwise(1); ...
                    scoresEventwise(1); ...
                    scoresPointAdjusted(1); ...
                    scoresPointwise(2); ...
                    scoresEventwise(2); ...
                    scoresPointAdjusted(2)];
    scoresCell{dataIdx, 1} = fullScores;
end
end
function scoresCell = fitAndEvaluateModel_DNN(options, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, ratioValTest, threshold)
%FITANDEVALUATEMODEL_DNN
%
% Trains and tests the selected model configured in the options parameter

scoresCell = cell(size(dataTest, 1), 1);

model.options = options;

trainedModel = trainModels_DNN_Consecutive(model, dataTrain, ...
                                                labelsTrain, dataValTest, ...
                                                labelsValTest, ratioValTest, threshold, 'none');

options = trainedModel.(options.id).options;
Mdl = trainedModel.(options.id).Mdl;
pd = trainedModel.(options.id).pd;
staticThreshold = trainedModel.(options.id).staticThreshold;

if ~options.calcThresholdLast
    fields = fieldnames(staticThreshold);
    selectedThreshold = staticThreshold.(fields{1});
else
    selectedThreshold = threshold;
end

for dataIdx = 1:size(dataTest, 1)
    [XTest, YTest, labels] = prepareDataTest_DNN(options, dataTest(dataIdx, 1), labelsTest(dataIdx, 1));
    
    anomalyScores = detectWithDNN(options, Mdl, XTest, YTest, labels, options.scoringFunction, pd);
    
    [labels_pred, ~] = calcStaticThresholdPrediction(anomalyScores, labels, selectedThreshold, options.calcThresholdLast, options.model);
    [scoresPointwise, scoresEventwise, scoresPointAdjusted, scoresComposite] = calcScores(labels_pred, labels);

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
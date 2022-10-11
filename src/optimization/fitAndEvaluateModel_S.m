function scoresCell = fitAndEvaluateModel_S(options, trainingData, trainingLabels, testValData, testValLabels, testingData, testingLabels, thresholds)
%FITANDEVALUATEMODEL_S
%
% Trains and tests the selected model configured in the options parameter

scoresCell = cell(size(testingData, 1), 1);

if ~options.trainOnAnomalousData
    XTrain = prepareDataTrain_S(options, trainingData);
else
    XTrain = prepareDataTrain_S(options, testValData);
end

Mdl = trainS(options, XTrain);

if ~options.calcThresholdLast
    staticThreshold = getStaticThreshold_S(options, Mdl, XTrain, testValData, testValLabels, thresholds);
    fields = fieldnames(staticThreshold);
    selectedThreshold = staticThreshold.(fields{1});
else
    selectedThreshold = thresholds(1);
end

for dataIdx = 1:size(testingData, 1)
    [XTest, YTest, labels] = prepareDataTest_S(options, testingData(dataIdx, 1), testingLabels(dataIdx, 1));
    [anomalyScores, ~, labels] = detectWithS(options, Mdl, XTest, YTest, labels);
    
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
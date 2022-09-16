function scoresCell = fitAndEvaluateModel_CML(options, trainingData, trainingLabels, testValData, testValLabels, testingData, testingLabels, thresholds)
scoresCell = cell(size(testingData, 1), 1);

[XTrain, XVal] = prepareDataTrain_CML(options, trainingData);

Mdl = trainCML(options, XTrain);

[staticThreshold, ~] = getStaticThreshold_CML(options, Mdl, XTrain, XVal, testValData, testValLabels, thresholds);

fields = fieldnames(staticThreshold);
selectedThreshold = staticThreshold.(fields{1});

for dataIdx = 1:size(testingData, 1)
    [XTest, labels] = prepareDataTest_CML(options, testingData(dataIdx, 1), testingLabels(dataIdx, 1));
    [anomalyScores, ~, labels] = detectWithCML(options, Mdl, XTest, labels);
    
    labels_pred = calcStaticThresholdPrediction(anomalyScores, selectedThreshold, 0, false);
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
function scoresCell = fitAndEvaluateModel_DNN(options, trainingData, trainingLabels, testValData, testValLabels, testingData, testingLabels, thresholds)
%FITANDEVALUATEMODEL_DNN
%
% Trains and tests the selected model configured in the options parameter

[XTrain, YTrain, XVal, YVal] = prepareDataTrain_DNN(options, trainingData, trainingLabels);

[Mdl, ~] = trainDNN(options, XTrain, YTrain, XVal, YVal, 'none');

if ~options.calcThresholdLast
    staticThreshold = getStaticThreshold_DNN(options, Mdl, XTrain, YTrain, XVal, YVal, testValData, testValLabels, thresholds);
    fields = fieldnames(staticThreshold);
    selectedThreshold = staticThreshold.(fields{1});
else
    selectedThreshold = thresholds(1);
end

scoresCell = cell(size(testingData, 1), 1);

for dataIdx = 1:size(testingData, 1)
    [XTest, YTest, labels] = prepareDataTest_DNN(options, testingData(dataIdx, 1), testingLabels(dataIdx, 1));
    
    [anomalyScores, ~, labels] = detectWithDNN(options, Mdl, XTest, YTest, labels);
    
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
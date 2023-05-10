function scores = detectAndEvaluateWith(trainedModel, dataTest, labelsTest, threshold, dynamicThresholdSettings)
%DETECTANDEVALUATEWITH Runs the detection and returns the scores for the model

fprintf("Detecting with: %s\n", trainedModel.modelOptions.label);

[XTest, TSTest, labels] = prepareDataTest_Wrapper(trainedModel.modelOptions, dataTest, labelsTest);
    
anomalyScores = detectionWrapper(trainedModel, XTest, TSTest, labels);

if ~trainedModel.modelOptions.outputsLabels
    [predictedLabels, ~] = applyThresholdToAnomalyScores(trainedModel, anomalyScores, labels, threshold, dynamicThresholdSettings);
else
    predictedLabels = anomalyScores;
end

scores = calcScores(anomalyScores, predictedLabels, labels, trainedModel.modelOptions.outputsLabels);
end
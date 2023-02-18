function scores = detectAndEvaluateWith(trainedModel, dataTest, labelsTest, threshold, dynamicThresholdSettings)
%DETECTANDEVALUATEWITH
%
% Runs the detection and returns the scores for the model

switch trainedModel.options.type
    case 'DNN'
        [XTest, YTest, labels] = prepareDataTest_DNN_wrapper(trainedModel.options, dataTest, labelsTest);
            
        anomalyScores = detectWithDNN_wrapper(trainedModel, XTest, YTest, labels);
    case 'CML'        
        [XTest, YTest, labels] = prepareDataTest_CML_wrapper(trainedModel.options, dataTest, labelsTest);
        
        anomalyScores = detectWithCML_wrapper(trainedModel, XTest, YTest, labels);
    case 'S'        
        [XTest, YTest, labels] = prepareDataTest_S_wrapper(trainedModel.options, dataTest, labelsTest);
        
        anomalyScores = detectWithS_wrapper(trainedModel, XTest, YTest, labels);
end

if ~trainedModel.options.outputsLabels
    if ~strcmp(threshold, "dynamic")
        % Static threshold
    
        if ~isempty(trainedModel.staticThreshold) && isfield(trainedModel.staticThreshold, threshold)  
            selectedThreshold = trainedModel.staticThreshold.(threshold);
        else
            selectedThreshold = threshold;
        end
        
        predictedLabels = calcStaticThresholdPrediction(anomalyScores, labels, selectedThreshold, trainedModel.options.model);
    else
        % Dynamic threshold    
        [predictedLabels, ~] = calcDynamicThresholdPrediction(anomalyScores, labels, dynamicThresholdSettings);
    end
else
    predictedLabels = anomalyScores;
end

[scoresPointwise, scoresEventwise, ...
            scoresPointAdjusted, scoresComposite] = calcScores(predictedLabels, labels);

scores = [scoresPointwise(3); ...
            scoresEventwise(3); ...
            scoresPointAdjusted(3); ...
            scoresComposite(1); ...
            scoresPointwise(4); ...
            scoresEventwise(4); ...
            scoresPointAdjusted(4); ...
            scoresComposite(2); ...
            scoresPointwise(1); ...
            scoresEventwise(1); ...
            scoresPointAdjusted(1); ...
            scoresPointwise(2); ...
            scoresEventwise(2); ...
            scoresPointAdjusted(2)];
end
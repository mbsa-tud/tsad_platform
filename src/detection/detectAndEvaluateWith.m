function scores = detectAndEvaluateWith(model, dataTest, labelsTest, threshold, dynamicThresholdSettings)
%DETECTANDEVALUATEWITH
%
% Runs the detection and returns the scores for the model


options = model.options;
switch options.type
    case 'DNN'
        [XTest, YTest, labels] = prepareDataTest_DNN(options, dataTest, labelsTest);
            
        anomalyScores = detectWithDNN(options, model.Mdl, XTest, YTest, labels, options.scoringFunction, model.trainingErrorFeatures);
    case 'CML'        
        [XTest, YTest, labels] = prepareDataTest_CML(options, dataTest, labelsTest);
        
        anomalyScores = detectWithCML(options, model.Mdl, XTest, YTest, labels);
    case 'S'        
        [XTest, YTest, labels] = prepareDataTest_S(options, dataTest, labelsTest);
        
        anomalyScores = detectWithS(options, model.Mdl, XTest, YTest, labels);
end

if ~options.outputsLabels
    if ~strcmp(threshold, "dynamic")
        % Static threshold
    
        if ~isempty(model.staticThreshold) && isfield(model.staticThreshold, threshold)  
            selectedThreshold = model.staticThreshold.(threshold);
        else
            selectedThreshold = threshold;
        end
        
        predictedLabels = calcStaticThresholdPrediction(anomalyScores, labels, selectedThreshold, options.model);
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
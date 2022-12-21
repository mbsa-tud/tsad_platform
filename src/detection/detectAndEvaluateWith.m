function scores = detectAndEvaluateWith(model, dataTest, labelsTest, threshold)
%DETECTANDEVALUATEWITH
%
% Runs the detection and returns the scores for the model


options = model.options;
switch options.type
    case 'DNN'
        [XTest, YTest, labels] = prepareDataTest_DNN(options, dataTest, labelsTest);
            
        anomalyScores = detectWithDNN(options, model.Mdl, XTest, YTest, labels, options.scoringFunction, model.pd);
    case 'CML'        
        [XTest, YTest, labels] = prepareDataTest_CML(options, dataTest, labelsTest);
        
        anomalyScores = detectWithCML(options, model.Mdl, XTest, YTest, labels);
    case 'S'        
        [XTest, YTest, labels] = prepareDataTest_S(options, dataTest, labelsTest);
        
        anomalyScores = detectWithS(options, model.Mdl, XTest, YTest, labels);
end


if ~strcmp(threshold, "dynamic")
    % Static threshold

    if ~isempty(model.staticThreshold) && isfield(model.staticThreshold, threshold)  
        selectedThreshold = model.staticThreshold.(threshold);
    else
        selectedThreshold = threshold;
    end
    
    anoms = calcStaticThresholdPrediction(anomalyScores, labels, selectedThreshold, options.model);
    [scoresPointwise, scoresEventwise, ...
        scoresPointAdjusted, scoresComposite] = calcScores(anoms, labels);
else
    % Dynamic threshold
    % TODO: make this configurable
    
    if iscell(YTest)
        windowSize = floor(size(YTest{1, 1}, 1) / 2);
    else
        windowSize = floor(size(YTest, 1) / 2);
    end
    padding = 3;
    z_range = 1:2;
    min_percent = 1;
    
    [anoms, ~] = calcDynamicThresholdPrediction(anomalyScores, labels, padding, ...
        windowSize, min_percent, z_range);
    [scoresPointwise, scoresEventwise, ...
        scoresPointAdjusted, scoresComposite] = calcScores(anoms, labels);
end


scores = [scoresComposite(1); ...
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
end
function scores = detectAndEvaluateWith(model, dataTest, labelsTest, thresholds)
%DETECTANDEVALUATEWITH
%
% Runs the detection and returns the scores for the model


options = model.options;
switch options.type
    case 'DNN'
        [XTest, YTest, labels] = prepareDataTest_DNN(options, dataTest, labelsTest);
            
        anomalyScores = detectWithDNN(options, model.Mdl, XTest, YTest, labels, options.scoringFunction, model.pd);
        
        if ~options.calcThresholdLast
            staticThreshold = model.staticThreshold;
        
            thrFields = fieldnames(staticThreshold);
            selectedThreshold = staticThreshold.(thrFields{1});
        else
            selectedThreshold = thresholds(1);
        end
    
        anomsStatic = calcStaticThresholdPrediction(anomalyScores, labels, selectedThreshold, options.calcThresholdLast, options.model);
        [scoresPointwiseStatic, scoresEventwiseStatic, ...
            scoresPointAdjustedStatic, scoresCompositeStatic] = calcScores(anomsStatic, labels);
    
        padding = 3;
        windowSize = floor(size(YTest{1, 1}, 1) / 2);           
        z_range = 1:2;
        min_percent = 1;
    
        [anomsDynamic, ~] = calcDynamicThresholdPrediction(anomalyScores, labels, padding, ...
            windowSize, min_percent, z_range);
        [scoresPointwiseDynamic, scoresEventwiseDynamic, ...
            scoresPointAdjustedDynamic, scoresCompositeDynamic] = calcScores(anomsDynamic, labels);
    case 'CML'        
        [XTest, YTest, labels] = prepareDataTest_CML(options, dataTest, labelsTest);
        
        anomalyScores = detectWithCML(options, model.Mdl, XTest, YTest, labels);
        
        if ~options.calcThresholdLast
            staticThreshold = model.staticThreshold;
        
            thrFields = fieldnames(staticThreshold);
            selectedThreshold = staticThreshold.(thrFields{1});
        else
            selectedThreshold = thresholds(1);
        end
    
        anomsStatic = calcStaticThresholdPrediction(anomalyScores, labels, selectedThreshold, options.calcThresholdLast, options.model);
        [scoresPointwiseStatic, scoresEventwiseStatic, ...
            scoresPointAdjustedStatic, scoresCompositeStatic] = calcScores(anomsStatic, labels);
        
        padding = 3;
        windowSize = floor(size(YTest, 1) / 2);           
        z_range = 1:2;
        min_percent = 1;
        
        [anomsDynamic, ~] = calcDynamicThresholdPrediction(anomalyScores, labels, padding, ...
            windowSize, min_percent, z_range);
        [scoresPointwiseDynamic, scoresEventwiseDynamic, ...
            scoresPointAdjustedDynamic, scoresCompositeDynamic] = calcScores(anomsDynamic, labels);

    case 'S'        
        [XTest, YTest, labels] = prepareDataTest_S(options, dataTest, labelsTest);
        
        anomalyScores = detectWithS(options, model.Mdl, XTest, YTest, labels);
        
        if ~options.calcThresholdLast
            staticThreshold = model.staticThreshold;
        
            thrFields = fieldnames(staticThreshold);
            selectedThreshold = staticThreshold.(thrFields{1});
        else
            selectedThreshold = thresholds(1);
        end
    
        anomsStatic = calcStaticThresholdPrediction(anomalyScores, labels, selectedThreshold, options.calcThresholdLast, options.model);
        [scoresPointwiseStatic, scoresEventwiseStatic, ...
            scoresPointAdjustedStatic, scoresCompositeStatic] = calcScores(anomsStatic, labels);
        
        padding = 3;
        windowSize = floor(size(YTest, 1) / 2);           
        z_range = 1:2;
        min_percent = 1;
        
        [anomsDynamic, ~] = calcDynamicThresholdPrediction(anomalyScores, labels, padding, ...
            windowSize, min_percent, z_range);
        [scoresPointwiseDynamic, scoresEventwiseDynamic, ...
            scoresPointAdjustedDynamic, scoresCompositeDynamic] = calcScores(anomsDynamic, labels);

end

scores = [scoresCompositeStatic(1); ...
            scoresPointwiseStatic(3); ...
            scoresEventwiseStatic(3); ...
            scoresPointAdjustedStatic(3); ...
            scoresCompositeStatic(2); ...
            scoresPointwiseStatic(4); ...
            scoresEventwiseStatic(4); ...
            scoresPointAdjustedStatic(4); ...
            scoresPointwiseStatic(1); ...
            scoresEventwiseStatic(1); ...
            scoresPointAdjustedStatic(1); ...
            scoresPointwiseStatic(2); ...
            scoresEventwiseStatic(2); ...
            scoresPointAdjustedStatic(2); ...
            scoresCompositeDynamic(1); ...
            scoresPointwiseDynamic(3); ...
            scoresEventwiseDynamic(3); ...
            scoresPointAdjustedDynamic(3); ...
            scoresCompositeDynamic(2); ...
            scoresPointwiseDynamic(4); ...
            scoresEventwiseDynamic(4); ...
            scoresPointAdjustedDynamic(4); ...
            scoresPointwiseDynamic(1); ...
            scoresEventwiseDynamic(1); ...
            scoresPointAdjustedDynamic(1); ...
            scoresPointwiseDynamic(2); ...
            scoresEventwiseDynamic(2); ...
            scoresPointAdjustedDynamic(2)];
end
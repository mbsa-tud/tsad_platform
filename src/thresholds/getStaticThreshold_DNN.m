function staticThreshold = getStaticThreshold_DNN(options, Mdl, XTrain, YTrain, XVal, YVal, dataValTest, labelsValTest, thresholds, pd)
%GETSTATICTHRESHOLD_DNN
%
% This function calculates the static threshold for DL models and
% returnes them in the staticThreshold struct

staticThreshold = [];

if size(XTrain, 2) > 1
    isMultivariate = true;
else
    isMultivariate = false;
end

if ~isempty(dataValTest)
    XValTestCell = cell(size(dataValTest, 1), 1);
    YValTestCell = cell(size(dataValTest, 1), 1);
    labelsValTestCell = cell(size(dataValTest, 1), 1);
    
    numAnoms = 0;
    numTimeSteps = 0;

    for i = 1:size(dataValTest, 1)
        [XValTestCell{i, 1}, YValTestCell{i, 1}, labelsValTestCell{i, 1}] = prepareDataTest_DNN(options, dataValTest(i, :), labelsValTest(i, :));
        
        numAnoms = numAnoms + sum(labelsValTestCell{end} == 1);
        numTimeSteps = numTimeSteps + size(labelsValTestCell{end}, 1);
    end

    contaminationFraction = numAnoms / numTimeSteps;
    
    if contaminationFraction > 0
        anomalyScores = [];
        labels = [];

        for i = 1:size(XValTestCell, 1)
            anomalyScores_tmp = detectWithDNN(options, Mdl, XValTestCell{i, 1}, YValTestCell{i, 1}, labelsValTestCell{i, 1}, options.scoringFunction, pd);
            anomalyScores = [anomalyScores; anomalyScores_tmp];
            labels = [labels; labelsValTestCell{i, 1}];
        end

        for i = 1:length(thresholds)
            if ~strcmp(thresholds(i), "dynamic") && ~strcmp(thresholds(i), "pointFive")
                staticThreshold.(thresholds(i)) = calcStaticThreshold(anomalyScores, labels, thresholds(i), options.model);
            end
        end
    else
        fprintf("Warning! Anomalous validation set doesn't contain anomalies, possibly couldn't calculate some static thresholds.");
    end
end

if ismember("pointFive", thresholds)
    staticThreshold.pointFive = 0.5;
end
end

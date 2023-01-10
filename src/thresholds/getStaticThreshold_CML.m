function staticThreshold = getStaticThreshold_CML(options, Mdl, XTrain, dataValTest, labelsValTest, thresholds)
%GETSTATICTHRESHOLD_CML
%
% This function calculates the static threshold for classic ML models and
% returnes them in the staticThreshold struct

staticThreshold = [];

if ~isempty(dataValTest)
    XValTestCell = cell(size(dataValTest, 1), 1);
    YValTestCell = cell(size(dataValTest, 1), 1);
    labelsValTestCell = cell(size(dataValTest, 1), 1);
    
    numAnoms = 0;
    numTimeSteps = 0;

    for i = 1:size(dataValTest, 1)
        [XValTestCell{i, 1}, YValTestCell{i, 1}, labelsValTestCell{i, 1}] = prepareDataTest_CML(options, dataValTest(i, 1), labelsValTest(i, 1));
        
        numAnoms = numAnoms + sum(labelsValTestCell{end} == 1);
        numTimeSteps = numTimeSteps + size(labelsValTestCell{end}, 1);
    end

    contaminationFraction = numAnoms / numTimeSteps;                       
    
    if contaminationFraction > 0
        anomalyScores = [];
        labels = [];

        for i = 1:size(XValTestCell, 1)
            anomalyScores_tmp = detectWithCML(options, Mdl, XValTestCell{i, 1}, YValTestCell{i, 1}, labelsValTestCell{i, 1});
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

function score = opt_fun(options, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, threshold, dynamicThresholdSettings, cmpScore, optVars, trainingPlots, trainParallel, exportLogData)
%OPT_FUN
%
% Objective function for the bayesian optimization

options = adaptModelOptions(options, optVars);

scoresCell = trainAndEvaluateModel(options, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, threshold, dynamicThresholdSettings, trainingPlots, trainParallel);


numOfMetrics = size(scoresCell{1, 1}, 1);
numOfScoreMatrices = size(scoresCell, 1);

avgScores = zeros(numOfMetrics, 1);
for i = 1:numOfMetrics
    scores = zeros(numOfScoreMatrices, 1);
    for dataIdx = 1:numOfScoreMatrices
        scores(dataIdx, 1) = scoresCell{dataIdx, 1}(i, 1);
        if isnan(scores(dataIdx, 1))
            scores(dataIdx, 1) = 0;
        end
    end
    avgScores(i, 1) = mean(scores);
end

switch cmpScore
    case 'F1 Score (point-wise)'
        avgScore = avgScores(1, 1);
    case 'F1 Score (event-wise)'
        avgScore = avgScores(2, 1);
    case 'F1 Score (point-adjusted)'
        avgScore = avgScores(3, 1);
    case 'F1 Score (composite)'
        avgScore = avgScores(4, 1);
    case 'F0.5 Score (point-wise)'
        avgScore = avgScores(5, 1);
    case 'F0.5 Score (event-wise)'
        avgScore = avgScores(6, 1);
    case 'F0.5 Score (point-adjusted)'
        avgScore = avgScores(7, 1);
    case 'F0.5 Score (composite)'
        avgScore = avgScores(8, 1);
    case 'Precision (point-wise)'
        avgScore = avgScores(9, 1);
    case 'Precision (event-wise)'
        avgScore = avgScores(10, 1);
    case 'Precision (point-adjusted)'
        avgScore = avgScores(11, 1);
    case 'Recall (point-wise)'
        avgScore = avgScores(12, 1);
    case 'Recall (event-wise)'
        avgScore = avgScores(13, 1);
    case 'Recall (point-adjusted)'
        avgScore = avgScores(14, 1);
end

score = 1 - avgScore;

% Export results and current options
if exportLogData
    logPath = fullfile(pwd, 'Optimization_Logdata');
    if ~exist(logPath, 'dir')
        mkdir(logPath);
    end
    logPath = fullfile(logPath, sprintf('Logs_%s_%s', replace(cmpScore, ' ', '_'), options.id));
    if ~exist(logPath, 'dir')
        mkdir(logPath);
    end
    expPath = fullfile(logPath, sprintf('Log__%s.csv', datestr(now,'mm-dd-yyyy_HH-MM-SS')));
    
    oldVarNames = optVars.Properties.VariableNames;
    optVars = [optVars, array2table(avgScores')];
    optVars.Properties.VariableNames = [oldVarNames, ...
                                        "F1 Score (point-wise)", ...
                                        "F1 Score (event-wise)", ...
                                        "F1 Score (point-adjusted)", ...
                                        "F1 Score (composite)", ...
                                        "F0.5 Score (point-wise)", ...
                                        "F0.5 Score (event-wise)", ...
                                        "F0.5 Score (point-adjusted)", ...
                                        "F0.5 Score (composite)", ...
                                        "Precision (point-wise)", ...
                                        "Precision (event-wise)", ...
                                        "Precision (point-adjusted)", ...
                                        "Recall (point-wise)", ...
                                        "Recall (event-wise)", ...
                                        "Recall (point-adjusted)"];
    writetable(optVars, expPath);
end
end

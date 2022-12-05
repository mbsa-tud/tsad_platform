function score = opt_fun(options, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, ratioValTest, threshold, cmpScore, optVars, exportLogData)
%OPT_FUN
%
% Objective function for the bayesian optimization

options = adaptModelOptions(options, optVars);

switch options.type
    case 'DNN'
        scoresCell = fitAndEvaluateModel_DNN(options, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, ratioValTest, threshold);
    case 'CML'     
        scoresCell = fitAndEvaluateModel_CML(options, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, ratioValTest, threshold);
    case 'S'    
        scoresCell = fitAndEvaluateModel_S(options, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, ratioValTest, threshold);
end

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
    case 'Composite F1 Score'
        avgScore = avgScores(1, 1);
    case 'Point-wise F1 Score'
        avgScore = avgScores(2, 1);
    case 'Event-wise F1 Score'
        avgScore = avgScores(3, 1);
    case 'Point-adjusted F1 Score'
        avgScore = avgScores(4, 1);
    case 'Composite F0.5 Score'
        avgScore = avgScores(5, 1);
    case 'Point-wise F0.5 Score'
        avgScore = avgScores(6, 1);
    case 'Event-wise F0.5 Score'
        avgScore = avgScores(7, 1);
    case 'Point-adjusted F0.5 Score'
        avgScore = avgScores(8, 1);
    case 'Point-wise Precision'
        avgScore = avgScores(9, 1);
    case 'Event-wise Precision'
        avgScore = avgScores(10, 1);
    case 'Point-adjusted Precision'
        avgScore = avgScores(11, 1);
    case 'Point-wise Recall'
        avgScore = avgScores(12, 1);
    case 'Event-wise Recall'
        avgScore = avgScores(13, 1);
    case 'Point-adjusted Recall'
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
    optVars.Properties.VariableNames = [oldVarNames, "Composite F1 Score", ...
                                        "Point-wise F1 Score", ...
                                        "Event-wise F1 Score", ...
                                        "Point-adjusted F1 Score", ...
                                        "Composite F0.5 Score", ...
                                        "Point-wise F0.5 Score", ...
                                        "Event-wise F0.5 Score", ...
                                        "Point-adjusted F0.5 Score", ...
                                        "Point-wise Precision", ...
                                        "Event-wise Precision", ...
                                        "Point-adjusted Precision", ...
                                        "Point-wise Recall", ...
                                        "Event-wise Recall", ...
                                        "Point-adjusted Recall"];
    writetable(optVars, expPath);
end
end

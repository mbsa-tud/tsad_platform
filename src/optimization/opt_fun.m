function score = opt_fun(modelOptions, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, threshold, dynamicThresholdSettings, selectedMetric, optVars, trainingPlots, trainParallel, exportLogData)
%OPT_FUN Objective function for the bayesian optimization
%   The objective function runs the training and testing pipeline and
%   returns the specified metric (/score)

modelOptions = adaptModelOptions(modelOptions, optVars);

scoresCell = trainAndEvaluateModel(modelOptions, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, threshold, dynamicThresholdSettings, trainingPlots, trainParallel);


numOfMetrics = size(scoresCell{1, 1}, 1);
numOfScoreMatrices = size(scoresCell, 1);

avgScores = zeros(numOfMetrics, 1);
for metric_idx = 1:numOfMetrics
    scores = zeros(numOfScoreMatrices, 1);
    for data_idx = 1:numOfScoreMatrices
        scores(data_idx, 1) = scoresCell{data_idx, 1}(metric_idx, 1);
        if isnan(scores(data_idx, 1))
            scores(data_idx, 1) = 0;
        end
    end
    avgScores(metric_idx, 1) = mean(scores);
end

% Get specified score
[~, score_idx] = ismember(selectedMetric, METRIC_NAMES);
avgScore = avgScores(score_idx, 1);
score = 1 - avgScore;

% Export results and current modelOptions
if exportLogData
    logPath = fullfile(pwd, 'Optimization_Logdata');
    if ~exist(logPath, 'dir')
        mkdir(logPath);
    end
    logPath = fullfile(logPath, sprintf('Logs_%s_%s', replace(selectedMetric, ' ', '_'), modelOptions.id));
    if ~exist(logPath, 'dir')
        mkdir(logPath);
    end
    expPath = fullfile(logPath, sprintf('Log__%s.csv', datestr(now,'mm-dd-yyyy_HH-MM-SS')));
    
    oldVarNames = optVars.Properties.VariableNames;
    optVars = [optVars, array2table(avgScores')];
    optVars.Properties.VariableNames = [oldVarNames, ...
                                        METRIC_NAMES];
    writetable(optVars, expPath);
end
end

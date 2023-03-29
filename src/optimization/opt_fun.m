function score = opt_fun(modelOptions, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, threshold, dynamicThresholdSettings, selectedMetric, optVars, trainingPlots)
%OPT_FUN Objective function for the bayesian optimization
%   The objective function runs the training and testing pipeline and
%   returns the specified metric (/score)

modelOptions = adaptModelOptions(modelOptions, optVars);

scoresCell = trainAndEvaluateModel(modelOptions, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, threshold, dynamicThresholdSettings, trainingPlots, false);

avgScores = calcAverageScores(scoresCell);

% Get specified score
[~, score_idx] = ismember(selectedMetric, METRIC_NAMES);
avgScore = avgScores(score_idx, 1);
score = 1 - avgScore;
end

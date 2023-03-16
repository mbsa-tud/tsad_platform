function results = optimizeModel(optVars, model, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, thresholds, dynamicThresholdSettings, cmpScore, iterations, trainingPlots, trainParallel, exportLogData)
%OPTIMIZEMODEL Runs the byesian optimization for a model
%   Sets the optVars, defines the opt_fun and calls the bayesopt function

optVariables = [];
optVarNames = fieldnames(optVars);
for i = 1:length(optVarNames)
    optVariables = [optVariables optimizableVariable(optVarNames{i}, ...
        optVars.(optVarNames{i}).value, 'Type', optVars.(optVarNames{i}).type)];
end

fun = @(x)opt_fun(model, ...
    dataTrain, ...
    labelsTrain, ...
    dataValTest, ...
    labelsValTest, ...
    dataTest, ...
    labelsTest, ...
    thresholds, ...
    dynamicThresholdSettings, ...
    cmpScore, ...
    x, ...
    trainingPlots, ...
    trainParallel, ...
    exportLogData);

results = bayesopt(fun, optVariables, Verbose=0,...
    AcquisitionFunctionName='expected-improvement-plus', ...
    MaxObjectiveEvaluations=iterations, ...
    IsObjectiveDeterministic=false);
end
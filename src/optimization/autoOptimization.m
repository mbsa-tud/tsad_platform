function bestOptions = autoOptimization(models, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, configOptFileName, cmpScore, threshold, dynamicThresholdSettings, iterations, trainingPlots, trainParallel, exportLogdata)
%AUTOOPTIMIZATION
%
% Runs the auto-optimization for all selected models

bestOptions_DNN = [];
bestOptions_CML = [];
bestOptions_S = [];

for i = 1:length(models)
    options = models(i).options;
    % Load hyperparameters to be optimized
    optVars = getOptimizationVariables(models(i).options.model, configOptFileName);
    
    % Check for each optVar if it matches a hyperparameter in the options struct
    if isfield(options, 'hyperparameters')
        varNames = fieldnames(optVars);
        for j = 1:length(varNames)
            flag = false;
            if isfield(options.hyperparameters, varNames{j})
                flag = true;
            end

            if ~flag
                optVars = rmfield(optVars, varNames{j});
            end
        end
    end

    
    % If no hyperparameters are available for the model, save default
    % options
    if isempty(optVars) || ~isfield(options, 'hyperparameters')
        bestOptions_tmp.options = options;
        switch options.type
            case 'DNN'
                bestOptions_DNN = [bestOptions_DNN; bestOptions_tmp];
            case 'CML'
                bestOptions_CML = [bestOptions_CML; bestOptions_tmp];
            case 'S'
                bestOptions_S = [bestOptions_S; bestOptions_tmp];
        end
        continue;
    end
    
    % Optimization
    results = optimizeModel(optVars, options, dataTrain, ...
                            labelsTrain, dataValTest, labelsValTest, ...
                            dataTest, labelsTest, threshold, dynamicThresholdSettings, ...
                            cmpScore, iterations, trainingPlots, trainParallel, exportLogdata);

    optimumVars = results.XAtMinObjective;
    
    bestOptions_tmp.options = adaptModelOptions(options, optimumVars);
    switch options.type
        case 'DNN'
            bestOptions_DNN = [bestOptions_DNN; bestOptions_tmp];
        case 'CML'
            bestOptions_CML = [bestOptions_CML; bestOptions_tmp];
        case 'S'
            bestOptions_S = [bestOptions_S; bestOptions_tmp];
    end
end

if ~isempty(bestOptions_DNN)
    bestOptions.DNN_Models = bestOptions_DNN;
end
if ~isempty(bestOptions_CML)
    bestOptions.CML_Models = bestOptions_CML;
end
if ~isempty(bestOptions_S)
    bestOptions.S_Models = bestOptions_S;
end
end
function bestOptions = autoOptimization(models, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, configOptFileName, cmpScore, threshold, dynamicThresholdSettings, iterations, trainingPlots, trainParallel, exportLogdata)
%AUTOOPTIMIZATION Runs the auto optimization for the models
%   Main wrapper function to run the bayesian optimization for all selected
%   models

bestOptions_DNN = [];
bestOptions_CML = [];
bestOptions_S = [];

for i = 1:length(models)
    modelOptions = models(i).modelOptions;
    % Load hyperparameters to be optimized
    optVars = getOptimizationVariables(models(i).modelOptions.name, configOptFileName);
    
    % Check for each optVar if it matches a hyperparameter in the modelOptions struct
    if isfield(modelOptions, 'hyperparameters')
        varNames = fieldnames(optVars);
        for j = 1:length(varNames)
            flag = false;
            if isfield(modelOptions.hyperparameters, varNames{j})
                flag = true;
            end

            if ~flag
                optVars = rmfield(optVars, varNames{j});
            end
        end
    end

    
    % If no hyperparameters are available for the model, save default
    % modelOptions
    if isempty(optVars) || ~isfield(modelOptions, 'hyperparameters')
        bestOptions_tmp.modelOptions = modelOptions;
        switch modelOptions.type
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
    results = optimizeModel(optVars, modelOptions, dataTrain, ...
                            labelsTrain, dataValTest, labelsValTest, ...
                            dataTest, labelsTest, threshold, dynamicThresholdSettings, ...
                            cmpScore, iterations, trainingPlots, trainParallel, exportLogdata);

    optimumVars = results.XAtMinObjective;
    
    bestOptions_tmp.modelOptions = adaptModelOptions(modelOptions, optimumVars);
    switch modelOptions.type
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
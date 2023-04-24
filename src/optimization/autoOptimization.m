function optimizedModelOptions = autoOptimization(models, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, configOptFileName, metric, threshold, dynamicThresholdSettings, iterations, trainingPlots, parallelEnabled)
%AUTOOPTIMIZATION Runs the auto optimization for the models
%   Main wrapper function to run the bayesian optimization for all selected
%   models

optimizedModelOptions = [];

for model_idx = 1:length(models)
    modelOptions = models(model_idx).modelOptions;
    % Load hyperparameters to be optimized
    optVars = getOptimizationVariables(models(model_idx).modelOptions.name, configOptFileName);
    
    % Check for each optVar if it matches a hyperparameter in the modelOptions struct
    if ~isempty(optVars) && isfield(modelOptions, "hyperparameters")
        varNames = fieldnames(optVars);
        for var_idx = 1:length(varNames)
            flag = false;
            if isfield(modelOptions.hyperparameters, varNames{var_idx})
                flag = true;
            end

            if ~flag
                optVars = rmfield(optVars, varNames{var_idx});
            end
        end
    end

    
    % If no hyperparameters are available for the model, save default
    % modelOptions
    if isempty(optVars) || ~isfield(modelOptions, "hyperparameters")
        tmp.modelOptions = modelOptions;
        optimizedModelOptions = [optimizedModelOptions; tmp];
        continue;
    end
    
    % Optimization
    results = optimizeModel(optVars, modelOptions, dataTrain, ...
                            labelsTrain, dataValTest, labelsValTest, ...
                            dataTest, labelsTest, threshold, dynamicThresholdSettings, ...
                            metric, iterations, trainingPlots, parallelEnabled);

    optimumVars = results.XAtMinObjective;
    
    if ~isempty(optimumVars)
        tmp.modelOptions = adaptModelOptions(modelOptions, optimumVars);
        optimizedModelOptions = [optimizedModelOptions; tmp];
    else
        tmp.modelOptions = modelOptions;
        optimizedModelOptions = [optimizedModelOptions; tmp];
    end
end
end
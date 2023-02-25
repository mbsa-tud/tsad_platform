function options = adaptModelOptions(options, optVars)
%ADAPTMODELOPTIONS
%
% Reconfigures the options for the bayesian optimization

varNames = optVars.Properties.VariableNames;
for i = 1:length(varNames)
    if isfield(options.hyperparameters, 'model')
        if isfield(options.hyperparameters.model, varNames{i})
            options.hyperparameters.model.(varNames{i}).value = optVars{1, i};
            continue;
        end
    end
    if isfield(options.hyperparameters, 'data')
        if isfield(options.hyperparameters.data, varNames{i})
            options.hyperparameters.data.(varNames{i}).value = optVars{1, i};
            continue;
        end
    end
    if isfield(options.hyperparameters, 'training')
        if isfield(options.hyperparameters.training, varNames{i})
            options.hyperparameters.training.(varNames{i}).value = optVars{1, i};
            continue;
        end
    end
end
end
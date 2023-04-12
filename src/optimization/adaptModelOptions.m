function modelOptions = adaptModelOptions(modelOptions, optVars)
%ADAPTMODELOPTIONS Converts the model options
%   Converts the modelOptions of a model to the new values chosen by the
%   bayesian optimization algorithm

varNames = optVars.Properties.VariableNames;
for var_idx = 1:length(varNames)
    if isfield(modelOptions.hyperparameters, varNames{var_idx})
        if iscategorical(optVars{1, var_idx})
            if isnumeric(modelOptions.hyperparameters.(varNames{var_idx}))
                tmp = categories(optVars{1, var_idx});
                newVar = double(tmp{1}); 
            else
                tmp = categories(optVars{1, var_idx});
                newVar = string(tmp{1});
            end
        else
            newVar = optVars{1, var_idx};
        end

        modelOptions.hyperparameters.(varNames{var_idx}) = newVar;
        continue;
    else
        warning("Your trying to optimize a hyperparameter which is not defined in the modelOptions struct of your model");
    end
end
end
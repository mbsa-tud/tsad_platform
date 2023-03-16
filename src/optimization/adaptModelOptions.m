function modelOptions = adaptModelOptions(modelOptions, optVars)
%ADAPTMODELOPTIONS Converts the model options
%   Converts the modelOptions of a model to the new values chosen by the
%   bayesian optimization algorithm

varNames = optVars.Properties.VariableNames;
for i = 1:length(varNames)
    if isfield(modelOptions.hyperparameters, varNames{i})
        modelOptions.hyperparameters.(varNames{i}).value = optVars{1, i};
        continue;
    else
        warning("Your trying to optimize a hyperparameter which is not defined in the modelOptions struct of your model");
    end
end
end
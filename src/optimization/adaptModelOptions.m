function options = adaptModelOptions(options, optVars)
%ADAPTMODELOPTIONS
%
% Reconfigures the options for the bayesian optimization

varNames = optVars.Properties.VariableNames;
for i = 1:length(varNames)
    if isfield(options.hyperparameters, varNames{i})
        options.hyperparameters.(varNames{i}).value = optVars{1, i};
        continue;
    else
        warning("Your trying to optimize a hyperparameter which is not defined in the options struct of your model");
    end
end
end
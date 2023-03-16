function optVars = getOptimizationVariables(modelName, configFileName)
%GETOPTIMIZATIONVARIABLES Load the optimization variables
%   Loads the optimizations variables for the model from the configuration
%   file

% Convert model name to valid matlab struct fieldname

tmp = fieldnames(jsondecode(sprintf('{"%s":[]}', modelName)));
modelName = tmp{1};

% Load all models with their hyperparameter optimization configuration
fid = fopen(configFileName);
raw = fread(fid, inf);
str = char(raw');
fclose(fid);
config = jsondecode(str);

vars = fieldnames(config.(modelName));
if isempty(vars)
    optVars = [];
    return;
end

% Load optimizable hyperparameters
for i = 1:length(vars)
    optVars.(vars{i}).value = config.(modelName).(vars{i}).value;
    optVars.(vars{i}).type = config.(modelName).(vars{i}).type;
end
end
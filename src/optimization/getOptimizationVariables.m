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
    optVars = struct(); % Return empty struct
    return;
end

% Load optimizable hyperparameters
for var_idx = 1:numel(vars)
    optVars.(vars{var_idx}).value = config.(modelName).(vars{var_idx}).value;
    optVars.(vars{var_idx}).type = config.(modelName).(vars{var_idx}).type;
end
end
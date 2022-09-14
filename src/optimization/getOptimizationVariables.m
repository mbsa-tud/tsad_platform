function optVars = getOptimizationVariables(model, configOptFileName)
% Convert model name to valid matlab struct fieldname
model = replace(model, '(', '');
model = replace(model, ')', '');
model = replace(model, ' ', '_');
model = replace(model, '-', '_');

% Load all models with their hyperparameter optimization configuration
fid = fopen(configOptFileName);
raw = fread(fid, inf);
str = char(raw');
fclose(fid);
config = jsondecode(str);

vars = fieldnames(config.(model));
if isempty(vars)
    optVars = [];
    return;
end

% Load optimizable hyperparameters
for i = 1:length(vars)
    optVars.(vars{i}).value = config.(model).(vars{i}).value;
    optVars.(vars{i}).type = config.(model).(vars{i}).type;
end
end
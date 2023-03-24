function [finalTable, selectedModels] = evaluateDynamicSwitch(classifier, trainedModels, dataTestSwitch, labelsTestSwitch, threshold, dynamicThresholdSettings)
% EVALUATEDYNAMICSWITCH Tests the dynamic switch and compares it to the
% performance of all individual models

numOfTestingFiles = size(dataTestSwitch, 1);
trainedModelsFields = fieldnames(trainedModels);
numOfModels = numel(trainedModelsFields);
allModelNames = strings(numOfModels, 1);

for model_idx = 1:numOfModels
    allModelNames(model_idx) = trainedModels.(trainedModelsFields{model_idx}).modelOptions.label;
end

fullScores_Switch = cell(numOfTestingFiles, 1);
fullScores = cell(numOfTestingFiles, 1);

selectedModels = strings(numOfTestingFiles, 1);

for data_idx = 1:numOfTestingFiles    
    % select data
    XTest_switch = diagnosticFeatures(dataTestSwitch{data_idx, 1});

    % classifier chooses model
    pred = string(classify(classifier, XTest_switch));
    selectedModel = trainedModels.(pred);
    
    selectedModels(data_idx, 1) = trainedModels.(pred).modelOptions.label;
    fprintf("\n### Dynamic switch chose model %s for file No.%d ###\n\n", trainedModels.(pred).modelOptions.label, data_idx);
    
    fullScores_Switch{data_idx, 1} = detectAndEvaluateWith(selectedModel, dataTestSwitch(data_idx, 1), labelsTestSwitch(data_idx, 1), threshold, dynamicThresholdSettings);
    for model_idx = 1:numOfModels
        fullScores{data_idx, 1} = [fullScores{data_idx, 1}, detectAndEvaluateWith(trainedModels.(trainedModelsFields{model_idx}),  dataTestSwitch(data_idx, 1), labelsTestSwitch(data_idx, 1), threshold, dynamicThresholdSettings)];
    end
end


averages = calcAverageScores(fullScores_Switch);
averages = [averages calcAverageScores(fullScores)];

scoreNames = table(METRIC_NAMES);
scoreNames.Properties.VariableNames = "Metric";

averagesTable = array2table(averages);
averagesTable.Properties.VariableNames = ["Dynamic Switch"; allModelNames];

finalTable = [scoreNames, averagesTable];
end


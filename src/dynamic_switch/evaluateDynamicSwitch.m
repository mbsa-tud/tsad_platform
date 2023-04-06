function [finalTable, selectedModels] = evaluateDynamicSwitch(classifier, trainedModels, dataTestSwitch, labelsTestSwitch, threshold, dynamicThresholdSettings)
% EVALUATEDYNAMICSWITCH Tests the dynamic switch and compares it to the
% performance of all individual models

numTestingFiles = size(dataTestSwitch, 1);
trainedModelIds = fieldnames(trainedModels);
numModels = numel(trainedModelIds);
allModelNames = strings(numModels, 1);

for model_idx = 1:numModels
    allModelNames(model_idx) = trainedModels.(trainedModelIds{model_idx}).modelOptions.label;
end

fullScores_Switch = cell(numTestingFiles, 1);
fullScores = cell(numTestingFiles, 1);

selectedModels = strings(numTestingFiles, 1);

for data_idx = 1:numTestingFiles    
    % select data
    XTest_switch = diagnosticFeatures(dataTestSwitch{data_idx, 1});

    % classifier chooses model
    pred = string(classify(classifier, XTest_switch));
    selectedModel = trainedModels.(pred);
    
    selectedModels(data_idx, 1) = trainedModels.(pred).modelOptions.label;
    fprintf("\n### Dynamic switch chose model %s for file No.%d ###\n\n", trainedModels.(pred).modelOptions.label, data_idx);
    
    fullScores_Switch{data_idx, 1} = detectAndEvaluateWith(selectedModel, dataTestSwitch(data_idx, 1), labelsTestSwitch(data_idx, 1), threshold, dynamicThresholdSettings);
    for model_idx = 1:numModels
        fullScores{data_idx, 1} = [fullScores{data_idx, 1}, detectAndEvaluateWith(trainedModels.(trainedModelIds{model_idx}),  dataTestSwitch(data_idx, 1), labelsTestSwitch(data_idx, 1), threshold, dynamicThresholdSettings)];
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


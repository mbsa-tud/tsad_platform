function [finalTable, selectedModels] = evaluateDynamicSwitch(classifier, trainedModels, dataTestSwitch, labelsTestSwitch, fileNamesTestSwitch, threshold, dynamicThresholdSettings)
% EVALUATEDYNAMICSWITCH Tests the dynamic switch and compares it to the
% performance of all individual models

numTestingFiles = numel(dataTestSwitch);
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
    XTestSwitch = diagnosticFeatures(dataTestSwitch{data_idx});

    % classifier chooses model
    pred = string(classify(classifier, XTestSwitch));
    selectedModel = trainedModels.(pred);
    
    selectedModels(data_idx) = trainedModels.(pred).modelOptions.label;
    fprintf("\n### Dynamic switch chose model %s for file %s ###\n\n", trainedModels.(pred).modelOptions.label, fileNamesTestSwitch(data_idx));
    
    fullScores_Switch{data_idx} = detectAndEvaluateWith(selectedModel, dataTestSwitch(data_idx), labelsTestSwitch(data_idx), threshold, dynamicThresholdSettings);
    for model_idx = 1:numModels
        fullScores{data_idx} = [fullScores{data_idx}, detectAndEvaluateWith(trainedModels.(trainedModelIds{model_idx}),  dataTestSwitch(data_idx), labelsTestSwitch(data_idx), threshold, dynamicThresholdSettings)];
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


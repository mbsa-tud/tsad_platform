function finalTable = evaluateDynamicSwitch(classifier, trainedModels, dataTestSwitch, labelsTestSwitch, threshold)
% EVALUATEDYNAMICSWITCH
%
% Tests the dynamic switch and compares it to all individual models on the
% danamic switch test dataset

numOfTestingFiles = size(dataTestSwitch, 1);
trainedModelsFields = fieldnames(trainedModels);
numOfModels = numel(trainedModelsFields);
allModelNames = strings(numOfModels, 1);

for i = 1:numOfModels
    allModelNames(i) = trainedModels.(trainedModelsFields{i}).options.label;
end

fullScores_Switch = cell(numOfTestingFiles, 1);
fullScores = cell(numOfModels, 1);

for fileIdx = 1:numOfTestingFiles    
    % select data
    XTest_switch = diagnosticFeatures(dataTestSwitch{fileIdx, 1});

    % classifier chooses model
    pred = string(classify(classifier, XTest_switch));
    selectedModel = trainedModels.(pred);
    
    fullScores_Switch{fileIdx, 1} = detectAndEvaluateWith(selectedModel, dataTestSwitch(fileIdx, 1), labelsTestSwitch, threshold);
    for j = 1:numOfModels
        fullScores{j, 1}{fileIdx, 1} = detectAndEvaluateWith(trainedModels.(trainedModelsFields{j}),  dataTestSwitch(fileIdx, 1), labelsTestSwitch, threshold);
    end
end


averages = calcAverageScores(fullScores_Switch);

for fileIdx = 1:numOfModels
    averages = [averages calcAverageScores(fullScores{fileIdx, 1})];
end

scoreNames = table(["F1 Score (point-wise)"; ...
                    "F1 Score (event-wise)"; ...
                    "F1 Score (point-adjusted)"; ...
                    "F1 Score (composite)"; ...
                    "F0.5 Score (point-wise)"; ...
                    "F0.5 Score (event-wise)"; ...
                    "F0.5 Score (point-adjusted)"; ...
                    "F0.5 Score (composite)"; ...
                    "Precision (point-wise)"; ...
                    "Precision (event-wise)"; ...
                    "Precision (point-adjusted)"; ...
                    "Recall (point-wise)"; ...
                    "Recall (event-wise)"; ...
                    "Recall (point-adjusted)"]);
scoreNames.Properties.VariableNames = "Metric";

averagesTable = array2table(averages);
averagesTable.Properties.VariableNames = ["Dynamic Switch"; allModelNames];

finalTable = [scoreNames, averagesTable];
end


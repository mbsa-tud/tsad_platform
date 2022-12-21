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

scoreNames = table([
    "Composite F1 Score"; ...
    "Point-wise F1 Score"; ...
    "Event-wise F1 Score"; ...
    "Point-adjusted F1 Score"; ...
    "Composite F0.5 Score"; ...
    "Point-wise F0.5 Score"; ...
    "Event-wise F0.5 Score"; ...
    "Point-adjusted F0.5 Score"; ...
    "Point-wise Precision"; ...
    "Event-wise Precision"; ...
    "Point-adjusted Precision"; ...
    "Point-wise Recall"; ...
    "Event-wise Recall"; ...
    "Point-adjusted Recall"]);
scoreNames.Properties.VariableNames = "Metric";

averagesTable = array2table(averages);
averagesTable.Properties.VariableNames = ["Dynamic Switch"; allModelNames];

finalTable = [scoreNames, averagesTable];
end


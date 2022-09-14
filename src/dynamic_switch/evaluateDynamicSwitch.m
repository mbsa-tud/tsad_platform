function finalTable = evaluateDynamicSwitch(classifier, datasetPath)
%% Confusionchart jsut for visually evaluating the switch performance
% [XTest, labels] = getDataTest_Switch(datasetPath);
% YPred = classify(classifier, XTest, 'MiniBatchSize', 32);
% 
% accuracy = sum(YPred == labels) / numel(labels);
% figure
% confusionchart(labels, YPred)
%%


fid = fopen(fullfile(datasetPath, 'preprocParams.json'));
raw = fread(fid, inf);
str = char(raw');
fclose(fid);
preprocParams = jsondecode(str);

models = load(fullfile(datasetPath, 'models.mat'));
models = models.allModels;
fields = fieldnames(models);
numOfModels = numel(fields);
allModelNames = strings(numOfModels, 1);
for i = 1:numOfModels
    allModelNames(i, 1) = models.(fields{i}).options.model;
end

dataTestPath = fullfile(datasetPath, 'test_switch');

testingFiles = dir(fullfile(dataTestPath, '*.csv'));

numOfTestingFiles = numel(testingFiles);

fullScores_Switch = cell(numOfTestingFiles, 1);
fullScores = cell(numOfModels, 1);

for i = 1:numOfTestingFiles
    dataFile = fullfile(dataTestPath, testingFiles(i).name);
    
    % Loading data
    data = readtable(dataFile);
    rawTestingData = [];
    labelsTestingData = [];

    rawTestingData{1, 1} = data{:, 2};
    labelsTestingData{1, 1} = data{:, 3};
    
    % Preprocessing
    [~, preprocessedTestingData, ~, ~, ~, ~] = preprocessData({}, rawTestingData, preprocParams.preprocMethod, true, preprocParams);         
    
    % Model selection with trained classifier
    XTest_switch = diagnosticFeatures(preprocessedTestingData{1, 1});
    pred = string(classify(classifier, XTest_switch));
    disp(pred);
    selectedModel = models.(pred);
    
    fullScores_Switch{i, 1} = detectAndEvaluateWith(selectedModel, preprocessedTestingData, labelsTestingData);
    for j = 1:numOfModels
        fullScores{j, 1}{i, 1} = detectAndEvaluateWith(models.(fields{j}), preprocessedTestingData, labelsTestingData);
    end
end


averages = calcAverageScores(fullScores_Switch);

for i = 1:numOfModels
    averages = [averages calcAverageScores(fullScores{i, 1})];
end

scoreNames = table([
    "Composite F1 Score (Static)"; ...
    "Point-wise F1 Score (Static)"; ...
    "Event-wise F1 Score (Static)"; ...
    "Point-adjusted F1 Score (Static)"; ...
    "Point-wise F0.5 Score (Static)"; ...
    "Event-wise F0.5 Score (Static)"; ...
    "Point-adjusted F0.5 Score (Static)"; ...
    "Point-wise Precision (Static)"; ...
    "Event-wise Precision (Static)"; ...
    "Point-adjusted Precision (Static)"; ...
    "Point-wise Recall (Static)"; ...
    "Event-wise Recall (Static)"; ...
    "Point-adjusted Recall (Static)"; ...
    "Composite F1 Score (Dynamic)"; ...
    "Point-wise F1 Score (Dynamic)"; ...
    "Event-wise F1 Score (Dynamic)"; ...
    "Point-adjusted F1 Score (Dynamic)"; ...
    "Point-wise F0.5 Score (Dynamic)"; ...
    "Event-wise F0.5 Score (Dynamic)"; ...
    "Point-adjusted F0.5 Score (Dynamic)"; ...
    "Point-wise Precision (Dynamic)"; ...
    "Event-wise Precision (Dynamic)"; ...
    "Point-adjusted Precision (Dynamic)"; ...
    "Point-wise Recall (Dynamic)"; ...
    "Event-wise Recall (Dynamic)"; ...
    "Point-adjusted Recall (Dynamic)"]);
scoreNames.Properties.VariableNames = "Metric";

averagesTable = array2table(averages);
averagesTable.Properties.VariableNames = ["Dynamic Switch"; allModelNames];

finalTable = [scoreNames, averagesTable];
end


function [XTest, labels] = getDataTest_Switch(datasetPath)

dataTestPath = fullfile(datasetPath, 'test_switch');
dataTrainPath = fullfile(datasetPath, 'train_switch');

fid = fopen(fullfile(datasetPath, 'preprocParams.json'));
raw = fread(fid, inf);
str = char(raw');
fclose(fid);
preprocParams = jsondecode(str);

testingFiles = dir(fullfile(dataTestPath, '*.csv'));

numOfTestingFiles = numel(testingFiles);

XTest = [];
labels = strings(numOfTestingFiles, 1);
for i = 1:numOfTestingFiles
    dataFile = fullfile(dataTestPath, testingFiles(i).name);
    name_split = split(testingFiles(i).name, '.');
    labelFile = fullfile(dataTrainPath, sprintf('%s_best_model.txt', name_split{1}));

    data = readtable(dataFile);

    % Preprocessing
    testData = cell(1, 1);
    testData{1, 1} = data{:, 2};
    [~, testData, ~, ~, ~, ~] = preprocessData({}, testData, preprocParams.preprocMethod, true, preprocParams);

    fid = fopen(labelFile);
    labels(i, 1) = string(textscan(fid, '%s', 1, 'delimiter', '\n', 'headerlines', 0));
    fclose(fid);

    XTest_tmp = diagnosticFeatures(testData{1, 1});
    XTest = [XTest; XTest_tmp];
end
labels = categorical(labels);
end

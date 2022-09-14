function [XTrain, labelName] = getDataTrain_Switch(datasetPath)
labelName = 'best_model';

trainSwitchPath = fullfile(datasetPath, 'train_switch');

fid = fopen(fullfile(datasetPath, 'preprocParams.json'));
raw = fread(fid, inf);
str = char(raw');
fclose(fid);
preprocParams = jsondecode(str);


testingFiles = dir(fullfile(trainSwitchPath, '*.csv'));

numOfTestingFiles = numel(testingFiles);

XTrain = [];
for i = 1:numOfTestingFiles
    dataFile = fullfile(trainSwitchPath, testingFiles(i).name);
    name_split = split(testingFiles(i).name, '.');
    labelFile = fullfile(trainSwitchPath, sprintf('%s_best_model.txt', name_split{1}));

    data = readtable(dataFile);
    
    % Preprocessing
    trainData = cell(1, 1);
    trainData{1, 1} = data{:, 2};
    [trainData, ~, ~, ~, ~, ~] = preprocessData(trainData, {}, preprocParams.preprocMethod, true, preprocParams);    

    fid = fopen(labelFile);
    label = string(textscan(fid, '%s', 1, 'delimiter', '\n', 'headerlines', 0));
    fclose(fid);

    XTrain_tmp = diagnosticFeatures(trainData{1, 1});
    XTrain_tmp.(labelName) = label;
    XTrain = [XTrain; XTrain_tmp];
end

XTrain = convertvars(XTrain, labelName, 'categorical');
end

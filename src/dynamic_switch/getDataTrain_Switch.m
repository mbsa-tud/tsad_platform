function [XTrain, labelName] = getDataTrain_Switch(datasetPath)
%GETDATATRAIN_SWITCH
%
% Prepares the training data for the dynamic switch ba extracting the time
% series features

labelName = 'best_model';

trainSwitchPath = fullfile(datasetPath, 'train_switch');

fid = fopen(fullfile(datasetPath, 'preprocParams.json'));
raw = fread(fid, inf);
str = char(raw');
fclose(fid);
preprocParams = jsondecode(str);


labelFiles = dir(fullfile(trainSwitchPath, '*.txt'));

numOfTestingFiles = numel(labelFiles);

XTrain = [];
for i = 1:numOfTestingFiles
    labelFile = fullfile(trainSwitchPath, labelFiles(i).name);
    name_split = split(labelFiles(i).name, '_best_model.txt');
    dataFile = fullfile(trainSwitchPath, sprintf('%s.csv', name_split{1}));    

    data = readtable(dataFile);
    
    % Preprocessing
    trainData = cell(1, 1);
    trainData{1, 1} = data{:, 2};
    [trainData, ~, ~, ~, ~, ~] = preprocessData(trainData, {}, preprocParams.preprocMethod, true, preprocParams);    

    fid = fopen(labelFile);
    label = string(textscan(fid, '%s', 1, 'delimiter', '\n', 'headerlines', 0));
    fclose(fid);
    
    % Convert time series to feature vector
    XTrain_tmp = diagnosticFeatures(trainData{1, 1});
    XTrain_tmp.(labelName) = label;
    XTrain = [XTrain; XTrain_tmp];
end

XTrain = convertvars(XTrain, labelName, 'categorical');
end

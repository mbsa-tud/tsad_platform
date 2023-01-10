function [trainingData, timestampsTraining, labelsTraining, filesTraining, ...
                testingData, timestampsTesting, labelsTesting, filesTesting] = loadCustomDataset(datasetPath)
%LOADCUSTOMDATASET
%
% Loads the custom dataset from CSV files.

trainingData = [];
testingData = [];
timestampsTraining = [];
timestampsTesting = [];
filesTraining = [];
filesTesting = [];
labelsTraining = [];
labelsTesting = [];

dataPath = datasetPath;

if ~isfolder(datasetPath)
    dataPath = fullfile(pwd, datasetPath);
    if ~isfolder(dataPath)
        return;
    end
end

dataTrainPath = fullfile(dataPath, 'train');
dataTestPath = fullfile(dataPath, 'test');


trainingFiles = dir(fullfile(dataTrainPath, '*.csv'));
testingFiles = dir(fullfile(dataTestPath, '*.csv'));

if numel(trainingFiles) == 0 && numel(testingFiles) == 0                
    return;
end

numOfTrainingFiles = numel(trainingFiles);
numOfTestingFiles = numel(testingFiles);
if numOfTrainingFiles > 0
    trainingData = cell(numOfTrainingFiles, 1);
    timestampsTraining = cell(numOfTrainingFiles, 1);
    labelsTraining = cell(numOfTestingFiles, 1);
    filesTraining = strings(1, numOfTrainingFiles);
end
if numOfTestingFiles > 0
    testingData = cell(numOfTestingFiles, 1);
    timestampsTesting = cell(numOfTestingFiles, 1);
    labelsTesting = cell(numOfTestingFiles, 1);
    filesTesting = strings(1, numOfTestingFiles);
end
    
for i = 1:numOfTrainingFiles
    file = fullfile(dataTrainPath, trainingFiles(i).name);
    data = readtable(file);

    name = strsplit(trainingFiles(i).name, '.');
    filesTraining(1, i) = name(1);
    trainingData{i, 1} = data{:, 2:(end - 1)};
    labelsTraining{i, 1} = logical(data{:, end});                

    try
        timestampsTraining{i, 1} = datetime(data{:, 1});
    catch
        timestampsTraining{i, 1} = data{:, 1};
    end
end


for i = 1:numOfTestingFiles
    file = fullfile(dataTestPath, testingFiles(i).name);
    data = readtable(file);

    name = strsplit(testingFiles(i).name, '.');
    filesTesting(1, i) = name(1);
    testingData{i, 1} = data{:, 2:(end - 1)};
    labelsTesting{i, 1} = logical(data{:, end});

    try
        timestampsTesting{i, 1} = datetime(data{:, 1});
    catch
        timestampsTesting{i, 1} = data{:, 1};
    end
end
end
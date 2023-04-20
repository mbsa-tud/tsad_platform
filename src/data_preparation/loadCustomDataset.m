function [trainingData, timestampsTraining, labelsTraining, filesTraining, ...
                testingData, timestampsTesting, labelsTesting, filesTesting, channelNames] = loadCustomDataset(datasetPath)
%LOADCUSTOMDATASET Loads the custom dataset from CSV files.

trainingData = [];
testingData = [];
timestampsTraining = [];
timestampsTesting = [];
filesTraining = [];
filesTesting = [];
labelsTraining = [];
labelsTesting = [];
channelNames = [];

if ~isfolder(datasetPath)
    datasetPath = fullfile(pwd, datasetPath);
    if ~isfolder(datasetPath)
        error("Provided folder doesn't exist!");
    end
end

dataTrainPath = fullfile(datasetPath, "train");
dataTestPath = fullfile(datasetPath, "test");


trainingFiles = dir(fullfile(dataTrainPath, "*.csv"));
testingFiles = dir(fullfile(dataTestPath, "*.csv"));

if numel(trainingFiles) == 0 && numel(testingFiles) == 0                
    error("Invalid dataset. Check the platform manual for the correct format of a dataset");
end

numOfTrainingFiles = numel(trainingFiles);
numOfTestingFiles = numel(testingFiles);
if numOfTrainingFiles > 0
    trainingData = cell(numOfTrainingFiles, 1);
    timestampsTraining = cell(numOfTrainingFiles, 1);
    labelsTraining = cell(numOfTestingFiles, 1);
    filesTraining = strings(numOfTrainingFiles, 1);
end
if numOfTestingFiles > 0
    testingData = cell(numOfTestingFiles, 1);
    timestampsTesting = cell(numOfTestingFiles, 1);
    labelsTesting = cell(numOfTestingFiles, 1);
    filesTesting = strings(numOfTestingFiles, 1);
end
    
for data_idx = 1:numOfTrainingFiles
    file = fullfile(dataTrainPath, trainingFiles(data_idx).name);
    data = readtable(file);

    name = strsplit(trainingFiles(data_idx).name, ".");
    filesTraining(data_idx, 1) = name(1);
    trainingData{data_idx, 1} = data{:, 2:(end - 1)};
    labelsTraining{data_idx, 1} = logical(data{:, end});                

    try
        timestampsTraining{data_idx, 1} = datetime(data{:, 1});
    catch
        timestampsTraining{data_idx, 1} = data{:, 1};
    end

    channelNames = string(data.Properties.VariableNames(2:(end - 1)));
end


for data_idx = 1:numOfTestingFiles
    file = fullfile(dataTestPath, testingFiles(data_idx).name);
    data = readtable(file);

    name = strsplit(testingFiles(data_idx).name, ".");
    filesTesting(data_idx, 1) = name(1);
    testingData{data_idx, 1} = data{:, 2:(end - 1)};
    labelsTesting{data_idx, 1} = logical(data{:, end});

    try
        timestampsTesting{data_idx, 1} = datetime(data{:, 1});
    catch
        timestampsTesting{data_idx, 1} = data{:, 1};
    end

    channelNames = string(data.Properties.VariableNames(2:(end - 1)));
end
end
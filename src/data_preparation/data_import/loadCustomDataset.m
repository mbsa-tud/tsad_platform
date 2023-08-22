function [trainingData, timestampsTrain, labelsTrain, fileNamesTrain, ...
                testingData, timestampsTest, labelsTest, fileNamesTest, channelNames] = loadCustomDataset(datasetPath)
%LOADCUSTOMDATASET Loads the custom dataset from CSV files.

trainingData = [];
testingData = [];
timestampsTrain = [];
timestampsTest = [];
fileNamesTrain = [];
fileNamesTest = [];
labelsTrain = [];
labelsTest = [];
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
    timestampsTrain = cell(numOfTrainingFiles, 1);
    labelsTrain = cell(numOfTestingFiles, 1);
    fileNamesTrain = strings(numOfTrainingFiles, 1);
end
if numOfTestingFiles > 0
    testingData = cell(numOfTestingFiles, 1);
    timestampsTest = cell(numOfTestingFiles, 1);
    labelsTest = cell(numOfTestingFiles, 1);
    fileNamesTest = strings(numOfTestingFiles, 1);
end
    
for data_idx = 1:numOfTrainingFiles
    file = fullfile(dataTrainPath, trainingFiles(data_idx).name);
    data = readtable(file);

    name = strsplit(trainingFiles(data_idx).name, ".");
    fileNamesTrain(data_idx) = name(1);
    trainingData{data_idx} = data{:, 2:(end - 1)};
    labelsTrain{data_idx} = logical(data{:, end});                

    try
        timestampsTrain{data_idx} = datetime(data{:, 1});
    catch
        timestampsTrain{data_idx} = data{:, 1};
    end

    channelNames = string(data.Properties.VariableNames(2:(end - 1)));
end


for data_idx = 1:numOfTestingFiles
    file = fullfile(dataTestPath, testingFiles(data_idx).name);
    data = readtable(file);

    name = strsplit(testingFiles(data_idx).name, ".");
    fileNamesTest(data_idx) = name(1);
    testingData{data_idx} = data{:, 2:(end - 1)};
    labelsTest{data_idx} = logical(data{:, end});

    try
        timestampsTest{data_idx} = datetime(data{:, 1});
    catch
        timestampsTest{data_idx} = data{:, 1};
    end

    channelNames = string(data.Properties.VariableNames(2:(end - 1)));
end
end
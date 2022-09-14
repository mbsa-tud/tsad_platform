% This script orders all files from the DATASET_PATH (dataset downloaded
% from: https://hpi-information-systems.github.io/timeeval-evaluation-paper/notebooks/Datasets.html)
% into separate folders called train, test and metadata.

DATASET_PATH = 'C:\Ich\Studium\Bachelorarbeit\Inhalt\Git\tsad_platform_parallel_dev\tsad_platform\datasets\OtherDatasets\Multivariate\multivariate\SMD';

files = dir([DATASET_PATH '/*.csv']);
metaFiles = dir([DATASET_PATH '/*.json']);

for k = 1:length(files)
    fileName = fullfile(DATASET_PATH, files(k).name);
    
    splitName = split(files(k).name, '.');
    type = splitName{end-1};

    switch type
        case 'train'
            folderName = fullfile(DATASET_PATH, splitName{1}, 'train');
        case 'test'
            folderName = fullfile(DATASET_PATH, splitName{1}, 'test');
        otherwise
            disp('error, file is invalid')
    end
    
    if ~exist(folderName, 'dir')
        mkdir(folderName);
    end

    movefile(fileName, folderName);
end

for k = 1:length(metaFiles)
    fileName = fullfile(DATASET_PATH, metaFiles(k).name);
    splitName = split(metaFiles(k).name, '.');
    folderName = fullfile(DATASET_PATH, splitName{1}, 'metadata');
    
    if ~exist(folderName, 'dir')
        mkdir(folderName);
    end

    movefile(fileName, folderName);
end
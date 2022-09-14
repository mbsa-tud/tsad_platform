DATASET_PATH = 'C:\Ich\Studium\Bachelorarbeit\Inhalt\Git\tsad_platform\myApp_resources\OtherDatasets\Unsupervised_GutenTAG';

dirs = dir(DATASET_PATH);

for k = 1:length(dirs)
    fullPath = fullfile(DATASET_PATH, dirs(k).name);
    if strncmpi(dirs(k).name, '.', 1)
        continue
    end
    trainPath = fullfile(fullPath, 'train');
    testPath = fullfile(fullPath, 'test');
    mkdir(trainPath);
    mkdir(testPath);
    movefile(fullfile(fullPath, 'train_anomaly.csv'), trainPath);
    movefile(fullfile(fullPath, 'test.csv'), testPath);
    delete(fullfile(fullPath, 'train_no_anomaly.csv'));
    disp(fullPath)
end
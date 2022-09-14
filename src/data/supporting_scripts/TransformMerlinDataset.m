% Script for transforming the MERLIN Dataset into csv format.

DATASET_PATH = 'C:\Ich\Studium\Bachelorarbeit\Inhalt\Git\tsad_platform\myApp_resources\OtherDatasets\MERLIN\UCR_Anomaly_FullData';

files = dir([DATASET_PATH '/*.txt']);

for k = 1:length(files)
    try
        disp(files(k).name);
        filePath = fullfile(DATASET_PATH, files(k).name);
        splitName = strsplit(files(k).name, '.');
        justName = splitName{1};
        fileParts = strsplit(justName, '_');
    
        datasetName = sprintf('%s_%s_%s_%s', fileParts{1}, fileParts{2}, fileParts{3}, fileParts{4});
        endTrain = str2double(fileParts{5});
        beginAnomaly = str2double(fileParts{6}) - endTrain;
        endAnomaly = str2double(fileParts{7}) - endTrain;
        datasetPath = fullfile(DATASET_PATH, datasetName);
        trainPath = fullfile(datasetPath, 'train');
        testPath = fullfile(datasetPath, 'test');
        trainFileName = fullfile(trainPath, sprintf('%s_train.csv', datasetName));
        testFileName = fullfile(testPath, sprintf('%s_test.csv', datasetName));
    
        data = readtable(filePath, Delimiter='\t');
        data = table2array(data);
        data_train = data(1:endTrain);
        data_test = data(endTrain+1:end);
        labels_train = zeros(endTrain, 1);
        labels_test = zeros(length(data)-endTrain, 1);
        labels_test(beginAnomaly:endAnomaly, 1) = 1;
        timestamps_train = (1:endTrain)';
        timestamps_test = (1:length(data)-endTrain)';
    
        final_table_train = table(timestamps_train, data_train, labels_train);
        final_table_test = table(timestamps_test, data_test, labels_test);
        final_table_train.Properties.VariableNames = {'timestamp', 'value', 'is_anomaly'};
        final_table_test.Properties.VariableNames = {'timestamp', 'value', 'is_anomaly'};
    
        if ~exist(datasetPath, 'dir')
            mkdir(datasetPath);
        end
        if ~exist(trainPath, 'dir')
            mkdir(trainPath);
        end
        if ~exist(testPath, 'dir')
            mkdir(testPath);
        end
    
        writetable(final_table_train, trainFileName);
        writetable(final_table_test, testFileName);
    catch 
    end
end

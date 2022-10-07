function prepareDatasetForDynamicSwitch(datasetPath)
%PREPAREDATASETFORDYNAMICSWITCH
%
% Splits the dataset for training and testing the dynamic switch into a
% train_switch and test_switch folder

fprintf('Splitting dataset for dynamic switch.\nCreating new folders: train_switch, test_switch');

dataTestPath = fullfile(datasetPath, 'test');
trainSwitchPath = fullfile(datasetPath, 'train_switch');
testSwitchPath = fullfile(datasetPath, 'test_switch');

if exist(trainSwitchPath, 'dir')
    rmdir(trainSwitchPath, 's');
end
if exist(testSwitchPath, 'dir')
    rmdir(testSwitchPath, 's');
end

mkdir(trainSwitchPath);
mkdir(testSwitchPath);

testingFiles = dir(fullfile(dataTestPath, '*.csv'));

if numel(testingFiles) == 0                
    return;
end

numOfTestingFiles = numel(testingFiles);
splitByFile = true;

if splitByFile    
    idx = randperm(numOfTestingFiles);
    splitPoint = floor(numOfTestingFiles / 2);
    for i = 1:numOfTestingFiles
        oldFile = fullfile(dataTestPath, testingFiles(idx(i)).name);
        trainFile = fullfile(trainSwitchPath, testingFiles(idx(i)).name);
        testFile = fullfile(testSwitchPath, testingFiles(idx(i)).name);
    
        data = readtable(oldFile);
        
        if i <= splitPoint
            writetable(data, trainFile);
        else
            writetable(data, testFile);
        end
    end
else
    % split each timeseries in half, randomly assign the two parts either to 
    % test or train set
    for i = 1:numOfTestingFiles
        oldFile = fullfile(dataTestPath, testingFiles(i).name);
        trainFile = fullfile(trainSwitchPath, testingFiles(i).name);
        testFile = fullfile(testSwitchPath, testingFiles(i).name);
    
        data = readtable(oldFile);
    
        splitPoint = floor(size(data, 1) / 2);
        fullData = {data(1:splitPoint, :), data((splitPoint + 1):end, :)};
        idx = randperm(2);
    
        writetable(fullData{idx(1)}, trainFile);
        writetable(fullData{idx(2)}, testFile);
    end
end
end

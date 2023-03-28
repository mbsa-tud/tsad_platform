function finalTable =  evaluateAllForDataset(datasetPath, models, useFraction, preprocMethod, ratioTestVal, thresholds, dynamicThresholdSettings, trainingPlots, parallelEnabled)
%EVALUATEALLFORDATASET Main function for training and testing all specified
%models on an entire dataset

fprintf('\n ----------------------------- \n');
fprintf('###  Evaluating all models  ###');
fprintf('\n ----------------------------- \n');

% Variable initialization
scoreNames = table(METRIC_NAMES);
scoreNames.Properties.VariableNames = "Metric";

% Create folders for results
% Structure: Dataset_Sweep_Results -> datasetName -> thresholdName -> all_results, 
%                                                                     Average_Scores.csv
datasetOutputFolder = fullfile(pwd, 'Auto_Run_Results');
if ~exist(datasetOutputFolder, 'dir')
    mkdir(datasetOutputFolder);
end

datasetPath_split = strsplit(datasetPath, filesep);
datasetName = datasetPath_split{end};
datasetOutputFolder = fullfile(datasetOutputFolder, datasetName);
if ~exist(datasetOutputFolder, 'dir')
    mkdir(datasetOutputFolder);
end

thresholdSubfolders = strings(length(thresholds), 1);

for thr_idx = 1:length(thresholds)
    thresholdSubfolders(thr_idx) = fullfile(datasetOutputFolder, thresholds(thr_idx));
    if ~exist(thresholdSubfolders(thr_idx), 'dir')
        mkdir(thresholdSubfolders(thr_idx));
    end
end

fprintf('Selected dataset: %s\n', datasetName);

% Get all dataset files
if exist(fullfile(datasetPath, 'test'), 'dir')
    % For single entity datasets
    indices = 1;
    isMultiEntity = false;
else
    % For multiple entity datasets
    d = dir(datasetPath);
    subFolders = d([d(:).isdir]);
    subFolders = subFolders(~ismember({subFolders(:).name},{'.','..'}));
    
    indices = randperm(length(subFolders), ceil(useFraction * length(subFolders)));
    isMultiEntity = true;
end

if isempty(indices)
    error("Invalid dataset selected");
end


% Initialize table for evaluation results
scoreMatrix = cell(length(thresholds), 1);

allTestFiles = [];

% Get all model names
finalTableVariableNames = "Metric";
for model_idx = 1:length(models)
    finalTableVariableNames = [finalTableVariableNames models(model_idx).modelOptions.label];
end




% Evaluate each model for every dataset
for dataset_idx = 1:length(indices)    
    if isMultiEntity
        fprintf('\n\nEvaluating subset %d/%d \n\n', dataset_idx, length(indices));
        fprintf('%s\n\n', subFolders(indices(dataset_idx)).name);
        dataPath = fullfile(datasetPath, subFolders(indices(dataset_idx)).name);
    else
        dataPath = datasetPath;
    end
    
    % Run evaluation
    [tmpScores, testFileNames] = trainAndEvaluateAllModels(dataPath, models, ...
        preprocMethod, ratioTestVal, thresholds, dynamicThresholdSettings, trainingPlots, parallelEnabled);

    allTestFiles = [allTestFiles testFileNames];

    for thr_idx = 1:length(thresholds)
        scoreMatrix{thr_idx, 1} = [scoreMatrix{thr_idx, 1}; tmpScores{thr_idx, 1}];
    end
    fprintf('\n ----------------------------- \n');
end



% Score calculations and saving of results
fprintf('\nCalculating max, min, average and standard deviation of scores\n\n')
for thr_idx = 1:length(scoreMatrix)
    scoreMatrix_tmp = scoreMatrix{thr_idx, 1};

    numOfTestingFiles = length(scoreMatrix_tmp);
    
    % Calc average scores
    avgScores = calcAverageScores(scoreMatrix_tmp);
    
    outputFolder = thresholdSubfolders(thr_idx);

    all_results_folder = fullfile(outputFolder, 'all_results');
    if ~exist(all_results_folder, 'dir')
        mkdir(all_results_folder);
    end
    
    for data_idx = 1:numOfTestingFiles
        all_results_filename = fullfile(all_results_folder, sprintf('%s_%s.csv', allTestFiles(data_idx), datestr(now,'mm-dd-yyyy_HH-MM')));
        scoreTable_tmp = array2table(scoreMatrix_tmp{data_idx, 1});
        scoreTable = [scoreNames scoreTable_tmp];
        scoreTable.Properties.VariableNames = finalTableVariableNames;
        writetable(scoreTable, all_results_filename);
    end
    
    fileName_Avg = fullfile(outputFolder, sprintf('Average_Scores__%s.csv', datestr(now,'mm-dd-yyyy_HH-MM')));    

    avg_tmp = array2table(avgScores);
    avgTable = [scoreNames avg_tmp];
    avgTable.Properties.VariableNames = finalTableVariableNames;
    
    % Write to files
    writetable(avgTable, fileName_Avg);
    
    % Return scores for first threshold to display in platform
    if thr_idx == 1
        finalTable = avgTable;
    end
end

fprintf('Saved all files to %s\n', datasetOutputFolder);
fprintf('\n ----------------------------- \n');
fprintf('###  Finished successfully! ###');
fprintf('\n ----------------------------- \n');
end

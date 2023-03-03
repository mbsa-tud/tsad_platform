function finalTable =  GT_evaluateAllForDataset(datasetPath, models, useFraction, preprocMethod, ratioTestVal, thresholds, dynamicThresholdSettings, trainingPlots, trainParallel,augmentationChoice,intensity,trained)
%EVALUATEALLFORDATASET
%
% Encapsulates the training and testing for all models for a dataset

fprintf('\n ----------------------------- \n');
fprintf('###  Evaluating all models  ###');
fprintf('\n ----------------------------- \n');

% Variable initialization
scoreNames = table(["F1 Score (point-wise)"; ...
                    "F1 Score (event-wise)"; ...
                    "F1 Score (point-adjusted)"; ...
                    "F1 Score (composite)"; ...
                    "F0.5 Score (point-wise)"; ...
                    "F0.5 Score (event-wise)"; ...
                    "F0.5 Score (point-adjusted)"; ...
                    "F0.5 Score (composite)"; ...
                    "Precision (point-wise)"; ...
                    "Precision (event-wise)"; ...
                    "Precision (point-adjusted)"; ...
                    "Recall (point-wise)"; ...
                    "Recall (event-wise)"; ...
                    "Recall (point-adjusted)"]);
scoreNames.Properties.VariableNames = "Metric";

% Create folders for results
% Structure: Dataset_Sweep_Results -> datasetName -> thresholdName -> all_results, 
%                                                                     Max_Scores.csv,
%                                                                     Min_Scores.csv,
%                                                                     Avg_Scores.csv,
%                                                                     Std_Scores.csv
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

for i = 1:length(thresholds)
    thresholdSubfolders(i) = fullfile(datasetOutputFolder, thresholds(i));
    if ~exist(thresholdSubfolders(i), 'dir')
        mkdir(thresholdSubfolders(i));
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

% Get all model names
models_DNN = models.models_DNN;
models_CML = models.models_CML;
models_S = models.models_S;

allTestFiles = [];
allModelNames = "Metric";
for i = 1:length(models_DNN)
    allModelNames = [allModelNames models_DNN(i).options.label];
end
for i = 1:length(models_CML)
    allModelNames = [allModelNames models_CML(i).options.label];
end
for i = 1:length(models_S)
    allModelNames = [allModelNames models_S(i).options.label];
end




% Evaluate each model for every dataset
for i = 1:length(indices)    
    if isMultiEntity
        fprintf('\n\nEvaluating subset %d/%d \n\n', i, length(indices));
        fprintf('%s\n\n', subFolders(indices(i)).name);
        dataPath = fullfile(datasetPath, subFolders(indices(i)).name);
    else
        dataPath = datasetPath;
    end
    
    % Run evaluation
    [tmpScores, testFileNames] = GT_trainAndEvaluateAllModels(dataPath, models_DNN, models_CML, models_S, ...
        preprocMethod, ratioTestVal, thresholds, dynamicThresholdSettings, trainingPlots, trainParallel,augmentationChoice,intensity,trained);

    allTestFiles = [allTestFiles testFileNames];

    for thrIdx = 1:length(thresholds)
        scoreMatrix{thrIdx, 1} = [scoreMatrix{thrIdx, 1}; tmpScores{thrIdx, 1}];
    end
    fprintf('\n ----------------------------- \n');
end



% Score calculations and saving of results
fprintf('\nCalculating max, min, average and standard deviation of scores\n\n')
for thr_idx = 1:length(scoreMatrix)
    scoreMatrix_tmp = scoreMatrix{thr_idx, 1};
    
    % Combine results into max, min, avg and std tables
    numOfScoreMatrices = length(scoreMatrix_tmp);
    numOfModels = size(scoreMatrix_tmp{1, 1}, 2);
    numOfMetrics = size(scoreMatrix_tmp{1, 1}, 1);

    avgScores = zeros(numOfMetrics, numOfModels);
    stdScores = zeros(numOfMetrics, numOfModels);
    minScores = zeros(numOfMetrics, numOfModels);
    maxScores = zeros(numOfMetrics, numOfModels);
    
    for i = 1:numOfModels
        for j = 1:numOfMetrics
            scores = zeros(numOfScoreMatrices, 1);
            for k = 1:numOfScoreMatrices
                tmp = scoreMatrix_tmp{k, 1};
                if isnan(tmp(j, i))
                    tmp(j, i) = 0;
                end
                scores(k, 1) = tmp(j, i);
            end
            minScore = min(scores);
            maxScore = max(scores);
            avgScore = mean(scores);
            stdScore = std(scores);
            avgScores(j, i) = avgScore;
            stdScores(j, i) = stdScore;
            minScores(j, i) = minScore;
            maxScores(j, i) = maxScore;
        end
    end
    
    
    outputFolder = thresholdSubfolders(thr_idx);

    all_results_folder = fullfile(outputFolder, 'all_results');
    if ~exist(all_results_folder, 'dir')
        mkdir(all_results_folder);
    end
    
    for i = 1:length(scoreMatrix_tmp)
        all_results_filename = fullfile(all_results_folder, sprintf('%s_%s_augmented_data.csv', allTestFiles(i), datestr(now,'mm-dd-yyyy_HH-MM')));
        scoreTable_tmp = array2table(scoreMatrix_tmp{i, 1});
        scoreTable = [scoreNames scoreTable_tmp];
        scoreTable.Properties.VariableNames = allModelNames;
        writetable(scoreTable, all_results_filename);
    end
    
    fileName_Max = fullfile(outputFolder, sprintf('Max_Scores__%s_augmented_data.csv', datestr(now,'mm-dd-yyyy_HH-MM')));
    fileName_Min = fullfile(outputFolder, sprintf('Min_Scores__%s_augmented_data.csv', datestr(now,'mm-dd-yyyy_HH-MM')));
    fileName_Avg = fullfile(outputFolder, sprintf('Avg_Scores__%s_augmented_data.csv', datestr(now,'mm-dd-yyyy_HH-MM')));
    fileName_Std = fullfile(outputFolder, sprintf('Std_Scores__%s_augmented_data.csv', datestr(now,'mm-dd-yyyy_HH-MM')));
    

    max_tmp = array2table(maxScores);
    maxTable = [scoreNames max_tmp];
    maxTable.Properties.VariableNames = allModelNames;
    min_tmp = array2table(minScores);
    minTable = [scoreNames min_tmp];
    minTable.Properties.VariableNames = allModelNames;
    avg_tmp = array2table(avgScores);
    avgTable = [scoreNames avg_tmp];
    avgTable.Properties.VariableNames = allModelNames;
    std_tmp = array2table(stdScores);
    stdTable = [scoreNames std_tmp];
    stdTable.Properties.VariableNames = allModelNames;

    writetable(maxTable, fileName_Max);
    writetable(minTable, fileName_Min);
    writetable(avgTable, fileName_Avg);
    writetable(stdTable, fileName_Std);

    if thr_idx == 1
        finalTable = avgTable;
    end
end

fprintf('Saved all files to %s\n', datasetOutputFolder);
fprintf('\n ----------------------------- \n');
fprintf('###  Finished successfully! ###');
fprintf('\n ----------------------------- \n');
end

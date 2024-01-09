function autoRun(datasetPath, outputPath, models, preprocessingMethod, ...
                    ratioTestVal, dynamicThresholdSettings, ...
                    trainingPlots, parallelEnabled, ...
                    augmentationMode, augmentationIntensity, ...
                    augmentedTrainingEnabled, getCompTime)
%AUTORUN Run training and detection for single-or multi-entity datasets (=datasets with multiple subsets) and
%store the results


fprintf("\n ------------------------- \n");
fprintf("###  Starting Auto Run  ###");
fprintf("\n ------------------------- \n");

thresholds = THRESHOLD_NAMES;
numThresholds = numel(thresholds);

% Variable initialization
scoreNames = table(METRIC_NAMES_WITH_COMP_TIME);
scoreNames.Properties.VariableNames = "Metric";

% Create folders to store results in .csv tables
datasetPath_split = strsplit(datasetPath, filesep);
datasetName = datasetPath_split{end};

fprintf("Selected dataset: %s\n", datasetName);

% Check if a multi-entity dataset was selected
if ~exist(fullfile(datasetPath, "train"), "dir") && ~exist(fullfile(datasetPath, "test"), "dir")
     % For multiple entity datasets
    d = dir(datasetPath);
    subFolders = d([d(:).isdir]);
    subFolders = subFolders(~ismember({subFolders(:).name},{'.', '..'}));
    
    subsetIndices = randperm(numel(subFolders));
    isMultiEntity = true;
else
   % For single entity datasets
    subsetIndices = 1;
    isMultiEntity = false;
end

if isempty(subsetIndices)
    error("Invalid dataset selected");
end


% Initialize table for evaluation results
allScores = cell(numThresholds, 1);

allTestFileNames = [];

% Get all model names
modelIDs = fieldnames(models);
numModels = numel(modelIDs);
finalTableVariableNames = strings(1, numModels);
finalTableVariableNames(1) = "Metric";

for i = 1:numModels
    finalTableVariableNames(i + 1) = models.(modelIDs{i}).instanceInfo.label;
end


% Evaluate each model for every dataset
for i = 1:numel(subsetIndices)    
    if isMultiEntity
        fprintf("\n\nEvaluating subset %d/%d \n\n", i, numel(subsetIndices));
        fprintf("%s\n\n", subFolders(subsetIndices(i)).name);
        subsetPath = fullfile(datasetPath, subFolders(subsetIndices(i)).name);
    else
        subsetPath = datasetPath;
    end

    % Load data
    fprintf("\nLoading data\n\n");
    [dataTrainRaw, ~, labelsTrain, ~, ...
        dataTestRaw, ~, labelsTest, fileNamesTest, ~] = loadCustomDataset(subsetPath);
    
    if isempty(dataTestRaw) && isempty(dataTrainRaw)
        error("Invalid dataset selected");
    end

    % Preprocessing

    fprintf("\nPreprocessing data with method: %s\n\n", preprocessingMethod);
    [dataTrain, dataTest, ~] = preprocessData(dataTrainRaw, dataTestRaw, preprocessingMethod, false, []);
    
    [dataTrain, dataTest] = augmentData(dataTrain, dataTest, augmentationMode, augmentationIntensity, augmentedTrainingEnabled);
    [dataTest, labelsTest, fileNamesTest, dataTestVal, labelsTestVal, ~] = splitTestVal(dataTest, labelsTest, fileNamesTest, ratioTestVal);    
    
    if numel(fileNamesTest) == 0
        error("No testing data found");
    end

    % Init subset score table
    subsetScores = cell(numThresholds, 1);
    for j = 1:numel(subsetScores)
        subsetScores{j} = cell(numel(fileNamesTest), 1);
    end

    % Train and test models

    for j = 1:numModels
        models.(modelIDs{j}).train(dataTrain, labelsTrain, dataTestVal, labelsTestVal, trainingPlots, true);

        % For all test files
        for k = 1:numel(fileNamesTest)                
            [anomalyScores, ~, labels, compTime] = models.(modelIDs{j}).detect(dataTest, labelsTest);
            
            % For all thresholds in the thresholds variable
            for l = 1:numThresholds
                [predictedLabels, ~] = models.(modelIDs{j}).applyThreshold(anomalyScores, labels, thresholds(l), dynamicThresholdSettings, []);
        
                scores = [compTime; computeMetrics(anomalyScores, predictedLabels, labels)];
                tmp = subsetScores{l};
                tmp{k} = [tmp{k}, scores];
                subsetScores{l} = tmp;
            end
        end
    end


    allTestFileNames = [allTestFileNames; fileNamesTest];

    for j = 1:numThresholds
        allScores{j} = [allScores{j}; subsetScores{j}];
    end
    fprintf("\n ----------------------------- \n");
end

datasetOutputFolder = fullfile(outputPath, "Auto_Run_Results");
if ~exist(datasetOutputFolder, "dir")
    mkdir(datasetOutputFolder);
end

datasetPath_split = strsplit(datasetPath, filesep);
datasetName = datasetPath_split{end};
datasetOutputFolder = fullfile(datasetOutputFolder, datasetName);
if ~exist(datasetOutputFolder, "dir")
    mkdir(datasetOutputFolder);
end

thresholdSubfolders = strings(numThresholds, 1);

for i = 1:numThresholds
    thresholdSubfolders(i) = fullfile(datasetOutputFolder, sprintf("THRESHOLD--%s", thresholds(i)));
    if ~exist(thresholdSubfolders(i), "dir")
        mkdir(thresholdSubfolders(i));
    end
end

% Score calculations and saving of results
fprintf("\nCalculating max, min, average and standard deviation of scores\n\n")
for i = 1:numel(allScores)
    scoreMatrix_tmp = allScores{i};

    numTestedFiles = numel(scoreMatrix_tmp);
    
    % Calc average scores
    avgScores = calcAverageScores(scoreMatrix_tmp);
    
    outputFolder = thresholdSubfolders(i);

    allResultsFolder = fullfile(outputFolder, "all_results");
    if ~exist(allResultsFolder, "dir")
        mkdir(allResultsFolder);
    end
    
    for j = 1:numTestedFiles
        allResultsFileName = fullfile(allResultsFolder, sprintf("%s_%s.csv", allTestFileNames(j), datetime("now", 'Format','MMMM_d_yyyy_HH_mm_ss')));
        scoreTable_tmp = array2table(scoreMatrix_tmp{j});
        scoreTable = [scoreNames scoreTable_tmp];
        scoreTable.Properties.VariableNames = finalTableVariableNames;
        writetable(scoreTable, allResultsFileName);
    end
    
    fileName_Avg = fullfile(outputFolder, sprintf("Average_Scores__%s.csv", datetime("now", 'Format','MMMM_d_yyyy_HH_mm_ss')));  

    avg_tmp = array2table(avgScores);
    avgTable = [scoreNames avg_tmp];
    avgTable.Properties.VariableNames = finalTableVariableNames;
    
    % Write to files
    writetable(avgTable, fileName_Avg);
end

fprintf("Saved all files to %s\n", datasetOutputFolder);
fprintf("\n -------------------------------------- \n");
fprintf("###  Finished Auto Run Successfully! ###");
fprintf("\n -------------------------------------- \n");
end

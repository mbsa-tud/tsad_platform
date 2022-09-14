function [bestOptions, finalTable, trainedModels] = autoOptimization(datasetPath, models, configOptFileName, preprocMethod, ratioTestVal, cmpScore, threshold, iterations)
% AUTOOPTIMIZATION automaitcally optimize hyperparameters for multiple models
%
% Description: Optimization of hyperparameters of all models from config
%              file using bayesian optimization
%
% Input: datasetPath:       string - path to the dataset
%        models:    struct - models to optimize
%        configOptFileName: string - filename for optimization config (.json)
%        preprocMethod:     string - method for preprocessing
%                                    Possible values: raw data, 
%                                                     standardize, 
%                                                     rescale
%        ratioTestVal:      double (0, 1] - ratio of validation set to full
%                                           test set
%        cmpScore:          string - score to optimize models for
%                                    Possible values: weighted f1score,
%                                                     unweighted f1score,
%                                                     eventwise f1score,
%                                                     composite f1score,
%        threshold:         string - threshold to use
%        iterations:        double [1, inf] - number of iterations for
%                                             bayesian optimization for
%                                             each model
%
% Output: bestOptions:      struct - config containing best options for
%                                    each model
%         finalTable:       table - all scores for all optimized models

% Load data
[rawTrainingData, ~, labelsTrainingData, ~, ...
    rawTestingData, ~, labelsTestingData, filesTestingData] = loadCustomDataset(datasetPath, 'test');

% Preprocessing
[preprocessedTrainingData, ...
    preprocessedTestingData, ~, ~, ~, ~] = preprocessData(rawTrainingData, rawTestingData, preprocMethod, false, []);         

% Split test/val set
[preprocessedTestingData, labelsTestingData, ...
    testValData, testValLabels, ~] = splitTestVal(preprocessedTestingData, labelsTestingData, ratioTestVal, filesTestingData);

bestOptions_DNN = [];
bestOptions_CML = [];
bestOptions_S = [];

for i = 1:length(models)
    % Load hyperparameters to be optimized
    optVars = getOptimizationVariables(models(i).options.model, configOptFileName);
    
    % If no hyperparameters are available for the model, save default
    % options
    if isempty(optVars)
        bestOptions_tmp.options = models(i).options;
        switch models(i).options.type
            case 'DNN'
                bestOptions_DNN = [bestOptions_DNN; bestOptions_tmp];
            case 'CML'
                bestOptions_CML = [bestOptions_CML; bestOptions_tmp];
            case 'S'
                bestOptions_S = [bestOptions_S; bestOptions_tmp];
        end
        continue;
    end
    
    % Optimization
    results = optimizeModel(optVars, models(i), preprocessedTrainingData, ...
                            labelsTrainingData, testValData, testValLabels, ...
                            preprocessedTestingData, labelsTestingData, ...
                            threshold, cmpScore, iterations, true);

    optimumVars = results.XAtMinObjective;
    
    bestOptions_tmp.options = adaptModelOptions(models(i).options, optimumVars);
    switch models(i).options.type
        case 'DNN'
            bestOptions_DNN = [bestOptions_DNN; bestOptions_tmp];
        case 'CML'
            bestOptions_CML = [bestOptions_CML; bestOptions_tmp];
        case 'S'
            bestOptions_S = [bestOptions_S; bestOptions_tmp];
    end
end

if ~isempty(bestOptions_DNN)
    bestOptions.DNN_Models = bestOptions_DNN;
end
if ~isempty(bestOptions_CML)
    bestOptions.CML_Models = bestOptions_CML;
end
if ~isempty(bestOptions_S)
    bestOptions.S_Models = bestOptions_S;
end

% Evaluate optimal models and return results
[scoreMatrix_tmp, ~, trainedModels] = evaluateAllModels(datasetPath, 'test', bestOptions_DNN, bestOptions_CML, bestOptions_S, ...
        preprocMethod, ratioTestVal, threshold, false, false);

% Change modle labels
fields = fieldnames(trainedModels);
for i = 1:numel(fields)
    trainedModels.(fields{i}).options.label = trainedModels.(fields{i}).options.label + " (optimized)";
    trainedModels.(fields{i}).options.id = trainedModels.(fields{i}).options.id + "_optimized";
end

% Combine results into max, min, avg and std tables
scoreMatrix_tmp = scoreMatrix_tmp{1, 1};
numOfScoreMatrices = length(scoreMatrix_tmp);
numOfModels = size(scoreMatrix_tmp{1, 1}, 2);
numOfMetrics = size(scoreMatrix_tmp{1, 1}, 1);

avgScores = zeros(numOfMetrics, numOfModels);

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
        avgScore = mean(scores);
        avgScores(j, i) = avgScore;
    end
end

scoreNames = table([
    "Composite F1 Score"; ...
    "Point-wise F1 Score"; ...
    "Event-wise F1 Score"; ...
    "Point-adjusted F1 Score"; ...
    "Point-wise F0.5 Score"; ...
    "Event-wise F0.5 Score"; ...
    "Point-adjusted F0.5 Score"; ...
    "Point-wise Precision"; ...
    "Event-wise Precision"; ...
    "Point-adjusted Precision"; ...
    "Point-wise Recall"; ...
    "Event-wise Recall"; ...
    "Point-adjusted Recall"]);

allModelNames = "Metric";
for i = 1:length(bestOptions_DNN)
    allModelNames = [allModelNames bestOptions_DNN(i).options.label];
end
for i = 1:length(bestOptions_CML)
    allModelNames = [allModelNames bestOptions_CML(i).options.label];
end
for i = 1:length(bestOptions_S)
    allModelNames = [allModelNames bestOptions_S(i).options.label];
end

avg_tmp = array2table(avgScores);
finalTable = [scoreNames avg_tmp];
finalTable.Properties.VariableNames = allModelNames;

% Save best config to dataset
fileID = fopen(fullfile(datasetPath, 'config_optimized.json'), 'w');
fprintf(fileID, jsonencode(bestOptions, PrettyPrint=true));
fclose(fileID);
end
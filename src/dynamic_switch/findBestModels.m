function findBestModels(datasetPath, models, preprocMethod, ratioValTest, cmpMetric)
%FINDBESTMODELS
%
% Auto-labels the dynamic switch train dataset

% Get all model names
models_DNN = models.models_DNN;
models_CML = models.models_CML;
models_S = models.models_S;

allModelNames = [];
for i = 1:length(models_DNN)
    allModelNames = [allModelNames string(models_DNN(i).options.id)];
end
for i = 1:length(models_CML)
    allModelNames = [allModelNames string(models_CML(i).options.id)];
end
for i = 1:length(models_S)
    allModelNames = [allModelNames string(models_S(i).options.id)];
end

switch cmpMetric
    case 'Composite F1 Score'
        threshold = "bestFscoreComposite";
    case 'Point-wise F1 Score'
        threshold = "bestFscorePointwise";
    case 'Event-wise F1 Score'
        threshold = "bestFscoreEventwise";
    case 'Point-adjusted F1 Score'
        threshold = "bestFscorePointAdjusted";
end

[tmpScores, testFileNames, trainedModels, preprocParams] = evaluateAllModels(datasetPath, 'train_switch', models_DNN, models_CML, models_S, ...
        preprocMethod, ratioValTest, threshold);

% Save models to models.mat file
fileName = fullfile(datasetPath, 'models.mat');
assignin('base', 'trainedModels', trainedModels);
save(fileName, 'trainedModels');

% Save preproc. parameters
fileID = fopen(fullfile(datasetPath, 'preprocParams.json'), 'w');
fprintf(fileID, jsonencode(preprocParams, PrettyPrint=true));
fclose(fileID);


switch cmpMetric
    case 'Composite F1 Score'
        score_idx = 1;
    case 'Point-wise F1 Score'
        score_idx = 2;
    case 'Event-wise F1 Score'
        score_idx = 3;
    case 'Point-adjusted F1 Score'
        score_idx = 4;
end

fprintf('Comparing model scores\n');

scores_all = tmpScores{1, 1};
for i = 1:length(scores_all)
    [~, idx] = max(scores_all{i, 1}(score_idx, :));
    
    bestModels.(testFileNames(i)) = allModelNames(idx); 
end

expPath = fullfile(datasetPath, 'train_switch', 'best_models.json');
fid = fopen(expPath, 'w');
fprintf(fid, jsonencode(bestModels, PrettyPrint=true));
fclose(fid);
end
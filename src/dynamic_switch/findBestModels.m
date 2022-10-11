function findBestModels(datasetPath, models, preprocMethod, ratioTestVal, cmpMetric)
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

[tmpScores, testFileNames] = evaluateAllModels(datasetPath, 'train_switch', models_DNN, models_CML, models_S, ...
        preprocMethod, ratioTestVal, threshold, true, true);

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
%     for k = 1:size(scores_all{i, 1}, 2)
%         fprintf('%f\n', scores_all{i, 1}(1, k));
%     end
    
    % fprintf("%s - best model: %s with score: %f\n", testFileNames(i), allModelNames(idx), maximum);
    
    fileName = sprintf('%s_best_model.txt', testFileNames(i));
    expPath = fullfile(datasetPath, 'train_switch', fileName);
    fid = fopen(expPath, 'w');
    fprintf(fid, '%s\n', allModelNames(idx));
    fclose(fid);
end
end
function avgScores = calcAverageScores(fullScores)
%CALCAVERAGESCORES Averages the scores across all tested files for every
%model

numOfModels = size(fullScores{1, 1}, 2);
numOfMetrics = size(fullScores{1, 1}, 1);
numOfTestingFiles = size(fullScores, 1);

avgScores = zeros(numOfMetrics, numOfModels);
for model_idx = 1:numOfModels
    for metric_idx = 1:numOfMetrics
        scores = zeros(numOfTestingFiles, 1);
        for data_idx = 1:numOfTestingFiles
            tmp = fullScores{data_idx, 1};
            if isnan(tmp(metric_idx, model_idx))
                scores(data_idx, 1) = 0; % Treat NaN as 0 for averaging
            else
                scores(data_idx, 1) = tmp(metric_idx, model_idx);
            end
        end
        avgScore = mean(scores);
        if avgScore == 0
            avgScore = NaN;
        end
        avgScores(metric_idx, model_idx) = avgScore;
    end
end
end

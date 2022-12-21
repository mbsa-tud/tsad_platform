function avgScores = calcAverageScores(fullScores)
%CALCAVERAGESCORES
%
% Averages the scores across all tested files

numOfMetrics = size(fullScores{1, 1}, 1);
numOfTestingFiles = size(fullScores, 1);

avgScores = zeros(numOfMetrics, 1);
for i = 1:numOfMetrics
    scores = zeros(numOfTestingFiles, 1);
    for j = 1:numOfTestingFiles
        tmp = fullScores{j, 1};
        if isnan(tmp(i, 1))
            tmp(i, 1) = 0;
        end
        scores(j, 1) = tmp(i, 1);
    end
    avgScore = mean(scores);
    if avgScore == 0
        avgScore = NaN;
    end
    avgScores(i, 1) = avgScore;
end
end
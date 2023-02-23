function reshapedPrediction = mergeOverlappingAnomalyScores(data, windowSize)
%reshapeOverlappingSubsequences
%
% Calculates the median anomaly score for all overlapping subsequences for
% the ML and statistical algorithms

data;

c = [];
for i = 1:size(data, 1)
    c(:, i) = data(i, :);
end
b = [];
c = flip(c);
for i = 1:(size(c, 2) - windowSize)
    b(i, :) = median(diag(c(:, i:(i + windowSize - 1))));
end
reshapedPrediction = b;
end

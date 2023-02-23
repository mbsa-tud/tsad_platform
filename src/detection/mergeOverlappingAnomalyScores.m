function reshapedanomalyScores = mergeOverlappingAnomalyScores(options, anomalyScores)
%mergeOverlappingAnomalyScores
%
% Calculates the median anomaly score for all overlapping subsequences for
% the ML and statistical algorithms

switch options.model
    case "Your model"
    otherwise
        windowSize = options.hyperparameters.data.windowSize.value;
        anomalyScores = repmat(anomalyScores, 1, windowSize);

        c = [];
        for i = 1:size(anomalyScores, 1)
            c(:, i) = anomalyScores(i, :);
        end
        b = [];
        c = flip(c);
        for i = 1:(size(c, 2) - windowSize)
            b(i, :) = median(diag(c(:, i:(i + windowSize - 1))));
        end
        reshapedanomalyScores = b;
end
end

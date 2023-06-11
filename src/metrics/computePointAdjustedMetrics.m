function [pre, rec, f1, f05] = computePointAdjustedMetrics(predictedLabels, labels)
%COMPUTEPOINTADJUSTEDMETRICS Computes poin-adjusted metrics

try
    sequences = findConsecutiveSequences(find(labels == 1));

    for i = 1:numel(sequences)
        if any(predictedLabels(sequences{i}, 1))
            predictedLabels(sequences{i}, 1) = 1;
        end
    end

    confmat = confusionmat(logical(labels), logical(predictedLabels));
    tp = confmat(2, 2);
    fp = confmat(1, 2);
    fn = confmat(2, 1);
    pre = tp / (tp + fp);
    rec = tp / (tp + fn);
    f1 = 2 * pre * rec / (pre + rec);
    f05 = (1 + 0.5^2) * (pre * rec) / ((0.5^2 * pre) + rec);
catch
    pre = NaN;
    rec = NaN;
    f1 = NaN;
    f05 = NaN;
end
end
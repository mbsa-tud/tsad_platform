function [pre, rec, f1, f05] = computePointwiseMetrics(predictedLabels, labels)
%COMPUTEPOINTWISEMETRICS Computes poinwise metrics

try
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
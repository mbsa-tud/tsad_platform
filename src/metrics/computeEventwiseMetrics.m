function [pre, rec, f1, f05] = computeEventwiseMetrics(predictedLabels, labels)
%COMPUTEEVENTWISEMETRICS Computes event-wise metrics

try
    fp = 0;
    fn = 0;
    tp = 0;


    predictedSequences = findConsecutiveAnomalySequences(find(predictedLabels == 1));
    trueSequences = findConsecutiveAnomalySequences(find(labels == 1));
    
    for i = 1:numel(trueSequences)
        if any(predictedLabels(trueSequences{i}))
            tp = tp + 1;
        else
            fn = fn + 1;
        end
    end
    
    for i = 1:numel(predictedSequences)
        if ~any(labels(predictedSequences{i}))
            fp = fp + 1;
        end
    end

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
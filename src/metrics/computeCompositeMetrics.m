function [f1, f05] = computeCompositeMetrics(predictedLabels, labels)
%COMPUTEPOINTWISEMETRICS Computes composite metrics (composed of point-wise
%precision and event-wise recall)

% Composite F-score
try
    confmat = confusionmat(logical(labels), logical(predictedLabels));
    tp_p = confmat(2, 2);
    fp_p = confmat(1, 2);
    pre_p = tp_p / (tp_p + fp_p); % pointwise precision
    
    tp_e = 0;
    fn_e = 0;
    trueSequences = findConsecutiveSequences(find(labels == 1));
    
    for i = 1:numel(trueSequences)
        if any(predictedLabels(trueSequences{i}, 1))
            tp_e = tp_e + 1;
        else
            fn_e = fn_e + 1;
        end
    end
    rec_e = tp_e / (tp_e + fn_e); % event-wise recall

    f1= 2 * pre_p * rec_e / (pre_p + rec_e);    
    f05 = (1 + 0.5^2) * (pre_p * rec_e) / ((0.5^2 * pre_p) + rec_e);
catch
    f1 = NaN;
    f05 = NaN;
end
end
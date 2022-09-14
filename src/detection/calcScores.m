function [scoresWeighted, scoresUnweighted, scoresPointAdjusted, compositeFScore] = calcScores(labels_pred, labels)
% Weighted scores
try
    confmat = confusionmat(logical(labels), logical(labels_pred));
    tp_w = confmat(2, 2);
    fp_w = confmat(1, 2);
    fn_w = confmat(2, 1);
    pre_w = tp_w / (tp_w + fp_w);
    rec_w = tp_w / (tp_w + fn_w);
    f1_score_w = 2 * pre_w * rec_w / (pre_w + rec_w);
    f05_score_w = (1 + 0.5^2) * (pre_w * rec_w) / ((0.5^2 * pre_w) + rec_w);
    scoresWeighted = [pre_w; rec_w; f1_score_w; f05_score_w];
catch ME
    pre_w = 0;
    scoresWeighted = [NaN; NaN; NaN; NaN];
end

% Unweighted scores
try
    [fp_u, fn_u, tp_u] = overlap_seg(labels, labels_pred);
    pre_u = tp_u / (tp_u + fp_u);
    rec_u = tp_u / (tp_u + fn_u);
    f1_score_u = 2 * pre_u * rec_u / (pre_u + rec_u);
    f05_score_u = (1 + 0.5^2) * (pre_u * rec_u) / ((0.5^2 * pre_u) + rec_u);                
    scoresUnweighted = [pre_u; rec_u; f1_score_u; f05_score_u];
catch ME
    scoresUnweighted = [NaN; NaN; NaN; NaN];
end

% Point-adjusted scores
tp_c = 0; % True positives for Composite F-score
fn_c = 0; % False negatives for Composite F-score
anomsPointAdjusted = labels_pred;
i = 1;
while i <= numel(labels)
    if labels(i, 1) == 1
        flag = 0;
        startPoint = i;
        endPoint = i;
        for j = 0:(numel(labels) - i)
            if labels(i + j, 1) == 0
                break
            end
            endPoint = i + j;
        end
        for j = 0:(endPoint - i)
            if labels_pred(i + j, 1) == 1
                flag = 1;
                break
            end
        end
        if flag == 1
            anomsPointAdjusted(startPoint:endPoint, 1) = 1;
            tp_c = tp_c + 1;
        else
            fn_c = fn_c + 1;
        end
        i = endPoint + 1;
        continue
    end
    i = i + 1;
end

try
    confmat = confusionmat(logical(labels), logical(anomsPointAdjusted));
    tp_a = confmat(2, 2);
    fp_a = confmat(1, 2);
    fn_a = confmat(2, 1);
    pre_a = tp_a / (tp_a + fp_a);
    rec_a = tp_a / (tp_a + fn_a);
    f1_score_a = 2 * pre_a * rec_a / (pre_a + rec_a);
    f05_score_a = (1 + 0.5^2) * (pre_a * rec_a) / ((0.5^2 * pre_a) + rec_a);
    scoresPointAdjusted = [pre_a; rec_a; f1_score_a; f05_score_a];
catch ME
    scoresPointAdjusted = [NaN; NaN; NaN; NaN];
end

% Composite F-score
pre_c = pre_w;
rec_c = tp_c / (tp_c + fn_c);
compositeFScore = 2 * pre_c * rec_c / (pre_c + rec_c);

scoresWeighted = round(scoresWeighted, 4);
scoresUnweighted = round(scoresUnweighted, 4);
scoresPointAdjusted = round(scoresPointAdjusted, 4);
compositeFScore = round(compositeFScore, 4);
end

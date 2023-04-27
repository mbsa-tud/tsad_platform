function scores = calcScores(anomalyScores, predictedLabels, labels, justLabels)
%CALCSCORES Calculates the different metrics
% justLabels is true if the model outpus labels instead of anomaly scores

% Pointwise (weighted) scores
try
    confmat = confusionmat(logical(labels), logical(predictedLabels));
    tp_p = confmat(2, 2);
    fp_p = confmat(1, 2);
    fn_p = confmat(2, 1);
    pre_p = tp_p / (tp_p + fp_p);
    rec_p = tp_p / (tp_p + fn_p);
    f1_score_p = 2 * pre_p * rec_p / (pre_p + rec_p);
    f05_score_p = (1 + 0.5^2) * (pre_p * rec_p) / ((0.5^2 * pre_p) + rec_p);
    scoresPointwise = [pre_p; rec_p; f1_score_p; f05_score_p];
catch ME
    scoresPointwise = [NaN; NaN; NaN; NaN];
    pre_p = NaN;
end

% Eventwise (unweighted) scores
try
    [fp_e, fn_e, tp_e] = overlap_seg(labels, predictedLabels);
    pre_e = tp_e / (tp_e + fp_e);
    rec_e = tp_e / (tp_e + fn_e);
    f1_score_e = 2 * pre_e * rec_e / (pre_e + rec_e);
    f05_score_e = (1 + 0.5^2) * (pre_e * rec_e) / ((0.5^2 * pre_e) + rec_e);                
    scoresEventwise = [pre_e; rec_e; f1_score_e; f05_score_e];
catch ME
    scoresEventwise = [NaN; NaN; NaN; NaN];
    rec_e = NaN;
end

% Point-adjusted scores
anomsPointAdjusted = predictedLabels;

sequences = find_cons_sequences(find(labels == 1));

for i = 1:numel(sequences)
    if any(predictedLabels(sequences{i}, 1))
        anomsPointAdjusted(sequences{i}, 1) = 1;
    end
end

try
    confmat = confusionmat(logical(labels), logical(anomsPointAdjusted));
    tp_pa = confmat(2, 2);
    fp_pa = confmat(1, 2);
    fn_pa = confmat(2, 1);
    pre_pa = tp_pa / (tp_pa + fp_pa);
    rec_pa = tp_pa / (tp_pa + fn_pa);
    f1_score_pa = 2 * pre_pa * rec_pa / (pre_pa + rec_pa);
    f05_score_pa = (1 + 0.5^2) * (pre_pa * rec_pa) / ((0.5^2 * pre_pa) + rec_pa);
    scoresPointAdjusted = [pre_pa; rec_pa; f1_score_pa; f05_score_pa];
catch ME
    scoresPointAdjusted = [NaN; NaN; NaN; NaN];
end

% Composite F-score
try
    f1_score_c = 2 * pre_p * rec_e / (pre_p + rec_e);    
    f05_score_c = (1 + 0.5^2) * (pre_p * rec_e) / ((0.5^2 * pre_p) + rec_e);
    
    scoresComposite = [f1_score_c; f05_score_c];
catch ME
    scoresComposite = [NaN; NaN];
end

if justLabels
    AUC = NaN;
else
    if size(anomalyScores, 2) > 1
        AUC = NaN;
    else
        try
            [~, ~, ~, AUC] = perfcurve(labels, anomalyScores, 1);
        catch
            AUC = NaN;
        end
    end
end

scores = [scoresPointwise(3); ...
            scoresEventwise(3); ...
            scoresPointAdjusted(3); ...
            scoresComposite(1); ...
            scoresPointwise(4); ...
            scoresEventwise(4); ...
            scoresPointAdjusted(4); ...
            scoresComposite(2); ...
            scoresPointwise(1); ...
            scoresEventwise(1); ...
            scoresPointAdjusted(1); ...
            scoresPointwise(2); ...
            scoresEventwise(2); ...
            scoresPointAdjusted(2); ...
            AUC];

scores = round(scores, 4); % Round do 4 decimal places
end

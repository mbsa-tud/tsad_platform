function thr = computeBestFscoreThreshold(anomalyScores, labels, type)
%COMPUTEBESTFSCORETHRESHOLD Comput the best F-Score threshold
%   Computes either the point-wise, event-wise, point-adjusted
%   or composite best F-Score threshold

thresholdCandidates = uniquetol(anomalyScores, 0.0001);
numThresholdCandidates = size(thresholdCandidates, 1);

for cand_idx = 1:numThresholdCandidates
    predictedLabels(:, cand_idx) = any(anomalyScores > thresholdCandidates(cand_idx), 2);
end

Fscore = [];
switch type
    case 'point-wise'
        for cand_idx = 1:numThresholdCandidates
            confmat = confusionmat(logical(labels), logical(predictedLabels(:, cand_idx)));
            try
                pre_p = confmat(2, 2) / (confmat(2, 2) + confmat(1, 2));
                rec_p = confmat(2, 2) / (confmat(2, 2) + confmat(2, 1));
                Fscore(cand_idx) = 2 * (pre_p * rec_p) / (pre_p + rec_p);
            catch
                Fscore(cand_idx) = NaN;
            end
        end
    case 'event-wise'   
        for cand_idx = 1:numThresholdCandidates
            try
                [fp_e, fn_e, tp_e] = overlap_seg(labels, predictedLabels(:, cand_idx));
                pre_e = tp_e / (tp_e + fp_e);
                rec_e = tp_e / (tp_e + fn_e);
                Fscore(cand_idx) = 2 * pre_e * rec_e / (pre_e + rec_e);
            catch ME
                Fscore(cand_idx) = NaN;
            end
        end
    case 'point-adjusted'
        sequences = find_cons_sequences(find(labels == 1));

        for cand_idx = 1:numThresholdCandidates
            labels_pred_point_adjusted = predictedLabels(:, cand_idx);

            for j = 1:size(sequences, 1) 
                if any(predictedLabels(sequences{j, 1}, cand_idx))
                    labels_pred_point_adjusted(sequences{j, 1}, 1) = 1;
                end
            end

            confmat = confusionmat(logical(labels), logical(labels_pred_point_adjusted));
            try
                tp_a = confmat(2, 2);
                fp_a = confmat(1, 2);
                fn_a = confmat(2, 1);
                pre_a = tp_a / (tp_a + fp_a);
                rec_a = tp_a / (tp_a + fn_a);
                Fscore(cand_idx) = 2 * pre_a * rec_a / (pre_a + rec_a);
            catch ME
                Fscore(cand_idx) = NaN;
            end
        end
    case 'composite'
        sequences = find_cons_sequences(find(labels == 1));

        for cand_idx = 1:numThresholdCandidates
            tp_e = 0;
            fn_e = 0;
            
            for j = 1:size(sequences, 1) 
                if any(predictedLabels(sequences{j, 1}, cand_idx))
                    tp_e = tp_e + 1;
                else
                    fn_e = fn_e + 1;
                end
            end
            
            confmat = confusionmat(logical(labels), logical(predictedLabels(:, cand_idx)));
            try
                pre_p = confmat(2, 2) / (confmat(2, 2) + confmat(1, 2));
                rec_e = tp_e / (tp_e + fn_e);
                Fscore(cand_idx) = 2 * pre_p * rec_e / (pre_p + rec_e);
            catch ME
                Fscore(cand_idx) = NaN;
            end
        end
end

if isempty(Fscore) || ~any(Fscore)
    thr = NaN;
    return;
end

maxFScore = max(Fscore);
thr_idx = find(Fscore == maxFScore, 1);

thr = thresholdCandidates(thr_idx);
end
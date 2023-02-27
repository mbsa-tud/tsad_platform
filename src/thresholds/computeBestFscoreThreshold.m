function thr = computeBestFscoreThreshold(anomalyScores, labels, type)
%COMPUTEBESTFSCORETHRESHOLD
%
% This function computes the best F score thresholds

beta = 1;
numChannels = size(anomalyScores, 2);

thresholdCandidates = uniquetol(anomalyScores, 0.0001);
numThresholdCandidates = size(thresholdCandidates, 1);

lables_pred = logical([]);
for i = 1:numThresholdCandidates
    if numChannels > 1
        labels_pred(:, i) = any(anomalyScores > thresholdCandidates(i), 2);
    else
        labels_pred(:, i) = anomalyScores > thresholdCandidates(i);
    end
end

Fscore = [];
switch type
    case 'point-wise'
        for k = 1:numThresholdCandidates
            confmat = confusionmat(logical(labels), logical(labels_pred(:, k)));
            try
                pre_p = confmat(2, 2) / (confmat(2, 2) + confmat(1, 2));
                rec_p = confmat(2, 2) / (confmat(2, 2) + confmat(2, 1));
                Fscore(k) = (1 + beta^2) * (pre_p * rec_p) / (pre_p * beta^2 + rec_p);
            catch
                Fscore(k) = NaN;
            end
        end
    case 'event-wise'   
        for k = 1:numThresholdCandidates
            try
                [fp_e, fn_e, tp_e] = overlap_seg(labels, labels_pred(:, k));
                pre_e = tp_e / (tp_e + fp_e);
                rec_e = tp_e / (tp_e + fn_e);
                Fscore(k) = 2 * pre_e * rec_e / (pre_e + rec_e);
            catch ME
                Fscore(k) = NaN;
            end
        end
    case 'point-adjusted'
        sequences = find_cons_sequences(find(labels == 1));

        for k = 1:numThresholdCandidates
            labels_pred_point_adjusted = labels_pred(:, k);

            for j = 1:size(sequences, 1) 
                if any(labels_pred(sequences{j, 1}, k))
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
                Fscore(k) = 2 * pre_a * rec_a / (pre_a + rec_a);
            catch ME
                Fscore(k) = NaN;
            end
        end
    case 'composite'
        sequences = find_cons_sequences(find(labels == 1));

        for k = 1:numThresholdCandidates
            tp_e = 0;
            fn_e = 0;
            
            for j = 1:size(sequences, 1) 
                if any(labels_pred(sequences{j, 1}, k))
                    tp_e = tp_e + 1;
                else
                    fn_e = fn_e + 1;
                end
            end
            
            confmat = confusionmat(logical(labels), logical(labels_pred(:, k)));
            try
                pre_p = confmat(2, 2) / (confmat(2, 2) + confmat(1, 2));
                rec_e = tp_e / (tp_e + fn_e);
                Fscore(k) = 2 * pre_p * rec_e / (pre_p + rec_e);
            catch ME
                Fscore(k) = NaN;
            end
        end
end

if isempty(Fscore) || ~any(Fscore)
    thr = NaN;
    return;
end

maxFScore = max(Fscore);
thrIdx = find(Fscore == maxFScore, 1);

thr = thresholdCandidates(thrIdx);
end
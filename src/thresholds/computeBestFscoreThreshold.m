function thr = computeBestFscoreThreshold(anomalyScores, labels, useParametric, pd, type)
beta = 1;
numChannels = size(anomalyScores, 2);

if useParametric == 1
    anomalyScores_old = anomalyScores;
    anomalyScores = pdf(pd, anomalyScores);
end 

lables_pred = logical([]);

numOfTimesteps = size(anomalyScores, 1);

if numChannels == 1
    threshMax = sort(anomalyScores);
else
    minimum = min(min(anomalyScores));
    maximum = max(max(anomalyScores));
    threshMax = zeros(numOfTimesteps, 1);
    for i = 1:numOfTimesteps
        threshMax(i) = minimum + ((i / numOfTimesteps) * (maximum - minimum));
    end
end

if useParametric == 0
    for i = 1:numOfTimesteps
        labels_tmp = logical([]);
        for j = 1:numChannels
            labels_tmp(:, j) = anomalyScores(:, j) > threshMax(i);
        end
        labels_pred(:, i) = any(labels_tmp, 2);
    end
else
    for i = 1:numOfTimesteps
        labels_tmp = logical([]);
        for j = 1:numChannels
            labels_tmp(:, j) = anomalyScores(:, j) < threshMax(i);
        end
        labels_pred(:, i) = any(labels_tmp, 2);
    end
end

Fscore = [];
switch type
    case 'point-wise'
        for k = 1:numOfTimesteps
            confmat = confusionmat(logical(labels), logical(labels_pred(:, k)));
            try
                precision = confmat(2, 2) / (confmat(2, 2) + confmat(1, 2));
                recall = confmat(2, 2) / (confmat(2, 2) + confmat(2, 1));
                Fscore(k) = (1 + beta^2) * (precision * recall) / (precision * beta^2 + recall);
            catch
                Fscore(k) = NaN;
            end
        end
    case 'event-wise'   
        for k = 1:numOfTimesteps
            try
                [fp_u, fn_u, tp_u] = overlap_seg(labels, labels_pred(:, k));
                pre_u = tp_u / (tp_u + fp_u);
                rec_u = tp_u / (tp_u + fn_u);
                Fscore(k) = 2 * pre_u * rec_u / (pre_u + rec_u);
            catch ME
                Fscore(k) = NaN;
            end
        end
    case 'point-adjusted'
        for k = 1:numOfTimesteps
            labels_pred_point_adjusted = labels_pred;
            i = 1;
            while i <= numel(labels)
                if labels(i, 1) == 1
                    flag_e = 0;
                    startPoint = i;
                    endPoint = i;
                    for j = 0:(numel(labels) - i)
                        if labels(i + j, 1) == 0
                            break
                        end
                        endPoint = i + j;
                    end
                    for j = 0:(endPoint - i)
                        if labels_pred(i + j, k) == 1
                            flag_e = 1;
                            break
                        end
                    end
                    if flag_e == 1
                        labels_pred_point_adjusted(startPoint:endPoint, k) = 1;
                    end
                    i = endPoint + 1;
                    continue
                end
                i = i + 1;
            end
            
            confmat = confusionmat(logical(labels), logical(labels_pred_point_adjusted(:, k)));
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
        for k = 1:numOfTimesteps
            tp_c = 0;
            fn_c = 0;

            i = 1;
            while i <= numel(labels)
                if labels(i, 1) == 1
                    flag_e = 0;
                    endPoint = i;
                    for j = 0:(numel(labels) - i)
                        if labels(i + j, 1) == 0
                            break
                        end
                        endPoint = i + j;
                    end
                    for j = 0:(endPoint - i)
                        if labels_pred(i + j, k) == 1
                            flag_e = 1;
                            break
                        end
                    end
                    if flag_e == 1
                        tp_c = tp_c + 1;
                    else
                        fn_c = fn_c + 1;
                    end
                    i = endPoint + 1;
                    continue
                end
                i = i + 1;
            end

            confmat = confusionmat(logical(labels), logical(labels_pred(:, k)));
            try
                pre_c = confmat(2, 2) / (confmat(2, 2) + confmat(1, 2));
                rec_c = tp_c / (tp_c + fn_c);
                Fscore(k) = 2 * pre_c * rec_c / (pre_c + rec_c);
            catch ME
                Fscore(k) = NaN;
            end
        end
end

if isempty(Fscore) || ~any(Fscore)
    thr = NaN;
    return;
end

MaxFScore = max(Fscore);
thrIdx = find(Fscore == MaxFScore);
clear thrMax
if size(thrIdx, 2) >1
    p = thrIdx(1);
else
    p = thrIdx;
end

thr = threshMax(p);

if useParametric == 1
    try
        thr = anomalyScores_old(find(anomalyScores == thr, 1));
    catch
        thr = 0.1;
    end
end
end
function labels_pred = calcStaticThresholdPrediction(anomalyScores, staticThreshold, pd, parametric)
% TODO: the parameters pd and parametric are currently unused. This is
% because the modified version of the parametric static threshold doesn't
% require them. If the threshold gets adapted somehow, they will be needed
% in this function again.

labels_pred_tmp = logical([]);
numChannels = size(anomalyScores, 2);


for j = 1:numChannels
    if parametric
        anomalyScores = pdf(pd, anomalyScores);
        labels_pred_tmp(:, j) = anomalyScores(:, j) < staticThreshold;
    else
        labels_pred_tmp(:, j) = anomalyScores(:, j) > staticThreshold;
    end
end
labels_pred = any(labels_pred_tmp, 2);

% f = figure;
% f.Position = [100 100 1000 200];
% labels_pred = zeros(3335, 1);
% labels_pred(1138:1244) = 1;
% labels_pred(1678:1798) = 1;
% labels_pred(2100) = 1;
% labels_pred(3000) = 1;
% labels_pred(3100) = 1;
% 
% plot(labels_pred);
% %xlabel('Timestamp', FontSize=14);
% ylim([-0.1 1.1]);
% xlim([0 3300]);
% xlabel('Timestamp', FontSize=14);
% set(gca, ytick=[0 1]);

% anoms = combineAnomsAndStatic(anomalyScores, anoms);
end

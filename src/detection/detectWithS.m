function anomalyScores = detectWithS(options, Mdl, XTest, YTest, labels)
%DETECTWITHS
%
% Runs the detection for statistical models and returns anomaly Scores

% Fraction of outliers
if ~isempty(labels)
    numOfAnoms = sum(labels == 1);
    contaminationFraction = numOfAnoms / size(labels, 1);
else
    contaminationFraction = 0;
end

% Detect with model
switch options.model
    case 'Grubbs test'
        anomalyScores = grubbs_test(XTest{1, 1}, options.hyperparameters.model.alpha.value);
    case 'OD_wpca'
        [~, anomalyScores, ~] = OD_wpca(XTest{1, 1}, options.hyperparameters.model.ratioOversample.value);
end

% Merge overlapping scores
anomalyScores = repmat(anomalyScores, 1, options.hyperparameters.data.windowSize.value);
anomalyScores = reshapeReconstructivePrediction(anomalyScores, false, options.hyperparameters.data.windowSize.value, 1);
end

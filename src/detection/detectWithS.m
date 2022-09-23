function [anomalyScores, YTest, labels] = detectWithS(options, Mdl, XTest, YTest, labels)
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
        anomalyScores = grubbs_test(XTest, options.hyperparameters.model.alpha.value);
    case 'OD_wpca'
        [~, anomalyScores, ~] = OD_wpca(XTest, options.hyperparameters.model.ratioOversample.value);
end

anomalyScores = repmat(anomalyScores, 1, options.hyperparameters.data.windowSize.value);
anomalyScores = reshapeReconstructivePrediction(anomalyScores, options.hyperparameters.data.windowSize.value);
labels = labels(1:(end - options.hyperparameters.data.windowSize.value), 1);
YTest = YTest(1:(end - options.hyperparameters.data.windowSize.value), 1);
end

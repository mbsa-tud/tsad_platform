function [anomalyScores, XTest, labels] = detectWithS(options, Mdl, XTest, labels)
% Fraction of outliers
numOfAnoms = sum(labels == 1);
contaminationFraction = numOfAnoms / size(labels, 1);

% Detect with model
switch options.model
    case 'Grubbs test'
        anomalyScores = grubbs_test(XTest, options.hyperparameters.model.alpha.value);
    case 'OD_wpca'
        [~, anomalyScores, ~] = OD_wpca(XTest, options.hyperparameters.model.ratioOversample.value);
end
end

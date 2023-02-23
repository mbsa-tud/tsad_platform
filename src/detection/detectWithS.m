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
        anomalyScores = grubbs_test(XTest, options.hyperparameters.model.alpha.value);
    case 'OD_wpca'
        [~, anomalyScores, ~] = OD_wpca(XTest, options.hyperparameters.model.ratioOversample.value);
end

if isfield(options, 'outputsLabels')
    if options.outputsLabels
        return;
    end
end
if isfield(options, 'useSubsequences')
    if ~options.useSubsequences
        return;
    end
end

% Merge overlapping scores
anomalyScores = repmat(anomalyScores, 1, options.hyperparameters.data.windowSize.value);
anomalyScores = mergeOverlappingAnomalyScores(anomalyScores, options.hyperparameters.data.windowSize.value);
end

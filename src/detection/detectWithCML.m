function anomalyScores = detectWithCML(options, Mdl, XTest, YTest, labels)
%DETECTWITHCML
%
% Runs the detection for classic ML models and returns anomaly Scores

switch options.model
    case 'iForest'
        [~, anomalyScores] = isanomaly(Mdl, XTest);
        case 'OC-SVM'
        [~, anomalyScores] = predict(Mdl, XTest);
        anomalyScores = gnegate(anomalyScores);
    case 'ABOD'
        [~, anomalyScores] = ABOD(XTest);
    case 'LOF'
        [~, anomalyScores] = LOF(XTest, options.hyperparameters.model.k.value);
    case 'LDOF'
        anomalyScores = LDOF(XTest, options.hyperparameters.model.k.value);
    case 'Merlin'
        numAnoms = 0;
        i = 1;
        while i <= length(labels)
            if labels(i) == 1
                k = 0;
                while labels(k + i) == 1
                    k = k + 1;
                    if (k + i) > length(labels)
                        break;
                    end
                end
                i = i + k;
                numAnoms = numAnoms + 1;
            end
            i = i + 1;
        end
        if numAnoms == 0
            numAnoms = 1;
        end

        if options.hyperparameters.model.minL.value < options.hyperparameters.model.maxL.value
            anomalyScores = run_MERLIN(XTest,  options.hyperparameters.model.minL.value, ...
                options.hyperparameters.model.maxL.value, numAnoms);
        else
            fprintf("Warning! minL is greater than maxL for merlin, setting anomaly scores to zero.");
            anomalyScores = zeros(size(XTest, 1), 1);
            return;
        end
        anomalyScores = double(anomalyScores);
        return;
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
anomalyScores = reshapeOverlappingSubsequences(anomalyScores, false, options.hyperparameters.data.windowSize.value, 1);
end

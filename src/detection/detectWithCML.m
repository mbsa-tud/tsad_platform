function [anomalyScores, XTest, labels] = detectWithCML(options, Mdl, XTest, labels)
% Fraction of outliers
numOfAnoms = sum(labels == 1);
contaminationFraction = numOfAnoms / size(labels, 1);

switch options.model
    case 'OC-SVM'
        [~, anomalyScores] = predict(Mdl, XTest);
        anomalyScores = gnegate(anomalyScores);
        minScore = min(anomalyScores);
        anomalyScores = (anomalyScores - minScore) / (max(anomalyScores) - minScore);
    case 'iForest'
        rng('default');
        [~, ~, anomalyScores] = iforest(XTest, ContaminationFraction=contaminationFraction, ...
            NumLearner=options.hyperparameters.model.numLearners.value, ...
            NumObservationsPerLearner=options.hyperparameters.model.numObservationsPerLearner.value);
    case 'ABOD'
        [~, anomalyScores] = ABOD(XTest);
    case 'LOF'
        [~, anomalyScores] = LOF(XTest, 100);
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
            anomalyScores = zeros(size(XTest, 1), 1);
        end
    case 'LDOF'
        anomalyScores = LDOF(XTest, options.hyperparameters.model.knn.value);
end
end

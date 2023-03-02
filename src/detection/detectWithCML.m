function [anomalyScores, compTime] = detectWithCML(options, Mdl, XTest, YTest, labels, getCompTime)
%DETECTWITHCML
%
% Runs the detection for classic ML models and returns anomaly Scores
compTime = NaN;

switch options.model
    case 'iForest'
        % iForest supports outlier and novelty detection.
        if isempty(Mdl)
            [~, ~, anomalyScores] = iforest(XTest, NumLearners=options.hyperparameters.numLearners.value, NumObservationsPerLearner=options.hyperparameters.numObservationsPerLearner.value);
        else
            [~, anomalyScores] = isanomaly(Mdl, XTest);
        end

        if options.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(options, anomalyScores);
        end
    case 'OC-SVM'
        % OC-SVM support outlier and novelty detection.
        if isempty(Mdl)
            if ~isempty(labels)
                numOfAnoms = sum(labels == 1);
                contaminationFraction = numOfAnoms / size(labels, 1);
            else
                contaminationFraction = 0;
            end
            Mdl = fitcsvm(XTest, ones(size(XTest, 1), 1), OutlierFraction=contaminationFraction, KernelFunction=string(options.hyperparameters.kernelFunction.value), KernelScale="auto");
        end
        [~, anomalyScores] = predict(Mdl, XTest);

        if options.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(options, anomalyScores);
        end
        anomalyScores = anomalyScores < 0;
    case 'ABOD'
        [~, anomalyScores] = ABOD(XTest);

        if options.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(options, anomalyScores);
        end
    case 'LOF'
        [~, anomalyScores] = LOF(XTest, options.hyperparameters.k.value);

        if options.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(options, anomalyScores);
        end
    case 'LDOF'
        anomalyScores = LDOF(XTest, options.hyperparameters.k.value);

        if options.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(options, anomalyScores);
        end
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

        if options.hyperparameters.minL.value < options.hyperparameters.maxL.value
            [~, indices, ~] = run_MERLIN(XTest,  options.hyperparameters.minL.value, ...
                options.hyperparameters.maxL.value, numAnoms);
            indices = sort(indices, 2);
            
            anomalyScores = zeros(size(XTest, 1), 1);

            for i = 1:numAnoms
                avg_disc_loc = floor(median(indices(:, i)));
                anomalyScores(avg_disc_loc:(avg_disc_loc + floor((options.hyperparameters.minL.value + options.hyperparameters.maxL.value) / 2))) = 1;
            end
        else
            fprintf("Warning! minL is greater than maxL for Merlin, setting anomaly scores to zero.");
            anomalyScores = zeros(size(XTest, 1), 1);
        end
        anomalyScores = double(anomalyScores);
end
end

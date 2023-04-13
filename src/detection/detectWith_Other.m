function [anomalyScores, compTime] = detectWith_Other(modelOptions, Mdl, XTest, YTest, labels, getCompTime)
%DETECTWITHCML Runs the detection for classic ML models

% Comptime measure the computation time for a single subsequence. Might be
% unavailable for some models
compTime = NaN;

switch modelOptions.name
    case 'Your model name'
    case 'iForest'
        % iForest supports outlier and novelty detection.
        if isempty(Mdl)
            if ~isempty(labels)
                numOfAnoms = sum(labels == 1);
                contaminationFraction = numOfAnoms / size(labels, 1);
            else
                contaminationFraction = 0;
            end

            [~, ~, anomalyScores] = iforest(XTest, contaminationFraction=contaminationFraction, NumLearners=modelOptions.hyperparameters.numLearners, NumObservationsPerLearner=modelOptions.hyperparameters.numObservationsPerLearner);
        else
            [~, anomalyScores] = isanomaly(Mdl, XTest);
        end

        if modelOptions.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
        end
    case 'OC-SVM'
        [~, anomalyScores] = predict(Mdl, XTest);

        if modelOptions.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
        end
        anomalyScores = anomalyScores < 0;
    case 'ABOD'
        [~, anomalyScores] = ABOD(XTest);

        if modelOptions.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
        end
    case 'LOF'
        [~, anomalyScores] = LOF(XTest, modelOptions.hyperparameters.k);

        if modelOptions.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
        end
    case 'LDOF'
        anomalyScores = LDOF(XTest, modelOptions.hyperparameters.k);

        if modelOptions.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
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

        if modelOptions.hyperparameters.minL < modelOptions.hyperparameters.maxL
            [~, indices, ~] = run_MERLIN(XTest,  modelOptions.hyperparameters.minL, ...
                modelOptions.hyperparameters.maxL, numAnoms);
            indices = sort(indices, 2);
            
            if strcmp(modelOptions.hyperparameters.mode, "median")
                anomalyScores = zeros(size(XTest, 1), 1);
                
                % Get average locations of top k discords
                for i = 1:numAnoms
                    avg_disc_loc = floor(median(indices(:, i)));
                    anomalyScores(avg_disc_loc:(avg_disc_loc + floor((modelOptions.hyperparameters.minL + modelOptions.hyperparameters.maxL) / 2))) = 1;
                end
            elseif strcmp(modelOptions.hyperparameters.mode, "merged")
                % Alternativeley label all found anomalies of all lengths and merge afterwards
	            anomalyScores = zeros(size(XTest, 1), size(indices, 1));
                for i = 1:size(indices, 1)
                    for j = 1:numAnoms
                        anomalyScores(indices(i, j):(indices(i, j) + modelOptions.hyperparameters.minL - 2 + i)) = 1;
                    end
                end
                anomalyScores = any(anomalyScores, 2);
            end
        else
            fprintf("Warning! minL (%d) must be less than maxL (%d) for Merlin, setting anomaly scores to zero.", ...
                modelOptions.hyperparameters.minL, modelOptions.hyperparameters.maxL);
            anomalyScores = zeros(size(XTest, 1), 1);
        end
        anomalyScores = double(anomalyScores);
    case 'Grubbs test'
        anomalyScores = grubbs_test(XTest, modelOptions.hyperparameters.alpha);
    case 'over-sampling PCA'
        [~, anomalyScores, ~] = OD_wpca(XTest, modelOptions.hyperparameters.ratioOversample);

        if modelOptions.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
        end
end
end

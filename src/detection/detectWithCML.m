function [anomalyScores, compTime] = detectWithCML(modelOptions, Mdl, XTest, YTest, labels, getCompTime)
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

            [~, ~, anomalyScores] = iforest(XTest, contaminationFraction=contaminationFraction, NumLearners=modelOptions.hyperparameters.numLearners.value, NumObservationsPerLearner=modelOptions.hyperparameters.numObservationsPerLearner.value);
        else
            [~, anomalyScores] = isanomaly(Mdl, XTest);
        end

        if modelOptions.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
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

            Mdl = fitcsvm(XTest, ones(size(XTest, 1), 1), OutlierFraction=contaminationFraction, KernelFunction=string(modelOptions.hyperparameters.kernelFunction.value), KernelScale="auto");
        end
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
        [~, anomalyScores] = LOF(XTest, modelOptions.hyperparameters.k.value);

        if modelOptions.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
        end
    case 'LDOF'
        anomalyScores = LDOF(XTest, modelOptions.hyperparameters.k.value);

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

        if modelOptions.hyperparameters.minL.value < modelOptions.hyperparameters.maxL.value
            [~, indices, ~] = run_MERLIN(XTest,  modelOptions.hyperparameters.minL.value, ...
                modelOptions.hyperparameters.maxL.value, numAnoms);
            indices = sort(indices, 2);
            
            if strcmp(modelOptions.hyperparameters.mode.value, "median")
                anomalyScores = zeros(size(XTest, 1), 1);
                
                % Get average locations of top k discords
                for i = 1:numAnoms
                    avg_disc_loc = floor(median(indices(:, i)));
                    anomalyScores(avg_disc_loc:(avg_disc_loc + floor((modelOptions.hyperparameters.minL.value + modelOptions.hyperparameters.maxL.value) / 2))) = 1;
                end
            elseif strcmp(modelOptions.hyperparameters.mode.value, "merged")
                % Alternativeley label all found anomalies of all lengths and merge afterwards
	            anomalyScores = zeros(size(XTest, 1), size(indices, 1));
                for i = 1:size(indices, 1)
                    for j = 1:numAnoms
                        anomalyScores(indices(i, j):(indices(i, j) + modelOptions.hyperparameters.minL.value - 2 + i)) = 1;
                    end
                end
                anomalyScores = any(anomalyScores, 2);
            end
        else
            fprintf("Warning! minL is greater than maxL for Merlin, setting anomaly scores to zero.");
            anomalyScores = zeros(size(XTest, 1), 1);
        end
        anomalyScores = double(anomalyScores);
end
end

function [anomalyScores, compTime] = detect(modelOptions, Mdl, XTest, TSTest, labelsTest, getCompTime)
%DETECT Entry-point for adding detection function for models. This function 
% runs the detection for the selected model

% Fixed random seed
rng("default");

% Comptime measure the computation time for a single subsequence. Can be
% set for some model later in this file
compTime = NaN;

contaminationFraction = sum(labelsTest) / numel(labelsTest); % True fraction of outliers

switch modelOptions.name
    case "Your model name"
    case "iForest"
        % iForest supports outlier and novelty detection.
        if isempty(Mdl)
            [~, ~, anomalyScores] = iforest(XTest, NumLearners=modelOptions.hyperparameters.iTrees, ...
                                            NumObservationsPerLearner=modelOptions.hyperparameters.observationsPeriTree);
        else
            [~, anomalyScores] = isanomaly(Mdl, XTest);
        end

        if modelOptions.useSlidingWindow
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
        end
    case "OC-SVM"
        if isempty(Mdl)
            [~, ~, anomalyScores] = ocsvm(XTest, KernelScale="auto");
        else
            [~, anomalyScores] = isanomaly(Mdl, XTest);
        end

        if modelOptions.useSlidingWindow
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
        end
    case "ABOD"
        [~, anomalyScores] = ABOD(XTest);

        if modelOptions.useSlidingWindow
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
        end
    case "LOF"
        [~, anomalyScores] = LOF(XTest, modelOptions.hyperparameters.k);

        if modelOptions.useSlidingWindow
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
        end
    case "LDOF"
        anomalyScores = LDOF(XTest, modelOptions.hyperparameters.k);

        if modelOptions.useSlidingWindow
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
        end
    case "MERLIN"
        numAnoms = 0;
        i = 1;
        while i <= length(labelsTest)
            if labelsTest(i) == 1
                k = 0;
                while labelsTest(k + i) == 1
                    k = k + 1;
                    if (k + i) > length(labelsTest)
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
                anomalyScores = zeros(length(XTest), 1);
                
                % Get average locations of top k discords
                for i = 1:numAnoms
                    avg_disc_loc = floor(median(indices(:, i)));
                    anomalyScores(avg_disc_loc:(avg_disc_loc + floor((modelOptions.hyperparameters.minL + modelOptions.hyperparameters.maxL) / 2))) = 1;
                end
            elseif strcmp(modelOptions.hyperparameters.mode, "merged")
                % Alternativeley label all found anomalies of all lengths and merge afterwards
	            anomalyScores = zeros(length(XTest), size(indices, 1));
                for i = 1:size(indices, 1)
                    for j = 1:numAnoms
                        anomalyScores(indices(i, j):(indices(i, j) + modelOptions.hyperparameters.minL - 2 + i)) = 1;
                    end
                end
                anomalyScores = any(anomalyScores, 2);
            end
        else
            fprintf("Warning! minL (%d) must be less than maxL (%d) for MERLIN, setting anomaly scores to zero.", ...
                modelOptions.hyperparameters.minL, modelOptions.hyperparameters.maxL);
            anomalyScores = zeros(length(XTest), 1);
        end
        anomalyScores = double(anomalyScores);
    case "over-sampling PCA"
        [~, anomalyScores, ~] = OD_wpca(XTest, modelOptions.hyperparameters.oversamplingRatio);

        if modelOptions.useSlidingWindow
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
        end
    case "Grubbs test"
        anomalyScores = grubbs_test(XTest, modelOptions.hyperparameters.alpha);
    otherwise
        if strcmp(modelOptions.type, "deep-learning")
            % Default detection for semi-supervised deep-learning models
            [anomalyScores, compTime] = defaultDNNDetection(modelOptions, Mdl, XTest, TSTest, labelsTest, getCompTime);
        end
end
end

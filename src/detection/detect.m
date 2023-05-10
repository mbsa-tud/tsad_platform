function [anomalyScores, compTime] = detect(modelOptions, Mdl, XTest, TSTest, labels, getCompTime)
%DETECTWITHCML Runs the detection for classic ML models

% Comptime measure the computation time for a single subsequence. Might be
% unavailable for some models
compTime = NaN;

contaminationFraction = sum(labels) / numel(labels);

switch modelOptions.name
    case "Your model name"
    case "iForest"
        % iForest supports outlier and novelty detection.
        if isempty(Mdl)
            [~, ~, anomalyScores] = iforest(XTest, NumLearners=modelOptions.hyperparameters.numLearners, ...
                                            NumObservationsPerLearner=modelOptions.hyperparameters.numObservationsPerLearner);
        else
            [~, anomalyScores] = isanomaly(Mdl, XTest);
        end

        if modelOptions.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
        end
    case "OC-SVM"
        if isempty(Mdl)
            [~, ~, anomalyScores] = ocsvm(XTest, KernelScale="auto");
        else
            [~, anomalyScores] = isanomaly(Mdl, XTest);
        end

        if modelOptions.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
        end
    case "ABOD"
        [~, anomalyScores] = ABOD(XTest);

        if modelOptions.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
        end
    case "LOF"
        [~, anomalyScores] = LOF(XTest, modelOptions.hyperparameters.k);

        if modelOptions.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
        end
    case "LDOF"
        anomalyScores = LDOF(XTest, modelOptions.hyperparameters.k);

        if modelOptions.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
        end
    case "Merlin"
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
            fprintf("Warning! minL (%d) must be less than maxL (%d) for Merlin, setting anomaly scores to zero.", ...
                modelOptions.hyperparameters.minL, modelOptions.hyperparameters.maxL);
            anomalyScores = zeros(length(XTest), 1);
        end
        anomalyScores = double(anomalyScores);
    case "Grubbs test"
        anomalyScores = grubbs_test(XTest, modelOptions.hyperparameters.alpha);
    case "over-sampling PCA"
        [~, anomalyScores, ~] = OD_wpca(XTest, modelOptions.hyperparameters.ratioOversample);

        if modelOptions.useSubsequences
            % Merge overlapping scores
            anomalyScores = mergeOverlappingAnomalyScores(modelOptions, anomalyScores, @mean);
        end
    otherwise
        if strcmp(modelOptions.type, "deep-learning")
            prediction = predict(Mdl, XTest);

            if getCompTime
                iterations = min(500, size(XTest, 1));
                times = zeros(iterations, 1);
                for i = 1:iterations
                    tStart = cputime;
                    predict(Mdl, XTest(i, :));
                    times(i, 1) = cputime - tStart;
                end
                compTime = mean(times(~(times == 0)));
            end
    
              
            if strcmp(modelOptions.modelType, "reconstructive")
                if ~isfield(modelOptions, "hyperparameters") || ~isfield(modelOptions.hyperparameters, "reconstructionErrorType")
                    error("You must specify the reconstructionErrorType field in the hyperparameters of reconstructive models");
                end
    
                switch modelOptions.hyperparameters.reconstructionErrorType
                    case "median point-wise values"
                        % calculate median predicted value for each time step and then calculate the errors for the entire time series
                        prediction = mergeOverlappingSubsequences(modelOptions, prediction, @median);
                        anomalyScores = abs(prediction - TSTest);
                    case "median point-wise errors"
                        % calulate the point-wise errors for each subsequence and then calculate the median error for each time step
                        if modelOptions.dataType == 1
                            anomalyScores = abs(prediction - XTest);
                        elseif modelOptions.dataType == 2
                            anomalyScores = cell(numel(prediction), 1);
                            for i = 1:numel(prediction)
                                anomalyScores{i} = abs(prediction{i} - XTest{i});
                            end
                        end
                                
                        anomalyScores = mergeOverlappingSubsequences(modelOptions, anomalyScores, @median);
                    case "mean subsequence errors"
                        % calulate the MSE for each subsequence and channel and
                        % then calculate the mean error for each time step
                        % and channel
                        windowSize = modelOptions.hyperparameters.windowSize;
                        if modelOptions.dataType == 1
                            anomalyScores = abs(prediction - XTest);
                            numChannels = round(size(anomalyScores, 2) / windowSize);                        
                            for channel_idx = 1:numChannels
                                for i = 1:size(prediction, 1)
                                    anomalyScores(i, ((channel_idx - 1) * windowSize + 1):((channel_idx - 1) * windowSize + windowSize)) = ...
                                        mean(anomalyScores(i, ((channel_idx - 1) * windowSize + 1):((channel_idx - 1) * windowSize + windowSize)));
                                end
                            end
                        elseif modelOptions.dataType == 2
                            numChannels = size(prediction{1}, 1);
                            anomalyScores = prediction;
                            for i = 1:numel(prediction)
                                anomalyScores{i} = abs(prediction{i} - XTest{i});
    
                                for channel_idx = 1:numChannels                            
                                    anomalyScores{i}(channel_idx, :) = mean(anomalyScores{i}(channel_idx, :));
                                end
                            end            
                        end
    
                        anomalyScores = mergeOverlappingSubsequences(modelOptions, anomalyScores, @mean);
                    otherwise
                        error("Unknown reconstructionErrorType");
                end
            elseif strcmp(modelOptions.modelType, "predictive")
                if iscell(prediction)
                    pred_tmp = zeros(numel(prediction), size(prediction{1}, 1));
                    for i = 1:numel(prediction)
                            pred_tmp(i, :) = prediction{i}';
                    end
                    prediction = pred_tmp;
                end
    
                anomalyScores = abs(prediction - TSTest);
            end
        end
end
end

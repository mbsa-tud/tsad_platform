function [anomalyScores, compTime] = defaultDNNDetection(modelOptions, Mdl, XTest, TSTest, labelsTest, getCompTime)
%DEFAULTDNNDETECTION Runs the detection for TSAD platform default
%semi-supervised deep-learning models

% Fixed random seed
rng("default");

% Comptime measure the computation time for a single subsequence.
compTime = NaN;

if strcmp(modelOptions.type, "deep-learning")
    % Default detection for semi-supervised deep-learning models
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
            case "Median point-wise Values"
                % calculate median predicted value for each time step and then calculate the errors for the entire time series
                prediction = mergeOverlappingSubsequences(modelOptions, prediction, @median);
                anomalyScores = abs(prediction - TSTest);
            case "Median point-wise Errors"
                % calulate the point-wise errors for each subsequence and then calculate the median error for each time step
                if modelOptions.dataType == 1
                    errors = abs(prediction - XTest);
                elseif modelOptions.dataType == 2
                    errors = cell(numel(prediction), 1);
                    for i = 1:numel(prediction)
                        errors{i} = abs(prediction{i} - XTest{i});
                    end
                end
                        
                anomalyScores = mergeOverlappingSubsequences(modelOptions, errors, @median);
            case "Mean Subsequence MAE"
                % calulate the MAE for each subsequence and channel and
                % then calculate the mean error for each time step
                windowSize = modelOptions.hyperparameters.windowSize;
                if modelOptions.dataType == 1
                    errors = abs(prediction - XTest);
                    numChannels = round(size(errors, 2) / windowSize);                        
                    for channel_idx = 1:numChannels
                        % Assign MAE to each poit of every subsequence
                        for i = 1:size(prediction, 1)
                            errors(i, ((channel_idx - 1) * windowSize + 1):((channel_idx - 1) * windowSize + windowSize)) = ...
                                mean((errors(i, ((channel_idx - 1) * windowSize + 1):((channel_idx - 1) * windowSize + windowSize))));
                        end
                    end
                elseif modelOptions.dataType == 2
                    errors = cell(size(prediction, 1), 1);
                    numChannels = size(prediction{1}, 1);
                    for i = 1:numel(prediction)
                        errors{i} = abs(prediction{i} - XTest{i});

                        for channel_idx = 1:numChannels
                            % Assign MAE to each poit of every subsequence
                            errors{i}(channel_idx, :) = mean(errors{i}(channel_idx, :));
                        end
                    end            
                end

                anomalyScores = mergeOverlappingSubsequences(modelOptions, errors, @mean);
            case "Mean Subsequence MSE"
                % calulate the MSE for each subsequence and channel and
                % then calculate the mean error for each time step
                windowSize = modelOptions.hyperparameters.windowSize;
                if modelOptions.dataType == 1
                    errors = abs(prediction - XTest);
                    numChannels = round(size(errors, 2) / windowSize);                        
                    for channel_idx = 1:numChannels
                        % Assign MSE to each poit of every subsequence
                        for i = 1:size(prediction, 1)
                            errors(i, ((channel_idx - 1) * windowSize + 1):((channel_idx - 1) * windowSize + windowSize)) = ...
                                mean((errors(i, ((channel_idx - 1) * windowSize + 1):((channel_idx - 1) * windowSize + windowSize))).^2);
                        end
                    end
                elseif modelOptions.dataType == 2
                    errors = cell(size(prediction, 1), 1);
                    numChannels = size(prediction{1}, 1);
                    for i = 1:numel(prediction)
                        errors{i} = abs(prediction{i} - XTest{i});

                        for channel_idx = 1:numChannels
                            % Assign MSE to each poit of every subsequence
                            errors{i}(channel_idx, :) = mean(errors{i}(channel_idx, :).^2);
                        end
                    end            
                end

                anomalyScores = mergeOverlappingSubsequences(modelOptions, errors, @mean);
            case "Mean Subsequence RMSE"
                % calulate the RMSE for each subsequence and channel and
                % then calculate the mean error for each time step
                windowSize = modelOptions.hyperparameters.windowSize;
                if modelOptions.dataType == 1
                    errors = abs(prediction - XTest);
                    numChannels = round(size(errors, 2) / windowSize);                        
                    for channel_idx = 1:numChannels
                        % Assign RMSE to each poit of every subsequence
                        for i = 1:size(prediction, 1)
                            errors(i, ((channel_idx - 1) * windowSize + 1):((channel_idx - 1) * windowSize + windowSize)) = ...
                                sqrt(mean((errors(i, ((channel_idx - 1) * windowSize + 1):((channel_idx - 1) * windowSize + windowSize))).^2));
                        end
                    end
                elseif modelOptions.dataType == 2
                    errors = cell(size(prediction, 1), 1);
                    numChannels = size(prediction{1}, 1);
                    for i = 1:numel(prediction)
                        errors{i} = abs(prediction{i} - XTest{i});

                        for channel_idx = 1:numChannels
                            % Assign RMSE to each poit of every subsequence
                            errors{i}(channel_idx, :) = sqrt(mean(errors{i}(channel_idx, :).^2));
                        end
                    end            
                end

                anomalyScores = mergeOverlappingSubsequences(modelOptions, errors, @mean);
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

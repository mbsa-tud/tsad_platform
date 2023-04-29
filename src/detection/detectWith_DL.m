function [anomalyScores, compTime] = detectWith_DL(modelOptions, Mdl, XTest, YTest, labels, getCompTime)
%DETECTWITHDNN Runs the detection for DL models and returns anomaly Scores

compTime = NaN;

switch modelOptions.name
    case "Your model name"
    otherwise
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
                    anomalyScores = abs(prediction - YTest);
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

            anomalyScores = abs(prediction - YTest);
        end
end
end

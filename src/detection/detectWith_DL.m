function [anomalyScores, compTime] = detectWith_DL(modelOptions, Mdl, XTest, YTest, labels, getCompTime)
%DETECTWITHDNN Runs the detection for DL models and returns anomaly Scores

compTime = NaN;

switch modelOptions.name
    case 'Your model name'
    otherwise
        prediction = predict(Mdl, XTest);

        if getCompTime
            iterations = min(1000, size(XTest, 1));
            times = zeros(iterations, 1);
            for i = 1:iterations
                tStart = cputime;
                predict(Mdl, XTest(i, :));
                times(i, 1) = cputime - tStart;
            end
            compTime = mean(times(~(times == 0)));
        end

          
        if strcmp(modelOptions.modelType, 'reconstructive')
            if ~isfield(modelOptions, "hyperparameters") || ~isfield(modelOptions.hyperparameters, "reconstructionErrorType")
                error("You must specify the reconstructionErrorType field in the hyperparameters of reconstructive models");
            end

            switch modelOptions.hyperparameters.reconstructionErrorType.value
                case "median point-wise values"
                    % calculate median predicted value for each time step and then calculate the errors for the entire time series
                    prediction = mergeOverlappingSubsequences(modelOptions, prediction, @median);
                    anomalyScores = abs(prediction - YTest);
                case "median point-wise errors"
                    % calulate the point-wise errors for each subsequence and then calculate the median error for each time step
                    if modelOptions.dataType == 1
                        anomalyScores = abs(prediction - XTest);
                    elseif modelOptions.dataType == 2
                        anomalyScores = cell(size(prediction, 1), 1);
                        for i = 1:size(prediction, 1)
                            anomalyScores{i, 1} = abs(prediction{i, 1} - XTest{i, 1});
                        end
                    end
                            
                    anomalyScores = mergeOverlappingSubsequences(modelOptions, anomalyScores, @median);
                case "mean subsequence errors"
                    % calulate the MSE for each subsequence and channel and
                    % then calculate the median error for each time step
                    % and channel
                    windowSize = modelOptions.hyperparameters.windowSize.value;
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
                        numChannels = size(prediction{1, 1}, 1);
                        anomalyScores = prediction;
                        for i = 1:size(prediction, 1)
                            anomalyScores{i, 1} = abs(prediction{i, 1} - XTest{i, 1});

                            for channel_idx = 1:numChannels                            
                                anomalyScores{i, 1}(channel_idx, :) = mean(anomalyScores{i, 1}(channel_idx, :));
                            end
                        end            
                    end

                    anomalyScores = mergeOverlappingSubsequences(modelOptions, anomalyScores, @mean);
                otherwise
                    error("Unknown reconstructionErrorType");
            end
        elseif strcmp(modelOptions.modelType, 'predictive')
            if iscell(prediction)
                pred_tmp = zeros(size(prediction, 1), size(prediction{1, 1}, 1));
                for i = 1:size(prediction, 1)
                        pred_tmp(i, :) = prediction{i, 1}';
                end
                prediction = pred_tmp;
            end

            anomalyScores = abs(prediction - YTest);
        end
end
end

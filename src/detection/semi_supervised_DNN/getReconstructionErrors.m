function errors = getReconstructionErrors(prediction, XTest, TSTest, errorType, windowSize, dataType)
%GETRECONSTRUCTIONERRORS Computes reconstruction errors according to
%selected errorType

switch errorType
    case "median point-wise values"
        % calculate median predicted value for each time step and then calculate the errors for the entire time series
        prediction = mergeOverlappingSubsequences(prediction, windowSize, dataType, @median);
        errors = abs(prediction - TSTest);
    case "median point-wise errors"
        % calulate the point-wise errors for each subsequence and then calculate the median error for each time step
        if dataType == 1
            errors = abs(prediction - XTest);
        elseif dataType == 2
            errors = cell(numel(prediction), 1);
            for i = 1:numel(prediction)
                errors{i} = abs(prediction{i} - XTest{i});
            end
        end
                
        errors = mergeOverlappingSubsequences(errors, windowSize, dataType, @median);
    case "mean subsequence RMSE"
        % calulate the RMSE for each subsequence and channel and
        % then calculate the mean error for each time step
        if dataType == 1
            errors = abs(prediction - XTest);
            numChannels = round(size(errors, 2) / windowSize);                        
            for channel_idx = 1:numChannels
                % Assign RMSE to each poit of every subsequence
                for i = 1:size(prediction, 1)
                    errors(i, ((channel_idx - 1) * windowSize + 1):((channel_idx - 1) * windowSize + windowSize)) = ...
                        sqrt(mean((errors(i, ((channel_idx - 1) * windowSize + 1):((channel_idx - 1) * windowSize + windowSize))).^2));
                end
            end
        elseif dataType == 2
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

        errors = mergeOverlappingSubsequences(errors, windowSize, dataType, @mean);
    otherwise
        error("Unknown reconstructionErrorType");
end
end
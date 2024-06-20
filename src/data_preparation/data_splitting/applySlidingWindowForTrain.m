function [XTrain, YTrain, XVal, YVal] = applySlidingWindowForTrain(data, windowSize, stepSize, valSize, modelType, dataType)
%APPLYSLIDINGWINDOWFORTRAIN Splits the data for training using a sliding window defined
%by the window size and step size
% Possible values for dataType: CBT, BC  (meaning ChannelBatchTime and
% BatchChannel)


XTrain = [];
YTrain = [];

% Check modelType and dataType
if (~ismember(modelType, ["reconstruction", "forecasting"]))
    error("invalid modelType, must be either forecasting or reconstruction")
end

if (~ismember(dataType, ["CBT", "BC"]))
    error("invalid dataType, must be either CBT or BC");
end

numChannels = size(data{1}, 2);

    
% Get total number of windows
numWindowsTotal = 0;

if strcmp(modelType, "reconstruction")
    for file_idx = 1:numel(data)
        numWindowsTotal = numWindowsTotal + floor((size(data{file_idx}, 1) - windowSize + 1) / stepSize);
    end
else
    for file_idx = 1:numel(data)
        numWindowsTotal = numWindowsTotal + floor((size(data{file_idx}, 1) - windowSize) / stepSize);
    end
end


 % Prepare data for different data types
switch dataType
    case "BC"
        flattenedWindowSize = windowSize * numChannels;

        XTrain = zeros(numWindowsTotal, flattenedWindowSize);
        if (strcmp(modelType, "forecasting"))
            YTrain = zeros(numWindowsTotal, numChannels);
        end

        index = 0;

        for file_idx = 1:numel(data)            
            if (strcmp(modelType, "reconstruction"))
                numWindows = floor((size(data{file_idx}, 1) - windowSize + 1) / stepSize);
            else
                numWindows = floor((size(data{file_idx}, 1) - windowSize) / stepSize);
            end

            if numWindows < 1
                error("Window size is too big for the time series. Must be less than the length of the time series");
            end
            
            if (strcmp(modelType, "reconstruction"))
                for i = 1:numWindows
                    XTrain(index + i, :) = reshape(data{file_idx}((i * stepSize):(i * stepSize + windowSize - 1), :), [1, flattenedWindowSize]);
                end
            else
                for i = 1:numWindows
                    XTrain(index + i, :) = reshape(data{file_idx}((i * stepSize):(i * stepSize + windowSize - 1), :), [1, flattenedWindowSize]);
                    YTrain(index + i, :) = data{file_idx}((((i - 1) * stepSize) + windowSize + 1), :);
                end
            end

            index = index + i;
        end
        
        
        % Shuffle data
        indices = randperm(numWindowsTotal);        
        
        if (strcmp(modelType, "reconstruction"))
            XTrain = XTrain(indices, :);
            if valSize ~= 0    
                l = round(valSize * numWindowsTotal);            
                XVal = XTrain(1:l, :);
                XTrain = XTrain((l + 1):end, :);
            else
                XVal = [];
            end
    
            YTrain = XTrain;
            YVal = XVal;
        else
            XTrain = XTrain(indices, :);
            YTrain = YTrain(indices, :);
            
            if valSize ~= 0
                l = round(valSize * numWindowsTotal);
            
                XVal = XTrain(1:l, :);
                YVal = YTrain(1:l, :);
                XTrain = XTrain((l + 1):end, :);
                YTrain = YTrain((l + 1):end, :);
            else
                XVal = [];
                YVal = [];
            end
        end        
    case "CBT"
        XTrain = zeros(numChannels, numWindowsTotal, windowSize);
        if (strcmp(modelType, "forecasting"))
            YTrain = zeros(numWindowsTotal, numChannels);
        end

        index = 0;

        for file_idx = 1:numel(data)
            if (strcmp(modelType, "reconstruction"))
                numWindows = floor((size(data{file_idx}, 1) - windowSize + 1) / stepSize);
            else
                numWindows = floor((size(data{file_idx}, 1) - windowSize) / stepSize);
            end

            if numWindows < 1
                error("Window size is too big for the time series. Must be less than the length of the time series");
            end
            
            if (strcmp(modelType, "reconstruction"))
                for i = 1:numWindows
                    XTrain(:, index + i, :) = reshape(data{file_idx}((i * stepSize):(i * stepSize + windowSize - 1), :)', [numChannels, 1, windowSize]);
                end
            else
                for i = 1:numWindows
                    XTrain(:, index + i, :) = reshape(data{file_idx}((i * stepSize):(i * stepSize + windowSize - 1), :)', [numChannels, 1, windowSize]);
                    YTrain(index + i, :) = data{file_idx}((((i - 1) * stepSize) + windowSize + 1), :);
                end
            end

            index = index + i;
        end
        
        % Shuffle data
        indices = randperm(numWindowsTotal);        
        
        if (strcmp(modelType, "reconstruction"))
            XTrain = XTrain(:, indices, :);
            if valSize ~= 0    
                l = round(valSize * numWindowsTotal);            
                XVal = XTrain(:, 1:l, :);
                XTrain = XTrain(:, (l + 1):end, :);
            else
                XVal = [];
            end
    
            YTrain = XTrain;
            YVal = XVal;
        else
            XTrain = XTrain(:, indices, :);
            YTrain = YTrain(indices, :);
            
            if valSize ~= 0
                l = round(valSize * numWindowsTotal);
            
                XVal = XTrain(:, 1:l, :);
                YVal = YTrain(1:l, :);
                XTrain = XTrain(:, (l + 1):end, :);
                YTrain = YTrain((l + 1):end, :);
            else
                XVal = [];
                YVal = [];
            end
        end
end
end
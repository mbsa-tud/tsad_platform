function [XTrain, YTrain, XVal, YVal] = applSlidingWindowForTrain(data, windowSize, stepSize, valSize, modelType, dataType)
%APPLYSLIDINGWINDOWFORTRAIN Splits the data for training using a sliding window defined
%by the window size and step size
% Possible values for dataType:
% "array_flattened": Array of flattened subsequences ((Windowsize * Features) x Observations)
% "array": Array of subsequences (Windowsize x Features x Observations)
% "cell_array": Cell array of transposed subsequences (Features x Windowsize)

XTrain = [];
YTrain = [];

numChannels = size(data{1}, 2);

if strcmp(modelType, "reconstruction")
    % Get total number of windows
    numWindowsTotal = 0;
    for file_idx = 1:numel(data)
        numWindowsTotal = numWindowsTotal + floor((size(data{file_idx}, 1) - windowSize + 1) / stepSize);
    end

     % Prepare data for different data types
    switch dataType
        case "array_flattened"
            flattenedWindowSize = windowSize * numChannels;

            XTrain = zeros(numWindowsTotal, flattenedWindowSize);

            index = 0;

            for file_idx = 1:numel(data)
                numWindows = floor((size(data{file_idx}, 1) - windowSize) / stepSize);
                if numWindows < 1
                    error("Window size is too big for the time series. Must be less than the length of the time series");
                end

                for i = (index + 1):(index + numWindows)
                    XTrain(i, :) = reshape(data{file_idx}((i * stepSize):(i * stepSize + windowSize - 1), :), [1, flattenedWindowSize]);
                end
            end

            YTrain = XTrain;
            
            % Shuffle data
            numWindows = size(XTrain, 1);
            indices = randperm(numWindows);
            
            XTrain = XTrain(indices, :);
            YTrain = YTrain(indices, :);
            
            % Val data
            if valSize ~= 0    
                l = round(valSize * numWindows);
            
                XVal = XTrain(1:l, :);
                YVal = YTrain(1:l, :);
                XTrain = XTrain((l + 1):end, :);
                YTrain = YTrain((l + 1):end, :);
            else
                XVal = [];
                YVal = [];
            end
        case "cell_array"
            XTrain = cell(numWindowsTotal, 1);

            index = 0;

            for file_idx = 1:numel(data)
                numWindows = floor((size(data{file_idx}, 1) - windowSize) / stepSize);
                if numWindows < 1
                    error("Window size is too big for the time series. Must be less than the length of the time series");
                end

                for i = (index + 1):(index + numWindows)
                    XTrain{i} = data{file_idx}((i * stepSize):(i * stepSize + windowSize - 1), :)';
                end
            end
            
            YTrain = XTrain;
            
            % Shuffle data
            numWindows = size(XTrain, 1);
            indices = randperm(numWindows);
            
            XTrain = XTrain(indices, :);
            YTrain = YTrain(indices, :);
            
            % Val data
            if valSize ~= 0    
                l = round(valSize * numWindows);
            
                XVal = XTrain(1:l, :);
                YVal = YTrain(1:l, :);
                XTrain = XTrain((l + 1):end, :);
                YTrain = YTrain((l + 1):end, :);
            else
                XVal = [];
                YVal = [];
            end
        otherwise
            error("Invalid dataType for reconstruction model. must be one of 'array_flattened', 'cell_array'");
    end
elseif strcmp(modelType, "forecasting")
    % Get total number of windows
    numWindowsTotal = 0;
    for file_idx = 1:numel(data)
        numWindowsTotal = numWindowsTotal + floor((size(data{file_idx}, 1) - windowSize) / stepSize);
    end

    % Prepare data for different data types
    switch dataType
        case "array_flattened"
            flattenedWindowSize = windowSize * numChannels;

            XTrain = zeros(numWindowsTotal, flattenedWindowSize);
            YTrain = zeros(numWindowsTotal, numChannels);

            index = 0;

            for file_idx = 1:numel(data)
                numWindows = floor((size(data{file_idx}, 1) - windowSize) / stepSize);
                if numWindows < 1
                    error("Window size is too big for the time series. Must be less than the length of the time series");
                end

                for i = (index + 1):(index + numWindows)
                    XTrain(i, :) = reshape(data{file_idx}((i * stepSize):(i * stepSize + windowSize - 1), :), [1, flattenedWindowSize]);
                    YTrain(i, :) = data{file_idx}((((i - 1) * stepSize) + windowSize + 1), :);
                end
            end
            
            % Shuffle data
            numWindows = size(XTrain, 1);
            indices = randperm(numWindows);
            
            XTrain = XTrain(indices, :);
            YTrain = YTrain(indices, :);
            
            % Val data
            if valSize ~= 0    
                l = round(valSize * numWindows);
            
                XVal = XTrain(1:l, :);
                YVal = YTrain(1:l, :);
                XTrain = XTrain((l + 1):end, :);
                YTrain = YTrain((l + 1):end, :);
            else
                XVal = [];
                YVal = [];
            end
        case "cell_array"
            XTrain = cell(numWindowsTotal, 1);
            YTrain = zeros(numWindowsTotal, numChannels);

            index = 0;

            for file_idx = 1:numel(data)
                numWindows = floor((size(data{file_idx}, 1) - windowSize) / stepSize);
                if numWindows < 1
                    error("Window size is too big for the time series. Must be less than the length of the time series");
                end

                for i = (index + 1):(index + numWindows)
                    XTrain{i} = data{file_idx}((i * stepSize):(i * stepSize + windowSize - 1), :)';
                    YTrain(i, :) = data{file_idx}((((i - 1) * stepSize) + windowSize + 1), :);
                end
            end

            % Shuffle data
            numWindows = size(XTrain, 1);
            indices = randperm(numWindows);
            
            XTrain = XTrain(indices, :);
            YTrain = YTrain(indices, :);
            
            % Val data
            if valSize ~= 0    
                l = round(valSize * numWindows);
            
                XVal = XTrain(1:l, :);
                YVal = YTrain(1:l, :);
                XTrain = XTrain((l + 1):end, :);
                YTrain = YTrain((l + 1):end, :);
            else
                XVal = [];
                YVal = [];
            end
        case "array"
            XTrain = zeros(windowSize, numChannels, numWindowsTotal);
            YTrain = zeros(numWindowsTotal, numChannels);

            index = 0;

            for file_idx = 1:numel(data)
                numWindows = floor((size(data{file_idx}, 1) - windowSize) / stepSize);
                if numWindows < 1
                    error("Window size is too big for the time series. Must be less than the length of the time series");
                end

                for i = (index + 1):(index + numWindows)
                    XTrain(:, :, i) = data{file_idx}((i * stepSize):(i * stepSize + windowSize - 1), :);
                    YTrain(i, :) = data{file_idx}((((i - 1) * stepSize) + windowSize + 1), :);
                end
            end

            % Shuffle data
            numWindows = size(XTrain, 3);
            indices = randperm(numWindows);
            
            XTrain = XTrain(:, :, indices);
            YTrain = YTrain(indices, :);
            
            % Val data
            if valSize ~= 0    
                l = round(valSize * numWindows);
            
                XVal = XTrain(:, :, 1:l);
                YVal = YTrain(1:l, :);
                XTrain = XTrain(:, :, (l + 1):end);
                YTrain = YTrain((l + 1):end, :);
            else
                XVal = [];
                YVal = [];
            end
        otherwise
            error("Invalid dataType for forecasting model. must be one of 'array_flattened', 'cell_array', 'array'");
    end
else
    error("Invalid modelType. Must be one of: forecasting, reconstruction");
end
end

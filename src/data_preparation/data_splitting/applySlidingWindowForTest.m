function [XTest, timeSeriesTest, labelsTest] = applySlidingWindowForTest(data, labels, windowSize, modelType, dataType)
%APPLYSLIDINGWINDOWFORTEST Splits the data for training using a sliding window defined
%by the window size and step size
% Possible values for dataType:
% "array_flattened": Array of flattened subsequences ((Windowsize * Features) x Observations)
% "array": Array of subsequences (Windowsize x Features x Observations)
% "cell_array": Cell array of transposed subsequences (Features x Windowsize)

numChannels = size(data{1}, 2);

if strcmp(modelType, "reconstruction")
    numWindows = size(data{1}, 1) - windowSize + 1;
    
    if numWindows < 1
        error("Window size is too big for the time series. Must be equal or less than the length of the time series");
    end

    % XTest
    switch dataType
        case "array_flattened"
            flattenedWindowSize = windowSize * numChannels;
            XTest = zeros(numWindows, flattenedWindowSize);
            for i = 1:numWindows
                XTest(i, :) = reshape(data{1}(i:(i + windowSize - 1), :), ...
                        [1, flattenedWindowSize]);
            end
        case "cell_array"
            XTest = cell(numWindows, 1);
            for i = 1:numWindows
                XTest{i} = data{1}(i:(i + windowSize - 1), :)';
            end
        otherwise
            error("Invalid dataType for reconstruction model. must be one of 'array_flattened', 'cell_array'");
    end

    % TSTest and labels
    timeSeriesTest = data{1};
    labelsTest = logical(labels{1});
elseif strcmp(modelType, "forecasting")
    numWindows = size(data{1}, 1) - windowSize;

    if numWindows < 1
        error("Window size is too big for the time series. Must be less than the length of the time series");
    end
    
    % XTest
    switch dataType
        case "array_flattened"
            flattenedWindowSize = windowSize * numChannels;
            XTest = zeros(numWindows, flattenedWindowSize);
            for i = 1:numWindows
                XTest(i, :) = reshape(data{1}(i:(i + windowSize - 1), :), ...
                        [1, flattenedWindowSize]);
            end
        case "cell_array"
            XTest = cell(numWindows, 1);
            for i = 1:numWindows
                XTest{i} = data{1}(i:(i + windowSize - 1), :)';
            end
        case "array"
            XTest = zeros(windowSize, numChannels, numWindows);
            for i = 1:numWindows
                XTest(:, :, i) = data{1}(i:(i + windowSize - 1), :);
            end
        otherwise
            error("Invalid dataType for forecasting model. must be one of 'array_flattened', 'cell_array', 'array'");
    end
    
    % TSTest and labels
    timeSeriesTest = data{1}((windowSize + 1):end, :);
    labelsTest = logical(labels{1}((windowSize + 1):end, 1));
else
    error("Invalid modelType. Must be one of: forecasting, reconstruction");
end
end


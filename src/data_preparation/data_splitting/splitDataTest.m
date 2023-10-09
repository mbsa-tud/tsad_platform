function [XTest, timeSeriesTest, labelsTest] = splitDataTest(data, labels, windowSize, modelType, dataType)
%SPLITDATATEST Splits the data for testing using a sliding window defined
%by the window size

numChannels = size(data{1}, 2);

if strcmp(modelType, "reconstruction")
    numWindows = size(data{1}, 1) - windowSize + 1;
    
    if numWindows < 1
        error("Window size is too big for the time series. Must be equal or less than the length of the time series");
    end

    % XTest
    if dataType == 1
        flattenedWindowSize = windowSize * numChannels;
        XTest = zeros(numWindows, flattenedWindowSize);
        for i = 1:numWindows
            XTest(i, :) = reshape(data{1}(i:(i + windowSize - 1), :), ...
                    [1, flattenedWindowSize]);
        end
    elseif dataType == 2
        XTest = cell(numWindows, 1);
        for i = 1:numWindows
            XTest{i} = data{1}(i:(i + windowSize - 1), :)';
        end
    else
        error("Invalid dataType for reconstruction model. Must be one of: 1, 2");
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
    if dataType == 1
        flattenedWindowSize = windowSize * numChannels;
        XTest = zeros(numWindows, flattenedWindowSize);
        for i = 1:numWindows
            XTest(i, :) = reshape(data{1}(i:(i + windowSize - 1), :), ...
                    [1, flattenedWindowSize]);
        end
    elseif dataType == 2
        XTest = cell(numWindows, 1);
        for i = 1:numWindows
            XTest{i} = data{1}(i:(i + windowSize - 1), :)';
        end
    elseif dataType == 3
        XTest = cell(numWindows, 1);
        for i = 1:numWindows
            XTest{i} = data{1}(i:(i + windowSize - 1), :);
        end
    else
        error("Invalid dataType for forecasting model. Must be one of: 1, 2, 3");
    end
    
    % TSTest and labels
    timeSeriesTest = data{1}((windowSize + 1):end, :);
    labelsTest = logical(labels{1}((windowSize + 1):end, 1));
else
    error("Invalid modelType. Must be one of: forecasting, reconstruction");
end
end


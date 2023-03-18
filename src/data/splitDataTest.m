function [XTest, YTest, labelsTest] = splitDataTest(data, labels, windowSize, modelType, dataType)
%SPLITDATATEST Splits the data for testing using a sliding window defined
%by the window size

numChannels = size(data{1, 1}, 2);

if strcmp(modelType, 'reconstructive')
    numWindows = size(data{1, 1}, 1) - windowSize + 1;

    if numWindows < windowSize
        error("Window size is too big for the time series. Must be less than a third the length of the time series");
    end

    % XTest
    if dataType == 1
        flattenedWindowsSize = windowSize * numChannels;
        XTest = zeros(numWindows, flattenedWindowsSize);
        for i = 1:numWindows
            XTest(i, :) = reshape(data{1, 1}(i:(i + windowSize - 1), :), ...
                    [1, flattenedWindowsSize]);
        end
    elseif dataType == 2
        XTest = cell(numWindows, 1);
        for i = 1:numWindows
            XTest{i, 1} = data{1, 1}(i:(i + windowSize - 1), :)';
        end
    else
        error("Invalid dataType for reconstructive model. Must be one of: 1, 2");
    end

    % YTest and labels
    YTest = data{1, 1};
    labelsTest = logical(labels{1, 1});
elseif strcmp(modelType, 'predictive')
    numWindows = size(data{1, 1}, 1) - windowSize;

    if numWindows < 1
        error("Window size is too big for the time series. Must be less than half the length of the time series");
    end
    
    % XTest
    if dataType == 1
        flattenedWindowsSize = windowSize * numChannels;
        XTest = zeros(numWindows, flattenedWindowsSize);
        for i = 1:numWindows
            XTest(i, :) = reshape(data{1, 1}(i:(i + windowSize - 1), :), ...
                    [1, flattenedWindowsSize]);
        end
    elseif dataType == 2
        XTest = cell(numWindows, 1);
        for i = 1:numWindows
            XTest{i, 1} = data{1, 1}(i:(i + windowSize - 1), :)';
        end
    elseif dataType == 3
        XTest = cell(numWindows, 1);
        for i = 1:numWindows
            XTest{i, 1} = data{1, 1}(i:(i + windowSize - 1), :);
        end
    else
        error("Invalid dataType for predictive model. Must be one of: 1, 2, 3");
    end
    
    % YTest and labels
    YTest = data{1, 1}((windowSize + 1):end, :);
    labelsTest = logical(labels{1, 1}((windowSize + 1):end, 1));
else
    error("Invalid modelType. Must be one of: predictive, reconstructive");
end
end


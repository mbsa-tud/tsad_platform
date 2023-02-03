function [XTest, YTest, labelsTest] = splitDataTest(data, labels, windowSize, modelType, dataType)
%SPLITDATATEST
%
% Splits the data for testing using the sliding window

numChannels = size(data{1, 1}, 2);
numWindows = round((size(data{1, 1}, 1) - windowSize));

if strcmp(modelType, 'reconstructive')
    if numWindows < windowSize
        error("Window size is too big for the time series. Must be less than a third the length of the time series");
    end
elseif strcmp(modelType, 'predictive')
    if numWindows < 1
        error("Window size is too big for the time series. Must be less than half the length of the time series");
    end
end

% XTest
if dataType == 1
    flattenedWindowsSize = windowSize * numChannels;
    XTest = zeros(numWindows, flattenedWindowsSize);
    for j = 1:numWindows
        XTest(j, :) = reshape(data{1, 1}(j:(j + windowSize - 1), :), ...
                [1, flattenedWindowsSize]);
    end
elseif dataType == 2
    XTest = cell(numWindows, 1);
    for j = 1:numWindows
        XTest{j, 1} = data{1, 1}(j:(j + windowSize - 1), :)';
    end
elseif dataType == 3
    XTest = cell(numWindows, 1);
    for j = 1:numWindows
        XTest{j, 1} = data{1, 1}(j:(j + windowSize - 1), :);
    end
end

% YTest and labels
if strcmp(modelType, 'predictive')
    YTest = data{1, 1}((windowSize + 1):end, :);
    labelsTest = logical(labels{1, 1}((windowSize + 1):end, 1));
elseif strcmp(modelType, 'reconstructive')
    YTest = data{1, 1}(windowSize:(end - windowSize - 1), :);
    labelsTest = logical(labels{1, 1}(windowSize:(end - windowSize - 1), 1));
end
end


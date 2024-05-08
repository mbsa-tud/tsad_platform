function [XTest, timeSeriesTest, labelsTest] = applySlidingWindowForTest(data, labels, windowSize, modelType, dataType)
%APPLYSLIDINGWINDOWFORTEST Splits the data for training using a sliding window defined
%by the window size and step size
% Possible values for dataType: CBT, BC  (meaning ChannelBatchTime and
% BatchChannel)

% Check modelType and dataType
if (~ismember(modelType, ["reconstruction", "forecasting"]))
    error("invalid modelType, must be either forecasting or reconstruction")
end

if (~ismember(dataType, ["CBT", "BC"]))
    error("invalid dataType, must be either CBT or BC");
end

numChannels = size(data{1}, 2);

if strcmp(modelType, "reconstruction")
    numWindows = size(data{1}, 1) - windowSize + 1;
else
    numWindows = size(data{1}, 1) - windowSize;
end

if numWindows < 1
    error("Window size is too big for the time series. Must be less than the length of the time series");
end

% XTest
switch dataType
    case "BC"
        flattenedWindowSize = windowSize * numChannels;
        XTest = zeros(numWindows, flattenedWindowSize);
        for i = 1:numWindows
            XTest(i, :) = reshape(data{1}(i:(i + windowSize - 1), :), [1, flattenedWindowSize]);
        end
    case "CBT"
        XTest = zeros(numChannels, numWindows, windowSize);
        for i = 1:numWindows
            XTest(:, i, :) = reshape(data{1}((i):(i + windowSize - 1), :)', [numChannels, 1, windowSize]);
        end
end

% The time series section which will have anomly scores and the labels
if strcmp(modelType, "reconstruction")
    timeSeriesTest = data{1};
    labelsTest = logical(labels{1});
else
    timeSeriesTest = data{1}((windowSize + 1):end, :);
    labelsTest = logical(labels{1}((windowSize + 1):end, 1));
end
end


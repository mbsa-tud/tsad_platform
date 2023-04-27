function [XTrain, YTrain, XVal, YVal] = splitDataTrain(data, windowSize, stepSize, ratioTrainVal, modelType, dataType)
%SPLITDATATRAIN Splits the data for training using a sliding window defined
%by the window size and step size

XTrain = [];
YTrain = [];

numChannels = size(data{1}, 2);

if strcmp(modelType, "reconstructive")
    for data_idx = 1:numel(data)
        numWindows = floor((size(data{data_idx}, 1) - windowSize + 1) / stepSize);
        
        if numWindows < 1
            error("Window size is too big for the time series. Must be equal or less than the length of the time series");
        end

        if dataType == 1
            flattenedWindowsSize = windowSize * numChannels;
            XTrainTmp = zeros(numWindows, flattenedWindowsSize);
            for i = 1:numWindows
                XTrainTmp(i, :) = reshape(data{data_idx}((i * stepSize):(i * stepSize + windowSize - 1), :), ...
                    [1, flattenedWindowsSize]);
            end

            XTrain = [XTrain; XTrainTmp];
            YTrain = XTrain;
        elseif dataType == 2
            XTrainTmp = cell(numWindows, 1);
            for i = 1:numWindows
                XTrainTmp{i} = data{data_idx}((i * stepSize):(i * stepSize + windowSize - 1), :)';
            end

            XTrain = [XTrain; XTrainTmp];
            YTrain = XTrain;
        else
            error("Invalid dataType for reconstructive model. Must be one of: 1, 2");
        end
    end
elseif strcmp(modelType, "predictive")
    for data_idx = 1:numel(data)
        numWindows = floor((size(data{data_idx}, 1) - windowSize) / stepSize);
        
        if numWindows < 1
            error("Window size is too big for the time series. Must be less than the length of the time series");
        end

        if dataType == 1
            flattenedWindowsSize = windowSize * numChannels;
            XTrainTmp = zeros(numWindows, flattenedWindowsSize);
            for i = 1:numWindows
                XTrainTmp(i, :) = reshape(data{data_idx}((i * stepSize):(i * stepSize + windowSize - 1), :), ...
                    [1, flattenedWindowsSize]);
            end

            YTrainTmp = zeros(numWindows, numChannels);
            for i = 1:numWindows
                YTrainTmp(i, :) = data{data_idx}((((i - 1) * stepSize) + windowSize + 1), :);
            end

            XTrain = [XTrain; XTrainTmp];
            YTrain = [YTrain; YTrainTmp]; 
        elseif dataType == 2
            XTrainTmp = cell(numWindows, 1);
            for i = 1:numWindows
                XTrainTmp{i} = data{data_idx}((i * stepSize):(i * stepSize + windowSize - 1), :)';
            end

            YTrainTmp = zeros(numWindows, numChannels);
            for i = 1:numWindows
                YTrainTmp(i, :) = data{data_idx}((((i - 1) * stepSize) + windowSize + 1), :);
            end

            XTrain = [XTrain; XTrainTmp];
            YTrain = [YTrain; YTrainTmp]; 
        elseif dataType == 3
            XTrainTmp = cell(numWindows, 1);
            for i = 1:numWindows
                XTrainTmp{i} = data{data_idx}((i * stepSize):(i * stepSize + windowSize - 1), :);
            end

            YTrainTmp = cell(numWindows, 1);
            for i = 1:numWindows
                YTrainTmp{i, :} = data{data_idx}((((i - 1) * stepSize) + windowSize + 1), :)';
            end

            XTrain = [XTrain; XTrainTmp];
            YTrain = [YTrain; YTrainTmp];
        else
            error("Invalid dataType for predictive model. Must be one of: 1, 2, 3");
        end                   
    end
else
    error("Invalid modelType. Must be one of: predictive, reconstructive");
end

% Val data
if ratioTrainVal ~= 0
    numWindows = size(XTrain, 1);

    l = round(ratioTrainVal * numWindows);

    XVal = XTrain(1:l, :);
    YVal = YTrain(1:l, :);
    XTrain = XTrain((l + 1):end, :);
    YTrain = YTrain((l + 1):end, :);
else
    XVal = [];
    YVal = [];
end
end

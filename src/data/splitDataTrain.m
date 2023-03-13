function [XTrain, YTrain, XVal, YVal] = splitDataTrain(data, windowSize, stepSize, ratioTrainVal, modelType, dataType)
%SPLITDATATRAIN
%
% Splits the data for training using a sliding window defined by the
% windowSize and stepSize

XTrain = [];
YTrain = [];

numChannels = size(data{1, 1}, 2);

if strcmp(modelType, 'reconstructive')
    for dataIdx = 1:size(data, 1)
        numWindows = floor((size(data{dataIdx, 1}, 1) - windowSize + 1) / stepSize);
        
        if dataType == 1
            flattenedWindowsSize = windowSize * numChannels;
            XTrainTmp = zeros(numWindows, flattenedWindowsSize);
            for i = 1:numWindows
                XTrainTmp(i, :) = reshape(data{dataIdx, 1}((i * stepSize):(i * stepSize + windowSize - 1), :), ...
                    [1, flattenedWindowsSize]);
            end

            XTrain = [XTrain; XTrainTmp];
            YTrain = XTrain;
        elseif dataType == 2
            XTrainTmp = cell(numWindows, 1);
            for i = 1:numWindows
                XTrainTmp{i, 1} = data{dataIdx, 1}((i * stepSize):(i * stepSize + windowSize - 1), :)';
            end

            XTrain = [XTrain; XTrainTmp];
            YTrain = XTrain;
        else
            error("Invalid dataType for reconstructive model. Must be one of: 1, 2");
        end
    end
elseif strcmp(modelType, 'predictive')
    for dataIdx = 1:size(data, 1)
        numWindows = floor((size(data{dataIdx, 1}, 1) - windowSize) / stepSize);
        
        if dataType == 1
            flattenedWindowsSize = windowSize * numChannels;
            XTrainTmp = zeros(numWindows, flattenedWindowsSize);
            for i = 1:numWindows
                XTrainTmp(i, :) = reshape(data{dataIdx, 1}((i * stepSize):(i * stepSize + windowSize - 1), :), ...
                    [1, flattenedWindowsSize]);
            end

            YTrainTmp = zeros(numWindows, numChannels);
            for i = 1:numWindows
                YTrainTmp(i, :) = data{dataIdx, 1}((((i - 1) * stepSize) + windowSize + 1), :);
            end

            XTrain = [XTrain; XTrainTmp];
            YTrain = [YTrain; YTrainTmp]; 
        elseif dataType == 2
            XTrainTmp = cell(numWindows, 1);
            for i = 1:numWindows
                XTrainTmp{i, 1} = data{dataIdx, 1}((i * stepSize):(i * stepSize + windowSize - 1), :)';
            end

            YTrainTmp = zeros(numWindows, numChannels);
            for i = 1:numWindows
                YTrainTmp(i, :) = data{dataIdx, 1}((((i - 1) * stepSize) + windowSize + 1), :);
            end

            XTrain = [XTrain; XTrainTmp];
            YTrain = [YTrain; YTrainTmp]; 
        elseif dataType == 3
            XTrainTmp = cell(numWindows, 1);
            for i = 1:numWindows
                XTrainTmp{i, 1} = data{dataIdx, 1}((i * stepSize):(i * stepSize + windowSize - 1), :);
            end

            YTrainTmp = cell(numWindows, 1);
            for i = 1:numWindows
                YTrainTmp{i, :} = data{dataIdx, 1}((((i - 1) * stepSize) + windowSize + 1), :)';
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

% Shuffle
indices = randperm(size(XTrain, 1));

XTrain = XTrain(indices, :);
YTrain = YTrain(indices, :);

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

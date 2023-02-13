function [XTrain, YTrain, XVal, YVal] = splitDataTrain(data, windowSize, stepSize, ratioTrainVal, modelType, dataType)
%SPLITDATATRAIN
%
% Splits the data for training using a sliding sliding window

XTrain = [];
YTrain = [];

numChannels = size(data{1, 1}, 2);

for i = 1:size(data, 1)
    numWindows = round((size(data{i, 1}, 1) - windowSize - stepSize + 1) / stepSize);
    
    if dataType == 1
        flattenedWindowsSize = windowSize * numChannels;
        XTrainTmp = zeros(numWindows, flattenedWindowsSize);
        for j = 1:numWindows
            XTrainTmp(j, :) = reshape(data{i, 1}((j * stepSize):(j * stepSize + windowSize - 1), :), ...
                [1, flattenedWindowsSize]);
        end
    elseif dataType == 2 || dataType == 3
        XTrainTmp = cell(numWindows, 1);
        for j = 1:numWindows
            XTrainTmp{j, 1} = data{i, 1}((j * stepSize):(j * stepSize + windowSize - 1), :)';
        end
    end      
    
    XTrain = [XTrain; XTrainTmp];

    if strcmp(modelType, 'predictive')
        if dataType == 3
            YTrainTmp = cell(numWindows, 1);
            for j = 1:numWindows
                YTrainTmp{j, 1} = data{i, 1}((((j - 1) * stepSize) + windowSize + 1), :)';
            end
        else
            YTrainTmp = zeros(numWindows, numChannels);
            for j = 1:numWindows
                YTrainTmp(j, :) = data{i, 1}((((j - 1) * stepSize) + windowSize + 1), :);
            end
        end

        YTrain = [YTrain; YTrainTmp];
    elseif strcmp(modelType, 'reconstructive')
        YTrain = XTrain;
    end
end


% Shuffle
indices = randperm(size(XTrain, 1));

XTrain = XTrain(indices, :);
YTrain = YTrain(indices, :);


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

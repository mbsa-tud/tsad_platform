function reshapedPrediction = mergeOverlappingSubsequences(prediction, windowSize, dataType, averagingFunction)
%MERGEOVERLAPPINGSUBSEQUENCES Get the average predicted value for each
%observation of the time series

if (~ismember(dataType, ["CBT", "BC"]))
    error("invalid dataType, must be either CBT or BC");
end

if strcmp(dataType, "BC")
    numChannels = round(size(prediction, 2) / windowSize);
    numWindows = size(prediction, 1);
    reshapedPrediction = zeros((numWindows + windowSize - 1), numChannels);
    
    for channel_idx = 1:numChannels
        data = zeros(numWindows, windowSize);
        for i = 1:numWindows
            data(i, :) = prediction(i, ((channel_idx - 1) * windowSize + 1):((channel_idx - 1) * windowSize + windowSize));
        end
    
        reshapedPrediction(:, channel_idx) = mergeSequences(data, windowSize, averagingFunction);
    end
elseif strcmp(dataType, "CBT")
    numChannels = size(prediction, 1);
    numWindows = size(prediction, 2);
    reshapedPrediction = zeros((numWindows + windowSize - 1), numChannels);
    
    for channel_idx = 1:numChannels
        data = zeros(numWindows, windowSize);
        for i = 1:numWindows
            data(i, :) = reshape(prediction(channel_idx, i, :), [1, windowSize]);
        end
    
        reshapedPrediction(:, channel_idx) = mergeSequences(data, windowSize, averagingFunction);
    end
end
end

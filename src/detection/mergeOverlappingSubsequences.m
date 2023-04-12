function reshapedPrediction = mergeOverlappingSubsequences(modelOptions, prediction, averagingFunction)
%MERGEOVERLAPPINGSUBSEQUENCES Get the median predicted value for each
%observation of the time series

windowSize = modelOptions.hyperparameters.windowSize;
dataType = modelOptions.dataType;

if dataType == 1
    numChannels = round(size(prediction, 2) / windowSize);
    reshapedPrediction = zeros((size(prediction, 1) + windowSize - 1), numChannels);
    
    for channel_idx = 1:numChannels
        data = zeros(size(prediction, 1), windowSize);
        for i = 1:size(prediction, 1)
            data(i, :) = prediction(i, ((channel_idx - 1) * windowSize + 1):((channel_idx - 1) * windowSize + windowSize));
        end
    
        reshapedPrediction(:, channel_idx) = mergeSequences(data, windowSize, averagingFunction);
    end
elseif dataType == 2
    numChannels = size(prediction{1, 1}, 1);
    reshapedPrediction = zeros((size(prediction, 1) + windowSize - 1), numChannels);
    
    for channel_idx = 1:numChannels
        data = zeros(size(prediction, 1), size(prediction{1, 1}, 2));
        for i = 1:size(prediction, 1)
            data(i, :) = prediction{i, 1}(channel_idx, :);
        end
    
        reshapedPrediction(:, channel_idx) = mergeSequences(data, windowSize, averagingFunction);
    end
end
end

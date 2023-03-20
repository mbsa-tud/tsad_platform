function reshapedPrediction = mergeOverlappingSubsequences(modelOptions, prediction)
%MERGEOVERLAPPINGSUBSEQUENCES Get the median predicted value for each
%observation of the time series

windowSize = modelOptions.hyperparameters.windowSize.value;
dataType = modelOptions.dataType;

if dataType == 1
    numChannels = round(size(prediction, 2) / windowSize);
    reshapedPrediction = zeros((size(prediction, 1) + windowSize - 1), numChannels);
    
    for h = 1:numChannels
        data = zeros(size(prediction, 1), windowSize);
        for j = 1:size(prediction, 1)
            data(j, :) = prediction(j, ((h - 1) * windowSize + 1):((h - 1) * windowSize + windowSize));
        end
    
        reshapedPrediction(:, h) = mergeSequences(data, windowSize, modelOptions.outputsLabels);
    end
elseif dataType == 2
    numChannels = size(prediction{1, 1}, 1);
    reshapedPrediction = zeros((size(prediction, 1) + windowSize - 1), numChannels);
    
    for h = 1:numChannels
        data = zeros(size(prediction, 1), size(prediction{1, 1}, 2));
        for j = 1:size(prediction, 1)
            data(j, :) = prediction{j, 1}(h, :);
        end
    
        reshapedPrediction(:, h) = mergeSequences(data, windowSize, modelOptions.outputsLabels);
    end
end
end

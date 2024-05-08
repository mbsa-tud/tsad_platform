function mergedSubsequences = mergeOverlappingSubsequences(unmergedSubsequences, windowSize, averagingFunction)
%MERGEOVERLAPPINGSUBSEQUENCES Get the average predicted value for each
%observation of the time series

numChannels = size(unmergedSubsequences, 1);
numWindows = size(unmergedSubsequences, 2);
mergedSubsequences = zeros((numWindows + windowSize - 1), numChannels);

for channel_idx = 1:numChannels
    data = zeros(numWindows, windowSize);
    for i = 1:numWindows
        data(i, :) = reshape(unmergedSubsequences(channel_idx, i, :), [1, windowSize]);
    end

    mergedSubsequences(:, channel_idx) = mergeSequences(data, windowSize, averagingFunction);
end
end

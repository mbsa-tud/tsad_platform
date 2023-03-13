function mergedData = mergeSequences(data, windowSize)
reshapedData = flip(data');

newSequenceLength = size(reshapedData, 2) - windowSize + 1;

mergedData = zeros(newSequenceLength, 1);
for i = 1:newSequenceLength
    mergedData(i, 1) = median(diag(reshapedData(:, i:(i + windowSize - 1))));
end
end
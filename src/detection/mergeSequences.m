function mergedData = mergeSequences(data, windowSize)
reshapedData = flip(data');

mergedData = zeros(size(data, 1), 1);
for i = 1:(size(reshapedData, 2) - windowSize)
    mergedData(i, 1) = median(diag(reshapedData(:, i:(i + windowSize - 1))));
end
end
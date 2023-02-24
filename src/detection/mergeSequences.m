function mergedData = mergeSequences(data, windowSize)
reshapedData = [];
for i = 1:size(data, 1)
    reshapedData(:, i) = data(i, :);
end

reshapedData = flip(reshapedData);

mergedData = [];
for i = 1:(size(reshapedData, 2) - windowSize)
    mergedData(i, :) = median(diag(reshapedData(:, i:(i + windowSize - 1))));
end
end
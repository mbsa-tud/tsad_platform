function mergedData = mergeSequences(data, windowSize)
%MERGESEQUENCES Get median value for all overlapping values for each
%observation of the time series
reshapedData = flip(data');

middleSectionLength = size(data, 1) - windowSize + 1;
newSequenceLength = size(data, 1) + windowSize - 1;

mergedData = zeros(newSequenceLength, 1);

for i = 1:middleSectionLength
    mergedData(i + windowSize - 1, 1) = median(diag(reshapedData(:, i:(i + windowSize - 1))));
end
for i = 1:(windowSize - 1)
    mergedData(i, 1) = median(diag(reshapedData((i + 1):end, 1:(windowSize - i))));
    mergedData(middleSectionLength + windowSize - 1 + i) = median(diag(reshapedData((i + 1):end, (middleSectionLength + windowSize - 1 + i):end)));
end
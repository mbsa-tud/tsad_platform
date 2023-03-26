function mergedData = mergeSequences(data, windowSize, averagingFunction)
%MERGESEQUENCES Get averrage value for all overlapping values for each
%observation of the time series using the averaging function provided as an
%argument
reshapedData = flip(data');

middleSectionLength = size(data, 1) - windowSize + 1;
newSequenceLength = size(data, 1) + windowSize - 1;

mergedData = zeros(newSequenceLength, 1);

for i = 1:middleSectionLength
    mergedData(i + windowSize - 1, 1) = averagingFunction(diag(reshapedData(:, i:(i + windowSize - 1))));
end
for i = 1:(windowSize - 1)
    mergedData(windowSize - i, 1) = averagingFunction(diag(reshapedData((i + 1):end, 1:(windowSize - i))));
    mergedData(middleSectionLength + windowSize - 1 + i) = averagingFunction(diag(reshapedData(1:(end - i), (middleSectionLength + i):end)));
end
end
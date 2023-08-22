function mergedData = mergeSequences(data, windowSize, averagingFunction)
%MERGESEQUENCES Get averrage value for all overlapping values for each
%observation of the time series using the averaging function provided as an
%argument
reshapedData = flip(data');

newSequenceLength = size(data, 1) + windowSize - 1;

beginningSectionLength = windowSize;
middleSectionLength = max(0, size(data, 1) - windowSize - 1);
endSectionLength = min(windowSize, (newSequenceLength - windowSize - middleSectionLength));

mergedData = zeros(newSequenceLength, 1);

% Beginning part
for i = 1:beginningSectionLength
    mergedData(i, 1) = averagingFunction(diag(reshapedData((windowSize + 1 - i):end, 1:(min(end, i)))));
end

% End part
for i = 1:endSectionLength
    mergedData(end + 1 - i, 1) = averagingFunction(diag(reshapedData(1:i, (end + 1 - i):end)));
end

% Middle part
for i = 1:middleSectionLength
    mergedData(windowSize + i, 1) = averagingFunction(diag(reshapedData(:, i:(i + windowSize - 1))));
end
end
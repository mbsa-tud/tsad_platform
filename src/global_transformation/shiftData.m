function augmentedData = shiftData(rawData, maximum, minimum, level)
%SHIFTDATA Shift the data by (maximum - minimum) * level

numChannels = size(rawData{1, 1}, 2);

for data_idx = 1:size(rawData, 1)
    currentData = rawData{data_idx, 1};
    for channel_idx = 1:numChannels
        shiftValue = maximum(channel_idx)  * level/100;
        currentData(:, channel_idx) = currentData(:, channel_idx) + shiftValue;
    end
    rawData{data_idx, 1} = currentData;
end

augmentedData = rawData;
end

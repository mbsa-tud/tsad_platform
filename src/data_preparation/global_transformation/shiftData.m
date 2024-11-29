function augmentedData = shiftData(rawData, maximum, level)
%SHIFTDATA Shift the data by maximum * level

numChannels = size(rawData{1}, 2);

for data_idx = 1:numel(rawData)
    currentData = rawData{data_idx};
    for channel_idx = 1:numChannels
        shiftValue = maximum(channel_idx)  * level/100;
        currentData(:, channel_idx) = currentData(:, channel_idx) + shiftValue;
    end
    rawData{data_idx} = currentData;
end

augmentedData = rawData;
end

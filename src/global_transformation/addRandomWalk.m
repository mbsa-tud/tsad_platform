function augmentedData = addRandomWalk(rawData, maximum, minimum, level)
%ADDRANDOMWALK Add random walk noise to the data

level=level/10;
numChannels = size(rawData{1, 1}, 2);

for data_idx = 1:size(rawData, 1)
    currentData = rawData{data_idx, 1};
    for channel_idx = 1:numChannels
        % Generate random walk noise scaled by the amplitude of the signal
        noise = cumsum(randn(size(currentData, 1), 1) * level/50 * (maximum(channel_idx) - minimum(channel_idx)));
        % Add noise to current channel
        currentData(:, channel_idx) = currentData(:, channel_idx) + noise;
    end
    rawData{data_idx, 1} = currentData;
end

augmentedData = rawData;
end
function augmentedData = attenuateExtremum(rawData, mu, level)
%ATTENUATEEXTREMUM Attenuate the extremum of the data

numChannels = size(rawData{1, 1}, 2);

level = level/100;

if ~(level == 0)
    for data_idx = 1:size(rawData, 1)
        newData = rawData{data_idx, 1};
        for channel_idx = 1:numChannels
            newData(:, channel_idx) = newData(:, channel_idx) .* exp(-(newData(:, channel_idx) - mu(channel_idx)) * level);
        end
        rawData{data_idx, 1} = newData;
    end
end

augmentedData = rawData;
end
function augmentedData = addWhiteNoise(rawData, maximum, minimum, level)
%WHITENOISE Adds white noise to the data using maximum and minimum
%parameters and a specified noise level

numChannels = size(rawData{1, 1}, 2);

for data_idx = 1:size(rawData, 1)
    newData = rawData{data_idx, 1};
    for channel_idx = 1:numChannels
        % Génération de bruit blanc pour chaque canal
        noise = (maximum(channel_idx) - minimum(channel_idx)) * level/50 * randn(size(newData(:, channel_idx)));
        newData(:, channel_idx) = newData(:, channel_idx) + noise;
    end
    rawData{data_idx, 1} = newData;
end

augmentedData = rawData;
end
function standardizedData = standardizeData(data, mu, sigma)
%STANDARDIZEDATA Standardizes the data
%   transforms the data to set the mean to 0 and the standard deviation to
%   1


numChannels = size(data{1, 1}, 2);

for channel_idx = 1:numChannels
    if sigma(channel_idx) == 0
        % If data is a flat line, set mean to 0
        for data_idx = 1:size(data, 1)
            newData = data{data_idx, 1}(:, channel_idx);
            newData = newData - mu(channel_idx);
            data{data_idx, 1}(:, channel_idx) = newData;
        end
    else
        for data_idx = 1:size(data, 1)
            newData = data{data_idx, 1}(:, channel_idx);
            newData = (newData - mu(channel_idx)) / sigma(channel_idx);
            data{data_idx, 1}(:, channel_idx) = newData;
        end
    end
end

standardizedData = data;
end
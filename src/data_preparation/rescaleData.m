function rescaledData = rescaleData(data, maximum, minimum)
%RESCALEDATA Rescales the data to the range: [0, 1]


numChannels = size(data{1}, 2);

for channel_idx = 1:numChannels
    if maximum(channel_idx) == minimum(channel_idx)
        % If data is just a flat line, set mean to 0
        for data_idx = 1:numel(data)
            % rescale
            newData = data{data_idx}(:, channel_idx);
            newData = newData - minimum(channel_idx);
    	    
            % clipping (this only has an effect for testing data)
            newData(newData > 5) = 5;
            newData(newData < -4) = -4;
            data{data_idx}(:, channel_idx) = newData;
        end
    else
        for data_idx = 1:numel(data)
            % rescale
            newData = data{data_idx}(:, channel_idx);
            newData = (newData - minimum(channel_idx)) / (maximum(channel_idx) - minimum(channel_idx));

            % clipping (this only has an effect for testing data)
            newData(newData > 5) = 5;
            newData(newData < -4) = -4;
            data{data_idx}(:, channel_idx) = newData;
        end
    end
end

rescaledData = data;
end
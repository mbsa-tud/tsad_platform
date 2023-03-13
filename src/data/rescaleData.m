function rescaledData = rescaleData(data, maximum, minimum)
%RESCALEDATA
%
% Rescales the data using the parameters maximum and minimum


numChannels = size(data{1, 1}, 2);

for channelIdx = 1:numChannels
    if maximum(channelIdx) == minimum(channelIdx)
        % If data is just a flat line, set mean to 0
        for dataIdx = 1:size(data, 1)
            % rescale
            newData = data{dataIdx, 1}(:, channelIdx);
            newData = newData - minimum(channelIdx);
    	    
            % clipping
            newData(newData > 5) = 5;
            newData(newData < -4) = -4;
            data{dataIdx, 1}(:, channelIdx) = newData;
        end
    else
        for dataIdx = 1:size(data, 1)
            % rescale
            newData = data{dataIdx, 1}(:, channelIdx);
            newData = (newData - minimum(channelIdx)) / (maximum(channelIdx) - minimum(channelIdx));

            % clipping
            newData(newData > 5) = 5;
            newData(newData < -4) = -4;
            data{dataIdx, 1}(:, channelIdx) = newData;
        end
    end
end

rescaledData = data;
end
function rescaledData = rescaleData(data, maximum, minimum)
%RESCALEDATA
%
% Rescales the data using the parameters maximum and minimum


numChannels = size(data{1, 1}, 2);

for j = 1:numChannels
    if maximum(j) == minimum(j)
        % If data is just a flat line, set mean to 0
        for i = 1:size(data, 1)
            % rescale
            newData = data{i, 1}(:, j);
            newData = newData - minimum(j);
    	    
            % clipping
            newData(newData > 5) = 5;
            newData(newData < -4) = -4;
            data{i, 1}(:, j) = newData;
        end
    else
        for i = 1:size(data, 1)
            % rescale
            newData = data{i, 1}(:, j);
            newData = (newData - minimum(j)) / (maximum(j) - minimum(j));

            % clipping
            newData(newData > 5) = 5;
            newData(newData < -4) = -4;
            data{i, 1}(:, j) = newData;
        end
    end
end

rescaledData = data;
end
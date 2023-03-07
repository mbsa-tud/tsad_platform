function rescaledData = rescaleData(data, maximum, minimum)
%RESCALEDATA
%
% Rescales the data using the parameters maximum and minimum


numChannels = size(data{1, 1}, 2);

for j = 1:numChannels
    if maximum(j) == minimum(j)
        % If data is just a flat line, set mean to 0
        for i = 1:size(data, 1)
            newData = data{i, 1};
            newData(:, j) = newData(:, j) - minimum(j);
            data{i, 1} = newData;
        end
    else
        for i = 1:size(data, 1)
            newData = data{i, 1};
            newData(:, j) = (newData(:, j) - minimum(j)) / (maximum(j) - minimum(j));
            data{i, 1} = newData;
        end
    end
end

rescaledData = data;
end
function rescaledData = rescaleData(data, maximum, minimum)
%RESCALEDATA
%
% Rescales the data using the parameters maximum and minimum


numChannels = size(data{1, 1}, 2);

for j = 1:numChannels
    if maximum(j) == minimum(j)
        % If training data is just a flat line, all points are set 
        % to 1 for the training dataset

        for i = 1:size(data, 1)
            newData = data{i, 1};
            if maximum(j) < 0
                newData(:, j) = newData(:, j) + (1 + abs(maximum(j)));
            elseif maximum(j) < 1
                newData(:, j) = newData(:, j) + (1 - maximum(j));
            else
                newData(:, j) = newData(:, j) - maximum(j);
            end
            data{i, 1} = newData;
        end
        continue;
    end

    for i = 1:size(data, 1)
        newData = data{i, 1};
        newData(:, j) = (newData(:, j) - minimum(j)) / (maximum(j) - minimum(j));
        data{i, 1} = newData;
    end
end

rescaledData = data;
end
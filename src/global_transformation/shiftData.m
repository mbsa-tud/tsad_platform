function augmentedData = shiftData(rawData, maximum, minimum, level)
%SHIFTDATA
%
% Shift the data by (maximum - minimum) * level

numChannels = size(rawData{1, 1}, 2);

for i = 1:size(rawData, 1)
    currentData = rawData{i, 1};
    for j = 1:numChannels
        shiftValue = maximum(j)  * level/100;
        currentData(:, j) = currentData(:, j) + shiftValue;
    end
    rawData{i, 1} = currentData;
end

augmentedData = rawData;
end

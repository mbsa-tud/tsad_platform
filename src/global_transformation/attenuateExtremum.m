function augmentedData = attenuateExtremum(rawData, level)
%ATTENUATEEXTREMUM
%
% Attenuate the extremum of the data

for i = 1:size(rawData, 1)
    currentData = rawData{i, 1};
    meanValue = mean(currentData);
    for j = 1:size(currentData, 1)
        if currentData(j) > meanValue
            currentData(j) = currentData(j) * level;
        else
            currentData(j) = currentData(j) / level;
        end
    end
    rawData{i, 1} = currentData;
end

augmentedData = rawData;
end
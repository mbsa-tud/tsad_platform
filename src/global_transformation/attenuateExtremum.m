function augmentedData = attenuateExtremum(rawData, maximum, minimum, level)
%ATTENUATEEXTREMUM Attenuate the extremum of the data

level=level/100;

for data_idx = 1:size(rawData, 1)
    currentData = rawData{data_idx, 1};
    moyenne=mean(currentData);
    
    for j = 1:size(currentData, 1)
        if ~(level==0)        
            currentData(j) = currentData(j)*exp(- (currentData(j)-moyenne)*level);
        end
    end
    rawData{data_idx, 1} = currentData;
end

augmentedData = rawData;
end
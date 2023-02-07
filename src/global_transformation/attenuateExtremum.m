function augmentedData = attenuateExtremum(rawData,maximums,minimums,level)
%ATTENUATEEXTREMUM
%
% Attenuate the extremum of the data
level=level/100;
for i = 1:size(rawData, 1)
    currentData = rawData{i, 1};
    
    
    for j = 1:size(currentData, 1)
        ref=currentData(j)/max([abs(maximums), abs(minimums)]);
        if ~(level==0)

                    currentData(j) =currentData(j)* exp(-ref*level);
                

        end
    end
    rawData{i, 1} = currentData;
end

augmentedData = rawData;
end
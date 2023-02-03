function augmentedData = attenuateExtremum(rawData, level)
%ATTENUATEEXTREMUM
%
% Attenuate the extremum of the data

for i = 1:size(rawData, 1)
    currentData = rawData{i, 1};
    meanValue = mean(currentData);
    for j = 1:size(currentData, 1)
        if ~(level==0)

            if currentData(j)>0
                if currentData(j) > meanValue
                    currentData(j) =currentData(j)*(level/100);
                else
                    currentData(j) =currentData(j)/ (level/100);
                end
            else
                if currentData(j) > meanValue
                    currentData(j) =currentData(j)/(level/100);
                else
                    currentData(j) =currentData(j)* (level/100);
                end

            end
        end
    end
    rawData{i, 1} = currentData;
end

augmentedData = rawData;
end
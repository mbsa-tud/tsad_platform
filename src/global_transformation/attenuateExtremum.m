function augmentedData = attenuateExtremum(rawData,maximums,minimums,level)
%ATTENUATEEXTREMUM Attenuate the extremum of the data
moyenne=0;
level=level/100;
for i = 1:size(rawData, 1)
    currentData = rawData{i, 1};
    moyenne=mean(currentData);
    
    for j = 1:size(currentData, 1)
        
        if ~(level==0)        

                    currentData(j) =currentData(j)*exp(- (currentData(j)-moyenne)*level);
                

        end
    end
    rawData{i, 1} = currentData;
end

augmentedData = rawData;
end
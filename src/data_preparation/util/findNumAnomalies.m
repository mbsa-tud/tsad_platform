function numAnoms = findNumAnomalies(labels)
%FINDNUMANOMALIES Finds number of anomalies (=number of consecutive regions
%with value of 1)

numAnoms = 0;
i = 1;
while i <= length(labels)
    if labels(i) == 1
        k = 0;
        while labels(k + i) == 1
            k = k + 1;
            if (k + i) > length(labels)
                break;
            end
        end
        i = i + k;
        numAnoms = numAnoms + 1;
    end
    i = i + 1;
end
if numAnoms == 0
    numAnoms = 1;
end
end


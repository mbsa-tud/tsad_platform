function index = getAnomalyIndices(data)
%GETANOMALYINDICES Get indices for anomalies for plots

try
    shift = [0; data(1:end-1)];
catch
    shift = [0 data(1:end-1)];
end
change = shift ~= data;
begin = find(data & change);
endI = find(change & shift) -1;
if length(endI) == length(begin) -1
    try
        endI = [endI length(data)];
    catch
        endI = [endI; length(data)];
    end
end
if size(begin, 1) ~= 1
    begin = begin';
end
if size(endI, 1) ~= 1
    endI = endI';
end
index = [begin; endI; endI; begin];
end
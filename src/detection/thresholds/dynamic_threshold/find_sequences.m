function [indices, max_below] = find_sequences(errors, epsilon, anomaly_padding)
% Find sequences of values that are above epsilon.
% This is done following this steps:
% * create a boolean mask that indicates which values are above epsilon.
% * mark certain range of errors around True values with a True as well.
% * shift this mask by one place, filing the empty gap with a False.
% * compare the shifted mask with the original one to see if there are changes.
% * Consider a sequence start any point which was true and has changed.
% * Consider a sequence end any point which was false and has changed.
above = (errors > epsilon);
index_above = find(above == 1);
for i = 1:length(index_above)    
    above(max(1, index_above(i) - anomaly_padding):min(index_above(i) + anomaly_padding + 1, length(above))) = true;    
end
try
    shift = [0 above(1:end-1)];
catch
    shift = [0; above(1:end-1)];
end

change = above ~= logical(shift);
if all(above)
    max_below = 0;
else
    max_below = max(errors(~above));
end

starts = find(above & change);
ends = find(~above & change)-1;

if length(ends) == length(starts) - 1
    try
        ends = [ends length(above)];
    catch 
        ends = [ends; length(above)];
    end
end
try
indices = ([starts, ends]);
catch
    indices = ([starts, ends']);
end
    
end
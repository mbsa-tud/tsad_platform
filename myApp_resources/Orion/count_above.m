function [total_above,total_consecutive] = count_above(errors, epsilon)
% Count number of errors and continuous sequences above epsilon.
% Continuous sequences are counted by shifting and counting the number
% of positions where there was a change and the original value was true,
% which means that a sequence started at that position.
above = errors > epsilon;
total_above = length(errors(above));

try
    shift = [above(2:end) 0];
catch
    shift = [above(2:end); 0];
end

change = above ~= shift;

total_consecutive = sum(above & change);
end


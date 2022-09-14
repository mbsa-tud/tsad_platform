function max_err = prune_anomalies(max_errors, min_percent)
% Prune anomalies to mitigate false positives.
% This is done by following these steps:
% * Shift the errors 1 negative step to compare each value with the next one.
% * Drop the last row, which we do not want to compare.
% * Calculate the percentage increase for each row.
% * Find rows which are below ``min_percent``.
% * Find the index of the latest of such rows.
% * Get the values of all the sequences above that index.

next_error = max_errors(2:end,:);
max_error = max_errors(1:end-1,:);

increase = (max_error(:,3) - next_error(:,3)) ./ max_error(:,3);
too_small = increase < min_percent;

if all(too_small)   
    max_err = max_errors;
else
    last_index = find(~too_small,1,'last');
    max_err = max_errors(1: last_index,:);
end




end
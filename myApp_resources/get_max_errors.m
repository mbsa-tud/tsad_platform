function max_err_array = get_max_errors(errors, sequences, max_below)
% Get the maximum error for each anomalous sequence.
% Also add a row with the max error which was not considered anomalous.
% Table containing a ``max_error`` column with the maximum error of each
% sequence and the columns ``start`` and ``stop`` with the corresponding start and stop
% indexes, sorted descendingly by the maximum error.
max_errors = [max_below,-1,-1];

    for i = 1:size(sequences,1)
        start = sequences(i,1);
        stop = sequences(i,2);
        sequence_errors = errors(start: stop);
        max_errors(i,:) = [start stop max(sequence_errors)];        
    end
    [sorted_err, I] = sort(max_errors(:,3), 'descend');
    max_errors = max_errors(I,:);
    max_err_array = max_errors;
end
    
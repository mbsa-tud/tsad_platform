function window_sequences = find_window_sequences(window, z_range, anomaly_padding, min_percent, window_start, fixed_threshold)
% Find sequences of values that are anomalous.
% We first find the threshold for the window, then find all sequences above that threshold.
% After that, we get the max errors of the sequences and prune the anomalies. Lastly, the
% score of the anomalies is computed.
if fixed_threshold
    threshold = fixed_threshold(window);
else
    threshold = find_threshold(window, z_range);
end
[window_sequences, max_below] = find_sequences(window, threshold, anomaly_padding);
max_errors = get_max_errors(window, window_sequences, max_below);
pruned_anomalies = prune_anomalies(max_errors, min_percent);
window_sequences = compute_scores(pruned_anomalies, window, threshold, window_start);

end
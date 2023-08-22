function anomalies = compute_scores(pruned_anomalies, errors, threshold, window_start)
% Compute the score of the anomalies.
% Calculate the score of the anomalies proportional to the maximum error in the sequence
% and add window_start timestamp to make the index absolute.
anomalies = [];
denominator = mean(errors) + std(errors);

for i = 1:size(pruned_anomalies,1)
    max_error = pruned_anomalies(i,3);
    score = (max_error - threshold) / denominator;
    anomalies(i,:) = [pruned_anomalies(i,1)+ window_start pruned_anomalies(i,2) + window_start score];
end


end
function merged_anom = merge_sequences(sequences)
% Merge consecutive and overlapping sequences.
% We iterate over a list of start, end, score triples and merge together
% overlapping or consecutive sequences.
% The score of a merged sequence is the average of the single scores,
% weighted by the length of the corresponding sequences.
if isempty(sequences)
    merged_anom = [];
end
[~, I] = sort(sequences(:,1));
sorted_sequences = sequences(I,:);
new_sequences = [sorted_sequences(1,:)];
score = [sorted_sequences(1,3)];
weights = [sorted_sequences(1,2) - sorted_sequences(1,1)];

for i = 2:length(sorted_sequences)
    prev_sequence = new_sequences(i-1,:);
    
    if sorted_sequences(i,1) <= prev_sequence(2) + 1
        score = [score sorted_sequences(i,3)];
        weights = [weights sorted_sequences(i,2) - sorted_sequences(i,1)];
        weighted_average = (score .*weights)/sum(weights);
        new_sequences = [new_sequences;prev_sequence(1) max(prev_sequence(2), sorted_sequences(i,2)) weighted_average];
    else
        score = [sorted_sequences(i,3)];
        weights = [sorted_sequences(i,2) - sorted_sequences(i,1)];
        new_sequences = [new_sequences; sorted_sequences(i,:)];
    end
    merged_anom = new_sequences;
end
end
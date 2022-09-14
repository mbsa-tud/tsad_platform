function anomalyScores = run_MERLIN(data, minL, maxL, numAnoms)
r = 5;
display_meta_info = false;
numLengths = maxL - minL + 1;
disc_dist_a = zeros(numLengths, numAnoms);
disc_loc_a = zeros(numLengths, numAnoms);
lengths = minL:maxL;
for lengthIndex = 1:numLengths
    while true
        [temp_disc_loc_a, temp_disc_dist_a,  ~] = discord_discovery_gemm3(data, lengths(lengthIndex), r, display_meta_info);            
        
        if length(temp_disc_dist_a) >= numAnoms
            break;
        else
            r = r*(lengths(lengthIndex)-1)/lengths(lengthIndex);
        end
    end
    
    if length(temp_disc_loc_a) > 1
        [temp_disc_dist_a, idx] = maxk(temp_disc_dist_a, numAnoms);
        temp_disc_loc_a = temp_disc_loc_a(idx);
    end
    disc_dist_a(lengthIndex, :) = temp_disc_dist_a;
    disc_loc_a(lengthIndex, :) = temp_disc_loc_a;
    r = temp_disc_dist_a(1);
end

anomalyScores = zeros(size(data, 1), 1);

for i = 1:numAnoms
    mean_disc_loc = floor(mean(disc_loc_a(:, i)));
    anomalyScores(mean_disc_loc:(mean_disc_loc + floor((minL + maxL) / 2))) = 1;
end
end

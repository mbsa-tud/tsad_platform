function threshold = find_threshold(errors, z_range)
% Find the ideal threshold.
% The ideal threshold is the one that minimizes the z_cost function. Scipy.fmin is used
% to find the minimum, using the values from z_range as starting points.
meann = mean(errors);
stdd = std(errors);

min_z = min(z_range);
max_z = max(z_range);
best_z = min_z;
best_cost = Inf;
% for z = min_z:max_z
%     best = fmin(z_cost, z, args=(errors, meann, stdd), full_output=True, disp=False)
%     z, cost = best[0:2]
%     if cost < best_cost:
%         best_z = z[0]
%     end
% end
        
for z = min_z:max_z
    cost = z_cost(z, errors, meann, stdd);    
    if cost < best_cost
        best_z = z;
    end
end

threshold = meann + best_z * stdd;
end


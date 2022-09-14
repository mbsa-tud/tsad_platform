function cost = z_cost(z, errors, meann, stdd)
% Compute how bad a z value is.
% The original formula is::
% (delta_mean/mean) + (delta_std/std)
% ------------------------------------------------------
% number of errors above + (number of sequences above)^2
% which computes the "goodness" of `z`, meaning that the higher the value
% the better the `z`.
% In this case, we return this value inverted (we make it negative), to convert
% it into a cost function, as later on we will use scipy.fmin to minimize it.
epsilon = meann + z * stdd;

[delta_mean, delta_std] = deltas(errors, epsilon, meann, stdd);
[above, consecutive] = count_above(errors, epsilon);

numerator = -(delta_mean / meann + delta_std / stdd);
denominator = above + consecutive^2;

if denominator == 0
    cost = inf;
else    
    cost = numerator / denominator;
end



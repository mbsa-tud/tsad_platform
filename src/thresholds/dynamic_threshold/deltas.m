function [delta_mean, delta_std] = deltas(errors, epsilon, meann, stdd)
%Compute mean and std deltas.
below = errors(errors <= epsilon);
if isempty(below)
    delta_mean = 0; delta_std = 0;
else
    delta_mean = meann - mean(below); delta_std = stdd - std(below);
end

end


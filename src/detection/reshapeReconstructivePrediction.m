function pred = reshapeReconstructivePrediction(data, windowSize)
c = [];
if iscell(data)
    for i = 1:size(data, 1)
        c(:, i) = data{i, :};
    end
else
    for i = 1:size(data, 1)
        c(:, i) = data(i, :);
    end
end
b = [];
c = flip(c);
for i = 1:(size(c, 2) - windowSize)
    % TODO: mean or meadian here?
    b(i, :) = median(diag(c(:, i:(i + windowSize - 1))));
end
pred = b;
end

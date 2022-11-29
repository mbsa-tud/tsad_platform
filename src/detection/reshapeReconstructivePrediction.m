function pred = reshapeReconstructivePrediction(prediction, windowSize)
%RESHAPERECONSTRUCTIVEPREDICTION
%
% Calculates the median anomaly score for all overlapping subsequences for
% the reconstructive DL models and ML algorithms

if iscell(prediction)
    if size(prediction{1, 1}, 1) > 1
        isMultivariate = true;
    else
        isMultivariate = false;
    end
else
    isMultivariate = false;
end

if ~isMultivariate
    data = prediction;

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
        b(i, :) = median(diag(c(:, i:(i + windowSize - 1))));
    end
    pred = b;
else
    pred = zeros((size(prediction, 1) - windowSize), size(prediction{1, 1}, 1));
    
    for h = 1:size(prediction{1, 1}, 1)
        data = zeros(size(prediction, 1), size(prediction{1, 1}, 2));
        for j = 1:size(prediction, 1)
            data(j, :) = prediction{j, 1}(h, :);
        end
    
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
            b(i, :) = median(diag(c(:, i:(i + windowSize - 1))));
        end
        pred(:, h) = b;
    end
end
end

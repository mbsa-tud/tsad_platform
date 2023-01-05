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
    if size(prediction, 2) > windowSize
        isMultivariate = true;
    else
        isMultivariate = false;
    end
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
    if iscell(prediction)
        numChannels = size(prediction{1, 1}, 1);
        pred = zeros((size(prediction, 1) - windowSize), numChannels);
        
        for h = 1:numChannels
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
    else
        numChannels = round(size(prediction, 2) / windowSize);
        pred = zeros((size(prediction, 1) - windowSize), numChannels);
        
        for h = 1:numChannels
            data = zeros(size(prediction, 1), windowSize);
            for j = 1:size(prediction, 1)
                data(j, :) = prediction(j, ((h - 1) * windowSize + 1):((h - 1) * windowSize + windowSize));
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
end

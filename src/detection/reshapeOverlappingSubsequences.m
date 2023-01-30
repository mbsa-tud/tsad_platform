function reshapedPrediction = reshapeReconstructivePrediction(prediction, isMultivariate, windowSize, dataType)
%RESHAPERECONSTRUCTIVEPREDICTION
%
% Calculates the median anomaly score for all overlapping subsequences for
% the reconstructive DL models and ML algorithms

if ~isMultivariate
    if dataType == 1
        data = prediction;

        c = [];
        for i = 1:size(data, 1)
            c(:, i) = data(i, :);
        end
        b = [];
        c = flip(c);
        for i = 1:(size(c, 2) - windowSize)
            b(i, :) = median(diag(c(:, i:(i + windowSize - 1))));
        end
        reshapedPrediction = b;
    elseif dataType == 2
        data = prediction;

        c = [];
        for i = 1:size(data, 1)
            c(:, i) = data{i, 1};
        end

        b = [];
        c = flip(c);
        for i = 1:(size(c, 2) - windowSize)
            b(i, :) = median(diag(c(:, i:(i + windowSize - 1))));
        end
        reshapedPrediction = b;
    elseif dataType == 3
        data = prediction;

        c = [];
        for i = 1:size(data, 1)
            c(:, i) = data{i, :}';
        end

        b = [];
        c = flip(c);
        for i = 1:(size(c, 2) - windowSize)
            b(i, :) = median(diag(c(:, i:(i + windowSize - 1))));
        end
        reshapedPrediction = b;
    end
else
    if dataType == 1
        numChannels = round(size(prediction, 2) / windowSize);
        reshapedPrediction = zeros((size(prediction, 1) - windowSize), numChannels);
        
        for h = 1:numChannels
            data = zeros(size(prediction, 1), windowSize);
            for j = 1:size(prediction, 1)
                data(j, :) = prediction(j, ((h - 1) * windowSize + 1):((h - 1) * windowSize + windowSize));
            end
        
            c = [];
            for i = 1:size(data, 1)
                c(:, i) = data(i, :);
            end
            b = [];
            c = flip(c);
            for i = 1:(size(c, 2) - windowSize)
                b(i, :) = median(diag(c(:, i:(i + windowSize - 1))));
            end
            reshapedPrediction(:, h) = b;
        end
    elseif dataType == 2
        numChannels = size(prediction{1, 1}, 1);
        reshapedPrediction = zeros((size(prediction, 1) - windowSize), numChannels);
        
        for h = 1:numChannels
            data = zeros(size(prediction, 1), size(prediction{1, 1}, 2));
            for j = 1:size(prediction, 1)
                data(j, :) = prediction{j, 1}(h, :);
            end
        
            c = [];
            for i = 1:size(data, 1)
                c(:, i) = data(i, :);
            end
            b = [];
            c = flip(c);
            for i = 1:(size(c, 2) - windowSize)
                b(i, :) = median(diag(c(:, i:(i + windowSize - 1))));
            end
            reshapedPrediction(:, h) = b;
        end        
    elseif dataType == 3
        numChannels = size(prediction{1, 1}, 2);
        reshapedPrediction = zeros((size(prediction, 1) - windowSize), numChannels);
        
        for h = 1:numChannels
            data = zeros(size(prediction, 1), size(prediction{1, 1}, 1));
            for j = 1:size(prediction, 1)
                data(j, :) = prediction{j, 1}(:, h)';
            end
        
            c = [];
            for i = 1:size(data, 1)
                c(:, i) = data(i, :);
            end
            b = [];
            c = flip(c);
            for i = 1:(size(c, 2) - windowSize)
                b(i, :) = median(diag(c(:, i:(i + windowSize - 1))));
            end
            reshapedPrediction(:, h) = b;
        end        
    end
end
end

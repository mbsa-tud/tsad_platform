function reshapedPrediction = mergeOverlappingSubsequences(options, prediction)
%mergeOverlappingSubsequences
%
% Calculates the median anomaly score for all overlapping subsequences for
% the reconstructive DL models

switch options.model
    case "Your model"
    otherwise
        windowSize = options.hyperparameters.data.windowSize.value;
        dataType = options.dataType;

        if dataType == 1
            numChannels = round(size(prediction, 2) / windowSize);
            reshapedPrediction = zeros((size(prediction, 1) - windowSize), numChannels);
            
            for h = 1:numChannels
                data = zeros(size(prediction, 1), windowSize);
                for j = 1:size(prediction, 1)
                    data(j, :) = prediction(j, ((h - 1) * windowSize + 1):((h - 1) * windowSize + windowSize));
                end
            
                reshapedPrediction(:, h) = mergeSequences(data, windowSize);
            end
        elseif dataType == 2
            numChannels = size(prediction{1, 1}, 1);
            reshapedPrediction = zeros((size(prediction, 1) - windowSize), numChannels);
            
            for h = 1:numChannels
                data = zeros(size(prediction, 1), size(prediction{1, 1}, 2));
                for j = 1:size(prediction, 1)
                    data(j, :) = prediction{j, 1}(h, :);
                end
            
                reshapedPrediction(:, h) = mergeSequences(data, windowSize);
            end
        end
end
end

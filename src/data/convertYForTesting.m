function Y = convertYForTesting(Y, type, isMultivariate, windowSize)
%CONVERTYFORTESTING
% Convert Y to enable calculation of anomaly Scores, this is needed for the
% validation data for DL models

if isMultivariate
    if strcmp(type, 'reconstructive')
        if iscell(Y{1, 1})
            numChannels = size(Y{1, 1}{1, 1}, 1);
            numObservations = size(Y{1, 1}, 1) - windowSize;
        
            Y_tmp = zeros(numObservations, numChannels);
    
            for i = 1:numObservations
                Y_tmp(i, :) = Y{1, 1}{i, 1}(:, end)';
            end
            Y = {Y_tmp};
        else
            numChannels = round(size(Y{1, 1}, 2) / windowSize);
            numObservations = size(Y{1, 1}, 1) - windowSize;
        
            Y_tmp = zeros(numObservations, numChannels);
    
            for i = 1:numObservations
                Y_tmp(i, :) = Y{1, 1}(i, windowSize:windowSize:size(Y{1, 1}, 2));
            end
            Y = {Y_tmp};
        end
    end
else
    numChannels = size(Y, 2);
    if strcmp(type, 'reconstructive')
        for i = 1:numChannels
            if iscell(Y{1, i})
                Y{1, i} = cell2mat(Y{1, i});
                Y{1, i} = Y{1, i}(1:(end - windowSize), end);
            else
                Y{1, i} = Y{1, i}(1:(end - windowSize), end);
            end
        end
    else
        if iscell(Y{1, 1})
            for i = 1:numChannels
                Y{1, i} = cell2mat(Y{1, i});
            end
        end
    end
end
end
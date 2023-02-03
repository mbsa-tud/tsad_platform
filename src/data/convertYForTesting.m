function Y = convertYForTesting(options, Y)
%CONVERTYFORTESTING
% Convert Y to enable calculation of anomaly Scores, this is needed for the
% validation data for DL models

switch options.model
    case 'Your model'
    otherwise
        if options.isMultivariate
            if strcmp(options.modelType, 'reconstructive')
                if options.dataType == 1
                    numChannels = round(size(Y{1, 1}, 2) / options.hyperparameters.data.windowSize.value);
                    numObservations = size(Y{1, 1}, 1) - options.hyperparameters.data.windowSize.value;
                
                    Y_tmp = zeros(numObservations, numChannels);
            
                    for i = 1:numObservations
                        Y_tmp(i, :) = Y{1, 1}(i, options.hyperparameters.data.windowSize.value:options.hyperparameters.data.windowSize.value:size(Y{1, 1}, 2));
                    end
                    Y = {Y_tmp};
                elseif options.dataType == 2
                    numChannels = size(Y{1, 1}{1, 1}, 1);
                    numObservations = size(Y{1, 1}, 1) - options.hyperparameters.data.windowSize.value;
                
                    Y_tmp = zeros(numObservations, numChannels);
            
                    for i = 1:numObservations
                        Y_tmp(i, :) = Y{1, 1}{i, 1}(:, end)';
                    end
                    Y = {Y_tmp};
                elseif options.dataType == 3
                    %TODO: this was never tested
                    numChannels = size(Y{1, 1}{1, 1}, 2);
                    numObservations = size(Y{1, 1}, 1) - options.hyperparameters.data.windowSize.value;
                
                    Y_tmp = zeros(numObservations, numChannels);
            
                    for i = 1:numObservations
                        Y_tmp(i, :) = Y{1, 1}{i, 1}(end, :);
                    end
                    Y = {Y_tmp};
                end
            else
                if iscell(Y{1, 1})
                    numChannels = size(Y{1, 1}{1, 1}, 1);
                    numObservations = size(Y{1, 1}, 1);
        
                    Y_tmp = zeros(numObservations, numChannels);
        
                    for i = 1:numObservations
                        Y_tmp(i, :) = Y{1, 1}{i, 1}';
                    end
        
                    Y = {Y_tmp};
                end
            end
        else
            numChannels = size(Y, 2);
            if strcmp(options.modelType, 'reconstructive')
                for i = 1:numChannels
                    if options.dataType == 1
                        Y{1, i} = Y{1, i}(1:(end - options.hyperparameters.data.windowSize.value), end);
                    elseif options.dataType == 2
                        Y{1, i} = cell2mat(Y{1, i});
                        Y{1, i} = Y{1, i}(1:(end - options.hyperparameters.data.windowSize.value), end);
                    elseif options.dataType == 3
                        %TODO: this was never tested
                        Y{1, i} = cell2mat(Y{1, i});
                        Y{1, i} = Y{1, i}(options.hyperparameters.data.windowSize.value:options.hyperparameters.data.windowSize.value:end, 1);
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
end
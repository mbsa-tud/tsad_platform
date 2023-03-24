function [preprocessedTrainingData, preprocessedTestingData, preprocParams] = preprocessData(rawTrainingData, rawTestingData, method, usePrevious, paramsPrevious)
% PREPROCESSDATA Preprocesses the data with the specified method

preprocessedTrainingData  = [];
preprocessedTestingData = [];

preprocParams.method = method;
preprocParams.minimum = [];
preprocParams.maximum = [];
preprocParams.mu = [];
preprocParams.sigma = [];

switch method
    case 'Rescale [0, 1]'
        if ~isempty(rawTrainingData)
            if usePrevious
                preprocParams.maximum = paramsPrevious.maximum;
                preprocParams.minimum = paramsPrevious.minimum;
            else
                numFiles = size(rawTrainingData, 1);
                numChannels = size(rawTrainingData{1, 1}, 2);
    
                maxima = zeros(numFiles, numChannels);
                minima = zeros(numFiles, numChannels);
                for data_idx = 1:numFiles
                    maxima(data_idx, :) =  max(rawTrainingData{data_idx, 1}, [], 1);
                    minima(data_idx, :) =  min(rawTrainingData{data_idx, 1}, [], 1);
                end
                preprocParams.maximum = max(maxima, [], 1);
                preprocParams.minimum = min(minima, [], 1);
            end

            preprocessedTrainingData = rescaleData(rawTrainingData, preprocParams.maximum, preprocParams.minimum);
        end
        if ~isempty(rawTestingData)
            if usePrevious
                preprocParams.maximum = paramsPrevious.maximum;
                preprocParams.minimum = paramsPrevious.minimum;
            else
                if isempty(preprocParams.maximum)
                    numFiles = size(rawTestingData, 1);
                    numChannels = size(rawTestingData{1, 1}, 2);
    
                    maxima = zeros(numFiles, numChannels);
                    minima = zeros(numFiles, numChannels);
                    for data_idx = 1:numFiles
                        maxima(data_idx, :) =  max(rawTestingData{data_idx, 1}, [], 1);
                        minima(data_idx, :) =  min(rawTestingData{data_idx, 1}, [], 1);
                    end
                    preprocParams.maximum = max(maxima, [], 1);
                    preprocParams.minimum = min(minima, [], 1);
                end
            end
            preprocessedTestingData = rescaleData(rawTestingData, preprocParams.maximum, preprocParams.minimum);
        end
    case 'Standardize'
        if ~isempty(rawTrainingData)
            if usePrevious
                preprocParams.mu = paramsPrevious.mu;
                preprocParams.sigma = paramsPrevious.sigma;
            else                
                fullData = [];
                for data_idx = 1:size(rawTrainingData, 1)
                    fullData = [fullData; rawTrainingData{data_idx, 1}];
                end
                [~, preprocParams.mu, preprocParams.sigma] = zscore(fullData, 0, 1);
            end

            preprocessedTrainingData = standardizeData(rawTrainingData, preprocParams.mu, preprocParams.sigma);
        end
        if ~isempty(rawTestingData)
            if usePrevious
                preprocParams.mu = paramsPrevious.mu;
                preprocParams.sigma = paramsPrevious.sigma;
            else
                if isempty(preprocParams.mu)    
                    fullData = [];
                    for data_idx = 1:size(rawTestingData, 1)
                        fullData = [fullData; rawTestingData{data_idx, 1}];
                    end
                    [~, preprocParams.mu, preprocParams.sigma] = zscore(fullData, 0, 1);
                end
            end
            
            preprocessedTestingData = standardizeData(rawTestingData, preprocParams.mu, preprocParams.sigma);
        end
    case 'Raw Data'
        preprocessedTrainingData = rawTrainingData;
        preprocessedTestingData = rawTestingData;
end


function [preprocessedTrainingData, preprocessedTestingData, maximum, minimum, mu, sigma] = preprocessData(rawTrainingData, rawTestingData, method, usePrevious, params)
% PREPROCESSDATA
%
% Preprocessed the data

preprocessedTrainingData  = [];
preprocessedTestingData = [];
minimum = [];
maximum = [];
mu = [];
sigma = [];

switch method
    case 'Rescale [0, 1]'
        if ~isempty(rawTrainingData)
            if usePrevious
                maximum = params.maximum;
                minimum = params.minimum;
            else
                numFiles = size(rawTrainingData, 1);
                numChannels = size(rawTrainingData{1, 1}, 2);
    
                maxima = zeros(numFiles, numChannels);
                minima = zeros(numFiles, numChannels);
                for i = 1:numFiles
                    maxima(i, :) =  max(rawTrainingData{i, 1}, [], 1);
                    minima(i, :) =  min(rawTrainingData{i, 1}, [], 1);
                end
                maximum = max(maxima, [], 1);
                minimum = min(minima, [], 1);
            end

            preprocessedTrainingData = rescaleData(rawTrainingData, maximum, minimum);
        end
        if ~isempty(rawTestingData)
            if usePrevious
                maximum = params.maximum;
                minimum = params.minimum;
            else
                if isempty(maximum)
                    numFiles = size(rawTestingData, 1);
                    numChannels = size(rawTestingData{1, 1}, 2);
    
                    maxima = zeros(numFiles, numChannels);
                    minima = zeros(numFiles, numChannels);
                    for i = 1:numFiles
                        maxima(i, :) =  max(rawTestingData{i, 1}, [], 1);
                        minima(i, :) =  min(rawTestingData{i, 1}, [], 1);
                    end
                    maximum = max(maxima, [], 1);
                    minimum = min(minima, [], 1);
                end
            end
            preprocessedTestingData = rescaleData(rawTestingData, maximum, minimum);
        end
    case 'Standardize'
        if ~isempty(rawTrainingData)
            if usePrevious
                mu = params.mu;
                sigma = params.sigma;
            else                
                fullData = [];
                for i = 1:size(rawTrainingData, 1)
                    fullData = [fullData; rawTrainingData{i, 1}];
                end
                [~, mu, sigma] = zscore(fullData, 0, 1);
            end

            preprocessedTrainingData = standardizeData(rawTrainingData, mu, sigma);
        end
        if ~isempty(rawTestingData)
            if usePrevious
                mu = params.mu;
                sigma = params.sigma;
            else
                if isempty(mu)    
                    fullData = [];
                    for i = 1:size(app.rawTestingData, 1)
                        fullData = [fullData; rawTestingData{i, 1}];
                    end
                    [~, mu, sigma] = zscore(fullData, 0, 1);
                end
            end
            
            preprocessedTestingData = standardizeData(rawTestingData, mu, sigma);
        end
    case 'Raw Data'
        preprocessedTrainingData = rawTrainingData;
        preprocessedTestingData = rawTestingData;
end


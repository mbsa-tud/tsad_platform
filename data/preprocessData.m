function [preprocessedTrainingData, preprocessedTestingData, preprocParams] = preprocessData(rawTrainingData, rawTestingData, method, usePrevious, paramsPrevious)
% PREPROCESSDATA
%
% Preprocessed the data

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
                for i = 1:numFiles
                    maxima(i, :) =  max(rawTrainingData{i, 1}, [], 1);
                    minima(i, :) =  min(rawTrainingData{i, 1}, [], 1);
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
                    for i = 1:numFiles
                        maxima(i, :) =  max(rawTestingData{i, 1}, [], 1);
                        minima(i, :) =  min(rawTestingData{i, 1}, [], 1);
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
                for i = 1:size(rawTrainingData, 1)
                    fullData = [fullData; rawTrainingData{i, 1}];
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
                    for i = 1:size(app.rawTestingData, 1)
                        fullData = [fullData; rawTestingData{i, 1}];
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


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
    case "min_max_normalization"
        if ~isempty(rawTrainingData)
            if usePrevious
                preprocParams.maximum = paramsPrevious.maximum;
                preprocParams.minimum = paramsPrevious.minimum;
            else
                fullData = [];
                for data_idx = 1:numel(rawTrainingData)
                    fullData = [fullData; rawTrainingData{data_idx}];
                end
                preprocParams.maximum = max(fullData);
                preprocParams.minimum = min(fullData);
            end

            preprocessedTrainingData = rescaleData(rawTrainingData, preprocParams.maximum, preprocParams.minimum);
        end
        if ~isempty(rawTestingData)
            if usePrevious
                preprocParams.maximum = paramsPrevious.maximum;
                preprocParams.minimum = paramsPrevious.minimum;
            else
                if isempty(preprocParams.maximum)
                    fullData = [];
                    for data_idx = 1:numel(rawTestingData)
                        fullData = [fullData; rawTestingData{data_idx}];
                    end
                    preprocParams.maximum = max(fullData);
                    preprocParams.minimum = min(fullData);
                end
            end
            
            preprocessedTestingData = rescaleData(rawTestingData, preprocParams.maximum, preprocParams.minimum);
        end
    case "standardization"
        if ~isempty(rawTrainingData)
            if usePrevious
                preprocParams.mu = paramsPrevious.mu;
                preprocParams.sigma = paramsPrevious.sigma;
            else                
                fullData = [];
                for data_idx = 1:numel(rawTrainingData)
                    fullData = [fullData; rawTrainingData{data_idx}];
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
                    for data_idx = 1:numel(rawTestingData)
                        fullData = [fullData; rawTestingData{data_idx}];
                    end
                    [~, preprocParams.mu, preprocParams.sigma] = zscore(fullData, 0, 1);
                end
            end
            
            preprocessedTestingData = standardizeData(rawTestingData, preprocParams.mu, preprocParams.sigma);
        end
    case "none"
        preprocessedTrainingData = rawTrainingData;
        preprocessedTestingData = rawTestingData;
    otherwise
        error("unknown preprocessing method");
end


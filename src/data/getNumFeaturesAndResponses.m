function [numFeatures, numResponses] = getNumFeaturesAndResponses(XTrain, YTrain, isMultivariate, modelType, dataType)
if ~isMultivariate
    if dataType == 1
        numFeatures = size(XTrain, 2);
    else
        numFeatures = size(XTrain{1, 1}, 1);
    end
    
    if dataType == 1
        numResponses = size(YTrain, 2);
    else
        if strcmp(modelType, 'Reconstructive')
            numResponses = size(YTrain{1, 1}, 1);
        else
            numResponses = 1;
        end
    end        
else
    numFeatures = size(XTrain{1, 1}, 1);

    if strcmp(modelType, 'Reconstructive')
        numResponses = numFeatures;
    else
        numResponses = 1;
    end
end
end
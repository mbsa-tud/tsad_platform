function [numFeatures, numResponses] = getNumFeaturesAndResponses(XTrain, YTrain, modelType, dataType)
if strcmp(modelType, 'reconstructive')
    if dataType == 1
        numFeatures = size(XTrain, 2);
        numResponses = numFeatures;
    elseif dataType == 2
        numFeatures = size(XTrain{1, 1}, 1);
        numResponses = numFeatures;
    end
else
    if dataType == 1
        numFeatures = size(XTrain, 2);
        numResponses = size(YTrain, 2);
    elseif dataType == 2
        numFeatures = size(XTrain{1, 1}, 1);
        numResponses = numFeatures;
    elseif dataType == 3
        numFeatures = size(XTrain{1, 1}, 1);
        numResponses = 1;
    end
end
end
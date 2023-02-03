function [Mdl, MdlInfo] = trainDNN(options, XTrain, YTrain, XVal, YVal, trainingPlots)
%TRAINDNN
%
% Train DL models

switch options.model
    case 'Your model'
    otherwise
        [numFeatures, numResponses] = getNumFeaturesAndResponses(XTrain, YTrain, options.modelType, options.dataType);

        layers = getLayers(options, numFeatures, numResponses);
        trainOptions = getOptions(options, XVal, YVal, size(XTrain, 1), trainingPlots);
        
        [Mdl, MdlInfo] = trainNetwork(XTrain, YTrain, layers, trainOptions);
end
end
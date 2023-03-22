function [Mdl, MdlInfo] = trainDNN(modelOptions, XTrain, YTrain, XVal, YVal, trainingPlots)
%TRAINDNN Trains DNN models

switch modelOptions.name
    case 'Your model name'
    otherwise
        [numFeatures, numResponses] = getNumFeaturesAndResponses(XTrain, YTrain, modelOptions.modelType, modelOptions.dataType);

        layers = getLayers(modelOptions, numFeatures, numResponses);
        trainOptions = getTrainOptions(modelOptions, XVal, YVal, size(XTrain, 1), trainingPlots);
        
        [Mdl, MdlInfo] = trainNetwork(XTrain, YTrain, layers, trainOptions);
end
end
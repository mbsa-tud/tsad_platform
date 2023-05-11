function Mdl = train(modelOptions, XTrain, YTrain, XVal, YVal, trainingPlots, verbose)
%TRAIN Entry-point for adding training functions for models. This function selects the correct
%model and trains it.

switch modelOptions.name
    case "Your model name"
    case "OC-SVM"
        Mdl = ocsvm(XTrain, KernelScale="auto");
    case "iForest"
        [Mdl, ~, ~] = iforest(XTrain, NumLearners=modelOptions.hyperparameters.numLearners, NumObservationsPerLearner=modelOptions.hyperparameters.numObservationsPerLearner);
    otherwise
        if strcmp(modelOptions.type, "deep-learning")
            % Default training for semi-supervised deep-learning models
            [numFeatures, numResponses] = getNumFeaturesAndResponses(XTrain, YTrain, modelOptions.modelType, modelOptions.dataType);
    
            layers = getLayers(modelOptions, numFeatures, numResponses);
            trainOptions = getTrainOptions(modelOptions, XVal, YVal, size(XTrain, 1), trainingPlots, verbose);
            
            Mdl = trainNetwork(XTrain, YTrain, layers, trainOptions);
        else
            Mdl = [];
        end
end
end
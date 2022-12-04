function trainedModels = trainModels_DNN_Consecutive(models, dataTrain, labelsTrain, dataValTest, labelsValTest, ratioValTest, thresholds, trainingPlots)
%TRAINMODELS_DNN_CONSECUTIVE
%
% Trains all DL models consecutively and calculates the thresholds

for i = 1:length(models)
    options = models(i).options;

    switch options.requiresPriorTraining
        case true
            if ratioValTest == 1
                options.calcThresholdLast = true;
            else
                options.calcThresholdLast = false;
            end
    
            [XTrain, YTrain, XVal, YVal] = prepareDataTrain_DNN(options, dataTrain, labelsTrain);
            [Mdl, MdlInfo] = trainDNN(options, XTrain, YTrain, XVal, YVal, trainingPlots);
            
            if ~isequal(XVal{1, 1}, 0)
                pd = getProbDist(options, Mdl, XVal, convertYForTesting(YVal, options.modelType, options.isMultivariate, options.hyperparameters.data.windowSize.value));
            else
                pd = getProbDist(options, Mdl, XTrain, convertYForTesting(YTrain, options.modelType, options.isMultivariate, options.hyperparameters.data.windowSize.value));
            end
            
            if ~options.calcThresholdLast
                staticThreshold = getStaticThreshold_DNN(options, Mdl, XTrain, YTrain, XVal, YVal, dataValTest, labelsValTest, thresholds, pd);
            else
                staticThreshold = [];
            end
        case false
            % Not yet implemented
    end
    
    
    trainedNetwork.Mdl = Mdl;
    trainedNetwork.MdlInfo = MdlInfo;
    trainedNetwork.options = options;
    trainedNetwork.staticThreshold = staticThreshold;
    trainedNetwork.pd = pd;

    trainedModels.(options.id) = trainedNetwork;
end
end
function trainedModels = trainModels_DNN_Consecutive(models, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds, trainingPlots, trainParallel)
%TRAINMODELS_DNN_CONSECUTIVE
%
% Trains all DL models consecutively and calculates the thresholds

for i = 1:length(models)
    options = models(i).options;

    switch options.requiresPriorTraining
        case true
            if isempty(dataTrain)
                error("One of the selected models requires prior training, but the dataset doesn't contain training data (train folder).")
            end

            [XTrain, YTrain, XVal, YVal] = prepareDataTrain_DNN(options, dataTrain, labelsTrain);

            [Mdl, MdlInfo] = trainDNN(options, XTrain, YTrain, XVal, YVal, trainingPlots, trainParallel);
            
            if ~options.outputsLabels
                if ~isempty(XVal{1, 1})
                    pd = getProbDist(options, Mdl, XVal, convertYForTesting(YVal, options.modelType, options.isMultivariate, options.hyperparameters.data.windowSize.value));
                else
                    pd = getProbDist(options, Mdl, XTrain, convertYForTesting(YTrain, options.modelType, options.isMultivariate, options.hyperparameters.data.windowSize.value));
                end
                
                staticThreshold = getStaticThreshold_DNN(options, Mdl, XTrain, YTrain, XVal, YVal, dataValTest, labelsValTest, thresholds, pd);
            else
                pd = [];
                staticThreshold = [];
            end
        case false
            % Not yet implemented, does this even make sense?
    end
    
    
    trainedNetwork.Mdl = Mdl;
    trainedNetwork.MdlInfo = MdlInfo;
    trainedNetwork.options = options;
    trainedNetwork.staticThreshold = staticThreshold;
    trainedNetwork.pd = pd;

    trainedModels.(options.id) = trainedNetwork;
end
end
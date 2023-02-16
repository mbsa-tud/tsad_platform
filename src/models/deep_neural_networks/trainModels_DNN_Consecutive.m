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

            [XTrain, YTrain, XVal, YVal] = prepareDataTrain_DNN_wrapper(options, dataTrain, labelsTrain);

            [Mdl, MdlInfo] = trainDNN_wrapper(options, XTrain, YTrain, XVal, YVal, trainingPlots, trainParallel);
            
            if ~options.outputsLabels
                [XTrainTest, YTrainTest, ~] = prepareDataTest_DNN_wrapper(options, dataTrain, labelsTrain);
                trainingErrorFeatures = getTrainingErrorFeatures(options, Mdl, XTrainTest, YTrainTest);
                
                staticThreshold = getStaticThreshold_DNN(options, Mdl, dataValTest, labelsValTest, thresholds, trainingErrorFeatures);
            else
                trainingErrorFeatures = [];
                staticThreshold = [];
            end
        case false
            % Not yet implemented, does this even make sense?
    end
    
    
    trainedNetwork.Mdl = Mdl;
    trainedNetwork.MdlInfo = MdlInfo;
    trainedNetwork.options = options;
    trainedNetwork.staticThreshold = staticThreshold;
    trainedNetwork.trainingErrorFeatures = trainingErrorFeatures;

    trainedModels.(options.id) = trainedNetwork;
end
end
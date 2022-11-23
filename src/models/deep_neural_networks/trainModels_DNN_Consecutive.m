function trainedModels = trainModels_DNN_Consecutive(models, dataTrain, labelsTrain, dataValTest, labelsValTest, ratioValTest, thresholds, trainingPlots)
%TRAINMODELS_DNN_CONSECUTIVE
%
% Trains all DL models consecutively and calculates the thresholds

for i = 1:length(models)
    options = models(i).options;

    switch options.learningType
        case 'unsupervised'
        case 'semisupervised'
            if ratioValTest == 1
                options.calcThresholdLast = true;
            else
                options.calcThresholdLast = false;
            end
    
            [XTrain, YTrain, XVal, YVal] = prepareDataTrain_DNN(options, dataTrain, labelsTrain);
            [Mdl, MdlInfo] = trainDNN(options, XTrain, YTrain, XVal, YVal, trainingPlots);
    
            if ~options.calcThresholdLast
                staticThreshold = getStaticThreshold_DNN(options, Mdl, XTrain, YTrain, XVal, YVal, dataValTest, labelsValTest, thresholds);
            else
                staticThreshold = [];
            end
        case 'supervised'
    end
    
    trainedNetwork.Mdl = Mdl;
    trainedNetwork.MdlInfo = MdlInfo;
    trainedNetwork.options = options;
    trainedNetwork.staticThreshold = staticThreshold;

    trainedModels.(options.id) = trainedNetwork;
end
end
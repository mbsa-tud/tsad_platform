function trainedModels_DNN = trainModels_DNN_Consecutive(models, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds, trainingPlots, trainParallel)
%TRAINMODELS_DNN_CONSECUTIVE
%
% Trains all DL models consecutively and calculates the thresholds

for i = 1:length(models)
    options = models(i).options;

    if options.requiresPriorTraining
        if isempty(dataTrain)
            error("One of the selected models requires prior training, but the dataset doesn't contain training data (train folder).")
        end

        [XTrain, YTrain, XVal, YVal] = prepareDataTrain_DNN_wrapper(options, dataTrain, labelsTrain);

        [Mdl, MdlInfo] = trainDNN_wrapper(options, XTrain, YTrain, XVal, YVal, trainingPlots, trainParallel);
        
        if ~options.outputsLabels
            XTrainTestCell = cell(size(dataTrain, 1), 1);
            YTrainTestCell = cell(size(dataTrain, 1), 1);

        
            for j = 1:size(dataTrain, 1)
                [XTrainTestCell{i, 1}, YTrainTestCell{i, 1}, ~] = prepareDataTest_DNN_wrapper(options, dataTrain(i, :), labelsTrain(i, :));
            end

            trainingErrorFeatures = getTrainingErrorFeatures(options, Mdl, XTrainTestCell, YTrainTestCell);
            
            staticThreshold = getStaticThreshold_DNN(options, Mdl, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds, trainingErrorFeatures);
        else
            trainingErrorFeatures = [];
            staticThreshold = [];
        end
    else
        % Does this make sense?
        Mdl = [];
        trainingErrorFeatures = [];
        staticThreshold = getStaticThreshold_DNN(options, Mdl, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds, trainingErrorFeatures);
    end
    
    
    trainedNetwork.Mdl = Mdl;
    trainedNetwork.MdlInfo = MdlInfo;
    trainedNetwork.options = options;
    trainedNetwork.staticThreshold = staticThreshold;
    trainedNetwork.trainingErrorFeatures = trainingErrorFeatures;

    trainedModels_DNN.(options.id) = trainedNetwork;
end
end
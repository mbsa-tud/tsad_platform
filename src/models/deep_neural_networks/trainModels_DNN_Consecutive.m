function trainedModels_DNN = trainModels_DNN_Consecutive(models, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds, trainingPlots, trainParallel)
%TRAINMODELS_DNN_CONSECUTIVE
%
% Trains all DL models consecutively and calculates the thresholds

for i = 1:length(models)
    options = models(i).options;
    trainedModel.options = options;

    if options.requiresPriorTraining
        if isempty(dataTrain)
            error("One of the selected models requires prior training, but the dataset doesn't contain training data (train folder).")
        end

        [XTrain, YTrain, XVal, YVal] = prepareDataTrain_DNN_wrapper(options, dataTrain, labelsTrain);

        [trainedModel.Mdl, trainedModel.MdlInfo] = trainDNN_wrapper(options, XTrain, YTrain, XVal, YVal, trainingPlots, trainParallel);
        
        if ~options.outputsLabels
            XTrainTestCell = cell(size(dataTrain, 1), 1);
            YTrainTestCell = cell(size(dataTrain, 1), 1);

        
            for j = 1:size(dataTrain, 1)
                [XTrainTestCell{j, 1}, YTrainTestCell{j, 1}, ~] = prepareDataTest_DNN_wrapper(options, dataTrain(j, :), labelsTrain(j, :));
            end

            trainedModel.trainingErrorFeatures = getTrainingErrorFeatures(trainedModel, XTrainTestCell, YTrainTestCell);
            
            trainedModel.staticThreshold = getStaticThreshold_DNN(trainedModel, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds);
        else
            trainedModel.trainingErrorFeatures = [];
            trainedModel.staticThreshold = [];
        end
    else
        % Does this make sense?
        trainedModel.Mdl = [];
        trainedModel.trainingErrorFeatures = [];
        trainedModel.staticThreshold = getStaticThreshold_DNN(trainedModel, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds);
    end

    trainedModels_DNN.(options.id) = trainedModel;
end
end
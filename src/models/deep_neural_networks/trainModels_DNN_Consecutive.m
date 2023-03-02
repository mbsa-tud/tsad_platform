function trainedModels_DNN = trainModels_DNN_Consecutive(models, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds, trainingPlots, trainParallel)
%TRAINMODELS_DNN_CONSECUTIVE
%
% Trains all DL models consecutively and calculates the thresholds

for i = 1:length(models)
    options = models(i).options;
    trainedModel.options = options;

    fprintf("Training: %s\n", options.model);

    if options.requiresPriorTraining
        if isempty(dataTrain)
            error("The %s model requires prior training, but the dataset doesn't contain training data (train folder).", options.model);
        end

        [XTrain, YTrain, XVal, YVal] = prepareDataTrain(options, dataTrain, labelsTrain);

        [trainedModel.Mdl, trainedModel.MdlInfo] = trainDNN_wrapper(options, XTrain, YTrain, XVal, YVal, trainingPlots, trainParallel);
        
        if ~options.outputsLabels
            XTrainTestCell = cell(size(dataTrain, 1), 1);
            YTrainTestCell = cell(size(dataTrain, 1), 1);

        
            for j = 1:size(dataTrain, 1)
                [XTrainTestCell{j, 1}, YTrainTestCell{j, 1}, ~] = prepareDataTest(options, dataTrain(j, :), labelsTrain(j, :));
            end

            trainedModel.trainingErrorFeatures = getTrainingErrorFeatures(trainedModel, XTrainTestCell, YTrainTestCell);
            
            trainedModel.staticThreshold = getStaticThresholds(trainedModel, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds);
        else
            trainedModel.trainingErrorFeatures = [];
            trainedModel.staticThreshold = [];
        end
    else
        % Does this make sense?
        trainedModel.Mdl = [];
        trainedModel.trainingErrorFeatures = [];
        trainedModel.staticThreshold = getStaticThresholds(trainedModel, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds);
    end

    trainedModels_DNN.(options.id) = trainedModel;
end
end
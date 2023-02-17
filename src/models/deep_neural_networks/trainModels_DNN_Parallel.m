function trainedModels_DNN = trainModels_DNN_Parallel(models, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds, closeOnFinished)
%TRAINMODELS_DNN_PARALLEL
%
% Trains all DL models in parallel and calculates the thresholds

numNetworks = length(models);

XTrainCell = cell(1, numNetworks);
YTrainCell = cell(1, numNetworks);
XValCell = cell(1, numNetworks);
YValCell = cell(1, numNetworks);

for i = 1:numNetworks
    options = models(i).options;

    if options.requiresPriorTraining
        if isempty(dataTrain)
            error("One of the selected models requires prior training, but the dataset doesn't contain training data (train folder).")
        end
        
        [XTrain, YTrain, XVal, YVal] = prepareDataTrain_DNN_wrapper(options, dataTrain, labelsTrain);
    else
        error("One of the selected models for parallel training doesn't require prior training.");
    end

    XTrainCell{i} = XTrain{1, 1};
    YTrainCell{i} = YTrain{1, 1};
    XValCell{i} = XVal{1, 1};
    YValCell{i} = YVal{1, 1};
end

[Mdl, MdlInfo] = trainDNN_Parallel(models, XTrainCell, YTrainCell, XValCell, YValCell, closeOnFinished);

for i = 1:numel(models)
    options = models(i).options;

    if options.requiresPriorTraining
        if ~options.outputsLabels
            XTrainTestCell = cell(size(dataTrain, 1), 1);
            YTrainTestCell = cell(size(dataTrain, 1), 1);

        
            for j = 1:size(dataTrain, 1)
                [XTrainTestCell{i, 1}, YTrainTestCell{i, 1}, ~] = prepareDataTest_DNN_wrapper(options, dataTrain(i, :), labelsTrain(i, :));
            end

            trainingErrorFeatures = getTrainingErrorFeatures(options, Mdl{i}, XTrainTestCell, YTrainTestCell);

            staticThreshold = getStaticThreshold_DNN(options, Mdl{i}, dataTrain, labelsTrain, dataValTest, labelsValTest, thresholds, trainingErrorFeatures);
        else
            trainingErrorFeatures = [];
            staticThreshold = [];
        end
    else
            % Not yet implemented, does this even make sense?
    end


    trainedNetwork.Mdl = Mdl{i};
    trainedNetwork.MdlInfo = MdlInfo{i};
    trainedNetwork.options = options;
    trainedNetwork.staticThreshold = staticThreshold;
    trainedNetwork.trainingErrorFeatures = trainingErrorFeatures;

    trainedModels_DNN.(options.id) = trainedNetwork;
end
end                              

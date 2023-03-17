function [Mdl, MdlInfo] = trainDNN_wrapper(modelOptions, XTrain, YTrain, XVal, YVal, trainingPlots, trainParallel)
%TRAINDNN_WRAPPER Wrapper function for training DNN models

if modelOptions.isMultivariate
    % Train single model on entire data
    [Mdl, MdlInfo] = trainDNN(modelOptions, XTrain{1, 1}, YTrain{1, 1}, XVal{1, 1}, YVal{1, 1}, trainingPlots);
    Mdl = {Mdl};
    MdlInfo = {MdlInfo};
else
    % Train the same model for each channel seperately
    % if trainParallel is set to true, training is done in
    % parallel
    
    numChannels = size(XTrain, 2);

    if trainParallel
        models = [];
        for i = 1:numChannels
            modelInfo.modelOptions = modelOptions;
            models = [models modelInfo];
        end
        [Mdl, MdlInfo] = trainDNN_Parallel(models, XTrain, YTrain, XVal, YVal, trainingPlots, false);
    else
        Mdl = cell(numChannels, 1);
        MdlInfo = cell(numChannels, 1);

        for i = 1:numChannels
            [Mdl{i, 1}, MdlInfo{i, 1}] = trainDNN(modelOptions, XTrain{1, i}, YTrain{1, i}, XVal{1, i}, YVal{1, i}, trainingPlots);
        end
    end
end
end
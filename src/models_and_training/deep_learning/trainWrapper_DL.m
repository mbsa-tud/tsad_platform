function [Mdl, MdlInfo] = trainWrapper_DL(modelOptions, XTrain, YTrain, XVal, YVal, trainingPlots)
%TRAINDNN_WRAPPER Wrapper function for training DNN models

if modelOptions.isMultivariate
    % Train single model on entire data
    [Mdl, MdlInfo] = train_DL(modelOptions, XTrain{1, 1}, YTrain{1, 1}, XVal{1, 1}, YVal{1, 1}, trainingPlots);
    Mdl = {Mdl};
    MdlInfo = {MdlInfo};
else
    % Train the same model for each channel seperately
    % if trainParallel is set to true, training is done in
    % parallel
    
    numChannels = size(XTrain, 2);
    Mdl = cell(numChannels, 1);
    MdlInfo = cell(numChannels, 1);

    for channel_idx = 1:numChannels
        [Mdl{channel_idx, 1}, MdlInfo{channel_idx, 1}] = train_DL(modelOptions, XTrain{1, channel_idx}, YTrain{1, channel_idx}, XVal{1, channel_idx}, YVal{1, channel_idx}, trainingPlots);
    end
end
end
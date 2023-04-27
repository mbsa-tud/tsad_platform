function [Mdl, MdlInfo] = trainWrapper_DL(modelOptions, XTrain, YTrain, XVal, YVal, trainingPlots, verbose)
%TRAINDNN_WRAPPER Wrapper function for training DNN models

if modelOptions.isMultivariate
    % Train single model on entire data
    [Mdl, MdlInfo] = train_DL(modelOptions, XTrain{1}, YTrain{1}, XVal{1}, YVal{1}, trainingPlots, verbose);
    Mdl = {Mdl};
    MdlInfo = {MdlInfo};
else
    % Train the same model for each channel seperately
    
    numChannels = numel(XTrain);
    Mdl = cell(numChannels, 1);
    MdlInfo = cell(numChannels, 1);

    for channel_idx = 1:numChannels
        [Mdl{channel_idx}, MdlInfo{channel_idx}] = train_DL(modelOptions, XTrain{channel_idx}, YTrain{channel_idx}, XVal{channel_idx}, YVal{channel_idx}, trainingPlots, verbose);
    end
end
end
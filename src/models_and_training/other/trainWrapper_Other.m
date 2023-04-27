function Mdl = trainWrapper_Other(modelOptions, XTrain, YTrain)
%TRAINCML Wrapper for training classic ML models

if modelOptions.isMultivariate
    % Train one model on entire data
    Mdl = train_Other(modelOptions, XTrain{1}, YTrain{1});
    Mdl = {Mdl};
else
    % Train the same model for each channel seperately

    numChannels = numel(XTrain);
    
    Mdl = cell(numChannels, 1);

    for channel_idx = 1:numChannels
        Mdl{channel_idx} = train_Other(modelOptions, XTrain{channel_idx}, YTrain{channel_idx});
    end
end
end

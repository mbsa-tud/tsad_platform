function Mdl = trainS_wrapper(modelOptions, XTrain, YTrain)
%TRAINS_WRAPPER Wrapper function for training statistical models

if modelOptions.isMultivariate
    % Train single model on entire data
    Mdl = trainS(modelOptions, XTrain{1, 1}, YTrain{1, 1});
    Mdl = {Mdl};
else
    % Train the same model for each channel seperately

    numChannels = size(XTrain, 2);

    Mdl = cell(numChannels, 1);

    for i = 1:numChannels
        Mdl{i, 1} = trainS(modelOptions, XTrain{1, i}, YTrain{1, i});
    end
end
end
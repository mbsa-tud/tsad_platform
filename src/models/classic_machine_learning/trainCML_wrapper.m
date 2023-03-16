function Mdl = trainCML_wrapper(modelOptions, XTrain, YTrain)
%TRAINCML Wrapper for training classic ML models

if modelOptions.isMultivariate
    % Train one model on entire data
    Mdl = trainCML(modelOptions, XTrain{1, 1}, YTrain{1, 1});
    Mdl = {Mdl};
else
    % Train the same model for each channel seperately

    numChannels = size(XTrain, 2);
    
    Mdl = cell(numChannels, 1);

    for i = 1:numChannels
        Mdl{i, 1} = trainCML(modelOptions, XTrain{1, i}, YTrain{1, i});
    end
end
end

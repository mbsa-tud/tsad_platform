function [anomalyScores, compTime] = detectWith(trainedModel, XTest, TSTest, labels, getCompTime)
%DETECTWITH Function for running a single detection

if strcmp(trainedModel.modelOptions.dimensionality, "multivariate")
    % For multivariate models
    
    if isfield(trainedModel, "Mdl")
        if ~isempty(trainedModel.Mdl)
            Mdl_tmp = trainedModel.Mdl{1};
        else
            Mdl_tmp = [];
        end
    else
        Mdl_tmp = [];
    end

    [anomalyScores, compTime] = detect(trainedModel.modelOptions, Mdl_tmp, XTest{1}, TSTest{1}, labels, getCompTime);
else
    % For univariate models which are trained separately for each channel
    numChannels = numel(XTest);

    anomalyScores = [];
    compTimes = [];
    for channel_idx = 1:numChannels
        if isfield(trainedModel, "Mdl")
            if ~isempty(trainedModel.Mdl)
                Mdl_tmp = trainedModel.Mdl{channel_idx};
            else
                Mdl_tmp = [];
            end
        else
            Mdl_tmp = [];
        end
        
        [anomalyScores_tmp, compTime_tmp]  = detect(trainedModel.modelOptions, Mdl_tmp, XTest{channel_idx}, TSTest{channel_idx}, labels, getCompTime);
        anomalyScores = [anomalyScores, anomalyScores_tmp];
        compTimes = [compTimes, compTime_tmp];
    end
    
    if getCompTime
        compTime = sum(compTimes);
    else
        compTime = NaN;
    end
end
end

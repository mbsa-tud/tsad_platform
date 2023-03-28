function [anomalyScores, compTime] = detectWithModel(trainedModel, XTest, YTest, labels, getCompTime)
%DETECTWITHMODEL Wrapper function for running a single detection

if trainedModel.modelOptions.isMultivariate
    % For multivariate models
    
    if isfield(trainedModel, "Mdl")
        if ~isempty(trainedModel.Mdl)
            Mdl_tmp = trainedModel.Mdl{1, 1};
        else
            Mdl_tmp = [];
        end
    else
        Mdl_tmp = [];
    end

    switch trainedModel.modelOptions.type
        case 'DL'
            [anomalyScores, compTime] = detectWith_DL(trainedModel.modelOptions, Mdl_tmp, XTest{1, 1}, YTest{1, 1}, labels, getCompTime);
        otherwise
            [anomalyScores, compTime] = detectWith_Other(trainedModel.modelOptions, Mdl_tmp, XTest{1, 1}, YTest{1, 1}, labels, getCompTime);
    end
else
    % For univariate models which are trained separately for each channel
    numChannels = size(XTest, 2);

    anomalyScores = [];
    compTimes = [];
    for channel_idx = 1:numChannels
        if isfield(trainedModel, "Mdl")
            if ~isempty(trainedModel.Mdl)
                Mdl_tmp = trainedModel.Mdl{channel_idx, 1};
            else
                Mdl_tmp = [];
            end
        else
            Mdl_tmp = [];
        end
        
        switch trainedModel.modelOptions.type
            case 'DL'
                [anomalyScores_tmp, compTime_tmp]  = detectWith_DL(trainedModel.modelOptions, Mdl_tmp, XTest{1, channel_idx}, YTest{1, channel_idx}, labels, getCompTime);
                anomalyScores = [anomalyScores, anomalyScores_tmp];
                compTimes = [compTimes, compTime_tmp];
            otherwise
                [anomalyScores_tmp, compTime_tmp]  = detectWith_Other(trainedModel.modelOptions, Mdl_tmp, XTest{1, channel_idx}, YTest{1, channel_idx}, labels, getCompTime);
                anomalyScores = [anomalyScores, anomalyScores_tmp];
                compTimes = [compTimes, compTime_tmp];
        end
    end
    
    if getCompTime
        compTime = sum(compTimes);
    else
        compTime = NaN;
    end
end
end

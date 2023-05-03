function [anomalyScores, compTime] = detectWithModel(trainedModel, XTest, TSTest, labels, getCompTime)
%DETECTWITHMODEL Wrapper function for running a single detection

if trainedModel.modelOptions.isMultivariate
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

    switch trainedModel.modelOptions.type
        case 'deep-learning'
            [anomalyScores, compTime] = detectWith_DL(trainedModel.modelOptions, Mdl_tmp, XTest{1}, TSTest{1}, labels, getCompTime);
        otherwise
            [anomalyScores, compTime] = detectWith_Other(trainedModel.modelOptions, Mdl_tmp, XTest{1}, TSTest{1}, labels, getCompTime);
    end
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
        
        switch trainedModel.modelOptions.type
            case 'deep-learning'
                [anomalyScores_tmp, compTime_tmp]  = detectWith_DL(trainedModel.modelOptions, Mdl_tmp, XTest{channel_idx}, TSTest{channel_idx}, labels, getCompTime);
                anomalyScores = [anomalyScores, anomalyScores_tmp];
                compTimes = [compTimes, compTime_tmp];
            otherwise
                [anomalyScores_tmp, compTime_tmp]  = detectWith_Other(trainedModel.modelOptions, Mdl_tmp, XTest{channel_idx}, TSTest{channel_idx}, labels, getCompTime);
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

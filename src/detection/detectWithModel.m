function [anomalyScores, compTime] = detectWithModel(trainedModel, XTest, YTest, labels, getCompTime)
%DETECTWITH
%
% Runs the detection and returns anomaly Scores

if trainedModel.options.isMultivariate
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

    switch trainedModel.options.type
        case 'DNN'
            [anomalyScores, compTime] = detectWithDNN(trainedModel.options, Mdl_tmp, XTest{1, 1}, YTest{1, 1}, labels, getCompTime);
        case 'CML'
            [anomalyScores, compTime] = detectWithCML(trainedModel.options, Mdl_tmp, XTest{1, 1}, YTest{1, 1}, labels, getCompTime);
        case 'S'
            [anomalyScores, compTime] = detectWithS(trainedModel.options, Mdl_tmp, XTest{1, 1}, YTest{1, 1}, labels, getCompTime);
    end
else
    % For univariate models which are trained separately for each channel
    numChannels = size(XTest, 2);

    anomalyScores = [];
    compTimes = [];
    for i = 1:numChannels
        if isfield(trainedModel, "Mdl")
            if ~isempty(trainedModel.Mdl)
                Mdl_tmp = trainedModel.Mdl{i, 1};
            else
                Mdl_tmp = [];
            end
        else
            Mdl_tmp = [];
        end
        
        switch trainedModel.options.type
            case 'DNN'
                [anomalyScores_tmp, compTime_tmp]  = detectWithDNN(trainedModel.options, Mdl_tmp, XTest{1, i}, YTest{1, i}, labels, getCompTime);
                anomalyScores = [anomalyScores, anomalyScores_tmp];
                compTimes = [compTimes, compTime_tmp];
            case 'CML'
                [anomalyScores_tmp, compTime_tmp]  = detectWithCML(trainedModel.options, Mdl_tmp, XTest{1, i}, YTest{1, i}, labels, getCompTime);
                anomalyScores = [anomalyScores, anomalyScores_tmp];
                compTimes = [compTimes, compTime_tmp];
            case 'S'
                [anomalyScores_tmp, compTime_tmp]  = detectWithS(trainedModel.options, Mdl_tmp, XTest{1, i}, YTest{1, i}, labels, getCompTime);
                anomalyScores = [anomalyScores, anomalyScores_tmp];
                compTimes = [compTimes, compTime_tmp];
        end
    end
    
    if getCompTime
        compTime = sum(compTimes);
    end
end
end

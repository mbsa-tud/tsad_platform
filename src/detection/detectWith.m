function [anomalyScores, compTimeOut] = detectWith(trainedModel, XTest, YTest, labels, getCompTime)
%DETECTWITH
%
% Runs the detection and returns anomaly Scores

if ~exist('getCompTime', 'var')
    getCompTime = false;
end

if trainedModel.options.isMultivariate
    % For multivariate models
    
    if ~isempty(trainedModel.Mdl)
        Mdl_tmp = trainedModel.Mdl{1, 1};
    else
        Mdl_tmp = trainedModel.Mdl;
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
    numChannels = size(XTest, 2);

    anomalyScores = [];
    compTimes = [];
    for i = 1:numChannels
        if ~isempty(trainedModel.Mdl)
            Mdl_tmp = trainedModel.Mdl{i, 1};
        else
            Mdl_tmp = trainedModel.Mdl;
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

if nargout == 2
    compTimeOut = compTime;
end

if trainedModel.options.outputsLabels
    anomalyScores = any(anomalyScores, 2);
    return;
end

numChannels = size(anomalyScores, 2);

if isfield(trainedModel.options, 'hyperparameters')
    if isfield(trainedModel.options.hyperparameters, 'scoringFunction') && isfield(trainedModel, 'trainingErrorFeatures') && ~isempty(trainedModel.trainingErrorFeatures)
        % Apply scoring function
        switch trainedModel.options.hyperparameters.scoringFunction.value
            case 'channelwise-errors'
                if numChannels > 1
                    for i = 1:numChannels
                        anomalyScores(:, i) = anomalyScores(:, i) - trainedModel.trainingErrorFeatures.mu(i);
                    end
                end
            case 'aggregated-errors'
                if numChannels > 1
                    for i = 1:numChannels
                        anomalyScores(:, i) = anomalyScores(:, i) - trainedModel.trainingErrorFeatures.mu(i);
                    end
                    anomalyScores = rms(anomalyScores, 2);
                end
            case 'gauss'
                anomalyScores = -log(1 - mvncdf(anomalyScores, trainedModel.trainingErrorFeatures.mu, trainedModel.trainingErrorFeatures.covar));
                anomalyScores(isinf(anomalyScores)) = 0; % Does this make sense?
            case 'aggregated-gauss'
                for i = 1:numChannels
                    anomalyScores(:, i) = -log(1 - cdf('Normal', anomalyScores(:, i), ...
                        trainedModel.trainingErrorFeatures.mu(i), sqrt(trainedModel.trainingErrorFeatures.covar(i, i))));
                end
                anomalyScores(isinf(anomalyScores)) = 0; % Does this make sense?
                anomalyScores = sum(anomalyScores, 2);
            case 'channelwise-gauss'
                for i = 1:numChannels
                    anomalyScores(:, i) = -log(1 - cdf('Normal', anomalyScores(:, i), ...
                        trainedModel.trainingErrorFeatures.mu(i), sqrt(trainedModel.trainingErrorFeatures.covar(i, i))));
                end
                anomalyScores(isinf(anomalyScores)) = 0; % Does this make sense?
            otherwise
                % Do nothing
        end
    end
end
end

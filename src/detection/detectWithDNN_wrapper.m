function [anomalyScores, compTimeOut] = detectWithDNN_wrapper(options, Mdl, XTest, YTest, labels, trainingErrorFeatures, getCompTime)
%DETECTWITHDNN
%
% Runs the detection for DL models and returns anomaly Scores

if ~exist('getCompTime', 'var')
    getCompTime = false;
end

if options.isMultivariate
   % For multivariate models
    [anomalyScores, compTime] = detectWithDNN(options, Mdl{1, 1}, XTest{1, 1}, YTest{1, 1}, labels, getCompTime);
else
    numChannels = size(XTest, 2);

    anomalyScores = [];
    compTimes = [];
    for i = 1:numChannels
        [anomalyScores_tmp, compTime_tmp]  = detectWithDNN(options, Mdl{i, 1}, XTest{1, i}, YTest{1, i}, labels, getCompTime);
        anomalyScores = [anomalyScores, anomalyScores_tmp];
        compTimes = [compTimes, compTime_tmp];
    end
    
    if getCompTime
        compTime = sum(compTimes);
    end
end

if options.outputsLabels
    anomalyScores = any(anomalyScores, 2);
    return;
end

numChannels = size(anomalyScores, 2);

if isfield(options, 'scoringFunction')
    % Apply scoring function
    switch options.scoringFunction
        case 'channelwise-errors'
            if numChannels > 1
                for i = 1:numChannels
                    anomalyScores(:, i) = anomalyScores(:, i) - trainingErrorFeatures.mu(i);
                end
            end
        case 'aggregated-errors'
            if numChannels > 1
                for i = 1:numChannels
                    anomalyScores(:, i) = anomalyScores(:, i) - trainingErrorFeatures.mu(i);
                end
                anomalyScores = rms(anomalyScores, 2);
            end
        case 'gauss'
            anomalyScores = -log(1 - mvncdf(anomalyScores, trainingErrorFeatures.mu, trainingErrorFeatures.covar));
            anomalyScores(isinf(anomalyScores)) = 0; % Does this make sense?
        case 'aggregated-gauss'
            for i = 1:numChannels
                anomalyScores(:, i) = -log(1 - cdf('Normal', anomalyScores(:, i), ...
                    trainingErrorFeatures.mu(i), sqrt(trainingErrorFeatures.covar(i, i))));
            end
            anomalyScores(isinf(anomalyScores)) = 0; % Does this make sense?
            anomalyScores = sum(anomalyScores, 2);
        case 'channelwise-gauss'
            for i = 1:numChannels
                anomalyScores(:, i) = -log(1 - cdf('Normal', anomalyScores(:, i), ...
                    trainingErrorFeatures.mu(i), sqrt(trainingErrorFeatures.covar(i, i))));
            end
            anomalyScores(isinf(anomalyScores)) = 0; % Does this make sense?
        otherwise
            % Do nothing
    end
end

if nargout == 2
    compTimeOut = compTime;
end
end

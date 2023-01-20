function [anomalyScores, compTimeOut] = detectWithDNN(options, Mdl, XTest, YTest, labels, scoringFunction, trainingErrorFeatures, getCompTime)
%DETECTWITHDNN
%
% Runs the detection for DL models and returns anomaly Scores

if ~exist('getCompTime', 'var')
    getCompTime = false;
end

switch options.model
    case 'Your model'
    otherwise
        if ~options.isMultivariate
            % For univariate models
            anomalyScores = [];

            % Comp time
            times = zeros(length(Mdl), 1);

            % Get anomaly scores for each channel
            for i = 1:length(Mdl)
                if iscell(Mdl)
                    net_tmp = Mdl{i};
                else
                    net_tmp = Mdl(i);
                end
                
                prediction = predict(net_tmp, XTest{i});
                
                if getCompTime
                    iterations = min(1000, size(XTest{i}, 1));
                    times_tmp = zeros(iterations, 1);
                    for k = 1:iterations
                        tStart = cputime;
                        predict(net_tmp, XTest{i}(k, :));
                        times_tmp(k, 1) = cputime - tStart;
                    end
                    times(i, 1) = mean(times_tmp);
                end
                
                if strcmp(options.modelType, 'reconstructive')
                    prediction = reshapeReconstructivePrediction(prediction, options.isMultivariate, options.hyperparameters.data.windowSize.value, options.dataType);
                elseif strcmp(options.modelType, 'predictive')
                    if iscell(prediction)
                        prediction = cell2mat(prediction);
                    end
                end   
                
                anomalyScores(:, i) = abs(prediction - YTest{i});

                % Hi future contributor to this platform.
                % Does the following thing make more sense than what is
                % done above?:
                % Rather than selecting the median reconstructed value for
                % each observation, calculate the reconstrunction errors
                % first and the select the median reconstruction error.
            end
            
            if getCompTime
                compTime = sum(times);
            end
        else
            % For multivariate models
            prediction = predict(Mdl, XTest{1});
            
            if getCompTime
                iterations = min(1000, size(XTest{1}, 1));
                times = zeros(iterations, 1);
                for k = 1:iterations
                    tStart = cputime;
                    predict(Mdl, XTest{1}(k, :));
                    times(k, 1) = cputime - tStart;
                end
                compTime = mean(times);
            end
            
            if strcmp(options.modelType, 'reconstructive')
                prediction = reshapeReconstructivePrediction(prediction, options.isMultivariate, options.hyperparameters.data.windowSize.value, options.dataType);
            elseif strcmp(options.modelType, 'predictive')
                if iscell(prediction)
                    pred_tmp = zeros(size(prediction, 1), size(prediction{1, 1}, 1));
                    for i = 1:size(prediction, 1)
                            pred_tmp(i, :) = prediction{i, 1}';
                    end
                    prediction = pred_tmp;
                end
            end
            
            anomalyScores = abs(prediction - YTest{1});
        end
        
        numChannels = size(anomalyScores, 2);
        
        % Apply scoring function
        switch scoringFunction
            case 'separate'
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
        end
end

if nargout == 2
    compTimeOut = compTime;
end

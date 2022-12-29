function [anomalyScores, compTimeOut] = detectWithDNN(options, Mdl, XTest, YTest, labels, scoringFunction, pd, getCompTime)
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
                
                pred = predict(net_tmp, XTest{i});
                
                if getCompTime
                    numWindows = size(XTest{i}, 1);
                    times_tmp = zeros(numWindows, 1);
                    for k = 1:numWindows
                        tStart = cputime;
                        predict(net_tmp, XTest{i}(k, :));
                        times_tmp(k, 1) = cputime - tStart;
                    end
                    times(i, 1) = mean(times_tmp);
                end
                
                if strcmp(options.modelType, 'reconstructive')
                    pred = reshapeReconstructivePrediction(pred, options.hyperparameters.data.windowSize.value);
                else
                    if iscell(pred)
                        pred = cell2mat(pred);
                    end
                end   
                
                anomalyScores(:, i) = abs(pred - YTest{i});

                % Hi future contributor to this platform.
                % Do the following lines make more sense than what is done above?
                % Rather than selecting the median reconstructed value for
                % each observation, calculate the reconstrunction errors
                % first and the select the median reconstruction error.
                
%                 if strcmp(options.modelType, 'reconstructive')
%                     anomalyScores(:, i) = reshapeReconstructivePrediction(abs(pred - XTest{i}), options.hyperparameters.data.windowSize.value);
%                 else
%                     if iscell(pred)
%                         pred = cell2mat(pred);
%                     end
%                     anomalyScores(:, i) = abs(pred - YTest{i});
%                 end   
            end
            
            if getCompTime
                compTime = sum(times);
            end
        else
            % For multivariate models
            pred = predict(Mdl, XTest{1});
            
            if getCompTime
                numWindows = size(XTest{1}, 1);
                times = zeros(numWindows, 1);
                for k = 1:numWindows
                    tStart = cputime;
                    predict(Mdl, XTest{1}(k, :));
                    times(k, 1) = cputime - tStart;
                end
                compTime = mean(times);
            end
            
            if strcmp(options.modelType, 'reconstructive')
                pred = reshapeReconstructivePrediction(pred, options.hyperparameters.data.windowSize.value);
            end   
            
            anomalyScores = abs(pred - YTest{1});
        end
        
        numChannels = size(anomalyScores, 2);

        switch scoringFunction
            case 'separate'
            case 'channelwise-errors'
                if numChannels > 1
                    for i = 1:numChannels
                        anomalyScores(:, i) = anomalyScores(:, i) - pd(i).mu;
                    end
                end
            case 'aggregated-errors'
                if numChannels > 1
                    for i = 1:numChannels
                        anomalyScores(:, i) = anomalyScores(:, i) - pd(i).mu;
                    end
                    anomalyScores = rms(anomalyScores, 2);
                end   
            case 'gauss'
                for i = 1:numChannels
                    anomalyScores(:, i) = -log(1 - cdf(pd(i), anomalyScores(:, i)));
                end
                anomalyScores = sum(anomalyScores, 2);
%                 anomalyScores = -log(1 - mvncdf(anomalyScores, pd.mu, pd.sigma));
        end
end

if nargout == 2
    compTimeOut = compTime;
end

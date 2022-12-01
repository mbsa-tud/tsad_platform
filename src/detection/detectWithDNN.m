function [anomalyScores, YTest, labels] = detectWithDNN(options, Mdl, XTest, YTest, labels, scoringFunction, pd)
%DETECTWITHDNN
%
% Runs the detection for DL models and returns anomaly Scores


switch options.model
    case 'Your model'
    otherwise
        if ~options.isMultivariate
            anomalyScores = [];
            % Get anomaly scores for each channel
            for i = 1:length(Mdl)
                if iscell(Mdl)
                    net_tmp = Mdl{i};
                else
                    net_tmp = Mdl(i);
                end
    
                pred = predict(net_tmp, XTest{i});
                
                if strcmp(options.modelType, 'Reconstructive')
                    pred = reshapeReconstructivePrediction(pred, options.hyperparameters.data.windowSize.value);
                    YTest_tmp = YTest{i};
                    YTest{i} = YTest_tmp(1:(end - options.hyperparameters.data.windowSize.value), 1);
                else
                    if iscell(pred)
                        pred = cell2mat(pred);
                    end
                end   
                
                anomalyScores(:, i) = abs(pred - YTest{i});
            end
        else
            pred = predict(Mdl, XTest{1});
            
            if strcmp(options.modelType, 'Reconstructive')
                pred = reshapeReconstructivePrediction(pred, options.hyperparameters.data.windowSize.value);
                YTest{1} = YTest{1}(1:(end - options.hyperparameters.data.windowSize.value), :);
            end   
            
            anomalyScores = abs(pred - YTest{1});
        end
        
        numChannels = size(anomalyScores, 2);

        switch scoringFunction
            case 'channelwise-errors'
                if numChannels > 1
                    for i = 1:numChannels
                        anomalyScores(:, i) = anomalyScores(:, i) - mean(anomalyScores(:, i));
                    end
                end
            case 'aggregated-errors'
                if numChannels > 1
                    for i = 1:numChannels
                        anomalyScores(:, i) = anomalyScores(:, i) - mean(anomalyScores(:, i));
                    end
                    anomalyScores = rms(anomalyScores, 2);
                end   
            case 'gauss'
                for i = 1:numChannels
                    anomalyScores(:, i) = cdf(pd(i), anomalyScores(:, i));
                end
                anomalyScores = sum(anomalyScores, 2);
        end

        % Crop labels for reconstructive models
        if strcmp(options.modelType, 'Reconstructive')
            labels = labels(1:(end - options.hyperparameters.data.windowSize.value), 1);
        end
end
end

function [anomalyScores, YTest, labels] = detectWithDNN(options, Mdl, XTest, YTest, labels)
%DETECTWITHDNN
%
% Runs the detection for DL models and returns anomaly Scores


switch options.model
    case 'Your model'
    otherwise
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
            if length(Mdl) > 1
                anomalyScores(:, i) = anomalyScores(:, i) - mean(anomalyScores(:, i));
            end
        end
        
        aggregateScores = false;
        if aggregateScores
            anomalyScores = rms(anomalyScores, 2);
        end

        % Crop labels for reconstructive models
        if strcmp(options.modelType, 'Reconstructive')
            labels = labels(1:(end - options.hyperparameters.data.windowSize.value), 1);
        end
end
end

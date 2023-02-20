function [anomalyScores, compTime] = detectWithDNN(options, Mdl, XTest, YTest, labels, getCompTime)
%DETECTWITHDNN
%
% Runs the detection for DL models and returns anomaly Scores

switch options.model
    case 'Your model'
    otherwise
        % For multivariate models
        prediction = predict(Mdl, XTest);
        
        if getCompTime
            iterations = min(1000, size(XTest, 1));
            times = zeros(iterations, 1);
            for k = 1:iterations
                tStart = cputime;
                predict(Mdl, XTest(k, :));
                times(k, 1) = cputime - tStart;
            end
            compTime = mean(times);
        else
            compTime = [];
        end

          
        if strcmp(options.modelType, 'reconstructive')
         % DEV NOTE: There are two versions two do this. Which one is
         % better?
         % 1. (currently used version) calculate median predicted value for each time step and then calculate the errors for the entire time series

            prediction = reshapeOverlappingSubsequences(prediction, options.isMultivariate, options.hyperparameters.data.windowSize.value, options.dataType);
            anomalyScores = abs(prediction - YTest);

         % 2.calulate the errors for each subsequence and then calculate the median (/mean?) error for each time step
         
%             if options.dataType == 1
%                 anomalyScores = abs(prediction - XTest);
%             elseif options.dataType == 2
%                 anomalyScores = cell(size(prediction, 1), 1);
%                 for i = 1:size(prediction, 1)
%                     anomalyScores{i, 1} = abs(prediction{i, 1} - XTest{i, 1});
%                 end
%             end
%             
%             anomalyScores = reshapeOverlappingSubsequences(anomalyScores, options.isMultivariate, options.hyperparameters.data.windowSize.value, options.dataType);
        elseif strcmp(options.modelType, 'predictive')
            if iscell(prediction)
                pred_tmp = zeros(size(prediction, 1), size(prediction{1, 1}, 1));
                for i = 1:size(prediction, 1)
                        pred_tmp(i, :) = prediction{i, 1}';
                end
                prediction = pred_tmp;
            end

            anomalyScores = abs(prediction - YTest);
        end
end
end

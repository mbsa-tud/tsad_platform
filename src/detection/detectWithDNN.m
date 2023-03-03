function [anomalyScores, compTime] = detectWithDNN(options, Mdl, XTest, YTest, labels, getCompTime)
%DETECTWITHDNN
%
% Runs the detection for DL models and returns anomaly Scores
compTime = NaN;

switch options.model
    case 'Your model'
    otherwise
        prediction = predict(Mdl, XTest);

        if getCompTime
            iterations = min(1000, size(XTest, 1));
            times = zeros(iterations, 1);
            for k = 1:iterations
                tStart = cputime;
                predict(Mdl, XTest(k, :));
                times(k, 1) = cputime - tStart;
            end
            compTime = mean(times(~(times == 0)));
        end

          
        if strcmp(options.modelType, 'reconstructive')
         % DEV NOTE: There are two versions two do this. Which one is
         % better?
         % 1. (currently used version) calculate median predicted value for each time step and then calculate the errors for the entire time series

            prediction = mergeOverlappingSubsequences(options, prediction);
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
%             anomalyScores = mergeOverlappingSubsequences(options, anomalyScores);
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

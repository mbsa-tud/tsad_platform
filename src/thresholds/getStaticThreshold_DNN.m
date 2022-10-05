function [staticThreshold, pd] = getStaticThreshold_DNN(options, Mdl, XTrain, YTrain, XVal, YVal, testValData, testValLabels, thresholds)
%GETSTATICTHRESHOLD_DNN
%
% This function calculates the static threshold for DL models and
% returnes them in the staticThreshold struct

pd = [];
switch options.model
    case 'Your model'
    otherwise
        if size(XTrain, 2) > 1
            isMultivariate = true;
        else
            isMultivariate = false;
        end

        if ~isempty(testValData)
            XTestValCell = cell(size(testValData, 1), 1);
            YTestValCell = cell(size(testValData, 1), 1);
            labelsTestValCell = cell(size(testValData, 1), 1);
            
            numAnoms = 0;
            numTimeSteps = 0;

            for i = 1:size(testValData, 1)
                [XTestValCell{i, 1}, YTestValCell{i, 1}, labelsTestValCell{i, 1}] = prepareDataTest_DNN(options, testValData(i, :), testValLabels(i, :));
                
                numAnoms = numAnoms + sum(labelsTestValCell{end} == 1);
                numTimeSteps = numTimeSteps + size(labelsTestValCell{end}, 1);
            end

            contaminationFraction = numAnoms / numTimeSteps;
            
            if contaminationFraction > 0
                anomalyScores = [];
                labelsTestVal = [];

                for i = 1:size(XTestValCell, 1)
                    [anomalyScores_tmp, ~, labelsTestVal_tmp] = detectWithDNN(options, Mdl, XTestValCell{i, 1}, YTestValCell{i, 1}, labelsTestValCell{i, 1});
                    anomalyScores = [anomalyScores; anomalyScores_tmp];
                    labelsTestVal = [labelsTestVal; labelsTestVal_tmp];
                end

                if ismember("bestFscorePointwise", thresholds) || ismember("all", thresholds)
                    thr = computeBestFscoreThreshold(anomalyScores, labelsTestVal, 0, 0, 'point-wise');
                    if ~isnan(thr)
                        staticThreshold.bestFscorePointwise = thr;
                    else
                        staticThreshold.bestFscorePointwise = 0;
                    end
                end

                if ismember("bestFscoreEventwise", thresholds) || ismember("all", thresholds)
                    thr = computeBestFscoreThreshold(anomalyScores, labelsTestVal, 0, 0, 'event-wise');
                    if ~isnan(thr)
                        staticThreshold.bestFscoreEventwise = thr;
                    else
                        staticThreshold.bestFscoreEventwise = 0;
                    end
                end
                
                if ismember("bestFscorePointAdjusted", thresholds) || ismember("all", thresholds)
                    thr = computeBestFscoreThreshold(anomalyScores, labelsTestVal, 0, 0, 'point-adjusted');
                    if ~isnan(thr)
                        staticThreshold.bestFscorePointAdjusted = thr;
                    else
                        staticThreshold.bestFscorePointAdjusted = 0;
                    end
                end
                
                if ismember("bestFscoreComposite", thresholds) || ismember("all", thresholds)
                    thr = computeBestFscoreThreshold(anomalyScores, labelsTestVal, 0, 0, 'composite');
                    if ~isnan(thr)
                        staticThreshold.bestFscoreComposite = thr;
                    else
                        staticThreshold.bestFscoreComposite = 0;
                    end
                end
                
                if ismember("topK", thresholds) || ismember("all", thresholds) && ~isMultivariate
                    thr = quantile(anomalyScores, 1 - contaminationFraction);
                    if ~isnan(thr)
                        staticThreshold.topK = thr;
                    else
                        staticThreshold.topK = 0;
                    end
                end

                if any(ismember(thresholds, ["bestFscorePointwiseParametric", "bestFscoreEventwiseParametric", ...
                        "bestFscorePointAdjustedParametric", "bestFscoreCompositeParametric", "topKParametric"])) ...
                        && ~any(ismember(thresholds, ["bestFscorePointwise", "bestFscoreEventwise", ...
                        "bestFscorePointAdjusted", "bestFscoreComposite", "topK", "meanStd"])) ...
                        && options.hyperparameters.training.ratioTrainVal.value == 1
                    error("To compute parametric static thresholds, validation data is needed!");
                end
                if any(ismember(thresholds, ["bestFscorePointwiseParametric", "bestFscoreEventwiseParametric", ...
                        "bestFscorePointAdjustedParametric", "bestFscoreCompositeParametric", "topKParametric"])) ...
                        && options.hyperparameters.training.ratioTrainVal.value == 1
                    disp("Warning! You selected a parametric static threshold but didn't use any validation data.");
                end

                if options.hyperparameters.training.ratioTrainVal.value ~= 1
                    YVal = convertYForTesting(YVal, options.modelType);
    
                    [anomalyScoresVal, ~, ~] = detectWithDNN(options, Mdl, XVal, YVal, zeros(size(YVal{1, 1}, 1), 1));
                    pd = fitdist(anomalyScoresVal, "Normal");

                    if ismember("bestFscorePointwiseParametric", thresholds) || ismember("all", thresholds)
                        thr = computeBestFscoreThreshold(anomalyScores, labelsTestVal, 1, pd, 'point-wise');
                        if ~isnan(thr)
                            staticThreshold.bestFscorePointwiseParametric = thr;
                        else
                            staticThreshold.bestFscorePointwiseParametric = 0;
                        end
                    end
    
                    if ismember("bestFscoreEventwiseParametric", thresholds) || ismember("all", thresholds)
                        thr = computeBestFscoreThreshold(anomalyScores, labelsTestVal, 1, pd, 'event-wise');
                        if ~isnan(thr)
                            staticThreshold.bestFscoreEventwiseParametric = thr;
                        else
                            staticThreshold.bestFscoreEventwiseParametric = 0;
                        end
                    end
                    
                    if ismember("bestFscorePointAdjustedParametric", thresholds) || ismember("all", thresholds)
                        thr = computeBestFscoreThreshold(anomalyScores, labelsTestVal, 1, pd, 'point-adjusted');
                        if ~isnan(thr)
                            staticThreshold.bestFscorePointAdjustedParametric = thr;
                        else
                            staticThreshold.bestFscorePointAdjustedParametric = 0;
                        end
                    end
                    
                    if ismember("bestFscoreCompositeParametric", thresholds) || ismember("all", thresholds)
                        thr = computeBestFscoreThreshold(anomalyScores, labelsTestVal, 1, pd, 'composite');
                        if ~isnan(thr)
                            staticThreshold.bestFscoreCompositeParametric = thr;
                        else
                            staticThreshold.bestFscoreCompositeParametric = 0;
                        end
                    end
                end                            
            end
        end
        
        if ismember("meanStd", thresholds) || ismember("all", thresholds)
            if options.hyperparameters.training.ratioTrainVal.value == 1
                YTrain = convertYForTesting(YTrain, options.modelType);
                [anomalyScores, ~, ~] = detectWithDNN(options, Mdl, XTrain, YTrain, zeros(size(YTrain{1, 1}, 1), 1));
                staticThreshold.meanStd = mean(mean(anomalyScores, 1)) + 4 * mean(std(anomalyScores, 0, 1));
            else
                YVal = convertYForTesting(YVal, options.modelType);
                [anomalyScoresVal, ~, ~] = detectWithDNN(options, Mdl, XVal, YVal, zeros(size(YVal{1, 1}, 1), 1));
                staticThreshold.meanStd = mean(mean(anomalyScoresVal, 1)) + 4 * mean(std(anomalyScoresVal, 0, 1));
            end
        end
end
end

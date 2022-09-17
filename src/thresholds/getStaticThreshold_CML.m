function [staticThreshold, pd] = getStaticThreshold_CML(options, Mdl, XTrain, XVal, testValData, testValLabels, thresholds)
pd = [];
switch options.model
    case 'Merlin'
        staticThreshold.default = 0.5;
    otherwise
        if ~isempty(testValData)
            XTestValCell = cell(size(testValData, 1), 1);
            labelsTestValCell = cell(size(testValData, 1), 1);
            
            numAnoms = 0;
            numTimeSteps = 0;

            for i = 1:size(testValData, 1)
                [XTestValCell{i, 1}, labelsTestValCell{i, 1}] = prepareDataTest_CML(options, testValData(i, 1), testValLabels(i, 1));
                
                numAnoms = numAnoms + sum(labelsTestValCell{end} == 1);
                numTimeSteps = numTimeSteps + size(labelsTestValCell{end}, 1);
            end

            contaminationFraction = numAnoms / numTimeSteps;                       
            
            if contaminationFraction > 0
                anomalyScores = [];
                labelsTestVal = [];

                for i = 1:size(XTestValCell, 1)
                    [anomalyScores_tmp, ~, labelsTestVal_tmp] = detectWithCML(options, Mdl, XTestValCell{i, 1}, labelsTestValCell{i, 1});
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
                
                if ismember("topK", thresholds) || ismember("all", thresholds)
                    thr = quantile(anomalyScores, 1 - contaminationFraction);
                    if ~isnan(thr)
                        staticThreshold.topK = thr;
                    else
                        staticThreshold.topK = 0;
                    end
                end

                if any(ismember(thresholds, ["bestFscorePointwiseGauss", "bestFscoreEventwiseGauss", ...
                        "bestFscorePointAdjustedGauss", "bestFscoreCompositeGauss", "topKGauss"])) ...
                        && ~any(ismember(thresholds, ["bestFscorePointwise", "bestFscoreEventwise", ...
                        "bestFscorePointAdjusted", "bestFscoreComposite", "topK", "meanStd"])) ...
                        && options.hyperparameters.training.ratioTrainVal.value == 1
                    error("To compute Gauss static thresholds, validation data is needed!");
                end
                if any(ismember(thresholds, ["bestFscorePointwiseGauss", "bestFscoreEventwiseGauss", ...
                        "bestFscorePointAdjustedGauss", "bestFscoreCompositeGauss", "topKGauss"])) ...
                        && options.hyperparameters.training.ratioTrainVal.value == 1
                    disp("Warning! You selected thresholds for gaussian anomaly scoring but didn't use any validation data.");
                end

                if options.hyperparameters.training.ratioTrainVal.value ~= 1    
                    [anomalyScoresVal, ~, ~] = detectWithCML(options, Mdl, XVal, []);
                    pd = fitdist(anomalyScoresVal, "Normal");

                    if ismember("bestFscorePointwiseGauss", thresholds) || ismember("all", thresholds)
                        thr = computeBestFscoreThreshold(anomalyScores, labelsTestVal, 1, pd, 'point-wise');
                        if ~isnan(thr)
                            staticThreshold.bestFscorePointwiseGauss = thr;
                        else
                            staticThreshold.bestFscorePointwiseGauss = 0;
                        end
                    end
    
                    if ismember("bestFscoreEventwiseGauss", thresholds) || ismember("all", thresholds)
                        thr = computeBestFscoreThreshold(anomalyScores, labelsTestVal, 1, pd, 'event-wise');
                        if ~isnan(thr)
                            staticThreshold.bestFscoreEventwiseGauss = thr;
                        else
                            staticThreshold.bestFscoreEventwiseGauss = 0;
                        end
                    end
                    
                    if ismember("bestFscorePointAdjustedGauss", thresholds) || ismember("all", thresholds)
                        thr = computeBestFscoreThreshold(anomalyScores, labelsTestVal, 1, pd, 'point-adjusted');
                        if ~isnan(thr)
                            staticThreshold.bestFscorePointAdjustedGauss = thr;
                        else
                            staticThreshold.bestFscorePointAdjustedGauss = 0;
                        end
                    end
                    
                    if ismember("bestFscoreCompositeGauss", thresholds) || ismember("all", thresholds)
                        thr = computeBestFscoreThreshold(anomalyScores, labelsTestVal, 1, pd, 'composite');
                        if ~isnan(thr)
                            staticThreshold.bestFscoreCompositeGauss = thr;
                        else
                            staticThreshold.bestFscoreCompositeGauss = 0;
                        end
                    end

                    if ismember("topKGauss", thresholds) || ismember("all", thresholds) && ~isMultivariate
                        anomalyScores = pdf(pd, anomalyScores);
                        thr = quantile(anomalyScores, contaminationFraction);
                        if ~isnan(thr)
                            staticThreshold.topKGauss = thr;
                        else
                            staticThreshold.topKGauss = 0;
                        end
                    end
                end 
            end
        end
        if ismember("meanStd", thresholds) || ismember("all", thresholds)
            [anomalyScores, ~, ~] = detectWithCML(options, Mdl, XTrain, zeros(size(XTrain, 1), 1));
            staticThreshold.meanStd = mean(anomalyScores) + 4 * std(anomalyScores);
        end
end
end

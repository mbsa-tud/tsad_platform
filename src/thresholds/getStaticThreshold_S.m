function staticThreshold = getStaticThreshold_S(options, Mdl, XTrain, dataValTest, labelsValTest, thresholds)
%GETSTATICTHRESHOLD_S
%
% This function calculates the static thresholds for statistical models and
% returnes them in the staticThreshold struct

switch options.model
    case 'Your model'
    otherwise
        if ~isempty(dataValTest)
            XValTestCell = cell(size(dataValTest, 1), 1);
            YValTestCell = cell(size(dataValTest, 1), 1);
            labelsValTestCell = cell(size(dataValTest, 1), 1);
            
            numAnoms = 0;
            numTimeSteps = 0;

            for i = 1:size(dataValTest, 1)
                [XValTestCell{i, 1}, YValTestCell{i, 1}, labelsValTestCell{i, 1}] = prepareDataTest_S(options, dataValTest(i, 1), labelsValTest(i, 1));
                
                numAnoms = numAnoms + sum(labelsValTestCell{end} == 1);
                numTimeSteps = numTimeSteps + size(labelsValTestCell{end}, 1);
            end

            contaminationFraction = numAnoms / numTimeSteps;                       
            
            if contaminationFraction > 0
                anomalyScores = [];
                labelsValTest = [];

                for i = 1:size(XValTestCell, 1)
                    [anomalyScores_tmp, ~, labelsTestVal_tmp] = detectWithS(options, Mdl, XValTestCell{i, 1}, YValTestCell{i, 1}, labelsValTestCell{i, 1});
                    anomalyScores = [anomalyScores; anomalyScores_tmp];
                    labelsValTest = [labelsValTest; labelsTestVal_tmp];
                end
                
                if ismember("bestFscorePointwise", thresholds) || ismember("all", thresholds)
                    thr = computeBestFscoreThreshold(anomalyScores, labelsValTest, 0, 0, 'point-wise');
                    if ~isnan(thr)
                        staticThreshold.bestFscorePointwise = thr;
                    else
                        staticThreshold.bestFscorePointwise = 0;
                    end
                end

                if ismember("bestFscoreEventwise", thresholds) || ismember("all", thresholds)
                    thr = computeBestFscoreThreshold(anomalyScores, labelsValTest, 0, 0, 'event-wise');
                    if ~isnan(thr)
                        staticThreshold.bestFscoreEventwise = thr;
                    else
                        staticThreshold.bestFscoreEventwise = 0;
                    end
                end

                if ismember("bestFscorePointAdjusted", thresholds) || ismember("all", thresholds)
                    thr = computeBestFscoreThreshold(anomalyScores, labelsValTest, 0, 0, 'point-adjusted');
                    if ~isnan(thr)
                        staticThreshold.bestFscorePointAdjusted = thr;
                    else
                        staticThreshold.bestFscorePointAdjusted = 0;
                    end
                end

                if ismember("bestFscoreComposite", thresholds) || ismember("all", thresholds)
                    thr = computeBestFscoreThreshold(anomalyScores, labelsValTest, 0, 0, 'composite');
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
            else
                error("Anomalous validation set doesn't contain anomalies");
            end
        end

        if any(ismember(thresholds, ["bestFscorePointwiseParametric", "bestFscoreEventwiseParametric", ...
                "bestFscorePointAdjustedParametric", "bestFscoreCompositeParametric", "topKParametric"])) ...
                && ~any(ismember(thresholds, ["bestFscorePointwise", "bestFscoreEventwise", ...
                "bestFscorePointAdjusted", "bestFscoreComposite", "topK"]))
            error("Parametric static thresholds are not available for Statistical models!");
        end
        if any(ismember(thresholds, ["bestFscorePointwiseParametric", "bestFscoreEventwiseParametric", ...
                "bestFscorePointAdjustedParametric", "bestFscoreCompositeParametric", "topKParametric"]))
            disp("Warning! You selected a parametric static threshold which is not available for Statistical models.");
        end
        if length(thresholds) == 1 && ismember("meanStd", thresholds)
            disp("Warning! Threshold using the mean and standard deviation of the anomaly scores for training/validation data is only available for DL models.");
        end
end
end

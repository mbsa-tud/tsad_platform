function [staticThreshold, pd] = getStaticThreshold_CML(options, Mdl, XTrain, testValData, testValLabels, thresholds)
%GETSTATICTHRESHOLD_CML
%
% This function calculates the static threshold for classic ML models and
% returnes them in the staticThreshold struct

pd = [];
switch options.model
    case 'Merlin'
        staticThreshold.dummy = 0.5;
    otherwise
        if ~isempty(testValData)
            XTestValCell = cell(size(testValData, 1), 1);
            YTestValCell = cell(size(testValData, 1), 1);
            labelsTestValCell = cell(size(testValData, 1), 1);
            
            numAnoms = 0;
            numTimeSteps = 0;

            for i = 1:size(testValData, 1)
                [XTestValCell{i, 1}, YTestValCell{i, 1}, labelsTestValCell{i, 1}] = prepareDataTest_CML(options, testValData(i, 1), testValLabels(i, 1));
                
                numAnoms = numAnoms + sum(labelsTestValCell{end} == 1);
                numTimeSteps = numTimeSteps + size(labelsTestValCell{end}, 1);
            end

            contaminationFraction = numAnoms / numTimeSteps;                       
            
            if contaminationFraction > 0
                anomalyScores = [];
                labelsTestVal = [];

                for i = 1:size(XTestValCell, 1)
                    [anomalyScores_tmp, ~, labelsTestVal_tmp] = detectWithCML(options, Mdl, XTestValCell{i, 1}, YTestValCell{i, 1}, labelsTestValCell{i, 1});
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
            else
                error("Anomalous validation set doesn't contain anomalies");
            end
        end

        if any(ismember(thresholds, ["bestFscorePointwiseParametric", "bestFscoreEventwiseParametric", ...
                "bestFscorePointAdjustedParametric", "bestFscoreCompositeParametric", "topKParametric"])) ...
                && ~any(ismember(thresholds, ["bestFscorePointwise", "bestFscoreEventwise", ...
                "bestFscorePointAdjusted", "bestFscoreComposite", "topK"]))
            error("Parametric static thresholds are not available for CML models!");
        end
        if any(ismember(thresholds, ["bestFscorePointwiseParametric", "bestFscoreEventwiseParametric", ...
                "bestFscorePointAdjustedParametric", "bestFscoreCompositeParametric", "topKParametric"]))
            disp("Warning! You selected a parametric static threshold which is not available for CML models.");
        end
        if length(thresholds) == 1 && ismember("meanStd", thresholds)
            disp("Warning! Threshold using the mean and standard deviation of the anomaly scores for training/validation data is only available for DL models.");
        end
end
end

classdef TSAD_LOF < TSADModel
    %TSAD_LOF Local outlier factor

    methods (Access = protected)
        function [XTest, timeSeriesTest, labelsTest] =  prepareDataTest(obj, data, labels)
            %PREPAREDATATEST Prepares testing data

            [XTest, timeSeriesTest, labelsTest] = applySlidingWindowForTest(data, labels, ...
                                                        obj.parameters.windowSize, ...
                                                        "reconstruction", "flattened");
        end
        
        function [anomalyScores, windowComputationTime] = predict(obj, Mdl, XTest, timeSeriesTest, labelsTest, getWindowComputationTime)
            %PREDICT Makes prediction on test data using the Mdl
            
            % Ignore comptation time as it is only of interest for DNNs
            windowComputationTime = NaN;
            
            % Run LOD
            [~, anomalyScores] = LOF(XTest, obj.parameters.k);

            % Merge overlapping anoamly scores
            anomalyScores = mergeOverlappingAnomalyScores(anomalyScores, obj.parameters.windowSize, @mean);
        end
    end
end
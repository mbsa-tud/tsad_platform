classdef TSAD_ABOD < TSADModel
    %TSAD_ABOD Angle based outlier detection

    methods (Access = protected)
        function [XTest, timeSeriesTest, labelsTest] =  prepareDataTest(obj, data, labels)
            %PREPAREDATATEST Prepares testing data

            [XTest, timeSeriesTest, labelsTest] = splitDataTest(data, labels, ...
                                                        obj.parameters.windowSize, ...
                                                        "reconstruction", 1);
        end
        
        function [anomalyScores, windowComputationTime] = predict(obj, Mdl, XTest, timeSeriesTest, labelsTest, getWindowComputationTime)
            %PREDICT Makes prediction on test data using the Mdl
            
            % Ignore comptation time as it is only of interest for DNNs
            windowComputationTime = NaN;
            
            % Rund ABOD
            [~, anomalyScores] = ABOD(XTest);

            % Merge overlapping anoamly scores
            anomalyScores = mergeOverlappingAnomalyScores(anomalyScores, obj.parameters.windowSize, @mean);
        end
    end
end







classdef TSAD_LOF < TSADModel
    %TSAD_LOF Local outlier factor

    methods (Access = protected)
        function [XTest, timeSeriesTest, labelsTest] =  prepareDataTest(obj, data, labels)
            %PREPAREDATATEST Prepares testing data

            [XTest, timeSeriesTest, labelsTest] = splitDataTest(data, labels, ...
                                                        obj.parameters.windowSize, ...
                                                        "reconstruction", 1);
        end
        
        function [anomalyScores, computationTime] = predict(obj, Mdl, XTest, timeSeriesTest, labelsTest, getComputationTime)
            %PREDICT Makes prediction on test data using the Mdl
            
            % Ignore comptation time as it is only of interest for DNNs
            computationTime = NaN;
            
            % Run LOD
            [~, anomalyScores] = LOF(XTest, obj.parameters.k);

            % Merge overlapping anoamly scores
            anomalyScores = mergeOverlappingAnomalyScores(anomalyScores, obj.parameters.windowSize, @mean);
        end
    end
end
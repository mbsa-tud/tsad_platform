classdef TSAD_ABOD < TSADModel
    %TSAD_ABOD Angle based outlier detection

    methods (Access = protected)
        function [XTest, TSTest, labelsTest] =  prepareDataTest(obj, data, labels)
            %PREPAREDATATEST Prepares testing data

            [XTest, TSTest, labelsTest] = splitDataTest(data, labels, ...
                                                        obj.parameters.windowSize, ...
                                                        "reconstructive", 1);
        end
        
        function [anomalyScores, computationTime] = predict(obj, Mdl, XTest, TSTest, labelsTest, getComputationTime)
            %PREDICT Makes prediction on test data using the Mdl
            
            % Ignore comptation time as it is only of interest for DNNs
            computationTime = NaN;
            
            % Rund ABOD
            [~, anomalyScores] = ABOD(XTest);

            % Merge overlapping anoamly scores
            anomalyScores = mergeOverlappingAnomalyScores(anomalyScores, obj.parameters.windowSize, @mean);
        end
    end
end







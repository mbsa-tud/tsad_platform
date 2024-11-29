classdef TSAD_MERLIN < TSADModel
    %TSAD_MERLIN MERLIN

    methods (Access = protected)
        function [XTest, timeSeriesTest, labelsTest] =  prepareDataTest(obj, data, labels)
            %PREPAREDATATEST Prepares testing data

            XTest = cell2mat(data);
            timeSeriesTest = XTest;
            labelsTest = cell2mat(labels);
        end
        
        function [anomalyScores, windowComputationTime] = predict(obj, Mdl, XTest, timeSeriesTest, labelsTest, getWindowComputationTime)
            %PREDICT Makes prediction on test data using the Mdl
            
            % Ignore comptation time as it is only of interest for DNNs
            windowComputationTime = NaN;
            
            % Find number of anomalies (required for MERLIN)
            numAnomalies = findNumAnomalies(labelsTest);
    
            if obj.parameters.minL < obj.parameters.maxL
                % Run MERLIN if minL is smaller than maxL
                [~, indices, ~] = runMERLIN(XTest, obj.parameters.minL, ...
                                                obj.parameters.maxL, numAnomalies);
                indices = sort(indices, 2);
                
                % Merge all indices of found anomalies of all sequence
                % lengths L (from minL to maxL)
                anomalyScores = zeros(length(XTest), size(indices, 1));
                for i = 1:size(indices, 1)
                    for j = 1:numAnomalies
                        anomalyScores(indices(i, j):(indices(i, j) + obj.parameters.minL - 2 + i)) = 1;
                    end
                end
                anomalyScores = any(anomalyScores, 2);
            else
                warning("Warning! minL (%d) must be less than maxL (%d) for MERLIN, setting anomaly scores to zero.", ...
                        obj.parameters.minL, obj.parameters.maxL);
                anomalyScores = zeros(length(XTest), 1);
            end

            % Convert to double array
            anomalyScores = double(anomalyScores);
        end
    end
end
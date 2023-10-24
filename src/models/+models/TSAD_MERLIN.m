classdef TSAD_MERLIN < TSADModel
    %TSAD_MERLIN MERLIN

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
            
            % Find number of anomalies (required for MERLIN)
            numAnomalies = findNumAnomalies(labelsTest);
    
            if obj.parameters.minL < obj.parameters.maxL
                % Run MERLIN if minL is smaller than maxL
                [~, indices, ~] = run_MERLIN(XTest,  obj.parameters.minL, ...
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
classdef TSAD_iForest < TSADModel
    %TSAD_iForest Isolation forest

    methods (Access = protected)
        function [XTrain, YTrain, XVal, YVal] = prepareDataTrain(obj, data, labels)
            %PREPAREDATATRAIN Prepares training data

            YTrain = [];
            XVal = [];
            YVal = [];

            [XTrain, ~, ~, ~] = splitDataTrain(data, ...
                                                obj.parameters.windowSize,  ...
                                                obj.parameters.stepSize,  ...
                                                0, "reconstruction", 1);
        end
        
        function [XTest, timeSeriesTest, labelsTest] =  prepareDataTest(obj, data, labels)
            %PREPAREDATATEST Prepares testing data

            [XTest, timeSeriesTest, labelsTest] = splitDataTest(data, labels, ...
                                                        obj.parameters.windowSize, ...
                                                        "reconstruction", 1);
        end
        
        function Mdl = fit(obj, XTrain, YTrain, XVal, YVal, plots, verbose)
            %FIT Trains the model

            [Mdl, ~, ~] = iforest(XTrain, NumLearners=obj.parameters.iTrees, NumObservationsPerLearner=obj.parameters.observationsPerITree);
        end
        
        function [anomalyScores, computationTime] = predict(obj, Mdl, XTest, timeSeriesTest, labelsTest, getComputationTime)
            %PREDICT Makes prediction on test data using the Mdl
            
            % Ignore comptation time as it is only of interest for DNNs
            computationTime = NaN;
            
            % Either semi-supervised or unsupervised anomlay detection
            if strcmp(obj.parameters.learningType, "unsupervised")
                [~, ~, anomalyScores] = iforest(XTest, NumLearners=obj.parameters.iTrees, ...
                                                NumObservationsPerLearner=obj.parameters.observationsPerITree);
            else
                [~, anomalyScores] = isanomaly(obj.Mdl, XTest);
            end
    
            % Merge overlapping anomaly scores
            anomalyScores = mergeOverlappingAnomalyScores(anomalyScores, obj.parameters.windowSize, @mean);
        end
    end
end







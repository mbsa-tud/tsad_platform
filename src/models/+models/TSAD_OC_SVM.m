classdef TSAD_OC_SVM < TSADModel
    %TSAD_OC_SVM One-class support vector machine

    methods (Access = protected)
        function [XTrain, YTrain, XVal, YVal] = prepareDataTrain(obj, data, labels)
            %PREPAREDATATRAIN Prepares training data

            YTrain = [];
            XVal = [];
            YVal = [];

            [XTrain, ~, ~, ~] = splitDataTrain(data, ...
                                                obj.parameters.windowSize,  ...
                                                obj.parameters.stepSize,  ...
                                                0, "reconstructive", 1);
        end
        
        function [XTest, TSTest, labelsTest] =  prepareDataTest(obj, data, labels)
            %PREPAREDATATEST Prepares testing data

            [XTest, TSTest, labelsTest] = splitDataTest(data, labels, ...
                                                        obj.parameters.windowSize, ...
                                                        "reconstructive", 1);
        end
        
        function Mdl = fit(obj, XTrain, YTrain, XVal, YVal, plots, verbose)
            %FIT Trains the model

            Mdl = ocsvm(XTrain, KernelScale="auto");
        end
        
        function [anomalyScores, computationTime] = predict(obj, Mdl, XTest, TSTest, labelsTest, getComputationTime)
            %PREDICT Makes prediction on test data using the Mdl
    
            % Ignore comptation time as it is only of interest for DNNs
            computationTime = NaN;
            
            % Either semi-supervised or unsupervised anomlay detection
            if strcmp(obj.learningType, "unsupervised")
                [~, ~, anomalyScores] = ocsvm(XTest, KernelScale="auto");
            else
                [~, anomalyScores] = isanomaly(Mdl, XTest);
            end
    
            % Merge overlapping anomaly scores
            anomalyScores = mergeOverlappingAnomalyScores(anomalyScores, obj.parameters.windowSize, @mean);
        end
    end
end







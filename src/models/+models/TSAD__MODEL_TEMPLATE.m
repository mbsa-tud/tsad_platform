classdef TSAD__MODEL_TEMPLATE < TSADModel
    %TSAD_LSTM LSTM for forecasting

    methods (Access = protected)
        function [XTrain, YTrain, XVal, YVal] = prepareDataTrain(obj, data, labels)
            %PREPAREDATATRAIN Prepares training data

            XTrain = []; % Training data
            YTrain = []; % Training labels
            XVal = []; % Validation data
            YVal = []; % Validation labels

            % Your training data preparation code goes here. This includes
            % for example the splitting into train and validation data and data
            % reshaping
        end
        
        function [XTest, timeSeriesTest, labelsTest] =  prepareDataTest(obj, data, labels)
            %PREPAREDATATEST Prepares testing data
            
            XTest = []; % Testing data as input for model
            timeSeriesTest = []; % Tested time series
            labelsTest = []; % Labels for tested time series

            % Your testing data preparation code goes here. This includes
            % for example data reshaping.
        end
        
        function Mdl = fit(obj, XTrain, YTrain, XVal, YVal, plots, verbose)
            %FIT Trains the model

            Mdl = []; % The trained model (can be empty for unsipervised models)

            % Train your model here and store it in the Mdl variable.
        end
        
        function [anomalyScores, windowComputationTime] = predict(obj, Mdl, XTest, timeSeriesTest, labelsTest, getWindowComputationTime)
            %PREDICT Makes prediction on test data using the Mdl
            
            anomalyScores = []; % The anomaly scores for the time series
            windowComputationTime = NaN; % The mean computation time per window (only relevant for DNNs)

            % Your prediction code goes here. It should either return
            % anomaly scores or detected anomalies as binary labels. In the
            % second case set the "outputType" filed of the config to
            % "labels"
        end

        function layers = getLayers(obj, XTrain, YTrain)
            %GETLAYERS Returns the layers of the neural network

            layers = []; % neural network layers object

            % If your model is a neural network you can implement this
            % function to create layers. This will make the layer preview
            % available for your model within the platform.
        end
    end
end







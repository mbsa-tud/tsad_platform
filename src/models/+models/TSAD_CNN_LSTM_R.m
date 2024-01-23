classdef TSAD_CNN_LSTM_R < TSADModel
    %TSAD_CNN_LSTM_R CNN-LSTM for reconstruction

    methods (Access = protected)
        function [XTrain, YTrain, XVal, YVal] = prepareDataTrain(obj, data, labels)
            %PREPAREDATATRAIN Prepares training data

            [XTrain, YTrain, XVal, YVal] = splitDataTrain(data, ...
                                                          obj.parameters.windowSize, ...
                                                          obj.parameters.stepSize,  ...
                                                          obj.parameters.valSize, ...
                                                          "reconstruction", ...
                                                          2);
        end
        
        function [XTest, timeSeriesTest, labelsTest] =  prepareDataTest(obj, data, labels)
            %PREPAREDATATEST Prepares testing data

            [XTest, timeSeriesTest, labelsTest] = splitDataTest(data, ...
                                                        labels, ...
                                                        obj.parameters.windowSize, ...
                                                        "reconstruction", ...
                                                        2);
        end
        
        function Mdl = fit(obj, XTrain, YTrain, XVal, YVal, plots, verbose)
            %FIT Trains the model

            layers = obj.getLayers(XTrain, YTrain);
            trainOptions = obj.getTrainOptions(XVal, YVal, size(XTrain, 1), plots, verbose);
            
            Mdl = trainNetwork(XTrain, YTrain, layers, trainOptions);
        end
        
        function [anomalyScores, windowComputationTime] = predict(obj, Mdl, XTest, timeSeriesTest, labelsTest, getWindowComputationTime)
            %PREDICT Makes prediction on test data using the Mdl
            
            [prediction, windowComputationTime] = predictWithDNN(Mdl, XTest, getWindowComputationTime);
            anomalyScores = getReconstructionErrors(prediction, ...
                                                    XTest, ...
                                                    timeSeriesTest, ...
                                                    obj.parameters.reconstructionErrorType, ...
                                                    obj.parameters.windowSize, ...
                                                    2);
        end

        function layers = getLayers(obj, XTrain, YTrain)
            %GETLAYERS Returns the layers of the neural network

            numFeatures = size(XTrain{1}, 1);
            numResponses = numFeatures;
            
            filter = obj.parameters.filter;
            hiddenUnits = obj.parameters.hiddenUnits;
            
            layers = [sequenceInputLayer(numFeatures)
                      convolution1dLayer(5, filter, Padding="same", DilationFactor=1)
                      batchNormalizationLayer()
                      reluLayer()
                      convolution1dLayer(5, filter, Padding="same", DilationFactor=1)
                      reluLayer()
                      lstmLayer(hiddenUnits)
                      dropoutLayer(0.25)
                      lstmLayer(hiddenUnits)
                      fullyConnectedLayer(numResponses)
                      regressionLayer()];
            
            layers = layerGraph(layers);
        end
    end

    methods (Access = private)
        function trainOptions = getTrainOptions(obj, XVal, YVal, numWindows, plots, verbose)
            %GETTRAINOPTIONS Gets training options for neural network

            if gpuDeviceCount > 0
                device = "gpu";
            else
                device = "cpu";
            end
            
            % Set different training options according to use of validation
            % data during training
            if obj.parameters.valSize == 0
                trainOptions = trainingOptions("adam", ...
                                                Plots=plots, ...
                                                Verbose=verbose, ...
                                                MaxEpochs=obj.parameters.epochs, ...
                                                MiniBatchSize=obj.parameters.minibatchSize, ...
                                                GradientThreshold=1, ...
                                                InitialLearnRate=obj.parameters.learningRate, ...
                                                Shuffle="every-epoch",...
                                                ExecutionEnvironment=device);
            else
                trainOptions = trainingOptions("adam", ...
                                                OutputNetwork="best-validation-loss", ...
                                                Plots=plots, ...
                                                Verbose=verbose, ...
                                                MaxEpochs=obj.parameters.epochs, ...
                                                MiniBatchSize=obj.parameters.minibatchSize, ...
                                                GradientThreshold=1, ...
                                                InitialLearnRate=obj.parameters.learningRate, ...
                                                Shuffle="every-epoch", ...
                                                ExecutionEnvironment=device, ...
                                                ValidationData={XVal, YVal}, ...
                                                ValidationFrequency=floor(numWindows / (3 * obj.parameters.minibatchSize)));
            end
        end
    end
end







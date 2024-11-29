classdef TSAD_FC_AE < TSADModel
    %TSAD_FC_AE Fully-Connected Autoencoder

    methods (Access = protected)
        function [XTrain, YTrain, XVal, YVal] = prepareDataTrain(obj, data, labels)
            %PREPAREDATATRAIN Prepares training data

            [XTrain, YTrain, XVal, YVal] = applySlidingWindowForTrain(data, ...
                                                                      obj.parameters.windowSize, ...
                                                                      obj.parameters.stepSize,  ...
                                                                      obj.parameters.valSize, ...
                                                                      "reconstruction", ...
                                                                      "BC");
        end
        
        function [XTest, timeSeriesTest, labelsTest] =  prepareDataTest(obj, data, labels)
            %PREPAREDATATEST Prepares testing data

            [XTest, timeSeriesTest, labelsTest] = applySlidingWindowForTest(data, ...
                                                                            labels, ...
                                                                            obj.parameters.windowSize, ...
                                                                            "reconstruction", ...
                                                                            "BC");
        end
        
        function Mdl = fit(obj, XTrain, YTrain, XVal, YVal, plots, verbose)
            %FIT Trains the model

            network = obj.getNetwork(XTrain, YTrain);
            trainOptions = obj.getTrainOptions(XVal, YVal, size(XTrain, 1), plots, verbose);
            
            Mdl = trainnet(XTrain, YTrain, network, "mean-squared-error", trainOptions);
        end
        
        function [anomalyScores, windowComputationTime] = predict(obj, Mdl, XTest, timeSeriesTest, labelsTest, getWindowComputationTime)
            %PREDICT Makes prediction on test data using the Mdl
            
            [prediction, windowComputationTime] = predictWithDNN(Mdl, XTest, getWindowComputationTime);
            anomalyScores = getReconstructionErrors(prediction, ...
                                                    XTest, ...
                                                    timeSeriesTest, ...
                                                    obj.parameters.reconstructionErrorType, ...
                                                    obj.parameters.windowSize, ...
                                                    "BC");
        end

        function network = getNetwork(obj, XTrain, YTrain)
            %GETNETWORK Returns the dlnetwork architecture

            numFeatures = size(XTrain, 2);
            numResponses = numFeatures;
        
            firstLayerNeurons = obj.parameters.firstLayerNeurons;

            layers = [inputLayer([obj.parameters.minibatchSize, numFeatures], "BC", Name="Input")
                      fullyConnectedLayer(firstLayerNeurons)
                      reluLayer()
                      fullyConnectedLayer(floor(firstLayerNeurons / 2))
                      reluLayer()
                      fullyConnectedLayer(floor(floor(firstLayerNeurons / 2) / 2))
                      reluLayer()
                      fullyConnectedLayer(floor(firstLayerNeurons / 2))
                      reluLayer()
                      fullyConnectedLayer(firstLayerNeurons)
                      reluLayer()
                      fullyConnectedLayer(numResponses)];
            
            network = dlnetwork(layers);
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







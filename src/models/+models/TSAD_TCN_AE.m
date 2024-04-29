classdef TSAD_TCN_AE < TSADModel
    %TSAD_TCN_AE TCN Autoencoder

    methods (Access = protected)
        function [XTrain, YTrain, XVal, YVal] = prepareDataTrain(obj, data, labels)
            %PREPAREDATATRAIN Prepares training data

            [XTrain, YTrain, XVal, YVal] = applySlidingWindowForTrain(data, ...
                                                                      obj.parameters.windowSize, ...
                                                                      obj.parameters.stepSize,  ...
                                                                      obj.parameters.valSize, ...
                                                                      "reconstruction", ...
                                                                      "cell_array");
        end
        
        function [XTest, timeSeriesTest, labelsTest] =  prepareDataTest(obj, data, labels)
            %PREPAREDATATEST Prepares testing data

            [XTest, timeSeriesTest, labelsTest] = applySlidingWindowForTest(data, ...
                                                                            labels, ...
                                                                            obj.parameters.windowSize, ...
                                                                            "reconstruction", ...
                                                                            "cell_array");
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

            if mod(obj.parameters.windowSize, 4) ~= 0
                error("Window size must be divisible by 4 for the TCN AE.");
            end
    
            numFeatures = size(XTrain{1, 1}, 1);
            numResponses = numFeatures;

            filter = obj.parameters.filter;
    
            layers = [sequenceInputLayer(numFeatures, MinLength=obj.parameters.windowSize, Name="Input")
            
                        convolution1dLayer(5, filter, Stride=1, Padding="causal", DilationFactor=1)
                        reluLayer()
                        layerNormalizationLayer()
                        dropoutLayer(0.25)
                        convolution1dLayer(5, filter, Stride=1, Padding="causal", DilationFactor=1)
                        reluLayer()
                        layerNormalizationLayer()
                        dropoutLayer(0.25)
                        additionLayer(2, Name="Add_1")
                        reluLayer()
            
                        convolution1dLayer(5, filter, Stride=1, Padding="causal", DilationFactor=2)
                        reluLayer()
                        layerNormalizationLayer()
                        dropoutLayer(0.25)
                        convolution1dLayer(5, filter, Stride=1, Padding="causal", DilationFactor=2)
                        reluLayer()
                        layerNormalizationLayer()
                        dropoutLayer(0.25)
                        additionLayer(2, Name="Add_2")
                        reluLayer()
            
            
            
                        convolution1dLayer(1, ceil(numFeatures / 4), Padding="same")
                        averagePooling1dLayer(4, Stride=4)
                        
                        transposedConv1dLayer(4, ceil(numFeatures / 4), Stride=4, Name="Upsample")
            
            
            
                        convolution1dLayer(5, filter, Stride=1, Padding="causal", DilationFactor=2)
                        reluLayer()
                        layerNormalizationLayer()
                        dropoutLayer(0.25)
                        convolution1dLayer(5, filter, Stride=1, Padding="causal", DilationFactor=2)
                        reluLayer()
                        layerNormalizationLayer()
                        dropoutLayer(0.25)
                        additionLayer(2, Name="Add_3")
                        reluLayer()
            
                        convolution1dLayer(5, filter, Stride=1, Padding="causal", DilationFactor=1)
                        reluLayer()
                        layerNormalizationLayer()
                        dropoutLayer(0.25)
                        convolution1dLayer(5, filter, Stride=1, Padding="causal", DilationFactor=1)
                        reluLayer()
                        layerNormalizationLayer()
                        dropoutLayer(0.25)
                        additionLayer(2, Name="Add_4")
                        reluLayer()
            
                        convolution1dLayer(1, numResponses, Padding="same")
            
                        regressionLayer(Name="Output")];

            layers = layerGraph(layers);
            layers = addLayers(layers, convolution1dLayer(1, filter, Stride=1, Name="Conv_skip_1"));
            layers = addLayers(layers, convolution1dLayer(1, filter, Stride=1, Name="Conv_skip_2"));
            layers = addLayers(layers, convolution1dLayer(1, filter, Stride=1, Name="Conv_skip_3"));
            layers = addLayers(layers, convolution1dLayer(1, filter, Stride=1, Name="Conv_skip_4"));
            layers = connectLayers(layers, "Input", "Conv_skip_1");
            layers = connectLayers(layers, "Conv_skip_1", "Add_1/in2");
            layers = connectLayers(layers, "Add_1", "Conv_skip_2");
            layers = connectLayers(layers, "Conv_skip_2", "Add_2/in2");
            layers = connectLayers(layers, "Upsample", "Conv_skip_3");
            layers = connectLayers(layers, "Conv_skip_3", "Add_3/in2");
            layers = connectLayers(layers, "Add_3", "Conv_skip_4");
            layers = connectLayers(layers, "Conv_skip_4", "Add_4/in2");
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







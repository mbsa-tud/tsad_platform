classdef TSAD_FC_AE < TSADModel
    %TSAD_FC_AE Fully-Connected Autoencoder

    methods (Access = protected)
        function [XTrain, YTrain, XVal, YVal] = prepareDataTrain(obj, data, labels)
            %PREPAREDATATRAIN Prepares training data

            [XTrain, YTrain, XVal, YVal] = splitDataTrain(data, ...
                                                          obj.parameters.windowSize, ...
                                                          obj.parameters.stepSize,  ...
                                                          obj.parameters.valSize, ...
                                                          obj.parameters.modelType, ...
                                                          1);
        end
        
        function [XTest, timeSeriesTest, labelsTest] =  prepareDataTest(obj, data, labels)
            %PREPAREDATATEST Prepares testing data

            [XTest, timeSeriesTest, labelsTest] = splitDataTest(data, ...
                                                        labels, ...
                                                        obj.parameters.windowSize, ...
                                                        obj.parameters.modelType, ...
                                                        1);
        end
        
        function Mdl = fit(obj, XTrain, YTrain, XVal, YVal, plots, verbose)
            %FIT Trains the model

            layers = obj.getLayers(XTrain, YTrain);
            trainOptions = obj.getTrainOptions(XVal, YVal, size(XTrain, 1), plots, verbose);
            
            Mdl = trainNetwork(XTrain, YTrain, layers, trainOptions);
        end
        
        function [anomalyScores, computationTime] = predict(obj, Mdl, XTest, timeSeriesTest, labelsTest, getComputationTime)
            %PREDICT Makes prediction on test data using the Mdl
            
            [prediction, computationTime] = predictWithDNN(Mdl, XTest, getComputationTime);
            anomalyScores = getReconstructionErrors(prediction, ...
                                                    XTest, ...
                                                    timeSeriesTest, ...
                                                    obj.parameters.reconstructionErrorType, ...
                                                    obj.parameters.windowSize, ...
                                                    1);
        end

        function layers = getLayers(obj, XTrain, YTrain)
            %GETLAYERS Returns the layers of the neural network

            numFeatures = size(XTrain, 2);
            numResponses = numFeatures;
        
            neurons = obj.parameters.neurons;

            layers = [featureInputLayer(numFeatures)
                      fullyConnectedLayer(neurons)
                      reluLayer()
                      fullyConnectedLayer(floor(neurons / 2))
                      reluLayer()
                      fullyConnectedLayer(floor(floor(neurons / 2) / 2))
                      reluLayer()
                      fullyConnectedLayer(floor(neurons / 2))
                      reluLayer()
                      fullyConnectedLayer(neurons)
                      reluLayer()
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







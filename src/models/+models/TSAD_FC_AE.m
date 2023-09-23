classdef TSAD_FC_AE < TSADModel
    %TSAD_FC_AE Fully-Connected AutoEncoder

    methods (Access = protected)
        function obj = initModelInfo(obj)
            %INITMODELINFO Initializes the modelInfo of this model
            
            obj.modelInfo.name = "FC-AE";
            obj.modelInfo.type = "deep_learning";
            obj.modelInfo.modelType = "reconstruction";
            obj.modelInfo.learningType = "semi_supervised";
            obj.modelInfo.outputType = "anomaly_scores";
            obj.modelInfo.dimensionality = "multivariate";
        end

        function [XTrain, YTrain, XVal, YVal] = prepareDataTrain(obj, data, labels)
            %PREPAREDATATRAIN Prepares training data

            [XTrain, YTrain, XVal, YVal] = splitDataTrain(data, ...
                                                          obj.hyperparameters.windowSize, ...
                                                          obj.hyperparameters.stepSize,  ...
                                                          obj.hyperparameters.valSize, ...
                                                          obj.modelInfo.modelType, ...
                                                          1);
        end
        
        function [XTest, TSTest, labelsTest] =  prepareDataTest(obj, data, labels)
            %PREPAREDATATEST Prepares testing data

            [XTest, TSTest, labelsTest] = splitDataTest(data, ...
                                                        labels, ...
                                                        obj.hyperparameters.windowSize, ...
                                                        obj.modelInfo.modelType, ...
                                                        1);
        end
        
        function Mdl = fit(obj, XTrain, YTrain, XVal, YVal, plots, verbose)
            %FIT Trains the model

            layers = obj.getLayers(XTrain, YTrain);
            trainOptions = obj.getTrainOptions(XVal, YVal, size(XTrain, 1), plots, verbose);
            
            Mdl = trainNetwork(XTrain, YTrain, layers, trainOptions);
        end
        
        function [anomalyScores, computationTime] = predict(obj, Mdl, XTest, TSTest, labelsTest, getComputationTime)
            %PREDICT Makes prediction on test data using the Mdl
            
            [prediction, computationTime] = predictWithDNN(Mdl, XTest, getComputationTime);
            anomalyScores = getReconstructionErrors(prediction, ...
                                                    XTest, ...
                                                    TSTest, ...
                                                    obj.hyperparameters.reconstructionErrorType, ...
                                                    obj.hyperparameters.windowSize, ...
                                                    1);
        end

        function layers = getLayers(obj, XTrain, YTrain)
            %GETLAYERS Returns the layers of the neural network

            numFeatures = size(XTrain, 2);
            numResponses = numFeatures;
        
            neurons = obj.hyperparameters.neurons;
            layers = [ ...
                featureInputLayer(numFeatures, Name="Input")
                fullyConnectedLayer(neurons, Name=strcat("Encode: Fully connected with ", num2str(neurons), " neurons"))
                reluLayer()
                fullyConnectedLayer(floor(neurons / 2), Name=strcat("Encode: Fully connected with ", num2str(floor(neurons/2)), " neurons"))
                reluLayer()
                fullyConnectedLayer(floor(floor(neurons / 2) / 2), Name=strcat("Encode: Fully connected with ", num2str(floor(floor(neurons/2)/2)), " neurons"))
                reluLayer()
                fullyConnectedLayer(floor(neurons / 2), Name=strcat("Decode:Fully connected with ", num2str(floor(neurons/2)), " neurons"))
                reluLayer()
                fullyConnectedLayer(neurons, Name=strcat("Decode: Fully connected with ", num2str(neurons), " neurons"))
                reluLayer()
                fullyConnectedLayer(numResponses, Name="Out")
                regressionLayer(Name="Output")];
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
            if obj.hyperparameters.valSize == 0
                trainOptions = trainingOptions("adam", ...
                                                Plots=plots, ...
                                                Verbose=verbose, ...
                                                MaxEpochs=obj.hyperparameters.epochs, ...
                                                MiniBatchSize=obj.hyperparameters.minibatchSize, ...
                                                GradientThreshold=1, ...
                                                InitialLearnRate=obj.hyperparameters.learningRate, ...
                                                Shuffle="every-epoch",...
                                                ExecutionEnvironment=device);
            else
                trainOptions = trainingOptions("adam", ...
                                                Plots=plots, ...
                                                Verbose=verbose, ...
                                                MaxEpochs=obj.hyperparameters.epochs, ...
                                                MiniBatchSize=obj.hyperparameters.minibatchSize, ...
                                                GradientThreshold=1, ...
                                                InitialLearnRate=obj.hyperparameters.learningRate, ...
                                                Shuffle="every-epoch", ...
                                                ExecutionEnvironment=device, ...
                                                ValidationData={XVal, YVal}, ...
                                                ValidationFrequency=floor(numWindows / (3 * obj.hyperparameters.minibatchSize)));
            end
        end
    end
end







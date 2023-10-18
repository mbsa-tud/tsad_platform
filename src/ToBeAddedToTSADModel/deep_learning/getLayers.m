function layers = getLayers(modelOptions, XTrain, YTrain)
%GETLAYERS Gets the layers for the DNN model specified in the modelOptions parameter

switch modelOptions.name
    case "Your model name"
    case "FC-AE"
        
    case "LSTM (reconstruction)"
        
    case "Hybrid CNN-LSTM (reconstruction)"
        
    case "TCN-AE"
        if mod(modelOptions.hyperparameters.windowSize, 4) ~= 0
            error("Window size must be divisible by 4 for the TCN AE.");
        end

        numFeatures = size(XTrain{1, 1}, 1);
        numResponses = numFeatures;

        layers = [ ...
            sequenceInputLayer(numFeatures, Name="Input", MinLength=modelOptions.hyperparameters.windowSize)

            convolution1dLayer(5, modelOptions.hyperparameters.filter, Stride=1, Padding="causal", WeightsInitializer="he", DilationFactor=1)
            reluLayer()
            layerNormalizationLayer()
            dropoutLayer(0.25)
            convolution1dLayer(5, modelOptions.hyperparameters.filter, Stride=1, Padding="causal", WeightsInitializer="he", DilationFactor=1)
            reluLayer()
            layerNormalizationLayer()
            dropoutLayer(0.25)
            additionLayer(2, Name="Add_1")
            reluLayer()

            convolution1dLayer(5, modelOptions.hyperparameters.filter, Stride=1, Padding="causal", WeightsInitializer="he", DilationFactor=2)
            reluLayer()
            layerNormalizationLayer()
            dropoutLayer(0.25)
            convolution1dLayer(5, modelOptions.hyperparameters.filter, Stride=1, Padding="causal", WeightsInitializer="he", DilationFactor=2)
            reluLayer()
            layerNormalizationLayer()
            dropoutLayer(0.25)
            additionLayer(2, Name="Add_2")
            reluLayer()



            convolution1dLayer(1, ceil(numFeatures / 4), Padding="same")
            averagePooling1dLayer(4, Stride=4)
            
            transposedConv1dLayer(4, ceil(numFeatures / 4), Stride=4, Name="Upsample")



            convolution1dLayer(5, modelOptions.hyperparameters.filter, Stride=1, Padding="causal", WeightsInitializer="he", DilationFactor=2)
            reluLayer()
            layerNormalizationLayer()
            dropoutLayer(0.25)
            convolution1dLayer(5, modelOptions.hyperparameters.filter, Stride=1, Padding="causal", WeightsInitializer="he", DilationFactor=2)
            reluLayer()
            layerNormalizationLayer()
            dropoutLayer(0.25)
            additionLayer(2, Name="Add_3")
            reluLayer()

            convolution1dLayer(5, modelOptions.hyperparameters.filter, Stride=1, Padding="causal", WeightsInitializer="he", DilationFactor=1)
            reluLayer()
            layerNormalizationLayer()
            dropoutLayer(0.25)
            convolution1dLayer(5, modelOptions.hyperparameters.filter, Stride=1, Padding="causal", WeightsInitializer="he", DilationFactor=1)
            reluLayer()
            layerNormalizationLayer()
            dropoutLayer(0.25)
            additionLayer(2, Name="Add_4")
            reluLayer()

            convolution1dLayer(1, numResponses, Padding="same")

            regressionLayer(Name="Output")];
        layers = layerGraph(layers);
        layers = addLayers(layers, convolution1dLayer(1, modelOptions.hyperparameters.filter, Stride=1, Name="Conv_skip_1"));
        layers = addLayers(layers, convolution1dLayer(1, modelOptions.hyperparameters.filter, Stride=1, Name="Conv_skip_2"));
        layers = addLayers(layers, convolution1dLayer(1, modelOptions.hyperparameters.filter, Stride=1, Name="Conv_skip_3"));
        layers = addLayers(layers, convolution1dLayer(1, modelOptions.hyperparameters.filter, Stride=1, Name="Conv_skip_4"));
        layers = connectLayers(layers, "Input", "Conv_skip_1");
        layers = connectLayers(layers, "Conv_skip_1", "Add_1/in2");
        layers = connectLayers(layers, "Add_1", "Conv_skip_2");
        layers = connectLayers(layers, "Conv_skip_2", "Add_2/in2");
        layers = connectLayers(layers, "Upsample", "Conv_skip_3");
        layers = connectLayers(layers, "Conv_skip_3", "Add_3/in2");
        layers = connectLayers(layers, "Add_3", "Conv_skip_4");
        layers = connectLayers(layers, "Conv_skip_4", "Add_4/in2");
    case "LSTM"
        numFeatures = size(XTrain{1, 1}, 1);
        numResponses = numFeatures;

        outputMode = "last";

        layers = [ ...
            sequenceInputLayer(numFeatures, MinLength=modelOptions.hyperparameters.windowSize)
            lstmLayer(modelOptions.hyperparameters.hiddenUnits)
            dropoutLayer(0.3)
            lstmLayer(modelOptions.hyperparameters.hiddenUnits, OutputMode=outputMode)
            fullyConnectedLayer(numResponses)
            regressionLayer];
        layers = layerGraph(layers);
    case "Hybrid CNN-LSTM"
        numFeatures = size(XTrain{1, 1}, 1);
        numResponses = numFeatures;

        outputMode = "last";

        layers = [ ...
            sequenceInputLayer(numFeatures, MinLength=modelOptions.hyperparameters.windowSize, Name="Input")
            convolution1dLayer(5, modelOptions.hyperparameters.filter, Padding="same", WeightsInitializer="he", DilationFactor=1)
            batchNormalizationLayer()
            reluLayer()
            convolution1dLayer(5, modelOptions.hyperparameters.filter, Padding="same", WeightsInitializer="he", DilationFactor=1)
            reluLayer()
            lstmLayer(modelOptions.hyperparameters.hiddenUnits, RecurrentWeightsInitializer="He", InputWeightsInitializer="He")
            dropoutLayer(0.25)
            lstmLayer(modelOptions.hyperparameters.hiddenUnits, RecurrentWeightsInitializer="He", InputWeightsInitializer="He", OutputMode=outputMode)
            fullyConnectedLayer(numResponses)
            regressionLayer()];
        layers = layerGraph(layers);
    case "GRU"
        numFeatures = size(XTrain{1, 1}, 1);
        numResponses = numFeatures;

        outputMode = "last";

        layers = [ ...
            sequenceInputLayer(numFeatures, MinLength=modelOptions.hyperparameters.windowSize)
            gruLayer(modelOptions.hyperparameters.hiddenUnits)
            dropoutLayer(0.3)
            gruLayer(modelOptions.hyperparameters.hiddenUnits, OutputMode=outputMode)
            fullyConnectedLayer(numResponses)
            regressionLayer];
        layers = layerGraph(layers);
    case "CNN (DeepAnT)"
        numFeatures = size(XTrain{1, 1}, 2);
        numResponses = numFeatures;

        layers = [ ...
            sequenceInputLayer([modelOptions.hyperparameters.windowSize numFeatures], Name="Input") % 1D image input would be better, but wasn't possible. This is a workaround
            
            convolution1dLayer(5, modelOptions.hyperparameters.filter, Stride=1, Padding="same", WeightsInitializer="he")
            reluLayer()
            maxPooling1dLayer(3, Padding="same", Name="Maxpool1")
            convolution1dLayer(5, modelOptions.hyperparameters.filter * 2, Stride=1, Padding="same", WeightsInitializer="he")
            reluLayer()
            maxPooling1dLayer(3, Padding="same", Name="Maxpool2")
            convolution1dLayer(5, modelOptions.hyperparameters.filter * 4, Stride=1, Padding="same", WeightsInitializer="he")
            reluLayer()
            maxPooling1dLayer(3, Padding="same", Name="Maxpool3")

            flattenLayer()
            fullyConnectedLayer(32)
            reluLayer()
            fullyConnectedLayer(numResponses)
            regressionLayer(Name="Output")];
        layers = layerGraph(layers);
    case "ResNet"
        numFeatures = size(XTrain{1, 1}, 2);
        numResponses = numFeatures;
        
        layers = [ ...
            sequenceInputLayer([modelOptions.hyperparameters.windowSize numFeatures], Name="Input") % 1D image input would be better, but wasn't possible. This is a workaround

            convolution1dLayer(5, modelOptions.hyperparameters.filter, Stride=1, Padding="same", WeightsInitializer="he")
            reluLayer(Name="ReLU 1")

            convolution1dLayer(5, modelOptions.hyperparameters.filter, Stride=1, Padding="same", WeightsInitializer="he")
            batchNormalizationLayer()
            reluLayer()
            convolution1dLayer(5, modelOptions.hyperparameters.filter, Stride=1, Padding="same", WeightsInitializer="he")
            batchNormalizationLayer()
            additionLayer(2, Name="Add")
            reluLayer()

            flattenLayer()
            fullyConnectedLayer(32)
            reluLayer()
            fullyConnectedLayer(numResponses)
            regressionLayer(Name="Output")];
        layers = layerGraph(layers);
        layers = connectLayers(layers, "ReLU 1", "Add/in2");
    case "MLP"
        numFeatures = size(XTrain, 2);
        numResponses = size(YTrain, 2);

        layers = [ ...
            featureInputLayer(numFeatures, Name="Input")
            fullyConnectedLayer(modelOptions.hyperparameters.neurons)
            reluLayer()
            fullyConnectedLayer(floor(modelOptions.hyperparameters.neurons / 2))
            reluLayer()
            fullyConnectedLayer(floor(modelOptions.hyperparameters.neurons / 4))
            reluLayer()
            fullyConnectedLayer(numResponses)
            regressionLayer(Name="Output")];
        layers = layerGraph(layers);
end
end

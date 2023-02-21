function layers = getLayers(options, numFeatures, numResponses)
%GETLAYERS
%
% Returns the layers for the DL model specified in the options parameter

switch options.model
    case 'FC AE'
        neurons = options.hyperparameters.model.neurons.value;
        layers = [featureInputLayer(numFeatures, Name='Input')
            fullyConnectedLayer(neurons, Name=strcat('Encode: Fully connected with ', num2str(neurons), ' neurons'))
            leakyReluLayer()
            fullyConnectedLayer(floor(neurons / 2), Name=strcat('Encode: Fully connected with ', num2str(floor(neurons/2)), ' neurons'))
            leakyReluLayer()
            fullyConnectedLayer(floor(floor(neurons / 2) / 2), Name=strcat('Encode: Fully connected with ', num2str(floor(floor(neurons/2)/2)), ' neurons'))
            leakyReluLayer()
            fullyConnectedLayer(floor(neurons / 2), Name=strcat("Decode:Fully connected with ", num2str(floor(neurons/2)), ' neurons'))
            leakyReluLayer()
            fullyConnectedLayer(neurons, Name=strcat('Decode: Fully connected with ', num2str(neurons), ' neurons'))
            leakyReluLayer()
            fullyConnectedLayer(numResponses, Name='Out')
            leakyReluLayer()
            regressionLayer(Name='Output')];
        layers = layerGraph(layers);
    case 'LSTM (r)'
        layers = [
            sequenceInputLayer(numFeatures, MinLength=options.hyperparameters.data.windowSize.value)
            lstmLayer(options.hyperparameters.model.hiddenUnits.value)
            dropoutLayer(0.3)
            lstmLayer(options.hyperparameters.model.hiddenUnits.value)
            fullyConnectedLayer(numResponses)
            regressionLayer];
        layers = layerGraph(layers);
    case 'Hybrid CNN-LSTM (r)'
        layers = [...
            sequenceInputLayer(numFeatures, MinLength=options.hyperparameters.data.windowSize.value)
            convolution1dLayer(5, options.hyperparameters.model.filter.value, Padding='same', WeightsInitializer='he', DilationFactor=1)
            batchNormalizationLayer()
            leakyReluLayer()
            convolution1dLayer(5, options.hyperparameters.model.filter.value, Padding='same', Weightsinitializer='he', DilationFactor=1)
            leakyReluLayer()
            lstmLayer(options.hyperparameters.model.hiddenUnits.value, RecurrentWeightsInitializer='He', InputWeightsInitializer='He')
            dropoutLayer(0.25)
            lstmLayer(options.hyperparameters.model.hiddenUnits.value, RecurrentWeightsInitializer='He', InputWeightsInitializer='He')
            fullyConnectedLayer(numResponses)
            regressionLayer()];
        layers = layerGraph(layers);
    case 'TCN AE'
        if mod(options.hyperparameters.data.windowSize.value, 4) ~= 0
            error("Window size must be divisible by 4 for the TCN AE.");
        end
        layers = [
            sequenceInputLayer(numFeatures, Name='Input', MinLength=options.hyperparameters.data.windowSize.value, Name='Input')

            convolution1dLayer(5, options.hyperparameters.model.filter.value, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=1)
            batchNormalizationLayer()
            leakyReluLayer()
            convolution1dLayer(5, options.hyperparameters.model.filter.value, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=1)
            batchNormalizationLayer()
            additionLayer(2, Name='Add_1')
            leakyReluLayer(Name='Relu_2')

            convolution1dLayer(5, options.hyperparameters.model.filter.value, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=2)
            batchNormalizationLayer()
            leakyReluLayer()
            convolution1dLayer(5, options.hyperparameters.model.filter.value, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=2)
            batchNormalizationLayer()
            additionLayer(2, Name='Add_2')
            leakyReluLayer()



            convolution1dLayer(1, ceil(numFeatures / 4), Padding='same')
            averagePooling1dLayer(4, Stride=4)
            
            transposedConv1dLayer(4, ceil(numFeatures / 4), Stride=4, Name='Upsample')



            convolution1dLayer(5, options.hyperparameters.model.filter.value, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=2)
            batchNormalizationLayer()
            leakyReluLayer()
            convolution1dLayer(5, options.hyperparameters.model.filter.value, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=2)
            batchNormalizationLayer()
            additionLayer(2, Name='Add_3')
            leakyReluLayer(Name='Relu_6')

            convolution1dLayer(5, options.hyperparameters.model.filter.value, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=1)
            batchNormalizationLayer()
            leakyReluLayer()
            convolution1dLayer(5, options.hyperparameters.model.filter.value, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=1)
            batchNormalizationLayer()
            additionLayer(2, Name='Add_4')
            leakyReluLayer()

            convolution1dLayer(1, numFeatures, Padding='same')

            regressionLayer(Name='Output')
            ];
        layers = layerGraph(layers);
        layers = addLayers(layers, convolution1dLayer(1, options.hyperparameters.model.filter.value, Stride=1, Name='Conv_skip_1'));
        layers = addLayers(layers, convolution1dLayer(1, options.hyperparameters.model.filter.value, Stride=1, Name='Conv_skip_2'));
        layers = addLayers(layers, convolution1dLayer(1, options.hyperparameters.model.filter.value, Stride=1, Name='Conv_skip_3'));
        layers = addLayers(layers, convolution1dLayer(1, options.hyperparameters.model.filter.value, Stride=1, Name='Conv_skip_4'));
        layers = connectLayers(layers, "Input", "Conv_skip_1");
        layers = connectLayers(layers, "Conv_skip_1", "Add_1/in2");
        layers = connectLayers(layers, "Relu_2", "Conv_skip_2");
        layers = connectLayers(layers, "Conv_skip_2", "Add_2/in2");
        layers = connectLayers(layers, "Upsample", "Conv_skip_3");
        layers = connectLayers(layers, "Conv_skip_3", "Add_3/in2");
        layers = connectLayers(layers, "Relu_6", "Conv_skip_4");
        layers = connectLayers(layers, "Conv_skip_4", "Add_4/in2");
    case 'LSTM'
        outputMode = 'last';

        layers = [
            sequenceInputLayer(numFeatures, MinLength=options.hyperparameters.data.windowSize.value)
            lstmLayer(options.hyperparameters.model.hiddenUnits.value)
            dropoutLayer(0.3)
            lstmLayer(options.hyperparameters.model.hiddenUnits.value, OutputMode=outputMode)
            fullyConnectedLayer(numResponses)
            regressionLayer];
        layers = layerGraph(layers);
    case 'Hybrid CNN-LSTM'
        outputMode = 'last';

        layers = [...
            sequenceInputLayer(numFeatures, MinLength=options.hyperparameters.data.windowSize.value, Name='Input')
            convolution1dLayer(5, options.hyperparameters.model.filter.value, Padding='same', WeightsInitializer='he', DilationFactor=1)
            batchNormalizationLayer()
            leakyReluLayer()
            convolution1dLayer(5, options.hyperparameters.model.filter.value, Padding='same', WeightsInitializer='he', DilationFactor=1)
            leakyReluLayer()
            lstmLayer(options.hyperparameters.model.hiddenUnits.value, RecurrentWeightsInitializer='He', InputWeightsInitializer='He')
            dropoutLayer(0.25)
            lstmLayer(options.hyperparameters.model.hiddenUnits.value, RecurrentWeightsInitializer='He', InputWeightsInitializer='He', OutputMode=outputMode)
            fullyConnectedLayer(numResponses)
            regressionLayer()];
        layers = layerGraph(layers);
    case 'GRU'
        outputMode = 'last';

        layers = [
            sequenceInputLayer(numFeatures, MinLength=options.hyperparameters.data.windowSize.value)
            gruLayer(options.hyperparameters.model.hiddenUnits.value)
            dropoutLayer(0.3)
            gruLayer(options.hyperparameters.model.hiddenUnits.value, OutputMode=outputMode)
            fullyConnectedLayer(numResponses)
            regressionLayer];
        layers = layerGraph(layers);
    case 'CNN (DeepAnT)'
        layers = [
            sequenceInputLayer([options.hyperparameters.data.windowSize.value numFeatures], Name='Input')
            sequenceFoldingLayer(Name='Fold')

            convolution1dLayer(5, options.hyperparameters.model.filter.value, Stride=1, Padding='same', WeightsInitializer='he')
            leakyReluLayer()
            maxPooling1dLayer(3, Padding='same', Name='Maxpool1')
            convolution1dLayer(5, options.hyperparameters.model.filter.value * 2, Stride=1, Padding='same', WeightsInitializer='he')
            leakyReluLayer()
            maxPooling1dLayer(3, Padding='same', Name='Maxpool2')
            convolution1dLayer(5, options.hyperparameters.model.filter.value * 4, Stride=1, Padding='same', WeightsInitializer='he')
            leakyReluLayer()
            maxPooling1dLayer(3, Padding='same', Name='Maxpool3')

            sequenceUnfoldingLayer(Name='Unfold')
            flattenLayer()
            fullyConnectedLayer(32)
            leakyReluLayer()
            fullyConnectedLayer(numResponses)
            regressionLayer(Name='Output')
            ];
        layers = layerGraph(layers);
        layers = connectLayers(layers, 'Fold/miniBatchSize', 'Unfold/miniBatchSize');
    case 'ResNet'
        layers = [
            sequenceInputLayer([options.hyperparameters.data.windowSize.value numFeatures], Name='Input')
            sequenceFoldingLayer(Name='Fold')

            convolution1dLayer(5, options.hyperparameters.model.filter.value, Stride=1, Padding='same', WeightsInitializer='he')
            leakyReluLayer(Name='ReLU 1')

            convolution1dLayer(5, options.hyperparameters.model.filter.value, Stride=1, Padding='same', WeightsInitializer='he')
            batchNormalizationLayer()
            leakyReluLayer()
            convolution1dLayer(5, options.hyperparameters.model.filter.value, Stride=1, Padding='same', WeightsInitializer='he')
            batchNormalizationLayer()
            additionLayer(2, Name='Add')
            leakyReluLayer()                        

            sequenceUnfoldingLayer(Name='Unfold')
            flattenLayer()
            fullyConnectedLayer(32)
            leakyReluLayer()
            fullyConnectedLayer(numResponses)
            regressionLayer(Name='Output')
            ];
        layers = layerGraph(layers);
        layers = connectLayers(layers, 'ReLU 1', 'Add/in2');
        layers = connectLayers(layers, 'Fold/miniBatchSize', 'Unfold/miniBatchSize');
    case 'MLP'
        layers = [
            featureInputLayer(numFeatures, Name='Input')
            fullyConnectedLayer(options.hyperparameters.model.neurons.value)
            leakyReluLayer()
            fullyConnectedLayer(floor(options.hyperparameters.model.neurons.value / 2))
            leakyReluLayer()
            fullyConnectedLayer(floor(options.hyperparameters.model.neurons.value / 4))
            leakyReluLayer()
            fullyConnectedLayer(numResponses)
            regressionLayer(Name='Output')
            ];
        layers = layerGraph(layers);
end
end

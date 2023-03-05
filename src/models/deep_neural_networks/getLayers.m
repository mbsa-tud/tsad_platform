function layers = getLayers(options, numFeatures, numResponses)
%GETLAYERS
%
% Returns the layers for the DL model specified in the options parameter

switch options.model
    case 'FC AE'
        neurons = options.hyperparameters.neurons.value;
        layers = [featureInputLayer(numFeatures, Name='Input')
            fullyConnectedLayer(neurons, Name=strcat('Encode: Fully connected with ', num2str(neurons), ' neurons'))
            reluLayer()
            fullyConnectedLayer(floor(neurons / 2), Name=strcat('Encode: Fully connected with ', num2str(floor(neurons/2)), ' neurons'))
            reluLayer()
            fullyConnectedLayer(floor(floor(neurons / 2) / 2), Name=strcat('Encode: Fully connected with ', num2str(floor(floor(neurons/2)/2)), ' neurons'))
            reluLayer()
            fullyConnectedLayer(floor(neurons / 2), Name=strcat("Decode:Fully connected with ", num2str(floor(neurons/2)), ' neurons'))
            reluLayer()
            fullyConnectedLayer(neurons, Name=strcat('Decode: Fully connected with ', num2str(neurons), ' neurons'))
            reluLayer()
            fullyConnectedLayer(numResponses, Name='Out')
            regressionLayer(Name='Output')];
        layers = layerGraph(layers);
    case 'LSTM (reconstruction)'
        layers = [
            sequenceInputLayer(numFeatures, MinLength=options.hyperparameters.windowSize.value)
            lstmLayer(options.hyperparameters.hiddenUnits.value)
            dropoutLayer(0.3)
            lstmLayer(options.hyperparameters.hiddenUnits.value)
            fullyConnectedLayer(numResponses)
            regressionLayer];
        layers = layerGraph(layers);
    case 'Hybrid CNN-LSTM (reconstruction)'
        layers = [...
            sequenceInputLayer(numFeatures, MinLength=options.hyperparameters.windowSize.value)
            convolution1dLayer(5, options.hyperparameters.filter.value, Padding='same', WeightsInitializer='he', DilationFactor=1)
            batchNormalizationLayer()
            reluLayer()
            convolution1dLayer(5, options.hyperparameters.filter.value, Padding='same', Weightsinitializer='he', DilationFactor=1)
            reluLayer()
            lstmLayer(options.hyperparameters.hiddenUnits.value, RecurrentWeightsInitializer='He', InputWeightsInitializer='He')
            dropoutLayer(0.25)
            lstmLayer(options.hyperparameters.hiddenUnits.value, RecurrentWeightsInitializer='He', InputWeightsInitializer='He')
            fullyConnectedLayer(numResponses)
            regressionLayer()];
        layers = layerGraph(layers);
    case 'TCN AE'
        if mod(options.hyperparameters.windowSize.value, 4) ~= 0
            error("Window size must be divisible by 4 for the TCN AE.");
        end
        layers = [
            sequenceInputLayer(numFeatures, Name='Input', MinLength=options.hyperparameters.windowSize.value, Name='Input')

            convolution1dLayer(5, options.hyperparameters.filter.value, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=1)
            batchNormalizationLayer()
            reluLayer()
            convolution1dLayer(5, options.hyperparameters.filter.value, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=1)
            batchNormalizationLayer()
            additionLayer(2, Name='Add_1')
            reluLayer(Name='Relu_2')

            convolution1dLayer(5, options.hyperparameters.filter.value, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=2)
            batchNormalizationLayer()
            reluLayer()
            convolution1dLayer(5, options.hyperparameters.filter.value, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=2)
            batchNormalizationLayer()
            additionLayer(2, Name='Add_2')
            reluLayer()



            convolution1dLayer(1, ceil(numFeatures / 4), Padding='same')
            averagePooling1dLayer(4, Stride=4)
            
            transposedConv1dLayer(4, ceil(numFeatures / 4), Stride=4, Name='Upsample')



            convolution1dLayer(5, options.hyperparameters.filter.value, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=2)
            batchNormalizationLayer()
            reluLayer()
            convolution1dLayer(5, options.hyperparameters.filter.value, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=2)
            batchNormalizationLayer()
            additionLayer(2, Name='Add_3')
            reluLayer(Name='Relu_6')

            convolution1dLayer(5, options.hyperparameters.filter.value, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=1)
            batchNormalizationLayer()
            reluLayer()
            convolution1dLayer(5, options.hyperparameters.filter.value, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=1)
            batchNormalizationLayer()
            additionLayer(2, Name='Add_4')
            reluLayer()

            convolution1dLayer(1, numFeatures, Padding='same')

            regressionLayer(Name='Output')
            ];
        layers = layerGraph(layers);
        layers = addLayers(layers, convolution1dLayer(1, options.hyperparameters.filter.value, Stride=1, Name='Conv_skip_1'));
        layers = addLayers(layers, convolution1dLayer(1, options.hyperparameters.filter.value, Stride=1, Name='Conv_skip_2'));
        layers = addLayers(layers, convolution1dLayer(1, options.hyperparameters.filter.value, Stride=1, Name='Conv_skip_3'));
        layers = addLayers(layers, convolution1dLayer(1, options.hyperparameters.filter.value, Stride=1, Name='Conv_skip_4'));
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
            sequenceInputLayer(numFeatures, MinLength=options.hyperparameters.windowSize.value)
            lstmLayer(options.hyperparameters.hiddenUnits.value)
            dropoutLayer(0.3)
            lstmLayer(options.hyperparameters.hiddenUnits.value, OutputMode=outputMode)
            fullyConnectedLayer(numResponses)
            regressionLayer];
        layers = layerGraph(layers);
    case 'Hybrid CNN-LSTM'
        outputMode = 'last';

        layers = [...
            sequenceInputLayer(numFeatures, MinLength=options.hyperparameters.windowSize.value, Name='Input')
            convolution1dLayer(5, options.hyperparameters.filter.value, Padding='same', WeightsInitializer='he', DilationFactor=1)
            batchNormalizationLayer()
            reluLayer()
            convolution1dLayer(5, options.hyperparameters.filter.value, Padding='same', WeightsInitializer='he', DilationFactor=1)
            reluLayer()
            lstmLayer(options.hyperparameters.hiddenUnits.value, RecurrentWeightsInitializer='He', InputWeightsInitializer='He')
            dropoutLayer(0.25)
            lstmLayer(options.hyperparameters.hiddenUnits.value, RecurrentWeightsInitializer='He', InputWeightsInitializer='He', OutputMode=outputMode)
            fullyConnectedLayer(numResponses)
            regressionLayer()];
        layers = layerGraph(layers);
    case 'GRU'
        outputMode = 'last';

        layers = [
            sequenceInputLayer(numFeatures, MinLength=options.hyperparameters.windowSize.value)
            gruLayer(options.hyperparameters.hiddenUnits.value)
            dropoutLayer(0.3)
            gruLayer(options.hyperparameters.hiddenUnits.value, OutputMode=outputMode)
            fullyConnectedLayer(numResponses)
            regressionLayer];
        layers = layerGraph(layers);
    case 'CNN (DeepAnT)'
        layers = [
            sequenceInputLayer([options.hyperparameters.windowSize.value numFeatures], Name='Input')
            sequenceFoldingLayer(Name='Fold')

            convolution1dLayer(5, options.hyperparameters.filter.value, Stride=1, Padding='same', WeightsInitializer='he')
            reluLayer()
            maxPooling1dLayer(3, Padding='same', Name='Maxpool1')
            convolution1dLayer(5, options.hyperparameters.filter.value * 2, Stride=1, Padding='same', WeightsInitializer='he')
            reluLayer()
            maxPooling1dLayer(3, Padding='same', Name='Maxpool2')
            convolution1dLayer(5, options.hyperparameters.filter.value * 4, Stride=1, Padding='same', WeightsInitializer='he')
            reluLayer()
            maxPooling1dLayer(3, Padding='same', Name='Maxpool3')

            sequenceUnfoldingLayer(Name='Unfold')
            flattenLayer()
            fullyConnectedLayer(32)
            reluLayer()
            fullyConnectedLayer(numResponses)
            regressionLayer(Name='Output')
            ];
        layers = layerGraph(layers);
        layers = connectLayers(layers, 'Fold/miniBatchSize', 'Unfold/miniBatchSize');
    case 'ResNet'
        layers = [
            sequenceInputLayer([options.hyperparameters.windowSize.value numFeatures], Name='Input')
            sequenceFoldingLayer(Name='Fold')

            convolution1dLayer(5, options.hyperparameters.filter.value, Stride=1, Padding='same', WeightsInitializer='he')
            reluLayer(Name='ReLU 1')

            convolution1dLayer(5, options.hyperparameters.filter.value, Stride=1, Padding='same', WeightsInitializer='he')
            batchNormalizationLayer()
            reluLayer()
            convolution1dLayer(5, options.hyperparameters.filter.value, Stride=1, Padding='same', WeightsInitializer='he')
            batchNormalizationLayer()
            additionLayer(2, Name='Add')
            reluLayer()                        

            sequenceUnfoldingLayer(Name='Unfold')
            flattenLayer()
            fullyConnectedLayer(32)
            reluLayer()
            fullyConnectedLayer(numResponses)
            regressionLayer(Name='Output')
            ];
        layers = layerGraph(layers);
        layers = connectLayers(layers, 'ReLU 1', 'Add/in2');
        layers = connectLayers(layers, 'Fold/miniBatchSize', 'Unfold/miniBatchSize');
    case 'MLP'
        layers = [
            featureInputLayer(numFeatures, Name='Input')
            fullyConnectedLayer(options.hyperparameters.neurons.value)
            reluLayer()
            fullyConnectedLayer(floor(options.hyperparameters.neurons.value / 2))
            reluLayer()
            fullyConnectedLayer(floor(options.hyperparameters.neurons.value / 4))
            reluLayer()
            fullyConnectedLayer(numResponses)
            regressionLayer(Name='Output')
            ];
        layers = layerGraph(layers);
end
end

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
        layers = [
            sequenceInputLayer(numFeatures, Name='Input', MinLength=options.hyperparameters.data.windowSize.value)

            convolution1dLayer(5, options.hyperparameters.model.filter.value, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=1)
            leakyReluLayer()
            dropoutLayer(0.25)
            convolution1dLayer(5, options.hyperparameters.model.filter.value, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=2)
            leakyReluLayer()
            dropoutLayer(0.25)

            convolution1dLayer(1, numFeatures, Padding='same')
            averagePooling1dLayer(4, Stride=4)
            
            transposedConv1dLayer(4, numFeatures, Stride=4)
            convolution1dLayer(5, options.hyperparameters.model.filter.value, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=1)
            leakyReluLayer()
            dropoutLayer(0.25)
            convolution1dLayer(5, options.hyperparameters.model.filter.value, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=2)
            leakyReluLayer()
            dropoutLayer(0.25)

            convolution1dLayer(1, numFeatures, Padding='same')

            regressionLayer(Name='Output')
            ];
        layers = layerGraph(layers);
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
            sequenceInputLayer([options.hyperparameters.data.windowsize.value numFeatures 1], Name='Input')
            sequenceFoldingLayer(Name='Fold')

            convolution2dLayer(5, options.hyperparameters.model.filter.value, Stride=1, Padding='same', WeightsInitializer='he')
            leakyReluLayer()
            maxPooling2dLayer(3, Padding='same', Name='Maxpool1')
            convolution2dLayer(5, options.hyperparameters.model.filter.value * 2, Stride=1, Padding='same', WeightsInitializer='he')
            leakyReluLayer()
            maxPooling2dLayer(3, Padding='same', Name='Maxpool2')
            convolution2dLayer(5, options.hyperparameters.model.filter.value * 4, Stride=1, Padding='same', WeightsInitializer='he')
            leakyReluLayer()
            maxPooling2dLayer(3, Padding='same', Name='Maxpool3')

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
            sequenceInputLayer([options.hyperparameters.data.windowsize.value numFeatures 1], Name='Input')
            sequenceFoldingLayer(Name='Fold')

            convolution2dLayer(5, options.hyperparameters.model.filter.value, Stride=1, Padding='same', WeightsInitializer='he')
            leakyReluLayer(Name='ReLU 1')

            convolution2dLayer(5, options.hyperparameters.model.filter.value, Stride=1, Padding='same', WeightsInitializer='he')
            batchNormalizationLayer()
            leakyReluLayer()
            convolution2dLayer(5, options.hyperparameters.model.filter.value, Stride=1, Padding='same', WeightsInitializer='he')
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

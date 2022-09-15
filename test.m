numFeatures = 1;

layers = [
    sequenceInputLayer(numFeatures, Name='Input', MinLength=32)
    convolution1dLayer(5, 32, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=1);
    convolution1dLayer(5, 32, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=2);
    convolution1dLayer(5, 32, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=4);
    convolution1dLayer(1, 8, Padding='same');
    averagePooling1dLayer(4, Stride=4);
    
    transposedConv1dLayer(4, 8, Stride=4)
    convolution1dLayer(5, 32, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=1);
    convolution1dLayer(5, 32, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=2);
    convolution1dLayer(5, 32, Stride=1, Padding='causal', WeightsInitializer='he', DilationFactor=4);

    convolution1dLayer(1, numFeatures, Padding='same');

    regressionLayer(Name='Output')
    ];
layers = layerGraph(layers);
analyzeNetwork(layers);
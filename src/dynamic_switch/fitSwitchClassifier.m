function net = fitSwitchClassifier(XTrain, labelName)
%FITSWITCHCLASSIFIER
%
% Trains the dynamic switch DNN classifier

classNames = categories(XTrain{:, labelName});
numFeatures = size(XTrain, 2) - 1;
numClasses = numel(classNames);

miniBatchSize = 64;

options = trainingOptions('adam', ...
    'InitialLearnRate', 0.01, ...
    'MaxEpochs', 1500, ...
    'MiniBatchSize', miniBatchSize, ...
    'Shuffle', 'every-epoch', ...
    'Plots', 'training-progress', ...
    'Verbose', false);

layers = [
    featureInputLayer(numFeatures)
    fullyConnectedLayer(50)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

net = trainNetwork(XTrain, labelName, layers, options);
end
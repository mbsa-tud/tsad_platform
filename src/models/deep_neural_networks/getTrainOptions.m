function trainOptions = getTrainOptions(modelOptions, XVal, YVal, numWindows, plots)
%GETTRAINOPTIONS Gets training options for training DNN models

if gpuDeviceCount > 0
    device = 'gpu';
else
    device = 'cpu';
end

switch modelOptions.name
    case 'Your model name'
    otherwise
        if modelOptions.hyperparameters.ratioTrainVal.value == 0
            trainOptions = trainingOptions('adam', ...
                'Plots', plots, ...
                'MaxEpochs', modelOptions.hyperparameters.epochs.value, ...
                'MiniBatchSize', modelOptions.hyperparameters.minibatchSize.value, ...
                'GradientThreshold', 1, ...
                'InitialLearnRate', modelOptions.hyperparameters.learningRate.value, ...
                'Shuffle', 'every-epoch',...
                'ExecutionEnvironment', device);
        else
            trainOptions = trainingOptions('adam', ...
                'Plots', plots, ...
                'MaxEpochs', modelOptions.hyperparameters.epochs.value, ...
                'MiniBatchSize', modelOptions.hyperparameters.minibatchSize.value, ...
                'GradientThreshold', 1, ...
                'InitialLearnRate', modelOptions.hyperparameters.learningRate.value, ...
                'Shuffle', 'every-epoch', ...
                'ExecutionEnvironment', device, ...
                'ValidationData', {XVal, YVal}, ...
                'ValidationFrequency', floor(numWindows / (3 * modelOptions.hyperparameters.minibatchSize.value)));
        end
end
end

function trainOptions = getOptions(options, XVal, YVal, numWindows, plots)
%GETOPTIONS
%
% Returns the training options for training of DL models

if gpuDeviceCount > 0
    device = 'gpu';
else
    device = 'cpu';
end

switch options.model
    case 'FC AE'
        if options.hyperparameters.training.ratioTrainVal.value == 0
            trainOptions = trainingOptions("adam", ...
                "Plots", plots, ...
                "MaxEpochs", options.hyperparameters.training.epochs.value, ...
                "MiniBatchSize", options.hyperparameters.training.minibatchSize.value, ...
                'GradientThreshold', 1, ...
                "InitialLearnRate", options.hyperparameters.training.learningRate.value, ...
                'Shuffle', "every-epoch",...
                'ExecutionEnvironment', device);
        else
            trainOptions = trainingOptions("adam", ...
                "Plots", plots, ...
                "MaxEpochs", options.hyperparameters.training.epochs.value, ...
                "MiniBatchSize", options.hyperparameters.training.minibatchSize.value, ...
                'GradientThreshold', 1, ...
                "InitialLearnRate", options.hyperparameters.training.learningRate.value, ...
                'ExecutionEnvironment', device, ...
                "ValidationData", {XVal, YVal}, ...
                'Shuffle', "every-epoch",...
                "ValidationFrequency", floor(numWindows / (3 * options.hyperparameters.training.minibatchSize.value)));
        end
    case 'LSTM (r)'
        if options.hyperparameters.training.ratioTrainVal.value == 0
            trainOptions = trainingOptions("adam", ...
                "Plots", plots, ...
                "MaxEpochs", options.hyperparameters.training.epochs.value, ...
                "MiniBatchSize", options.hyperparameters.training.minibatchSize.value, ...
                'GradientThreshold', 1, ...
                "InitialLearnRate", options.hyperparameters.training.learningRate.value, ...
                'Shuffle', "every-epoch",...
                'ExecutionEnvironment', device);
        else
            trainOptions = trainingOptions("adam", ...
                "Plots", plots, ...
                "MaxEpochs", options.hyperparameters.training.epochs.value, ...
                "MiniBatchSize", options.hyperparameters.training.minibatchSize.value, ...
                'GradientThreshold', 1, ...
                "InitialLearnRate", options.hyperparameters.training.learningRate.value, ...
                'ExecutionEnvironment', device, ...
                "ValidationData", {XVal, YVal}, ...
                'Shuffle', "every-epoch",...
                "ValidationFrequency", floor(numWindows / (3 * options.hyperparameters.training.minibatchSize.value)));
        end
    case 'Hybrid CNN-LSTM (r)'            
        if options.hyperparameters.training.ratioTrainVal.value == 0
            trainOptions = trainingOptions('adam', ...
                'MaxEpochs', options.hyperparameters.training.epochs.value, ...
                'GradientThreshold', 1, ...
                'InitialLearnRate', options.hyperparameters.training.learningRate.value, ...
                'MiniBatchSize', options.hyperparameters.training.minibatchSize.value,...
                'Verbose', false, ...
                'Shuffle', "every-epoch",...
                'ExecutionEnvironment', device,...
                'Plots', plots);
        else
            trainOptions = trainingOptions('adam', ...
                'MaxEpochs', options.hyperparameters.training.epochs.value, ...
                'GradientThreshold', 1, ...
                'InitialLearnRate', options.hyperparameters.training.learningRate.value, ...
                'MiniBatchSize', options.hyperparameters.training.minibatchSize.value,...
                'Verbose', false, ...
                'Shuffle', "every-epoch",...
                'ExecutionEnvironment', device,...
                'Plots', plots, ...
                "ValidationData", {XVal, YVal}, ...
                "ValidationFrequency", floor(numWindows / (3 * options.hyperparameters.training.minibatchSize.value)));
        end
    case 'TCN AE'
        if options.hyperparameters.training.ratioTrainVal.value == 0
            trainOptions = trainingOptions("adam", ...
                "Plots", plots, ...
                "MaxEpochs", options.hyperparameters.training.epochs.value, ...
                "MiniBatchSize", options.hyperparameters.training.minibatchSize.value, ...
                'GradientThreshold', 1, ...
                "InitialLearnRate", options.hyperparameters.training.learningRate.value, ...
                'Shuffle', "every-epoch",...
                'ExecutionEnvironment', device);
        else
            trainOptions = trainingOptions("adam", ...
                "Plots", plots, ...
                "MaxEpochs", options.hyperparameters.training.epochs.value, ...
                "MiniBatchSize", options.hyperparameters.training.minibatchSize.value, ...
                'GradientThreshold', 1, ...
                "InitialLearnRate", options.hyperparameters.training.learningRate.value, ...
                'ExecutionEnvironment', device, ...
                "ValidationData", {XVal, YVal}, ...
                'Shuffle', "every-epoch",...
                "ValidationFrequency", floor(numWindows / (3 * options.hyperparameters.training.minibatchSize.value)));
        end
    case 'LSTM'
        if options.hyperparameters.training.ratioTrainVal.value == 0
            trainOptions = trainingOptions("adam", ...
                "Plots", plots, ...
                "MaxEpochs", options.hyperparameters.training.epochs.value, ...
                "MiniBatchSize", options.hyperparameters.training.minibatchSize.value, ...
                'GradientThreshold', 1, ...
                "InitialLearnRate", options.hyperparameters.training.learningRate.value, ...
                'Shuffle', "every-epoch",...
                'ExecutionEnvironment', device);
        else
            trainOptions = trainingOptions("adam", ...
                "Plots", plots, ...
                "MaxEpochs", options.hyperparameters.training.epochs.value, ...
                "MiniBatchSize", options.hyperparameters.training.minibatchSize.value, ...
                'GradientThreshold', 1, ...
                "InitialLearnRate", options.hyperparameters.training.learningRate.value, ...
                'ExecutionEnvironment', device, ...
                "ValidationData", {XVal, YVal}, ...
                'Shuffle', "every-epoch",...
                "ValidationFrequency", floor(numWindows / (3 * options.hyperparameters.training.minibatchSize.value)));
        end
    case 'Hybrid CNN-LSTM'
        if options.hyperparameters.training.ratioTrainVal.value == 0
            trainOptions = trainingOptions('adam', ...
                'MaxEpochs', options.hyperparameters.training.epochs.value, ...
                'GradientThreshold', 1, ...
                'InitialLearnRate', options.hyperparameters.training.learningRate.value, ...
                'MiniBatchSize', options.hyperparameters.training.minibatchSize.value,...
                'Verbose', false, ...
                'Shuffle', "every-epoch",...
                'ExecutionEnvironment', device,...
                'Plots', plots);
        else
            trainOptions = trainingOptions('adam', ...
                'MaxEpochs', options.hyperparameters.training.epochs.value, ...
                'GradientThreshold', 1, ...
                'InitialLearnRate', options.hyperparameters.training.learningRate.value, ...
                'MiniBatchSize', options.hyperparameters.training.minibatchSize.value,...
                'Verbose', false, ...
                'Shuffle', "every-epoch",...
                'ExecutionEnvironment', device,...
                'Plots',plots, ...
                "ValidationData", {XVal, YVal}, ...
                "ValidationFrequency", floor(numWindows / (3 * options.hyperparameters.training.minibatchSize.value)));
        end
    case 'GRU'
        if options.hyperparameters.training.ratioTrainVal.value == 0
            trainOptions = trainingOptions("adam", ...
                "Plots", plots, ...
                "MaxEpochs", options.hyperparameters.training.epochs.value, ...
                "MiniBatchSize", options.hyperparameters.training.minibatchSize.value, ...
                'GradientThreshold', 1, ...
                "InitialLearnRate", options.hyperparameters.training.learningRate.value, ...
                'Shuffle', "every-epoch",...
                'ExecutionEnvironment', device);
        else
            trainOptions = trainingOptions("adam", ...
                "Plots", plots, ...
                "MaxEpochs", options.hyperparameters.training.epochs.value, ...
                "MiniBatchSize", options.hyperparameters.training.minibatchSize.value, ...
                'GradientThreshold', 1, ...
                "InitialLearnRate", options.hyperparameters.training.learningRate.value, ...
                'ExecutionEnvironment', device, ...
                "ValidationData", {XVal, YVal}, ...
                'Shuffle', "every-epoch",...
                "ValidationFrequency", floor(numWindows / (3 * options.hyperparameters.training.minibatchSize.value)));
        end
    case 'CNN (DeepAnT)'
        if options.hyperparameters.training.ratioTrainVal.value == 0
            trainOptions = trainingOptions('adam', ...
                'MaxEpochs', options.hyperparameters.training.epochs.value, ...
                'GradientThreshold', 1, ...
                'InitialLearnRate', options.hyperparameters.training.learningRate.value, ...
                'MiniBatchSize', options.hyperparameters.training.minibatchSize.value,...
                'Verbose', false, ...
                'Shuffle', "every-epoch",...
                'ExecutionEnvironment', device,...
                'Plots', plots);
        else
            trainOptions = trainingOptions('adam', ...
                'MaxEpochs', options.hyperparameters.training.epochs.value, ...
                'GradientThreshold', 1, ...
                'InitialLearnRate', options.hyperparameters.training.learningRate.value, ...
                'MiniBatchSize', options.hyperparameters.training.minibatchSize.value,...
                'Verbose', false, ...
                'Shuffle', "every-epoch",...
                'ExecutionEnvironment', device,...
                'Plots', plots, ...
                "ValidationData", {XVal, YVal}, ...
                "ValidationFrequency", floor(numWindows / (3 * options.hyperparameters.training.minibatchSize.value)));
        end
    case 'ResNet'
        if options.hyperparameters.training.ratioTrainVal.value == 0
            trainOptions = trainingOptions('adam', ...
                'Plots', plots, ...
                'MaxEpochs', options.hyperparameters.training.epochs.value, ...
                'GradientThreshold', 1, ...
                'InitialLearnRate', options.hyperparameters.training.learningRate.value, ...
                'MiniBatchSize', options.hyperparameters.training.minibatchSize.value,...
                'Verbose', false, ...
                'Shuffle', "every-epoch",...
                'ExecutionEnvironment', device);
        else
            trainOptions = trainingOptions('adam', ...
                'Plots', plots, ...
                'MaxEpochs', options.hyperparameters.training.epochs.value, ...
                'GradientThreshold', 1, ...
                'InitialLearnRate', options.hyperparameters.training.learningRate.value, ...
                'MiniBatchSize', options.hyperparameters.training.minibatchSize.value,...
                'Verbose', false, ...
                'Shuffle', "every-epoch",...
                'ExecutionEnvironment', device,...
                "ValidationData", {XVal, YVal}, ...
                "ValidationFrequency", floor(numWindows / (3 * options.hyperparameters.training.minibatchSize.value)));
        end
    case 'MLP'
        if options.hyperparameters.training.ratioTrainVal.value == 0
            trainOptions = trainingOptions('adam', ...
                'MaxEpochs', options.hyperparameters.training.epochs.value, ...
                'GradientThreshold', 1, ...
                'InitialLearnRate', options.hyperparameters.training.learningRate.value, ...
                'MiniBatchSize', options.hyperparameters.training.minibatchSize.value,...
                'Verbose', false, ...
                'Shuffle', "every-epoch",...
                'ExecutionEnvironment', device,...
                'Plots', plots);
        else
            trainOptions = trainingOptions('adam', ...
                'MaxEpochs', options.hyperparameters.training.epochs.value, ...
                'GradientThreshold', 1, ...
                'InitialLearnRate', options.hyperparameters.training.learningRate.value, ...
                'MiniBatchSize', options.hyperparameters.training.minibatchSize.value,...
                'Verbose', false, ...
                'Shuffle', "every-epoch",...
                'ExecutionEnvironment', device,...
                'Plots', plots, ...
                "ValidationData", {XVal, YVal}, ...
                "ValidationFrequency", floor(numWindows / (3 * options.hyperparameters.training.minibatchSize.value)));
        end
end
end

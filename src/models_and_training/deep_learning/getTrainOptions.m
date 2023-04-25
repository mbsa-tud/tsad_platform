function trainOptions = getTrainOptions(modelOptions, XVal, YVal, numWindows, plots, verbose)
%GETTRAINOPTIONS Gets training options for training DNN models

if gpuDeviceCount > 0
    device = "gpu";
else
    device = "cpu";
end

switch modelOptions.name
    case "Your model name"
    otherwise
        if modelOptions.hyperparameters.ratioTrainVal == 0
            trainOptions = trainingOptions("adam", ...
                Plots=plots, ...
                Verbose=verbose, ...
                MaxEpochs=modelOptions.hyperparameters.epochs, ...
                MiniBatchSize=modelOptions.hyperparameters.minibatchSize, ...
                GradientThreshold=1, ...
                InitialLearnRate=modelOptions.hyperparameters.learningRate, ...
                Shuffle="every-epoch",...
                ExecutionEnvironment=device);
        else
            trainOptions = trainingOptions("adam", ...
                Plots=plots, ...
                Verbose=verbose, ...
                MaxEpochs=modelOptions.hyperparameters.epochs, ...
                MiniBatchSize=modelOptions.hyperparameters.minibatchSize, ...
                GradientThreshold=1, ...
                InitialLearnRate=modelOptions.hyperparameters.learningRate, ...
                Shuffle="every-epoch", ...
                ExecutionEnvironment=device, ...
                ValidationData={XVal, YVal}, ...
                ValidationFrequency=floor(numWindows / (3 * modelOptions.hyperparameters.minibatchSize)));
        end
end
end

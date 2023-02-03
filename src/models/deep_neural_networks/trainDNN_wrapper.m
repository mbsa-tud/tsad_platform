function [Mdl, MdlInfo] = trainDNN_wrapper(options, XTrain, YTrain, XVal, YVal, trainingPlots, trainParallel)
%TRAINDNN
%
% Train DL models

if options.isMultivariate
    [Mdl, MdlInfo] = trainDNN(options, XTrain{1, 1}, YTrain{1, 1}, XVal{1, 1}, YVal{1, 1}, trainingPlots);
    Mdl = {Mdl};
    MdlInfo = {MdlInfo};
else
    numChannels = size(XTrain, 2);

    % Train the same model for each channel seperately
    % if trainParallel is set to true, training is done in
    % parallel
    if trainParallel
        models = [];
        for i = 1:numChannels
            modelInfo.options = options;
            models = [models modelInfo];
        end
        [Mdl, MdlInfo] = trainDNN_Parallel(models, XTrain, YTrain, XVal, YVal, true);
    else
        Mdl = cell(numChannels, 1);
        MdlInfo = cell(numChannels, 1);

        for i = 1:numChannels
            [Mdl{i, 1}, MdlInfo{i, 1}] = trainDNN(options, XTrain{1, i}, YTrain{1, i}, XVal{1, i}, YVal{1, i}, trainingPlots);
        end
    end
end
end
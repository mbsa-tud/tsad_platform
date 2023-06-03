function [XTrain, YTrain, XVal, YVal] = dataTrainPreparationWrapper(modelOptions, data, labels)
%DATATRAINPREPARATIONWRAPPER Training data preparation wrapper function

if strcmp(modelOptions.dimensionality, "multivariate")
    [XTrain, YTrain, XVal, YVal] = prepareDataTrain(modelOptions, data, labels);
    XTrain = {XTrain};
    YTrain = {YTrain};
    XVal = {XVal};
    YVal = {YVal};
else
    numChannels = size(data{1}, 2);

    XTrain = cell(1, numChannels);
    YTrain = cell(1, numChannels);
    XVal = cell(1, numChannels);
    YVal = cell(1, numChannels);

    for channel_idx = 1:numChannels
        data_tmp = cell(numel(data), 1);
        for j = 1:numel(data)
            data_tmp{j} = data{j}(:, channel_idx);
        end

        [XTrain{channel_idx}, YTrain{channel_idx}, XVal{channel_idx}, YVal{channel_idx}] = prepareDataTrain(modelOptions, data_tmp, labels);
    end
end
end

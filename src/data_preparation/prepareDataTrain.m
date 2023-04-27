function [XTrain, YTrain, XVal, YVal] = prepareDataTrain(modelOptions, data, labels)
%PREPAREDATATRAIN Training data preparation wrapper function

if modelOptions.isMultivariate
    switch modelOptions.type
        case "deep-learning"
            [XTrain, YTrain, XVal, YVal] = prepareDataTrain_DL(modelOptions, data, labels);
            XTrain = {XTrain};
            YTrain = {YTrain};
            XVal = {XVal};
            YVal = {YVal};
        otherwise
            [XTrain, YTrain] = prepareDataTrain_Other(modelOptions, data, labels);
            XTrain = {XTrain};
            YTrain = {YTrain};
    end
else
    numChannels = size(data{1}, 2);

    switch modelOptions.type
        case "deep-learning"
            XTrain = cell(1, numChannels);
            YTrain = cell(1, numChannels);
            XVal = cell(1, numChannels);
            YVal = cell(1, numChannels);
        
            for channel_idx = 1:numChannels
                data_tmp = cell(numel(data), 1);
                for j = 1:numel(data)
                    data_tmp{j} = data{j}(:, channel_idx);
                end
        
                [XTrain{channel_idx}, YTrain{channel_idx}, XVal{channel_idx}, YVal{channel_idx}] = prepareDataTrain_DL(modelOptions, data_tmp, labels);
            end
        otherwise
            XTrain = cell(1, numChannels);
            YTrain = cell(1, numChannels);
        
            for channel_idx = 1:numChannels
                data_tmp = cell(numel(data), 1);
                for j = 1:numel(data)
                    data_tmp{j} = data{j}(:, channel_idx);
                end
        
                [XTrain{channel_idx}, YTrain{channel_idx}] = prepareDataTrain_Other(modelOptions, data_tmp, labels);
            end
    end
end
end

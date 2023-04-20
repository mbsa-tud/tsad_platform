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
    numChannels = size(data{1, 1}, 2);

    switch modelOptions.type
        case "deep-learning"
            XTrain = cell(1, numChannels);
            YTrain = cell(1, numChannels);
            XVal = cell(1, numChannels);
            YVal = cell(1, numChannels);
        
            for channel_idx = 1:numChannels
                data_tmp = cell(size(data));
                for j = 1:size(data, 1)
                    data_tmp{j, 1} = data{j, 1}(:, channel_idx);
                end
        
                [XTrain{1, channel_idx}, YTrain{1, channel_idx}, XVal{1, channel_idx}, YVal{1, channel_idx}] = prepareDataTrain_DL(modelOptions, data_tmp, labels);
            end
        otherwise
            XTrain = cell(1, numChannels);
            YTrain = cell(1, numChannels);
        
            for channel_idx = 1:numChannels
                data_tmp = cell(size(data));
                for j = 1:size(data, 1)
                    data_tmp{j, 1} = data{j, 1}(:, channel_idx);
                end
        
                [XTrain{1, channel_idx}, YTrain{1, channel_idx}] = prepareDataTrain_Other(modelOptions, data_tmp, labels);
            end
    end
end
end

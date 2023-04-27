function [XTest, YTest, labelsTest] = prepareDataTest(modelOptions, data, labels)
%PREPAREDATATEST Testing data preparation wrapper function

if modelOptions.isMultivariate
    switch modelOptions.type
        case "deep-learning"
            [XTest, YTest, labelsTest] = prepareDataTest_DL(modelOptions, data, labels);
            XTest = {XTest};
            YTest = {YTest};
        otherwise
            [XTest, YTest, labelsTest] = prepareDataTest_Other(modelOptions, data, labels);
            XTest = {XTest};
            YTest = {YTest};
    end
else
    numChannels = size(data{1}, 2);

    switch modelOptions.type
        case "deep-learning"
            XTest = cell(1, numChannels);
            YTest = cell(1, numChannels);
        
            for channel_idx = 1:numChannels
                data_tmp = cell(numel(data), 1);
                for j = 1:numel(data)
                    data_tmp{j} = data{j}(:, channel_idx);
                end
        
                [XTest{channel_idx}, YTest{channel_idx}, labelsTest] = prepareDataTest_DL(modelOptions, data_tmp, labels);
            end
        otherwise
            XTest = cell(1, numChannels);
            YTest = cell(1, numChannels);
        
            for channel_idx = 1:numChannels
                data_tmp = cell(numel(data), 1);
                for j = 1:numel(data)
                    data_tmp{j} = data{j}(:, channel_idx);
                end
        
                [XTest{channel_idx}, YTest{channel_idx}, labelsTest] = prepareDataTest_Other(modelOptions, data_tmp, labels);
            end
    end
end
end

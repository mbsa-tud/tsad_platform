function [XTest, YTest, labelsTest] = prepareDataTest(modelOptions, data, labels)
%PREPAREDATATEST Testing data preparation wrapper function

if modelOptions.isMultivariate
    switch modelOptions.type
        case 'DNN'
            [XTest, YTest, labelsTest] = prepareDataTest_DNN(modelOptions, data, labels);
            XTest = {XTest};
            YTest = {YTest};
        case 'CML'
            [XTest, YTest, labelsTest] = prepareDataTest_CML(modelOptions, data, labels);
            XTest = {XTest};
            YTest = {YTest};
        case 'S'
            [XTest, YTest, labelsTest] = prepareDataTest_S(modelOptions, data, labels);
            XTest = {XTest};
            YTest = {YTest};
    end
else
    numChannels = size(data{1, 1}, 2);

    switch modelOptions.type
        case 'DNN'
            XTest = cell(1, numChannels);
            YTest = cell(1, numChannels);
        
            for channel_idx = 1:numChannels
                data_tmp = cell(size(data));
                for j = 1:size(data, 1)
                    data_tmp{j, 1} = data{j, 1}(:, channel_idx);
                end
        
                [XTest{1, channel_idx}, YTest{1, channel_idx}, labelsTest] = prepareDataTest_DNN(modelOptions, data_tmp, labels);
            end
        case 'CML'
            XTest = cell(1, numChannels);
            YTest = cell(1, numChannels);
        
            for channel_idx = 1:numChannels
                data_tmp = cell(size(data));
                for j = 1:size(data, 1)
                    data_tmp{j, 1} = data{j, 1}(:, channel_idx);
                end
        
                [XTest{1, channel_idx}, YTest{1, channel_idx}, labelsTest] = prepareDataTest_CML(modelOptions, data_tmp, labels);
            end
        case 'S'
            XTest = cell(1, numChannels);
            YTest = cell(1, numChannels);
        
            for channel_idx = 1:numChannels
                data_tmp = cell(size(data));
                for j = 1:size(data, 1)
                    data_tmp{j, 1} = data{j, 1}(:, channel_idx);
                end
        
                [XTest{1, channel_idx}, YTest{1, channel_idx}, labelsTest] = prepareDataTest_S(modelOptions, data_tmp, labels);
            end
    end
end
end

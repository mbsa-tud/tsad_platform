function [XTest, TSTest, labelsTest] = dataTestPreparationWrapper(modelOptions, data, labels)
%DATATESTPREPARATIONWRAPPER Testing data preparation wrapper function

if strcmp(modelOptions.dimensionality, "multivariate")
    [XTest, TSTest, labelsTest] = prepareDataTest(modelOptions, data, labels);
    XTest = {XTest};
    TSTest = {TSTest};
else
    numChannels = size(data{1}, 2);
    XTest = cell(1, numChannels);
    TSTest = cell(1, numChannels);

    for channel_idx = 1:numChannels
        data_tmp = cell(numel(data), 1);
        for j = 1:numel(data)
            data_tmp{j} = data{j}(:, channel_idx);
        end

        [XTest{channel_idx}, TSTest{channel_idx}, labelsTest] = prepareDataTest(modelOptions, data_tmp, labels);
    end
end
end

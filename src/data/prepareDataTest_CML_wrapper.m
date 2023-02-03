function [XTest, YTest, labelsTest] = prepareDataTest_CML_wrapper(options, data, labels)
%PREPAREDATATEST_CML
%
% Prepares the testing data for classic ML models

if options.isMultivariate
    [XTest, YTest, labelsTest] = prepareDataTest_CML(options, data, labels);
    XTest = {XTest};
    YTest = {YTest};
else
    numChannels = size(data{1, 1}, 2);
    XTest = cell(1, numChannels);
    YTest = cell(1, numChannels);

    for i = 1:numChannels
        data_tmp = cell(size(data));
        for j = 1:size(data, 1)
            data_tmp{j, 1} = data{j, 1}(:, i);
        end

        [XTest{1, i}, YTest{1, i}, labelsTest] = prepareDataTest_CML(options, data_tmp, labels);
    end
end
end


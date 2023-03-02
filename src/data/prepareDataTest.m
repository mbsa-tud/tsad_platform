function [XTest, YTest, labelsTest] = prepareDataTest(options, data, labels)
%PREPAREDATATEST_DNN
%
% Prepares the testing data for DL models

if options.isMultivariate
    switch options.type
        case 'DNN'
            [XTest, YTest, labelsTest] = prepareDataTest_DNN(options, data, labels);
            XTest = {XTest};
            YTest = {YTest};
        case 'CML'
            [XTest, YTest, labelsTest] = prepareDataTest_CML(options, data, labels);
            XTest = {XTest};
            YTest = {YTest};
        case 'S'
            [XTest, YTest, labelsTest] = prepareDataTest_S(options, data, labels);
            XTest = {XTest};
            YTest = {YTest};
    end
else
    numChannels = size(data{1, 1}, 2);

    switch options.type
        case 'DNN'
            XTest = cell(1, numChannels);
            YTest = cell(1, numChannels);
        
            for i = 1:numChannels
                data_tmp = cell(size(data));
                for j = 1:size(data, 1)
                    data_tmp{j, 1} = data{j, 1}(:, i);
                end
        
                [XTest{1, i}, YTest{1, i}, labelsTest] = prepareDataTest_DNN(options, data_tmp, labels);
            end
        case 'CML'
            XTest = cell(1, numChannels);
            YTest = cell(1, numChannels);
        
            for i = 1:numChannels
                data_tmp = cell(size(data));
                for j = 1:size(data, 1)
                    data_tmp{j, 1} = data{j, 1}(:, i);
                end
        
                [XTest{1, i}, YTest{1, i}, labelsTest] = prepareDataTest_CML(options, data_tmp, labels);
            end
        case 'S'
            XTest = cell(1, numChannels);
            YTest = cell(1, numChannels);
        
            for i = 1:numChannels
                data_tmp = cell(size(data));
                for j = 1:size(data, 1)
                    data_tmp{j, 1} = data{j, 1}(:, i);
                end
        
                [XTest{1, i}, YTest{1, i}, labelsTest] = prepareDataTest_S(options, data_tmp, labels);
            end
    end
end
end

function [XTrain, YTrain, XVal, YVal] = prepareDataTrain(options, data, labels)
%PREPAREDATATRAIN_DNN
%
% Prepares the training data for DL models

if options.isMultivariate
    switch options.type
        case 'DNN'
            [XTrain, YTrain, XVal, YVal] = prepareDataTrain_DNN(options, data, labels);
            XTrain = {XTrain};
            YTrain = {YTrain};
            XVal = {XVal};
            YVal = {YVal};
        case 'CML'
            [XTrain, YTrain] = prepareDataTrain_CML(options, data, labels);
            XTrain = {XTrain};
            YTrain = {YTrain};
        case 'S'
            [XTrain, YTrain] = prepareDataTrain_S(options, data, labels);
            XTrain = {XTrain};
            YTrain = {YTrain};
    end
else
    numChannels = size(data{1, 1}, 2);

    switch options.type
        case 'DNN'
            XTrain = cell(1, numChannels);
            YTrain = cell(1, numChannels);
            XVal = cell(1, numChannels);
            YVal = cell(1, numChannels);
        
            for i = 1:numChannels
                data_tmp = cell(size(data));
                for j = 1:size(data, 1)
                    data_tmp{j, 1} = data{j, 1}(:, i);
                end
        
                [XTrain{1, i}, YTrain{1, i}, XVal{1, i}, YVal{1, i}] = prepareDataTrain_DNN(options, data_tmp, labels);
            end
        case 'CML'
            XTrain = cell(1, numChannels);
            YTrain = cell(1, numChannels);
        
            for i = 1:numChannels
                data_tmp = cell(size(data));
                for j = 1:size(data, 1)
                    data_tmp{j, 1} = data{j, 1}(:, i);
                end
        
                [XTrain{1, i}, YTrain{1, i}] = prepareDataTrain_CML(options, data_tmp, labels);
            end
        case 'S'
            XTrain = cell(1, numChannels);
            YTrain = cell(1, numChannels);
            
            for i = 1:numChannels
                data_tmp = cell(size(data));
                for j = 1:size(data, 1)
                    data_tmp{j, 1} = data{j, 1}(:, i);
                end
        
                [XTrain{1, i}, YTrain{1, i}] = prepareDataTrain_S(options, data_tmp, labels);
            end
    end
end
end

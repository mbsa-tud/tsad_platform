function [XTrain, YTrain, XVal, YVal] = prepareDataTrain_DNN_wrapper(options, data, labels)
%PREPAREDATATRAIN_DNN
%
% Prepares the training data for DL models

if options.isMultivariate
    [XTrain, YTrain, XVal, YVal] = prepareDataTrain_DNN(options, data, labels);
    XTrain = {XTrain};
    YTrain = {YTrain};
    XVal = {XVal};
    YVal = {YVal};
else
    numChannels = size(data{1, 1}, 2);
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
end
end

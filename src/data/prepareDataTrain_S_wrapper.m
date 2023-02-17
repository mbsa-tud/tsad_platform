function XTrain = prepareDataTrain_S_wrapper(options, data, labels)
%PREPAREDATATRAIN_DNN
%
% Prepares the training data for DL models

if options.isMultivariate
    XTrain = prepareDataTrain_S(options, data, labels);
    XTrain = {XTrain};
else
    numChannels = size(data{1, 1}, 2);
    XTrain = cell(1, numChannels);
    
    for i = 1:numChannels
        data_tmp = cell(size(data));
        for j = 1:size(data, 1)
            data_tmp{j, 1} = data{j, 1}(:, i);
        end

        XTrain{1, i} = prepareDataTrain_S(options, data_tmp, labels);
    end
end
end

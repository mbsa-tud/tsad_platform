function [XTrain, labelName] = getDataTrain_Switch(data, labels, files)
%GETDATATRAIN_SWITCH Prepares the training data for the dynamic switch

labelName = 'best_model';

fields = fieldnames(labels);

XTrain = [];

for data_idx = 1:numel(fields)
    [~, file_idx] = ismember(fields{data_idx}, files);

    % Convert time series to feature vector
    XTrain_tmp = diagnosticFeatures(data{file_idx, 1});
    XTrain_tmp.(labelName) = convertCharsToStrings(labels.(fields{data_idx}).id);
    XTrain = [XTrain; XTrain_tmp];
end

XTrain = convertvars(XTrain, labelName, 'categorical');
end

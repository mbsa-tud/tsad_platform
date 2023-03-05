function [XTrain, labelName] = getDataTrain_Switch(data, labels, files)
%GETDATATRAIN_SWITCH
%
% Prepares the training data for the dynamic switch ba extracting the time
% series features

labelName = 'best_model';

fields = fieldnames(labels);

XTrain = [];

for i = 1:numel(fields)
    [~, fileIdx] = ismember(fields{i}, files);

    % Convert time series to feature vector
    XTrain_tmp = diagnosticFeatures(data{fileIdx, 1});
    XTrain_tmp.(labelName) = convertCharsToStrings(labels.(fields{i}).id);
    XTrain = [XTrain; XTrain_tmp];
end

XTrain = convertvars(XTrain, labelName, 'categorical');
end

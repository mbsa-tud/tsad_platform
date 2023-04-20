function [XTrain, labelName] = getDataTrain_Switch(data, labels, files)
%GETDATATRAIN_SWITCH Prepares the training data for the dynamic switch

labelName = "best_model";

labeledFiles = fieldnames(labels);

XTrain = [];

for labeledFile_idx = 1:numel(labeledFiles)
    [exists, file_idx] = ismember(labeledFiles{labeledFile_idx}, files);

    if ~exists
        continue;
    end

    % Convert time series to feature vector
    XTrain_tmp = diagnosticFeatures(data{file_idx, 1});
    XTrain_tmp.(labelName) = convertCharsToStrings(labels.(labeledFiles{labeledFile_idx}).id);
    XTrain = [XTrain; XTrain_tmp];
end

XTrain = convertvars(XTrain, labelName, "categorical");
end

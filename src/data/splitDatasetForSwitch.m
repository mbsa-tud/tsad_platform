function [data, labels, files, dataSwitch, labelsSwitch, filesSwitch] = splitDatasetForSwitch(data, labels, files, ratio)
% SPLITTESTVAL 
% 
% Split testing data into testing set and test-validation set

if size(data, 1) > 1
    idx = 1:size(data, 1);
    splitPoint = min([floor(ratio * size(data, 1)), size(data, 1) - 1]);
    if splitPoint == 0
        splitPoint = 1;
    end

    dataSwitch = data(idx(1:splitPoint), 1);
    labelsSwitch = labels(idx(1:splitPoint), 1);
    data = data(idx((splitPoint + 1):end), 1);
    labels = labels(idx((splitPoint + 1):end), 1);

    if ~isempty(files)
        filesSwitch = files(1, idx(1:splitPoint));
        files = files(1, idx((splitPoint + 1):end));
    end
else
    error("Dynamic switch can only be used for dataset with multiple anomalous testing files!");     
end
end
function [dataTest, labelsTest, fileNamesTest, dataSwitch, labelsSwitch, fileNamesSwitch] = splitDatasetForDynamicSwitch(dataTest, labelsTest, fileNamesTest, ratio)
%SPLITDATASETFORDYNAMICSWITCH Splits a multiple-test-file dataset into a
%test set and a test set for the dynamic switch mechanism

numTestFiles = numel(dataTest);

if numTestFiles > 1
    idx = 1:numTestFiles;
    splitPoint = min([floor(ratio * numTestFiles), numTestFiles - 1]);
    if splitPoint == 0
        splitPoint = 1;
    end

    dataSwitch = dataTest(idx(1:splitPoint));
    labelsSwitch = labelsTest(idx(1:splitPoint));
    dataTest = dataTest(idx((splitPoint + 1):end));
    labelsTest = labelsTest(idx((splitPoint + 1):end));

    if ~isempty(fileNamesTest)
        fileNamesSwitch = fileNamesTest(idx(1:splitPoint));
        fileNamesTest = fileNamesTest(idx((splitPoint + 1):end));
    end
else
    error("Dynamic switch can only be used for dataset with multiple anomalous testing files!");     
end
end
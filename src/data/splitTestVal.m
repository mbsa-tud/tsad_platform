function [dataTest, labelsTest, dataValTest, labelsValTest, fileNamesTest] = splitTestVal(dataTest, labelsTest, ratio, fileNamesTest)
% SPLITTESTVAL 
% 
% Split testing data into testing set and validation set

if size(dataTest, 1) > 1
    idx = randperm(size(dataTest, 1));
    splitPoint = ceil(ratio * size(dataTest, 1));

    dataValTest = dataTest(idx(1:splitPoint), 1);
    labelsValTest = labelsTest(idx(1:splitPoint), 1);
    dataTest = dataTest(idx((splitPoint + 1):end), 1);
    labelsTest = labelsTest(idx((splitPoint + 1):end), 1);
    if ~isempty(fileNamesTest)
        fileNamesTest = fileNamesTest(1, idx((splitPoint + 1):end));
    end
else
    if ratio == 1
        dataValTest = dataTest;
        labelsValTest = labelsTest;
    else
        dataTmp = dataTest{1, 1};
        labelsTmp = labelsTest{1, 1};
        dataValTest = cell(1, 1);
        labelsValTest = cell(1, 1);
        
        splitPoint = round(ratio * size(dataTmp, 1));
        
        dataValTest{1, 1} = dataTmp(1:(splitPoint - 1), 1);
        labelsValTest{1, 1} = labelsTmp(1:(splitPoint - 1), 1);
        dataTest{1, 1} = dataTmp(splitPoint:end, 1);
        labelsTest{1, 1} = labelsTmp(splitPoint:end, 1);        
    end
end
end
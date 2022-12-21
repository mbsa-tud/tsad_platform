function [dataTest, labelsTest, filesTest, dataTestVal, labelsTestVal, filesTestVal] = splitTestVal(dataTest, labelsTest, filesTest, ratio)
% SPLITTESTVAL 
% 
% Split testing data into testing set and test-validation set

if ratio == 0
    dataTestVal = [];
    labelsTestVal = [];
    filesTestVal = [];
    return;
end

if size(dataTest, 1) > 1
    idx = 1:size(dataTest, 1);
    splitPoint = min([floor(ratio * size(dataTest, 1)), size(dataTest, 1) - 1]);
    if splitPoint == 0
        splitPoint = 1;
    end

    dataTestVal = dataTest(idx(1:splitPoint), 1);
    labelsTestVal = labelsTest(idx(1:splitPoint), 1);
    dataTest = dataTest(idx((splitPoint + 1):end), 1);
    labelsTest = labelsTest(idx((splitPoint + 1):end), 1);

    if ~isempty(filesTest)
        filesTestVal = filesTest(1, idx(1:splitPoint));
        filesTest = filesTest(1, idx((splitPoint + 1):end));
    end
else
    filesTestVal = filesTest;

    dataTmp = dataTest{1, 1};
    labelsTmp = labelsTest{1, 1};
    dataTestVal = cell(1, 1);
    labelsTestVal = cell(1, 1);
    
    splitPoint = round(ratio * size(dataTmp, 1));
    
    dataTestVal{1, 1} = dataTmp(1:(splitPoint - 1), :);
    labelsTestVal{1, 1} = labelsTmp(1:(splitPoint - 1), :);
    dataTest{1, 1} = dataTmp(splitPoint:end, :);
    labelsTest{1, 1} = labelsTmp(splitPoint:end, :);        
end
end
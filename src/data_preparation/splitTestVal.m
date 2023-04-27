function [dataTest, labelsTest, fileNamesTest, dataTestVal, labelsTestVal, fileNamesTestVal] = splitTestVal(dataTest, labelsTest, fileNamesTest, ratio)
%SPLITTESTVAL Splits testing data into testing set and test-validation set
%(used for calculating static thresholds)

if ratio == 0
    dataTestVal = [];
    labelsTestVal = [];
    fileNamesTestVal = [];
    return;
end

numTestFiles = numel(dataTest);

if numTestFiles > 1    
    idx = 1:numTestFiles;
    splitPoint = min([floor(ratio * numTestFiles), numTestFiles - 1]);
    if splitPoint == 0
        splitPoint = 1;
    end

    dataTestVal = dataTest(idx(1:splitPoint));
    labelsTestVal = labelsTest(idx(1:splitPoint));
    dataTest = dataTest(idx((splitPoint + 1):end));
    labelsTest = labelsTest(idx((splitPoint + 1):end));

    if ~isempty(fileNamesTest)
        fileNamesTestVal = fileNamesTest(idx(1:splitPoint));
        fileNamesTest = fileNamesTest(idx((splitPoint + 1):end));
    end
else
    fileNamesTestVal = fileNamesTest;

    dataTmp = dataTest{1};
    labelsTmp = labelsTest{1};
    dataTestVal = cell(1, 1);
    labelsTestVal = cell(1, 1);
    
    splitPoint = round(ratio * size(dataTmp, 1));
    
    dataTestVal{1} = dataTmp(1:(splitPoint - 1), :);
    labelsTestVal{1} = labelsTmp(1:(splitPoint - 1), :);
    dataTest{1} = dataTmp(splitPoint:end, :);
    labelsTest{1} = labelsTmp(splitPoint:end, :);        
end
end
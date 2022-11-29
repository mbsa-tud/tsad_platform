function [dataTest, labelsTest, dataValTest, labelsValTest, filesTest, filesValTest] = splitTestVal(dataTest, labelsTest, ratio, filesTestFull)
% SPLITTESTVAL 
% 
% Split testing data into testing set and test-validation set

if size(dataTest, 1) > 1
    if ratio == 1
        filesTest = filesTestFull;
        filesValTest = {};
        dataValTest = [];
        labelsValTest = [];
    else
        idx = 1:size(dataTest, 1);
        splitPoint = min([floor(ratio * size(dataTest, 1)), size(dataTest, 1) - 1]);
        if splitPoint == 0
            splitPoint = 1;
        end

        dataValTest = dataTest(idx(1:splitPoint), 1);
        labelsValTest = labelsTest(idx(1:splitPoint), 1);
        dataTest = dataTest(idx((splitPoint + 1):end), 1);
        labelsTest = labelsTest(idx((splitPoint + 1):end), 1);
    
        if ~isempty(filesTestFull)
            filesTest = filesTestFull(1, idx((splitPoint + 1):end));
            filesValTest = filesTestFull(1, idx(1:splitPoint));
        end
    end
else
    filesTest = filesTestFull;
    filesValTest = filesTestFull;

    if ratio == 1
        dataValTest = [];
        labelsValTest = [];
    else
        dataTmp = dataTest{1, 1};
        labelsTmp = labelsTest{1, 1};
        dataValTest = cell(1, 1);
        labelsValTest = cell(1, 1);
        
        splitPoint = round(ratio * size(dataTmp, 1));
        
        dataValTest{1, 1} = dataTmp(1:(splitPoint - 1), :);
        labelsValTest{1, 1} = labelsTmp(1:(splitPoint - 1), :);
        dataTest{1, 1} = dataTmp(splitPoint:end, :);
        labelsTest{1, 1} = labelsTmp(splitPoint:end, :);        
    end
end
end
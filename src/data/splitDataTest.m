function [XTest, YTest, labelsTest] = splitDataTest(data, labels, windowSize, modelType, dataType, isMultivariate)
%SPLITDATATEST
%
% Splits the data for testing using the sliding window

if isMultivariate
    dataType = 2;
end

numChannels = size(data{1, 1}, 2);
numOfWindows = round((size(data{1, 1}, 1) - windowSize));

XTest = cell(1, numChannels);
YTest = cell(1, numChannels);
labelsTest = [];

% Get XTest and YTest for each channel of the test data
for ch_idx = 1:numChannels
    XTest_c = [];
    YTest_c = [];
    for i = 1:size(data, 1)      
        % XTest
        dataTmp = data{i, 1};
        XTestLag = lagmatrix(dataTmp(:, ch_idx), 1:windowSize);
        XTestAll = XTestLag((windowSize + 1):end, :);
        
        if dataType == 1
            XTestTmp = zeros(numOfWindows, windowSize);
            for j = 1:numOfWindows
                XTestTmp(j, :) = flip(XTestAll(j, :));
            end
        elseif dataType == 2
            XTestTmp = cell(numOfWindows, 1);
            for j = 1:numOfWindows
                XTestTmp{j, 1} = flip(XTestAll(j, :));
            end
        elseif dataType == 3
            XTestTmp = cell(numOfWindows, 1);
            for j = 1:numOfWindows
                XTestTmp{j, 1} = flip(XTestAll(j, :))';
            end
        end
    
        XTest_c = [XTest_c; XTestTmp];
        
        % YTest
        if strcmp(modelType, 'predictive')
            YTestCell = data{i, 1};
            YTestAll = YTestCell((windowSize + 1):end, ch_idx);
    
            YTestTmp = zeros(numOfWindows, 1);
            
            for j = 1:numOfWindows
                YTestTmp(j, 1) = YTestAll(j, :)';
            end
        else
            YTestCell = data{i, 1};
            YTestAll = YTestCell(windowSize:(end - windowSize), ch_idx);                  
            YTestTmp = zeros((numOfWindows - windowSize), 1);
    
            for j = 1:(numOfWindows - windowSize)
                YTestTmp(j, 1) = YTestAll(j, :)';
            end
        end
    
        YTest_c = [YTest_c; YTestTmp];        
    end    

    XTest{1, ch_idx} = XTest_c;
    YTest{1, ch_idx} = YTest_c;
end
for i = 1:size(data, 1)
    % Get labels
    if strcmp(modelType, 'predictive')    
        labelsCell = labels{i, 1};
        labelsAll = labelsCell((windowSize + 1):end, 1);
        labelsTestTmp= zeros(numOfWindows, 1);
        
        for j = 1:numOfWindows
            labelsTestTmp(j, 1) = logical(labelsAll(j, :))';
        end
    else
        labelsCell = labels{i, 1};
        labelsAll = labelsCell(windowSize:(end - windowSize), 1);   
        labelsTestTmp = zeros((numOfWindows - windowSize), 1);
        
        for j = 1:(numOfWindows - windowSize)
            labelsTestTmp(j, 1) = logical(labelsAll(j, :))';
        end
    end

    labelsTest = [labelsTest; labelsTestTmp];
end

if isMultivariate
    XTest_tmp = cell(numOfWindows, 1);
    for i = 1:numOfWindows
        for j = 1:numChannels
            XTest_tmp{i, 1} = [XTest_tmp{i, 1}; XTest{1, j}{i, 1}];
        end
    end
    XTest = cell(1, 1);
    XTest{1, 1} = XTest_tmp;
    
    YTest_tmp = cell2mat(YTest);
    YTest = cell(1, 1);
    YTest{1, 1} = YTest_tmp;
end
end

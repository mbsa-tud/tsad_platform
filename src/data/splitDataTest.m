function [XTest, YTest, labelsTest] = splitDataTest(data, labels, windowSize, modelType, dataType)
% SPLITDATATEST % split data for testing
%
% Description: apply slinding window on dataset for each channel and file
%              separately
%
% Input:  data: data
%         labels: labels
%         windowSize: double [1, inf] - size of the sliding window
%         modelType: string - one of (Predictive, Reconstructive)
%         dataType: double - this adjusts what shape the ouptut data should
%                            have together with the modelType
%                            see TSADPlatform_Documentation for more
%                            information                            
%
% Output: XTest
%         YTest
%         labelsTest

numChannels = size(data{1, 1}, 2);

XTest = cell(1, numChannels);
YTest = cell(1, numChannels);
labelsTest = [];
% Get XTest and YTest for each channel of the test data
for ch_idx = 1:numChannels
    XTest_c = [];
    YTest_c = [];
    for i = 1:size(data, 1)
        numOfWindows = round((size(data{i, 1}, 1) - windowSize));
        
        % XTest
        dataTmp = data{i, 1};
        XTestLag = lagmatrix(dataTmp(:, ch_idx), 1:windowSize);
        XTestAll = XTestLag((windowSize + 1):end,:);
        
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
        if strcmp(modelType, 'Predictive')
            YTestCell = data{i, 1};
            YTestAll = YTestCell((windowSize + 1):end, ch_idx);
    
            YTestTmp = zeros(numOfWindows, 1);
            
            for j = 1:numOfWindows
                YTestTmp(j, 1) = YTestAll(j, :)';
            end
        else
            YTestCell = data{i, 1};
            YTestAll = YTestCell(windowSize:end, ch_idx);                  
            YTestTmp = zeros(numOfWindows, 1);
    
            for j = 1:numOfWindows
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
    if strcmp(modelType, 'Predictive')    
        labelsCell = labels{i, 1};
        labelsAll = labelsCell((windowSize + 1):end, 1);
        labelsTestTmp= zeros(numOfWindows, 1);
        
        for j = 1:numOfWindows
            labelsTestTmp(j, 1) = logical(labelsAll(j, :))';
        end
    else
        labelsCell = labels{i, 1};
        labelsAll = labelsCell(windowSize:end, 1);   
        labelsTestTmp = zeros(numOfWindows, 1);
        
        for j = 1:numOfWindows
            labelsTestTmp(j, 1) = logical(labelsAll(j, :))';
        end
    end

    labelsTest = [labelsTest; labelsTestTmp];
end
end

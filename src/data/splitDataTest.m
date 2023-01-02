function [XTestOut, YTestOut, labelsTestOut] = splitDataTest(data, labels, windowSize, modelType, dataType, isMultivariate)
%SPLITDATATEST
%
% Splits the data for testing using the sliding window

% TODO: this function can be way simpler

if ~isMultivariate
    % For univariate models
    numChannels = size(data{1, 1}, 2);
    numWindows = round((size(data{1, 1}, 1) - windowSize));
    
    XTestOut = cell(1, numChannels);
    YTestOut = cell(1, numChannels);
    
    % Get XTest and YTest for each channel of the test data
    for ch_idx = 1:numChannels
        XTest_c = [];
        YTest_c = [];
      
        if dataType == 1
            XTestTmp = zeros(numWindows, windowSize);
            for j = 1:numWindows
                XTestTmp(j, :) = data{1, 1}(j:(j + windowSize - 1), ch_idx);
            end
        elseif dataType == 2
            XTestTmp = cell(numWindows, 1);
            for j = 1:numWindows
                XTestTmp{j, 1} = data{1, 1}(j:(j + windowSize - 1), ch_idx)';
            end
        elseif dataType == 3
            XTestTmp = cell(numWindows, 1);
            for j = 1:numWindows
                XTestTmp{j, 1} = data{1, 1}(j:(j + windowSize - 1), ch_idx);
            end
        end
    
        XTest_c = [XTest_c; XTestTmp];
        
        % YTest
        if strcmp(modelType, 'predictive')
            YTestTmp = data{1, 1}((windowSize + 1):end, ch_idx);
        else
            YTestTmp = data{1, 1}(windowSize:(end - windowSize - 1), ch_idx);
        end
    
        YTest_c = [YTest_c; YTestTmp];        
    
        XTestOut{1, ch_idx} = XTest_c;
        YTestOut{1, ch_idx} = YTest_c;
    end

    % Get labels
    if strcmp(modelType, 'predictive')    
        labelsTestOut = logical(labels{1, 1}((windowSize + 1):end, 1));
    else
        labelsTestOut = logical(labels{1, 1}(windowSize:(end - windowSize - 1), 1));
    end
else
    % For multivariate models
    numChannels = size(data{1, 1}, 2); 
    numWindows = round((size(data{1, 1}, 1) - windowSize));
    
    % XTest
    if dataType == 1
        flattenedWindowsSize = windowSize * numChannels;
        XTest = zeros(numWindows, flattenedWindowsSize);
        for j = 1:numWindows
            XTest(j, :) = reshape(data{1, 1}(j:(j + windowSize - 1), :)', ...
                    [1, flattenedWindowsSize]);
        end
        XTestOut = {XTest};
    elseif dataType == 2
        XTest = cell(numWindows, 1);
        for j = 1:numWindows
            XTest{j, 1} = data{1, 1}(j:(j + windowSize - 1), :)';
        end
        XTestOut = {XTest};
    end
    
    % YTest and labels
    if strcmp(modelType, 'predictive')
        YTestOut = {data{1, 1}((windowSize + 1):end, :)};
        labelsTestOut = logical(labels{1, 1}((windowSize + 1):end, 1));
    else
        YTestOut = {data{1, 1}(windowSize:(end - windowSize - 1), :)};
        labelsTestOut = logical(labels{1, 1}(windowSize:(end - windowSize - 1), 1));
    end
end
end

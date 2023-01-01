function [XTrain, YTrain, XVal, YVal] = splitDataTrain(data, windowSize, stepSize, ratioValTrain, modelType, dataType, isMultivariate)
%SPLITDATATRAIN
%
% Splits the data for training using a sliding sliding window

% TODO: this function can be way simpler

if ~isMultivariate
    % For univariate models
    numChannels = size(data{1, 1}, 2);
    
    XTrain = cell(1, numChannels);
    YTrain = cell(1, numChannels);
    XVal = cell(1, numChannels);
    YVal = cell(1, numChannels);
    
    for ch_idx = 1:numChannels
        XTrain_c = [];
        YTrain_c = [];
        for i = 1:size(data, 1)
            numOfWindows = round((size(data{i, 1}, 1) - windowSize - stepSize + 1) / stepSize);
    
            data_tmp = data{i, 1};
            XTrainLag = lagmatrix(data_tmp(:, ch_idx), 1:windowSize);
            XTrainAll = XTrainLag((windowSize + 1):end, :);                
            
            if dataType == 1
                XTrainTmp = zeros(numOfWindows, windowSize);
                for j = 1:numOfWindows
                    XTrainTmp(j, :) = flip(XTrainAll(j * stepSize, :));
                end
            elseif dataType == 2
                XTrainTmp = cell(numOfWindows, 1);
                for j = 1:numOfWindows
                    XTrainTmp{j, 1} = flip(XTrainAll(j * stepSize, :));
                end
            elseif dataType == 3
                XTrainTmp = cell(numOfWindows, 1);
                for j = 1:numOfWindows
                    XTrainTmp{j, 1} = flip(XTrainAll(j * stepSize, :))';
                end
            end
            
            XTrain_c = [XTrain_c; XTrainTmp];
    
            if strcmp(modelType, 'predictive')
                YTrainCell = data{i, 1};
                YTrainAll = YTrainCell((windowSize + 1):end, ch_idx);
    
                if dataType == 3
                    YTrainTmp = cell(numOfWindows, 1);
                    for j = 1:numOfWindows
                        YTrainTmp{j, 1} = YTrainAll((j * stepSize), 1);
                    end
                else
                    YTrainTmp = zeros(numOfWindows, 1);
                    for j = 1:numOfWindows
                        YTrainTmp(j, 1) = YTrainAll((j * stepSize), 1);
                    end
                end
    
                YTrain_c = [YTrain_c; YTrainTmp];
            else
                YTrain_c = XTrain_c;
            end
        end
    
        if ratioValTrain ~= 1
            numOfWindows = size(XTrain_c, 1);
        
            l = round(ratioValTrain * numOfWindows);
            
            XVal_c = XTrain_c((l + 1):end, :);
            YVal_c = YTrain_c((l + 1):end, :);
            XTrain_c = XTrain_c(1:l, :);
            YTrain_c = YTrain_c(1:l, :);
        else
            XVal_c = 0;
            YVal_c = 0;
        end
    
        XTrain{1, ch_idx} = XTrain_c;
        YTrain{1, ch_idx} = YTrain_c;
        XVal{1, ch_idx} = XVal_c;
        YVal{1, ch_idx} = YVal_c;
    end
else
    % For multivariate models
    numChannels = size(data{1, 1}, 2);
    
    XTrain = cell(1, numChannels);
    YTrain = cell(1, numChannels);
    XVal = cell(1, numChannels);
    YVal = cell(1, numChannels);
    
    for ch_idx = 1:numChannels
        XTrain_c = [];
        YTrain_c = [];
        for i = 1:size(data, 1)
            numOfWindows = round((size(data{i, 1}, 1) - windowSize - stepSize + 1) / stepSize);
    
            data_tmp = data{i, 1};
            XTrainLag = lagmatrix(data_tmp(:, ch_idx), 1:windowSize);
            XTrainAll = XTrainLag((windowSize + 1):end, :);                
            
            XTrainTmp = cell(numOfWindows, 1);
            for j = 1:numOfWindows
                XTrainTmp{j, 1} = flip(XTrainAll(j * stepSize, :));
            end
            
            XTrain_c = [XTrain_c; XTrainTmp];
    
            if strcmp(modelType, 'predictive')
                YTrainCell = data{i, 1};
                YTrainAll = YTrainCell((windowSize + 1):end, ch_idx);
    
                YTrainTmp = zeros(numOfWindows, 1);
                for j = 1:numOfWindows
                    YTrainTmp(j, 1) = YTrainAll((j * stepSize), 1);
                end
    
                YTrain_c = [YTrain_c; YTrainTmp];
            else
                YTrain_c = XTrain_c;
            end
        end
    
        if ratioValTrain ~= 1
            numOfWindows = size(XTrain_c, 1);
        
            l = round(ratioValTrain * numOfWindows);
            
            XVal_c = XTrain_c((l + 1):end, :);
            YVal_c = YTrain_c((l + 1):end, :);
            XTrain_c = XTrain_c(1:l, :);
            YTrain_c = YTrain_c(1:l, :);
        else
            XVal_c = 0;
            YVal_c = 0;
        end
    
        XTrain{1, ch_idx} = XTrain_c;
        YTrain{1, ch_idx} = YTrain_c;
        XVal{1, ch_idx} = XVal_c;
        YVal{1, ch_idx} = YVal_c;
    end


    numOfWindows_Train = size(XTrain{1, 1}, 1);
    XTrain_tmp = cell(numOfWindows_Train, 1);
    for i = 1:numOfWindows_Train
        for j = 1:numChannels
            XTrain_tmp{i, 1} = [XTrain_tmp{i, 1}; XTrain{1, j}{i, 1}];
        end
    end
    XTrain = cell(1, 1);
    XTrain{1, 1} = XTrain_tmp;
    
    if ratioValTrain ~= 1
        numOfWindows_Val = size(XVal{1, 1}, 1);
        XVal_tmp = cell(numOfWindows_Val, 1);
        for i = 1:numOfWindows_Val
            for j = 1:numChannels
                XVal_tmp{i, 1} = [XVal_tmp{i, 1}; XVal{1, j}{i, 1}];
            end
        end
        XVal = cell(1, 1);
        XVal{1, 1} = XVal_tmp;
    end

    
    if strcmp(modelType, 'reconstructive')
        YTrain = XTrain;
        YVal = XVal;
    else
        YTrain_tmp = zeros(numOfWindows_Train, numChannels);
        for i = 1:numOfWindows_Train
            for j = 1:numChannels
                YTrain_tmp(i, j) = YTrain{1, j}(i, 1);
            end
        end
        YTrain = cell(1, 1);
        YTrain{1, 1} = YTrain_tmp;

        if ratioValTrain ~= 1
            YVal_tmp = zeros(numOfWindows_Val, numChannels);
            for i = 1:numOfWindows_Val
                for j = 1:numChannels
                    YVal_tmp(i, j) = YVal{1, j}(i, 1);
                end
            end
            YVal = cell(1, 1);
            YVal{1, 1} = YVal_tmp;
        end
    end
end
end

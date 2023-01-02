function [XTrainOut, YTrainOut, XValOut, YValOut] = splitDataTrain(data, windowSize, stepSize, ratioTrainVal, modelType, dataType, isMultivariate)
%SPLITDATATRAIN
%
% Splits the data for training using a sliding sliding window

% TODO: this function can be way simpler

if ~isMultivariate
    % For univariate models
    numChannels = size(data{1, 1}, 2);
    
    XTrainOut = cell(1, numChannels);
    YTrainOut = cell(1, numChannels);
    XValOut = cell(1, numChannels);
    YValOut = cell(1, numChannels);
    
    for ch_idx = 1:numChannels
        XTrain_c = [];
        YTrain_c = [];
        for i = 1:size(data, 1)
            numWindows = round((size(data{i, 1}, 1) - windowSize - stepSize + 1) / stepSize);

            if dataType == 1
                XTrainTmp = zeros(numWindows, windowSize);
                for j = 1:numWindows
                    XTrainTmp(j, :) = data{i, 1}((j * stepSize):(j * stepSize + windowSize - 1), ch_idx);
                end
            elseif dataType == 2
                XTrainTmp = cell(numWindows, 1);
                for j = 1:numWindows
                    XTrainTmp{j, 1} = data{i, 1}((j * stepSize):(j * stepSize + windowSize - 1), ch_idx)';
                end
            elseif dataType == 3
                XTrainTmp = cell(numWindows, 1);
                for j = 1:numWindows
                    XTrainTmp{j, 1} = data{i, 1}((j * stepSize):(j * stepSize + windowSize - 1), ch_idx);
                end
            end
            
            XTrain_c = [XTrain_c; XTrainTmp];
    
            if strcmp(modelType, 'predictive')
                if dataType == 3
                    YTrainTmp = cell(numWindows, 1);
                    for j = 1:numWindows
                        YTrainTmp{j, 1} = data{i, 1}((((j - 1) * stepSize) + windowSize + 1), ch_idx);
                    end
                else
                    YTrainTmp = zeros(numWindows, 1);
                    for j = 1:numWindows
                        YTrainTmp(j, 1) = data{i, 1}((((j - 1) * stepSize) + windowSize + 1), ch_idx);
                    end
                end
    
                YTrain_c = [YTrain_c; YTrainTmp];
            else
                YTrain_c = XTrain_c;
            end
        end
    
        if ratioTrainVal ~= 1
            numWindows = size(XTrain_c, 1);
        
            l = round(ratioTrainVal * numWindows);
            
            XVal_c = XTrain_c((l + 1):end, :);
            YVal_c = YTrain_c((l + 1):end, :);
            XTrain_c = XTrain_c(1:l, :);
            YTrain_c = YTrain_c(1:l, :);
        else
            XVal_c = [];
            YVal_c = [];
        end
    
        XTrainOut{1, ch_idx} = XTrain_c;
        YTrainOut{1, ch_idx} = YTrain_c;
        XValOut{1, ch_idx} = XVal_c;
        YValOut{1, ch_idx} = YVal_c;
    end
else
    % For multivariate models 
    XTrain = [];
    YTrain = [];

    numChannels = size(data{1, 1}, 2);
    
    for i = 1:size(data, 1)
        numWindows = round((size(data{i, 1}, 1) - windowSize - stepSize + 1) / stepSize);
        
        if dataType == 1
            flattenedWindowsSize = windowSize * numChannels;
            XTrainTmp = zeros(numWindows, flattenedWindowsSize);
            for j = 1:numWindows
                XTrainTmp(j, :) = reshape(data{i, 1}((j * stepSize):(j * stepSize + windowSize - 1), :)', ...
                    [1, flattenedWindowsSize]);
            end
        elseif dataType == 2
            XTrainTmp = cell(numWindows, 1);
            for j = 1:numWindows
                XTrainTmp{j, 1} = data{i, 1}((j * stepSize):(j * stepSize + windowSize - 1), :)';
            end
        end     
        
        XTrain = [XTrain; XTrainTmp];

        if strcmp(modelType, 'predictive')
            YTrainTmp = zeros(numWindows, numChannels);
            for j = 1:numWindows
                YTrainTmp(j, :) = data{i, 1}((((j - 1) * stepSize) + windowSize + 1), :);
            end

            YTrain = [YTrain; YTrainTmp];
        else
            YTrain = XTrain;
        end
    end

    if ratioTrainVal ~= 1
        numWindows = size(XTrain, 1);
    
        l = round(ratioTrainVal * numWindows);
        
        XVal = XTrain((l + 1):end, :);
        YVal = YTrain((l + 1):end, :);
        XTrain = XTrain(1:l, :);
        YTrain = YTrain(1:l, :);
    else
        XVal = [];
        YVal = [];
    end

    XTrainOut = {XTrain};
    YTrainOut = {YTrain};
    XValOut = {XVal};
    YValOut = {YVal};
end

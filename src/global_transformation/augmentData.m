function [augmentedTrainingData, augmentedTestingData] = augmentData(rawTrainingData, rawTestingData, method, level, augmentTrainingData)
% AUGMENTATIONDATA Augment the data

augmentedTrainingData = rawTrainingData;
augmentedTestingData = [];

if ~isempty(rawTestingData)
    fullData = [];
    for data_idx = 1:numel(rawTestingData)
        fullData = [fullData; rawTestingData{data_idx}];
    end
    maximum = max(fullData);
    minimum = min(fullData);
    mu = mean(fullData);

    switch method
        case "white noise"
            augmentedTestingData = addWhiteNoise(rawTestingData, maximum, minimum, level);
        case "random walk"
            augmentedTestingData = addRandomWalk(rawTestingData, maximum, minimum, level);
        case "global shift"
            augmentedTestingData = shiftData(rawTestingData, maximum, level);
        case "attenuate extremum"
            augmentedTestingData = attenuateExtremum(rawTestingData, mu, level);
    end
end


if augmentTrainingData
    if ~isempty(rawTrainingData)
        fullData = [];
        for data_idx = 1:numel(rawTrainingData)
            fullData = [fullData; rawTrainingData{data_idx}];
        end
        maximum = max(fullData);
        minimum = min(fullData);
        mu = mean(fullData);

        switch method
            case "white noise"
                augmentedTrainingData = addWhiteNoise(rawTrainingData, maximum, minimum, level);
            case "random walk"
                augmentedTrainingData = addRandomWalk(rawTrainingData, maximum, minimum, level);
            case "global shift"
                augmentedTrainingData = shiftData(rawTrainingData, maximum, level);
            case "attenuate extremum"
                augmentedTrainingData = attenuateExtremum(rawTrainingData, mu, level);
        end
    end
end
end


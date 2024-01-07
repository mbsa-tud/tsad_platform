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
        case "none"
            augmentedTestingData = rawTestingData;
        case "white_noise"
            augmentedTestingData = addWhiteNoise(rawTestingData, maximum, minimum, level);
        case "random_walk"
            augmentedTestingData = addRandomWalk(rawTestingData, maximum, minimum, level);
        case "global_shift"
            augmentedTestingData = shiftData(rawTestingData, maximum, level);
        case "attenuate_extremum"
            augmentedTestingData = attenuateExtremum(rawTestingData, mu, level);
        otherwise
            error("unknown augmentation method");
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
            case "none"
                augmentedTrainingData = rawTrainingData;
            case "white_noise"
                augmentedTrainingData = addWhiteNoise(rawTrainingData, maximum, minimum, level);
            case "random_walk"
                augmentedTrainingData = addRandomWalk(rawTrainingData, maximum, minimum, level);
            case "global_shift"
                augmentedTrainingData = shiftData(rawTrainingData, maximum, level);
            case "attenuate_extremum"
                augmentedTrainingData = attenuateExtremum(rawTrainingData, mu, level);
            otherwise
                error("unknown augmentation method");
        end
    end
end
end


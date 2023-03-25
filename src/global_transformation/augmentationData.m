function [augmentedTrainingData, augmentedTestingData] = augmentationData(rawTrainingData, rawTestingData, choice_aug, intensity, trained)
% AUGMENTATIONDATA Augment the data

augmentedTrainingData = rawTrainingData;
augmentedTestingData = [];
method = choice_aug;
level = intensity;




if ~isempty(rawTestingData)
    fullData = [];
    for data_idx = 1:size(rawTestingData, 1)
        fullData = [fullData; rawTestingData{data_idx, 1}];
    end
    maximum = max(fullData);
    minimum = min(fullData);
    mu = mean(fullData);

    switch method
        case 'white noise'
            augmentedTestingData = addWhiteNoise(rawTestingData, maximum, minimum, level);
        case 'random walk'
            augmentedTestingData = addRandomWalk(rawTestingData, maximum, minimum, level);
        case 'global shift'
            augmentedTestingData = shiftData(rawTestingData, maximum, minimum, level);
        case 'attenuate extremum'
            augmentedTestingData = attenuateExtremum(rawTestingData, mu, level);
    end
end


if trained
    if ~isempty(rawTrainingData)
        fullData = [];
        for data_idx = 1:size(rawTrainingData, 1)
            fullData = [fullData; rawTrainingData{data_idx, 1}];
        end
        maximum = max(fullData);
        minimum = min(fullData);
        mu = mean(fullData);

        switch method
            case 'white noise'
                augmentedTrainingData = addWhiteNoise(rawTrainingData, maximum, minimum, level);
            case 'random walk'
                augmentedTrainingData = addRandomWalk(rawTrainingData, maximum, minimum, level);
            case 'global shift'
                augmentedTrainingData = shiftData(rawTrainingData, maximum, minimum, level);
            case 'attenuate extremum'
                augmentedTrainingData = attenuateExtremum(rawTrainingData, mu, level);
        end
    end
end
end


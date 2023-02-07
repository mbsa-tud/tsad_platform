function [augmentedTrainingData, augmentedTestingData] = augmentationData(rawTrainingData, rawTestingData, choice_aug,intensity,trained)
% AUGMENTATIONDATA
%
% Augmented the data

augmentedTrainingData = rawTrainingData;
augmentedTestingData = [];
maximum =[];
minimum =[];
method = choice_aug;
level = intensity;




if ~isempty(rawTestingData)
    numFiles = size(rawTestingData, 1);
    numChannels = size(rawTestingData{1, 1}, 2);

    maxima = zeros(numFiles, numChannels);
    minima = zeros(numFiles, numChannels);
    for i = 1:numFiles
        maxima(i, :) =  max(rawTestingData{i, 1}, [], 1);
        minima(i, :) =  min(rawTestingData{i, 1}, [], 1);
    end
    maximum = max(maxima, [], 1);
    minimum = min(minima, [], 1);

    switch method
        case 'white noise'
            augmentedTestingData = addWhiteNoise(rawTestingData,  maximum, minimum,level);
        case 'random walk'
            augmentedTestingData = addRandomWalk(rawTestingData,  maximum,minimum,level);
        case 'global shift'
            augmentedTestingData = shiftData(rawTestingData,maximum, minimum,level);
        case 'attenuate extremum'
            augmentedTestingData = attenuateExtremum(rawTestingData,maximum,minimum,level);

    end

end


if trained
    if ~isempty(rawTrainingData)
        numFiles = size(rawTrainingData, 1);
        numChannels = size(rawTrainingData{1, 1}, 2);

        maxima = zeros(numFiles, numChannels);
        minima = zeros(numFiles, numChannels);
        for i = 1:numFiles
            maxima(i, :) =  max(rawTrainingData{i, 1}, [], 1);
            minima(i, :) =  min(rawTrainingData{i, 1}, [], 1);
        end
        maximum = max(maxima, [], 1);
        minimum = min(minima, [], 1);

        switch method
            case 'white noise'
                augmentedTrainingData = addWhiteNoise(rawTrainingData,  maximum, minimum,level);
            case 'random walk'
                augmentedTrainingData = addRandomWalk(rawTrainingData,  maximum,minimum,level);
            case 'global shift'
                augmentedTrainingData = shiftData(rawTrainingData,maximum, minimum,level);
            case 'attenuate extremum'
                augmentedTrainingData = attenuateExtremum(rawTrainingData,maximum,minimum,level);

        end
    end
end
end


function augmentedData = applyDataAugmentation(data, choice, intensity)
    switch choice
        case 'white noise'
            augmentedData = addWhiteNoise(data, intensity);
        case 'random walk'
            augmentedData = addRandomWalk(data, intensity);
        case 'global shift'
            augmentedData = shiftData(data, intensity);
        case 'attenuate extremum'
            augmentedData = attenuateExtremum(data, intensity);
        
    end
end
